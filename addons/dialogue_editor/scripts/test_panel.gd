@tool
extends PanelContainer
## Test panel for in-editor dialogue testing.
## Displays dialogue content, choices, and simulated state.

signal test_started()
signal test_stopped()
signal node_highlighted(node_id: String)
signal node_unhighlighted()

const DialogueRunnerScript = preload("res://addons/dialogue_editor/scripts/dialogue_runner.gd")

# Runner instance
var _runner: DialogueRunnerScript
var _canvas: GraphEdit

# UI References
var _speaker_label: Label
var _dialogue_text: RichTextLabel
var _portrait_rect: TextureRect
var _choices_container: VBoxContainer
var _continue_btn: Button
var _state_container: VBoxContainer
var _flags_list: ItemList
var _quests_list: ItemList
var _reputation_list: ItemList
var _items_list: ItemList

# Control bar references
var _back_btn: Button
var _restart_btn: Button
var _stop_btn: Button
var _skip_dropdown: OptionButton
var _skill_check_toggle: CheckButton
var _coverage_label: Label

# Currently highlighted node
var _highlighted_node: GraphNode = null
var _original_node_style: StyleBox = null


func _ready() -> void:
	_setup_ui()
	_setup_runner()


func _setup_ui() -> void:
	name = "TestPanel"
	custom_minimum_size = Vector2(350, 0)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)

	# Title bar
	var title_bar = _create_title_bar()
	main_vbox.add_child(title_bar)

	# Control bar (back, restart, stop, skip)
	var control_bar = _create_control_bar()
	main_vbox.add_child(control_bar)

	main_vbox.add_child(HSeparator.new())

	# Dialogue display area
	var dialogue_area = _create_dialogue_area()
	main_vbox.add_child(dialogue_area)

	# Choices area
	var choices_area = _create_choices_area()
	main_vbox.add_child(choices_area)

	main_vbox.add_child(HSeparator.new())

	# State display (collapsible)
	var state_area = _create_state_area()
	main_vbox.add_child(state_area)

	# Coverage display
	var coverage_bar = _create_coverage_bar()
	main_vbox.add_child(coverage_bar)


func _create_title_bar() -> HBoxContainer:
	var bar = HBoxContainer.new()

	var title = Label.new()
	title.text = "Dialogue Test"
	title.add_theme_font_size_override("font_size", 16)
	bar.add_child(title)

	bar.add_child(_create_spacer())

	# Skill check toggle
	_skill_check_toggle = CheckButton.new()
	_skill_check_toggle.text = "Pass Skill Checks"
	_skill_check_toggle.button_pressed = true
	_skill_check_toggle.toggled.connect(_on_skill_check_toggled)
	_skill_check_toggle.tooltip_text = "Toggle whether skill checks automatically pass or fail"
	bar.add_child(_skill_check_toggle)

	return bar


func _create_control_bar() -> HBoxContainer:
	var bar = HBoxContainer.new()

	_back_btn = Button.new()
	_back_btn.text = "Back"
	_back_btn.tooltip_text = "Go back to previous choice"
	_back_btn.pressed.connect(_on_back_pressed)
	_back_btn.disabled = true
	bar.add_child(_back_btn)

	_restart_btn = Button.new()
	_restart_btn.text = "Restart"
	_restart_btn.tooltip_text = "Restart from beginning"
	_restart_btn.pressed.connect(_on_restart_pressed)
	bar.add_child(_restart_btn)

	_stop_btn = Button.new()
	_stop_btn.text = "Stop"
	_stop_btn.tooltip_text = "Stop testing"
	_stop_btn.pressed.connect(_on_stop_pressed)
	bar.add_child(_stop_btn)

	bar.add_child(_create_spacer())

	# Skip to node dropdown
	var skip_label = Label.new()
	skip_label.text = "Skip to:"
	bar.add_child(skip_label)

	_skip_dropdown = OptionButton.new()
	_skip_dropdown.custom_minimum_size = Vector2(120, 0)
	_skip_dropdown.tooltip_text = "Jump to a specific node"
	_skip_dropdown.item_selected.connect(_on_skip_selected)
	bar.add_child(_skip_dropdown)

	return bar


func _create_dialogue_area() -> VBoxContainer:
	var area = VBoxContainer.new()

	# Speaker row with portrait
	var speaker_row = HBoxContainer.new()

	_portrait_rect = TextureRect.new()
	_portrait_rect.custom_minimum_size = Vector2(48, 48)
	_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_rect.visible = false
	speaker_row.add_child(_portrait_rect)

	_speaker_label = Label.new()
	_speaker_label.text = "Speaker"
	_speaker_label.add_theme_font_size_override("font_size", 14)
	_speaker_label.add_theme_color_override("font_color", Color.CYAN)
	speaker_row.add_child(_speaker_label)

	area.add_child(speaker_row)

	# Dialogue text
	_dialogue_text = RichTextLabel.new()
	_dialogue_text.custom_minimum_size = Vector2(0, 80)
	_dialogue_text.bbcode_enabled = true
	_dialogue_text.fit_content = true
	_dialogue_text.scroll_active = true
	_dialogue_text.text = "[i]Start a test to see dialogue here[/i]"
	area.add_child(_dialogue_text)

	# Continue button (hidden when choices available)
	_continue_btn = Button.new()
	_continue_btn.text = "Continue"
	_continue_btn.pressed.connect(_on_continue_pressed)
	_continue_btn.visible = false
	area.add_child(_continue_btn)

	return area


func _create_choices_area() -> VBoxContainer:
	var area = VBoxContainer.new()

	var choices_label = Label.new()
	choices_label.text = "Choices:"
	choices_label.add_theme_font_size_override("font_size", 12)
	choices_label.modulate = Color(1, 1, 1, 0.7)
	area.add_child(choices_label)

	_choices_container = VBoxContainer.new()
	area.add_child(_choices_container)

	return area


func _create_state_area() -> VBoxContainer:
	var area = VBoxContainer.new()

	var state_label = Label.new()
	state_label.text = "Simulated State:"
	state_label.add_theme_font_size_override("font_size", 12)
	state_label.modulate = Color(1, 1, 1, 0.7)
	area.add_child(state_label)

	_state_container = VBoxContainer.new()
	area.add_child(_state_container)

	# Create tabs for different state types
	var tab_container = TabContainer.new()
	tab_container.custom_minimum_size = Vector2(0, 120)

	# Flags tab
	var flags_scroll = ScrollContainer.new()
	flags_scroll.name = "Flags"
	_flags_list = ItemList.new()
	_flags_list.custom_minimum_size = Vector2(0, 100)
	flags_scroll.add_child(_flags_list)
	tab_container.add_child(flags_scroll)

	# Quests tab
	var quests_scroll = ScrollContainer.new()
	quests_scroll.name = "Quests"
	_quests_list = ItemList.new()
	_quests_list.custom_minimum_size = Vector2(0, 100)
	quests_scroll.add_child(_quests_list)
	tab_container.add_child(quests_scroll)

	# Reputation tab
	var rep_scroll = ScrollContainer.new()
	rep_scroll.name = "Rep"
	_reputation_list = ItemList.new()
	_reputation_list.custom_minimum_size = Vector2(0, 100)
	rep_scroll.add_child(_reputation_list)
	tab_container.add_child(rep_scroll)

	# Items tab
	var items_scroll = ScrollContainer.new()
	items_scroll.name = "Items"
	_items_list = ItemList.new()
	_items_list.custom_minimum_size = Vector2(0, 100)
	items_scroll.add_child(_items_list)
	tab_container.add_child(items_scroll)

	_state_container.add_child(tab_container)

	return area


func _create_coverage_bar() -> HBoxContainer:
	var bar = HBoxContainer.new()

	_coverage_label = Label.new()
	_coverage_label.text = "Coverage: 0%"
	_coverage_label.add_theme_font_size_override("font_size", 11)
	_coverage_label.modulate = Color(1, 1, 1, 0.6)
	bar.add_child(_coverage_label)

	return bar


func _create_spacer() -> Control:
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spacer


func _setup_runner() -> void:
	_runner = DialogueRunnerScript.new()
	_runner.dialogue_started.connect(_on_dialogue_started)
	_runner.dialogue_ended.connect(_on_dialogue_ended)
	_runner.node_entered.connect(_on_node_entered)
	_runner.choices_available.connect(_on_choices_available)
	_runner.state_changed.connect(_on_state_changed)


## Set the canvas reference and start testing.
func start_test(canvas: GraphEdit) -> void:
	_canvas = canvas
	_runner.setup(canvas)
	_runner.start()
	_populate_skip_dropdown()
	test_started.emit()


## Stop the current test.
func stop_test() -> void:
	_runner.stop()
	_unhighlight_current_node()
	_clear_display()
	test_stopped.emit()


## Check if test is running.
func is_testing() -> bool:
	return _runner.is_running


func _populate_skip_dropdown() -> void:
	_skip_dropdown.clear()
	_skip_dropdown.add_item("-- Select --")

	var node_ids = _runner.get_all_node_ids()
	for node_id in node_ids:
		_skip_dropdown.add_item(node_id)


func _clear_display() -> void:
	_speaker_label.text = "Speaker"
	_dialogue_text.text = "[i]Start a test to see dialogue here[/i]"
	_portrait_rect.visible = false
	_clear_choices()
	_continue_btn.visible = false
	_update_state_display()
	_update_coverage_display()


func _clear_choices() -> void:
	for child in _choices_container.get_children():
		child.queue_free()


func _update_state_display() -> void:
	# Update flags list
	_flags_list.clear()
	for flag_name in _runner.flags:
		_flags_list.add_item("%s = %s" % [flag_name, _runner.flags[flag_name]])

	# Update quests list
	_quests_list.clear()
	for quest_id in _runner.quests:
		var status = _runner.quests[quest_id]
		var color = Color.WHITE
		match status:
			"active": color = Color.YELLOW
			"complete": color = Color.GREEN
			"failed": color = Color.RED
		var idx = _quests_list.add_item("%s: %s" % [quest_id, status])
		_quests_list.set_item_custom_fg_color(idx, color)

	# Update reputation list
	_reputation_list.clear()
	for faction in _runner.reputation:
		var amount = _runner.reputation[faction]
		var color = Color.GREEN if amount > 0 else (Color.RED if amount < 0 else Color.WHITE)
		var sign = "+" if amount > 0 else ""
		var idx = _reputation_list.add_item("%s: %s%d" % [faction, sign, amount])
		_reputation_list.set_item_custom_fg_color(idx, color)

	# Update items list
	_items_list.clear()
	for item_id in _runner.items:
		var qty = _runner.items[item_id]
		if qty > 0:
			_items_list.add_item("%s x%d" % [item_id, qty])


func _update_coverage_display() -> void:
	var coverage = _runner.get_coverage_percent()
	_coverage_label.text = "Coverage: %.0f%% (%d/%d)" % [
		coverage,
		_runner.visited_nodes.size(),
		_runner.get_all_node_ids().size()
	]


func _highlight_node(node_id: String) -> void:
	_unhighlight_current_node()

	if not _canvas:
		return

	var node = _canvas.get_node_or_null(NodePath(node_id))
	if node and node is GraphNode:
		_highlighted_node = node

		# Create highlight style
		var highlight_style = StyleBoxFlat.new()
		highlight_style.bg_color = Color(1.0, 0.8, 0.0, 0.3)
		highlight_style.border_color = Color.YELLOW
		highlight_style.set_border_width_all(4)
		highlight_style.set_corner_radius_all(4)

		# Store original style and apply highlight
		_original_node_style = node.get_theme_stylebox("panel")
		node.add_theme_stylebox_override("panel", highlight_style)

		# Also highlight when selected
		node.add_theme_stylebox_override("panel_selected", highlight_style)

		node_highlighted.emit(node_id)


func _unhighlight_current_node() -> void:
	if _highlighted_node and is_instance_valid(_highlighted_node):
		# Restore original style
		if _original_node_style:
			_highlighted_node.add_theme_stylebox_override("panel", _original_node_style)
		else:
			_highlighted_node.remove_theme_stylebox_override("panel")

		_highlighted_node.remove_theme_stylebox_override("panel_selected")
		node_unhighlighted.emit()

	_highlighted_node = null
	_original_node_style = null


# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_dialogue_started() -> void:
	_back_btn.disabled = not _runner.can_go_back()


func _on_dialogue_ended(end_type: String) -> void:
	_dialogue_text.text = "[i]Dialogue ended (%s)[/i]" % end_type
	_clear_choices()
	_continue_btn.visible = false
	_unhighlight_current_node()


func _on_node_entered(node_id: String, node_data: Dictionary) -> void:
	_highlight_node(node_id)
	_back_btn.disabled = not _runner.can_go_back()
	_update_coverage_display()

	var node_type = node_data.get("type", "")

	match node_type:
		"Speaker":
			_display_speaker_node(node_data)
		"Choice":
			# Choices are handled via choices_available signal
			pass
		"Branch", "SkillCheck", "FlagCheck", "FlagSet", "Quest", "Reputation", "Item":
			# Action/condition nodes process automatically
			_display_action_node(node_type, node_data)
		"End":
			# Handled by dialogue_ended signal
			pass


func _display_speaker_node(node_data: Dictionary) -> void:
	var speaker = node_data.get("speaker", "NPC")
	var text = node_data.get("text", "")
	var portrait = node_data.get("portrait", "")

	_speaker_label.text = speaker

	# Color by speaker
	var color = Color.CYAN
	match speaker:
		"Narrator": color = Color.GRAY
		"Player": color = Color.DODGER_BLUE
		"Guard": color = Color.DARK_RED
		"Merchant": color = Color.GOLD

	_speaker_label.add_theme_color_override("font_color", color)
	_dialogue_text.text = text

	# Portrait (if available)
	if not portrait.is_empty() and ResourceLoader.exists(portrait):
		_portrait_rect.texture = load(portrait)
		_portrait_rect.visible = true
	else:
		_portrait_rect.visible = false


func _display_action_node(node_type: String, node_data: Dictionary) -> void:
	# Brief display of action nodes as they're processed
	var display_text = "[i]Processing: %s[/i]" % node_type

	match node_type:
		"FlagSet":
			display_text = "[i]Setting flag: %s = %s[/i]" % [
				node_data.get("flag_name", ""),
				node_data.get("flag_value", "true")
			]
		"Quest":
			display_text = "[i]Quest: %s - %s[/i]" % [
				node_data.get("quest_id", ""),
				node_data.get("quest_action", "Start")
			]
		"Reputation":
			var amount = node_data.get("amount", 0)
			var sign = "+" if amount > 0 else ""
			display_text = "[i]Reputation: %s %s%d[/i]" % [
				node_data.get("faction", ""),
				sign,
				amount
			]
		"Item":
			display_text = "[i]Item: %s %s x%d[/i]" % [
				node_data.get("item_action", "Give"),
				node_data.get("item_id", ""),
				node_data.get("quantity", 1)
			]
		"SkillCheck":
			var result = "PASS" if _runner.skill_check_auto_pass else "FAIL"
			display_text = "[i]Skill Check: %s DC %d - %s[/i]" % [
				node_data.get("skill", ""),
				node_data.get("difficulty_class", 10),
				result
			]
		"FlagCheck", "Branch":
			display_text = "[i]Checking condition...[/i]"

	_speaker_label.text = "System"
	_speaker_label.add_theme_color_override("font_color", Color.GRAY)
	_dialogue_text.text = display_text


func _on_choices_available(choices: Array[Dictionary]) -> void:
	_clear_choices()

	if choices.is_empty():
		# No choices, show continue button
		_continue_btn.visible = true
		return

	_continue_btn.visible = false

	for i in choices.size():
		var choice = choices[i]
		var btn = Button.new()
		btn.text = "%d. %s" % [i + 1, choice.get("text", "...")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice_selected.bind(i))

		# Style the choice button
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.3, 0.5, 0.8)
		style.border_color = Color.DODGER_BLUE
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		btn.add_theme_stylebox_override("normal", style)

		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.3, 0.4, 0.6, 0.9)
		btn.add_theme_stylebox_override("hover", hover_style)

		_choices_container.add_child(btn)


func _on_state_changed() -> void:
	_update_state_display()


func _on_choice_selected(choice_index: int) -> void:
	_runner.select_choice(choice_index)


func _on_continue_pressed() -> void:
	_runner.continue_dialogue()


func _on_back_pressed() -> void:
	_runner.go_back()


func _on_restart_pressed() -> void:
	_runner.restart()


func _on_stop_pressed() -> void:
	stop_test()


func _on_skip_selected(index: int) -> void:
	if index == 0:
		return  # "-- Select --" option

	var node_id = _skip_dropdown.get_item_text(index)
	_runner.jump_to_node(node_id)
	_skip_dropdown.select(0)  # Reset to "-- Select --"


func _on_skill_check_toggled(pressed: bool) -> void:
	_runner.set_skill_check_mode(pressed)
