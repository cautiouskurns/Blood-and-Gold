@tool
extends RefCounted
class_name BodyPart
## Body part data class for the Character Assembler.
## Represents a single body part with shapes, pivot point, and parent reference.

# Standard body part names (14 parts)
const PART_NAMES := [
	"Head",
	"Torso",
	"L Upper Arm",
	"L Lower Arm",
	"L Hand",
	"R Upper Arm",
	"R Lower Arm",
	"R Hand",
	"L Upper Leg",
	"L Lower Leg",
	"L Foot",
	"R Upper Leg",
	"R Lower Leg",
	"R Foot",
]

# Default parent relationships
const DEFAULT_PARENTS := {
	"Head": "Torso",
	"Torso": "",  # Root
	"L Upper Arm": "Torso",
	"L Lower Arm": "L Upper Arm",
	"L Hand": "L Lower Arm",
	"R Upper Arm": "Torso",
	"R Lower Arm": "R Upper Arm",
	"R Hand": "R Lower Arm",
	"L Upper Leg": "Torso",
	"L Lower Leg": "L Upper Leg",
	"L Foot": "L Lower Leg",
	"R Upper Leg": "Torso",
	"R Lower Leg": "R Upper Leg",
	"R Foot": "R Lower Leg",
}

# Default pivot point descriptions (for UI hints)
const PIVOT_HINTS := {
	"Head": "neck",
	"Torso": "waist/center",
	"L Upper Arm": "left shoulder",
	"L Lower Arm": "left elbow",
	"L Hand": "left wrist",
	"R Upper Arm": "right shoulder",
	"R Lower Arm": "right elbow",
	"R Hand": "right wrist",
	"L Upper Leg": "left hip",
	"L Lower Leg": "left knee",
	"L Foot": "left ankle",
	"R Upper Leg": "right hip",
	"R Lower Leg": "right knee",
	"R Foot": "right ankle",
}

# Body part properties
var part_name: String = ""
var shape_indices: Array[int] = []  # Indices of shapes belonging to this body part
var pivot: Vector2 = Vector2.ZERO  # Pivot point in canvas coordinates
var pivot_set: bool = false  # Whether pivot has been explicitly set
var parent_name: String = ""  # Name of parent body part (empty for root)


func _init(name: String = "") -> void:
	part_name = name
	if name in DEFAULT_PARENTS:
		parent_name = DEFAULT_PARENTS[name]


## Add a shape index to this body part.
func add_shape(index: int) -> void:
	if index not in shape_indices:
		shape_indices.append(index)


## Remove a shape index from this body part.
func remove_shape(index: int) -> void:
	shape_indices.erase(index)


## Check if this body part has any shapes.
func has_shapes() -> bool:
	return not shape_indices.is_empty()


## Check if this body part is fully configured.
func is_complete() -> bool:
	return has_shapes() and pivot_set


## Get the number of shapes in this body part.
func get_shape_count() -> int:
	return shape_indices.size()


## Set the pivot point.
func set_pivot(pos: Vector2) -> void:
	pivot = pos
	pivot_set = true


## Clear the pivot point.
func clear_pivot() -> void:
	pivot = Vector2.ZERO
	pivot_set = false


## Convert to dictionary for serialization.
func to_dict() -> Dictionary:
	return {
		"name": part_name,
		"shapes": shape_indices.duplicate(),
		"pivot": [pivot.x, pivot.y],
		"pivot_set": pivot_set,
		"parent": parent_name,
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> BodyPart:
	var part = BodyPart.new(data.get("name", ""))

	var shapes = data.get("shapes", [])
	for idx in shapes:
		part.shape_indices.append(int(idx))

	var pivot_arr = data.get("pivot", [0, 0])
	part.pivot = Vector2(pivot_arr[0], pivot_arr[1])
	part.pivot_set = data.get("pivot_set", false)
	part.parent_name = data.get("parent", "")

	return part


## Get the default parent for a body part name.
static func get_default_parent(name: String) -> String:
	return DEFAULT_PARENTS.get(name, "")


## Get the pivot hint for a body part name.
static func get_pivot_hint(name: String) -> String:
	return PIVOT_HINTS.get(name, "center")


## Check if a name is a valid body part name.
static func is_valid_part_name(name: String) -> bool:
	return name in PART_NAMES


## Get all children of a body part.
static func get_children(parent_name: String) -> Array[String]:
	var children: Array[String] = []
	for part_name in PART_NAMES:
		if DEFAULT_PARENTS.get(part_name, "") == parent_name:
			children.append(part_name)
	return children
