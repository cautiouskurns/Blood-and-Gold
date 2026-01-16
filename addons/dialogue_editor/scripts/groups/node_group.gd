@tool
class_name DialogueNodeGroup
extends Control
## Visual group for organizing dialogue nodes.
## Draws a colored box with a label that can contain multiple nodes.

signal group_changed()
signal title_edit_requested(group: DialogueNodeGroup)
signal move_started()
signal move_ended()
signal select_contents_requested(group: DialogueNodeGroup)
signal context_menu_requested(group: DialogueNodeGroup, global_position: Vector2)
signal delete_requested(group: DialogueNodeGroup)

# =============================================================================
# GROUP DATA
# =============================================================================

## Unique identifier for this group.
var group_id: String = ""

## Display name shown in the title bar.
var group_name: String = "Group":
	set(value):
		group_name = value
		_update_title_label()
		queue_redraw()

## Background color of the group.
var group_color: Color = Color(0.3, 0.5, 0.7, 0.3):
	set(value):
		group_color = value
		queue_redraw()

## Node IDs contained in this group (for reference/selection purposes).
var contained_node_ids: Array[String] = []

# =============================================================================
# VISUAL CONFIGURATION
# =============================================================================

const TITLE_HEIGHT := 28
const BORDER_WIDTH := 2
const CORNER_RADIUS := 8
const RESIZE_HANDLE_SIZE := 12
const MIN_SIZE := Vector2(100, 80)

# Colors
const TITLE_BG_DARKEN := 0.3
const BORDER_LIGHTEN := 0.2
const RESIZE_HANDLE_COLOR := Color(1, 1, 1, 0.5)

# =============================================================================
# UI STATE
# =============================================================================

var _title_label: Label
var _is_resizing: bool = false
var _resize_edge: int = 0  # Bitfield: 1=left, 2=right, 4=top, 8=bottom
var _is_dragging: bool = false
var _drag_start_position: Vector2
var _drag_start_mouse: Vector2
var _resize_start_size: Vector2
var _resize_start_position: Vector2
var _is_hovered: bool = false
var _is_selected: bool = false

# Edge constants for resize
const EDGE_LEFT := 1
const EDGE_RIGHT := 2
const EDGE_TOP := 4
const EDGE_BOTTOM := 8


func _init() -> void:
	# Set up the control
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = MIN_SIZE


func _ready() -> void:
	_setup_title_label()
	_update_title_label()


func _setup_title_label() -> void:
	_title_label = Label.new()
	_title_label.name = "TitleLabel"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.add_theme_font_size_override("font_size", 14)
	add_child(_title_label)

	# Position the label in the title bar area
	_title_label.position = Vector2(CORNER_RADIUS, 2)


func _update_title_label() -> void:
	if _title_label:
		_title_label.text = group_name
		_title_label.size = Vector2(size.x - CORNER_RADIUS * 2, TITLE_HEIGHT - 4)


# =============================================================================
# DRAWING
# =============================================================================

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)

	# Draw background (semi-transparent)
	var bg_color = group_color
	draw_rect(rect, bg_color, true)

	# Draw title bar background (darker)
	var title_rect = Rect2(Vector2.ZERO, Vector2(size.x, TITLE_HEIGHT))
	var title_color = group_color.darkened(TITLE_BG_DARKEN)
	title_color.a = min(title_color.a + 0.2, 0.9)
	draw_rect(title_rect, title_color, true)

	# Draw border
	var border_color = group_color.lightened(BORDER_LIGHTEN)
	border_color.a = 0.8
	var border_thickness = BORDER_WIDTH if not _is_selected else BORDER_WIDTH * 2
	draw_rect(rect, border_color, false, border_thickness)

	# Draw selection highlight
	if _is_selected:
		var highlight_color = Color.WHITE
		highlight_color.a = 0.3
		draw_rect(rect.grow(-2), highlight_color, false, 1)

	# Draw resize handles when hovered or selected
	if _is_hovered or _is_selected:
		_draw_resize_handles()


func _draw_resize_handles() -> void:
	var handle_color = RESIZE_HANDLE_COLOR
	var half_size = RESIZE_HANDLE_SIZE / 2.0

	# Corner handles
	var corners = [
		Vector2(0, 0),  # Top-left
		Vector2(size.x, 0),  # Top-right
		Vector2(0, size.y),  # Bottom-left
		Vector2(size.x, size.y)  # Bottom-right
	]

	for corner in corners:
		var handle_rect = Rect2(
			corner - Vector2(half_size, half_size),
			Vector2(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
		)
		draw_rect(handle_rect, handle_color, true)

	# Edge handles (midpoints)
	var edges = [
		Vector2(size.x / 2, 0),  # Top
		Vector2(size.x / 2, size.y),  # Bottom
		Vector2(0, size.y / 2),  # Left
		Vector2(size.x, size.y / 2)  # Right
	]

	for edge in edges:
		var handle_rect = Rect2(
			edge - Vector2(half_size, half_size),
			Vector2(RESIZE_HANDLE_SIZE, RESIZE_HANDLE_SIZE)
		)
		draw_rect(handle_rect, handle_color.darkened(0.2), true)


# =============================================================================
# INPUT HANDLING
# =============================================================================

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Check for double-click on title bar for editing
			if event.double_click and _is_in_title_bar(event.position):
				title_edit_requested.emit(self)
				accept_event()
				return

			# Check for resize handle
			var resize_edge = _get_resize_edge(event.position)
			if resize_edge != 0:
				_start_resize(event.position, resize_edge)
				accept_event()
				return

			# Check for drag (title bar or with Ctrl/Shift)
			if _is_in_title_bar(event.position) or event.ctrl_pressed:
				_start_drag(event.position)
				accept_event()
				return

			# Click on background - select all contained nodes
			select_contents_requested.emit(self)
			_is_selected = true
			queue_redraw()
			accept_event()
		else:
			# Mouse released
			if _is_resizing:
				_end_resize()
			elif _is_dragging:
				_end_drag()

	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			# Right-click context menu - use screen coordinates for popup
			var screen_pos = DisplayServer.mouse_get_position()
			context_menu_requested.emit(self, Vector2(screen_pos))
			accept_event()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _is_resizing:
		_update_resize(event.position)
		accept_event()
	elif _is_dragging:
		_update_drag(event.global_position)
		accept_event()
	else:
		# Update cursor based on position
		var resize_edge = _get_resize_edge(event.position)
		_update_cursor(resize_edge)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_is_hovered = true
			queue_redraw()
		NOTIFICATION_MOUSE_EXIT:
			_is_hovered = false
			mouse_default_cursor_shape = Control.CURSOR_ARROW
			queue_redraw()
		NOTIFICATION_RESIZED:
			_update_title_label()


func _is_in_title_bar(local_pos: Vector2) -> bool:
	return local_pos.y < TITLE_HEIGHT


func _get_resize_edge(local_pos: Vector2) -> int:
	var edge := 0
	var threshold = RESIZE_HANDLE_SIZE

	if local_pos.x < threshold:
		edge |= EDGE_LEFT
	elif local_pos.x > size.x - threshold:
		edge |= EDGE_RIGHT

	if local_pos.y < threshold:
		edge |= EDGE_TOP
	elif local_pos.y > size.y - threshold:
		edge |= EDGE_BOTTOM

	return edge


func _update_cursor(edge: int) -> void:
	if edge == 0:
		if _is_in_title_bar(get_local_mouse_position()):
			mouse_default_cursor_shape = Control.CURSOR_MOVE
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW
		return

	# Diagonal cursors
	if (edge & EDGE_LEFT and edge & EDGE_TOP) or (edge & EDGE_RIGHT and edge & EDGE_BOTTOM):
		mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	elif (edge & EDGE_RIGHT and edge & EDGE_TOP) or (edge & EDGE_LEFT and edge & EDGE_BOTTOM):
		mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
	# Horizontal/vertical cursors
	elif edge & EDGE_LEFT or edge & EDGE_RIGHT:
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif edge & EDGE_TOP or edge & EDGE_BOTTOM:
		mouse_default_cursor_shape = Control.CURSOR_VSIZE


# =============================================================================
# DRAG HANDLING
# =============================================================================

func _start_drag(local_pos: Vector2) -> void:
	_is_dragging = true
	_drag_start_position = position
	_drag_start_mouse = get_global_mouse_position()
	move_started.emit()


func _update_drag(global_mouse_pos: Vector2) -> void:
	var delta = global_mouse_pos - _drag_start_mouse
	position = _drag_start_position + delta
	group_changed.emit()


func _end_drag() -> void:
	_is_dragging = false
	move_ended.emit()
	group_changed.emit()


# =============================================================================
# RESIZE HANDLING
# =============================================================================

func _start_resize(local_pos: Vector2, edge: int) -> void:
	_is_resizing = true
	_resize_edge = edge
	_resize_start_size = size
	_resize_start_position = position
	_drag_start_mouse = get_global_mouse_position()


func _update_resize(local_pos: Vector2) -> void:
	var global_mouse = get_global_mouse_position()
	var delta = global_mouse - _drag_start_mouse

	var new_position = _resize_start_position
	var new_size = _resize_start_size

	# Handle horizontal resize
	if _resize_edge & EDGE_LEFT:
		new_position.x = _resize_start_position.x + delta.x
		new_size.x = _resize_start_size.x - delta.x
	elif _resize_edge & EDGE_RIGHT:
		new_size.x = _resize_start_size.x + delta.x

	# Handle vertical resize
	if _resize_edge & EDGE_TOP:
		new_position.y = _resize_start_position.y + delta.y
		new_size.y = _resize_start_size.y - delta.y
	elif _resize_edge & EDGE_BOTTOM:
		new_size.y = _resize_start_size.y + delta.y

	# Enforce minimum size
	if new_size.x < MIN_SIZE.x:
		if _resize_edge & EDGE_LEFT:
			new_position.x = _resize_start_position.x + _resize_start_size.x - MIN_SIZE.x
		new_size.x = MIN_SIZE.x

	if new_size.y < MIN_SIZE.y:
		if _resize_edge & EDGE_TOP:
			new_position.y = _resize_start_position.y + _resize_start_size.y - MIN_SIZE.y
		new_size.y = MIN_SIZE.y

	position = new_position
	size = new_size
	group_changed.emit()


func _end_resize() -> void:
	_is_resizing = false
	_resize_edge = 0
	group_changed.emit()


# =============================================================================
# PUBLIC API
# =============================================================================

## Check if a point (in parent coordinates) is inside this group.
func contains_point(point: Vector2) -> bool:
	var local_point = point - position
	return Rect2(Vector2.ZERO, size).has_point(local_point)


## Check if a node (by its position and size) is inside this group.
func contains_node(node_position: Vector2, node_size: Vector2) -> bool:
	var group_rect = Rect2(position, size)
	var node_rect = Rect2(node_position, node_size)
	return group_rect.encloses(node_rect)


## Get the bounding rect in parent coordinates.
func get_bounding_rect() -> Rect2:
	return Rect2(position, size)


## Set selection state.
func set_selected(selected: bool) -> void:
	if _is_selected != selected:
		_is_selected = selected
		queue_redraw()


## Check if group is selected.
func is_selected() -> bool:
	return _is_selected


## Serialize group data to dictionary.
func serialize() -> Dictionary:
	return {
		"group_id": group_id,
		"name": group_name,
		"color": {
			"r": group_color.r,
			"g": group_color.g,
			"b": group_color.b,
			"a": group_color.a
		},
		"position_x": position.x,
		"position_y": position.y,
		"size_x": size.x,
		"size_y": size.y,
		"contained_nodes": contained_node_ids.duplicate()
	}


## Deserialize group data from dictionary.
func deserialize(data: Dictionary) -> void:
	group_id = data.get("group_id", "")
	group_name = data.get("name", "Group")

	if data.has("color"):
		var c = data.color
		group_color = Color(c.get("r", 0.3), c.get("g", 0.5), c.get("b", 0.7), c.get("a", 0.3))

	position = Vector2(data.get("position_x", 0), data.get("position_y", 0))
	size = Vector2(data.get("size_x", 200), data.get("size_y", 150))

	contained_node_ids.clear()
	for node_id in data.get("contained_nodes", []):
		contained_node_ids.append(str(node_id))


## Update contained nodes list based on current positions.
func update_contained_nodes(nodes: Array) -> void:
	contained_node_ids.clear()
	var group_rect = Rect2(position, size)

	for node in nodes:
		if node is GraphNode:
			var node_rect = Rect2(node.position_offset, node.size)
			# Check if node center is inside group
			var node_center = node.position_offset + node.size / 2
			if group_rect.has_point(node_center):
				contained_node_ids.append(node.name)
