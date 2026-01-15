@tool
extends Command
class_name DeleteShapeCommand
## Command for deleting shapes from the canvas.
## Supports deleting multiple shapes at once.

var _canvas: CharacterCanvas
var _deleted_shapes: Array[Dictionary] = []  # {index: int, data: Dictionary}
var _previous_selection: Array[int] = []


func _init(canvas: CharacterCanvas, indices: Array[int]) -> void:
	var count := indices.size()
	super._init("Delete %d shape%s" % [count, "" if count == 1 else "s"])
	_canvas = canvas

	# Store shape data before deletion (sorted descending for proper removal)
	var sorted_indices := indices.duplicate()
	sorted_indices.sort()
	sorted_indices.reverse()

	for index in sorted_indices:
		if index >= 0 and index < canvas.shapes.size():
			_deleted_shapes.append({
				"index": index,
				"data": canvas.shapes[index].duplicate(true)
			})

	_previous_selection = canvas.selected_indices.duplicate()


func execute() -> bool:
	if not _canvas or _deleted_shapes.is_empty():
		return false

	# Delete shapes in descending index order
	for entry in _deleted_shapes:
		var index: int = entry["index"]
		if index >= 0 and index < _canvas.shapes.size():
			_canvas.shapes.remove_at(index)
			_canvas.shape_removed.emit(index)

	# Clear selection
	_canvas.selected_indices.clear()
	_canvas.shape_selected.emit(_canvas.selected_indices)
	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()

	return true


func undo() -> bool:
	if not _canvas or _deleted_shapes.is_empty():
		return false

	# Restore shapes in ascending index order (reverse of deletion)
	var reversed := _deleted_shapes.duplicate()
	reversed.reverse()

	for entry in reversed:
		var index: int = entry["index"]
		var data: Dictionary = entry["data"].duplicate(true)

		# Insert at original position
		if index <= _canvas.shapes.size():
			_canvas.shapes.insert(index, data)
		else:
			_canvas.shapes.append(data)

		_canvas.shape_added.emit(index)

	# Restore selection
	_canvas.selected_indices = _previous_selection.duplicate()
	_canvas.shape_selected.emit(_canvas.selected_indices)
	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()

	return true
