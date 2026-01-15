@tool
extends RefCounted
class_name CommandManager
## Manages undo/redo stacks for the Character Assembler.
## Implements a command history with configurable depth.

signal command_executed(command: Command)
signal command_undone(command: Command)
signal command_redone(command: Command)
signal history_changed()

## Maximum number of commands to keep in history.
const MAX_HISTORY_SIZE := 20

## Time window in milliseconds for merging similar commands.
const MERGE_WINDOW_MS := 500

## Stack of executed commands (for undo).
var _undo_stack: Array[Command] = []

## Stack of undone commands (for redo).
var _redo_stack: Array[Command] = []

## Whether we're currently executing an undo/redo operation.
var _is_undoing: bool = false


## Execute a command and add it to the undo stack.
func execute(command: Command) -> bool:
	if _is_undoing:
		return false

	# Try to execute the command
	if not command.execute():
		return false

	# Check if we can merge with the previous command
	if _try_merge_command(command):
		history_changed.emit()
		return true

	# Add to undo stack
	_undo_stack.append(command)

	# Clear redo stack (new action invalidates redo history)
	_redo_stack.clear()

	# Trim undo stack if too large
	while _undo_stack.size() > MAX_HISTORY_SIZE:
		_undo_stack.pop_front()

	command_executed.emit(command)
	history_changed.emit()
	return true


## Undo the last command.
func undo() -> bool:
	if _undo_stack.is_empty():
		return false

	_is_undoing = true
	var command := _undo_stack.pop_back()

	if command.undo():
		_redo_stack.append(command)
		command_undone.emit(command)
		history_changed.emit()
		_is_undoing = false
		return true
	else:
		# Undo failed, put command back
		_undo_stack.append(command)
		_is_undoing = false
		return false


## Redo the last undone command.
func redo() -> bool:
	if _redo_stack.is_empty():
		return false

	_is_undoing = true
	var command := _redo_stack.pop_back()

	if command.execute():
		_undo_stack.append(command)
		command_redone.emit(command)
		history_changed.emit()
		_is_undoing = false
		return true
	else:
		# Redo failed, put command back
		_redo_stack.append(command)
		_is_undoing = false
		return false


## Check if undo is available.
func can_undo() -> bool:
	return not _undo_stack.is_empty()


## Check if redo is available.
func can_redo() -> bool:
	return not _redo_stack.is_empty()


## Get the description of the next undo command.
func get_undo_description() -> String:
	if _undo_stack.is_empty():
		return ""
	return _undo_stack.back().description


## Get the description of the next redo command.
func get_redo_description() -> String:
	if _redo_stack.is_empty():
		return ""
	return _redo_stack.back().description


## Get the number of commands in the undo stack.
func get_undo_count() -> int:
	return _undo_stack.size()


## Get the number of commands in the redo stack.
func get_redo_count() -> int:
	return _redo_stack.size()


## Clear all history.
func clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	history_changed.emit()


## Try to merge a new command with the last command in the undo stack.
func _try_merge_command(new_command: Command) -> bool:
	if _undo_stack.is_empty():
		return false

	if not new_command.can_merge:
		return false

	var last_command := _undo_stack.back()

	# Check if commands are within the merge window
	var time_diff: int = new_command.created_at - last_command.created_at
	if time_diff > MERGE_WINDOW_MS:
		return false

	# Check if commands can be merged
	if last_command.can_merge_with(new_command):
		last_command.merge_with(new_command)
		return true

	return false


## Get a list of undo descriptions for UI display.
func get_undo_history() -> Array[String]:
	var history: Array[String] = []
	for i in range(_undo_stack.size() - 1, -1, -1):
		history.append(_undo_stack[i].description)
	return history


## Get a list of redo descriptions for UI display.
func get_redo_history() -> Array[String]:
	var history: Array[String] = []
	for i in range(_redo_stack.size() - 1, -1, -1):
		history.append(_redo_stack[i].description)
	return history


## Add a command to history without executing it.
## Use this when an operation has already been performed (e.g., during drag).
func _add_to_history(command: Command) -> void:
	if _is_undoing:
		return

	# Check if we can merge with the previous command
	if _try_merge_command(command):
		history_changed.emit()
		return

	# Add to undo stack
	_undo_stack.append(command)

	# Clear redo stack (new action invalidates redo history)
	_redo_stack.clear()

	# Trim undo stack if too large
	while _undo_stack.size() > MAX_HISTORY_SIZE:
		_undo_stack.pop_front()

	command_executed.emit(command)
	history_changed.emit()
