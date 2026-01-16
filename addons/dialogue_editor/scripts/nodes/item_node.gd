@tool
class_name ItemNode
extends DialogueNode
## Item node - Manages item giving, taking, and checking.
## Has one input slot and one or two output slots depending on action.

const ITEM_ACTIONS := ["Give", "Take", "Check"]

var item_action: String = "Give"
var item_id: String = ""
var quantity: int = 1

# UI References
var _action_dropdown: OptionButton
var _item_edit: LineEdit
var _quantity_spinbox: SpinBox
var _has_label: Label
var _missing_label: Label


func _setup_node() -> void:
	node_type = "Item"
	title = "Item"
	custom_minimum_size = Vector2(200, 0)
	apply_color_theme(Color.ORANGE)


func _setup_slots() -> void:
	# Action row (slot 0) - has input and possibly output
	var action_row = HBoxContainer.new()
	var action_label = Label.new()
	action_label.text = "Action:"
	action_label.custom_minimum_size = Vector2(55, 0)
	action_row.add_child(action_label)

	_action_dropdown = OptionButton.new()
	_action_dropdown.custom_minimum_size = Vector2(90, 0)
	for action in ITEM_ACTIONS:
		_action_dropdown.add_item(action)
	_action_dropdown.item_selected.connect(_on_action_changed)
	action_row.add_child(_action_dropdown)
	add_child(action_row)

	# Item ID row (slot 1)
	var item_row = HBoxContainer.new()
	var item_label = Label.new()
	item_label.text = "Item:"
	item_label.custom_minimum_size = Vector2(55, 0)
	item_row.add_child(item_label)

	_item_edit = LineEdit.new()
	_item_edit.custom_minimum_size = Vector2(105, 0)
	_item_edit.placeholder_text = "item_id"
	_item_edit.text_changed.connect(_on_item_changed)
	item_row.add_child(_item_edit)
	add_child(item_row)

	# Quantity row (slot 2)
	var qty_row = HBoxContainer.new()
	var qty_label = Label.new()
	qty_label.text = "Qty:"
	qty_label.custom_minimum_size = Vector2(55, 0)
	qty_row.add_child(qty_label)

	_quantity_spinbox = SpinBox.new()
	_quantity_spinbox.min_value = 1
	_quantity_spinbox.max_value = 999
	_quantity_spinbox.value = 1
	_quantity_spinbox.custom_minimum_size = Vector2(80, 0)
	_quantity_spinbox.value_changed.connect(_on_quantity_changed)
	qty_row.add_child(_quantity_spinbox)
	add_child(qty_row)

	# Has Item output row (slot 3) - only visible for Check action
	_has_label = Label.new()
	_has_label.text = "Has Item →"
	_has_label.modulate = SLOT_COLOR_BRANCH_TRUE
	_has_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_has_label.custom_minimum_size = Vector2(145, 0)
	_has_label.visible = false
	add_child(_has_label)

	# Missing Item output row (slot 4) - only visible for Check action
	_missing_label = Label.new()
	_missing_label.text = "Missing →"
	_missing_label.modulate = SLOT_COLOR_BRANCH_FALSE
	_missing_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_missing_label.custom_minimum_size = Vector2(145, 0)
	_missing_label.visible = false
	add_child(_missing_label)

	# Configure slots - default for Give/Take (single output)
	# Must be deferred to ensure GraphNode properly registers all children
	call_deferred("_update_slots_for_action")


func _update_slots_for_action() -> void:
	var is_check = (item_action == "Check")

	# Show/hide conditional output labels
	_has_label.visible = is_check
	_missing_label.visible = is_check

	if is_check:
		# Check action: input on slot 0, no output on slot 0
		# Branch outputs on slots 3 and 4
		set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, false, 0, Color.WHITE)
		set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
		set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
		set_slot(3, false, 0, Color.WHITE, true, SlotType.BRANCH_TRUE, SLOT_COLOR_BRANCH_TRUE)
		set_slot(4, false, 0, Color.WHITE, true, SlotType.BRANCH_FALSE, SLOT_COLOR_BRANCH_FALSE)
	else:
		# Give/Take actions: input and output on slot 0
		set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)
		set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
		set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
		set_slot(3, false, 0, Color.WHITE, false, 0, Color.WHITE)
		set_slot(4, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_action_changed(index: int) -> void:
	item_action = ITEM_ACTIONS[index]
	_update_slots_for_action()
	_emit_data_changed()


func _on_item_changed(new_text: String) -> void:
	item_id = new_text
	_emit_data_changed()


func _on_quantity_changed(new_value: float) -> void:
	quantity = int(new_value)
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["item_action"] = item_action
	data["item_id"] = item_id
	data["quantity"] = quantity
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("item_action"):
		item_action = data.item_action
		if _action_dropdown:
			var idx = ITEM_ACTIONS.find(item_action)
			if idx >= 0:
				_action_dropdown.select(idx)
			_update_slots_for_action()
	if data.has("item_id"):
		item_id = data.item_id
		if _item_edit:
			_item_edit.text = item_id
	if data.has("quantity"):
		quantity = data.quantity
		if _quantity_spinbox:
			_quantity_spinbox.value = quantity


func get_output_slot_type(port: int) -> SlotType:
	if item_action == "Check":
		match port:
			3: return SlotType.BRANCH_TRUE
			4: return SlotType.BRANCH_FALSE
			_: return SlotType.FLOW
	return SlotType.FLOW
