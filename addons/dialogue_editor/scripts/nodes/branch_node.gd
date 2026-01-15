@tool
class_name BranchNode
extends DialogueNode
## Branch node - Conditional branching with dual-mode support.
## Simple mode: dropdown-based UI for common checks.
## Expression mode: full expression editor for complex logic.

const ExpressionFieldScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_field.gd")
const ExpressionParserScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")

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

enum ConditionMode {
	SIMPLE,
	EXPRESSION
}

# =============================================================================
# DATA
# =============================================================================

## Current mode: Simple dropdown or Expression
var condition_mode: ConditionMode = ConditionMode.SIMPLE

## Simple mode data
var condition_type: ConditionType = ConditionType.FLAG_CHECK
var condition_key: String = ""
var condition_value: String = ""

## Expression mode data
var expression_text: String = ""

## Multiple simple conditions (for AND'd conditions)
var additional_conditions: Array[Dictionary] = []  # [{type, key, value}]

# =============================================================================
# UI REFERENCES - Mode Selection
# =============================================================================

var _mode_container: HBoxContainer
var _simple_radio: CheckBox
var _expression_radio: CheckBox

# =============================================================================
# UI REFERENCES - Simple Mode
# =============================================================================

var _simple_container: VBoxContainer
var _type_dropdown: OptionButton
var _key_edit: LineEdit
var _value_edit: LineEdit
var _add_condition_button: Button
var _switch_to_expression_button: Button
var _additional_conditions_container: VBoxContainer

# =============================================================================
# UI REFERENCES - Expression Mode
# =============================================================================

var _expression_container: VBoxContainer
var _expression_field: Control  # ExpressionField
var _test_button: Button
var _expression_status_label: Label

# =============================================================================
# UI REFERENCES - Output Slots
# =============================================================================

var _true_label: Label
var _false_label: Label


func _setup_node() -> void:
	node_type = "Branch"
	title = "Branch"
	custom_minimum_size = Vector2(280, 0)
	apply_color_theme(Color.ORANGE)


func _setup_slots() -> void:
	# Mode selection row (slot 0) - has input
	_mode_container = HBoxContainer.new()

	var mode_label = Label.new()
	mode_label.text = "Mode:"
	mode_label.custom_minimum_size = Vector2(40, 0)
	_mode_container.add_child(mode_label)

	_simple_radio = CheckBox.new()
	_simple_radio.text = "Simple"
	_simple_radio.button_pressed = true
	_simple_radio.toggled.connect(_on_simple_mode_toggled)
	_mode_container.add_child(_simple_radio)

	_expression_radio = CheckBox.new()
	_expression_radio.text = "Expression"
	_expression_radio.toggled.connect(_on_expression_mode_toggled)
	_mode_container.add_child(_expression_radio)

	add_child(_mode_container)

	# Simple mode container (slot 1)
	_setup_simple_mode_ui()

	# Expression mode container (slot 2)
	_setup_expression_mode_ui()

	# True output row (slot 3) - has output for TRUE branch
	_true_label = Label.new()
	_true_label.text = "True →"
	_true_label.modulate = SLOT_COLOR_BRANCH_TRUE
	_true_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_true_label.custom_minimum_size = Vector2(220, 0)
	add_child(_true_label)

	# False output row (slot 4) - has output for FALSE branch
	_false_label = Label.new()
	_false_label.text = "False →"
	_false_label.modulate = SLOT_COLOR_BRANCH_FALSE
	_false_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_false_label.custom_minimum_size = Vector2(220, 0)
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

	# Initially show Simple mode
	_update_mode_visibility()


func _setup_simple_mode_ui() -> void:
	_simple_container = VBoxContainer.new()
	_simple_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Condition type row
	var type_row = HBoxContainer.new()
	var type_label = Label.new()
	type_label.text = "Type:"
	type_label.custom_minimum_size = Vector2(50, 0)
	type_row.add_child(type_label)

	_type_dropdown = OptionButton.new()
	_type_dropdown.custom_minimum_size = Vector2(160, 0)
	for ct in ConditionType.values():
		_type_dropdown.add_item(CONDITION_NAMES[ct])
	_type_dropdown.item_selected.connect(_on_type_changed)
	type_row.add_child(_type_dropdown)
	_simple_container.add_child(type_row)

	# Key row
	var key_row = HBoxContainer.new()
	var key_label = Label.new()
	key_label.text = "Key:"
	key_label.custom_minimum_size = Vector2(50, 0)
	key_row.add_child(key_label)

	_key_edit = LineEdit.new()
	_key_edit.custom_minimum_size = Vector2(160, 0)
	_key_edit.placeholder_text = "flag_name"
	_key_edit.text_changed.connect(_on_key_changed)
	key_row.add_child(_key_edit)
	_simple_container.add_child(key_row)

	# Value row
	var value_row = HBoxContainer.new()
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.custom_minimum_size = Vector2(50, 0)
	value_row.add_child(value_label)

	_value_edit = LineEdit.new()
	_value_edit.custom_minimum_size = Vector2(160, 0)
	_value_edit.placeholder_text = "true / 15"
	_value_edit.text_changed.connect(_on_value_changed)
	value_row.add_child(_value_edit)
	_simple_container.add_child(value_row)

	# Additional conditions container (for multiple AND'd conditions)
	_additional_conditions_container = VBoxContainer.new()
	_simple_container.add_child(_additional_conditions_container)

	# Buttons row
	var buttons_row = HBoxContainer.new()

	_add_condition_button = Button.new()
	_add_condition_button.text = "+ AND"
	_add_condition_button.tooltip_text = "Add another condition (AND'd together)"
	_add_condition_button.pressed.connect(_on_add_condition_pressed)
	buttons_row.add_child(_add_condition_button)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons_row.add_child(spacer)

	_switch_to_expression_button = Button.new()
	_switch_to_expression_button.text = "→ Expression"
	_switch_to_expression_button.tooltip_text = "Convert to expression mode"
	_switch_to_expression_button.pressed.connect(_on_switch_to_expression_pressed)
	buttons_row.add_child(_switch_to_expression_button)

	_simple_container.add_child(buttons_row)

	add_child(_simple_container)


func _setup_expression_mode_ui() -> void:
	_expression_container = VBoxContainer.new()
	_expression_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Expression field (use class_name directly to avoid @tool preload timing issues)
	_expression_field = ExpressionField.new()
	_expression_field.placeholder_text = "condition expression..."
	_expression_field.expression_changed.connect(_on_expression_changed)
	_expression_field.validation_changed.connect(_on_expression_validation_changed)
	_expression_container.add_child(_expression_field)

	# Status/test row
	var status_row = HBoxContainer.new()

	_expression_status_label = Label.new()
	_expression_status_label.text = ""
	_expression_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_expression_status_label.add_theme_font_size_override("font_size", 11)
	status_row.add_child(_expression_status_label)

	_test_button = Button.new()
	_test_button.text = "Test..."
	_test_button.tooltip_text = "Test expression with sample values"
	_test_button.pressed.connect(_on_test_expression_pressed)
	status_row.add_child(_test_button)

	_expression_container.add_child(status_row)

	add_child(_expression_container)


# =============================================================================
# MODE SWITCHING
# =============================================================================

func _on_simple_mode_toggled(pressed: bool) -> void:
	if pressed and condition_mode != ConditionMode.SIMPLE:
		condition_mode = ConditionMode.SIMPLE
		_expression_radio.button_pressed = false
		_update_mode_visibility()
		_emit_data_changed()


func _on_expression_mode_toggled(pressed: bool) -> void:
	if pressed and condition_mode != ConditionMode.EXPRESSION:
		condition_mode = ConditionMode.EXPRESSION
		_simple_radio.button_pressed = false
		_update_mode_visibility()
		_emit_data_changed()


func _update_mode_visibility() -> void:
	if _simple_container:
		_simple_container.visible = (condition_mode == ConditionMode.SIMPLE)
	if _expression_container:
		_expression_container.visible = (condition_mode == ConditionMode.EXPRESSION)


func _on_switch_to_expression_pressed() -> void:
	# Convert current simple condition(s) to expression
	expression_text = _convert_simple_to_expression()

	# Switch to expression mode
	condition_mode = ConditionMode.EXPRESSION
	_simple_radio.button_pressed = false
	_expression_radio.button_pressed = true
	_update_mode_visibility()

	# Update expression field
	if _expression_field:
		_expression_field.set_expression(expression_text)

	_emit_data_changed()


## Convert current simple condition(s) to an expression string.
func _convert_simple_to_expression() -> String:
	var conditions: Array[String] = []

	# Convert primary condition
	var primary = _simple_condition_to_expression(condition_type, condition_key, condition_value)
	if not primary.is_empty():
		conditions.append(primary)

	# Convert additional conditions
	for cond in additional_conditions:
		var expr = _simple_condition_to_expression(
			cond.get("type", ConditionType.FLAG_CHECK) as ConditionType,
			cond.get("key", ""),
			cond.get("value", "")
		)
		if not expr.is_empty():
			conditions.append(expr)

	# Join with "and"
	return " and ".join(conditions)


## Convert a single simple condition to expression.
func _simple_condition_to_expression(type: ConditionType, key: String, value: String) -> String:
	if key.is_empty():
		return ""

	match type:
		ConditionType.FLAG_CHECK:
			if value.to_lower() == "true":
				return 'has_flag("%s")' % key
			elif value.to_lower() == "false":
				return 'not has_flag("%s")' % key
			else:
				return 'get_flag("%s") == "%s"' % [key, value]

		ConditionType.SKILL_CHECK:
			if value.is_valid_int():
				return 'skill_check("%s", %s)' % [key, value]
			else:
				return 'skill_check("%s", 10)' % key

		ConditionType.ITEM_CHECK:
			if value.is_valid_int() and int(value) > 1:
				return 'count("%s") >= %s' % [key, value]
			else:
				return 'has_item("%s")' % key

		ConditionType.REPUTATION_CHECK:
			if value.is_valid_int():
				return '%s >= %s' % [key, value]
			else:
				return '%s >= 0' % key

		ConditionType.CUSTOM:
			# Custom already is an expression
			return key

	return ""


# =============================================================================
# SIMPLE MODE CALLBACKS
# =============================================================================

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


func _on_add_condition_pressed() -> void:
	# Add a new additional condition
	var new_cond := {
		"type": ConditionType.FLAG_CHECK,
		"key": "",
		"value": ""
	}
	additional_conditions.append(new_cond)
	_rebuild_additional_conditions_ui()
	_emit_data_changed()


func _rebuild_additional_conditions_ui() -> void:
	# Clear existing UI
	for child in _additional_conditions_container.get_children():
		child.queue_free()

	# Rebuild for each additional condition
	for i in range(additional_conditions.size()):
		var cond = additional_conditions[i]
		var cond_ui = _create_additional_condition_ui(i, cond)
		_additional_conditions_container.add_child(cond_ui)


func _create_additional_condition_ui(index: int, cond: Dictionary) -> VBoxContainer:
	var container = VBoxContainer.new()

	# Header with AND label and remove button
	var header = HBoxContainer.new()

	var and_label = Label.new()
	and_label.text = "AND"
	and_label.add_theme_color_override("font_color", Color("#ffaa00"))
	and_label.add_theme_font_size_override("font_size", 11)
	header.add_child(and_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	var remove_btn = Button.new()
	remove_btn.text = "×"
	remove_btn.tooltip_text = "Remove this condition"
	remove_btn.custom_minimum_size = Vector2(24, 24)
	remove_btn.pressed.connect(_on_remove_additional_condition.bind(index))
	header.add_child(remove_btn)

	container.add_child(header)

	# Type dropdown
	var type_row = HBoxContainer.new()
	var type_label = Label.new()
	type_label.text = "Type:"
	type_label.custom_minimum_size = Vector2(50, 0)
	type_label.add_theme_font_size_override("font_size", 11)
	type_row.add_child(type_label)

	var type_dropdown = OptionButton.new()
	type_dropdown.custom_minimum_size = Vector2(140, 0)
	for ct in ConditionType.values():
		type_dropdown.add_item(CONDITION_NAMES[ct])
	type_dropdown.select(cond.get("type", 0))
	type_dropdown.item_selected.connect(_on_additional_type_changed.bind(index))
	type_row.add_child(type_dropdown)
	container.add_child(type_row)

	# Key field
	var key_row = HBoxContainer.new()
	var key_label = Label.new()
	key_label.text = "Key:"
	key_label.custom_minimum_size = Vector2(50, 0)
	key_label.add_theme_font_size_override("font_size", 11)
	key_row.add_child(key_label)

	var key_edit = LineEdit.new()
	key_edit.custom_minimum_size = Vector2(140, 0)
	key_edit.text = cond.get("key", "")
	key_edit.text_changed.connect(_on_additional_key_changed.bind(index))
	key_row.add_child(key_edit)
	container.add_child(key_row)

	# Value field
	var value_row = HBoxContainer.new()
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.add_theme_font_size_override("font_size", 11)
	value_row.add_child(value_label)

	var value_edit = LineEdit.new()
	value_edit.custom_minimum_size = Vector2(140, 0)
	value_edit.text = cond.get("value", "")
	value_edit.text_changed.connect(_on_additional_value_changed.bind(index))
	value_row.add_child(value_edit)
	container.add_child(value_row)

	return container


func _on_remove_additional_condition(index: int) -> void:
	if index >= 0 and index < additional_conditions.size():
		additional_conditions.remove_at(index)
		_rebuild_additional_conditions_ui()
		_emit_data_changed()


func _on_additional_type_changed(type_index: int, cond_index: int) -> void:
	if cond_index >= 0 and cond_index < additional_conditions.size():
		additional_conditions[cond_index]["type"] = type_index
		_emit_data_changed()


func _on_additional_key_changed(new_text: String, cond_index: int) -> void:
	if cond_index >= 0 and cond_index < additional_conditions.size():
		additional_conditions[cond_index]["key"] = new_text
		_emit_data_changed()


func _on_additional_value_changed(new_text: String, cond_index: int) -> void:
	if cond_index >= 0 and cond_index < additional_conditions.size():
		additional_conditions[cond_index]["value"] = new_text
		_emit_data_changed()


# =============================================================================
# EXPRESSION MODE CALLBACKS
# =============================================================================

func _on_expression_changed(new_expression: String) -> void:
	expression_text = new_expression
	_emit_data_changed()


func _on_expression_validation_changed(is_valid: bool, error: String) -> void:
	if is_valid:
		_expression_status_label.text = ""
	else:
		_expression_status_label.text = error
		_expression_status_label.add_theme_color_override("font_color", Color("#f92672"))


func _on_test_expression_pressed() -> void:
	# For now, just print - in future could open a test dialog
	print("Test expression: ", expression_text)


# =============================================================================
# SERIALIZATION
# =============================================================================

func serialize() -> Dictionary:
	var data = super.serialize()

	# Store mode
	data["condition_mode"] = "expression" if condition_mode == ConditionMode.EXPRESSION else "simple"

	# Simple mode data (always store for backward compatibility)
	data["condition_type"] = condition_type
	data["condition_key"] = condition_key
	data["condition_value"] = condition_value

	# Additional conditions for Simple mode
	if not additional_conditions.is_empty():
		data["additional_conditions"] = additional_conditions.duplicate(true)

	# Expression mode data
	if condition_mode == ConditionMode.EXPRESSION:
		data["expression"] = expression_text
	else:
		# Auto-generate expression for export even in Simple mode
		data["expression"] = _convert_simple_to_expression()

	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)

	# Load mode (default to simple for backward compatibility)
	var mode_str = data.get("condition_mode", "simple")
	condition_mode = ConditionMode.EXPRESSION if mode_str == "expression" else ConditionMode.SIMPLE

	# Update radio buttons
	if _simple_radio and _expression_radio:
		_simple_radio.button_pressed = (condition_mode == ConditionMode.SIMPLE)
		_expression_radio.button_pressed = (condition_mode == ConditionMode.EXPRESSION)

	# Load simple mode data
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

	# Load additional conditions
	if data.has("additional_conditions"):
		additional_conditions.clear()
		for cond in data.additional_conditions:
			additional_conditions.append(cond.duplicate())
		_rebuild_additional_conditions_ui()

	# Load expression mode data
	if data.has("expression"):
		expression_text = data.expression
		if _expression_field:
			_expression_field.set_expression(expression_text)

	# Update visibility
	_update_mode_visibility()


## Get the compiled expression for this branch.
## Always returns an expression regardless of mode.
func get_compiled_expression() -> String:
	if condition_mode == ConditionMode.EXPRESSION:
		return expression_text
	else:
		return _convert_simple_to_expression()


## Check if the expression is valid.
func is_expression_valid() -> bool:
	var expr = get_compiled_expression()
	if expr.is_empty():
		return true  # Empty is valid (always true)

	var parser = ExpressionParserScript.new()
	var result = parser.parse(expr)
	return not result.has_errors()


## Get the slot type for output port.
func get_output_slot_type(port: int) -> SlotType:
	match port:
		3:
			return SlotType.BRANCH_TRUE
		4:
			return SlotType.BRANCH_FALSE
		_:
			return SlotType.FLOW
