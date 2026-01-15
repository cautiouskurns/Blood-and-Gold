@tool
extends RefCounted
class_name FrameExporter
## Exports individual animation frames as PNG files.
## Uses naming conventions: {character}_{direction}_{animation}_{frame:03d}.png

## Result of frame export operation.
class FrameExportResult:
	var success: bool
	var files_exported: int
	var errors: Array[String]
	var output_directory: String

	func _init() -> void:
		success = true
		files_exported = 0
		errors = []
		output_directory = ""


## Export all frames from a single animation.
static func export_animation(
	shapes: Array,
	body_parts: Dictionary,
	animation: AnimationData,
	output_dir: String,
	character_name: String,
	direction_name: String = "",
	canvas_size: int = 64,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> FrameExportResult:
	var result := FrameExportResult.new()
	result.output_directory = output_dir

	if not animation.is_generated or animation.generated_frames.is_empty():
		result.success = false
		result.errors.append("Animation '%s' has no generated frames" % animation.animation_name)
		return result

	# Ensure output directory exists
	var err := DirAccess.make_dir_recursive_absolute(output_dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		result.success = false
		result.errors.append("Failed to create output directory: %s" % error_string(err))
		return result

	# Render all frames
	var frames := FrameRenderer.render_animation_frames(
		shapes,
		body_parts,
		animation,
		canvas_size,
		scale,
		background,
		background_color
	)

	# Save each frame
	for i in range(frames.size()):
		var filename := _generate_filename(character_name, direction_name, animation.animation_name, i)
		var filepath := output_dir.path_join(filename)

		var save_err := frames[i].save_png(filepath)
		if save_err != OK:
			result.success = false
			result.errors.append("Failed to save frame %d: %s" % [i, error_string(save_err)])
		else:
			result.files_exported += 1

	return result


## Export all animations for a character.
static func export_all_animations(
	shapes: Array,
	body_parts: Dictionary,
	animations: Array[AnimationData],
	output_dir: String,
	character_name: String,
	direction_name: String = "",
	canvas_size: int = 64,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> FrameExportResult:
	var result := FrameExportResult.new()
	result.output_directory = output_dir

	for animation in animations:
		if not animation.is_generated or animation.generated_frames.is_empty():
			continue

		var anim_result := export_animation(
			shapes,
			body_parts,
			animation,
			output_dir,
			character_name,
			direction_name,
			canvas_size,
			scale,
			background,
			background_color
		)

		result.files_exported += anim_result.files_exported
		result.errors.append_array(anim_result.errors)
		if not anim_result.success:
			result.success = false

	return result


## Export all directions and animations.
static func export_all_directions(
	direction_views: Dictionary,  # direction_key -> DirectionView
	body_parts_per_direction: Dictionary,  # direction_key -> body_parts Dictionary
	animations: Array[AnimationData],
	output_dir: String,
	character_name: String,
	canvas_size: int = 64,
	scale: int = 1,
	background: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT,
	background_color: Color = Color.TRANSPARENT
) -> FrameExportResult:
	var result := FrameExportResult.new()
	result.output_directory = output_dir

	for dir_key in direction_views:
		var view: DirectionView = direction_views[dir_key]
		if not view or not view.is_configured:
			continue

		var dir_body_parts: Dictionary = body_parts_per_direction.get(dir_key, {})

		var dir_result := export_all_animations(
			view.shapes,
			dir_body_parts,
			animations,
			output_dir,
			character_name,
			dir_key,
			canvas_size,
			scale,
			background,
			background_color
		)

		result.files_exported += dir_result.files_exported
		result.errors.append_array(dir_result.errors)
		if not dir_result.success:
			result.success = false

	return result


## Generate a filename for a frame.
## Format: {character}_{direction}_{animation}_{frame:03d}.png
static func _generate_filename(
	character_name: String,
	direction_name: String,
	animation_name: String,
	frame_index: int
) -> String:
	# Sanitize names for filesystem
	var safe_char := _sanitize_filename(character_name)
	var safe_dir := _sanitize_filename(direction_name)
	var safe_anim := _sanitize_filename(animation_name)

	# Build filename with zero-padded frame number
	var frame_str := "%03d" % (frame_index + 1)  # 1-indexed for user clarity

	if safe_dir.is_empty():
		return "%s_%s_%s.png" % [safe_char, safe_anim, frame_str]
	else:
		return "%s_%s_%s_%s.png" % [safe_char, safe_dir, safe_anim, frame_str]


## Sanitize a string for use in filenames.
static func _sanitize_filename(name: String) -> String:
	if name.is_empty():
		return ""

	# Convert to lowercase and replace spaces with underscores
	var result := name.to_lower().replace(" ", "_")

	# Remove any characters that aren't alphanumeric, underscore, or hyphen
	var sanitized := ""
	for c in result:
		if c.is_valid_identifier() or c == "-":
			sanitized += c

	return sanitized


## Get expected file count for export planning.
static func count_expected_files(
	animations: Array[AnimationData],
	direction_count: int = 1
) -> int:
	var frame_count := 0
	for anim in animations:
		if anim.is_generated and not anim.generated_frames.is_empty():
			frame_count += anim.generated_frames.size()

	return frame_count * max(1, direction_count)


## Get list of filenames that would be generated.
static func get_expected_filenames(
	animations: Array[AnimationData],
	character_name: String,
	direction_names: Array[String] = []
) -> Array[String]:
	var filenames: Array[String] = []

	if direction_names.is_empty():
		direction_names = [""]

	for dir_name in direction_names:
		for anim in animations:
			if not anim.is_generated or anim.generated_frames.is_empty():
				continue

			for i in range(anim.generated_frames.size()):
				filenames.append(_generate_filename(character_name, dir_name, anim.animation_name, i))

	return filenames
