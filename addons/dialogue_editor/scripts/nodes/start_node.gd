@tool
class_name StartNode
extends DialogueNode
## Start node - Entry point for dialogue trees.
## Has no input slot and one output slot.


func _setup_node() -> void:
	node_type = "Start"
	title = "Start"
	apply_color_theme(Color.GREEN)


func _setup_slots() -> void:
	# Add a spacer label for the slot
	var label = Label.new()
	label.text = "Begin →"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.custom_minimum_size = Vector2(100, 0)
	add_child(label)

	# No input (false), output enabled (true) with FLOW type
	set_slot(0, false, 0, Color.WHITE, true, SlotType.FLOW, SLOT_COLOR_FLOW)


func serialize() -> Dictionary:
	var data = super.serialize()
	# Start node has no additional data
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)


## Start nodes cannot accept input connections.
func can_accept_input() -> bool:
	return false
