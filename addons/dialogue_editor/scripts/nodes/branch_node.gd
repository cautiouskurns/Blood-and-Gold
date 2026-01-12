@tool
class_name BranchNode
extends DialogueNode
## Branch node - Conditional branching.
## Has one input slot and multiple output slots based on condition.

enum ConditionType {
	FLAG_CHECK,
	SKILL_CHECK,
	ITEM_CHECK,
	REPUTATION_CHECK,
	CUSTOM
}

const CONDITION_NAMES := {
	ConditionType.FLAG_CHECK: "Flag Check",
	ConditionType.SKILL_CHECK: "Skill Check",
	ConditionType.ITEM_CHECK: "Item Check",
	ConditionType.REPUTATION_CHECK: "Reputation",
	ConditionType.CUSTOM: "Custom"
}

var condition_type: ConditionType = ConditionType.FLAG_CHECK
var condition_key: String = ""
var condition_value: String = ""

# UI References
var _type_dropdown: OptionButton
var _key_edit: LineEdit
var _value_edit: LineEdit
var _true_label: Label
var _false_label: Label


func _setup_node() -> void:
	node_type = "Branch"
	title = "Branch"
	custom_minimum_size = Vector2(240, 0)
	apply_color_theme(Color.ORANGE)


func _setup_slots() -> void:
	# Condition type row (slot 0) - has input
	var type_row = HBoxContainer.new()
	var type_label = Label.new()
	type_label.text = "Type:"
	type_label.custom_minimum_size = Vector2(50, 0)
	type_row.add_child(type_label)

	_type_dropdown = OptionButton.new()
	_type_dropdown.custom_minimum_size = Vector2(130, 0)
	for ct in ConditionType.values():
		_type_dropdown.add_item(CONDITION_NAMES[ct])
	_type_dropdown.item_selected.connect(_on_type_changed)
	type_row.add_child(_type_dropdown)
	add_child(type_row)

	# Key row (slot 1)
	var key_row = HBoxContainer.new()
	var key_label = Label.new()
	key_label.text = "Key:"
	key_label.custom_minimum_size = Vector2(50, 0)
	key_row.add_child(key_label)

	_key_edit = LineEdit.new()
	_key_edit.custom_minimum_size = Vector2(130, 0)
	_key_edit.placeholder_text = "flag_name"
	_key_edit.text_changed.connect(_on_key_changed)
	key_row.add_child(_key_edit)
	add_child(key_row)

	# Value row (slot 2)
	var value_row = HBoxContainer.new()
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.custom_minimum_size = Vector2(50, 0)
	value_row.add_child(value_label)

	_value_edit = LineEdit.new()
	_value_edit.custom_minimum_size = Vector2(130, 0)
	_value_edit.placeholder_text = "true / 15"
	_value_edit.text_changed.connect(_on_value_changed)
	value_row.add_child(_value_edit)
	add_child(value_row)

	# True output row (slot 3) - has output for TRUE branch
	_true_label = Label.new()
	_true_label.text = "True →"
	_true_label.modulate = SLOT_COLOR_BRANCH_TRUE
	_true_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_true_label.custom_minimum_size = Vector2(180, 0)
	add_child(_true_label)

	# False output row (slot 4) - has output for FALSE branch
	_false_label = Label.new()
	_false_label.text = "False →"
	_false_label.modulate = SLOT_COLOR_BRANCH_FALSE
	_false_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_false_label.custom_minimum_size = Vector2(180, 0)
	add_child(_false_label)

	# Configure slots:
	# Slot 0: Input only (flow in)
	# Slot 3: True output
	# Slot 4: False output
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, false, 0, Color.WHITE)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(3, false, 0, Color.WHITE, true, SlotType.BRANCH_TRUE, SLOT_COLOR_BRANCH_TRUE)
	set_slot(4, false, 0, Color.WHITE, true, SlotType.BRANCH_FALSE, SLOT_COLOR_BRANCH_FALSE)


func _on_type_changed(index: int) -> void:
	condition_type = index as ConditionType
	_update_placeholder_text()
	_emit_data_changed()


func _on_key_changed(new_text: String) -> void:
	condition_key = new_text
	_emit_data_changed()


func _on_value_changed(new_text: String) -> void:
	condition_value = new_text
	_emit_data_changed()


func _update_placeholder_text() -> void:
	match condition_type:
		ConditionType.FLAG_CHECK:
			_key_edit.placeholder_text = "flag_name"
			_value_edit.placeholder_text = "true"
		ConditionType.SKILL_CHECK:
			_key_edit.placeholder_text = "persuasion"
			_value_edit.placeholder_text = "15"
		ConditionType.ITEM_CHECK:
			_key_edit.placeholder_text = "item_id"
			_value_edit.placeholder_text = "1"
		ConditionType.REPUTATION_CHECK:
			_key_edit.placeholder_text = "faction_id"
			_value_edit.placeholder_text = "50"
		ConditionType.CUSTOM:
			_key_edit.placeholder_text = "expression"
			_value_edit.placeholder_text = "value"


func serialize() -> Dictionary:
	var data = super.serialize()
	data["condition_type"] = condition_type
	data["condition_key"] = condition_key
	data["condition_value"] = condition_value
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("condition_type"):
		condition_type = data.condition_type as ConditionType
		if _type_dropdown:
			_type_dropdown.select(condition_type)
		_update_placeholder_text()
	if data.has("condition_key"):
		condition_key = data.condition_key
		if _key_edit:
			_key_edit.text = condition_key
	if data.has("condition_value"):
		condition_value = data.condition_value
		if _value_edit:
			_value_edit.text = condition_value


## Get the slot type for output port.
func get_output_slot_type(port: int) -> SlotType:
	match port:
		3:
			return SlotType.BRANCH_TRUE
		4:
			return SlotType.BRANCH_FALSE
		_:
			return SlotType.FLOW
