@tool
extends Control
class_name FourUpPreview
## Displays all 4 character directions in a 2x2 grid layout.
## Shows South, North, East, West views simultaneously for comparison.

signal direction_selected(direction: DirectionView.Direction)

# Direction views data
var direction_views: Dictionary = {}  # Direction -> DirectionView
var canvas_size: int = 64
var selected_direction: DirectionView.Direction = DirectionView.Direction.SOUTH

# Visual settings
const GRID_PADDING := 8
const LABEL_HEIGHT := 20
const BACKGROUND_COLOR := Color(0.12, 0.12, 0.12, 1.0)
const BORDER_COLOR := Color(0.4, 0.4, 0.4, 1.0)
const SELECTED_BORDER_COLOR := Color(0.4, 0.7, 1.0, 1.0)
const UNCONFIGURED_COLOR := Color(0.2, 0.2, 0.2, 1.0)
const AUTO_GENERATED_TINT := Color(0.8, 0.9, 1.0, 0.3)

# Grid layout (2x2)
# [ South | East  ]
# [ West  | North ]
const GRID_LAYOUT: Array[DirectionView.Direction] = [
	DirectionView.Direction.SOUTH,
	DirectionView.Direction.EAST,
	DirectionView.Direction.WEST,
	DirectionView.Direction.NORTH,
]


func _ready() -> void:
	custom_minimum_size = Vector2(300, 300)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_direction := _get_direction_at_position(event.position)
		if clicked_direction != -1:
			selected_direction = clicked_direction as DirectionView.Direction
			direction_selected.emit(selected_direction)
			queue_redraw()


func _draw() -> void:
	var cell_size := _get_cell_size()

	for i in range(4):
		var direction: DirectionView.Direction = GRID_LAYOUT[i]
		var cell_rect := _get_cell_rect(i, cell_size)

		# Draw cell background
		var view: DirectionView = direction_views.get(direction)
		if view and view.is_configured:
			draw_rect(cell_rect, BACKGROUND_COLOR)

			# Draw auto-generated indicator
			if view.is_auto_generated:
				draw_rect(cell_rect, AUTO_GENERATED_TINT)

			# Draw character shapes
			_draw_direction_preview(cell_rect, view)
		else:
			# Unconfigured direction
			draw_rect(cell_rect, UNCONFIGURED_COLOR)
			_draw_unconfigured_indicator(cell_rect, direction)

		# Draw border (highlighted if selected)
		var border_color := SELECTED_BORDER_COLOR if direction == selected_direction else BORDER_COLOR
		var border_width := 3.0 if direction == selected_direction else 1.0
		draw_rect(cell_rect, border_color, false, border_width)

		# Draw direction label
		_draw_direction_label(cell_rect, direction)


func _get_cell_size() -> Vector2:
	var available := size - Vector2(GRID_PADDING * 3, GRID_PADDING * 3 + LABEL_HEIGHT * 2)
	return Vector2(available.x / 2, available.y / 2)


func _get_cell_rect(index: int, cell_size: Vector2) -> Rect2:
	var col := index % 2
	var row := index / 2
	var x := GRID_PADDING + col * (cell_size.x + GRID_PADDING)
	var y := GRID_PADDING + LABEL_HEIGHT + row * (cell_size.y + GRID_PADDING + LABEL_HEIGHT)
	return Rect2(Vector2(x, y), cell_size)


func _get_direction_at_position(pos: Vector2) -> int:
	var cell_size := _get_cell_size()

	for i in range(4):
		var cell_rect := _get_cell_rect(i, cell_size)
		if cell_rect.has_point(pos):
			return GRID_LAYOUT[i]

	return -1


func _draw_direction_preview(cell_rect: Rect2, view: DirectionView) -> void:
	if view.shapes.is_empty():
		return

	# Sort shapes by layer
	var sorted_shapes := view.shapes.duplicate()
	sorted_shapes.sort_custom(func(a, b): return a.get("layer", 0) < b.get("layer", 0))

	var scale := min(cell_rect.size.x, cell_rect.size.y) / float(canvas_size)

	for shape in sorted_shapes:
		var pos := Vector2(shape.position[0], shape.position[1]) * scale + cell_rect.position
		var shape_size := Vector2(shape.size[0], shape.size[1]) * scale
		var color := Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])
		var rotation: float = shape.get("rotation", 0.0)

		match shape.type:
			"rectangle":
				_draw_rotated_rect(pos, shape_size, rotation, color)
			"circle":
				_draw_circle_shape(pos, shape_size, color)
			"ellipse":
				_draw_ellipse_shape(pos, shape_size, rotation, color)
			"triangle":
				_draw_triangle_shape(pos, shape_size, rotation, color)


func _draw_rotated_rect(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var half_size := shape_size / 2
	var points: PackedVector2Array = []

	var corners: Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	for corner in corners:
		var point: Vector2 = corner * half_size
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_circle_shape(pos: Vector2, shape_size: Vector2, color: Color) -> void:
	var center := pos + shape_size / 2
	var radius: float = minf(shape_size.x, shape_size.y) / 2.0
	draw_circle(center, radius, color)


func _draw_ellipse_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var points: PackedVector2Array = []

	for i in range(24):
		var angle := i * TAU / 24
		var point := Vector2(cos(angle) * shape_size.x / 2, sin(angle) * shape_size.y / 2)
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_triangle_shape(pos: Vector2, shape_size: Vector2, rotation: float, color: Color) -> void:
	var center := pos + shape_size / 2
	var tri_points := [
		Vector2(0, -shape_size.y / 2),
		Vector2(-shape_size.x / 2, shape_size.y / 2),
		Vector2(shape_size.x / 2, shape_size.y / 2),
	]

	var points: PackedVector2Array = []
	for point in tri_points:
		point = point.rotated(deg_to_rad(rotation))
		points.append(center + point)

	draw_colored_polygon(points, color)


func _draw_unconfigured_indicator(cell_rect: Rect2, direction: DirectionView.Direction) -> void:
	var font := ThemeDB.fallback_font
	var text := "Not Configured"
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
	var text_pos := cell_rect.position + (cell_rect.size - text_size) / 2
	text_pos.y += text_size.y / 2
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.5, 0.5, 0.5))


func _draw_direction_label(cell_rect: Rect2, direction: DirectionView.Direction) -> void:
	var font := ThemeDB.fallback_font
	var label := DirectionView.DIRECTION_NAMES.get(direction, "Unknown")
	var view: DirectionView = direction_views.get(direction)

	# Add indicator for auto-generated views
	if view and view.is_auto_generated:
		label += " (Auto)"

	var label_pos := Vector2(cell_rect.position.x, cell_rect.position.y - 4)
	var label_color := SELECTED_BORDER_COLOR if direction == selected_direction else Color.WHITE
	draw_string(font, label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, label_color)


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the direction views data.
func set_direction_views(views: Dictionary, p_canvas_size: int) -> void:
	direction_views = views
	canvas_size = p_canvas_size
	queue_redraw()


## Update a single direction view.
func update_direction_view(direction: DirectionView.Direction, view: DirectionView) -> void:
	direction_views[direction] = view
	queue_redraw()


## Set the selected direction.
func set_selected_direction(direction: DirectionView.Direction) -> void:
	selected_direction = direction
	queue_redraw()


## Get the selected direction.
func get_selected_direction() -> DirectionView.Direction:
	return selected_direction


## Clear all direction views.
func clear() -> void:
	direction_views.clear()
	queue_redraw()


## Check if a direction is configured.
func is_direction_configured(direction: DirectionView.Direction) -> bool:
	var view: DirectionView = direction_views.get(direction)
	return view != null and view.is_configured


## Get the count of configured directions.
func get_configured_count() -> int:
	var count := 0
	for direction in direction_views:
		var view: DirectionView = direction_views[direction]
		if view and view.is_configured:
			count += 1
	return count
