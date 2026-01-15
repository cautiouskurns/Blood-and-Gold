@tool
extends RefCounted
class_name SpriteSheetGenerator
## Generates sprite sheet images from character animations.
## Arranges frames in a grid layout for efficient texture atlasing.

## Result of sprite sheet generation.
class SpriteSheetResult:
	var image: Image
	var frame_size: Vector2i
	var grid_size: Vector2i  # columns x rows
	var animations: Dictionary  # animation_name -> { row: int, start_col: int, frame_count: int }
	var total_frames: int

	func _init() -> void:
		image = null
		frame_size = Vector2i.ZERO
		grid_size = Vector2i.ZERO
		animations = {}
		total_frames = 0


## Generate a sprite sheet from animations.
## Returns a SpriteSheetResult with the image and metadata.
static func generate(
	shapes: Array,
	body_parts: Dictionary,
	animations: Array[AnimationData],
	canvas_size: int,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> SpriteSheetResult:
	var result := SpriteSheetResult.new()

	if animations.is_empty():
		return result

	# Calculate total frames and max frames per animation
	var total_frames := 0
	var max_frames_per_animation := 0
	for anim in animations:
		if anim.is_generated:
			total_frames += anim.generated_frames.size()
			max_frames_per_animation = max(max_frames_per_animation, anim.generated_frames.size())

	if total_frames == 0:
		return result

	# Determine grid layout
	# Use a layout where each animation is on its own row
	var frame_size := canvas_size * scale
	var columns := max_frames_per_animation
	var rows := 0

	for anim in animations:
		if anim.is_generated and not anim.generated_frames.is_empty():
			rows += 1

	result.frame_size = Vector2i(frame_size, frame_size)
	result.grid_size = Vector2i(columns, rows)
	result.total_frames = total_frames

	# Create the sprite sheet image
	var sheet_width := columns * frame_size
	var sheet_height := rows * frame_size
	var sheet := Image.create(sheet_width, sheet_height, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)

	# Render each animation
	var current_row := 0
	for anim in animations:
		if not anim.is_generated or anim.generated_frames.is_empty():
			continue

		# Render all frames for this animation
		var frames := FrameRenderer.render_animation_frames(
			shapes,
			body_parts,
			anim,
			canvas_size,
			scale,
			background,
			background_color
		)

		# Blit frames to sheet
		for col in range(frames.size()):
			var frame := frames[col]
			var dest_pos := Vector2i(col * frame_size, current_row * frame_size)
			_blit_image(sheet, frame, dest_pos)

		# Store animation metadata
		result.animations[anim.animation_name] = {
			"row": current_row,
			"start_col": 0,
			"frame_count": frames.size(),
			"fps": anim.fps,
			"loop": anim.loop
		}

		current_row += 1

	result.image = sheet
	return result


## Generate a sprite sheet for a single direction with all animations.
static func generate_for_direction(
	shapes: Array,
	body_parts: Dictionary,
	animations: Array[AnimationData],
	direction_name: String,
	canvas_size: int,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> SpriteSheetResult:
	var result := generate(shapes, body_parts, animations, canvas_size, scale, background, background_color)

	# Rename animations to include direction
	var renamed_animations: Dictionary = {}
	for anim_name in result.animations:
		var new_name := "%s_%s" % [anim_name, direction_name]
		renamed_animations[new_name] = result.animations[anim_name]

	result.animations = renamed_animations
	return result


## Generate a combined sprite sheet for all directions.
## Each direction's animations are stacked vertically.
static func generate_all_directions(
	direction_views: Dictionary,  # direction_key -> DirectionView
	body_parts_per_direction: Dictionary,  # direction_key -> body_parts Dictionary
	animations: Array[AnimationData],
	canvas_size: int,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> SpriteSheetResult:
	var result := SpriteSheetResult.new()

	if direction_views.is_empty() or animations.is_empty():
		return result

	# Calculate frame count per animation
	var max_frames_per_animation := 0
	var valid_animation_count := 0
	for anim in animations:
		if anim.is_generated and not anim.generated_frames.is_empty():
			max_frames_per_animation = max(max_frames_per_animation, anim.generated_frames.size())
			valid_animation_count += 1

	if max_frames_per_animation == 0:
		return result

	# Count configured directions
	var configured_directions: Array[String] = []
	for dir_key in direction_views:
		var view: DirectionView = direction_views[dir_key]
		if view and view.is_configured:
			configured_directions.append(dir_key)

	if configured_directions.is_empty():
		return result

	# Calculate grid size
	var frame_size := canvas_size * scale
	var columns := max_frames_per_animation
	var rows := valid_animation_count * configured_directions.size()

	result.frame_size = Vector2i(frame_size, frame_size)
	result.grid_size = Vector2i(columns, rows)

	# Create the sprite sheet image
	var sheet_width := columns * frame_size
	var sheet_height := rows * frame_size
	var sheet := Image.create(sheet_width, sheet_height, false, Image.FORMAT_RGBA8)
	sheet.fill(Color.TRANSPARENT)

	# Render each direction's animations
	var current_row := 0
	var total_frames := 0

	for dir_key in configured_directions:
		var view: DirectionView = direction_views[dir_key]
		var dir_body_parts: Dictionary = body_parts_per_direction.get(dir_key, {})

		for anim in animations:
			if not anim.is_generated or anim.generated_frames.is_empty():
				continue

			# Render frames for this direction
			var frames := FrameRenderer.render_animation_frames(
				view.shapes,
				dir_body_parts,
				anim,
				canvas_size,
				scale,
				background,
				background_color
			)

			# Blit frames to sheet
			for col in range(frames.size()):
				var frame := frames[col]
				var dest_pos := Vector2i(col * frame_size, current_row * frame_size)
				_blit_image(sheet, frame, dest_pos)

			# Store animation metadata with direction
			var anim_key := "%s_%s" % [anim.animation_name, dir_key]
			result.animations[anim_key] = {
				"row": current_row,
				"start_col": 0,
				"frame_count": frames.size(),
				"fps": anim.fps,
				"loop": anim.loop,
				"direction": dir_key
			}

			total_frames += frames.size()
			current_row += 1

	result.total_frames = total_frames
	result.image = sheet
	return result


## Save a sprite sheet result to a PNG file.
static func save_to_png(result: SpriteSheetResult, path: String) -> Error:
	if result.image == null:
		return ERR_INVALID_DATA

	return result.image.save_png(path)


## Blit (copy) one image onto another at a position.
static func _blit_image(dest: Image, src: Image, pos: Vector2i) -> void:
	var src_rect := Rect2i(Vector2i.ZERO, src.get_size())
	dest.blit_rect(src, src_rect, pos)


## Calculate the optimal grid dimensions for a given number of frames.
static func calculate_optimal_grid(frame_count: int, max_columns: int = 16) -> Vector2i:
	if frame_count <= 0:
		return Vector2i(1, 1)

	# Try to make a square-ish grid
	var cols := min(frame_count, max_columns)
	var rows := ceili(float(frame_count) / float(cols))

	return Vector2i(cols, rows)


## Get the position of a frame in the sprite sheet.
static func get_frame_position(
	animation_name: String,
	frame_index: int,
	result: SpriteSheetResult
) -> Rect2i:
	if not result.animations.has(animation_name):
		return Rect2i()

	var anim_data: Dictionary = result.animations[animation_name]
	var row: int = anim_data.row
	var col: int = anim_data.start_col + frame_index

	if frame_index >= anim_data.frame_count:
		return Rect2i()

	return Rect2i(
		Vector2i(col * result.frame_size.x, row * result.frame_size.y),
		result.frame_size
	)
