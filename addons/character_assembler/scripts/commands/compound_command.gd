@tool
extends Command
class_name CompoundCommand
## Command that groups multiple commands into a single undoable unit.
## All sub-commands are executed/undone together as one operation.

var _commands: Array[Command] = []


func _init(desc: String = "Multiple operations") -> void:
	super._init(desc)


## Add a command to the compound.
func add_command(command: Command) -> void:
	_commands.append(command)


## Add multiple commands to the compound.
func add_commands(commands: Array[Command]) -> void:
	_commands.append_array(commands)


## Get the number of commands in this compound.
func get_command_count() -> int:
	return _commands.size()


## Check if the compound is empty.
func is_empty() -> bool:
	return _commands.is_empty()


func execute() -> bool:
	if _commands.is_empty():
		return false

	var success := true
	var executed: Array[Command] = []

	# Execute all commands in order
	for command in _commands:
		if command.execute():
			executed.append(command)
		else:
			success = false
			break

	# If any command failed, undo the ones that succeeded
	if not success:
		executed.reverse()
		for command in executed:
			command.undo()
		return false

	return true


func undo() -> bool:
	if _commands.is_empty():
		return false

	var success := true
	var undone: Array[Command] = []

	# Undo all commands in reverse order
	var reversed := _commands.duplicate()
	reversed.reverse()

	for command in reversed:
		if command.undo():
			undone.append(command)
		else:
			success = false
			break

	# If any undo failed, re-execute the ones that were undone
	if not success:
		undone.reverse()
		for command in undone:
			command.execute()
		return false

	return true


## Create a compound command from shape resize operation.
## This captures the before/after state of multiple shapes being resized together.
static func create_resize_command(
	canvas: CharacterCanvas,
	indices: Array[int],
	before_states: Dictionary,  # index -> shape_data
	after_states: Dictionary    # index -> shape_data
) -> CompoundCommand:
	var compound := CompoundCommand.new("Resize %d shape%s" % [indices.size(), "" if indices.size() == 1 else "s"])

	# Create a single modify command with the complete state changes
	var modify_cmd := ModifyShapeCommand.from_snapshots(canvas, indices, before_states, after_states, "Resize shapes")
	compound.add_command(modify_cmd)

	return compound
