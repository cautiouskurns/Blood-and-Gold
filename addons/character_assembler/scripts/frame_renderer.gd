@tool
extends RefCounted
class_name FrameRenderer
## Renders character frames to images for export.
## Handles scaling, background colors, and animation frame generation.

## Background options for export.
enum BackgroundType {
	TRANSPARENT,
	SOLID_COLOR,
}

## Render a single frame with the given rotations.
static func render_frame(
	shapes: Array,
	body_parts: Dictionary,
	rotations: Dictionary,
	canvas_size: int,
	scale: int = 1,
	background: BackgroundType = BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> Image:
	# Create a temporary pose from the rotations
	var temp_pose := Pose.new("export_frame", rotations)

	# Apply pose transformations
	var transformed := PoseRenderer.apply_pose(shapes, body_parts, temp_pose, canvas_size)

	# Create the base image
	var image := Image.create(canvas_size, canvas_size, false, Image.FORMAT_RGBA8)

	# Fill background
	if background == BackgroundType.SOLID_COLOR:
		image.fill(background_color)
	else:
		image.fill(Color.TRANSPARENT)

	# Sort shapes by layer and render
	var sorted_shapes := transformed.duplicate()
	sorted_shapes.sort_custom(func(a, b):
		return a.get("layer", 0) < b.get("layer", 0)
	)

	for shape in sorted_shapes:
		_render_shape_to_image(image, shape, canvas_size)

	# Scale if needed
	if scale > 1:
		var scaled_size := canvas_size * scale
		image.resize(scaled_size, scaled_size, Image.INTERPOLATE_NEAREST)

	return image


## Render a static frame (no pose applied).
static func render_static_frame(
	shapes: Array,
	canvas_size: int,
	scale: int = 1,
	background: BackgroundType = BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> Image:
	return render_frame(shapes, {}, {}, canvas_size, scale, background, background_color)


## Render all frames of an animation.
static func render_animation_frames(
	shapes: Array,
	body_parts: Dictionary,
	animation: AnimationData,
	canvas_size: int,
	scale: int = 1,
	background: BackgroundType = BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> Array[Image]:
	var frames: Array[Image] = []

	if not animation.is_generated or animation.generated_frames.is_empty():
		return frames

	for frame_rotations in animation.generated_frames:
		var frame := render_frame(
			shapes,
			body_parts,
			frame_rotations,
			canvas_size,
			scale,
			background,
			background_color
		)
		frames.append(frame)

	return frames


## Render a shape to an image with proper clipping.
static func _render_shape_to_image(image: Image, shape: Dictionary, canvas_size: int) -> void:
	var pos := Vector2(shape.position[0], shape.position[1])
	var size := Vector2(shape.size[0], shape.size[1])
	var color := Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])
	var shape_type: String = shape.get("type", "rectangle")
	var rotation: float = shape.get("rotation", 0.0)

	# Handle rotation by rendering rotated shapes
	if abs(rotation) > 0.5:
		_render_rotated_shape(image, pos, size, color, shape_type, rotation, canvas_size)
	else:
		_render_axis_aligned_shape(image, pos, size, color, shape_type, canvas_size)


## Render an axis-aligned shape (no rotation).
static func _render_axis_aligned_shape(
	image: Image,
	pos: Vector2,
	size: Vector2,
	color: Color,
	shape_type: String,
	canvas_size: int
) -> void:
	var rect := Rect2i(int(pos.x), int(pos.y), int(size.x), int(size.y))

	match shape_type:
		"rectangle":
			_fill_rect(image, rect, color, canvas_size)
		"circle":
			_fill_circle(image, rect, color, canvas_size)
		"ellipse":
			_fill_ellipse(image, rect, color, canvas_size)
		"triangle":
			_fill_triangle(image, rect, color, canvas_size)


## Render a rotated shape using polygon filling.
static func _render_rotated_shape(
	image: Image,
	pos: Vector2,
	size: Vector2,
	color: Color,
	shape_type: String,
	rotation: float,
	canvas_size: int
) -> void:
	var center := pos + size / 2.0
	var half_size := size / 2.0
	var rotation_rad := deg_to_rad(rotation)

	match shape_type:
		"rectangle":
			var corners := [
				Vector2(-half_size.x, -half_size.y),
				Vector2(half_size.x, -half_size.y),
				Vector2(half_size.x, half_size.y),
				Vector2(-half_size.x, half_size.y)
			]
			var rotated_corners: Array[Vector2] = []
			for corner in corners:
				rotated_corners.append(center + corner.rotated(rotation_rad))
			_fill_polygon(image, rotated_corners, color, canvas_size)

		"triangle":
			var points := [
				Vector2(0, -half_size.y),
				Vector2(-half_size.x, half_size.y),
				Vector2(half_size.x, half_size.y)
			]
			var rotated_points: Array[Vector2] = []
			for point in points:
				rotated_points.append(center + point.rotated(rotation_rad))
			_fill_polygon(image, rotated_points, color, canvas_size)

		"circle", "ellipse":
			# For ellipses, sample points around the perimeter
			var points: Array[Vector2] = []
			var num_segments := 24
			for i in range(num_segments):
				var angle := i * TAU / num_segments
				var point := Vector2(cos(angle) * half_size.x, sin(angle) * half_size.y)
				points.append(center + point.rotated(rotation_rad))
			_fill_polygon(image, points, color, canvas_size)


## Fill a rectangle.
static func _fill_rect(image: Image, rect: Rect2i, color: Color, canvas_size: int) -> void:
	for y in range(max(0, rect.position.y), min(canvas_size, rect.end.y)):
		for x in range(max(0, rect.position.x), min(canvas_size, rect.end.x)):
			_blend_pixel(image, x, y, color)


## Fill a circle (same width and height).
static func _fill_circle(image: Image, rect: Rect2i, color: Color, canvas_size: int) -> void:
	var center := Vector2(rect.position.x + rect.size.x / 2.0, rect.position.y + rect.size.y / 2.0)
	var radius := min(rect.size.x, rect.size.y) / 2.0

	for y in range(max(0, rect.position.y), min(canvas_size, rect.end.y)):
		for x in range(max(0, rect.position.x), min(canvas_size, rect.end.x)):
			var dist := Vector2(x - center.x, y - center.y).length()
			if dist <= radius:
				_blend_pixel(image, x, y, color)


## Fill an ellipse.
static func _fill_ellipse(image: Image, rect: Rect2i, color: Color, canvas_size: int) -> void:
	var center := Vector2(rect.position.x + rect.size.x / 2.0, rect.position.y + rect.size.y / 2.0)
	var radius := Vector2(rect.size.x / 2.0, rect.size.y / 2.0)

	for y in range(max(0, rect.position.y), min(canvas_size, rect.end.y)):
		for x in range(max(0, rect.position.x), min(canvas_size, rect.end.x)):
			var normalized := Vector2((x - center.x) / radius.x, (y - center.y) / radius.y)
			if normalized.length_squared() <= 1.0:
				_blend_pixel(image, x, y, color)


## Fill a triangle.
static func _fill_triangle(image: Image, rect: Rect2i, color: Color, canvas_size: int) -> void:
	var top := Vector2(rect.position.x + rect.size.x / 2.0, rect.position.y)
	var bottom_left := Vector2(rect.position.x, rect.end.y)
	var bottom_right := Vector2(rect.end.x, rect.end.y)

	_fill_polygon(image, [top, bottom_left, bottom_right], color, canvas_size)


## Fill an arbitrary polygon using scanline algorithm.
static func _fill_polygon(image: Image, points: Array[Vector2], color: Color, canvas_size: int) -> void:
	if points.size() < 3:
		return

	# Find bounding box
	var min_y := int(points[0].y)
	var max_y := int(points[0].y)
	for point in points:
		min_y = min(min_y, int(point.y))
		max_y = max(max_y, int(point.y))

	min_y = max(0, min_y)
	max_y = min(canvas_size - 1, max_y)

	# Scanline fill
	for y in range(min_y, max_y + 1):
		var intersections: Array[float] = []

		# Find intersections with polygon edges
		for i in range(points.size()):
			var p1 := points[i]
			var p2 := points[(i + 1) % points.size()]

			if (p1.y <= y and p2.y > y) or (p2.y <= y and p1.y > y):
				var t := (y - p1.y) / (p2.y - p1.y)
				intersections.append(p1.x + t * (p2.x - p1.x))

		# Sort intersections
		intersections.sort()

		# Fill between pairs
		for i in range(0, intersections.size() - 1, 2):
			var x_start := int(max(0, intersections[i]))
			var x_end := int(min(canvas_size - 1, intersections[i + 1]))
			for x in range(x_start, x_end + 1):
				_blend_pixel(image, x, y, color)


## Blend a pixel with alpha.
static func _blend_pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
		return

	if color.a >= 0.99:
		image.set_pixel(x, y, color)
	else:
		var existing := image.get_pixel(x, y)
		var blended := existing.blend(color)
		image.set_pixel(x, y, blended)
