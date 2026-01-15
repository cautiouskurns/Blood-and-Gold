@tool
extends Tree
## Table Grid for the Data Table Editor.
## Displays table data in a spreadsheet-style grid with schema-based columns.
## Supports inline editing with type-aware controls and validation.
## Spec: docs/tools/data-table-editor-roadmap.md - Features 1.4, 1.5

# ===== SIGNALS =====
signal row_selected(row_index: int)
signal cell_edited(row_index: int, column_name: String, new_value: Variant)
signal selection_changed(selected_count: int)
signal validation_error(row_index: int, column_name: String, error_message: String)
signal filter_changed(visible_count: int, total_count: int)

# ===== STATE =====
var _current_schema: Dictionary = {}
var _current_data: Array = []
var _columns: Array = []  # Array of column definitions
var _modified_rows: Dictionary = {}  # row_index -> true for modified rows
var _current_filter: String = ""  # Current filter text

# Sorting state
var _sort_column_index: int = -1  # Currently sorted column (-1 = none)
var _sort_ascending: bool = true  # Sort direction
var _original_column_titles: Array = []  # Store original titles without sort indicators

# Enum dropdown state
var _enum_popup: PopupMenu = null
var _enum_edit_item: TreeItem = null  # Item being edited
var _enum_edit_column: int = -1  # Column index being edited


# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_tree()


func _setup_tree() -> void:
	hide_root = true
	column_titles_visible = true
	select_mode = Tree.SELECT_MULTI  # Allow multi-row selection with Ctrl/Shift+click
	allow_rmb_select = true

	# Connect internal signals
	print("[TableGrid] Connecting item_selected signal")
	item_selected.connect(_on_item_selected)
	item_edited.connect(_on_item_edited)
	multi_selected.connect(_on_multi_selected)

	# Handle checkbox clicks for boolean columns
	button_clicked.connect(_on_button_clicked)

	# Handle column header clicks for sorting
	column_title_clicked.connect(_on_column_title_clicked)

	# Handle double-click for enum dropdown
	item_activated.connect(_on_item_activated)

	# Create enum dropdown popup
	_setup_enum_popup()

	# Ensure at least 1 column
	columns = 1
	set_column_title(0, "No data")


## Setup the PopupMenu for enum dropdown editing.
func _setup_enum_popup() -> void:
	_enum_popup = PopupMenu.new()
	_enum_popup.name = "EnumPopup"
	add_child(_enum_popup)
	_enum_popup.id_pressed.connect(_on_enum_popup_selected)


# ===== PUBLIC API =====

## Load table data into the grid using the provided schema.
## @param data: Array of row dictionaries
## @param schema: Schema dictionary with column definitions
func load_data(data: Array, schema: Dictionary) -> void:
	_current_data = data
	_current_schema = schema
	_columns = _get_columns_from_schema()
	_modified_rows.clear()
	_current_filter = ""

	# Reset sort state when loading new data
	_sort_column_index = -1
	_sort_ascending = true
	_original_column_titles.clear()

	_setup_columns()
	_populate_rows()

	print("[TableGrid] Loaded %d rows with %d columns" % [data.size(), _columns.size()])


## Clear all data from the grid.
func clear_data() -> void:
	_current_data = []
	_current_schema = {}
	_columns = []
	_modified_rows.clear()
	_current_filter = ""
	_sort_column_index = -1
	_sort_ascending = true
	_original_column_titles.clear()
	clear()
	columns = 1
	set_column_title(0, "No data")


## Get the currently selected row index, or -1 if none selected.
func get_selected_row_index() -> int:
	var selected = get_selected()
	if not selected:
		return -1
	var metadata = selected.get_metadata(0)
	# Handle both int (legacy) and Dictionary (cell metadata) formats
	if metadata is int:
		return metadata
	elif metadata is Dictionary:
		return metadata.get("row_index", -1)
	return -1


## Get all selected row indices.
func get_selected_row_indices() -> Array[int]:
	var indices: Array[int] = []
	var item = get_next_selected(null)
	while item:
		var index = _get_row_index_from_item(item)
		if index >= 0:
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


## Update a single cell's value and display.
## Used for two-way binding with detail panel.
func update_cell(row_index: int, column_name: String, new_value: Variant) -> void:
	if row_index < 0 or row_index >= _current_data.size():
		return

	# Find the column index
	var col_index := -1
	for i in range(_columns.size()):
		if _columns[i].get("name", "") == column_name:
			col_index = i
			break

	if col_index < 0:
		return

	# Find the TreeItem for this row
	var root = get_root()
	if not root:
		return

	var child = root.get_first_child()
	while child:
		if _get_row_index_from_item(child) == row_index:
			var col_type = _columns[col_index].get("type", "string")
			# Update cell display
			_configure_cell_for_type(child, col_index, col_type, new_value)
			_style_cell(child, col_index, col_type, new_value)
			# Mark row as modified
			mark_row_modified(row_index, true)
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


## Check if a row has been modified.
func is_row_modified(row_index: int) -> bool:
	return _modified_rows.get(row_index, false)


## Mark a row as modified or unmodified.
func mark_row_modified(row_index: int, modified: bool = true) -> void:
	if modified:
		_modified_rows[row_index] = true
	else:
		_modified_rows.erase(row_index)
	_update_row_modified_indicator(row_index)


## Clear all modified row indicators.
func clear_modified_indicators() -> void:
	var rows_to_update = _modified_rows.keys()
	_modified_rows.clear()
	for row_index in rows_to_update:
		_update_row_modified_indicator(row_index)


## Get list of modified row indices.
func get_modified_row_indices() -> Array[int]:
	var indices: Array[int] = []
	for row_index in _modified_rows.keys():
		indices.append(row_index)
	return indices


# ===== FILTERING =====

## Filter visible rows by search text. Matches against all visible columns.
## @param search_text: Text to search for (case-insensitive). Empty string shows all rows.
func filter_rows(search_text: String) -> void:
	_current_filter = search_text.to_lower().strip_edges()
	_apply_filter()


## Clear the current filter and show all rows.
func clear_filter() -> void:
	_current_filter = ""
	_apply_filter()


## Get the current filter text.
func get_filter_text() -> String:
	return _current_filter


## Get count of visible (non-filtered) rows.
func get_visible_row_count() -> int:
	var root = get_root()
	if not root:
		return 0

	var count := 0
	var child = root.get_first_child()
	while child:
		if child.visible:
			count += 1
		child = child.get_next()
	return count


# ===== SORTING =====

## Sort the grid by a column. Clicking the same column toggles direction.
## @param column_index: The column index to sort by
## @param ascending: Sort direction (true = A-Z/0-9, false = Z-A/9-0)
func sort_by_column(column_index: int, ascending: bool = true) -> void:
	if column_index < 0 or column_index >= _columns.size():
		return

	_sort_column_index = column_index
	_sort_ascending = ascending

	var col = _columns[column_index]
	var col_name = col.get("name", "")
	var col_type = col.get("type", "string")

	# Sort the data array
	_current_data.sort_custom(func(a, b):
		var val_a = a.get(col_name, "") if a is Dictionary else ""
		var val_b = b.get(col_name, "") if b is Dictionary else ""

		var result: int = _compare_values(val_a, val_b, col_type)
		return result < 0 if ascending else result > 0
	)

	# Refresh display
	_populate_rows()
	_update_column_sort_indicators()

	# Re-apply filter if active
	if not _current_filter.is_empty():
		_apply_filter()

	print("[TableGrid] Sorted by column '%s' (%s)" % [col_name, "ascending" if ascending else "descending"])


## Compare two values based on column type for sorting.
func _compare_values(val_a: Variant, val_b: Variant, col_type: String) -> int:
	# Handle null values - nulls sort to the end
	if val_a == null and val_b == null:
		return 0
	if val_a == null:
		return 1
	if val_b == null:
		return -1

	match col_type:
		"integer":
			var a_int = int(val_a) if val_a is float or val_a is int or (val_a is String and val_a.is_valid_int()) else 0
			var b_int = int(val_b) if val_b is float or val_b is int or (val_b is String and val_b.is_valid_int()) else 0
			return a_int - b_int
		"float":
			var a_float = float(val_a) if val_a is float or val_a is int or (val_a is String and val_a.is_valid_float()) else 0.0
			var b_float = float(val_b) if val_b is float or val_b is int or (val_b is String and val_b.is_valid_float()) else 0.0
			if a_float < b_float:
				return -1
			elif a_float > b_float:
				return 1
			return 0
		"boolean":
			var a_bool = bool(val_a)
			var b_bool = bool(val_b)
			if a_bool == b_bool:
				return 0
			return -1 if not a_bool else 1  # false < true
		_:
			# String comparison (default)
			var a_str = str(val_a).to_lower()
			var b_str = str(val_b).to_lower()
			if a_str < b_str:
				return -1
			elif a_str > b_str:
				return 1
			return 0


## Update column headers to show sort indicator on sorted column.
func _update_column_sort_indicators() -> void:
	# Store original titles if not already stored
	if _original_column_titles.is_empty():
		for i in range(_columns.size()):
			var col = _columns[i]
			var col_name = col.get("name", "Column %d" % i)
			var display_name = col.get("display_name", col_name.capitalize().replace("_", " "))
			_original_column_titles.append(display_name)

	# Update all column titles
	for i in range(_columns.size()):
		var title = _original_column_titles[i] if i < _original_column_titles.size() else "Column %d" % i
		if i == _sort_column_index:
			# Add sort indicator
			var indicator = " ▲" if _sort_ascending else " ▼"
			title = title + indicator
		set_column_title(i, title)


## Clear sorting and restore original order.
func clear_sort() -> void:
	_sort_column_index = -1
	_sort_ascending = true
	_update_column_sort_indicators()


## Get current sort column index (-1 if not sorted).
func get_sort_column() -> int:
	return _sort_column_index


## Get current sort direction.
func is_sort_ascending() -> bool:
	return _sort_ascending


## Handle column header clicks for sorting.
func _on_column_title_clicked(column: int, mouse_button_index: int) -> void:
	# Only respond to left-click
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return

	if column == _sort_column_index:
		# Same column - toggle direction
		sort_by_column(column, not _sort_ascending)
	else:
		# New column - sort ascending
		sort_by_column(column, true)


## Apply the current filter to all rows.
func _apply_filter() -> void:
	var root = get_root()
	if not root:
		filter_changed.emit(0, 0)
		return

	var visible_count := 0
	var total_count := 0
	var child = root.get_first_child()

	while child:
		total_count += 1
		var row_index = _get_row_index_from_item(child)

		if _current_filter.is_empty():
			# No filter - show all
			child.visible = true
			visible_count += 1
		else:
			# Check if any visible column contains the filter text
			var matches := false
			if row_index >= 0 and row_index < _current_data.size():
				var row_data = _current_data[row_index]
				if row_data is Dictionary:
					for col in _columns:
						var col_name = col.get("name", "")
						var value = row_data.get(col_name, "")
						var value_str = str(value).to_lower()
						if value_str.contains(_current_filter):
							matches = true
							break

			child.visible = matches
			if matches:
				visible_count += 1

		child = child.get_next()

	filter_changed.emit(visible_count, total_count)
	print("[TableGrid] Filter '%s': showing %d of %d rows" % [_current_filter, visible_count, total_count])


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

		# Set cell metadata for type-aware editing (before setting cell mode)
		item.set_metadata(col_index, {
			"row_index": row_index,
			"column_name": col_name,
			"column_type": col_type,
			"original_value": value
		})

		# Configure cell based on type
		_configure_cell_for_type(item, col_index, col_type, value)

		# Apply visual styling based on type
		_style_cell(item, col_index, col_type, value)

	# Apply modified indicator if this row is modified
	if _modified_rows.get(row_index, false):
		_apply_modified_indicator(item, true)


## Configure a cell's editing mode based on column type.
func _configure_cell_for_type(item: TreeItem, col_index: int, col_type: String, value: Variant) -> void:
	match col_type:
		"boolean":
			# Use checkbox mode for booleans
			item.set_cell_mode(col_index, TreeItem.CELL_MODE_CHECK)
			item.set_checked(col_index, bool(value))
			item.set_editable(col_index, true)
			item.set_text(col_index, "")  # No text, just checkbox
		"integer", "float":
			# Range mode could be used but text is simpler for now
			item.set_cell_mode(col_index, TreeItem.CELL_MODE_STRING)
			item.set_text(col_index, _value_to_display(value, col_type))
			item.set_editable(col_index, true)
		"enum":
			# Enum uses popup dropdown - NOT inline text editing
			item.set_cell_mode(col_index, TreeItem.CELL_MODE_STRING)
			item.set_text(col_index, _value_to_display(value, col_type))
			item.set_editable(col_index, false)  # Disabled - we use popup instead
		"dice":
			# Dice notation with tooltip showing avg/min/max
			item.set_cell_mode(col_index, TreeItem.CELL_MODE_STRING)
			item.set_text(col_index, _value_to_display(value, col_type))
			item.set_editable(col_index, true)
			# Set tooltip with dice statistics
			var tooltip = DiceParser.get_tooltip(str(value))
			item.set_tooltip_text(col_index, tooltip)
		_:
			# Default string mode
			item.set_cell_mode(col_index, TreeItem.CELL_MODE_STRING)
			item.set_text(col_index, _value_to_display(value, col_type))
			item.set_editable(col_index, true)


## Apply or remove the modified indicator on a row.
func _apply_modified_indicator(item: TreeItem, is_modified: bool) -> void:
	if is_modified:
		# Show * suffix on first column
		item.set_suffix(0, " *")
		# Yellow tint for modified rows - apply to all columns for visibility
		var modified_color = Color(0.5, 0.4, 0.1, 0.4)
		for col_idx in range(columns):
			item.set_custom_bg_color(col_idx, modified_color)
		print("[TableGrid] Applied modified indicator to row")
	else:
		item.set_suffix(0, "")
		for col_idx in range(columns):
			item.clear_custom_bg_color(col_idx)


## Get row index from TreeItem metadata (handles both int and Dictionary formats).
func _get_row_index_from_item(item: TreeItem) -> int:
	var metadata = item.get_metadata(0)
	if metadata is int:
		return metadata
	elif metadata is Dictionary:
		return metadata.get("row_index", -1)
	return -1


## Update the modified indicator for a specific row.
func _update_row_modified_indicator(row_index: int) -> void:
	var root = get_root()
	if not root:
		return

	var child = root.get_first_child()
	while child:
		if _get_row_index_from_item(child) == row_index:
			_apply_modified_indicator(child, _modified_rows.get(row_index, false))
			return
		child = child.get_next()


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
		"dice":
			# Color-code dice notation based on validity
			var dice_str = str(value)
			if dice_str.is_empty():
				item.set_custom_color(col_index, Color(0.7, 0.7, 0.7))  # Gray for empty
			elif DiceParser.is_valid(dice_str):
				item.set_custom_color(col_index, Color(0.5, 0.9, 0.5))  # Green for valid
				# Add checkmark suffix for valid dice
				item.set_suffix(col_index, " ✓")
			else:
				item.set_custom_color(col_index, Color(1.0, 0.4, 0.4))  # Red for invalid
				# Add error suffix for invalid dice
				item.set_suffix(col_index, " ✗")
				# Also set red background tint for visibility
				item.set_custom_bg_color(col_index, Color(0.5, 0.1, 0.1, 0.3))


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
	print("[TableGrid] _on_item_selected called")
	var selected = get_selected()
	if not selected:
		print("[TableGrid] No selected item")
		return

	var row_index = _get_row_index_from_item(selected)
	print("[TableGrid] Selected row_index: %d" % row_index)
	if row_index >= 0:
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

	var new_value: Variant

	# Handle different cell modes
	if col_type == "boolean":
		# For checkboxes, get the checked state
		new_value = selected.is_checked(col_index)
		print("[TableGrid] Boolean checkbox toggled to: %s" % new_value)
	else:
		# For text cells, convert the text to appropriate type
		var new_text = selected.get_text(col_index)
		new_value = _string_to_value(new_text, col_type)

	var row_index = _get_row_index_from_item(selected)
	if row_index < 0:
		print("[TableGrid] Could not get row index from item")
		return

	# Validate the new value
	var validation_result = _validate_cell_value(new_value, col)
	if not validation_result.valid:
		# Emit validation error
		validation_error.emit(row_index, col_name, validation_result.error)
		# Revert to original value
		var cell_metadata = selected.get_metadata(col_index)
		if cell_metadata is Dictionary:
			var original_value = cell_metadata.get("original_value")
			_configure_cell_for_type(selected, col_index, col_type, original_value)
			_style_cell(selected, col_index, col_type, original_value)
		print("[TableGrid] Validation failed for %s: %s" % [col_name, validation_result.error])
		return

	# Mark row as modified
	print("[TableGrid] Marking row %d as modified" % row_index)
	mark_row_modified(row_index, true)

	# Update the cell styling
	_style_cell(selected, col_index, col_type, new_value)

	# Emit the edit signal
	cell_edited.emit(row_index, col_name, new_value)


func _on_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	print("[TableGrid] _on_multi_selected: column=%d, selected=%s" % [column, selected])
	selection_changed.emit(get_selected_count())

	# Also emit row_selected for the first selected item to update detail panel
	if selected:
		var row_index = _get_row_index_from_item(item)
		if row_index >= 0:
			print("[TableGrid] Emitting row_selected from multi_selected: %d" % row_index)
			row_selected.emit(row_index)


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	# This handles button clicks in cells (though checkboxes use item_edited)
	# Reserved for future use with custom buttons
	pass


## Handle double-click on items - used for enum dropdown.
func _on_item_activated() -> void:
	var selected = get_selected()
	if not selected:
		return

	var col_index = get_selected_column()
	if col_index < 0 or col_index >= _columns.size():
		return

	var col = _columns[col_index]
	var col_type = col.get("type", "string")

	# Only handle enum columns with popup
	if col_type == "enum":
		_show_enum_popup(selected, col_index, col)


## Show the enum popup dropdown for a cell.
func _show_enum_popup(item: TreeItem, col_index: int, column: Dictionary) -> void:
	# Get enum options from column definition
	var options = column.get("options", [])
	if options.is_empty():
		print("[TableGrid] Enum column has no options defined")
		return

	# Store edit context
	_enum_edit_item = item
	_enum_edit_column = col_index

	# Clear and populate popup
	_enum_popup.clear()
	var current_value = item.get_text(col_index)

	for i in range(options.size()):
		var option = str(options[i])
		_enum_popup.add_item(option, i)
		# Mark current value with a checkmark
		if option == current_value:
			_enum_popup.set_item_checked(i, true)

	# Position popup below the cell using screen coordinates
	var cell_rect = get_item_area_rect(item, col_index)
	# Get screen position of the Tree widget
	var tree_screen_pos = get_screen_position()
	var popup_pos = tree_screen_pos + cell_rect.position + Vector2(0, cell_rect.size.y)

	# Show popup at correct screen position
	_enum_popup.popup(Rect2i(Vector2i(popup_pos), Vector2i(max(int(cell_rect.size.x), 120), 0)))
	print("[TableGrid] Showing enum popup at screen pos: %s" % popup_pos)


## Handle enum popup selection.
func _on_enum_popup_selected(id: int) -> void:
	if not _enum_edit_item or _enum_edit_column < 0:
		return

	var col = _columns[_enum_edit_column]
	var options = col.get("options", [])

	if id < 0 or id >= options.size():
		return

	var new_value = str(options[id])
	var old_value = _enum_edit_item.get_text(_enum_edit_column)

	# Only update if value changed
	if new_value != old_value:
		var row_index = _get_row_index_from_item(_enum_edit_item)
		var col_name = col.get("name", "")

		# Update cell display
		_enum_edit_item.set_text(_enum_edit_column, new_value)

		# Mark row as modified
		mark_row_modified(row_index, true)

		# Emit edit signal
		cell_edited.emit(row_index, col_name, new_value)
		print("[TableGrid] Enum value changed: %s -> %s" % [old_value, new_value])

	# Clear edit context
	_enum_edit_item = null
	_enum_edit_column = -1


# ===== VALIDATION =====

## Validate a cell value against its column definition.
func _validate_cell_value(value: Variant, column: Dictionary) -> Dictionary:
	# Use SchemaLoader validation if available
	var result = SchemaLoader.validate_value(value, column)
	return result
