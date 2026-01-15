@tool
extends Control
class_name CharacterCanvas
## Canvas viewport for the Character Assembler.
## Handles shape drawing, selection, manipulation, and reference image display.

signal shape_added(index: int)
signal shape_removed(index: int)
signal shape_selected(indices: Array[int])
signal shape_modified(index: int)
signal canvas_changed()
signal zoom_changed(zoom: float)
signal pivot_clicked(canvas_pos: Vector2)

# Canvas settings
var canvas_size: int = 64:
	set(value):
		canvas_size = clampi(value, 16, 128)
		queue_redraw()

var grid_enabled: bool = true:
	set(value):
		grid_enabled = value
		queue_redraw()

var grid_size: int = 8
var snap_to_grid: bool = true

# Zoom settings
var zoom_level: float = 4.0:
	set(value):
		zoom_level = clampf(value, 1.0, 16.0)
		zoom_changed.emit(zoom_level)
		queue_redraw()

var pan_offset: Vector2 = Vector2.ZERO

# Reference image
var reference_texture: Texture2D = null
var reference_opacity: float = 0.5:
	set(value):
		reference_opacity = clampf(value, 0.0, 1.0)
		queue_redraw()

# Shape data (mirrors project data)
var shapes: Array = []
var selected_indices: Array[int] = []

# Current tool state
enum Tool { SELECT, RECTANGLE, CIRCLE, ELLIPSE, TRIANGLE }
var current_tool: Tool = Tool.SELECT
var current_color: Color = Color.WHITE

# Pivot mode (for setting body part pivot points)
var pivot_mode: bool = false
var pivot_points: Dictionary = {}  # part_name -> Vector2
var highlighted_part: String = ""  # Body part to highlight shapes for
var highlighted_shapes: Array[int] = []  # Shape indices to highlight

# Pose preview state
var _pose_preview_enabled: bool = false
var _pose_preview_shapes: Array = []  # Transformed shapes for pose preview
var _current_preview_pose: Pose = null
var _current_preview_body_parts: Dictionary = {}

# Interaction state
var _is_drawing: bool = false
var _is_dragging: bool = false
var _is_resizing: bool = false
var _is_rotating: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_offset: Vector2 = Vector2.ZERO
var _resize_handle: int = -1  # 0-7 for corners/edges, -1 for none
var _rotation_start: float = 0.0
var _drawing_start: Vector2 = Vector2.ZERO
var _drawing_end: Vector2 = Vector2.ZERO

# Visual settings
const GRID_COLOR := Color(0.3, 0.3, 0.3, 0.5)
const GRID_COLOR_MAJOR := Color(0.4, 0.4, 0.4, 0.7)
const SELECTION_COLOR := Color(0.2, 0.6, 1.0, 0.8)
const HANDLE_SIZE := 6.0
const HANDLE_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const HANDLE_BORDER := Color(0.0, 0.0, 0.0, 1.0)
const PIVOT_COLOR := Color(1.0, 0.3, 0.3, 1.0)
const PIVOT_SIZE := 8.0
const HIGHLIGHT_COLOR := Color(1.0, 0.8, 0.2, 0.6)
const POSE_PREVIEW_TINT := Color(0.9, 0.95, 1.0, 1.0)  # Slight blue tint for pose preview


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Ensure we can receive input
	set_process_input(true)
	focus_mode = Control.FOCUS_ALL


func _draw() -> void:
	var canvas_rect = _get_canvas_rect()

	# Background
	draw_rect(canvas_rect, Color(0.15, 0.15, 0.15, 1.0))

	# Reference image
	if reference_texture:
		var ref_rect = canvas_rect
		draw_texture_rect(reference_texture, ref_rect, false, Color(1, 1, 1, reference_opacity))

	# Grid
	if grid_enabled:
		_draw_grid(canvas_rect)

	# Highlighted shapes (for body part preview)
	if not highlighted_part.is_empty():
		_draw_highlighted_shapes(canvas_rect)

	# Shapes (sorted by layer) - use pose preview shapes if enabled
	if _pose_preview_enabled and not _pose_preview_shapes.is_empty():
		var sorted_preview = _get_sorted_preview_shapes()
		for shape_data in sorted_preview:
			_draw_shape(shape_data.shape, shape_data.index, canvas_rect, true)
	else:
		var sorted_shapes = _get_sorted_shapes()
		for shape_data in sorted_shapes:
			_draw_shape(shape_data.shape, shape_data.index, canvas_rect, false)

	# Drawing preview
	if _is_drawing:
		_draw_shape_preview(canvas_rect)

	# Selection handles
	if not selected_indices.is_empty() and current_tool == Tool.SELECT:
		_draw_selection_handles(canvas_rect)

	# Pivot points
	_draw_pivots(canvas_rect)

	# Pivot mode cursor indicator
	if pivot_mode:
		_draw_pivot_cursor(canvas_rect)

	# Canvas border
	draw_rect(canvas_rect, Color(0.5, 0.5, 0.5, 1.0), false, 2.0)


func _draw_grid(canvas_rect: Rect2) -> void:
	var pixel_size = canvas_rect.size.x / canvas_size
	var grid_pixel_size = grid_size * pixel_size

	# Minor grid lines
	for i in range(1, canvas_size / grid_size):
		var x = canvas_rect.position.x + i * grid_pixel_size
		var y = canvas_rect.position.y + i * grid_pixel_size
		draw_line(Vector2(x, canvas_rect.position.y), Vector2(x, canvas_rect.end.y), GRID_COLOR)
		draw_line(Vector2(canvas_rect.position.x, y), Vector2(canvas_rect.end.x, y), GRID_COLOR)

	# Major grid lines (every 16 pixels)
	var major_grid = 16
	for i in range(1, canvas_size / major_grid):
		var x = canvas_rect.position.x + i * major_grid * pixel_size
		var y = canvas_rect.position.y + i * major_grid * pixel_size
		if int(i * major_grid) % grid_size == 0:
			draw_line(Vector2(x, canvas_rect.position.y), Vector2(x, canvas_rect.end.y), GRID_COLOR_MAJOR)
			draw_line(Vector2(canvas_rect.position.x, y), Vector2(canvas_rect.end.x, y), GRID_COLOR_MAJOR)


func _draw_shape(shape: Dictionary, index: int, canvas_rect: Rect2, is_pose_preview: bool = false) -> void:
	var pos = _canvas_to_screen(Vector2(shape.position[0], shape.position[1]), canvas_rect)
	var shape_size = Vector2(shape.size[0], shape.size[1]) * (canvas_rect.size.x / canvas_size)
	var color = Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])
	var rotation = shape.get("rotation", 0.0)

	# Apply pose preview tint if in preview mode
	if is_pose_preview:
		color = color * POSE_PREVIEW_TINT

	var is_selected = index in selected_indices and not is_pose_preview

	match shape.type:
		"rectangle":
			_draw_rotated_rect(pos, shape_size, rotation, color, is_selected)
		"circle":
			_draw_circle_shape(pos, shape_size, color, is_selected)
		"ellipse":
			_draw_ellipse_shape(pos, shape_size, rotation, color, is_selected)
		"triangle":
			_draw_triangle_shape(pos, shape_size, rotation, color, is_selected)


func _draw_rotated_rect(pos: Vector2, shape_size: Vector2, rotation: float, color: Color, is_selected: bool) -> void:
	var center = pos + shape_size / 2
	var half_size = shape_size / 2

	var points: PackedVector2Array = []
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var point = corner * half_size
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)

	if is_selected:
		draw_polyline(points + PackedVector2Array([points[0]]), SELECTION_COLOR, 2.0)


func _draw_circle_shape(pos: Vector2, shape_size: Vector2, color: Color, is_selected: bool) -> void:
	var center = pos + shape_size / 2
	var radius = min(shape_size.x, shape_size.y) / 2

	draw_circle(center, radius, color)

	if is_selected:
		draw_arc(center, radius, 0, TAU, 32, SELECTION_COLOR, 2.0)


func _draw_ellipse_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color, is_selected: bool) -> void:
	var center = pos + shape_size / 2
	var points: PackedVector2Array = []

	for i in range(32):
		var angle = i * TAU / 32
		var point = Vector2(cos(angle) * shape_size.x / 2, sin(angle) * shape_size.y / 2)
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)

	if is_selected:
		draw_polyline(points + PackedVector2Array([points[0]]), SELECTION_COLOR, 2.0)


func _draw_triangle_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color, is_selected: bool) -> void:
	var center = pos + shape_size / 2
	var points: PackedVector2Array = []

	# Equilateral triangle pointing up
	var tri_points = [
		Vector2(0, -shape_size.y / 2),  # Top
		Vector2(-shape_size.x / 2, shape_size.y / 2),  # Bottom left
		Vector2(shape_size.x / 2, shape_size.y / 2),  # Bottom right
	]

	for point in tri_points:
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)

	if is_selected:
		draw_polyline(points + PackedVector2Array([points[0]]), SELECTION_COLOR, 2.0)


func _draw_shape_preview(canvas_rect: Rect2) -> void:
	var start = _canvas_to_screen(_drawing_start, canvas_rect)
	var end = _canvas_to_screen(_drawing_end, canvas_rect)
	var preview_size = end - start
	var preview_color = Color(current_color, 0.5)

	match current_tool:
		Tool.RECTANGLE:
			draw_rect(Rect2(start, preview_size), preview_color)
			draw_rect(Rect2(start, preview_size), SELECTION_COLOR, false, 1.0)
		Tool.CIRCLE:
			var center = start + preview_size / 2
			var radius = min(abs(preview_size.x), abs(preview_size.y)) / 2
			draw_circle(center, radius, preview_color)
			draw_arc(center, radius, 0, TAU, 32, SELECTION_COLOR, 1.0)
		Tool.ELLIPSE:
			var center = start + preview_size / 2
			var points: PackedVector2Array = []
			for i in range(32):
				var angle = i * TAU / 32
				var point = Vector2(cos(angle) * preview_size.x / 2, sin(angle) * preview_size.y / 2)
				points.append(center + point)
			draw_colored_polygon(points, preview_color)
			draw_polyline(points + PackedVector2Array([points[0]]), SELECTION_COLOR, 1.0)
		Tool.TRIANGLE:
			var center = start + preview_size / 2
			var points: PackedVector2Array = [
				center + Vector2(0, -preview_size.y / 2),
				center + Vector2(-preview_size.x / 2, preview_size.y / 2),
				center + Vector2(preview_size.x / 2, preview_size.y / 2),
			]
			draw_colored_polygon(points, preview_color)
			draw_polyline(points + PackedVector2Array([points[0]]), SELECTION_COLOR, 1.0)


func _draw_selection_handles(canvas_rect: Rect2) -> void:
	var bounds = _get_selection_bounds()
	if bounds.size == Vector2.ZERO:
		return

	var screen_pos = _canvas_to_screen(bounds.position, canvas_rect)
	var screen_size = bounds.size * (canvas_rect.size.x / canvas_size)
	var screen_bounds = Rect2(screen_pos, screen_size)

	# Draw bounding box
	draw_rect(screen_bounds, SELECTION_COLOR, false, 1.0)

	# Draw handles at corners and edges
	var handles = _get_handle_positions(screen_bounds)
	for handle_pos in handles:
		draw_rect(Rect2(handle_pos - Vector2(HANDLE_SIZE/2, HANDLE_SIZE/2), Vector2(HANDLE_SIZE, HANDLE_SIZE)), HANDLE_COLOR)
		draw_rect(Rect2(handle_pos - Vector2(HANDLE_SIZE/2, HANDLE_SIZE/2), Vector2(HANDLE_SIZE, HANDLE_SIZE)), HANDLE_BORDER, false, 1.0)


func _get_handle_positions(bounds: Rect2) -> Array[Vector2]:
	return [
		bounds.position,  # Top-left
		Vector2(bounds.position.x + bounds.size.x / 2, bounds.position.y),  # Top-center
		Vector2(bounds.end.x, bounds.position.y),  # Top-right
		Vector2(bounds.end.x, bounds.position.y + bounds.size.y / 2),  # Right-center
		bounds.end,  # Bottom-right
		Vector2(bounds.position.x + bounds.size.x / 2, bounds.end.y),  # Bottom-center
		Vector2(bounds.position.x, bounds.end.y),  # Bottom-left
		Vector2(bounds.position.x, bounds.position.y + bounds.size.y / 2),  # Left-center
	]


func _draw_pivots(canvas_rect: Rect2) -> void:
	for part_name in pivot_points:
		var pivot_pos: Vector2 = pivot_points[part_name]
		var screen_pos = _canvas_to_screen(pivot_pos, canvas_rect)

		# Draw crosshair
		var half = PIVOT_SIZE / 2
		draw_line(screen_pos - Vector2(half, 0), screen_pos + Vector2(half, 0), PIVOT_COLOR, 2.0)
		draw_line(screen_pos - Vector2(0, half), screen_pos + Vector2(0, half), PIVOT_COLOR, 2.0)

		# Draw circle
		draw_arc(screen_pos, PIVOT_SIZE / 2, 0, TAU, 16, PIVOT_COLOR, 2.0)

		# Draw label with background for readability
		var font = ThemeDB.fallback_font
		var font_size = 18
		var label_pos = screen_pos + Vector2(PIVOT_SIZE + 4, 6)
		# Draw text shadow/outline for better visibility
		draw_string(font, label_pos + Vector2(1, 1), part_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
		draw_string(font, label_pos + Vector2(-1, -1), part_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
		draw_string(font, label_pos + Vector2(1, -1), part_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
		draw_string(font, label_pos + Vector2(-1, 1), part_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
		# Main text
		draw_string(font, label_pos, part_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, PIVOT_COLOR)


func _draw_pivot_cursor(canvas_rect: Rect2) -> void:
	# Draw a hint that we're in pivot mode
	var hint_pos = Vector2(canvas_rect.position.x + 10, canvas_rect.position.y + 20)
	var font = ThemeDB.fallback_font
	draw_string(font, hint_pos, "Click to set pivot", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, PIVOT_COLOR)


func _draw_highlighted_shapes(canvas_rect: Rect2) -> void:
	if highlighted_shapes.is_empty():
		return

	for index in highlighted_shapes:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			var pos = _canvas_to_screen(Vector2(shape.position[0], shape.position[1]), canvas_rect)
			var shape_size = Vector2(shape.size[0], shape.size[1]) * (canvas_rect.size.x / canvas_size)

			# Draw highlight overlay
			var highlight_rect = Rect2(pos, shape_size)
			draw_rect(highlight_rect, HIGHLIGHT_COLOR)
			draw_rect(highlight_rect, Color(1.0, 0.8, 0.2, 1.0), false, 2.0)


func _gui_input(event: InputEvent) -> void:
	var canvas_rect = _get_canvas_rect()

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("CharacterCanvas: Mouse click at ", event.position, " tool=", Tool.keys()[current_tool])
		_handle_mouse_button(event, canvas_rect)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event, canvas_rect)

	queue_redraw()


func _handle_mouse_button(event: InputEventMouseButton, canvas_rect: Rect2) -> void:
	var canvas_pos = _screen_to_canvas(event.position, canvas_rect)

	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Pivot mode takes priority
			if pivot_mode:
				var snapped_pos = _snap_position(canvas_pos)
				pivot_clicked.emit(snapped_pos)
				return

			if current_tool == Tool.SELECT:
				_start_selection(event.position, canvas_pos, event.shift_pressed, canvas_rect)
			else:
				_start_drawing(canvas_pos)
		else:
			if _is_drawing:
				_finish_drawing(canvas_pos)
			elif _is_dragging:
				_finish_dragging()
			elif _is_resizing:
				_finish_resizing()

	elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		zoom_level = min(zoom_level * 1.2, 16.0)

	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		zoom_level = max(zoom_level / 1.2, 1.0)

	elif event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_drag_start = event.position
		else:
			_drag_start = Vector2.ZERO


func _handle_mouse_motion(event: InputEventMouseMotion, canvas_rect: Rect2) -> void:
	var canvas_pos = _screen_to_canvas(event.position, canvas_rect)

	if _is_drawing:
		_drawing_end = _snap_position(canvas_pos)
	elif _is_dragging:
		_update_dragging(canvas_pos)
	elif _is_resizing:
		_update_resizing(canvas_pos)
	elif event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
		pan_offset += event.relative


func _start_selection(screen_pos: Vector2, canvas_pos: Vector2, add_to_selection: bool, canvas_rect: Rect2) -> void:
	# Check if clicking on a resize handle first
	if not selected_indices.is_empty():
		var bounds = _get_selection_bounds()
		var screen_bounds_pos = _canvas_to_screen(bounds.position, canvas_rect)
		var screen_bounds_size = bounds.size * (canvas_rect.size.x / canvas_size)
		var screen_bounds = Rect2(screen_bounds_pos, screen_bounds_size)

		var handles = _get_handle_positions(screen_bounds)
		for i in range(handles.size()):
			if screen_pos.distance_to(handles[i]) < HANDLE_SIZE:
				_resize_handle = i
				_is_resizing = true
				_drag_start = canvas_pos
				return

	# Check if clicking on a shape
	var clicked_index = _get_shape_at_position(canvas_pos)

	if clicked_index >= 0:
		if add_to_selection:
			if clicked_index in selected_indices:
				selected_indices.erase(clicked_index)
			else:
				selected_indices.append(clicked_index)
		else:
			if clicked_index not in selected_indices:
				selected_indices = [clicked_index]
			# Start dragging
			_is_dragging = true
			_drag_start = canvas_pos
			_drag_offset = Vector2.ZERO

		shape_selected.emit(selected_indices)
	else:
		if not add_to_selection:
			selected_indices.clear()
			shape_selected.emit(selected_indices)


func _start_drawing(canvas_pos: Vector2) -> void:
	_is_drawing = true
	_drawing_start = _snap_position(canvas_pos)
	_drawing_end = _drawing_start


func _finish_drawing(canvas_pos: Vector2) -> void:
	_is_drawing = false
	_drawing_end = _snap_position(canvas_pos)

	var start = Vector2(min(_drawing_start.x, _drawing_end.x), min(_drawing_start.y, _drawing_end.y))
	var end = Vector2(max(_drawing_start.x, _drawing_end.x), max(_drawing_start.y, _drawing_end.y))
	var shape_size = end - start

	# Minimum size check
	if shape_size.x < 2 or shape_size.y < 2:
		return

	var tool_type = ""
	match current_tool:
		Tool.RECTANGLE: tool_type = "rectangle"
		Tool.CIRCLE: tool_type = "circle"
		Tool.ELLIPSE: tool_type = "ellipse"
		Tool.TRIANGLE: tool_type = "triangle"

	if not tool_type.is_empty():
		var shape = {
			"type": tool_type,
			"position": [start.x, start.y],
			"size": [shape_size.x, shape_size.y],
			"color": [current_color.r, current_color.g, current_color.b, current_color.a],
			"rotation": 0.0,
			"layer": shapes.size()
		}
		shapes.append(shape)
		var index = shapes.size() - 1
		shape_added.emit(index)
		canvas_changed.emit()

		# Select the new shape
		selected_indices = [index]
		shape_selected.emit(selected_indices)


func _update_dragging(canvas_pos: Vector2) -> void:
	var snapped_pos = _snap_position(canvas_pos)
	var snapped_start = _snap_position(_drag_start)
	var delta = snapped_pos - snapped_start

	# Only move if there's actual movement
	if delta == Vector2.ZERO:
		return

	for index in selected_indices:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			var old_pos = Vector2(shape.position[0], shape.position[1])
			var new_pos = old_pos + delta
			shape.position = [new_pos.x, new_pos.y]

	_drag_start = canvas_pos
	canvas_changed.emit()


func _finish_dragging() -> void:
	_is_dragging = false
	for index in selected_indices:
		shape_modified.emit(index)


func _update_resizing(canvas_pos: Vector2) -> void:
	var snapped_pos = _snap_position(canvas_pos)
	var bounds = _get_selection_bounds()

	# Calculate new bounds based on which handle is being dragged
	var new_bounds = bounds
	match _resize_handle:
		0:  # Top-left
			new_bounds.position = snapped_pos
			new_bounds.size = bounds.end - snapped_pos
		2:  # Top-right
			new_bounds.position.y = snapped_pos.y
			new_bounds.size.x = snapped_pos.x - bounds.position.x
			new_bounds.size.y = bounds.end.y - snapped_pos.y
		4:  # Bottom-right
			new_bounds.size = snapped_pos - bounds.position
		6:  # Bottom-left
			new_bounds.position.x = snapped_pos.x
			new_bounds.size.x = bounds.end.x - snapped_pos.x
			new_bounds.size.y = snapped_pos.y - bounds.position.y

	# Apply scaling to selected shapes
	if new_bounds.size.x > 0 and new_bounds.size.y > 0:
		var scale_x = new_bounds.size.x / bounds.size.x if bounds.size.x > 0 else 1.0
		var scale_y = new_bounds.size.y / bounds.size.y if bounds.size.y > 0 else 1.0

		for index in selected_indices:
			if index >= 0 and index < shapes.size():
				var shape = shapes[index]
				var shape_pos = Vector2(shape.position[0], shape.position[1])
				var shape_size = Vector2(shape.size[0], shape.size[1])

				# Scale position relative to original bounds
				var rel_pos = (shape_pos - bounds.position) / bounds.size if bounds.size.x > 0 and bounds.size.y > 0 else Vector2.ZERO
				var new_pos = new_bounds.position + rel_pos * new_bounds.size

				shape.position = [new_pos.x, new_pos.y]
				shape.size = [shape_size.x * scale_x, shape_size.y * scale_y]

		canvas_changed.emit()


func _finish_resizing() -> void:
	_is_resizing = false
	_resize_handle = -1
	for index in selected_indices:
		shape_modified.emit(index)


func _get_canvas_rect() -> Rect2:
	var available_size = size
	var canvas_display_size = canvas_size * zoom_level
	var offset = (available_size - Vector2(canvas_display_size, canvas_display_size)) / 2 + pan_offset
	return Rect2(offset, Vector2(canvas_display_size, canvas_display_size))


func _canvas_to_screen(canvas_pos: Vector2, canvas_rect: Rect2) -> Vector2:
	var scale = canvas_rect.size.x / canvas_size
	return canvas_rect.position + canvas_pos * scale


func _screen_to_canvas(screen_pos: Vector2, canvas_rect: Rect2) -> Vector2:
	var scale = canvas_size / canvas_rect.size.x
	return (screen_pos - canvas_rect.position) * scale


func _snap_position(pos: Vector2) -> Vector2:
	if snap_to_grid:
		return Vector2(
			round(pos.x / grid_size) * grid_size,
			round(pos.y / grid_size) * grid_size
		)
	return pos


func _get_sorted_shapes() -> Array:
	var result = []
	for i in range(shapes.size()):
		result.append({"shape": shapes[i], "index": i})
	result.sort_custom(func(a, b): return a.shape.get("layer", 0) < b.shape.get("layer", 0))
	return result


func _get_sorted_preview_shapes() -> Array:
	var result = []
	for i in range(_pose_preview_shapes.size()):
		result.append({"shape": _pose_preview_shapes[i], "index": i})
	result.sort_custom(func(a, b): return a.shape.get("layer", 0) < b.shape.get("layer", 0))
	return result


func _get_shape_at_position(canvas_pos: Vector2) -> int:
	# Check shapes in reverse order (top to bottom)
	var sorted = _get_sorted_shapes()
	sorted.reverse()

	for shape_data in sorted:
		var shape = shape_data.shape
		var pos = Vector2(shape.position[0], shape.position[1])
		var shape_size = Vector2(shape.size[0], shape.size[1])
		var bounds = Rect2(pos, shape_size)

		if bounds.has_point(canvas_pos):
			return shape_data.index

	return -1


func _get_selection_bounds() -> Rect2:
	if selected_indices.is_empty():
		return Rect2()

	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)

	for index in selected_indices:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			var pos = Vector2(shape.position[0], shape.position[1])
			var shape_size = Vector2(shape.size[0], shape.size[1])

			min_pos = Vector2(min(min_pos.x, pos.x), min(min_pos.y, pos.y))
			max_pos = Vector2(max(max_pos.x, pos.x + shape_size.x), max(max_pos.y, pos.y + shape_size.y))

	return Rect2(min_pos, max_pos - min_pos)


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the current drawing tool.
func set_tool(tool_id: int) -> void:
	current_tool = tool_id as Tool
	print("CharacterCanvas: Tool changed to ", Tool.keys()[current_tool])
	if current_tool != Tool.SELECT:
		selected_indices.clear()
		shape_selected.emit(selected_indices)
	queue_redraw()


## Set the current drawing color.
func set_color(color: Color) -> void:
	current_color = color


## Load reference image from path.
func load_reference_image(path: String) -> bool:
	if path.is_empty():
		reference_texture = null
		queue_redraw()
		return true

	var texture = load(path) as Texture2D
	if texture:
		reference_texture = texture
		queue_redraw()
		return true
	return false


## Clear reference image.
func clear_reference_image() -> void:
	reference_texture = null
	queue_redraw()


## Set zoom level (1x, 2x, 4x, etc.)
func set_zoom(level: float) -> void:
	zoom_level = level


## Fit canvas to view.
func fit_to_view() -> void:
	var available_size = size
	var fit_zoom = min(available_size.x, available_size.y) / canvas_size * 0.9
	zoom_level = clampf(fit_zoom, 1.0, 16.0)
	pan_offset = Vector2.ZERO


## Reset view to default.
func reset_view() -> void:
	zoom_level = 4.0
	pan_offset = Vector2.ZERO


## Get zoom as percentage.
func get_zoom_percent() -> int:
	return int(zoom_level * 100)


## Load shapes from project.
func load_from_project(project: RefCounted) -> void:
	if project:
		shapes = project.shapes.duplicate(true)
		canvas_size = project.canvas_size
		reference_opacity = project.reference_opacity
		if not project.reference_image_path.is_empty():
			load_reference_image(project.reference_image_path)
		else:
			reference_texture = null
	else:
		shapes.clear()
		canvas_size = 64
		reference_texture = null

	selected_indices.clear()
	queue_redraw()


## Save shapes to project.
func save_to_project(project: RefCounted) -> void:
	if project:
		project.shapes = shapes.duplicate(true)
		project.canvas_size = canvas_size
		project.reference_opacity = reference_opacity


## Delete selected shapes.
func delete_selected() -> void:
	if selected_indices.is_empty():
		return

	# Sort indices in descending order to delete from end first
	var sorted_indices = selected_indices.duplicate()
	sorted_indices.sort()
	sorted_indices.reverse()

	for index in sorted_indices:
		if index >= 0 and index < shapes.size():
			shapes.remove_at(index)
			shape_removed.emit(index)

	selected_indices.clear()
	shape_selected.emit(selected_indices)
	canvas_changed.emit()


## Move selected shapes up in layer order.
func move_layer_up() -> void:
	for index in selected_indices:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			shape.layer = shape.get("layer", 0) + 1
	canvas_changed.emit()
	queue_redraw()


## Move selected shapes down in layer order.
func move_layer_down() -> void:
	for index in selected_indices:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			shape.layer = max(0, shape.get("layer", 0) - 1)
	canvas_changed.emit()
	queue_redraw()


## Update a selected shape's color.
func set_selected_color(color: Color) -> void:
	for index in selected_indices:
		if index >= 0 and index < shapes.size():
			var shape = shapes[index]
			shape.color = [color.r, color.g, color.b, color.a]
			shape_modified.emit(index)
	canvas_changed.emit()
	queue_redraw()


## Get the shape count.
func get_shape_count() -> int:
	return shapes.size()


# =============================================================================
# PIVOT AND BODY PART API
# =============================================================================

## Enable or disable pivot mode.
func set_pivot_mode(enabled: bool) -> void:
	pivot_mode = enabled
	queue_redraw()


## Set pivot point for a body part.
func set_pivot_point(part_name: String, pos: Vector2) -> void:
	pivot_points[part_name] = pos
	queue_redraw()


## Remove pivot point for a body part.
func remove_pivot_point(part_name: String) -> void:
	pivot_points.erase(part_name)
	queue_redraw()


## Clear all pivot points.
func clear_pivot_points() -> void:
	pivot_points.clear()
	queue_redraw()


## Load pivot points from body parts dictionary.
func load_pivot_points(body_parts: Dictionary) -> void:
	pivot_points.clear()
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part is BodyPart and part.pivot_set:
			pivot_points[part_name] = part.pivot
		elif part is Dictionary and part.get("pivot_set", false):
			var pivot_arr = part.get("pivot", [0, 0])
			pivot_points[part_name] = Vector2(pivot_arr[0], pivot_arr[1])
	queue_redraw()


## Highlight shapes belonging to a body part.
func highlight_body_part(part_name: String, shape_indices: Array[int]) -> void:
	highlighted_part = part_name
	highlighted_shapes = shape_indices
	queue_redraw()


## Clear shape highlighting.
func clear_highlight() -> void:
	highlighted_part = ""
	highlighted_shapes.clear()
	queue_redraw()


## Get shapes at specified indices (for export/visualization).
func get_shapes_at_indices(indices: Array[int]) -> Array:
	var result = []
	for idx in indices:
		if idx >= 0 and idx < shapes.size():
			result.append(shapes[idx])
	return result


# =============================================================================
# POSE PREVIEW API
# =============================================================================

## Set pose preview mode - transforms shapes based on pose rotations.
## pose: The Pose resource containing rotation data for body parts.
## body_parts: Dictionary of body part name -> BodyPart objects.
func set_pose_preview(pose: Pose, body_parts: Dictionary) -> void:
	if pose == null:
		clear_pose_preview()
		return

	_current_preview_pose = pose
	_current_preview_body_parts = body_parts

	# Debug logging
	print("set_pose_preview: shapes=%d, body_parts=%d, pose=%s" % [shapes.size(), body_parts.size(), pose.pose_name if pose else "null"])
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part is BodyPart:
			print("  %s: shapes=%s, pivot=%s, pivot_set=%s" % [part_name, part.shape_indices, part.pivot, part.pivot_set])
		else:
			print("  %s: NOT a BodyPart object, type=%s" % [part_name, typeof(part)])

	# PoseRenderer expects BodyPart objects directly
	# Use PoseRenderer to transform shapes
	_pose_preview_shapes = PoseRenderer.apply_pose(shapes, body_parts, pose, canvas_size)
	_pose_preview_enabled = true

	print("set_pose_preview: preview_shapes=%d, preview_enabled=%s" % [_pose_preview_shapes.size(), _pose_preview_enabled])

	queue_redraw()


## Clear pose preview and return to normal shape display.
func clear_pose_preview() -> void:
	_pose_preview_enabled = false
	_pose_preview_shapes.clear()
	_current_preview_pose = null
	_current_preview_body_parts.clear()
	queue_redraw()


## Check if pose preview is currently active.
func is_pose_preview_active() -> bool:
	return _pose_preview_enabled


## Update pose preview with current pose (call when pose rotations change).
func update_pose_preview() -> void:
	if _pose_preview_enabled and _current_preview_pose:
		set_pose_preview(_current_preview_pose, _current_preview_body_parts)
