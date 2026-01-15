@tool
class_name SetExpressionNode
extends DialogueNode
## Set Expression Node - Sets multiple variables in one action.
## Each row assigns a variable to the result of an expression.

const ExpressionFieldScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_field.gd")
const ExpressionParserScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")

# =============================================================================
# DATA
# =============================================================================

## List of assignments [{variable: String, expression: String}]
var assignments: Array[Dictionary] = []

# =============================================================================
# UI REFERENCES
# =============================================================================

var _assignments_container: VBoxContainer
var _add_button: Button
var _assignment_rows: Array[Control] = []

# =============================================================================
# INITIALIZATION
# =============================================================================

func _setup_node() -> void:
	node_type = "SetExpression"
	title = "Set Variables"
	custom_minimum_size = Vector2(320, 0)
	apply_color_theme(Color.MEDIUM_SLATE_BLUE)


func _setup_slots() -> void:
	# Header label (slot 0) - has input
	var header = Label.new()
	header.text = "Variable Assignments:"
	header.add_theme_font_size_override("font_size", 12)
	add_child(header)

	# Assignments container (slot 1) - no connections
	_assignments_container = VBoxContainer.new()
	_assignments_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_assignments_container)

	# Add button row (slot 2) - has output
	var button_row = HBoxContainer.new()
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(spacer)

	_add_button = Button.new()
	_add_button.text = "+ Add Assignment"
	_add_button.pressed.connect(_on_add_assignment)
	button_row.add_child(_add_button)

	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(spacer2)

	add_child(button_row)

	# Output label (slot 3) - has output
	var output_label = Label.new()
	output_label.text = "Next ->"
	output_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	output_label.modulate = SLOT_COLOR_FLOW
	add_child(output_label)

	# Configure slots:
	# Slot 0: Input flow
	# Slot 1-2: No connections (container)
	# Slot 3: Output flow
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, false, 0, Color.WHITE)
	set_slot(1, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(2, false, 0, Color.WHITE, false, 0, Color.WHITE)
	set_slot(3, false, 0, Color.WHITE, true, SlotType.FLOW, SLOT_COLOR_FLOW)

	# Add default empty assignment
	if assignments.is_empty():
		_add_assignment_row("", "")


# =============================================================================
# ASSIGNMENT MANAGEMENT
# =============================================================================

func _on_add_assignment() -> void:
	_add_assignment_row("", "")
	_emit_data_changed()


func _add_assignment_row(variable: String, expression: String) -> void:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Variable name input
	var var_edit = LineEdit.new()
	var_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var_edit.custom_minimum_size = Vector2(80, 0)
	var_edit.placeholder_text = "variable"
	var_edit.text = variable
	var_edit.text_changed.connect(_on_variable_changed.bind(row))
	row.add_child(var_edit)

	# Equals sign
	var equals = Label.new()
	equals.text = " = "
	row.add_child(equals)

	# Expression field - use simple LineEdit to avoid @tool compilation issues
	# TODO: Replace with ExpressionField when expression system is stable
	var expr_field = LineEdit.new()
	expr_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	expr_field.custom_minimum_size = Vector2(120, 0)
	expr_field.placeholder_text = "expression"
	expr_field.text = expression
	expr_field.text_changed.connect(_on_expression_changed.bind(row))
	row.add_child(expr_field)

	# Remove button
	var remove_btn = Button.new()
	remove_btn.text = "x"
	remove_btn.flat = true
	remove_btn.custom_minimum_size = Vector2(24, 24)
	remove_btn.tooltip_text = "Remove assignment"
	remove_btn.pressed.connect(_on_remove_assignment.bind(row))
	row.add_child(remove_btn)

	# Store references in row metadata
	row.set_meta("var_edit", var_edit)
	row.set_meta("expr_field", expr_field)

	_assignments_container.add_child(row)
	_assignment_rows.append(row)


func _on_remove_assignment(row: Control) -> void:
	var idx = _assignment_rows.find(row)
	if idx >= 0:
		_assignment_rows.remove_at(idx)
		row.queue_free()
		_emit_data_changed()

	# Ensure at least one row remains
	if _assignment_rows.is_empty():
		call_deferred("_add_assignment_row", "", "")


func _on_variable_changed(new_text: String, row: Control) -> void:
	_emit_data_changed()


func _on_expression_changed(new_expr: String, row: Control) -> void:
	_emit_data_changed()


func _on_validation_changed(is_valid: bool, error: String, row: Control) -> void:
	# Update row visual feedback
	var expr_field = row.get_meta("expr_field") as Control
	if expr_field:
		if is_valid:
			row.modulate = Color.WHITE
		else:
			row.modulate = Color(1.0, 0.9, 0.9)  # Slight red tint


# =============================================================================
# SERIALIZATION
# =============================================================================

func serialize() -> Dictionary:
	var data = super.serialize()

	# Collect assignments from UI
	var serialized_assignments: Array[Dictionary] = []
	for row in _assignment_rows:
		if is_instance_valid(row):
			var var_edit = row.get_meta("var_edit") as LineEdit
			var expr_field = row.get_meta("expr_field") as Control

			if var_edit and expr_field:
				var variable = var_edit.text.strip_edges()
				var expression = expr_field.get_expression().strip_edges()

				# Only include non-empty assignments
				if not variable.is_empty() or not expression.is_empty():
					serialized_assignments.append({
						"variable": variable,
						"expression": expression
					})

	data["assignments"] = serialized_assignments
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)

	# Clear existing rows
	for row in _assignment_rows:
		if is_instance_valid(row):
			row.queue_free()
	_assignment_rows.clear()

	# Load assignments
	var loaded_assignments = data.get("assignments", [])
	if loaded_assignments.is_empty():
		# Add default empty row
		call_deferred("_add_assignment_row", "", "")
	else:
		for assignment in loaded_assignments:
			var variable = assignment.get("variable", "")
			var expression = assignment.get("expression", "")
			call_deferred("_add_assignment_row", variable, expression)


# =============================================================================
# VALIDATION
# =============================================================================

## Check if all expressions in this node are valid.
func is_valid() -> bool:
	for row in _assignment_rows:
		if is_instance_valid(row):
			var expr_field = row.get_meta("expr_field") as Control
			if expr_field and expr_field.has_method("is_valid"):
				if not expr_field.is_valid():
					return false
	return true


## Get validation errors for this node.
func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []

	var row_idx = 0
	for row in _assignment_rows:
		if is_instance_valid(row):
			var var_edit = row.get_meta("var_edit") as LineEdit
			var expr_field = row.get_meta("expr_field") as Control

			if var_edit and expr_field:
				var variable = var_edit.text.strip_edges()
				var expression = expr_field.get_expression().strip_edges()

				# Check for empty variable name with non-empty expression
				if variable.is_empty() and not expression.is_empty():
					errors.append("Assignment %d: Variable name is required" % (row_idx + 1))

				# Check expression validity
				if expr_field.has_method("is_valid") and not expr_field.is_valid():
					var error = expr_field.get_error() if expr_field.has_method("get_error") else "Invalid"
					errors.append("Assignment %d: %s" % [(row_idx + 1), error])

		row_idx += 1

	return errors


# =============================================================================
# PUBLIC API
# =============================================================================

## Get all assignments as an array of dictionaries.
func get_assignments() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for row in _assignment_rows:
		if is_instance_valid(row):
			var var_edit = row.get_meta("var_edit") as LineEdit
			var expr_field = row.get_meta("expr_field") as Control

			if var_edit and expr_field:
				var variable = var_edit.text.strip_edges()
				var expression = expr_field.get_expression().strip_edges()

				if not variable.is_empty():
					result.append({
						"variable": variable,
						"expression": expression
					})

	return result


## Set assignments from an array of dictionaries.
func set_assignments(new_assignments: Array) -> void:
	# Clear existing rows
	for row in _assignment_rows:
		if is_instance_valid(row):
			row.queue_free()
	_assignment_rows.clear()

	# Add new assignments
	for assignment in new_assignments:
		var variable = assignment.get("variable", "")
		var expression = assignment.get("expression", "")
		call_deferred("_add_assignment_row", variable, expression)

	if new_assignments.is_empty():
		call_deferred("_add_assignment_row", "", "")

	_emit_data_changed()
