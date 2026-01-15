@tool
extends Resource
class_name ShapeGroup
## A reusable group of shapes that can be saved and loaded from the Shape Library.
## Shape groups allow users to save commonly used shape combinations (armor, weapons, etc.)
## and quickly add them to new characters.

## The display name of this shape group.
@export var group_name: String = ""

## The category this group belongs to (body, armor, weapons, accessories).
@export_enum("body", "armor", "weapons", "accessories", "custom") var category: String = "custom"

## Description of the shape group.
@export_multiline var description: String = ""

## The shapes in this group (Array of shape dictionaries).
@export var shapes: Array = []

## Original canvas size this group was created for (used for scaling).
@export var source_canvas_size: int = 64

## Preview image for the library browser (generated when saving).
@export var preview_image: Texture2D = null

## Creation timestamp.
@export var created_at: String = ""

## Author name (optional).
@export var author: String = ""

## Tags for searching/filtering.
@export var tags: PackedStringArray = []


func _init(p_name: String = "", p_category: String = "custom") -> void:
	group_name = p_name
	category = p_category
	created_at = Time.get_datetime_string_from_system()


## Create a ShapeGroup from selected shapes on a canvas.
static func from_shapes(p_shapes: Array, p_name: String, p_category: String = "custom", p_canvas_size: int = 64) -> ShapeGroup:
	var group := ShapeGroup.new(p_name, p_category)
	group.source_canvas_size = p_canvas_size

	# Deep copy shapes and normalize positions relative to bounds
	var bounds := _calculate_bounds(p_shapes)

	for shape in p_shapes:
		var normalized_shape: Dictionary = shape.duplicate(true)
		# Store original position for now (will be offset when inserting)
		group.shapes.append(normalized_shape)

	return group


## Calculate the bounding box of a set of shapes.
static func _calculate_bounds(p_shapes: Array) -> Rect2:
	if p_shapes.is_empty():
		return Rect2()

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for shape in p_shapes:
		var pos := Vector2(shape.position[0], shape.position[1])
		var size_vec := Vector2(shape.size[0], shape.size[1])

		min_pos.x = minf(min_pos.x, pos.x)
		min_pos.y = minf(min_pos.y, pos.y)
		max_pos.x = maxf(max_pos.x, pos.x + size_vec.x)
		max_pos.y = maxf(max_pos.y, pos.y + size_vec.y)

	return Rect2(min_pos, max_pos - min_pos)


## Get the bounding box of all shapes in this group.
func get_bounds() -> Rect2:
	return _calculate_bounds(shapes)


## Get shapes scaled and offset for a target canvas size and position.
func get_shapes_for_canvas(target_canvas_size: int, offset: Vector2 = Vector2.ZERO) -> Array:
	var result: Array = []
	var scale_factor: float = float(target_canvas_size) / float(source_canvas_size)

	for shape in shapes:
		var new_shape: Dictionary = shape.duplicate(true)

		# Scale position
		new_shape.position = [
			shape.position[0] * scale_factor + offset.x,
			shape.position[1] * scale_factor + offset.y
		]

		# Scale size
		new_shape.size = [
			shape.size[0] * scale_factor,
			shape.size[1] * scale_factor
		]

		result.append(new_shape)

	return result


## Get the center position of all shapes.
func get_center() -> Vector2:
	var bounds := get_bounds()
	return bounds.position + bounds.size / 2.0


## Save this shape group to a file.
func save_to_file(path: String) -> Error:
	return ResourceSaver.save(self, path)


## Load a shape group from a file.
static func load_from_file(path: String) -> ShapeGroup:
	if not FileAccess.file_exists(path):
		return null
	return load(path) as ShapeGroup


## Convert to dictionary for JSON serialization.
func to_dict() -> Dictionary:
	return {
		"group_name": group_name,
		"category": category,
		"description": description,
		"shapes": shapes.duplicate(true),
		"source_canvas_size": source_canvas_size,
		"created_at": created_at,
		"author": author,
		"tags": Array(tags)
	}


## Create from dictionary.
static func from_dict(data: Dictionary) -> ShapeGroup:
	var group := ShapeGroup.new()
	group.group_name = data.get("group_name", "")
	group.category = data.get("category", "custom")
	group.description = data.get("description", "")
	group.shapes = data.get("shapes", []).duplicate(true)
	group.source_canvas_size = data.get("source_canvas_size", 64)
	group.created_at = data.get("created_at", "")
	group.author = data.get("author", "")
	group.tags = PackedStringArray(data.get("tags", []))
	return group
