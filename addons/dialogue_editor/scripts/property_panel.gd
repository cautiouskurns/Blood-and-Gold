@tool
class_name DialoguePropertyPanel
extends PanelContainer
## Slide-out panel for editing selected node properties.
## Provides larger, more user-friendly editors than inline node editing.

signal property_changed(node: GraphNode, property: String, value: Variant)

const SpeakerColorsScript = preload("res://addons/dialogue_editor/scripts/speaker_colors.gd")

# Animation configuration
const SLIDE_DURATION := 0.2
const PANEL_WIDTH := 320

# Current state
var _selected_node: GraphNode = null
var _is_visible := false
var _tween: Tween = null

# UI containers
var _scroll: ScrollContainer
var _content: VBoxContainer
var _header: Label
var _node_id_label: Label
var _properties_container: VBoxContainer

# Common editors (cached for performance)
var _editors: Dictionary = {}


func _ready() -> void:
	_setup_panel()
	_setup_ui()
	# Start hidden off-screen
	custom_minimum_size.x = PANEL_WIDTH
	position.x = PANEL_WIDTH  # Hidden to the right
	visible = true  # Always visible but positioned off-screen


func _setup_panel() -> void:
	# Panel styling
	custom_minimum_size = Vector2(PANEL_WIDTH, 400)
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Create panel style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.18, 0.98)
	style.border_color = Color(0.3, 0.3, 0.35)
	style.set_border_width_all(1)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	add_theme_stylebox_override("panel", style)


func _setup_ui() -> void:
	# Main scroll container
	_scroll = ScrollContainer.new()
	_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)

	# Content container
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_content)

	# Header
	_header = Label.new()
	_header.text = "Node Properties"
	_header.add_theme_font_size_override("font_size", 16)
	_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_content.add_child(_header)

	# Separator
	var sep = HSeparator.new()
	_content.add_child(sep)

	# Node ID display
	var id_row = HBoxContainer.new()
	var id_label = Label.new()
	id_label.text = "Node ID:"
	id_label.custom_minimum_size = Vector2(70, 0)
	id_row.add_child(id_label)

	_node_id_label = Label.new()
	_node_id_label.text = "(none)"
	_node_id_label.modulate = Color(0.7, 0.7, 0.7)
	id_row.add_child(_node_id_label)
	_content.add_child(id_row)

	# Separator
	var sep2 = HSeparator.new()
	_content.add_child(sep2)

	# Properties container (populated dynamically)
	_properties_container = VBoxContainer.new()
	_properties_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(_properties_container)


## Show the panel with properties for the selected node.
func show_for_node(node: GraphNode) -> void:
	if node == _selected_node and _is_visible:
		return

	_selected_node = node
	_populate_properties()
	_slide_in()


## Hide the panel.
func hide_panel() -> void:
	_slide_out()
	_selected_node = null


## Check if panel is currently visible.
func is_panel_visible() -> bool:
	return _is_visible


## Get the currently selected node.
func get_selected_node() -> GraphNode:
	return _selected_node


# =============================================================================
# ANIMATION
# =============================================================================

func _slide_in() -> void:
	if _is_visible:
		return

	_is_visible = true

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "position:x", 0.0, SLIDE_DURATION)


func _slide_out() -> void:
	if not _is_visible:
		return

	_is_visible = false

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "position:x", float(PANEL_WIDTH), SLIDE_DURATION)


# =============================================================================
# PROPERTY POPULATION
# =============================================================================

func _populate_properties() -> void:
	# Clear existing editors
	for child in _properties_container.get_children():
		child.queue_free()
	_editors.clear()

	if not _selected_node:
		_header.text = "Node Properties"
		_node_id_label.text = "(none)"
		return

	# Update header
	var node_type = _selected_node.get("node_type") if _selected_node.get("node_type") else "Unknown"
	_header.text = "%s Properties" % node_type

	# Update node ID
	var node_id = _selected_node.get("node_id") if _selected_node.get("node_id") else _selected_node.name
	_node_id_label.text = node_id

	# Populate based on node type
	match node_type:
		"Start":
			_add_info_label("Start node has no editable properties.")
		"Speaker":
			_populate_speaker_properties()
		"Choice":
			_populate_choice_properties()
		"Branch":
			_populate_branch_properties()
		"End":
			_populate_end_properties()
		"SkillCheck":
			_populate_skill_check_properties()
		"FlagCheck":
			_populate_flag_check_properties()
		"FlagSet":
			_populate_flag_set_properties()
		"Quest":
			_populate_quest_properties()
		"Reputation":
			_populate_reputation_properties()
		"Item":
			_populate_item_properties()
		_:
			_add_info_label("Unknown node type: %s" % node_type)


func _add_info_label(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = Color(0.6, 0.6, 0.6)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_properties_container.add_child(label)


func _add_section_header(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.modulate = Color(0.9, 0.9, 0.5)
	_properties_container.add_child(label)


func _add_separator() -> void:
	var sep = HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.3)
	_properties_container.add_child(sep)


# =============================================================================
# SPEAKER NODE PROPERTIES
# =============================================================================

func _populate_speaker_properties() -> void:
	_add_section_header("Speaker")

	# Speaker dropdown
	var speakers = SpeakerColorsScript.get_common_speakers()
	var current_speaker = _selected_node.get("speaker") if _selected_node.get("speaker") else "NPC"
	var speaker_dropdown = _add_dropdown_editor("speaker", "Speaker:", speakers, speakers.find(current_speaker))
	_editors["speaker"] = speaker_dropdown

	_add_separator()
	_add_section_header("Dialogue Text")

	# Dialogue text (large text area)
	var current_text = _selected_node.get("dialogue_text") if _selected_node.get("dialogue_text") else ""
	var text_editor = _add_text_area_editor("dialogue_text", current_text, 500, 150)
	_editors["dialogue_text"] = text_editor

	_add_separator()
	_add_section_header("Portrait")

	# Portrait path
	var current_portrait = _selected_node.get("portrait_path") if _selected_node.get("portrait_path") else ""
	var portrait_editor = _add_file_path_editor("portrait_path", "Portrait:", current_portrait, ["*.png", "*.jpg", "*.webp"])
	_editors["portrait_path"] = portrait_editor

	# Portrait preview
	if not current_portrait.is_empty() and FileAccess.file_exists(current_portrait):
		_add_portrait_preview(current_portrait)


func _add_portrait_preview(path: String) -> void:
	var preview_container = HBoxContainer.new()
	preview_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(64, 64)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var texture = load(path) as Texture2D
	if texture:
		texture_rect.texture = texture

	preview_container.add_child(texture_rect)
	_properties_container.add_child(preview_container)


# =============================================================================
# CHOICE NODE PROPERTIES
# =============================================================================

func _populate_choice_properties() -> void:
	_add_section_header("Choice Text")

	var current_text = _selected_node.get("choice_text") if _selected_node.get("choice_text") else ""
	var text_editor = _add_text_area_editor("choice_text", current_text, 200, 80)
	_editors["choice_text"] = text_editor


# =============================================================================
# BRANCH NODE PROPERTIES
# =============================================================================

func _populate_branch_properties() -> void:
	_add_section_header("Condition")

	# Condition type
	var condition_types = ["Flag Check", "Skill Check", "Item Check", "Reputation Check", "Custom"]
	var current_type = _selected_node.get("condition_type") if _selected_node.get("condition_type") != null else 0
	var type_dropdown = _add_dropdown_editor("condition_type", "Type:", condition_types, current_type)
	_editors["condition_type"] = type_dropdown

	_add_separator()

	# Condition key
	var current_key = _selected_node.get("condition_key") if _selected_node.get("condition_key") else ""
	var key_editor = _add_line_editor("condition_key", "Key/Flag:", current_key)
	_editors["condition_key"] = key_editor

	# Condition value
	var current_value = _selected_node.get("condition_value") if _selected_node.get("condition_value") else ""
	var value_editor = _add_line_editor("condition_value", "Value:", current_value)
	_editors["condition_value"] = value_editor


# =============================================================================
# END NODE PROPERTIES
# =============================================================================

func _populate_end_properties() -> void:
	_add_section_header("End Type")

	var end_types = ["Normal End", "Start Combat", "Open Trade", "Exit Game", "Custom"]
	var current_type = _selected_node.get("end_type") if _selected_node.get("end_type") != null else 0
	var type_dropdown = _add_dropdown_editor("end_type", "Type:", end_types, current_type)
	_editors["end_type"] = type_dropdown

	# Custom action (show if custom selected)
	_add_separator()
	var current_action = _selected_node.get("custom_action") if _selected_node.get("custom_action") else ""
	var action_editor = _add_line_editor("custom_action", "Custom Action:", current_action)
	_editors["custom_action"] = action_editor


# =============================================================================
# SKILL CHECK NODE PROPERTIES
# =============================================================================

func _populate_skill_check_properties() -> void:
	_add_section_header("Skill Check")

	# Skill dropdown
	var skills = ["Persuasion", "Intimidation", "Deception", "Insight", "Perception", "Athletics", "Stealth", "Custom"]
	var current_skill = _selected_node.get("skill") if _selected_node.get("skill") else "Persuasion"
	var skill_idx = skills.find(current_skill)
	if skill_idx < 0:
		skill_idx = 0
	var skill_dropdown = _add_dropdown_editor("skill", "Skill:", skills, skill_idx)
	_editors["skill"] = skill_dropdown

	_add_separator()

	# Difficulty class
	var current_dc = _selected_node.get("difficulty_class") if _selected_node.get("difficulty_class") else 10
	var dc_editor = _add_spinbox_editor("difficulty_class", "DC:", current_dc, 1, 30)
	_editors["difficulty_class"] = dc_editor

	# Custom skill name
	_add_separator()
	var current_custom = _selected_node.get("custom_skill") if _selected_node.get("custom_skill") else ""
	var custom_editor = _add_line_editor("custom_skill", "Custom Skill:", current_custom)
	_editors["custom_skill"] = custom_editor


# =============================================================================
# FLAG CHECK NODE PROPERTIES
# =============================================================================

func _populate_flag_check_properties() -> void:
	_add_section_header("Flag Check")

	var current_flag = _selected_node.get("flag_name") if _selected_node.get("flag_name") else ""
	var flag_editor = _add_line_editor("flag_name", "Flag Name:", current_flag)
	_editors["flag_name"] = flag_editor

	_add_separator()

	# Operator
	var operators = ["==", "!=", ">", "<", ">=", "<="]
	var current_op = _selected_node.get("operator") if _selected_node.get("operator") else "=="
	var op_idx = operators.find(current_op)
	if op_idx < 0:
		op_idx = 0
	var op_dropdown = _add_dropdown_editor("operator", "Operator:", operators, op_idx)
	_editors["operator"] = op_dropdown

	_add_separator()

	var current_value = _selected_node.get("flag_value") if _selected_node.get("flag_value") else "true"
	var value_editor = _add_line_editor("flag_value", "Value:", current_value)
	_editors["flag_value"] = value_editor


# =============================================================================
# FLAG SET NODE PROPERTIES
# =============================================================================

func _populate_flag_set_properties() -> void:
	_add_section_header("Set Flag")

	var current_flag = _selected_node.get("flag_name") if _selected_node.get("flag_name") else ""
	var flag_editor = _add_line_editor("flag_name", "Flag Name:", current_flag)
	_editors["flag_name"] = flag_editor

	_add_separator()

	var current_value = _selected_node.get("flag_value") if _selected_node.get("flag_value") else "true"
	var value_editor = _add_line_editor("flag_value", "Value:", current_value)
	_editors["flag_value"] = value_editor


# =============================================================================
# QUEST NODE PROPERTIES
# =============================================================================

func _populate_quest_properties() -> void:
	_add_section_header("Quest")

	var current_id = _selected_node.get("quest_id") if _selected_node.get("quest_id") else ""
	var id_editor = _add_line_editor("quest_id", "Quest ID:", current_id)
	_editors["quest_id"] = id_editor

	_add_separator()

	var actions = ["Start", "Complete", "Fail", "Update"]
	var current_action = _selected_node.get("quest_action") if _selected_node.get("quest_action") else "Start"
	var action_idx = actions.find(current_action)
	if action_idx < 0:
		action_idx = 0
	var action_dropdown = _add_dropdown_editor("quest_action", "Action:", actions, action_idx)
	_editors["quest_action"] = action_dropdown


# =============================================================================
# REPUTATION NODE PROPERTIES
# =============================================================================

func _populate_reputation_properties() -> void:
	_add_section_header("Reputation")

	var factions = ["Player Faction", "Enemy Faction", "Neutral", "Merchants Guild", "City Guard", "Thieves Guild", "Custom"]
	var current_faction = _selected_node.get("faction") if _selected_node.get("faction") else "Player Faction"
	var faction_idx = factions.find(current_faction)
	if faction_idx < 0:
		faction_idx = factions.size() - 1  # Custom
	var faction_dropdown = _add_dropdown_editor("faction", "Faction:", factions, faction_idx)
	_editors["faction"] = faction_dropdown

	_add_separator()

	var current_amount = _selected_node.get("reputation_amount") if _selected_node.get("reputation_amount") != null else 0
	var amount_editor = _add_spinbox_editor("reputation_amount", "Amount:", current_amount, -100, 100)
	_editors["reputation_amount"] = amount_editor

	_add_separator()

	var current_custom = _selected_node.get("custom_faction") if _selected_node.get("custom_faction") else ""
	var custom_editor = _add_line_editor("custom_faction", "Custom Faction:", current_custom)
	_editors["custom_faction"] = custom_editor


# =============================================================================
# ITEM NODE PROPERTIES
# =============================================================================

func _populate_item_properties() -> void:
	_add_section_header("Item")

	var actions = ["Give", "Take", "Check"]
	var current_action = _selected_node.get("item_action") if _selected_node.get("item_action") else "Give"
	var action_idx = actions.find(current_action)
	if action_idx < 0:
		action_idx = 0
	var action_dropdown = _add_dropdown_editor("item_action", "Action:", actions, action_idx)
	_editors["item_action"] = action_dropdown

	_add_separator()

	var current_id = _selected_node.get("item_id") if _selected_node.get("item_id") else ""
	var id_editor = _add_line_editor("item_id", "Item ID:", current_id)
	_editors["item_id"] = id_editor

	_add_separator()

	var current_qty = _selected_node.get("quantity") if _selected_node.get("quantity") else 1
	var qty_editor = _add_spinbox_editor("quantity", "Quantity:", current_qty, 1, 999)
	_editors["quantity"] = qty_editor


# =============================================================================
# EDITOR FACTORY METHODS
# =============================================================================

func _add_dropdown_editor(property: String, label_text: String, options: Array, selected: int) -> OptionButton:
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90, 0)
	row.add_child(label)

	var dropdown = OptionButton.new()
	dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for opt in options:
		dropdown.add_item(opt)
	if selected >= 0 and selected < dropdown.item_count:
		dropdown.select(selected)
	dropdown.item_selected.connect(_on_dropdown_changed.bind(property, options))
	row.add_child(dropdown)

	_properties_container.add_child(row)
	return dropdown


func _add_line_editor(property: String, label_text: String, current_value: String) -> LineEdit:
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90, 0)
	row.add_child(label)

	var edit = LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text = current_value
	edit.text_changed.connect(_on_line_edit_changed.bind(property))
	row.add_child(edit)

	_properties_container.add_child(row)
	return edit


func _add_text_area_editor(property: String, current_value: String, max_length: int, min_height: int) -> TextEdit:
	var container = VBoxContainer.new()

	var text_edit = TextEdit.new()
	text_edit.custom_minimum_size = Vector2(0, min_height)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.text = current_value
	text_edit.text_changed.connect(_on_text_area_changed.bind(property, max_length, text_edit))
	container.add_child(text_edit)

	# Character counter
	var counter_row = HBoxContainer.new()
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	counter_row.add_child(spacer)

	var counter = Label.new()
	counter.name = "CharCounter"
	counter.text = "%d / %d" % [current_value.length(), max_length]
	counter.add_theme_font_size_override("font_size", 11)
	counter.modulate = _get_counter_color(current_value.length(), max_length)
	counter_row.add_child(counter)
	container.add_child(counter_row)

	_properties_container.add_child(container)
	return text_edit


func _add_spinbox_editor(property: String, label_text: String, current_value: int, min_val: int, max_val: int) -> SpinBox:
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90, 0)
	row.add_child(label)

	var spinbox = SpinBox.new()
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.value = current_value
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spinbox.value_changed.connect(_on_spinbox_changed.bind(property))
	row.add_child(spinbox)

	_properties_container.add_child(row)
	return spinbox


func _add_file_path_editor(property: String, label_text: String, current_value: String, filters: Array) -> LineEdit:
	var container = VBoxContainer.new()

	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(90, 0)
	row.add_child(label)

	var edit = LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text = current_value
	edit.placeholder_text = "res://path/to/file.png"
	edit.text_changed.connect(_on_line_edit_changed.bind(property))
	row.add_child(edit)

	container.add_child(row)

	# Browse button
	var browse_btn = Button.new()
	browse_btn.text = "Browse..."
	browse_btn.pressed.connect(_on_browse_pressed.bind(property, filters, edit))
	container.add_child(browse_btn)

	_properties_container.add_child(container)
	return edit


func _get_counter_color(current: int, max_len: int) -> Color:
	if current >= max_len:
		return Color.RED
	elif current >= max_len * 0.9:
		return Color.ORANGE
	else:
		return Color(1, 1, 1, 0.5)


# =============================================================================
# EDITOR SIGNAL HANDLERS
# =============================================================================

func _on_dropdown_changed(index: int, property: String, options: Array) -> void:
	if not _selected_node:
		return

	var value = options[index] if index < options.size() else options[0]

	# For integer-based enums, pass the index
	if property in ["condition_type", "end_type"]:
		_apply_property(property, index)
	else:
		_apply_property(property, value)


func _on_line_edit_changed(new_text: String, property: String) -> void:
	if not _selected_node:
		return
	_apply_property(property, new_text)


func _on_text_area_changed(property: String, max_length: int, text_edit: TextEdit) -> void:
	if not _selected_node:
		return

	var text = text_edit.text
	if text.length() > max_length:
		text = text.substr(0, max_length)
		text_edit.text = text
		text_edit.set_caret_column(max_length)

	# Update counter
	var counter = text_edit.get_parent().get_node_or_null("HBoxContainer/CharCounter")
	if not counter:
		# Find the counter in the container
		for child in text_edit.get_parent().get_children():
			if child is HBoxContainer:
				for subchild in child.get_children():
					if subchild is Label and subchild.name == "CharCounter":
						counter = subchild
						break

	if counter:
		counter.text = "%d / %d" % [text.length(), max_length]
		counter.modulate = _get_counter_color(text.length(), max_length)

	_apply_property(property, text)


func _on_spinbox_changed(value: float, property: String) -> void:
	if not _selected_node:
		return
	_apply_property(property, int(value))


func _on_browse_pressed(property: String, filters: Array, edit: LineEdit) -> void:
	# Create file dialog
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.filters = PackedStringArray(filters)
	dialog.current_dir = "res://"

	dialog.file_selected.connect(func(path: String):
		edit.text = path
		_apply_property(property, path)
		# Update portrait preview if this is a portrait
		if property == "portrait_path":
			_refresh_portrait_preview(path)
		dialog.queue_free()
	)

	dialog.canceled.connect(func():
		dialog.queue_free()
	)

	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


func _refresh_portrait_preview(path: String) -> void:
	# This would refresh the portrait preview, but for simplicity
	# we'll just repopulate the entire panel
	if _selected_node and _selected_node.get("node_type") == "Speaker":
		call_deferred("_populate_properties")


func _apply_property(property: String, value: Variant) -> void:
	if not _selected_node:
		return

	# Apply to the node using appropriate setter methods
	match property:
		"speaker":
			if _selected_node.has_method("set_speaker"):
				_selected_node.set_speaker(value)
		"dialogue_text":
			if _selected_node.has_method("set_dialogue_text"):
				_selected_node.set_dialogue_text(value)
		"portrait_path":
			_selected_node.portrait_path = value
		"choice_text":
			if _selected_node.has_method("set_choice_text"):
				_selected_node.set_choice_text(value)
		"condition_type":
			if _selected_node.has_method("set_condition_type"):
				_selected_node.set_condition_type(value)
			else:
				_selected_node.condition_type = value
		"condition_key":
			_selected_node.condition_key = value
		"condition_value":
			_selected_node.condition_value = value
		"end_type":
			if _selected_node.has_method("set_end_type"):
				_selected_node.set_end_type(value)
			else:
				_selected_node.end_type = value
		"custom_action":
			_selected_node.custom_action = value
		"skill":
			if _selected_node.has_method("set_skill"):
				_selected_node.set_skill(value)
			else:
				_selected_node.skill = value
		"difficulty_class":
			if _selected_node.has_method("set_difficulty"):
				_selected_node.set_difficulty(value)
			else:
				_selected_node.difficulty_class = value
		"custom_skill":
			_selected_node.custom_skill = value
		"flag_name":
			if _selected_node.has_method("set_flag_name"):
				_selected_node.set_flag_name(value)
			else:
				_selected_node.flag_name = value
		"operator":
			_selected_node.operator = value
		"flag_value":
			if _selected_node.has_method("set_flag_value"):
				_selected_node.set_flag_value(value)
			else:
				_selected_node.flag_value = value
		"quest_id":
			if _selected_node.has_method("set_quest_id"):
				_selected_node.set_quest_id(value)
			else:
				_selected_node.quest_id = value
		"quest_action":
			if _selected_node.has_method("set_quest_action"):
				_selected_node.set_quest_action(value)
			else:
				_selected_node.quest_action = value
		"faction":
			if _selected_node.has_method("set_faction"):
				_selected_node.set_faction(value)
			else:
				_selected_node.faction = value
		"reputation_amount":
			if _selected_node.has_method("set_amount"):
				_selected_node.set_amount(value)
			else:
				_selected_node.reputation_amount = value
		"custom_faction":
			_selected_node.custom_faction = value
		"item_action":
			if _selected_node.has_method("set_item_action"):
				_selected_node.set_item_action(value)
			else:
				_selected_node.item_action = value
		"item_id":
			if _selected_node.has_method("set_item_id"):
				_selected_node.set_item_id(value)
			else:
				_selected_node.item_id = value
		"quantity":
			if _selected_node.has_method("set_quantity"):
				_selected_node.set_quantity(value)
			else:
				_selected_node.quantity = value

	# Emit property changed signal
	property_changed.emit(_selected_node, property, value)
