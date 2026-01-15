@tool
extends Command
class_name MoveShapeCommand
## Command for moving shapes on the canvas.
## Supports merging for continuous drag operations.

var _canvas: CharacterCanvas
var _shape_indices: Array[int]
var _original_positions: Dictionary = {}  # index -> [x, y]
var _final_positions: Dictionary = {}  # index -> [x, y]
var _delta: Vector2


func _init(canvas: CharacterCanvas, indices: Array[int], delta: Vector2) -> void:
	var count := indices.size()
	super._init("Move %d shape%s" % [count, "" if count == 1 else "s"])
	_canvas = canvas
	_shape_indices = indices.duplicate()
	_delta = delta
	can_merge = true

	# Store original positions
	for index in indices:
		if index >= 0 and index < canvas.shapes.size():
			var shape: Dictionary = canvas.shapes[index]
			_original_positions[index] = [shape.position[0], shape.position[1]]
			_final_positions[index] = [
				shape.position[0] + delta.x,
				shape.position[1] + delta.y
			]


func execute() -> bool:
	if not _canvas or _shape_indices.is_empty():
		return false

	# Apply final positions
	for index in _shape_indices:
		if index >= 0 and index < _canvas.shapes.size():
			var shape: Dictionary = _canvas.shapes[index]
			if _final_positions.has(index):
				shape.position = _final_positions[index].duplicate()
			_canvas.shape_modified.emit(index)

	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()
	return true


func undo() -> bool:
	if not _canvas or _shape_indices.is_empty():
		return false

	# Restore original positions
	for index in _shape_indices:
		if index >= 0 and index < _canvas.shapes.size():
			var shape: Dictionary = _canvas.shapes[index]
			if _original_positions.has(index):
				shape.position = _original_positions[index].duplicate()
			_canvas.shape_modified.emit(index)

	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()
	return true


func get_command_id() -> String:
	# Unique ID based on affected shapes for merge detection
	var indices_str := ""
	for idx in _shape_indices:
		indices_str += str(idx) + ","
	return "move_shape_%s" % indices_str


func can_merge_with(other: Command) -> bool:
	if not other is MoveShapeCommand:
		return false

	var other_move := other as MoveShapeCommand
	# Can merge if same shapes are being moved
	return other_move.get_command_id() == get_command_id()


func merge_with(other: Command) -> void:
	if not other is MoveShapeCommand:
		return

	var other_move := other as MoveShapeCommand

	# Update final positions with the other command's final positions
	for index in other_move._final_positions:
		_final_positions[index] = other_move._final_positions[index].duplicate()

	# Accumulate delta
	_delta += other_move._delta
