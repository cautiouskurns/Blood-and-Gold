@tool
extends VBoxContainer
## Table Sidebar for the Data Table Editor.
## Displays all data tables organized by category with search filtering.
## Spec: docs/tools/data-table-editor-roadmap.md - Feature 1.2

# ===== SIGNALS =====
signal table_selected(path: String)
signal new_table_requested()
signal manage_schemas_requested()
signal table_context_action(action: String, path: String)

# ===== CONSTANTS =====
const DATA_ROOT_PATH: String = "res://data/"
const SCHEMA_PATH: String = "res://data/_schemas/"

# Category icons (using Godot editor icons)
const CATEGORY_ICONS: Dictionary = {
	"items": "Mesh",
	"abilities": "AnimationLibrary",
	"enemies": "Skeleton2D",
	"npcs": "AnimatedSprite2D",
	"loot": "RandomNumberGenerator",
	"locations": "Navigation2D",
	"quests": "Script",
	"default": "Folder"
}

# ===== NODE REFERENCES =====
@onready var search_edit: LineEdit = $SearchEdit
@onready var table_tree: Tree = $TableTree
@onready var new_table_btn: Button = $ButtonBox/NewTableBtn
@onready var manage_schemas_btn: Button = $ButtonBox/ManageSchemasBtn

# ===== STATE =====
var _tables: Dictionary = {}  # path -> TableInfo {schema, row_count, category}
var _modified_tables: Dictionary = {}  # path -> bool (tracks which tables have unsaved changes)
var _error_tables: Dictionary = {}  # path -> String (tracks tables with errors)
var _search_filter: String = ""
var _context_menu: PopupMenu = null


# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_tree()
	_setup_search()
	_setup_buttons()
	_setup_context_menu()
	_ensure_data_directories()
	refresh()


func _setup_tree() -> void:
	if not table_tree:
		return

	table_tree.hide_root = true
	table_tree.allow_rmb_select = true
	table_tree.item_selected.connect(_on_item_selected)
	table_tree.item_mouse_selected.connect(_on_item_mouse_selected)


func _setup_search() -> void:
	if not search_edit:
		return

	search_edit.placeholder_text = "Search tables..."
	search_edit.clear_button_enabled = true
	search_edit.text_changed.connect(_on_search_changed)


func _setup_buttons() -> void:
	if new_table_btn:
		new_table_btn.pressed.connect(_on_new_table_btn_pressed)
	if manage_schemas_btn:
		manage_schemas_btn.pressed.connect(_on_manage_schemas_btn_pressed)


func _setup_context_menu() -> void:
	_context_menu = PopupMenu.new()
	_context_menu.name = "ContextMenu"
	_context_menu.add_item("Rename Table", 0)
	_context_menu.add_item("Duplicate Table", 1)
	_context_menu.add_separator()
	_context_menu.add_item("Export to CSV", 2)
	_context_menu.add_item("Export to Markdown", 3)
	_context_menu.add_separator()
	_context_menu.add_item("Edit Schema", 4)
	_context_menu.add_separator()
	_context_menu.add_item("Delete Table", 5)
	_context_menu.id_pressed.connect(_on_context_menu_selected)
	add_child(_context_menu)


func _ensure_data_directories() -> void:
	if not DirAccess.dir_exists_absolute(DATA_ROOT_PATH):
		DirAccess.make_dir_recursive_absolute(DATA_ROOT_PATH)
		print("[TableSidebar] Created data directory: %s" % DATA_ROOT_PATH)

	if not DirAccess.dir_exists_absolute(SCHEMA_PATH):
		DirAccess.make_dir_recursive_absolute(SCHEMA_PATH)
		print("[TableSidebar] Created schemas directory: %s" % SCHEMA_PATH)


# ===== PUBLIC API =====

## Refresh the table list by rescanning the data folder.
func refresh() -> void:
	_scan_data_folder()
	_populate_tree()
	print("[TableSidebar] Refreshed - Found %d tables" % _tables.size())


## Mark a table as modified (shows indicator in sidebar).
func mark_modified(path: String, is_modified: bool) -> void:
	if is_modified:
		_modified_tables[path] = true
	else:
		_modified_tables.erase(path)
	_update_table_item(path)


## Mark a table as having an error.
func mark_error(path: String, error_message: String) -> void:
	if error_message.is_empty():
		_error_tables.erase(path)
	else:
		_error_tables[path] = error_message
	_update_table_item(path)


## Get table metadata for a given path.
func get_table_info(path: String) -> Dictionary:
	return _tables.get(path, {})


## Get all table paths.
func get_all_table_paths() -> Array:
	return _tables.keys()


## Select a table in the sidebar.
func select_table(path: String) -> void:
	var item = _find_tree_item_by_path(path)
	if item:
		item.select(0)


# ===== TABLE SCANNING =====
func _scan_data_folder() -> void:
	_tables.clear()
	_scan_directory(DATA_ROOT_PATH, "")


func _scan_directory(path: String, category: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path + file_name

		if dir.current_is_dir():
			# Skip hidden directories and special folders
			if not file_name.begins_with(".") and file_name != "_schemas" and file_name != "_meta":
				var sub_category = file_name if category.is_empty() else category
				_scan_directory(full_path + "/", sub_category)
		elif file_name.ends_with(".json"):
			var table_info = _parse_table_file(full_path)
			if not table_info.is_empty():
				table_info["category"] = category if not category.is_empty() else "root"
				_tables[full_path] = table_info

		file_name = dir.get_next()

	dir.list_dir_end()


func _parse_table_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		return {}

	# Check if it looks like a data table
	if data.has("rows") or data.has("schema"):
		var rows = data.get("rows", [])
		return {
			"schema": data.get("schema", ""),
			"row_count": rows.size() if rows is Array else 0,
			"display_name": path.get_file().get_basename()
		}

	return {}


# ===== TREE POPULATION =====
func _populate_tree() -> void:
	if not table_tree:
		return

	table_tree.clear()
	var root = table_tree.create_item()

	# Group tables by category
	var categories: Dictionary = {}
	for path in _tables:
		var info = _tables[path]
		var category = info.get("category", "root")

		# Apply search filter
		if not _search_filter.is_empty():
			var display_name = info.get("display_name", path.get_file().get_basename())
			if not display_name.to_lower().contains(_search_filter.to_lower()):
				if not category.to_lower().contains(_search_filter.to_lower()):
					continue

		if not categories.has(category):
			categories[category] = []
		categories[category].append(path)

	# Sort categories alphabetically
	var category_names = categories.keys()
	category_names.sort()

	# Move "root" to the end if it exists
	if "root" in category_names:
		category_names.erase("root")
		category_names.append("root")

	# Create tree structure
	for category in category_names:
		var category_item: TreeItem

		if category != "root":
			category_item = table_tree.create_item(root)
			category_item.set_text(0, _format_category_name(category))
			category_item.set_selectable(0, false)
			category_item.set_custom_color(0, Color(0.7, 0.8, 0.9))

			# Set category icon
			var icon_name = CATEGORY_ICONS.get(category.to_lower(), CATEGORY_ICONS["default"])
			var icon = _get_editor_icon(icon_name)
			if icon:
				category_item.set_icon(0, icon)
		else:
			category_item = root

		# Add tables in this category
		var paths = categories[category]
		paths.sort_custom(_sort_by_display_name)

		for path in paths:
			_create_table_item(category_item, path)


func _create_table_item(parent: TreeItem, path: String) -> TreeItem:
	var info = _tables[path]
	var item = table_tree.create_item(parent)

	var display_name = info.get("display_name", path.get_file().get_basename())
	var row_count = info.get("row_count", 0)

	# Build display text with indicators
	var text = "%s (%d)" % [display_name, row_count]

	# Add modified indicator
	if _modified_tables.has(path):
		text += " *"
		item.set_custom_color(0, Color(1.0, 0.9, 0.5))

	# Add error indicator
	if _error_tables.has(path):
		text = "! " + text
		item.set_custom_color(0, Color(1.0, 0.4, 0.4))
		item.set_tooltip_text(0, _error_tables[path])
	else:
		item.set_tooltip_text(0, path)

	item.set_text(0, text)
	item.set_metadata(0, path)

	# Set table icon (file icon)
	var icon = _get_editor_icon("File")
	if icon:
		item.set_icon(0, icon)

	return item


func _update_table_item(path: String) -> void:
	var item = _find_tree_item_by_path(path)
	if not item:
		return

	var info = _tables.get(path, {})
	var display_name = info.get("display_name", path.get_file().get_basename())
	var row_count = info.get("row_count", 0)

	var text = "%s (%d)" % [display_name, row_count]

	# Reset color
	item.set_custom_color(0, Color.WHITE)

	# Add modified indicator
	if _modified_tables.has(path):
		text += " *"
		item.set_custom_color(0, Color(1.0, 0.9, 0.5))

	# Add error indicator
	if _error_tables.has(path):
		text = "! " + text
		item.set_custom_color(0, Color(1.0, 0.4, 0.4))
		item.set_tooltip_text(0, _error_tables[path])
	else:
		item.set_tooltip_text(0, path)

	item.set_text(0, text)


func _find_tree_item_by_path(path: String) -> TreeItem:
	if not table_tree:
		return null

	var root = table_tree.get_root()
	if not root:
		return null

	return _find_item_recursive(root, path)


func _find_item_recursive(item: TreeItem, path: String) -> TreeItem:
	if item.get_metadata(0) == path:
		return item

	var child = item.get_first_child()
	while child:
		var found = _find_item_recursive(child, path)
		if found:
			return found
		child = child.get_next()

	return null


# ===== UTILITY FUNCTIONS =====
func _format_category_name(category: String) -> String:
	# Convert "items" to "Items", "loot_tables" to "Loot Tables"
	return category.replace("_", " ").capitalize()


func _sort_by_display_name(a: String, b: String) -> bool:
	var info_a = _tables.get(a, {})
	var info_b = _tables.get(b, {})
	var name_a = info_a.get("display_name", "").to_lower()
	var name_b = info_b.get("display_name", "").to_lower()
	return name_a < name_b


func _get_editor_icon(icon_name: String) -> Texture2D:
	if not Engine.is_editor_hint():
		return null

	var theme = EditorInterface.get_editor_theme()
	if theme:
		return theme.get_icon(icon_name, "EditorIcons")
	return null


# ===== SIGNAL HANDLERS =====
func _on_search_changed(new_text: String) -> void:
	_search_filter = new_text
	_populate_tree()


func _on_item_selected() -> void:
	var selected = table_tree.get_selected()
	if not selected:
		return

	var path = selected.get_metadata(0)
	if path and path is String and not path.is_empty():
		table_selected.emit(path)


func _on_item_mouse_selected(position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var selected = table_tree.get_selected()
		if selected and selected.get_metadata(0):
			_context_menu.position = get_screen_position() + position
			_context_menu.popup()


func _on_context_menu_selected(id: int) -> void:
	var selected = table_tree.get_selected()
	if not selected:
		return

	var path = selected.get_metadata(0)
	if not path or path.is_empty():
		return

	var action: String
	match id:
		0:  # Rename
			action = "rename"
		1:  # Duplicate
			action = "duplicate"
		2:  # Export CSV
			action = "export_csv"
		3:  # Export Markdown
			action = "export_markdown"
		4:  # Edit Schema
			action = "edit_schema"
		5:  # Delete
			action = "delete"

	if not action.is_empty():
		table_context_action.emit(action, path)


# ===== BUTTON HANDLERS =====
# These are connected from the scene
func _on_new_table_btn_pressed() -> void:
	new_table_requested.emit()


func _on_manage_schemas_btn_pressed() -> void:
	manage_schemas_requested.emit()
