@tool
extends RefCounted
class_name DirectionView
## Data class for a single direction view of a character.
## Each direction can have its own shapes, body parts, pivots, and poses.

## Direction enum for the 4 cardinal directions.
enum Direction {
	SOUTH,  # Front view - primary
	NORTH,  # Back view
	EAST,   # Right side view
	WEST    # Left side view
}

## Direction names for display.
const DIRECTION_NAMES := {
	Direction.SOUTH: "South",
	Direction.NORTH: "North",
	Direction.EAST: "East",
	Direction.WEST: "West"
}

## Direction descriptions for UI.
const DIRECTION_DESCRIPTIONS := {
	Direction.SOUTH: "Front View - Primary",
	Direction.NORTH: "Back View",
	Direction.EAST: "Right Side View",
	Direction.WEST: "Left Side View"
}

## The direction this view represents.
var direction: Direction = Direction.SOUTH

## Whether this direction has been configured (has shape data).
var is_configured: bool = false

## Whether this was auto-generated (vs manually created).
var is_auto_generated: bool = false

## Source direction if auto-generated (e.g., "south" for auto-generated west).
var source_direction: String = ""

## Shape data for this direction (same format as CharacterProject.shapes).
var shapes: Array = []

## Body part data for this direction (same format as CharacterProject.body_parts).
var body_parts: Dictionary = {}

## Pose overrides for this direction (pose_name -> rotations Dictionary).
## If empty, uses the base poses.
var pose_overrides: Dictionary = {}


func _init(p_direction: Direction = Direction.SOUTH) -> void:
	direction = p_direction


## Get the direction name for display.
func get_name() -> String:
	return DIRECTION_NAMES.get(direction, "Unknown")


## Get the direction description.
func get_description() -> String:
	return DIRECTION_DESCRIPTIONS.get(direction, "")


## Get the direction key (lowercase string).
func get_key() -> String:
	return get_name().to_lower()


## Check if this view has any shape data.
func has_shapes() -> bool:
	return not shapes.is_empty()


## Check if this view has body parts configured.
func has_body_parts() -> bool:
	return not body_parts.is_empty()


## Check if this view has pose overrides.
func has_pose_overrides() -> bool:
	return not pose_overrides.is_empty()


## Copy shape data from another direction view.
func copy_shapes_from(other: DirectionView) -> void:
	shapes = other.shapes.duplicate(true)
	is_configured = other.is_configured


## Copy body parts from another direction view.
func copy_body_parts_from(other: DirectionView) -> void:
	body_parts = other.body_parts.duplicate(true)


## Copy poses from another direction view.
func copy_poses_from(other: DirectionView) -> void:
	pose_overrides = other.pose_overrides.duplicate(true)


## Copy all data from another direction view.
func copy_all_from(other: DirectionView) -> void:
	copy_shapes_from(other)
	copy_body_parts_from(other)
	copy_poses_from(other)
	source_direction = other.get_key()


## Clear all data.
func clear() -> void:
	shapes.clear()
	body_parts.clear()
	pose_overrides.clear()
	is_configured = false
	is_auto_generated = false
	source_direction = ""


## Convert to dictionary for serialization.
func to_dict() -> Dictionary:
	return {
		"direction": direction,
		"is_configured": is_configured,
		"is_auto_generated": is_auto_generated,
		"source_direction": source_direction,
		"shapes": shapes.duplicate(true),
		"body_parts": body_parts.duplicate(true),
		"pose_overrides": pose_overrides.duplicate(true)
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> DirectionView:
	var view = DirectionView.new()
	view.direction = data.get("direction", Direction.SOUTH)
	view.is_configured = data.get("is_configured", false)
	view.is_auto_generated = data.get("is_auto_generated", false)
	view.source_direction = data.get("source_direction", "")
	view.shapes = data.get("shapes", []).duplicate(true)
	view.body_parts = data.get("body_parts", {}).duplicate(true)
	view.pose_overrides = data.get("pose_overrides", {}).duplicate(true)
	return view


## Get direction from string key.
static func direction_from_key(key: String) -> Direction:
	match key.to_lower():
		"south": return Direction.SOUTH
		"north": return Direction.NORTH
		"east": return Direction.EAST
		"west": return Direction.WEST
		_: return Direction.SOUTH


## Get all directions in order.
static func get_all_directions() -> Array[Direction]:
	return [Direction.SOUTH, Direction.NORTH, Direction.EAST, Direction.WEST]


## Get direction name from enum.
static func get_direction_name(dir: Direction) -> String:
	return DIRECTION_NAMES.get(dir, "Unknown")
