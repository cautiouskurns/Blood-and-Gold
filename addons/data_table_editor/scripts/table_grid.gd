@tool
extends Tree
## Table Grid for the Data Table Editor.
## Displays table data in a spreadsheet-style grid with schema-based columns.
## Spec: docs/tools/data-table-editor-roadmap.md - Feature 1.4

# ===== SIGNALS =====
signal row_selected(row_index: int)
signal cell_edited(row_index: int, column_name: String, new_value: Variant)
signal selection_changed(selected_count: int)

# ===== STATE =====
var _current_schema: Dictionary = {}
var _current_data: Array = []
var _columns: Array = []  # Array of column definitions


# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_tree()


func _setup_tree() -> void:
	hide_root = true
	column_titles_visible = true
	select_mode = Tree.SELECT_ROW
	allow_rmb_select = true

	# Connect internal signals
	item_selected.connect(_on_item_selected)
	item_edited.connect(_on_item_edited)
	multi_selected.connect(_on_multi_selected)

	# Ensure at least 1 column
	columns = 1
	set_column_title(0, "No data")


# ===== PUBLIC API =====

## Load table data into the grid using the provided schema.
## @param data: Array of row dictionaries
## @param schema: Schema dictionary with column definitions
func load_data(data: Array, schema: Dictionary) -> void:
	_current_data = data
	_current_schema = schema
	_columns = _get_columns_from_schema()

	_setup_columns()
	_populate_rows()

	print("[TableGrid] Loaded %d rows with %d columns" % [data.size(), _columns.size()])


## Clear all data from the grid.
func clear_data() -> void:
	_current_data = []
	_current_schema = {}
	_columns = []
	clear()
	columns = 1
	set_column_title(0, "No data")


## Get the currently selected row index, or -1 if none selected.
func get_selected_row_index() -> int:
	var selected = get_selected()
	if not selected:
		return -1
	return selected.get_metadata(0)


## Get all selected row indices.
func get_selected_row_indices() -> Array[int]:
	var indices: Array[int] = []
	var item = get_next_selected(null)
	while item:
		var index = item.get_metadata(0)
		if index is int:
			indices.append(index)
		item = get_next_selected(item)
	return indices


## Get the number of selected rows.
func get_selected_count() -> int:
	var count := 0
	var item = get_next_selected(null)
	while item:
		count += 1
		item = get_next_selected(item)
	return count


## Select a row by index.
func select_row(row_index: int) -> void:
	var root = get_root()
	if not root:
		return

	var child = root.get_first_child()
	while child:
		if child.get_metadata(0) == row_index:
			child.select(0)
			return
		child = child.get_next()


## Refresh the display of a specific row.
func refresh_row(row_index: int) -> void:
	if row_index < 0 or row_index >= _current_data.size():
		return

	var root = get_root()
	if not root:
		return

	var child = root.get_first_child()
	while child:
		if child.get_metadata(0) == row_index:
			_populate_row_item(child, row_index)
			return
		child = child.get_next()


## Refresh all rows from current data.
func refresh_all() -> void:
	_populate_rows()


## Get the current row count.
func get_row_count() -> int:
	return _current_data.size()


## Get the column name at a specific index.
func get_column_name(col_index: int) -> String:
	if col_index < 0 or col_index >= _columns.size():
		return ""
	return _columns[col_index].get("name", "")


## Get the column type at a specific index.
func get_column_type(col_index: int) -> String:
	if col_index < 0 or col_index >= _columns.size():
		return "string"
	return _columns[col_index].get("type", "string")


# ===== COLUMN SETUP =====

func _get_columns_from_schema() -> Array:
	var cols = _current_schema.get("columns", [])

	# If schema has display.grid_columns, use that subset
	var display = _current_schema.get("display", {})
	var grid_columns = display.get("grid_columns", [])

	if not grid_columns.is_empty():
		# Filter columns to only those in grid_columns, in that order
		var filtered: Array = []
		for col_name in grid_columns:
			var col = SchemaLoader.get_column(_current_schema, col_name)
			if not col.is_empty():
				filtered.append(col)
		if not filtered.is_empty():
			return filtered

	# Fall back to all columns
	if cols.is_empty() and not _current_data.is_empty():
		# Infer from data if no schema columns
		var first_row = _current_data[0]
		if first_row is Dictionary:
			for key in first_row.keys():
				cols.append({"name": key, "type": "string", "inferred": true})

	return cols


func _setup_columns() -> void:
	# Ensure at least 1 column (Tree requires columns >= 1)
	if _columns.is_empty():
		columns = 1
		set_column_title(0, "No data")
		return

	columns = _columns.size()

	for i in range(_columns.size()):
		var col = _columns[i]
		var col_name = col.get("name", "Column %d" % i)
		var display_name = col.get("display_name", col_name.capitalize().replace("_", " "))

		set_column_title(i, display_name)
		set_column_expand(i, true)
		set_column_clip_content(i, true)

		# Set minimum width based on column type
		var col_type = col.get("type", "string")
		var min_width = _get_column_min_width(col_type)
		set_column_custom_minimum_width(i, min_width)


func _get_column_min_width(col_type: String) -> int:
	match col_type:
		"boolean":
			return 60
		"integer", "float":
			return 80
		"enum":
			return 100
		"id", "string":
			return 120
		_:
			return 100


# ===== ROW POPULATION =====

func _populate_rows() -> void:
	clear()

	if _columns.is_empty():
		return

	var root = create_item()

	for row_index in range(_current_data.size()):
		var row_data = _current_data[row_index]
		if not row_data is Dictionary:
			continue

		var item = create_item(root)
		item.set_metadata(0, row_index)  # Store row index
		_populate_row_item(item, row_index)


func _populate_row_item(item: TreeItem, row_index: int) -> void:
	if row_index < 0 or row_index >= _current_data.size():
		return

	var row_data = _current_data[row_index]
	if not row_data is Dictionary:
		return

	for col_index in range(_columns.size()):
		var col = _columns[col_index]
		var col_name = col.get("name", "")
		var col_type = col.get("type", "string")
		var value = row_data.get(col_name, "")

		# Convert value to display string
		var display_text = _value_to_display(value, col_type)
		item.set_text(col_index, display_text)

		# Make cells editable
		item.set_editable(col_index, true)

		# Set cell metadata for type-aware editing
		item.set_metadata(col_index, {
			"row_index": row_index,
			"column_name": col_name,
			"column_type": col_type,
			"original_value": value
		})

		# Apply visual styling based on type
		_style_cell(item, col_index, col_type, value)


func _value_to_display(value: Variant, col_type: String) -> String:
	if value == null:
		return ""

	match col_type:
		"boolean":
			return "true" if value else "false"
		"integer":
			return str(int(value)) if value is float else str(value)
		"float":
			if value is float:
				# Format to 2 decimal places if needed
				return "%.2f" % value if value != int(value) else str(int(value))
			return str(value)
		"array":
			if value is Array:
				return "[%d items]" % value.size() if value.size() > 3 else JSON.stringify(value)
			return str(value)
		"json":
			if value is Dictionary:
				return "{%d keys}" % value.size() if value.size() > 3 else JSON.stringify(value)
			return str(value)
		"enum":
			return str(value)
		_:
			return str(value)


func _style_cell(item: TreeItem, col_index: int, col_type: String, value: Variant) -> void:
	# Apply subtle styling based on content
	match col_type:
		"boolean":
			if value == true:
				item.set_custom_color(col_index, Color(0.5, 0.9, 0.5))  # Green for true
			else:
				item.set_custom_color(col_index, Color(0.7, 0.7, 0.7))  # Gray for false
		"integer", "float":
			if value is int or value is float:
				if value < 0:
					item.set_custom_color(col_index, Color(1.0, 0.6, 0.6))  # Red for negative
		"enum":
			# Could color-code enum values in the future
			pass


# ===== VALUE CONVERSION =====

## Convert edited string back to appropriate value type.
func _string_to_value(text: String, col_type: String) -> Variant:
	match col_type:
		"boolean":
			return text.to_lower() in ["true", "1", "yes"]
		"integer":
			return int(text) if text.is_valid_int() else 0
		"float":
			return float(text) if text.is_valid_float() else 0.0
		"array", "json":
			var json = JSON.new()
			if json.parse(text) == OK:
				return json.get_data()
			return text
		_:
			return text


# ===== SIGNAL HANDLERS =====

func _on_item_selected() -> void:
	var selected = get_selected()
	if not selected:
		return

	var row_index = selected.get_metadata(0)
	if row_index is int:
		row_selected.emit(row_index)

	selection_changed.emit(get_selected_count())


func _on_item_edited() -> void:
	var selected = get_selected()
	if not selected:
		return

	var col_index = get_selected_column()
	if col_index < 0 or col_index >= _columns.size():
		return

	var col = _columns[col_index]
	var col_name = col.get("name", "")
	var col_type = col.get("type", "string")
	var new_text = selected.get_text(col_index)
	var new_value = _string_to_value(new_text, col_type)

	var row_index = selected.get_metadata(0)
	if row_index is int:
		cell_edited.emit(row_index, col_name, new_value)


func _on_multi_selected(_item: TreeItem, _column: int, _selected: bool) -> void:
	selection_changed.emit(get_selected_count())
