@tool
class_name ChoiceNode
extends DialogueNode
## Choice node - Player response option.
## Has one input slot, text field, and one output slot.

const SpeakerColorsScript = preload("res://addons/dialogue_editor/scripts/speaker_colors.gd")

const MAX_TEXT_LENGTH := 200

var choice_text: String = ""

# UI References
var _text_edit: LineEdit


func _setup_node() -> void:
	node_type = "Choice"
	title = "Choice"
	custom_minimum_size = Vector2(220, 0)
	# Use player color from centralized SpeakerColors manager
	apply_color_theme(SpeakerColorsScript.get_player_color())


func _setup_slots() -> void:
	# Choice text input
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = "Text:"
	label.custom_minimum_size = Vector2(40, 0)
	row.add_child(label)

	_text_edit = LineEdit.new()
	_text_edit.custom_minimum_size = Vector2(160, 0)
	_text_edit.placeholder_text = "Player choice..."
	_text_edit.max_length = MAX_TEXT_LENGTH
	_text_edit.text_changed.connect(_on_text_changed)
	row.add_child(_text_edit)

	add_child(row)

	# Input (accepts FLOW) and output (provides CHOICE type for player responses)
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.CHOICE, SLOT_COLOR_CHOICE)


func _on_text_changed(new_text: String) -> void:
	choice_text = new_text
	_emit_data_changed()


func set_choice_text(value: String) -> void:
	choice_text = value.substr(0, MAX_TEXT_LENGTH)
	if _text_edit:
		_text_edit.text = choice_text


func serialize() -> Dictionary:
	var data = super.serialize()
	data["text"] = choice_text
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("text"):
		set_choice_text(data.text)
