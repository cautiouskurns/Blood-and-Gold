@tool
class_name QuestNode
extends DialogueNode
## Quest node - Manages quest state changes.
## Has one input slot and one output slot.

const QUEST_ACTIONS := ["Start", "Complete", "Fail", "Update"]

var quest_id: String = ""
var quest_action: String = "Start"
var update_text: String = ""  # For "Update" action

# UI References
var _quest_edit: LineEdit
var _action_dropdown: OptionButton
var _update_edit: LineEdit


func _setup_node() -> void:
	node_type = "Quest"
	title = "Quest"
	custom_minimum_size = Vector2(200, 0)
	apply_color_theme(Color.ROYAL_BLUE)


func _setup_slots() -> void:
	# Quest ID row (slot 0) - has input and output
	var quest_row = HBoxContainer.new()
	var quest_label = Label.new()
	quest_label.text = "Quest:"
	quest_label.custom_minimum_size = Vector2(50, 0)
	quest_row.add_child(quest_label)

	_quest_edit = LineEdit.new()
	_quest_edit.custom_minimum_size = Vector2(110, 0)
	_quest_edit.placeholder_text = "quest_id"
	_quest_edit.text_changed.connect(_on_quest_changed)
	quest_row.add_child(_quest_edit)
	add_child(quest_row)

	# Action row (slot 1)
	var action_row = HBoxContainer.new()
	var action_label = Label.new()
	action_label.text = "Action:"
	action_label.custom_minimum_size = Vector2(50, 0)
	action_row.add_child(action_label)

	_action_dropdown = OptionButton.new()
	_action_dropdown.custom_minimum_size = Vector2(90, 0)
	for action in QUEST_ACTIONS:
		_action_dropdown.add_item(action)
	_action_dropdown.item_selected.connect(_on_action_changed)
	action_row.add_child(_action_dropdown)
	add_child(action_row)

	# Update text row (slot 2) - only visible when action is "Update"
	_update_edit = LineEdit.new()
	_update_edit.custom_minimum_size = Vector2(160, 0)
	_update_edit.placeholder_text = "Update text..."
	_update_edit.text_changed.connect(_on_update_text_changed)
	_update_edit.visible = false
	add_child(_update_edit)

	# Configure slots - input on slot 0, output on slot 0
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_quest_changed(new_text: String) -> void:
	quest_id = new_text
	_emit_data_changed()


func _on_action_changed(index: int) -> void:
	quest_action = QUEST_ACTIONS[index]
	_update_edit.visible = (quest_action == "Update")
	_emit_data_changed()


func _on_update_text_changed(new_text: String) -> void:
	update_text = new_text
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["quest_id"] = quest_id
	data["quest_action"] = quest_action
	data["update_text"] = update_text
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("quest_id"):
		quest_id = data.quest_id
		if _quest_edit:
			_quest_edit.text = quest_id
	if data.has("quest_action"):
		quest_action = data.quest_action
		if _action_dropdown:
			var idx = QUEST_ACTIONS.find(quest_action)
			if idx >= 0:
				_action_dropdown.select(idx)
			_update_edit.visible = (quest_action == "Update")
	if data.has("update_text"):
		update_text = data.update_text
		if _update_edit:
			_update_edit.text = update_text
