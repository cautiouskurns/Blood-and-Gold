@tool
extends Control
## Main panel for the Data Table Editor.
## Manages the table sidebar, data grid, and file operations.

# ===== CONSTANTS =====
const DATA_ROOT_PATH: String = "res://data/"
const SCHEMA_PATH: String = "res://data/_schemas/"

# ===== NODE REFERENCES =====
# Sidebar (now a component)
@onready var table_sidebar = %TableSidebar

# Toolbar
@onready var add_row_btn: Button = %AddRowBtn
@onready var duplicate_btn: Button = %DuplicateBtn
@onready var delete_btn: Button = %DeleteBtn
@onready var move_up_btn: Button = %MoveUpBtn
@onready var move_down_btn: Button = %MoveDownBtn
@onready var refresh_btn: Button = %RefreshBtn
@onready var save_btn: Button = %SaveBtn

# Grid
@onready var table_name_label: Label = $Margin/HSplit/RightPanel/TableNameLabel
@onready var data_grid: Tree = %DataGrid

# Status bar
@onready var row_count_label: Label = %RowCountLabel
@onready var selection_label: Label = %SelectionLabel
@onready var modified_label: Label = %ModifiedLabel
@onready var error_label: Label = %ErrorLabel

# ===== STATE =====
var _current_table_path: String = ""
var _current_table_data: Array = []
var _current_schema: Dictionary = {}
var _is_dirty: bool = false

# ===== LIFECYCLE =====
func _ready() -> void:
	# Force the panel to fill the entire main screen area
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_h_size_flags(Control.SIZE_EXPAND_FILL)
	set_v_size_flags(Control.SIZE_EXPAND_FILL)
	custom_minimum_size = Vector2(800, 600)

	_connect_signals()
	_update_toolbar_state()
	_update_status_bar()

	print("[DataTableEditor] Ready")


func _connect_signals() -> void:
	# Sidebar signals
	if table_sidebar:
		table_sidebar.table_selected.connect(_on_table_selected)
		table_sidebar.new_table_requested.connect(_on_new_table_pressed)
		table_sidebar.manage_schemas_requested.connect(_on_manage_schemas_pressed)
		table_sidebar.table_context_action.connect(_on_table_context_action)

	# Toolbar signals
	if add_row_btn:
		add_row_btn.pressed.connect(_on_add_row_pressed)
	if duplicate_btn:
		duplicate_btn.pressed.connect(_on_duplicate_pressed)
	if delete_btn:
		delete_btn.pressed.connect(_on_delete_pressed)
	if move_up_btn:
		move_up_btn.pressed.connect(_on_move_up_pressed)
	if move_down_btn:
		move_down_btn.pressed.connect(_on_move_down_pressed)
	if refresh_btn:
		refresh_btn.pressed.connect(_on_refresh_pressed)
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)

	# Grid signals (using TableGrid component)
	if data_grid:
		data_grid.row_selected.connect(_on_row_selected)
		data_grid.cell_edited.connect(_on_cell_edited)
		data_grid.selection_changed.connect(_on_selection_changed)


# ===== TABLE PARSING =====
func _parse_table_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		print("[DataTableEditor] Failed to parse %s: %s" % [path, json.get_error_message()])
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		return {}

	# Check if it looks like a data table (has "rows" array or "schema" field)
	if data.has("rows") or data.has("schema"):
		var rows = data.get("rows", [])
		return {
			"schema": data.get("schema", ""),
			"row_count": rows.size() if rows is Array else 0,
			"data": rows if rows is Array else []
		}

	return {}


# ===== TABLE LOADING =====
func _load_table(path: String) -> void:
	# Parse the table file directly
	var table_info = _parse_table_file(path)
	if table_info.is_empty():
		print("[DataTableEditor] Failed to load table: %s" % path)
		return

	_current_table_path = path
	_current_table_data = table_info.get("data", []).duplicate(true)

	# Load schema if available
	var schema_name = table_info.get("schema", "")
	if not schema_name.is_empty():
		_load_schema(schema_name)
	else:
		# Infer schema from data
		_infer_schema_from_data()

	# Load data into grid component
	if data_grid:
		data_grid.load_data(_current_table_data, _current_schema)

	_update_table_name_label()
	_update_toolbar_state()
	_update_status_bar()
	_is_dirty = false

	print("[DataTableEditor] Loaded table: %s (%d rows)" % [path, _current_table_data.size()])


func _load_schema(schema_name: String) -> void:
	# Use SchemaLoader to load schema with caching
	_current_schema = SchemaLoader.load_schema(schema_name)

	if _current_schema.is_empty():
		print("[DataTableEditor] Schema not found, inferring from data: %s" % schema_name)
		_infer_schema_from_data()
	else:
		print("[DataTableEditor] Loaded schema: %s" % schema_name)


func _infer_schema_from_data() -> void:
	# Use SchemaLoader to infer schema from data
	var table_name = _current_table_path.get_file().get_basename()
	_current_schema = SchemaLoader.infer_schema_from_data(_current_table_data, table_name)


# ===== DATA GRID HELPERS =====
## Refresh the grid display from current data and schema.
## Uses the TableGrid component for all rendering.
func _refresh_data_grid() -> void:
	if data_grid:
		data_grid.load_data(_current_table_data, _current_schema)


## Clear the grid display.
func _clear_data_grid() -> void:
	if data_grid:
		data_grid.clear_data()


# ===== UI UPDATES =====
func _update_table_name_label() -> void:
	if not table_name_label:
		return

	if _current_table_path.is_empty():
		table_name_label.text = "No table selected"
	else:
		var table_name = _current_table_path.get_file().get_basename()
		var dirty_marker = " *" if _is_dirty else ""
		table_name_label.text = table_name + dirty_marker


func _update_toolbar_state() -> void:
	var has_table = not _current_table_path.is_empty()
	var has_selection = data_grid and data_grid.get_selected_row_index() >= 0

	if add_row_btn:
		add_row_btn.disabled = not has_table
	if duplicate_btn:
		duplicate_btn.disabled = not has_selection
	if delete_btn:
		delete_btn.disabled = not has_selection
	if move_up_btn:
		move_up_btn.disabled = not has_selection
	if move_down_btn:
		move_down_btn.disabled = not has_selection
	if save_btn:
		save_btn.disabled = not has_table or not _is_dirty


func _update_status_bar() -> void:
	if row_count_label:
		var row_count = data_grid.get_row_count() if data_grid else _current_table_data.size()
		row_count_label.text = "%d rows" % row_count

	if selection_label:
		var selected_count = data_grid.get_selected_count() if data_grid else 0
		selection_label.text = "%d selected" % selected_count

	if modified_label:
		modified_label.text = "Modified" if _is_dirty else ""


func _mark_dirty() -> void:
	_is_dirty = true
	_update_table_name_label()
	_update_toolbar_state()
	_update_status_bar()
	# Notify sidebar of modified state
	if table_sidebar and not _current_table_path.is_empty():
		table_sidebar.mark_modified(_current_table_path, true)


# ===== SIGNAL HANDLERS =====
func _on_table_selected(path: String) -> void:
	if path.is_empty():
		return
	_load_table(path)


func _on_new_table_pressed() -> void:
	# TODO: Implement new table dialog
	print("[DataTableEditor] New table - not implemented yet")


func _on_manage_schemas_pressed() -> void:
	# TODO: Implement schema editor
	print("[DataTableEditor] Manage schemas - not implemented yet")


func _on_table_context_action(action: String, path: String) -> void:
	match action:
		"rename":
			print("[DataTableEditor] Rename table: %s - not implemented yet" % path)
		"duplicate":
			print("[DataTableEditor] Duplicate table: %s - not implemented yet" % path)
		"export_csv":
			_export_table_csv(path)
		"export_markdown":
			_export_table_markdown(path)
		"edit_schema":
			print("[DataTableEditor] Edit schema for: %s - not implemented yet" % path)
		"delete":
			print("[DataTableEditor] Delete table: %s - not implemented yet" % path)
		_:
			print("[DataTableEditor] Unknown context action: %s" % action)


func _export_table_csv(path: String) -> void:
	# Load the table data
	var table_info = table_sidebar.get_table_info(path)
	if table_info.is_empty():
		print("[DataTableEditor] Cannot export - table not found: %s" % path)
		return

	print("[DataTableEditor] Export CSV for: %s - not fully implemented yet" % path)
	# TODO: Implement file dialog and CSV export


func _export_table_markdown(path: String) -> void:
	print("[DataTableEditor] Export Markdown for: %s - not fully implemented yet" % path)
	# TODO: Implement file dialog and Markdown export


func _on_add_row_pressed() -> void:
	if _current_table_path.is_empty():
		return

	# Create new row with default values from schema
	var new_row: Dictionary = {}
	var columns = _current_schema.get("columns", [])
	for col in columns:
		var col_name = col.get("name", "")
		var default_value = SchemaLoader.get_column_default(col)
		new_row[col_name] = default_value

	_current_table_data.append(new_row)
	_refresh_data_grid()
	_mark_dirty()

	print("[DataTableEditor] Added new row")


func _on_duplicate_pressed() -> void:
	if not data_grid:
		return

	var row_index = data_grid.get_selected_row_index()
	if row_index < 0 or row_index >= _current_table_data.size():
		return

	var original_row = _current_table_data[row_index]
	var new_row = original_row.duplicate(true)

	# Update ID if present
	if new_row.has("id"):
		new_row.id = new_row.id + "_copy"

	_current_table_data.insert(row_index + 1, new_row)
	_refresh_data_grid()
	_mark_dirty()

	print("[DataTableEditor] Duplicated row %d" % row_index)


func _on_delete_pressed() -> void:
	if not data_grid:
		return

	var row_index = data_grid.get_selected_row_index()
	if row_index < 0 or row_index >= _current_table_data.size():
		return

	_current_table_data.remove_at(row_index)
	_refresh_data_grid()
	_mark_dirty()

	print("[DataTableEditor] Deleted row %d" % row_index)


func _on_move_up_pressed() -> void:
	if not data_grid:
		return

	var row_index = data_grid.get_selected_row_index()
	if row_index <= 0 or row_index >= _current_table_data.size():
		return

	# Swap with row above
	var temp = _current_table_data[row_index]
	_current_table_data[row_index] = _current_table_data[row_index - 1]
	_current_table_data[row_index - 1] = temp

	_refresh_data_grid()
	_mark_dirty()

	# Reselect the moved row
	data_grid.select_row(row_index - 1)

	print("[DataTableEditor] Moved row %d up" % row_index)


func _on_move_down_pressed() -> void:
	if not data_grid:
		return

	var row_index = data_grid.get_selected_row_index()
	if row_index < 0 or row_index >= _current_table_data.size() - 1:
		return

	# Swap with row below
	var temp = _current_table_data[row_index]
	_current_table_data[row_index] = _current_table_data[row_index + 1]
	_current_table_data[row_index + 1] = temp

	_refresh_data_grid()
	_mark_dirty()

	# Reselect the moved row
	data_grid.select_row(row_index + 1)

	print("[DataTableEditor] Moved row %d down" % row_index)


func _on_refresh_pressed() -> void:
	if table_sidebar:
		table_sidebar.refresh()

	# Reload current table if still exists
	var table_paths = table_sidebar.get_all_table_paths() if table_sidebar else []
	if not _current_table_path.is_empty() and _current_table_path in table_paths:
		_load_table(_current_table_path)
	else:
		_current_table_path = ""
		_current_table_data = []
		_current_schema = {}
		_clear_data_grid()
		_update_table_name_label()

	_update_toolbar_state()
	_update_status_bar()

	print("[DataTableEditor] Refreshed")


func _on_save_pressed() -> void:
	if _current_table_path.is_empty():
		return

	_save_table(_current_table_path)


func _save_table(path: String) -> void:
	# Build the save data
	var save_data: Dictionary = {
		"schema": _current_schema.get("name", ""),
		"version": "1.0",
		"rows": _current_table_data
	}

	var json_text = JSON.stringify(save_data, "  ")

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		print("[DataTableEditor] Failed to open file for writing: %s" % path)
		if error_label:
			error_label.text = "Save failed!"
		return

	file.store_string(json_text)
	file.close()

	_is_dirty = false
	_update_table_name_label()
	_update_toolbar_state()
	_update_status_bar()

	# Clear modified indicator in sidebar
	if table_sidebar:
		table_sidebar.mark_modified(path, false)

	print("[DataTableEditor] Saved table: %s" % path)


func _on_row_selected(row_index: int) -> void:
	_update_toolbar_state()
	_update_status_bar()


func _on_cell_edited(row_index: int, column_name: String, new_value: Variant) -> void:
	if row_index < 0 or row_index >= _current_table_data.size():
		return

	# Update the data
	_current_table_data[row_index][column_name] = new_value
	_mark_dirty()

	print("[DataTableEditor] Edited row %d, col '%s' = %s" % [row_index, column_name, new_value])


func _on_selection_changed(selected_count: int) -> void:
	_update_toolbar_state()
	_update_status_bar()


# ===== INPUT HANDLING =====
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventKey and event.pressed:
		var handled := false

		# F5 - Refresh
		if event.keycode == KEY_F5 and not event.ctrl_pressed:
			_on_refresh_pressed()
			handled = true

		# Delete - Delete selected
		if event.keycode == KEY_DELETE and not event.ctrl_pressed:
			_on_delete_pressed()
			handled = true

		if event.ctrl_pressed:
			match event.keycode:
				KEY_N:  # Ctrl+N - Add row
					_on_add_row_pressed()
					handled = true
				KEY_D:  # Ctrl+D - Duplicate
					_on_duplicate_pressed()
					handled = true
				KEY_S:  # Ctrl+S - Save
					_on_save_pressed()
					handled = true
				KEY_UP:  # Ctrl+Up - Move up
					_on_move_up_pressed()
					handled = true
				KEY_DOWN:  # Ctrl+Down - Move down
					_on_move_down_pressed()
					handled = true

		if handled:
			get_viewport().set_input_as_handled()
