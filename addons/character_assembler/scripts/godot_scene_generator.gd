@tool
extends RefCounted
class_name GodotSceneGenerator
## Generates Godot AnimatedSprite2D scenes from sprite sheet data.
## Creates .tscn files with SpriteFrames resource configured.

## Result of scene generation.
class SceneGenerationResult:
	var success: bool
	var scene_path: String
	var sprite_frames_path: String
	var errors: Array[String]

	func _init() -> void:
		success = true
		scene_path = ""
		sprite_frames_path = ""
		errors = []


## Generate an AnimatedSprite2D scene from a sprite sheet.
static func generate_scene(
	sprite_sheet_result: SpriteSheetGenerator.SpriteSheetResult,
	sprite_sheet_path: String,
	output_dir: String,
	character_name: String
) -> SceneGenerationResult:
	var result := SceneGenerationResult.new()

	if sprite_sheet_result.image == null:
		result.success = false
		result.errors.append("Sprite sheet result has no image")
		return result

	# Ensure output directory exists
	var err := DirAccess.make_dir_recursive_absolute(output_dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		result.success = false
		result.errors.append("Failed to create output directory: %s" % error_string(err))
		return result

	# Generate file paths
	var safe_name := _sanitize_name(character_name)
	result.sprite_frames_path = output_dir.path_join("%s.tres" % safe_name)
	result.scene_path = output_dir.path_join("%s.tscn" % safe_name)

	# Create and save SpriteFrames resource
	var sprite_frames := _create_sprite_frames(sprite_sheet_result, sprite_sheet_path)
	var save_err := ResourceSaver.save(sprite_frames, result.sprite_frames_path)
	if save_err != OK:
		result.success = false
		result.errors.append("Failed to save SpriteFrames: %s" % error_string(save_err))
		return result

	# Generate the scene file
	var scene_content := _generate_scene_content(safe_name, result.sprite_frames_path)
	var file := FileAccess.open(result.scene_path, FileAccess.WRITE)
	if file == null:
		result.success = false
		result.errors.append("Failed to create scene file: %s" % error_string(FileAccess.get_open_error()))
		return result

	file.store_string(scene_content)
	file.close()

	return result


## Create a SpriteFrames resource from sprite sheet data.
static func _create_sprite_frames(
	sheet_result: SpriteSheetGenerator.SpriteSheetResult,
	sprite_sheet_path: String
) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()

	# Load the sprite sheet texture
	var texture: Texture2D = null
	if ResourceLoader.exists(sprite_sheet_path):
		texture = load(sprite_sheet_path)
	else:
		# Create AtlasTexture will fail without the texture, but we generate the structure
		push_warning("Sprite sheet not yet loaded: %s" % sprite_sheet_path)

	# Remove default animation if it exists
	if sprite_frames.has_animation(&"default"):
		sprite_frames.remove_animation(&"default")

	# Create animations from sheet result
	for anim_name in sheet_result.animations:
		var anim_data: Dictionary = sheet_result.animations[anim_name]

		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, anim_data.get("fps", 12.0))
		sprite_frames.set_animation_loop(anim_name, anim_data.get("loop", true))

		# Add frames as AtlasTextures
		var row: int = anim_data.row
		var start_col: int = anim_data.start_col
		var frame_count: int = anim_data.frame_count

		for frame_idx in range(frame_count):
			var col := start_col + frame_idx
			var atlas := AtlasTexture.new()

			if texture:
				atlas.atlas = texture

			atlas.region = Rect2(
				col * sheet_result.frame_size.x,
				row * sheet_result.frame_size.y,
				sheet_result.frame_size.x,
				sheet_result.frame_size.y
			)

			sprite_frames.add_frame(anim_name, atlas)

	return sprite_frames


## Generate .tscn file content.
static func _generate_scene_content(node_name: String, sprite_frames_path: String) -> String:
	# Convert absolute path to res:// path if possible
	var res_path := sprite_frames_path
	if res_path.begins_with(ProjectSettings.globalize_path("res://")):
		res_path = "res://" + res_path.substr(ProjectSettings.globalize_path("res://").length())
	elif not res_path.begins_with("res://"):
		# Try to make it relative to project
		var project_path := ProjectSettings.globalize_path("res://")
		if res_path.begins_with(project_path):
			res_path = "res://" + res_path.substr(project_path.length())

	var content := """[gd_scene load_steps=2 format=3]

[ext_resource type="SpriteFrames" path="%s" id="1_sprite_frames"]

[node name="%s" type="AnimatedSprite2D"]
sprite_frames = ExtResource("1_sprite_frames")
""" % [res_path, node_name.to_pascal_case()]

	return content


## Generate a scene with individual frame textures instead of sprite sheet.
static func generate_scene_from_frames(
	animations: Array[AnimationData],
	frame_directory: String,
	character_name: String,
	direction_name: String,
	output_dir: String
) -> SceneGenerationResult:
	var result := SceneGenerationResult.new()

	# Ensure output directory exists
	var err := DirAccess.make_dir_recursive_absolute(output_dir)
	if err != OK and err != ERR_ALREADY_EXISTS:
		result.success = false
		result.errors.append("Failed to create output directory: %s" % error_string(err))
		return result

	var safe_name := _sanitize_name(character_name)
	if not direction_name.is_empty():
		safe_name = "%s_%s" % [safe_name, _sanitize_name(direction_name)]

	result.sprite_frames_path = output_dir.path_join("%s.tres" % safe_name)
	result.scene_path = output_dir.path_join("%s.tscn" % safe_name)

	# Create SpriteFrames from individual frames
	var sprite_frames := SpriteFrames.new()

	# Remove default animation
	if sprite_frames.has_animation(&"default"):
		sprite_frames.remove_animation(&"default")

	for anim in animations:
		if not anim.is_generated or anim.generated_frames.is_empty():
			continue

		sprite_frames.add_animation(anim.animation_name)
		sprite_frames.set_animation_speed(anim.animation_name, anim.fps)
		sprite_frames.set_animation_loop(anim.animation_name, anim.loop)

		# Add frames
		for i in range(anim.generated_frames.size()):
			var filename := FrameExporter._generate_filename(
				character_name, direction_name, anim.animation_name, i
			)
			var frame_path := frame_directory.path_join(filename)

			# Convert to res:// path
			var res_frame_path := _to_res_path(frame_path)

			if ResourceLoader.exists(res_frame_path):
				var texture := load(res_frame_path)
				sprite_frames.add_frame(anim.animation_name, texture)
			else:
				# Create placeholder reference
				var texture := PlaceholderTexture2D.new()
				sprite_frames.add_frame(anim.animation_name, texture)

	# Save SpriteFrames
	var save_err := ResourceSaver.save(sprite_frames, result.sprite_frames_path)
	if save_err != OK:
		result.success = false
		result.errors.append("Failed to save SpriteFrames: %s" % error_string(save_err))
		return result

	# Generate scene file
	var scene_content := _generate_scene_content(safe_name, result.sprite_frames_path)
	var file := FileAccess.open(result.scene_path, FileAccess.WRITE)
	if file == null:
		result.success = false
		result.errors.append("Failed to create scene file: %s" % error_string(FileAccess.get_open_error()))
		return result

	file.store_string(scene_content)
	file.close()

	return result


## Convert absolute path to res:// path.
static func _to_res_path(absolute_path: String) -> String:
	if absolute_path.begins_with("res://"):
		return absolute_path

	var project_path := ProjectSettings.globalize_path("res://")
	if absolute_path.begins_with(project_path):
		return "res://" + absolute_path.substr(project_path.length())

	return absolute_path


## Sanitize a name for use as a node/file name.
static func _sanitize_name(name: String) -> String:
	if name.is_empty():
		return "character"

	var result := name.to_lower().replace(" ", "_")
	var sanitized := ""
	for c in result:
		if c.is_valid_identifier() or c == "-":
			sanitized += c

	return sanitized if not sanitized.is_empty() else "character"


## Generate export metadata JSON.
static func generate_metadata_json(
	sheet_result: SpriteSheetGenerator.SpriteSheetResult,
	character_name: String,
	canvas_size: int,
	scale: int,
	output_path: String
) -> Error:
	var metadata := {
		"character_name": character_name,
		"canvas_size": canvas_size,
		"scale": scale,
		"frame_size": [sheet_result.frame_size.x, sheet_result.frame_size.y],
		"grid_size": [sheet_result.grid_size.x, sheet_result.grid_size.y],
		"total_frames": sheet_result.total_frames,
		"animations": {}
	}

	for anim_name in sheet_result.animations:
		var anim_data: Dictionary = sheet_result.animations[anim_name]
		metadata.animations[anim_name] = {
			"row": anim_data.row,
			"start_col": anim_data.start_col,
			"frame_count": anim_data.frame_count,
			"fps": anim_data.get("fps", 12.0),
			"loop": anim_data.get("loop", true)
		}

	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(metadata, "\t"))
	file.close()

	return OK
