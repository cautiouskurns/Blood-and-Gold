@tool
class_name FlagCheckNode
extends DialogueNode
## Flag Check node - Checks a game flag value.
## Has one input slot and two output slots (true/false).

const OPERATORS := ["==", "!=", ">", "<", ">=", "<="]

var flag_name: String = ""
var operator: String = "=="
var flag_value: String = "true"

# UI References
var _flag_edit: LineEdit
var _operator_dropdown: OptionButton
var _value_edit: LineEdit
var _true_label: Label
var _false_label: Label


func _setup_node() -> void:
	node_type = "FlagCheck"
	title = "Flag Check"
	custom_minimum_size = Vector2(220, 0)
	apply_color_theme(Color.YELLOW)


func _setup_slots() -> void:
	# Flag name row (slot 0) - has input
	var flag_row = HBoxContainer.new()
	var flag_label = Label.new()
	flag_label.text = "Flag:"
	flag_label.custom_minimum_size = Vector2(50, 0)
	flag_row.add_child(flag_label)

	_flag_edit = LineEdit.new()
	_flag_edit.custom_minimum_size = Vector2(120, 0)
	_flag_edit.placeholder_text = "flag_name"
	_flag_edit.text_changed.connect(_on_flag_changed)
	flag_row.add_child(_flag_edit)
	add_child(flag_row)

	# Operator row (slot 1)
	var op_row = HBoxContainer.new()
	var op_label = Label.new()
	op_label.text = "Op:"
	op_label.custom_minimum_size = Vector2(50, 0)
	op_row.add_child(op_label)

	_operator_dropdown = OptionButton.new()
	_operator_dropdown.custom_minimum_size = Vector2(80, 0)
	for op in OPERATORS:
		_operator_dropdown.add_item(op)
	_operator_dropdown.item_selected.connect(_on_operator_changed)
	op_row.add_child(_operator_dropdown)
	add_child(op_row)

	# Value row (slot 2)
	var value_row = HBoxContainer.new()
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.custom_minimum_size = Vector2(50, 0)
	value_row.add_child(value_label)

	_value_edit = LineEdit.new()
	_value_edit.custom_minimum_size = Vector2(100, 0)
	_value_edit.placeholder_text = "true"
	_value_edit.text_changed.connect(_on_value_changed)
	value_row.add_child(_value_edit)
	add_child(value_row)

	# True output row (slot 3)
	_true_label = Label.new()
	_true_label.text = "True →"
	_true_label.modulate = SLOT_COLOR_BRANCH_TRUE
	_true_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_true_label.custom_minimum_size = Vector2(160, 0)
	add_child(_true_label)

	# False output row (slot 4)
	_false_label = Label.new()
	_false_label.text = "False →"
	_false_label.modulate = SLOT_COLOR_BRANCH_FALSE
	_false_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_false_label.custom_minimum_size = Vector2(160, 0)
	add_child(_false_label)

	# Configure slots (deferred to ensure GraphNode registers children)
	call_deferred("_configure_slots")


func _configure_slots() -> void:
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, false, 0, Color.WHITE)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(3, false, 0, Color.WHITE, true, SlotType.BRANCH_TRUE, SLOT_COLOR_BRANCH_TRUE)
	set_slot(4, false, 0, Color.WHITE, true, SlotType.BRANCH_FALSE, SLOT_COLOR_BRANCH_FALSE)


func _on_flag_changed(new_text: String) -> void:
	flag_name = new_text
	_emit_data_changed()


func _on_operator_changed(index: int) -> void:
	operator = OPERATORS[index]
	_emit_data_changed()


func _on_value_changed(new_text: String) -> void:
	flag_value = new_text
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["flag_name"] = flag_name
	data["operator"] = operator
	data["flag_value"] = flag_value
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("flag_name"):
		flag_name = data.flag_name
		if _flag_edit:
			_flag_edit.text = flag_name
	if data.has("operator"):
		operator = data.operator
		if _operator_dropdown:
			var idx = OPERATORS.find(operator)
			if idx >= 0:
				_operator_dropdown.select(idx)
	if data.has("flag_value"):
		flag_value = data.flag_value
		if _value_edit:
			_value_edit.text = flag_value


func get_output_slot_type(port: int) -> SlotType:
	match port:
		3: return SlotType.BRANCH_TRUE
		4: return SlotType.BRANCH_FALSE
		_: return SlotType.FLOW
