@tool
class_name SpeakerNode
extends DialogueNode
## Speaker node - NPC dialogue line.
## Has one input slot, speaker dropdown, text field (500 char limit), and outputs.

const MAX_TEXT_LENGTH := 500

# Speaker options (can be extended via project settings or data file)
const DEFAULT_SPEAKERS := ["Narrator", "Player", "NPC", "Guard", "Merchant", "Villager"]

var speaker: String = "NPC"
var dialogue_text: String = ""
var portrait_path: String = ""

# UI References
var _speaker_dropdown: OptionButton
var _text_edit: TextEdit
var _char_count_label: Label


func _setup_node() -> void:
	node_type = "Speaker"
	title = "Speaker"
	custom_minimum_size = Vector2(280, 0)
	apply_color_theme(Color.CYAN)


func _setup_slots() -> void:
	# Speaker dropdown row
	var speaker_row = HBoxContainer.new()
	var speaker_label = Label.new()
	speaker_label.text = "Speaker:"
	speaker_label.custom_minimum_size = Vector2(60, 0)
	speaker_row.add_child(speaker_label)

	_speaker_dropdown = OptionButton.new()
	_speaker_dropdown.custom_minimum_size = Vector2(140, 0)
	for s in DEFAULT_SPEAKERS:
		_speaker_dropdown.add_item(s)
	_speaker_dropdown.item_selected.connect(_on_speaker_changed)
	speaker_row.add_child(_speaker_dropdown)
	add_child(speaker_row)

	# Text edit for dialogue
	_text_edit = TextEdit.new()
	_text_edit.custom_minimum_size = Vector2(260, 80)
	_text_edit.placeholder_text = "Enter dialogue text..."
	_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text_edit.text_changed.connect(_on_text_changed)
	add_child(_text_edit)

	# Character count
	_char_count_label = Label.new()
	_char_count_label.text = "0 / %d" % MAX_TEXT_LENGTH
	_char_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_char_count_label.add_theme_font_size_override("font_size", 10)
	_char_count_label.modulate = Color(1, 1, 1, 0.5)
	add_child(_char_count_label)

	# Input slot (slot 0 is speaker row), output slot - both use FLOW type
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)


func _on_speaker_changed(index: int) -> void:
	speaker = _speaker_dropdown.get_item_text(index)
	_update_color_by_speaker()
	_emit_data_changed()


func _on_text_changed() -> void:
	var text = _text_edit.text
	if text.length() > MAX_TEXT_LENGTH:
		# Truncate text
		_text_edit.text = text.substr(0, MAX_TEXT_LENGTH)
		_text_edit.set_caret_column(MAX_TEXT_LENGTH)

	dialogue_text = _text_edit.text
	_update_char_count()
	_emit_data_changed()


func _update_char_count() -> void:
	var count = _text_edit.text.length()
	_char_count_label.text = "%d / %d" % [count, MAX_TEXT_LENGTH]

	# Color warning when near limit
	if count >= MAX_TEXT_LENGTH:
		_char_count_label.modulate = Color.RED
	elif count >= MAX_TEXT_LENGTH * 0.9:
		_char_count_label.modulate = Color.ORANGE
	else:
		_char_count_label.modulate = Color(1, 1, 1, 0.5)


func _update_color_by_speaker() -> void:
	# Color code by speaker type
	var color = Color.CYAN
	match speaker:
		"Narrator":
			color = Color.GRAY
		"Player":
			color = Color.DODGER_BLUE
		"Guard":
			color = Color.DARK_RED
		"Merchant":
			color = Color.GOLD
		_:
			color = Color.CYAN

	apply_color_theme(color)


func set_speaker(value: String) -> void:
	speaker = value
	if _speaker_dropdown:
		for i in _speaker_dropdown.item_count:
			if _speaker_dropdown.get_item_text(i) == value:
				_speaker_dropdown.select(i)
				break
	_update_color_by_speaker()


func set_dialogue_text(value: String) -> void:
	dialogue_text = value.substr(0, MAX_TEXT_LENGTH)
	if _text_edit:
		_text_edit.text = dialogue_text
		_update_char_count()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["speaker"] = speaker
	data["text"] = dialogue_text
	data["portrait"] = portrait_path
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("speaker"):
		set_speaker(data.speaker)
	if data.has("text"):
		set_dialogue_text(data.text)
	if data.has("portrait"):
		portrait_path = data.portrait
