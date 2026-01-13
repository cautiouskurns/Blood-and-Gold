@tool
extends RefCounted
class_name PoseRenderer
## Renders a character with a pose applied, handling hierarchical rotations.

## Apply a pose to shapes and return transformed shape data for rendering.
## Returns an array of transformed shape dictionaries.
static func apply_pose(
	shapes: Array,
	body_parts: Dictionary,
	pose: Pose,
	canvas_size: int = 64
) -> Array:
	if shapes.is_empty() or body_parts.is_empty():
		return shapes.duplicate(true)

	# Create a deep copy of shapes to transform
	var transformed_shapes: Array = []
	for shape in shapes:
		transformed_shapes.append(shape.duplicate(true))

	# Track which shapes have been processed
	var processed_shapes: Dictionary = {}

	# Start from root (Torso) and process hierarchically
	_apply_rotation_recursive(
		"Torso",
		0.0,
		Vector2.ZERO,
		{},
		transformed_shapes,
		body_parts,
		pose,
		processed_shapes,
		canvas_size
	)

	return transformed_shapes


## Recursively apply rotations through the body part hierarchy.
static func _apply_rotation_recursive(
	part_name: String,
	parent_world_rotation: float,
	parent_pivot_offset: Vector2,
	processed_parts: Dictionary,
	shapes: Array,
	body_parts: Dictionary,
	pose: Pose,
	processed_shapes: Dictionary,
	canvas_size: int
) -> void:
	if part_name in processed_parts:
		return
	processed_parts[part_name] = true

	# Skip if this body part doesn't exist
	if part_name not in body_parts:
		# Still process children
		var children := BodyPart.get_children(part_name)
		for child_name in children:
			_apply_rotation_recursive(
				child_name,
				parent_world_rotation,
				parent_pivot_offset,
				processed_parts,
				shapes,
				body_parts,
				pose,
				processed_shapes,
				canvas_size
			)
		return

	var body_part: BodyPart = body_parts[part_name]
	var local_rotation: float = pose.get_rotation(part_name)
	var world_rotation: float = parent_world_rotation + local_rotation

	# Get pivot point for this body part
	var pivot: Vector2 = body_part.pivot

	# Rotate all shapes belonging to this body part around the pivot
	for shape_idx in body_part.shape_indices:
		if shape_idx < 0 or shape_idx >= shapes.size():
			continue
		if shape_idx in processed_shapes:
			continue

		processed_shapes[shape_idx] = true
		var shape = shapes[shape_idx]

		# Apply rotation around pivot
		_rotate_shape_around_pivot(shape, pivot, world_rotation)

	# Process children
	var children := BodyPart.get_children(part_name)
	for child_name in children:
		_apply_rotation_recursive(
			child_name,
			world_rotation,
			pivot,
			processed_parts,
			shapes,
			body_parts,
			pose,
			processed_shapes,
			canvas_size
		)


## Rotate a shape around a pivot point.
static func _rotate_shape_around_pivot(shape: Dictionary, pivot: Vector2, rotation_degrees: float) -> void:
	if abs(rotation_degrees) < 0.01:
		return

	var rotation_rad := deg_to_rad(rotation_degrees)

	# Get shape position
	var pos := Vector2(shape.position[0], shape.position[1])
	var size := Vector2(shape.size[0], shape.size[1])

	# Calculate shape center
	var shape_center := pos + size / 2.0

	# Rotate shape center around pivot
	var offset := shape_center - pivot
	var rotated_offset := offset.rotated(rotation_rad)
	var new_center := pivot + rotated_offset

	# Update shape position (top-left corner)
	var new_pos := new_center - size / 2.0
	shape.position = [new_pos.x, new_pos.y]

	# Add rotation to the shape's own rotation
	var current_rotation: float = shape.get("rotation", 0.0)
	shape.rotation = current_rotation + rotation_degrees


## Calculate the bounding box of all transformed shapes.
static func get_bounds(shapes: Array) -> Rect2:
	if shapes.is_empty():
		return Rect2()

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for shape in shapes:
		var pos := Vector2(shape.position[0], shape.position[1])
		var size := Vector2(shape.size[0], shape.size[1])

		# For rotated shapes, we need to consider the rotated corners
		var rotation: float = shape.get("rotation", 0.0)
		if abs(rotation) > 0.01:
			var corners := _get_rotated_corners(pos, size, rotation)
			for corner in corners:
				min_pos.x = min(min_pos.x, corner.x)
				min_pos.y = min(min_pos.y, corner.y)
				max_pos.x = max(max_pos.x, corner.x)
				max_pos.y = max(max_pos.y, corner.y)
		else:
			min_pos.x = min(min_pos.x, pos.x)
			min_pos.y = min(min_pos.y, pos.y)
			max_pos.x = max(max_pos.x, pos.x + size.x)
			max_pos.y = max(max_pos.y, pos.y + size.y)

	return Rect2(min_pos, max_pos - min_pos)


## Get the four corners of a rotated rectangle.
static func _get_rotated_corners(pos: Vector2, size: Vector2, rotation_degrees: float) -> Array[Vector2]:
	var center := pos + size / 2.0
	var half_size := size / 2.0
	var rotation_rad := deg_to_rad(rotation_degrees)

	var corners: Array[Vector2] = []
	var offsets := [
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	]

	for offset in offsets:
		var rotated := offset.rotated(rotation_rad)
		corners.append(center + rotated)

	return corners


## Create a preview image of the posed character.
static func render_to_image(
	shapes: Array,
	body_parts: Dictionary,
	pose: Pose,
	canvas_size: int = 64
) -> Image:
	var transformed := apply_pose(shapes, body_parts, pose, canvas_size)

	var image := Image.create(canvas_size, canvas_size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Sort by layer
	var sorted_shapes := transformed.duplicate()
	sorted_shapes.sort_custom(func(a, b):
		return a.get("layer", 0) < b.get("layer", 0)
	)

	# Render each shape
	for shape in sorted_shapes:
		_render_shape_to_image(image, shape)

	return image


## Render a single shape to an image.
static func _render_shape_to_image(image: Image, shape: Dictionary) -> void:
	var pos := Vector2(shape.position[0], shape.position[1])
	var size := Vector2(shape.size[0], shape.size[1])
	var color := Color(shape.color[0], shape.color[1], shape.color[2], shape.color[3])
	var shape_type: String = shape.get("type", "rectangle")
	var rotation: float = shape.get("rotation", 0.0)

	# For simplicity, render axis-aligned shapes
	# Full rotation support would require more complex rasterization
	var rect := Rect2i(
		int(pos.x),
		int(pos.y),
		int(size.x),
		int(size.y)
	)

	match shape_type:
		"rectangle":
			_fill_rect(image, rect, color)
		"ellipse":
			_fill_ellipse(image, rect, color)
		"triangle":
			_fill_triangle(image, rect, color)
		"line":
			_draw_line(image, rect, color)


static func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(max(0, rect.position.y), min(image.get_height(), rect.end.y)):
		for x in range(max(0, rect.position.x), min(image.get_width(), rect.end.x)):
			image.set_pixel(x, y, color)


static func _fill_ellipse(image: Image, rect: Rect2i, color: Color) -> void:
	var center := Vector2(rect.position.x + rect.size.x / 2.0, rect.position.y + rect.size.y / 2.0)
	var radius := Vector2(rect.size.x / 2.0, rect.size.y / 2.0)

	for y in range(max(0, rect.position.y), min(image.get_height(), rect.end.y)):
		for x in range(max(0, rect.position.x), min(image.get_width(), rect.end.x)):
			var normalized := Vector2((x - center.x) / radius.x, (y - center.y) / radius.y)
			if normalized.length_squared() <= 1.0:
				image.set_pixel(x, y, color)


static func _fill_triangle(image: Image, rect: Rect2i, color: Color) -> void:
	# Simple triangle pointing up
	var top := Vector2(rect.position.x + rect.size.x / 2.0, rect.position.y)
	var bottom_left := Vector2(rect.position.x, rect.end.y)
	var bottom_right := Vector2(rect.end.x, rect.end.y)

	for y in range(max(0, rect.position.y), min(image.get_height(), rect.end.y)):
		for x in range(max(0, rect.position.x), min(image.get_width(), rect.end.x)):
			if _point_in_triangle(Vector2(x, y), top, bottom_left, bottom_right):
				image.set_pixel(x, y, color)


static func _point_in_triangle(p: Vector2, v1: Vector2, v2: Vector2, v3: Vector2) -> bool:
	var d1 := _sign(p, v1, v2)
	var d2 := _sign(p, v2, v3)
	var d3 := _sign(p, v3, v1)

	var has_neg := (d1 < 0) or (d2 < 0) or (d3 < 0)
	var has_pos := (d1 > 0) or (d2 > 0) or (d3 > 0)

	return not (has_neg and has_pos)


static func _sign(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)


static func _draw_line(image: Image, rect: Rect2i, color: Color) -> void:
	# Draw a line from top-left to bottom-right
	var start := Vector2(rect.position.x, rect.position.y)
	var end := Vector2(rect.end.x, rect.end.y)

	var steps := int(max(abs(end.x - start.x), abs(end.y - start.y)))
	if steps == 0:
		return

	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var pos := start.lerp(end, t)
		var x := int(pos.x)
		var y := int(pos.y)
		if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
			image.set_pixel(x, y, color)
