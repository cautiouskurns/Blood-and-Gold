@tool
class_name FlagSetNode
extends DialogueNode
## Flag Set node - Sets a game flag value.
## Has one input slot and one output slot.

var flag_name: String = ""
var flag_value: String = "true"

# UI References
var _flag_edit: LineEdit
var _value_edit: LineEdit


func _setup_node() -> void:
	node_type = "FlagSet"
	title = "Set Flag"
	custom_minimum_size = Vector2(200, 0)
	apply_color_theme(Color.GOLD)


func _setup_slots() -> void:
	# Flag name row (slot 0) - has input and output
	var flag_row = HBoxContainer.new()
	var flag_label = Label.new()
	flag_label.text = "Flag:"
	flag_label.custom_minimum_size = Vector2(50, 0)
	flag_row.add_child(flag_label)

	_flag_edit = LineEdit.new()
	_flag_edit.custom_minimum_size = Vector2(110, 0)
	_flag_edit.placeholder_text = "flag_name"
	_flag_edit.text_changed.connect(_on_flag_changed)
	flag_row.add_child(_flag_edit)
	add_child(flag_row)

	# Value row (slot 1)
	var value_row = HBoxContainer.new()
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.custom_minimum_size = Vector2(50, 0)
	value_row.add_child(value_label)

	_value_edit = LineEdit.new()
	_value_edit.custom_minimum_size = Vector2(110, 0)
	_value_edit.placeholder_text = "true"
	_value_edit.text_changed.connect(_on_value_changed)
	value_row.add_child(_value_edit)
	add_child(value_row)

	# Configure slots - input on slot 0, output on slot 0
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_flag_changed(new_text: String) -> void:
	flag_name = new_text
	_emit_data_changed()


func _on_value_changed(new_text: String) -> void:
	flag_value = new_text
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["flag_name"] = flag_name
	data["flag_value"] = flag_value
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("flag_name"):
		flag_name = data.flag_name
		if _flag_edit:
			_flag_edit.text = flag_name
	if data.has("flag_value"):
		flag_value = data.flag_value
		if _value_edit:
			_value_edit.text = flag_value
