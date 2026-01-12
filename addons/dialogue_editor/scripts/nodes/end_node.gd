@tool
class_name EndNode
extends DialogueNode
## End node - Terminates dialogue tree.
## Has one input slot, no output slot, and end type selector.

enum EndType {
	NORMAL,
	COMBAT,
	TRADE,
	EXIT_GAME,
	CUSTOM
}

const END_TYPE_NAMES := {
	EndType.NORMAL: "Normal End",
	EndType.COMBAT: "Start Combat",
	EndType.TRADE: "Open Trade",
	EndType.EXIT_GAME: "Exit Game",
	EndType.CUSTOM: "Custom"
}

const END_TYPE_COLORS := {
	EndType.NORMAL: Color.RED,
	EndType.COMBAT: Color.DARK_RED,
	EndType.TRADE: Color.GOLD,
	EndType.EXIT_GAME: Color.PURPLE,
	EndType.CUSTOM: Color.GRAY
}

var end_type: EndType = EndType.NORMAL
var custom_action: String = ""

# UI References
var _type_dropdown: OptionButton
var _custom_edit: LineEdit


func _setup_node() -> void:
	node_type = "End"
	title = "End"
	custom_minimum_size = Vector2(180, 0)
	apply_color_theme(Color.RED)


func _setup_slots() -> void:
	# End type row
	var type_row = HBoxContainer.new()
	var type_label = Label.new()
	type_label.text = "Type:"
	type_label.custom_minimum_size = Vector2(45, 0)
	type_row.add_child(type_label)

	_type_dropdown = OptionButton.new()
	_type_dropdown.custom_minimum_size = Vector2(110, 0)
	for et in EndType.values():
		_type_dropdown.add_item(END_TYPE_NAMES[et])
	_type_dropdown.item_selected.connect(_on_type_changed)
	type_row.add_child(_type_dropdown)
	add_child(type_row)

	# Custom action row (only visible for CUSTOM type)
	_custom_edit = LineEdit.new()
	_custom_edit.custom_minimum_size = Vector2(160, 0)
	_custom_edit.placeholder_text = "Custom action..."
	_custom_edit.visible = false
	_custom_edit.text_changed.connect(_on_custom_changed)
	add_child(_custom_edit)

	# Input only (accepts FLOW), no output
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_END, false, 0, Color.WHITE)


func _on_type_changed(index: int) -> void:
	end_type = index as EndType
	_custom_edit.visible = (end_type == EndType.CUSTOM)
	apply_color_theme(END_TYPE_COLORS[end_type])
	_emit_data_changed()


func _on_custom_changed(new_text: String) -> void:
	custom_action = new_text
	_emit_data_changed()


func set_end_type(value: EndType) -> void:
	end_type = value
	if _type_dropdown:
		_type_dropdown.select(end_type)
	if _custom_edit:
		_custom_edit.visible = (end_type == EndType.CUSTOM)
	apply_color_theme(END_TYPE_COLORS[end_type])


func serialize() -> Dictionary:
	var data = super.serialize()
	data["end_type"] = end_type
	if end_type == EndType.CUSTOM:
		data["custom_action"] = custom_action
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("end_type"):
		set_end_type(data.end_type as EndType)
	if data.has("custom_action"):
		custom_action = data.custom_action
		if _custom_edit:
			_custom_edit.text = custom_action


## End nodes cannot provide output connections.
func can_provide_output() -> bool:
	return false
