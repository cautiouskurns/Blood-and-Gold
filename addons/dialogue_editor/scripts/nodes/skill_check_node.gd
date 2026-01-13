@tool
class_name SkillCheckNode
extends DialogueNode
## Skill Check node - Checks a skill against a DC.
## Has one input slot and two output slots (success/fail).

# Skill options (can be extended via project settings)
const SKILLS := ["Persuasion", "Intimidation", "Deception", "Insight", "Perception", "Athletics", "Stealth", "Custom"]

var skill: String = "Persuasion"
var difficulty_class: int = 10
var custom_skill: String = ""

# UI References
var _skill_dropdown: OptionButton
var _dc_spinbox: SpinBox
var _custom_edit: LineEdit
var _success_label: Label
var _fail_label: Label


func _setup_node() -> void:
	node_type = "SkillCheck"
	title = "Skill Check"
	custom_minimum_size = Vector2(220, 0)
	apply_color_theme(Color.PURPLE)


func _setup_slots() -> void:
	# Skill dropdown row (slot 0) - has input
	var skill_row = HBoxContainer.new()
	var skill_label = Label.new()
	skill_label.text = "Skill:"
	skill_label.custom_minimum_size = Vector2(40, 0)
	skill_row.add_child(skill_label)

	_skill_dropdown = OptionButton.new()
	_skill_dropdown.custom_minimum_size = Vector2(120, 0)
	for s in SKILLS:
		_skill_dropdown.add_item(s)
	_skill_dropdown.item_selected.connect(_on_skill_changed)
	skill_row.add_child(_skill_dropdown)
	add_child(skill_row)

	# Custom skill row (slot 1) - hidden by default
	_custom_edit = LineEdit.new()
	_custom_edit.custom_minimum_size = Vector2(160, 0)
	_custom_edit.placeholder_text = "Custom skill name"
	_custom_edit.text_changed.connect(_on_custom_skill_changed)
	_custom_edit.visible = false
	add_child(_custom_edit)

	# DC row (slot 2)
	var dc_row = HBoxContainer.new()
	var dc_label = Label.new()
	dc_label.text = "DC:"
	dc_label.custom_minimum_size = Vector2(40, 0)
	dc_row.add_child(dc_label)

	_dc_spinbox = SpinBox.new()
	_dc_spinbox.min_value = 1
	_dc_spinbox.max_value = 30
	_dc_spinbox.value = 10
	_dc_spinbox.custom_minimum_size = Vector2(80, 0)
	_dc_spinbox.value_changed.connect(_on_dc_changed)
	dc_row.add_child(_dc_spinbox)
	add_child(dc_row)

	# Success output row (slot 3)
	_success_label = Label.new()
	_success_label.text = "Success →"
	_success_label.modulate = SLOT_COLOR_BRANCH_TRUE
	_success_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_success_label.custom_minimum_size = Vector2(160, 0)
	add_child(_success_label)

	# Fail output row (slot 4)
	_fail_label = Label.new()
	_fail_label.text = "Fail →"
	_fail_label.modulate = SLOT_COLOR_BRANCH_FALSE
	_fail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fail_label.custom_minimum_size = Vector2(160, 0)
	add_child(_fail_label)

	# Configure slots
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, false, 0, Color.WHITE)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(3, false, 0, Color.WHITE, true, SlotType.BRANCH_TRUE, SLOT_COLOR_BRANCH_TRUE)
	set_slot(4, false, 0, Color.WHITE, true, SlotType.BRANCH_FALSE, SLOT_COLOR_BRANCH_FALSE)


func _on_skill_changed(index: int) -> void:
	skill = SKILLS[index]
	_custom_edit.visible = (skill == "Custom")
	_emit_data_changed()


func _on_custom_skill_changed(new_text: String) -> void:
	custom_skill = new_text
	_emit_data_changed()


func _on_dc_changed(new_value: float) -> void:
	difficulty_class = int(new_value)
	_emit_data_changed()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["skill"] = skill
	data["difficulty_class"] = difficulty_class
	data["custom_skill"] = custom_skill
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("skill"):
		skill = data.skill
		if _skill_dropdown:
			var idx = SKILLS.find(skill)
			if idx >= 0:
				_skill_dropdown.select(idx)
			_custom_edit.visible = (skill == "Custom")
	if data.has("difficulty_class"):
		difficulty_class = data.difficulty_class
		if _dc_spinbox:
			_dc_spinbox.value = difficulty_class
	if data.has("custom_skill"):
		custom_skill = data.custom_skill
		if _custom_edit:
			_custom_edit.text = custom_skill


func get_output_slot_type(port: int) -> SlotType:
	match port:
		3: return SlotType.BRANCH_TRUE
		4: return SlotType.BRANCH_FALSE
		_: return SlotType.FLOW
