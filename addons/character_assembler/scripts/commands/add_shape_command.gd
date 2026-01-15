@tool
extends Command
class_name AddShapeCommand
## Command for adding a new shape to the canvas.

var _canvas: CharacterCanvas
var _shape_data: Dictionary
var _added_index: int = -1


func _init(canvas: CharacterCanvas, shape_data: Dictionary) -> void:
	super._init("Add %s" % shape_data.get("type", "shape").capitalize())
	_canvas = canvas
	_shape_data = shape_data.duplicate(true)


func execute() -> bool:
	if not _canvas:
		return false

	# Add the shape to the canvas
	_canvas.shapes.append(_shape_data.duplicate(true))
	_added_index = _canvas.shapes.size() - 1

	# Update layer if not set
	if not _shape_data.has("layer"):
		_canvas.shapes[_added_index]["layer"] = _added_index

	# Emit signals
	_canvas.shape_added.emit(_added_index)
	_canvas.canvas_changed.emit()

	# Select the new shape
	_canvas.selected_indices = [_added_index]
	_canvas.shape_selected.emit(_canvas.selected_indices)
	_canvas.queue_redraw()

	return true


func undo() -> bool:
	if not _canvas or _added_index < 0 or _added_index >= _canvas.shapes.size():
		return false

	# Remove the shape
	_canvas.shapes.remove_at(_added_index)
	_canvas.shape_removed.emit(_added_index)

	# Clear selection if needed
	if _added_index in _canvas.selected_indices:
		_canvas.selected_indices.erase(_added_index)
		_canvas.shape_selected.emit(_canvas.selected_indices)

	_canvas.canvas_changed.emit()
	_canvas.queue_redraw()

	return true
