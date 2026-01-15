@tool
extends VBoxContainer
class_name ShapeLibraryPanel
## Shape Library panel for the Character Assembler.
## Allows saving, browsing, and inserting reusable shape groups.

signal group_insert_requested(shapes: Array)
signal save_selection_requested()

const ShapeGroupScript = preload("res://addons/character_assembler/scripts/shape_group.gd")

## Library paths
const BUILTIN_LIBRARY_PATH := "res://addons/character_assembler/resources/shape_library/"
const USER_LIBRARY_PATH := "user://character_assembler/shape_library/"

## Categories
const CATEGORIES := ["all", "body", "armor", "weapons", "accessories", "custom"]

## UI References
var _category_dropdown: OptionButton
var _search_field: LineEdit
var _group_list: ItemList
var _preview_panel: Control
var _preview_canvas: Control
var _group_name_label: Label
var _group_desc_label: Label
var _save_btn: Button
var _insert_btn: Button
var _delete_btn: Button
var _refresh_btn: Button

## State
var _groups: Array[ShapeGroup] = []
var _filtered_groups: Array[ShapeGroup] = []
var _selected_group: ShapeGroup = null
var _canvas_size: int = 64
var _has_selection: bool = false


func _ready() -> void:
	_ensure_directories()
	_setup_ui()
	_load_all_groups()
	_connect_signals()


func _ensure_directories() -> void:
	# Ensure user library directory exists
	var dir := DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("character_assembler"):
			dir.make_dir("character_assembler")
		if not dir.dir_exists("character_assembler/shape_library"):
			dir.make_dir("character_assembler/shape_library")


func _setup_ui() -> void:
	# Header
	var header := Label.new()
	header.text = "SHAPE LIBRARY"
	header.add_theme_font_size_override("font_size", 14)
	add_child(header)

	add_child(HSeparator.new())

	# Category filter
	var category_row := HBoxContainer.new()
	add_child(category_row)

	var cat_label := Label.new()
	cat_label.text = "Category:"
	category_row.add_child(cat_label)

	_category_dropdown = OptionButton.new()
	_category_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_category_dropdown.tooltip_text = "Filter groups by category"
	for cat in CATEGORIES:
		_category_dropdown.add_item(cat.capitalize())
	category_row.add_child(_category_dropdown)

	# Search field
	var search_row := HBoxContainer.new()
	add_child(search_row)

	var search_label := Label.new()
	search_label.text = "Search:"
	search_row.add_child(search_label)

	_search_field = LineEdit.new()
	_search_field.placeholder_text = "Filter groups..."
	_search_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_field.clear_button_enabled = true
	_search_field.tooltip_text = "Search groups by name, description, or tags"
	search_row.add_child(_search_field)

	# Group list
	_group_list = ItemList.new()
	_group_list.custom_minimum_size = Vector2(0, 120)
	_group_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_group_list.allow_reselect = true
	_group_list.select_mode = ItemList.SELECT_SINGLE
	_group_list.tooltip_text = "Click to select, double-click to insert"
	add_child(_group_list)

	# Preview panel
	_preview_panel = PanelContainer.new()
	_preview_panel.custom_minimum_size = Vector2(0, 80)
	add_child(_preview_panel)

	var preview_vbox := VBoxContainer.new()
	_preview_panel.add_child(preview_vbox)

	_group_name_label = Label.new()
	_group_name_label.text = "Select a group"
	_group_name_label.add_theme_font_size_override("font_size", 12)
	preview_vbox.add_child(_group_name_label)

	_group_desc_label = Label.new()
	_group_desc_label.text = ""
	_group_desc_label.add_theme_font_size_override("font_size", 10)
	_group_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_group_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	preview_vbox.add_child(_group_desc_label)

	# Preview canvas for shapes
	_preview_canvas = Control.new()
	_preview_canvas.custom_minimum_size = Vector2(0, 50)
	_preview_canvas.draw.connect(_on_preview_draw)
	preview_vbox.add_child(_preview_canvas)

	# Action buttons
	var btn_row1 := HBoxContainer.new()
	btn_row1.add_theme_constant_override("separation", 4)
	add_child(btn_row1)

	_save_btn = Button.new()
	_save_btn.text = "Save Selection"
	_save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_save_btn.tooltip_text = "Save selected shapes as a new group"
	btn_row1.add_child(_save_btn)

	_refresh_btn = Button.new()
	_refresh_btn.text = "Refresh"
	_refresh_btn.tooltip_text = "Reload library"
	btn_row1.add_child(_refresh_btn)

	var btn_row2 := HBoxContainer.new()
	btn_row2.add_theme_constant_override("separation", 4)
	add_child(btn_row2)

	_insert_btn = Button.new()
	_insert_btn.text = "Insert Group"
	_insert_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_insert_btn.disabled = true
	_insert_btn.tooltip_text = "Add selected group to canvas"
	btn_row2.add_child(_insert_btn)

	_delete_btn = Button.new()
	_delete_btn.text = "Delete"
	_delete_btn.disabled = true
	_delete_btn.tooltip_text = "Delete selected group"
	btn_row2.add_child(_delete_btn)


func _connect_signals() -> void:
	_category_dropdown.item_selected.connect(_on_category_changed)
	_search_field.text_changed.connect(_on_search_changed)
	_group_list.item_selected.connect(_on_group_selected)
	_group_list.item_activated.connect(_on_group_activated)
	_save_btn.pressed.connect(_on_save_pressed)
	_insert_btn.pressed.connect(_on_insert_pressed)
	_delete_btn.pressed.connect(_on_delete_pressed)
	_refresh_btn.pressed.connect(_on_refresh_pressed)


func _load_all_groups() -> void:
	_groups.clear()

	# Load built-in groups
	_load_groups_from_directory(BUILTIN_LIBRARY_PATH, true)

	# Load user groups
	_load_groups_from_directory(USER_LIBRARY_PATH, false)

	_apply_filter()


func _load_groups_from_directory(path: String, is_builtin: bool) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		# Directory doesn't exist, create built-in groups if this is the builtin path
		if is_builtin:
			_create_builtin_groups()
			dir = DirAccess.open(path)
			if not dir:
				return
		else:
			return

	# Check if directory is empty (for builtin path, generate groups if empty)
	if is_builtin:
		var has_files := false
		dir.list_dir_begin()
		var check_file := dir.get_next()
		while check_file != "":
			if check_file.ends_with(".tres") or check_file.ends_with(".res"):
				has_files = true
				break
			check_file = dir.get_next()
		dir.list_dir_end()

		if not has_files:
			_create_builtin_groups()

	# Now load all groups
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var full_path := path + file_name
			var group: ShapeGroup = load(full_path) as ShapeGroup
			if group:
				_groups.append(group)
		file_name = dir.get_next()

	dir.list_dir_end()


func _apply_filter() -> void:
	_filtered_groups.clear()

	var category_filter: String = CATEGORIES[_category_dropdown.selected] if _category_dropdown.selected >= 0 else "all"
	var search_text: String = _search_field.text.to_lower().strip_edges()

	for group in _groups:
		# Category filter
		if category_filter != "all" and group.category != category_filter:
			continue

		# Search filter
		if not search_text.is_empty():
			var matches := false
			if group.group_name.to_lower().contains(search_text):
				matches = true
			elif group.description.to_lower().contains(search_text):
				matches = true
			else:
				for tag in group.tags:
					if tag.to_lower().contains(search_text):
						matches = true
						break
			if not matches:
				continue

		_filtered_groups.append(group)

	_update_group_list()


func _update_group_list() -> void:
	_group_list.clear()
	_selected_group = null
	_insert_btn.disabled = true
	_delete_btn.disabled = true

	for group in _filtered_groups:
		var icon_name := _get_category_icon(group.category)
		var display_name := "%s (%d shapes)" % [group.group_name, group.shapes.size()]
		_group_list.add_item(display_name)

	_update_preview()


func _get_category_icon(category: String) -> String:
	match category:
		"body": return "Skeleton2D"
		"armor": return "CollisionShape2D"
		"weapons": return "Line2D"
		"accessories": return "Sprite2D"
		_: return "Node"


func _update_preview() -> void:
	if _selected_group:
		_group_name_label.text = _selected_group.group_name
		var desc := _selected_group.description if not _selected_group.description.is_empty() else "No description"
		desc += "\nCategory: %s | Shapes: %d" % [_selected_group.category.capitalize(), _selected_group.shapes.size()]
		_group_desc_label.text = desc
	else:
		_group_name_label.text = "Select a group"
		_group_desc_label.text = ""

	_preview_canvas.queue_redraw()


func _on_preview_draw() -> void:
	if not _selected_group or _selected_group.shapes.is_empty():
		return

	var panel_size := _preview_canvas.size
	var bounds := _selected_group.get_bounds()

	if bounds.size.x <= 0 or bounds.size.y <= 0:
		return

	# Calculate scale to fit preview
	var scale: float = minf(panel_size.x / bounds.size.x, panel_size.y / bounds.size.y) * 0.8
	var offset := (panel_size - bounds.size * scale) / 2.0 - bounds.position * scale

	# Draw shapes
	for shape in _selected_group.shapes:
		var pos := Vector2(shape.position[0], shape.position[1]) * scale + offset
		var shape_size := Vector2(shape.size[0], shape.size[1]) * scale
		var color := Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])

		match shape.type:
			"rectangle":
				_preview_canvas.draw_rect(Rect2(pos, shape_size), color)
			"circle":
				var radius: float = minf(shape_size.x, shape_size.y) / 2.0
				var center := pos + shape_size / 2.0
				_preview_canvas.draw_circle(center, radius, color)
			"ellipse":
				var center := pos + shape_size / 2.0
				_draw_ellipse(center, shape_size / 2.0, color)
			"triangle":
				var points := PackedVector2Array([
					Vector2(pos.x + shape_size.x / 2.0, pos.y),
					Vector2(pos.x + shape_size.x, pos.y + shape_size.y),
					Vector2(pos.x, pos.y + shape_size.y)
				])
				_preview_canvas.draw_colored_polygon(points, color)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var segments := 32

	for i in range(segments + 1):
		var angle: float = TAU * i / segments
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))

	_preview_canvas.draw_colored_polygon(points, color)


# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_category_changed(_index: int) -> void:
	_apply_filter()


func _on_search_changed(_text: String) -> void:
	_apply_filter()


func _on_group_selected(index: int) -> void:
	if index >= 0 and index < _filtered_groups.size():
		_selected_group = _filtered_groups[index]
		_insert_btn.disabled = false
		# Only allow deletion of custom groups (not built-in)
		_delete_btn.disabled = _selected_group.category != "custom"
	else:
		_selected_group = null
		_insert_btn.disabled = true
		_delete_btn.disabled = true

	_update_preview()


func _on_group_activated(index: int) -> void:
	# Double-click to insert
	_on_group_selected(index)
	if _selected_group:
		_on_insert_pressed()


func _on_save_pressed() -> void:
	save_selection_requested.emit()


func _on_insert_pressed() -> void:
	if _selected_group:
		var shapes := _selected_group.get_shapes_for_canvas(_canvas_size)
		group_insert_requested.emit(shapes)


func _on_delete_pressed() -> void:
	if not _selected_group:
		return

	# Only delete custom groups
	if _selected_group.category != "custom":
		return

	# Find and delete the file
	var deleted := false
	var dir := DirAccess.open(USER_LIBRARY_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var full_path := USER_LIBRARY_PATH + file_name
				var group: ShapeGroup = load(full_path) as ShapeGroup
				if group and group.group_name == _selected_group.group_name:
					dir.remove(file_name)
					deleted = true
					break
			file_name = dir.get_next()
		dir.list_dir_end()

	if deleted:
		_load_all_groups()


func _on_refresh_pressed() -> void:
	_load_all_groups()


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the current canvas size (used for scaling when inserting).
func set_canvas_size(size: int) -> void:
	_canvas_size = size


## Set whether there are shapes selected on the canvas.
func set_has_selection(has_selection: bool) -> void:
	_has_selection = has_selection
	if _save_btn:
		_save_btn.disabled = not has_selection


## Save selected shapes as a new group.
func save_shapes_as_group(shapes: Array, canvas_size: int) -> void:
	if shapes.is_empty():
		return

	# Show save dialog
	var dialog := _create_save_dialog()
	add_child(dialog)
	dialog.popup_centered()

	# Wait for dialog result
	var result: Dictionary = await dialog.confirmed_with_data
	dialog.queue_free()

	if result.is_empty():
		return

	# Create the group
	var group := ShapeGroupScript.from_shapes(shapes, result.name, result.category, canvas_size)
	group.description = result.description
	group.tags = PackedStringArray(result.tags.split(",", false))

	# Save to user library
	var file_name: String = result.name.to_snake_case() + ".tres"
	var save_path: String = USER_LIBRARY_PATH + file_name
	var err: Error = group.save_to_file(save_path)

	if err == OK:
		print("ShapeLibrary: Saved group '%s' to %s" % [result.name, save_path])
		_load_all_groups()
	else:
		push_error("ShapeLibrary: Failed to save group: %s" % error_string(err))


func _create_save_dialog() -> ConfirmationDialog:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Save Shape Group"
	dialog.size = Vector2(300, 200)

	var vbox := VBoxContainer.new()
	dialog.add_child(vbox)

	# Name field
	var name_row := HBoxContainer.new()
	vbox.add_child(name_row)
	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size.x = 80
	name_row.add_child(name_label)
	var name_edit := LineEdit.new()
	name_edit.name = "NameEdit"
	name_edit.placeholder_text = "Group name"
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_edit)

	# Category dropdown
	var cat_row := HBoxContainer.new()
	vbox.add_child(cat_row)
	var cat_label := Label.new()
	cat_label.text = "Category:"
	cat_label.custom_minimum_size.x = 80
	cat_row.add_child(cat_label)
	var cat_dropdown := OptionButton.new()
	cat_dropdown.name = "CategoryDropdown"
	cat_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for cat in ["body", "armor", "weapons", "accessories", "custom"]:
		cat_dropdown.add_item(cat.capitalize())
	cat_dropdown.select(4)  # Default to custom
	cat_row.add_child(cat_dropdown)

	# Description field
	var desc_label := Label.new()
	desc_label.text = "Description:"
	vbox.add_child(desc_label)
	var desc_edit := TextEdit.new()
	desc_edit.name = "DescEdit"
	desc_edit.custom_minimum_size = Vector2(0, 60)
	desc_edit.placeholder_text = "Optional description..."
	vbox.add_child(desc_edit)

	# Tags field
	var tags_row := HBoxContainer.new()
	vbox.add_child(tags_row)
	var tags_label := Label.new()
	tags_label.text = "Tags:"
	tags_label.custom_minimum_size.x = 80
	tags_row.add_child(tags_label)
	var tags_edit := LineEdit.new()
	tags_edit.name = "TagsEdit"
	tags_edit.placeholder_text = "tag1, tag2, ..."
	tags_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tags_row.add_child(tags_edit)

	# Custom signal for returning data
	dialog.set_meta("result", {})

	dialog.confirmed.connect(func():
		var result := {
			"name": name_edit.text.strip_edges(),
			"category": ["body", "armor", "weapons", "accessories", "custom"][cat_dropdown.selected],
			"description": desc_edit.text.strip_edges(),
			"tags": tags_edit.text.strip_edges()
		}
		if result.name.is_empty():
			result.name = "Unnamed Group"
		dialog.set_meta("result", result)
	)

	# Create a custom signal using a helper
	var signal_helper := RefCounted.new()
	signal_helper.set_meta("dialog", dialog)

	dialog.visibility_changed.connect(func():
		if not dialog.visible:
			var result: Dictionary = dialog.get_meta("result", {})
			dialog.set_meta("confirmed_result", result)
	)

	# Add signal
	dialog.add_user_signal("confirmed_with_data", [{"name": "data", "type": TYPE_DICTIONARY}])

	dialog.confirmed.connect(func():
		await dialog.get_tree().process_frame
		var result: Dictionary = dialog.get_meta("result", {})
		dialog.emit_signal("confirmed_with_data", result)
	)

	dialog.canceled.connect(func():
		dialog.emit_signal("confirmed_with_data", {})
	)

	return dialog


## Refresh the library.
func refresh() -> void:
	_load_all_groups()


# =============================================================================
# BUILT-IN GROUPS
# =============================================================================

func _create_builtin_groups() -> void:
	# Ensure directory exists
	var dir := DirAccess.open("res://addons/character_assembler/resources/")
	if dir:
		if not dir.dir_exists("shape_library"):
			dir.make_dir("shape_library")

	# Create humanoid base
	_create_humanoid_base_group()

	# Create weapon groups
	_create_sword_group()
	_create_shield_group()
	_create_bow_group()

	# Create armor groups
	_create_plate_armor_group()
	_create_leather_armor_group()


func _create_humanoid_base_group() -> void:
	var group := ShapeGroup.new("Humanoid Base", "body")
	group.description = "Basic humanoid body structure with 14 body parts"
	group.tags = PackedStringArray(["humanoid", "base", "character", "body"])
	group.source_canvas_size = 64

	# Head
	group.shapes.append({
		"type": "circle",
		"position": [24.0, 4.0],
		"size": [16.0, 16.0],
		"color": [0.9, 0.75, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 10
	})

	# Torso
	group.shapes.append({
		"type": "rectangle",
		"position": [22.0, 20.0],
		"size": [20.0, 20.0],
		"color": [0.3, 0.4, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 5
	})

	# Left Arm Upper
	group.shapes.append({
		"type": "rectangle",
		"position": [10.0, 20.0],
		"size": [12.0, 6.0],
		"color": [0.9, 0.75, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 4
	})

	# Left Arm Lower
	group.shapes.append({
		"type": "rectangle",
		"position": [4.0, 26.0],
		"size": [10.0, 5.0],
		"color": [0.9, 0.75, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 3
	})

	# Right Arm Upper
	group.shapes.append({
		"type": "rectangle",
		"position": [42.0, 20.0],
		"size": [12.0, 6.0],
		"color": [0.9, 0.75, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 4
	})

	# Right Arm Lower
	group.shapes.append({
		"type": "rectangle",
		"position": [50.0, 26.0],
		"size": [10.0, 5.0],
		"color": [0.9, 0.75, 0.6, 1.0],
		"rotation": 0.0,
		"layer": 3
	})

	# Left Leg Upper
	group.shapes.append({
		"type": "rectangle",
		"position": [22.0, 40.0],
		"size": [8.0, 12.0],
		"color": [0.25, 0.2, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 2
	})

	# Left Leg Lower
	group.shapes.append({
		"type": "rectangle",
		"position": [22.0, 52.0],
		"size": [8.0, 10.0],
		"color": [0.25, 0.2, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 1
	})

	# Right Leg Upper
	group.shapes.append({
		"type": "rectangle",
		"position": [34.0, 40.0],
		"size": [8.0, 12.0],
		"color": [0.25, 0.2, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 2
	})

	# Right Leg Lower
	group.shapes.append({
		"type": "rectangle",
		"position": [34.0, 52.0],
		"size": [8.0, 10.0],
		"color": [0.25, 0.2, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 1
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "humanoid_base.tres")


func _create_sword_group() -> void:
	var group := ShapeGroup.new("Sword", "weapons")
	group.description = "Basic sword weapon"
	group.tags = PackedStringArray(["weapon", "sword", "melee"])
	group.source_canvas_size = 64

	# Blade
	group.shapes.append({
		"type": "rectangle",
		"position": [28.0, 8.0],
		"size": [8.0, 28.0],
		"color": [0.75, 0.75, 0.8, 1.0],
		"rotation": 0.0,
		"layer": 8
	})

	# Guard
	group.shapes.append({
		"type": "rectangle",
		"position": [22.0, 36.0],
		"size": [20.0, 4.0],
		"color": [0.4, 0.35, 0.25, 1.0],
		"rotation": 0.0,
		"layer": 9
	})

	# Handle
	group.shapes.append({
		"type": "rectangle",
		"position": [29.0, 40.0],
		"size": [6.0, 12.0],
		"color": [0.35, 0.25, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 7
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "sword.tres")


func _create_shield_group() -> void:
	var group := ShapeGroup.new("Shield", "weapons")
	group.description = "Basic round shield"
	group.tags = PackedStringArray(["weapon", "shield", "defense"])
	group.source_canvas_size = 64

	# Shield body
	group.shapes.append({
		"type": "circle",
		"position": [16.0, 16.0],
		"size": [32.0, 32.0],
		"color": [0.5, 0.35, 0.2, 1.0],
		"rotation": 0.0,
		"layer": 6
	})

	# Shield boss (center)
	group.shapes.append({
		"type": "circle",
		"position": [26.0, 26.0],
		"size": [12.0, 12.0],
		"color": [0.6, 0.55, 0.45, 1.0],
		"rotation": 0.0,
		"layer": 7
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "shield.tres")


func _create_bow_group() -> void:
	var group := ShapeGroup.new("Bow", "weapons")
	group.description = "Basic bow weapon"
	group.tags = PackedStringArray(["weapon", "bow", "ranged"])
	group.source_canvas_size = 64

	# Bow body (using ellipse for curve effect)
	group.shapes.append({
		"type": "ellipse",
		"position": [26.0, 8.0],
		"size": [12.0, 48.0],
		"color": [0.45, 0.3, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 6
	})

	# Bowstring
	group.shapes.append({
		"type": "rectangle",
		"position": [30.0, 10.0],
		"size": [2.0, 44.0],
		"color": [0.8, 0.75, 0.65, 1.0],
		"rotation": 0.0,
		"layer": 5
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "bow.tres")


func _create_plate_armor_group() -> void:
	var group := ShapeGroup.new("Plate Armor", "armor")
	group.description = "Heavy plate armor set"
	group.tags = PackedStringArray(["armor", "plate", "heavy", "metal"])
	group.source_canvas_size = 64

	# Chest plate
	group.shapes.append({
		"type": "rectangle",
		"position": [20.0, 18.0],
		"size": [24.0, 24.0],
		"color": [0.5, 0.5, 0.55, 1.0],
		"rotation": 0.0,
		"layer": 6
	})

	# Left shoulder
	group.shapes.append({
		"type": "rectangle",
		"position": [8.0, 16.0],
		"size": [14.0, 10.0],
		"color": [0.5, 0.5, 0.55, 1.0],
		"rotation": 0.0,
		"layer": 7
	})

	# Right shoulder
	group.shapes.append({
		"type": "rectangle",
		"position": [42.0, 16.0],
		"size": [14.0, 10.0],
		"color": [0.5, 0.5, 0.55, 1.0],
		"rotation": 0.0,
		"layer": 7
	})

	# Helmet
	group.shapes.append({
		"type": "circle",
		"position": [22.0, 2.0],
		"size": [20.0, 18.0],
		"color": [0.5, 0.5, 0.55, 1.0],
		"rotation": 0.0,
		"layer": 11
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "plate_armor.tres")


func _create_leather_armor_group() -> void:
	var group := ShapeGroup.new("Leather Armor", "armor")
	group.description = "Light leather armor set"
	group.tags = PackedStringArray(["armor", "leather", "light"])
	group.source_canvas_size = 64

	# Chest piece
	group.shapes.append({
		"type": "rectangle",
		"position": [21.0, 19.0],
		"size": [22.0, 22.0],
		"color": [0.45, 0.3, 0.2, 1.0],
		"rotation": 0.0,
		"layer": 6
	})

	# Belt
	group.shapes.append({
		"type": "rectangle",
		"position": [20.0, 38.0],
		"size": [24.0, 4.0],
		"color": [0.35, 0.25, 0.15, 1.0],
		"rotation": 0.0,
		"layer": 7
	})

	# Left bracer
	group.shapes.append({
		"type": "rectangle",
		"position": [4.0, 24.0],
		"size": [8.0, 6.0],
		"color": [0.45, 0.3, 0.2, 1.0],
		"rotation": 0.0,
		"layer": 4
	})

	# Right bracer
	group.shapes.append({
		"type": "rectangle",
		"position": [52.0, 24.0],
		"size": [8.0, 6.0],
		"color": [0.45, 0.3, 0.2, 1.0],
		"rotation": 0.0,
		"layer": 4
	})

	group.save_to_file(BUILTIN_LIBRARY_PATH + "leather_armor.tres")
