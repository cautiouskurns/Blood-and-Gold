@tool
extends Command
class_name ModifyShapeCommand
## Command for modifying shape properties (size, color, rotation, layer).
## Stores the complete before/after state for reliable undo/redo.

var _canvas: CharacterCanvas
var _shape_indices: Array[int]
var _property_name: String
var _old_values: Dictionary = {}  # index -> old_value
var _new_values: Dictionary = {}  # index -> new_value


## Create a command for modifying a single property on selected shapes.
func _init(canvas: CharacterCanvas, indices: Array[int], property: String, new_value: Variant) -> void:
	super._init("Change %s" % property.capitalize())
	_canvas = canvas
	_shape_indices = indices.duplicate()
	_property_name = property
	can_merge = true

	# Store old values and set new values
	for index in indices:
		if index >= 0 and index < canvas.shapes.size():
			var shape: Dictionary = canvas.shapes[index]
			_old_values[index] = _get_property_value(shape, property)
			_new_values[index] = _clone_value(new_value)


## Create a command from stored before/after snapshots.
static func from_snapshots(
	canvas: CharacterCanvas,
	indices: Array[int],
	before: Dictionary,  # index -> shape_data
	after: Dictionary,   # index -> shape_data
	description: String = "Modify shapes"
) -> ModifyShapeCommand:
	var cmd := ModifyShapeCommand.new(canvas, [], "", null)
	cmd.description = description
	cmd._shape_indices = indices.duplicate()
	cmd._property_name = "_snapshot"

	# Store complete shape states
	for index in indices:
		if before.has(index):
			cmd._old_values[index] = before[index].duplicate(true)
		if after.has(index):
			cmd._new_values[index] = after[index].duplicate(true)

	return cmd


func execute() -> bool:
	if not _canvas or _shape_indices.is_empty():
		return false

	if _property_name == "_snapshot":
		# Apply complete shape snapshots
		for index in _shape_indices:
			if index >= 0 and index < _canvas.shapes.size() and _new_values.has(index):
				_canvas.shapes[index] = _new_values[index].duplicate(true)
				_canvas.shape_modified.emit(index)
	else:
		# Apply single property change
		for index in _shape_indices:
			if index >= 0 and index < _canvas.shapes.size() and _new_values.has(index):
				_set_property_value(_canvas.shapes[index], _property_name, _new_values[index])
				_canvas.shape_modified.emit(index)

	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()
	return true


func undo() -> bool:
	if not _canvas or _shape_indices.is_empty():
		return false

	if _property_name == "_snapshot":
		# Restore complete shape snapshots
		for index in _shape_indices:
			if index >= 0 and index < _canvas.shapes.size() and _old_values.has(index):
				_canvas.shapes[index] = _old_values[index].duplicate(true)
				_canvas.shape_modified.emit(index)
	else:
		# Restore single property
		for index in _shape_indices:
			if index >= 0 and index < _canvas.shapes.size() and _old_values.has(index):
				_set_property_value(_canvas.shapes[index], _property_name, _old_values[index])
				_canvas.shape_modified.emit(index)

	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()
	return true


func get_command_id() -> String:
	var indices_str := ""
	for idx in _shape_indices:
		indices_str += str(idx) + ","
	return "modify_%s_%s" % [_property_name, indices_str]


func can_merge_with(other: Command) -> bool:
	if not other is ModifyShapeCommand:
		return false

	var other_modify := other as ModifyShapeCommand
	return other_modify.get_command_id() == get_command_id()


func merge_with(other: Command) -> void:
	if not other is ModifyShapeCommand:
		return

	var other_modify := other as ModifyShapeCommand

	# Keep our original old values, use the other's new values
	for index in other_modify._new_values:
		_new_values[index] = _clone_value(other_modify._new_values[index])


func _get_property_value(shape: Dictionary, property: String) -> Variant:
	match property:
		"position_x":
			return shape.position[0]
		"position_y":
			return shape.position[1]
		"width":
			return shape.size[0]
		"height":
			return shape.size[1]
		"rotation":
			return shape.get("rotation", 0.0)
		"color":
			var c: Array = shape.color
			return [c[0], c[1], c[2], c[3]]
		"layer":
			return shape.get("layer", 0)
		_:
			return shape.get(property, null)


func _set_property_value(shape: Dictionary, property: String, value: Variant) -> void:
	match property:
		"position_x":
			shape.position[0] = value
		"position_y":
			shape.position[1] = value
		"width":
			shape.size[0] = value
		"height":
			shape.size[1] = value
		"rotation":
			shape.rotation = value
		"color":
			if value is Array:
				shape.color = value.duplicate()
			elif value is Color:
				shape.color = [value.r, value.g, value.b, value.a]
		"layer":
			shape.layer = value
		_:
			shape[property] = value


func _clone_value(value: Variant) -> Variant:
	if value is Array:
		return value.duplicate()
	elif value is Dictionary:
		return value.duplicate(true)
	else:
		return value
