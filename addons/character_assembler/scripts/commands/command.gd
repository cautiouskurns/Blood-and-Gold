@tool
extends RefCounted
class_name Command
## Base class for undoable commands in the Character Assembler.
## Implements the Command pattern for undo/redo functionality.

## Human-readable description of this command for UI display.
var description: String = "Unknown Command"

## Whether this command can be merged with subsequent similar commands.
## Used for operations like continuous dragging where many small moves should combine.
var can_merge: bool = false

## Timestamp when command was created (for merge window).
var created_at: int = 0


func _init(desc: String = "Unknown Command") -> void:
	description = desc
	created_at = Time.get_ticks_msec()


## Execute the command. Override in subclasses.
## Returns true if execution was successful.
func execute() -> bool:
	push_error("Command.execute() not implemented in %s" % get_script().get_path())
	return false


## Undo the command. Override in subclasses.
## Returns true if undo was successful.
func undo() -> bool:
	push_error("Command.undo() not implemented in %s" % get_script().get_path())
	return false


## Check if this command can merge with another command.
## Override in subclasses that support merging.
func can_merge_with(other: Command) -> bool:
	return false


## Merge another command into this one.
## Override in subclasses that support merging.
func merge_with(other: Command) -> void:
	pass


## Get a unique identifier for this command type.
## Used for merge detection.
func get_command_id() -> String:
	return ""
