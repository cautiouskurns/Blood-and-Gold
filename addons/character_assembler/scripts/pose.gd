@tool
extends Resource
class_name Pose
## Represents a character pose with rotation values for each body part.

## The name of the pose (e.g., "Idle", "Walk_Left")
@export var pose_name: String = ""

## Dictionary mapping body part name -> rotation in degrees
@export var rotations: Dictionary = {}

## Optional description for the pose
@export var description: String = ""


func _init(p_name: String = "", p_rotations: Dictionary = {}) -> void:
	pose_name = p_name
	rotations = p_rotations.duplicate()


## Get rotation for a specific body part (defaults to 0 if not set).
func get_rotation(part_name: String) -> float:
	return rotations.get(part_name, 0.0)


## Set rotation for a specific body part.
func set_rotation(part_name: String, degrees: float) -> void:
	rotations[part_name] = degrees


## Reset a specific body part rotation to 0.
func reset_part(part_name: String) -> void:
	rotations[part_name] = 0.0


## Reset all rotations to 0.
func reset_all() -> void:
	for part_name in rotations.keys():
		rotations[part_name] = 0.0


## Create a duplicate of this pose with a new name.
func duplicate_pose(new_name: String) -> Pose:
	var new_pose = Pose.new(new_name, rotations.duplicate())
	new_pose.description = description
	return new_pose


## Create a mirrored version of this pose (swap L/R rotations).
func mirror() -> void:
	var new_rotations: Dictionary = {}

	for part_name in rotations.keys():
		var rotation_value = rotations[part_name]
		var mirrored_name = _get_mirrored_part_name(part_name)

		# Mirror the rotation value (negate for left/right swap)
		if mirrored_name != part_name:
			new_rotations[mirrored_name] = -rotation_value
		else:
			# Center parts (Head, Torso) keep their rotation
			new_rotations[part_name] = rotation_value

	rotations = new_rotations


## Get the mirrored body part name (L <-> R).
func _get_mirrored_part_name(part_name: String) -> String:
	if part_name.begins_with("L "):
		return "R " + part_name.substr(2)
	elif part_name.begins_with("R "):
		return "L " + part_name.substr(2)
	return part_name


## Create a mirrored copy of this pose.
func create_mirrored_copy(new_name: String) -> Pose:
	var mirrored = duplicate_pose(new_name)
	mirrored.mirror()
	return mirrored


## Convert to dictionary for serialization.
func to_dict() -> Dictionary:
	return {
		"pose_name": pose_name,
		"rotations": rotations.duplicate(),
		"description": description
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> Pose:
	var pose = Pose.new()
	pose.pose_name = data.get("pose_name", "")
	pose.rotations = data.get("rotations", {}).duplicate()
	pose.description = data.get("description", "")
	return pose


## Check if this pose has any non-zero rotations.
func has_rotations() -> bool:
	for part_name in rotations:
		if abs(rotations[part_name]) > 0.01:
			return true
	return false


## Get a summary string of the pose.
func get_summary() -> String:
	var non_zero_count := 0
	for part_name in rotations:
		if abs(rotations[part_name]) > 0.01:
			non_zero_count += 1
	return "%s (%d rotations)" % [pose_name, non_zero_count]
