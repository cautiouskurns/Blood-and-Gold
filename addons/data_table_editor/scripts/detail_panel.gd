@tool
extends PanelContainer
## Detail Panel for the Data Table Editor.
## Shows a form with all fields for the selected row, allowing detailed editing.
## Supports two-way binding with the table grid.
## Spec: docs/tools/data-table-editor-roadmap.md - Feature 2.5

# ===== SIGNALS =====
signal field_changed(column_name: String, new_value: Variant)

# ===== STATE =====
var _current_schema: Dictionary = {}
var _current_row_data: Dictionary = {}
var _current_row_index: int = -1
var _field_controls: Dictionary = {}  # column_name -> Control
var _is_updating: bool = false  # Prevent recursive updates

# ===== NODE REFERENCES =====
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var fields_container: VBoxContainer = $ScrollContainer/FieldsContainer
@onready var title_label: Label = $ScrollContainer/FieldsContainer/TitleLabel
@onready var no_selection_label: Label = $ScrollContainer/FieldsContainer/NoSelectionLabel


# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_panel()


func _setup_panel() -> void:
	# Initial state - no row selected
	_show_no_selection()


# ===== PUBLIC API =====

## Set the schema for generating form fields.
func set_schema(schema: Dictionary) -> void:
	print("[DetailPanel] set_schema called - schema name: %s, columns: %d" % [schema.get("name", "unknown"), schema.get("columns", []).size()])
	_current_schema = schema
	_clear_fields()
	_generate_fields()
	print("[DetailPanel] After _generate_fields - field_controls count: %d" % _field_controls.size())


## Display a row's data in the detail panel.
## @param row_data: Dictionary of column values
## @param row_index: Index of the row in the table
func display_row(row_data: Dictionary, row_index: int) -> void:
	print("[DetailPanel] display_row called - row_index: %d, data keys: %s" % [row_index, row_data.keys()])
	_current_row_data = row_data
	_current_row_index = row_index

	if row_data.is_empty():
		print("[DetailPanel] row_data is empty, showing no selection")
		_show_no_selection()
		return

	print("[DetailPanel] Showing fields, field_controls count: %d" % _field_controls.size())
	_show_fields()
	_populate_fields(row_data)


## Clear the panel and show "no selection" message.
func clear_display() -> void:
	_current_row_data = {}
	_current_row_index = -1
	_show_no_selection()


## Update a specific field value (called when grid updates).
func update_field(column_name: String, value: Variant) -> void:
	if not _field_controls.has(column_name):
		return

	_is_updating = true
	var control = _field_controls[column_name]
	_set_control_value(control, value, _get_column_type(column_name))
	_is_updating = false


## Get the currently displayed row index.
func get_current_row_index() -> int:
	return _current_row_index


# ===== INTERNAL METHODS =====

func _show_no_selection() -> void:
	if no_selection_label:
		no_selection_label.visible = true
	if title_label:
		title_label.text = "No Row Selected"

	# Hide all field containers
	for child in fields_container.get_children():
		if child != title_label and child != no_selection_label:
			child.visible = false


func _show_fields() -> void:
	print("[DetailPanel] _show_fields - children count: %d" % fields_container.get_child_count())
	if no_selection_label:
		no_selection_label.visible = false

	# Show all field containers
	var shown_count := 0
	for child in fields_container.get_children():
		if child != no_selection_label:
			child.visible = true
			shown_count += 1
	print("[DetailPanel] Made %d children visible" % shown_count)


func _clear_fields() -> void:
	_field_controls.clear()

	# Remove all dynamic field containers (keep title and no_selection labels)
	for child in fields_container.get_children():
		if child != title_label and child != no_selection_label:
			child.queue_free()


func _generate_fields() -> void:
	var columns = _current_schema.get("columns", [])
	print("[DetailPanel] _generate_fields - columns count: %d, fields_container valid: %s" % [columns.size(), fields_container != null])
	if columns.is_empty():
		print("[DetailPanel] No columns in schema, returning early")
		return

	# Update title with schema name
	var schema_name = _current_schema.get("display_name", _current_schema.get("name", "Details"))
	if title_label:
		title_label.text = schema_name

	# Create field for each column
	for col in columns:
		var col_name = col.get("name", "")
		var col_type = col.get("type", "string")
		var display_name = col.get("display_name", col_name.capitalize().replace("_", " "))
		var required = col.get("required", false)

		var field_container = _create_field_container(col_name, col_type, display_name, required, col)
		fields_container.add_child(field_container)


func _create_field_container(col_name: String, col_type: String, display_name: String, required: bool, column: Dictionary) -> Control:
	var container = VBoxContainer.new()
	container.name = "Field_" + col_name

	# Label with field name
	var label = Label.new()
	label.text = display_name + ("*" if required else "")
	label.add_theme_font_size_override("font_size", 12)
	if required:
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	container.add_child(label)

	# Create appropriate control based on type
	var control = _create_control_for_type(col_name, col_type, column)
	control.name = "Input_" + col_name
	container.add_child(control)

	# Store reference
	_field_controls[col_name] = control

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 4
	container.add_child(spacer)

	return container


func _create_control_for_type(col_name: String, col_type: String, column: Dictionary) -> Control:
	match col_type:
		"boolean":
			var checkbox = CheckBox.new()
			checkbox.text = "Enabled"
			checkbox.toggled.connect(_on_field_changed.bind(col_name, col_type))
			return checkbox

		"integer":
			var spinbox = SpinBox.new()
			spinbox.min_value = column.get("min", -999999)
			spinbox.max_value = column.get("max", 999999)
			spinbox.step = 1
			spinbox.value_changed.connect(_on_spinbox_changed.bind(col_name))
			return spinbox

		"float":
			var spinbox = SpinBox.new()
			spinbox.min_value = column.get("min", -999999.0)
			spinbox.max_value = column.get("max", 999999.0)
			spinbox.step = 0.1
			spinbox.value_changed.connect(_on_spinbox_changed.bind(col_name))
			return spinbox

		"enum":
			var option_btn = OptionButton.new()
			var options = column.get("options", [])
			for i in range(options.size()):
				option_btn.add_item(str(options[i]), i)
			option_btn.item_selected.connect(_on_option_selected.bind(col_name, options))
			return option_btn

		"dice":
			var hbox = HBoxContainer.new()
			var line_edit = LineEdit.new()
			line_edit.placeholder_text = "e.g., 2d6+3"
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.text_changed.connect(_on_text_changed.bind(col_name, col_type))
			hbox.add_child(line_edit)

			# Add validation indicator
			var validation_label = Label.new()
			validation_label.name = "ValidationLabel"
			validation_label.custom_minimum_size.x = 60
			hbox.add_child(validation_label)

			return hbox

		"string":
			# Check if this might be a long text field (description, notes, etc.)
			var is_multiline = col_name in ["description", "notes", "text", "content", "body"]
			if is_multiline:
				var text_edit = TextEdit.new()
				text_edit.custom_minimum_size.y = 80
				text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
				text_edit.text_changed.connect(_on_text_edit_changed.bind(col_name))
				return text_edit
			else:
				var line_edit = LineEdit.new()
				line_edit.text_changed.connect(_on_text_changed.bind(col_name, col_type))
				return line_edit

		_:
			# Default: LineEdit
			var line_edit = LineEdit.new()
			line_edit.text_changed.connect(_on_text_changed.bind(col_name, col_type))
			return line_edit


func _populate_fields(row_data: Dictionary) -> void:
	_is_updating = true

	for col_name in _field_controls.keys():
		var control = _field_controls[col_name]
		var value = row_data.get(col_name, "")
		var col_type = _get_column_type(col_name)

		_set_control_value(control, value, col_type)

	# Update title with row ID if available
	var row_id = row_data.get("id", row_data.get("name", "Row %d" % _current_row_index))
	if title_label:
		var schema_name = _current_schema.get("display_name", _current_schema.get("name", "Details"))
		title_label.text = "%s: %s" % [schema_name, row_id]

	_is_updating = false


func _set_control_value(control: Control, value: Variant, col_type: String) -> void:
	match col_type:
		"boolean":
			if control is CheckBox:
				control.button_pressed = bool(value)

		"integer", "float":
			if control is SpinBox:
				control.value = float(value) if value != null else 0

		"enum":
			if control is OptionButton:
				var text_value = str(value)
				for i in range(control.item_count):
					if control.get_item_text(i) == text_value:
						control.select(i)
						break

		"dice":
			if control is HBoxContainer:
				var line_edit = control.get_child(0) as LineEdit
				var validation_label = control.get_node_or_null("ValidationLabel") as Label
				if line_edit:
					line_edit.text = str(value) if value != null else ""
				if validation_label:
					_update_dice_validation(str(value) if value != null else "", validation_label)

		"string":
			if control is TextEdit:
				control.text = str(value) if value != null else ""
			elif control is LineEdit:
				control.text = str(value) if value != null else ""

		_:
			if control is LineEdit:
				control.text = str(value) if value != null else ""


func _get_column_type(col_name: String) -> String:
	var columns = _current_schema.get("columns", [])
	for col in columns:
		if col.get("name", "") == col_name:
			return col.get("type", "string")
	return "string"


func _get_column(col_name: String) -> Dictionary:
	var columns = _current_schema.get("columns", [])
	for col in columns:
		if col.get("name", "") == col_name:
			return col
	return {}


func _update_dice_validation(dice_text: String, label: Label) -> void:
	if dice_text.is_empty():
		label.text = ""
		return

	if DiceParser.is_valid(dice_text):
		var avg = DiceParser.calculate_average(dice_text)
		label.text = "avg: %.1f ✓" % avg
		label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	else:
		label.text = "invalid ✗"
		label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))


# ===== SIGNAL HANDLERS =====

func _on_field_changed(value: Variant, col_name: String, col_type: String) -> void:
	if _is_updating:
		return
	field_changed.emit(col_name, value)


func _on_text_changed(new_text: String, col_name: String, col_type: String) -> void:
	if _is_updating:
		return

	# Update dice validation if applicable
	if col_type == "dice":
		var control = _field_controls.get(col_name)
		if control is HBoxContainer:
			var validation_label = control.get_node_or_null("ValidationLabel") as Label
			if validation_label:
				_update_dice_validation(new_text, validation_label)

	field_changed.emit(col_name, new_text)


func _on_text_edit_changed(col_name: String) -> void:
	if _is_updating:
		return
	var control = _field_controls.get(col_name)
	if control is TextEdit:
		field_changed.emit(col_name, control.text)


func _on_spinbox_changed(value: float, col_name: String) -> void:
	if _is_updating:
		return
	var col_type = _get_column_type(col_name)
	if col_type == "integer":
		field_changed.emit(col_name, int(value))
	else:
		field_changed.emit(col_name, value)


func _on_option_selected(index: int, col_name: String, options: Array) -> void:
	if _is_updating:
		return
	if index >= 0 and index < options.size():
		field_changed.emit(col_name, str(options[index]))
