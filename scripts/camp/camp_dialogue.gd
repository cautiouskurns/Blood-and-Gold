## CampDialogue - Visual novel style dialogue scenes with companions
## Part of: Blood & Gold Prototype
## Task 3.10: Camp Scene System
## Spec: docs/features/3.10-camp-scene-system.md
extends Control

# ===== SIGNALS =====
signal scene_started(scene_id: String)
signal scene_ended(scene_id: String)
signal dialogue_advanced(node_id: String)
signal choice_selected(choice_index: int, choice_text: String)

# ===== CONSTANTS =====
const PORTRAIT_SIZE := Vector2(200, 250)
const TYPEWRITER_SPEED: float = 0.03
const CONTINUE_INDICATOR_PULSE_SPEED: float = 2.0

# Portrait placeholder colors (matching CampScreen)
const PORTRAIT_COLORS: Dictionary = {
	"player": Color("#3498db"),
	"captain": Color("#3498db"),
	"thorne": Color("#2c3e50"),
	"lyra": Color("#f1c40f"),
	"matthias": Color("#c0392b"),
	"narrator": Color("#95a5a6"),
}

# Speaker name display colors
const SPEAKER_COLORS: Dictionary = {
	"player": Color("#FFFFFF"),
	"captain": Color("#FFFFFF"),
	"thorne": Color("#5dade2"),
	"lyra": Color("#f1c40f"),
	"matthias": Color("#e74c3c"),
	"narrator": Color("#95a5a6"),
}

# ===== NODE REFERENCES =====
@onready var background: ColorRect = $Background
@onready var left_portrait: Control = $PortraitLayer/LeftPortrait
@onready var right_portrait: Control = $PortraitLayer/RightPortrait
@onready var dialogue_panel: PanelContainer = $DialogueLayer/DialoguePanel
@onready var speaker_label: Label = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var continue_indicator: Label = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/ContinueIndicator
@onready var choice_container: VBoxContainer = $ChoiceLayer/ChoiceContainer

# ===== INTERNAL STATE =====
var _dialogue_manager: DialogueManager
var _scene_id: String = ""
var _is_typing: bool = false
var _full_text: String = ""
var _char_index: int = 0
var _type_timer: float = 0.0
var _is_waiting_for_input: bool = false
var _current_choices: Array[Dictionary] = []
var _pulse_time: float = 0.0
var _loyalty_popup: Node = null

# Preload LoyaltyPopup
const LoyaltyPopupScene = preload("res://scenes/UI/LoyaltyPopup.tscn")

# ===== LIFECYCLE =====
func _ready() -> void:
	_dialogue_manager = DialogueManager.new()
	_connect_signals()
	_hide_all_ui()
	_create_loyalty_popup()
	print("[CampDialogue] Initialized")

func _process(delta: float) -> void:
	# Typewriter effect
	if _is_typing:
		_type_timer += delta
		if _type_timer >= TYPEWRITER_SPEED:
			_type_timer = 0.0
			_advance_typewriter()

	# Continue indicator pulse
	if _is_waiting_for_input and continue_indicator.visible:
		_pulse_time += delta * CONTINUE_INDICATOR_PULSE_SPEED
		var alpha = (sin(_pulse_time) + 1.0) / 2.0
		continue_indicator.modulate.a = 0.3 + (alpha * 0.7)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Handle choice selection with number keys
	if _current_choices.size() > 0:
		if event is InputEventKey and event.pressed:
			var key_num = -1
			match event.keycode:
				KEY_1: key_num = 0
				KEY_2: key_num = 1
				KEY_3: key_num = 2
				KEY_4: key_num = 3
			if key_num >= 0 and key_num < _current_choices.size():
				_on_choice_selected(key_num)
				get_viewport().set_input_as_handled()
				return

	# Advance dialogue on input
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_advance_input()
			get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_handle_advance_input()
			get_viewport().set_input_as_handled()

func _connect_signals() -> void:
	_dialogue_manager.node_reached.connect(_on_node_reached)
	_dialogue_manager.choices_available.connect(_on_choices_available)
	_dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

# ===== PUBLIC API =====
func load_scene(json_path: String) -> bool:
	## Load a camp scene from JSON file
	if not _dialogue_manager.load_dialogue(json_path):
		push_error("[CampDialogue] Failed to load scene: %s" % json_path)
		return false

	_scene_id = _dialogue_manager.get_scene_id()
	print("[CampDialogue] Loaded scene: %s" % _scene_id)
	return true

func load_scene_from_data(data: Dictionary) -> bool:
	## Load a camp scene from dictionary data
	if not _dialogue_manager.load_dialogue_from_data(data):
		return false

	_scene_id = _dialogue_manager.get_scene_id()
	return true

func start_dialogue() -> void:
	## Begin the loaded dialogue
	if not _dialogue_manager.is_loaded():
		push_error("[CampDialogue] No dialogue loaded")
		return

	visible = true
	_show_dialogue_ui()
	scene_started.emit(_scene_id)

	# Start from first node
	var first_node = _dialogue_manager.start()
	if first_node.is_empty():
		push_error("[CampDialogue] Failed to start dialogue")

func end_dialogue() -> void:
	## End the dialogue and clean up
	_hide_all_ui()
	visible = false
	scene_ended.emit(_scene_id)

# ===== UI MANAGEMENT =====
func _hide_all_ui() -> void:
	dialogue_panel.visible = false
	continue_indicator.visible = false
	_hide_portraits()
	_hide_choices()

func _show_dialogue_ui() -> void:
	dialogue_panel.visible = true

func _hide_portraits() -> void:
	for child in left_portrait.get_children():
		child.queue_free()
	for child in right_portrait.get_children():
		child.queue_free()

func _hide_choices() -> void:
	for child in choice_container.get_children():
		child.queue_free()
	_current_choices.clear()
	choice_container.visible = false

func _create_loyalty_popup() -> void:
	## Create instance of LoyaltyPopup for showing changes
	_loyalty_popup = LoyaltyPopupScene.instantiate()
	add_child(_loyalty_popup)

# ===== PORTRAIT DISPLAY =====
func _show_portrait(speaker: String, side: String = "left") -> void:
	## Show a portrait for the speaker on the specified side
	var container = left_portrait if side == "left" else right_portrait

	# Clear existing portrait
	for child in container.get_children():
		child.queue_free()

	# Create placeholder portrait
	var portrait = _create_placeholder_portrait(speaker)
	container.add_child(portrait)

func _create_placeholder_portrait(character_id: String) -> Control:
	## Create a colored placeholder portrait with initials
	var frame = PanelContainer.new()
	frame.custom_minimum_size = PORTRAIT_SIZE

	var color_rect = ColorRect.new()
	color_rect.custom_minimum_size = PORTRAIT_SIZE
	color_rect.color = PORTRAIT_COLORS.get(character_id.to_lower(), Color.GRAY)
	frame.add_child(color_rect)

	var label = Label.new()
	label.text = character_id.left(3).to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.add_child(label)

	return frame

# ===== DIALOGUE DISPLAY =====
func _display_speaker_node(node_data: Dictionary) -> void:
	## Display a speaker node's content
	var speaker = node_data.get("speaker", "Unknown")
	var text = node_data.get("text", "")
	var portrait_id = node_data.get("portrait", speaker)

	# Update speaker label
	speaker_label.text = speaker.to_upper()
	var speaker_color = SPEAKER_COLORS.get(speaker.to_lower(), Color.WHITE)
	speaker_label.add_theme_color_override("font_color", speaker_color)

	# Show portrait
	_show_portrait(speaker, "left")

	# Start typewriter effect for text
	_start_typewriter(text)

	# Hide continue indicator until typing done
	continue_indicator.visible = false

func _start_typewriter(text: String) -> void:
	## Start the typewriter effect for text display
	_full_text = text
	_char_index = 0
	_type_timer = 0.0
	_is_typing = true
	_is_waiting_for_input = false
	dialogue_text.text = ""

func _advance_typewriter() -> void:
	## Add the next character in typewriter effect
	if _char_index < _full_text.length():
		dialogue_text.text += _full_text[_char_index]
		_char_index += 1
	else:
		_finish_typewriter()

func _finish_typewriter() -> void:
	## Complete the typewriter effect
	_is_typing = false
	dialogue_text.text = _full_text
	_is_waiting_for_input = true
	continue_indicator.visible = true
	_pulse_time = 0.0

func _skip_typewriter() -> void:
	## Skip to end of typewriter effect
	_is_typing = false
	dialogue_text.text = _full_text
	_is_waiting_for_input = true
	continue_indicator.visible = true

# ===== CHOICE DISPLAY =====
func _display_choices(choices: Array[Dictionary]) -> void:
	## Display choice buttons
	_hide_choices()
	_current_choices = choices
	choice_container.visible = true

	for i in choices.size():
		var choice = choices[i]
		var button = _create_choice_button(i, choice)
		choice_container.add_child(button)

	# Wait for player to select a choice
	_is_waiting_for_input = false
	continue_indicator.visible = false

func _create_choice_button(index: int, choice_data: Dictionary) -> Button:
	## Create a button for a dialogue choice
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var text = "[%d] %s" % [index + 1, choice_data.get("text", "...")]

	# Add loyalty change indicator
	var loyalty_changes = choice_data.get("loyalty_changes", {})
	if not loyalty_changes.is_empty():
		var indicators: Array[String] = []
		for companion_id in loyalty_changes.keys():
			var delta = loyalty_changes[companion_id]
			var sign_str = "+" if delta > 0 else ""
			indicators.append("%s%s" % [sign_str, companion_id.capitalize()])
		text += "  (%s)" % ", ".join(indicators)

	button.text = text
	button.pressed.connect(_on_choice_button_pressed.bind(index))

	return button

func _on_choice_button_pressed(index: int) -> void:
	## Handle choice button press
	_on_choice_selected(index)

func _on_choice_selected(index: int) -> void:
	## Handle choice selection
	if index < 0 or index >= _current_choices.size():
		return

	var choice_data = _current_choices[index]
	var choice_text = choice_data.get("text", "")
	var choice_id = choice_data.get("node_id", "")
	var loyalty_changes = choice_data.get("loyalty_changes", {})

	choice_selected.emit(index, choice_text)

	# Apply loyalty changes
	if not loyalty_changes.is_empty():
		_apply_loyalty_changes(loyalty_changes)

	# Hide choices and continue dialogue
	_hide_choices()

	# Select the choice in dialogue manager
	var next_node = _dialogue_manager.select_choice(choice_id)
	if next_node.is_empty():
		# Dialogue ended
		pass

# ===== LOYALTY INTEGRATION =====
func _apply_loyalty_changes(changes: Dictionary) -> void:
	## Apply loyalty changes and show popup
	for companion_id in changes.keys():
		var delta = changes[companion_id] as int
		LoyaltyManager.modify_loyalty(companion_id, delta)

	# Show popup
	if _loyalty_popup:
		_loyalty_popup.show_multiple_changes(changes)

# ===== INPUT HANDLING =====
func _handle_advance_input() -> void:
	## Handle input to advance dialogue
	if _is_typing:
		# Skip typewriter effect
		_skip_typewriter()
	elif _is_waiting_for_input and _current_choices.is_empty():
		# Advance to next node
		_is_waiting_for_input = false
		continue_indicator.visible = false
		var next_node = _dialogue_manager.advance()
		# If empty, dialogue_ended signal will be emitted

# ===== SIGNAL HANDLERS =====
func _on_node_reached(node_data: Dictionary) -> void:
	## Handle reaching a new dialogue node
	var node_type = node_data.get("type", "")
	var node_id = node_data.get("node_id", "")

	dialogue_advanced.emit(node_id)

	match node_type:
		DialogueManager.NODE_SPEAKER:
			_display_speaker_node(node_data)
		DialogueManager.NODE_END:
			end_dialogue()

func _on_choices_available(choices: Array[Dictionary]) -> void:
	## Handle choices becoming available
	_display_choices(choices)

func _on_dialogue_ended(end_type: String) -> void:
	## Handle dialogue ending
	print("[CampDialogue] Dialogue ended: %s" % end_type)

	# Wait for loyalty popup to close if showing
	if _loyalty_popup and _loyalty_popup.is_showing():
		await _loyalty_popup.popup_closed

	end_dialogue()
