@tool
extends RefCounted
class_name CharacterProject
## Data class for a character assembler project.
## Contains all shapes, body parts, poses, and animations for a character.

# Project metadata
var character_id: String = ""
var version: String = "1.0"
var canvas_size: int = 64
var reference_image_path: String = ""
var reference_opacity: float = 0.5

# Shape data - Array of Shape dictionaries
# Each shape: { type, position, size, color, rotation, layer }
var shapes: Array = []

# Body part data - Dictionary of body_part_name -> BodyPart dictionary
# Each body part: { name, shapes (indices), pivot, parent }
var body_parts: Dictionary = {}

# Pose data - Array of pose dictionaries
# Each pose: { pose_name, rotations (body_part_name -> degrees), description }
var poses: Array = []

# Animation data - Dictionary of animation_name -> Animation dictionary
# Each animation: { name, template, frames, fps, loop, pose_assignments }
var animations: Dictionary = {}

# Direction variants - Array of direction names that have been created
var directions: Array = ["south"]  # Start with south as primary

# Direction view data - Dictionary of direction_key -> DirectionView dictionary
# Each view stores shapes, body_parts, and pose_overrides for that direction
var direction_views: Dictionary = {}

# File format version for compatibility
const FILE_VERSION := 2  # Updated for direction views support


## Create a new shape and add it to the project.
## Returns the index of the new shape.
func add_shape(type: String, position: Vector2, size: Vector2, color: Color, rotation: float = 0.0) -> int:
	var shape = {
		"type": type,
		"position": [position.x, position.y],
		"size": [size.x, size.y],
		"color": [color.r, color.g, color.b, color.a],
		"rotation": rotation,
		"layer": shapes.size()  # Default layer is insertion order
	}
	shapes.append(shape)
	return shapes.size() - 1


## Remove a shape by index.
func remove_shape(index: int) -> void:
	if index >= 0 and index < shapes.size():
		shapes.remove_at(index)
		# Update body part shape references
		for part_name in body_parts:
			var part = body_parts[part_name]
			var new_shapes = []
			for shape_idx in part.shapes:
				if shape_idx < index:
					new_shapes.append(shape_idx)
				elif shape_idx > index:
					new_shapes.append(shape_idx - 1)
				# Skip if shape_idx == index (removed)
			part.shapes = new_shapes


## Get a shape by index.
func get_shape(index: int) -> Dictionary:
	if index >= 0 and index < shapes.size():
		return shapes[index]
	return {}


## Update a shape's properties.
func update_shape(index: int, properties: Dictionary) -> void:
	if index >= 0 and index < shapes.size():
		for key in properties:
			if key in shapes[index]:
				shapes[index][key] = properties[key]


## Create or update a body part.
## The pivot_set parameter indicates whether the pivot was explicitly set by the user.
func set_body_part(name: String, shape_indices: Array, pivot: Vector2, parent: String = "", pivot_set: bool = true) -> void:
	body_parts[name] = {
		"name": name,
		"shapes": shape_indices,
		"pivot": [pivot.x, pivot.y],
		"pivot_set": pivot_set,
		"parent": parent
	}


## Get a body part by name.
func get_body_part(name: String) -> Dictionary:
	return body_parts.get(name, {})


## Remove a body part.
func remove_body_part(name: String) -> void:
	body_parts.erase(name)


## Add a pose to the list.
func add_pose(name: String, rotations: Dictionary, description: String = "") -> void:
	poses.append({
		"pose_name": name,
		"rotations": rotations.duplicate(),
		"description": description
	})


## Get a pose by name.
func get_pose(name: String) -> Dictionary:
	for pose in poses:
		if pose.get("pose_name", "") == name:
			return pose
	return {}


## Remove a pose by name.
func remove_pose(name: String) -> void:
	for i in range(poses.size() - 1, -1, -1):
		if poses[i].get("pose_name", "") == name:
			poses.remove_at(i)
			break


## Create or update an animation.
func set_animation(name: String, template: String, frames: int, fps: int, loop: bool, pose_assignments: Dictionary) -> void:
	animations[name] = {
		"name": name,
		"template": template,
		"frames": frames,
		"fps": fps,
		"loop": loop,
		"pose_assignments": pose_assignments.duplicate()
	}


## Get an animation by name.
func get_animation(name: String) -> Dictionary:
	return animations.get(name, {})


## Remove an animation.
func remove_animation(name: String) -> void:
	animations.erase(name)


## Get the standard body parts hierarchy.
static func get_standard_body_parts() -> Array:
	return [
		{"name": "Head", "default_parent": "Torso"},
		{"name": "Torso", "default_parent": ""},  # Root
		{"name": "L Upper Arm", "default_parent": "Torso"},
		{"name": "L Lower Arm", "default_parent": "L Upper Arm"},
		{"name": "L Hand", "default_parent": "L Lower Arm"},
		{"name": "R Upper Arm", "default_parent": "Torso"},
		{"name": "R Lower Arm", "default_parent": "R Upper Arm"},
		{"name": "R Hand", "default_parent": "R Lower Arm"},
		{"name": "L Upper Leg", "default_parent": "Torso"},
		{"name": "L Lower Leg", "default_parent": "L Upper Leg"},
		{"name": "L Foot", "default_parent": "L Lower Leg"},
		{"name": "R Upper Leg", "default_parent": "Torso"},
		{"name": "R Lower Leg", "default_parent": "R Upper Leg"},
		{"name": "R Foot", "default_parent": "R Lower Leg"},
	]


## Convert to a saveable dictionary.
func to_dict() -> Dictionary:
	return {
		"file_version": FILE_VERSION,
		"character_id": character_id,
		"version": version,
		"canvas_size": canvas_size,
		"reference_image_path": reference_image_path,
		"reference_opacity": reference_opacity,
		"shapes": shapes.duplicate(true),
		"body_parts": body_parts.duplicate(true),
		"poses": poses.duplicate(true),
		"animations": animations.duplicate(true),
		"directions": directions.duplicate(),
		"direction_views": direction_views.duplicate(true)
	}


## Load from a dictionary.
func from_dict(data: Dictionary) -> void:
	character_id = data.get("character_id", "")
	version = data.get("version", "1.0")
	canvas_size = data.get("canvas_size", 64)
	reference_image_path = data.get("reference_image_path", "")
	reference_opacity = data.get("reference_opacity", 0.5)
	shapes = data.get("shapes", []).duplicate(true)
	body_parts = data.get("body_parts", {}).duplicate(true)
	poses = data.get("poses", []).duplicate(true)
	animations = data.get("animations", {}).duplicate(true)
	directions = data.get("directions", ["south"]).duplicate()
	direction_views = data.get("direction_views", {}).duplicate(true)

	# Migrate old format: if no direction_views but has shapes, create south view
	if direction_views.is_empty() and not shapes.is_empty():
		direction_views["south"] = {
			"direction": DirectionView.Direction.SOUTH,
			"is_configured": true,
			"is_auto_generated": false,
			"source_direction": "",
			"shapes": shapes.duplicate(true),
			"body_parts": body_parts.duplicate(true),
			"pose_overrides": {}
		}


## Save the project to a file.
func save_to_file(path: String) -> int:
	var data = to_dict()
	var json_string = JSON.stringify(data, "\t")

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(json_string)
	file.close()
	return OK


## Load a project from a file.
static func load_from_file(path: String) -> CharacterProject:
	if not FileAccess.file_exists(path):
		push_error("CharacterProject: File not found: %s" % path)
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("CharacterProject: Could not open file: %s" % path)
		return null

	var json_string = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if data == null:
		push_error("CharacterProject: Invalid JSON in file: %s" % path)
		return null

	var project = CharacterProject.new()
	project.from_dict(data)
	return project


## Get the file filter for file dialogs.
static func get_file_filter() -> String:
	return "*.charproj ; Character Project"


## Get character ID from a file path.
static func get_character_id_from_path(path: String) -> String:
	return path.get_file().get_basename()


# =============================================================================
# DIRECTION VIEW METHODS
# =============================================================================

## Set the direction view data for a specific direction.
func set_direction_view(direction_key: String, view_data: Dictionary) -> void:
	direction_views[direction_key] = view_data.duplicate(true)
	if direction_key not in directions:
		directions.append(direction_key)


## Get the direction view data for a specific direction.
func get_direction_view(direction_key: String) -> Dictionary:
	return direction_views.get(direction_key, {})


## Check if a direction has been configured.
func has_direction(direction_key: String) -> bool:
	return direction_key in direction_views and not direction_views[direction_key].is_empty()


## Get shapes for a specific direction.
func get_direction_shapes(direction_key: String) -> Array:
	var view := get_direction_view(direction_key)
	return view.get("shapes", [])


## Get body parts for a specific direction.
func get_direction_body_parts(direction_key: String) -> Dictionary:
	var view := get_direction_view(direction_key)
	return view.get("body_parts", {})


## Remove a direction view.
func remove_direction_view(direction_key: String) -> void:
	direction_views.erase(direction_key)
	directions.erase(direction_key)


## Get all configured direction keys.
func get_configured_directions() -> Array:
	var configured: Array = []
	for key in direction_views:
		var view: Dictionary = direction_views[key]
		if view.get("is_configured", false):
			configured.append(key)
	return configured


## Sync the primary (south) direction with the main shapes/body_parts.
## Call this when shapes are edited to keep the south view in sync.
func sync_primary_direction() -> void:
	direction_views["south"] = {
		"direction": DirectionView.Direction.SOUTH,
		"is_configured": not shapes.is_empty(),
		"is_auto_generated": false,
		"source_direction": "",
		"shapes": shapes.duplicate(true),
		"body_parts": body_parts.duplicate(true),
		"pose_overrides": {}
	}
	if "south" not in directions:
		directions.insert(0, "south")
