@tool
class_name ReputationNode
extends DialogueNode
## Reputation node - Modifies faction reputation.
## Has one input slot and one output slot.

# Default factions (can be extended via project settings)
const FACTIONS := ["Player Faction", "Guard", "Merchant Guild", "Thieves Guild", "Church", "Nobility", "Custom"]

var faction: String = "Player Faction"
var custom_faction: String = ""
var amount: int = 0

# UI References
var _faction_dropdown: OptionButton
var _custom_edit: LineEdit
var _amount_spinbox: SpinBox


func _setup_node() -> void:
	node_type = "Reputation"
	title = "Reputation"
	custom_minimum_size = Vector2(200, 0)
	apply_color_theme(Color.MEDIUM_PURPLE)


func _setup_slots() -> void:
	# Faction row (slot 0) - has input and output
	var faction_row = HBoxContainer.new()
	var faction_label = Label.new()
	faction_label.text = "Faction:"
	faction_label.custom_minimum_size = Vector2(55, 0)
	faction_row.add_child(faction_label)

	_faction_dropdown = OptionButton.new()
	_faction_dropdown.custom_minimum_size = Vector2(105, 0)
	for f in FACTIONS:
		_faction_dropdown.add_item(f)
	_faction_dropdown.item_selected.connect(_on_faction_changed)
	faction_row.add_child(_faction_dropdown)
	add_child(faction_row)

	# Custom faction row (slot 1) - hidden by default
	_custom_edit = LineEdit.new()
	_custom_edit.custom_minimum_size = Vector2(160, 0)
	_custom_edit.placeholder_text = "Custom faction"
	_custom_edit.text_changed.connect(_on_custom_faction_changed)
	_custom_edit.visible = false
	add_child(_custom_edit)

	# Amount row (slot 2)
	var amount_row = HBoxContainer.new()
	var amount_label = Label.new()
	amount_label.text = "Amount:"
	amount_label.custom_minimum_size = Vector2(55, 0)
	amount_row.add_child(amount_label)

	_amount_spinbox = SpinBox.new()
	_amount_spinbox.min_value = -100
	_amount_spinbox.max_value = 100
	_amount_spinbox.value = 0
	_amount_spinbox.custom_minimum_size = Vector2(80, 0)
	_amount_spinbox.prefix = ""
	_amount_spinbox.value_changed.connect(_on_amount_changed)
	amount_row.add_child(_amount_spinbox)
	add_child(amount_row)

	# Configure slots - input on slot 0, output on slot 0
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)


func _on_faction_changed(index: int) -> void:
	faction = FACTIONS[index]
	_custom_edit.visible = (faction == "Custom")
	_emit_data_changed()


func _on_custom_faction_changed(new_text: String) -> void:
	custom_faction = new_text
	_emit_data_changed()


func _on_amount_changed(new_value: float) -> void:
	amount = int(new_value)
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["faction"] = faction
	data["custom_faction"] = custom_faction
	data["amount"] = amount
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("faction"):
		faction = data.faction
		if _faction_dropdown:
			var idx = FACTIONS.find(faction)
			if idx >= 0:
				_faction_dropdown.select(idx)
			_custom_edit.visible = (faction == "Custom")
	if data.has("custom_faction"):
		custom_faction = data.custom_faction
		if _custom_edit:
			_custom_edit.text = custom_faction
	if data.has("amount"):
		amount = data.amount
		if _amount_spinbox:
			_amount_spinbox.value = amount
