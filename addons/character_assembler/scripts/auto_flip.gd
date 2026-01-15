@tool
extends RefCounted
class_name AutoFlip
## Utility class for automatically generating flipped direction views.
## Handles horizontal flip (East → West) and vertical flip (South → North).

## Flip modes for generating alternate directions.
enum FlipMode {
	HORIZONTAL,  # Mirror left-right (East <-> West)
	VERTICAL,    # Mirror top-bottom (South <-> North)
}


## Generate a horizontally flipped version of shapes.
## Used for East → West or West → East generation.
static func flip_shapes_horizontal(shapes: Array, canvas_size: int) -> Array:
	var flipped: Array = []

	for shape in shapes:
		var new_shape: Dictionary = shape.duplicate(true)

		# Flip X position: new_x = canvas_size - old_x - width
		var old_x: float = shape.position[0]
		var width: float = shape.size[0]
		new_shape.position = [canvas_size - old_x - width, shape.position[1]]

		# Flip rotation (negate the angle)
		if new_shape.has("rotation"):
			new_shape.rotation = -new_shape.rotation

		flipped.append(new_shape)

	return flipped


## Generate a vertically flipped version of shapes.
## Used for South → North or North → South generation.
## Note: This often needs manual adjustment for character backs.
static func flip_shapes_vertical(shapes: Array, canvas_size: int) -> Array:
	var flipped: Array = []

	for shape in shapes:
		var new_shape: Dictionary = shape.duplicate(true)

		# Flip Y position: new_y = canvas_size - old_y - height
		var old_y: float = shape.position[1]
		var height: float = shape.size[1]
		new_shape.position = [shape.position[0], canvas_size - old_y - height]

		# Flip rotation (negate the angle for vertical flip)
		if new_shape.has("rotation"):
			new_shape.rotation = -new_shape.rotation

		flipped.append(new_shape)

	return flipped


## Flip body part pivots horizontally.
static func flip_body_parts_horizontal(body_parts: Dictionary, canvas_size: int) -> Dictionary:
	var flipped: Dictionary = {}

	for part_name in body_parts:
		var part: Dictionary = body_parts[part_name].duplicate(true)

		# Flip pivot X position
		if part.has("pivot"):
			var pivot: Array = part.pivot
			part.pivot = [canvas_size - pivot[0], pivot[1]]

		# Flip connected shape indices (shapes will be flipped separately)
		# The shape references remain the same, just their positions change

		flipped[part_name] = part

	return flipped


## Flip body part pivots vertically.
static func flip_body_parts_vertical(body_parts: Dictionary, canvas_size: int) -> Dictionary:
	var flipped: Dictionary = {}

	for part_name in body_parts:
		var part: Dictionary = body_parts[part_name].duplicate(true)

		# Flip pivot Y position
		if part.has("pivot"):
			var pivot: Array = part.pivot
			part.pivot = [pivot[0], canvas_size - pivot[1]]

		flipped[part_name] = part

	return flipped


## Flip pose rotations horizontally.
## Negates rotation values for horizontal mirroring.
static func flip_pose_rotations_horizontal(rotations: Dictionary) -> Dictionary:
	var flipped: Dictionary = {}

	for part_name in rotations:
		# Negate rotation for horizontal flip
		flipped[part_name] = -rotations[part_name]

	return flipped


## Flip pose rotations vertically.
## Adjusts rotation values for vertical mirroring.
static func flip_pose_rotations_vertical(rotations: Dictionary) -> Dictionary:
	var flipped: Dictionary = {}

	for part_name in rotations:
		# For vertical flip, we also negate but may need different adjustments
		# depending on the character design
		flipped[part_name] = -rotations[part_name]

	return flipped


## Generate a complete flipped DirectionView from a source view.
static func generate_flipped_view(
	source: DirectionView,
	target_direction: DirectionView.Direction,
	flip_mode: FlipMode,
	canvas_size: int
) -> DirectionView:
	var flipped_view := DirectionView.new(target_direction)
	flipped_view.is_auto_generated = true
	flipped_view.source_direction = source.get_key()

	# Flip shapes
	if flip_mode == FlipMode.HORIZONTAL:
		flipped_view.shapes = flip_shapes_horizontal(source.shapes, canvas_size)
		flipped_view.body_parts = flip_body_parts_horizontal(source.body_parts, canvas_size)

		# Flip pose overrides
		for pose_name in source.pose_overrides:
			flipped_view.pose_overrides[pose_name] = flip_pose_rotations_horizontal(
				source.pose_overrides[pose_name]
			)
	else:  # VERTICAL
		flipped_view.shapes = flip_shapes_vertical(source.shapes, canvas_size)
		flipped_view.body_parts = flip_body_parts_vertical(source.body_parts, canvas_size)

		# Flip pose overrides
		for pose_name in source.pose_overrides:
			flipped_view.pose_overrides[pose_name] = flip_pose_rotations_vertical(
				source.pose_overrides[pose_name]
			)

	flipped_view.is_configured = source.is_configured

	return flipped_view


## Get the recommended flip mode for generating a target direction from source.
static func get_recommended_flip_mode(
	source: DirectionView.Direction,
	target: DirectionView.Direction
) -> FlipMode:
	# Horizontal flips: East <-> West
	if (source == DirectionView.Direction.EAST and target == DirectionView.Direction.WEST) or \
	   (source == DirectionView.Direction.WEST and target == DirectionView.Direction.EAST):
		return FlipMode.HORIZONTAL

	# Vertical flips: South <-> North
	# Note: This is less common as front/back views usually differ significantly
	return FlipMode.VERTICAL


## Check if a direction can be auto-generated from another.
static func can_auto_generate(
	source: DirectionView.Direction,
	target: DirectionView.Direction
) -> bool:
	# Can horizontally flip East <-> West
	if (source == DirectionView.Direction.EAST and target == DirectionView.Direction.WEST) or \
	   (source == DirectionView.Direction.WEST and target == DirectionView.Direction.EAST):
		return true

	# Can vertically flip South <-> North (though usually needs adjustment)
	if (source == DirectionView.Direction.SOUTH and target == DirectionView.Direction.NORTH) or \
	   (source == DirectionView.Direction.NORTH and target == DirectionView.Direction.SOUTH):
		return true

	return false


## Get the auto-generation source for a target direction.
## Returns the best source direction for auto-generating the target.
static func get_auto_source(target: DirectionView.Direction) -> DirectionView.Direction:
	match target:
		DirectionView.Direction.WEST:
			return DirectionView.Direction.EAST
		DirectionView.Direction.EAST:
			return DirectionView.Direction.WEST
		DirectionView.Direction.NORTH:
			return DirectionView.Direction.SOUTH
		DirectionView.Direction.SOUTH:
			return DirectionView.Direction.NORTH
		_:
			return DirectionView.Direction.SOUTH


## Apply layer order adjustments for flipped views.
## Some layers may need reordering when flipping (e.g., arm in front vs behind).
static func adjust_layer_order_for_flip(shapes: Array, flip_mode: FlipMode) -> Array:
	var adjusted := shapes.duplicate(true)

	# For horizontal flips, swap layers of left/right paired parts
	if flip_mode == FlipMode.HORIZONTAL:
		var layer_swaps: Dictionary = {}

		for i in range(adjusted.size()):
			var shape: Dictionary = adjusted[i]
			var part_name: String = shape.get("body_part", "")

			# Check for left/right pairs
			if part_name.ends_with("_left"):
				var right_name := part_name.replace("_left", "_right")
				layer_swaps[part_name] = right_name
			elif part_name.ends_with("_right"):
				var left_name := part_name.replace("_right", "_left")
				layer_swaps[part_name] = left_name

		# Swap layers between paired parts
		for i in range(adjusted.size()):
			var shape: Dictionary = adjusted[i]
			var part_name: String = shape.get("body_part", "")

			if layer_swaps.has(part_name):
				# Find the paired shape and swap layers
				for j in range(adjusted.size()):
					if adjusted[j].get("body_part", "") == layer_swaps[part_name]:
						var temp_layer: int = adjusted[i].get("layer", 0)
						adjusted[i]["layer"] = adjusted[j].get("layer", 0)
						adjusted[j]["layer"] = temp_layer
						break

	return adjusted
