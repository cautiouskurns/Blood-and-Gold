@tool
class_name DialogueRunner
extends RefCounted
## Runs dialogue trees for in-editor testing.
## Tracks simulated game state and navigation history.
## Supports expression-based conditions using the expression evaluator.

const ExpressionEvaluatorScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_evaluator.gd")

signal dialogue_started()
signal dialogue_ended(end_type: String)
signal node_entered(node_id: String, node_data: Dictionary)
signal choices_available(choices: Array[Dictionary])
signal state_changed()

# Node type constants matching the node scripts
const NODE_TYPE_START := "Start"
const NODE_TYPE_SPEAKER := "Speaker"
const NODE_TYPE_CHOICE := "Choice"
const NODE_TYPE_BRANCH := "Branch"
const NODE_TYPE_END := "End"
const NODE_TYPE_SKILL_CHECK := "SkillCheck"
const NODE_TYPE_FLAG_CHECK := "FlagCheck"
const NODE_TYPE_FLAG_SET := "FlagSet"
const NODE_TYPE_QUEST := "Quest"
const NODE_TYPE_REPUTATION := "Reputation"
const NODE_TYPE_ITEM := "Item"

# Simulated game state
var flags: Dictionary = {}  # flag_name -> value (String)
var quests: Dictionary = {}  # quest_id -> status ("active", "complete", "failed")
var reputation: Dictionary = {}  # faction -> amount (int)
var items: Dictionary = {}  # item_id -> quantity (int)

# Navigation history for "Back" functionality
var history: Array[Dictionary] = []  # [{node_id, state_snapshot}]
var visited_nodes: Array[String] = []  # For coverage tracking

# Current state
var current_node_id: String = ""
var current_node_data: Dictionary = {}
var canvas: GraphEdit = null
var is_running: bool = false

# Skill check simulation mode
var skill_check_auto_pass: bool = true  # If true, always pass. If false, always fail.


## Initialize the runner with a canvas reference.
func setup(dialogue_canvas: GraphEdit) -> void:
	canvas = dialogue_canvas


## Start the dialogue test from the beginning.
func start() -> void:
	if not canvas:
		push_error("DialogueRunner: No canvas set")
		return

	# Reset state
	_reset_state()
	is_running = true

	# Find the start node
	var start_node = _find_start_node()
	if not start_node:
		push_error("DialogueRunner: No Start node found")
		is_running = false
		return

	dialogue_started.emit()

	# Follow the connection from Start to the first real node
	var connections = _get_outgoing_connections(start_node.name)
	if connections.is_empty():
		push_error("DialogueRunner: Start node has no connections")
		is_running = false
		return

	# Move to the first connected node
	_go_to_node(connections[0].to_node)


## Stop the current test.
func stop() -> void:
	is_running = false
	current_node_id = ""
	current_node_data = {}


## Restart from the beginning.
func restart() -> void:
	stop()
	start()


## Go back to the previous choice point.
func go_back() -> bool:
	if history.is_empty():
		return false

	var prev_state = history.pop_back()
	_restore_state_snapshot(prev_state.state_snapshot)
	_go_to_node(prev_state.node_id, false)  # Don't save history when going back
	return true


## Jump to a specific node by ID.
func jump_to_node(node_id: String) -> void:
	if not is_running:
		# Start the runner if not running
		_reset_state()
		is_running = true
		dialogue_started.emit()

	_go_to_node(node_id, false)  # Don't save history when jumping


## Select a choice by index.
func select_choice(choice_index: int) -> void:
	if not is_running:
		return

	# Get available choices
	var choices = _get_available_choices()
	if choice_index < 0 or choice_index >= choices.size():
		push_error("DialogueRunner: Invalid choice index %d" % choice_index)
		return

	var choice = choices[choice_index]
	var choice_node_id = choice.node_id

	# Save current state to history before making choice
	_save_to_history()

	# Get the connection from the choice node to the next node
	var connections = _get_outgoing_connections(choice_node_id)
	if connections.is_empty():
		push_warning("DialogueRunner: Choice node %s has no outgoing connections" % choice_node_id)
		return

	# Follow the choice to the next node
	_go_to_node(connections[0].to_node)


## Continue to the next node (for non-choice nodes with single output).
func continue_dialogue() -> void:
	if not is_running or current_node_id.is_empty():
		return

	# Get outgoing connections from current node
	var connections = _get_outgoing_connections(current_node_id)
	if connections.is_empty():
		push_warning("DialogueRunner: No outgoing connections from %s" % current_node_id)
		return

	_go_to_node(connections[0].to_node)


## Toggle skill check pass/fail mode.
func set_skill_check_mode(auto_pass: bool) -> void:
	skill_check_auto_pass = auto_pass


## Get all node IDs for the "Skip to Node" dropdown.
func get_all_node_ids() -> Array[String]:
	var result: Array[String] = []
	if not canvas:
		return result

	for child in canvas.get_children():
		if child is GraphNode and child.has_method("get_node_id"):
			var node_id = child.get_node_id()
			if not node_id.is_empty():
				result.append(node_id)

	return result


## Get coverage percentage (visited nodes / total nodes).
func get_coverage_percent() -> float:
	if not canvas:
		return 0.0

	var total = get_all_node_ids().size()
	if total == 0:
		return 0.0

	return (float(visited_nodes.size()) / float(total)) * 100.0


## Check if a node has been visited.
func is_node_visited(node_id: String) -> bool:
	return node_id in visited_nodes


## Check if we can go back.
func can_go_back() -> bool:
	return not history.is_empty()


# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _reset_state() -> void:
	flags.clear()
	quests.clear()
	reputation.clear()
	items.clear()
	history.clear()
	visited_nodes.clear()
	current_node_id = ""
	current_node_data = {}


func _find_start_node() -> GraphNode:
	if not canvas:
		return null

	for child in canvas.get_children():
		if child is GraphNode and child.get("node_type") == NODE_TYPE_START:
			return child

	return null


func _get_node_by_id(node_id: String) -> GraphNode:
	if not canvas:
		return null

	return canvas.get_node_or_null(NodePath(node_id))


func _get_outgoing_connections(node_name: String) -> Array[Dictionary]:
	if not canvas or not canvas.has_method("get_connections_from"):
		return []

	return canvas.get_connections_from(node_name)


func _go_to_node(node_id: String, save_history: bool = true) -> void:
	var node = _get_node_by_id(node_id)
	if not node:
		push_error("DialogueRunner: Node not found: %s" % node_id)
		return

	current_node_id = node_id
	current_node_data = node.serialize() if node.has_method("serialize") else {}

	# Track visited nodes for coverage
	if node_id not in visited_nodes:
		visited_nodes.append(node_id)

	# Emit node entered signal
	node_entered.emit(node_id, current_node_data)

	# Process the node based on type
	var node_type = current_node_data.get("type", "")
	_process_node(node_type, current_node_data)


func _process_node(node_type: String, node_data: Dictionary) -> void:
	match node_type:
		NODE_TYPE_SPEAKER:
			# Speaker node - wait for user to continue or select choice
			var choices = _get_available_choices()
			# Always emit choices_available - if empty, test panel shows Continue button
			choices_available.emit(choices)

		NODE_TYPE_END:
			# End node - dialogue is over
			var end_type = node_data.get("end_type", "normal")
			is_running = false
			dialogue_ended.emit(end_type)

		NODE_TYPE_BRANCH:
			# Branch node - evaluate condition and follow appropriate path
			_process_branch_node(node_data)

		NODE_TYPE_SKILL_CHECK:
			# Skill check - use simulation mode to determine pass/fail
			_process_skill_check_node(node_data)

		NODE_TYPE_FLAG_CHECK:
			# Flag check - evaluate flag condition
			_process_flag_check_node(node_data)

		NODE_TYPE_FLAG_SET:
			# Flag set - set the flag and continue
			_process_flag_set_node(node_data)
			_auto_continue()

		NODE_TYPE_QUEST:
			# Quest node - update quest state and continue
			_process_quest_node(node_data)
			_auto_continue()

		NODE_TYPE_REPUTATION:
			# Reputation node - modify reputation and continue
			_process_reputation_node(node_data)
			_auto_continue()

		NODE_TYPE_ITEM:
			# Item node - process item action
			_process_item_node(node_data)


func _get_available_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if current_node_id.is_empty():
		return result

	# Get all nodes connected to the current node's output
	var connections = _get_outgoing_connections(current_node_id)
	for conn in connections:
		var target_node = _get_node_by_id(conn.to_node)
		if target_node and target_node.get("node_type") == NODE_TYPE_CHOICE:
			var choice_data = target_node.serialize() if target_node.has_method("serialize") else {}
			result.append({
				"node_id": conn.to_node,
				"text": choice_data.get("text", "..."),
				"port": conn.from_port
			})

	return result


func _process_branch_node(node_data: Dictionary) -> void:
	# Check if node has an expression (new dual-mode format)
	var expression = node_data.get("expression", "")

	if not expression.is_empty():
		# Use expression evaluator
		var result = _evaluate_expression(expression)
		_follow_branch_output(result)
	else:
		# Fall back to legacy condition format
		var condition_type = node_data.get("condition_type", 0)
		var condition_key = node_data.get("condition_key", "")
		var condition_value = node_data.get("condition_value", "")

		var result = _evaluate_branch_condition(condition_type, condition_key, condition_value)
		_follow_branch_output(result)


func _evaluate_branch_condition(condition_type: int, key: String, value: String) -> bool:
	match condition_type:
		0:  # flag_check
			return flags.get(key, "") == value
		1:  # skill_check
			return skill_check_auto_pass
		2:  # item_check
			return items.get(key, 0) > 0
		3:  # reputation_check
			var threshold = int(value) if value.is_valid_int() else 0
			return reputation.get(key, 0) >= threshold
		4:  # custom
			return true  # Custom always passes in test mode
		_:
			return false


## Evaluate an expression string using the expression evaluator.
func _evaluate_expression(expression: String) -> bool:
	if expression.is_empty():
		return true  # Empty expression = always true

	# Build context dictionary from current game state
	var context = _build_expression_context()

	# Create evaluator and evaluate
	var evaluator = ExpressionEvaluatorScript.new()
	evaluator.set_context(context)

	# Register custom functions that depend on runner state
	evaluator.register_function("skill_check", func(args: Array) -> Variant:
		# In test mode, use auto_pass setting
		return skill_check_auto_pass
	)

	var result = evaluator.evaluate_string(expression)

	if not result.success:
		push_warning("DialogueRunner: Expression error: %s" % result.error)
		return false

	# Convert result to bool
	return _to_bool(result.value)


## Build expression context from current game state.
func _build_expression_context() -> Dictionary:
	var context := {}

	# Add all flags as variables
	for flag_name in flags:
		context[flag_name] = flags[flag_name]

	# Add flag lookup dictionary for has_flag function
	context["flags"] = flags.duplicate()

	# Add items for has_item/count functions
	context["items"] = items.duplicate()

	# Add inventory as array format for has_item compatibility
	var inventory_array: Array[Dictionary] = []
	for item_id in items:
		if items[item_id] > 0:
			inventory_array.append({"id": item_id, "quantity": items[item_id]})
	context["inventory"] = inventory_array

	# Add reputation values
	for faction in reputation:
		context[faction] = reputation[faction]
	context["reputation"] = reputation.duplicate()

	# Add quests for quest_state function
	var quest_data := {}
	for quest_id in quests:
		quest_data[quest_id] = {"state": quests[quest_id]}
	context["quests"] = quest_data

	# Add player-like object for player.* access
	context["player"] = {
		"flags": flags.duplicate(),
		"items": items.duplicate(),
		"reputation": reputation.duplicate(),
		"quests": quests.duplicate()
	}

	return context


## Convert a value to bool for condition evaluation.
func _to_bool(value: Variant) -> bool:
	if value is bool:
		return value
	elif value is int or value is float:
		return value != 0
	elif value is String:
		return value.to_lower() == "true" or (value.is_valid_float() and float(value) != 0)
	elif value == null:
		return false
	else:
		return true  # Default to true for non-null objects


func _process_skill_check_node(node_data: Dictionary) -> void:
	# Use simulation mode to determine result
	var result = skill_check_auto_pass
	_follow_branch_output(result)


func _process_flag_check_node(node_data: Dictionary) -> void:
	var flag_name = node_data.get("flag_name", "")
	var operator = node_data.get("operator", "==")
	var flag_value = node_data.get("flag_value", "true")

	var current_value = flags.get(flag_name, "")
	var result = _evaluate_comparison(current_value, operator, flag_value)
	_follow_branch_output(result)


func _evaluate_comparison(current: String, op: String, target: String) -> bool:
	# Try numeric comparison first
	if current.is_valid_float() and target.is_valid_float():
		var curr_num = float(current)
		var targ_num = float(target)
		match op:
			"==": return curr_num == targ_num
			"!=": return curr_num != targ_num
			">": return curr_num > targ_num
			"<": return curr_num < targ_num
			">=": return curr_num >= targ_num
			"<=": return curr_num <= targ_num

	# Fall back to string comparison
	match op:
		"==": return current == target
		"!=": return current != target
		_: return false


func _process_flag_set_node(node_data: Dictionary) -> void:
	var flag_name = node_data.get("flag_name", "")
	var flag_value = node_data.get("flag_value", "true")

	if not flag_name.is_empty():
		flags[flag_name] = flag_value
		state_changed.emit()


func _process_quest_node(node_data: Dictionary) -> void:
	var quest_id = node_data.get("quest_id", "")
	var action = node_data.get("quest_action", "Start")

	if quest_id.is_empty():
		return

	match action:
		"Start":
			quests[quest_id] = "active"
		"Complete":
			quests[quest_id] = "complete"
		"Fail":
			quests[quest_id] = "failed"
		"Update":
			# Update doesn't change status, just logs for display
			pass

	state_changed.emit()


func _process_reputation_node(node_data: Dictionary) -> void:
	var faction = node_data.get("faction", "")
	var amount = node_data.get("amount", 0)

	if faction == "Custom":
		faction = node_data.get("custom_faction", "")

	if not faction.is_empty():
		reputation[faction] = reputation.get(faction, 0) + amount
		state_changed.emit()


func _process_item_node(node_data: Dictionary) -> void:
	var action = node_data.get("item_action", "Give")
	var item_id = node_data.get("item_id", "")
	var quantity = node_data.get("quantity", 1)

	if item_id.is_empty():
		_auto_continue()
		return

	match action:
		"Give":
			items[item_id] = items.get(item_id, 0) + quantity
			state_changed.emit()
			_auto_continue()
		"Take":
			items[item_id] = maxi(0, items.get(item_id, 0) - quantity)
			state_changed.emit()
			_auto_continue()
		"Check":
			# Check has conditional outputs like skill check
			var has_item = items.get(item_id, 0) >= quantity
			_follow_item_check_output(has_item)


func _follow_branch_output(result: bool) -> void:
	# Port 3 is True/Success, Port 4 is False/Fail
	var target_port = 3 if result else 4
	var connections = _get_outgoing_connections(current_node_id)

	for conn in connections:
		if conn.from_port == target_port:
			_go_to_node(conn.to_node)
			return

	push_warning("DialogueRunner: No connection for branch result %s" % str(result))


func _follow_item_check_output(has_item: bool) -> void:
	# Port 3 is Has Item, Port 4 is Missing
	var target_port = 3 if has_item else 4
	var connections = _get_outgoing_connections(current_node_id)

	for conn in connections:
		if conn.from_port == target_port:
			_go_to_node(conn.to_node)
			return

	push_warning("DialogueRunner: No connection for item check result %s" % str(has_item))


func _auto_continue() -> void:
	# For action nodes that automatically continue to the next node
	var connections = _get_outgoing_connections(current_node_id)
	if not connections.is_empty():
		# Find the flow output (port 0)
		for conn in connections:
			if conn.from_port == 0:
				_go_to_node(conn.to_node)
				return
		# Fall back to first connection if no port 0
		_go_to_node(connections[0].to_node)


func _save_to_history() -> void:
	history.append({
		"node_id": current_node_id,
		"state_snapshot": _create_state_snapshot()
	})


func _create_state_snapshot() -> Dictionary:
	return {
		"flags": flags.duplicate(),
		"quests": quests.duplicate(),
		"reputation": reputation.duplicate(),
		"items": items.duplicate()
	}


func _restore_state_snapshot(snapshot: Dictionary) -> void:
	flags = snapshot.get("flags", {}).duplicate()
	quests = snapshot.get("quests", {}).duplicate()
	reputation = snapshot.get("reputation", {}).duplicate()
	items = snapshot.get("items", {}).duplicate()
	state_changed.emit()
