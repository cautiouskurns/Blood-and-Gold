@tool
extends Tree
class_name RigTreeView
## Hierarchical tree view for displaying character rig structure.
## Shows body parts with their status and allows selection.

signal body_part_selected(part_name: String)
signal body_part_double_clicked(part_name: String)

var _body_parts: Dictionary = {}
var _root_item: TreeItem = null


func _ready() -> void:
	columns = 2
	set_column_title(0, "Body Part")
	set_column_title(1, "Status")
	set_column_expand(0, true)
	set_column_expand(1, false)
	set_column_custom_minimum_width(1, 100)
	hide_root = false
	allow_rmb_select = true

	# Larger font for readability
	add_theme_font_size_override("font_size", 28)

	item_selected.connect(_on_item_selected)
	item_activated.connect(_on_item_activated)


## Update the tree with current body parts data.
func update_tree(body_parts: Dictionary) -> void:
	_body_parts = body_parts
	clear()

	_root_item = create_item()
	_root_item.set_text(0, "Character")
	_root_item.set_selectable(0, false)
	_root_item.set_selectable(1, false)

	# Build tree starting from Torso (the root body part)
	# All other parts are children of Torso via the hierarchy
	_add_part_to_tree("Torso", _root_item)

	# Expand all by default
	_expand_all(_root_item)


func _add_part_to_tree(part_name: String, parent_item: TreeItem) -> void:
	var item := create_item(parent_item)
	item.set_text(0, part_name)
	item.set_metadata(0, part_name)

	# Set status based on body part state
	if part_name in _body_parts:
		var part: BodyPart = _body_parts[part_name]
		_update_item_status(item, part)
	else:
		# Not configured
		item.set_text(1, "---")
		item.set_custom_color(1, Color(0.5, 0.5, 0.5))

	# Add children based on default hierarchy
	var children := BodyPart.get_children(part_name)
	for child_name in children:
		_add_part_to_tree(child_name, item)


func _update_item_status(item: TreeItem, part: BodyPart) -> void:
	var shape_count := part.get_shape_count()

	if shape_count == 0:
		item.set_text(1, "empty")
		item.set_custom_color(1, Color(0.9, 0.3, 0.3))
	elif not part.pivot_set:
		item.set_text(1, "%d shapes" % shape_count)
		item.set_custom_color(1, Color(0.9, 0.7, 0.2))
		item.set_tooltip_text(1, "Pivot not set")
	else:
		item.set_text(1, "%d shapes" % shape_count)
		item.set_custom_color(1, Color(0.3, 0.8, 0.3))
		item.set_tooltip_text(1, "Complete")


func _expand_all(item: TreeItem) -> void:
	item.collapsed = false
	var child := item.get_first_child()
	while child:
		_expand_all(child)
		child = child.get_next()


func _on_item_selected() -> void:
	var selected := get_selected()
	if selected:
		var part_name = selected.get_metadata(0)
		if part_name:
			body_part_selected.emit(part_name)


func _on_item_activated() -> void:
	var selected := get_selected()
	if selected:
		var part_name = selected.get_metadata(0)
		if part_name:
			body_part_double_clicked.emit(part_name)


## Select a body part in the tree.
func select_part(part_name: String) -> void:
	var item := _find_item_by_name(_root_item, part_name)
	if item:
		item.select(0)


func _find_item_by_name(parent: TreeItem, part_name: String) -> TreeItem:
	if parent.get_metadata(0) == part_name:
		return parent

	var child := parent.get_first_child()
	while child:
		var found := _find_item_by_name(child, part_name)
		if found:
			return found
		child = child.get_next()

	return null


## Get the currently selected body part name.
func get_selected_part() -> String:
	var selected := get_selected()
	if selected:
		var part_name = selected.get_metadata(0)
		if part_name:
			return part_name
	return ""
