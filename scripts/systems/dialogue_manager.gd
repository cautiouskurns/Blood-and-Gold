## DialogueManager - Parses and navigates dialogue trees from JSON
## Part of: Blood & Gold Prototype
## Task 3.10: Camp Scene System
## Spec: docs/features/3.10-camp-scene-system.md
class_name DialogueManager
extends RefCounted

# ===== SIGNALS =====
signal node_reached(node_data: Dictionary)
signal choices_available(choices: Array[Dictionary])
signal dialogue_ended(end_type: String)

# ===== NODE TYPES =====
const NODE_START: String = "Start"
const NODE_SPEAKER: String = "Speaker"
const NODE_CHOICE: String = "Choice"
const NODE_END: String = "End"

# ===== INTERNAL STATE =====
var _dialogue_data: Dictionary = {}
var _current_node_id: String = ""
var _visited_nodes: Array[String] = []
var _is_loaded: bool = false

# ===== PUBLIC API =====
func load_dialogue(json_path: String) -> bool:
	## Load dialogue tree from JSON file
	## Returns true if successful, false otherwise
	_dialogue_data.clear()
	_current_node_id = ""
	_visited_nodes.clear()
	_is_loaded = false

	if not FileAccess.file_exists(json_path):
		push_error("[DialogueManager] File not found: %s" % json_path)
		return false

	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("[DialogueManager] Failed to open: %s" % json_path)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_error("[DialogueManager] JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return false

	_dialogue_data = json.data
	_is_loaded = true
	print("[DialogueManager] Loaded dialogue: %s" % _dialogue_data.get("title", "Untitled"))
	return true

func load_dialogue_from_data(data: Dictionary) -> bool:
	## Load dialogue from a dictionary (for testing/inline use)
	_dialogue_data = data
	_current_node_id = ""
	_visited_nodes.clear()
	_is_loaded = not data.is_empty()
	return _is_loaded

func start() -> Dictionary:
	## Start dialogue from the Start node
	## Returns first speaker node data, or empty if none found
	if not _is_loaded:
		push_error("[DialogueManager] No dialogue loaded")
		return {}

	var start_node_id = _find_start_node()
	if start_node_id.is_empty():
		push_error("[DialogueManager] No Start node found")
		return {}

	_current_node_id = start_node_id
	_visited_nodes.append(start_node_id)

	# Get connections from start and move to first node
	var connections = _get_connections_from(start_node_id)
	if connections.is_empty():
		push_error("[DialogueManager] Start node has no connections")
		return {}

	var first_target = connections[0].get("to", "")
	if first_target.is_empty():
		push_error("[DialogueManager] Invalid connection from Start node")
		return {}

	return _move_to_node(first_target)

func get_current_node() -> Dictionary:
	## Get data for the current node
	if _current_node_id.is_empty():
		return {}
	var nodes = _dialogue_data.get("nodes", {})
	return nodes.get(_current_node_id, {})

func get_current_node_type() -> String:
	## Get the type of the current node
	var node = get_current_node()
	return node.get("type", "")

func advance() -> Dictionary:
	## Advance to next node (for speaker nodes with single connection)
	## Returns node data, or empty if at choices/end
	var current = get_current_node()
	var node_type = current.get("type", "")

	if node_type == NODE_END:
		var end_type = current.get("end_type", "normal")
		dialogue_ended.emit(end_type)
		return {}

	if node_type == NODE_CHOICE:
		# Can't advance through choices - must select one
		return {}

	var connections = _get_connections_from(_current_node_id)

	# Check if next nodes are choices
	if not connections.is_empty():
		var first_target = connections[0].get("to", "")
		var first_node = _get_node(first_target)

		if first_node.get("type", "") == NODE_CHOICE:
			# We're at a speaker that leads to choices
			var choices = _gather_choices(connections)
			choices_available.emit(choices)
			return {}

	if connections.is_empty():
		# No connections = end of dialogue
		dialogue_ended.emit("normal")
		return {}

	# Single connection - advance
	var next_id = connections[0].get("to", "")
	return _move_to_node(next_id)

func get_available_choices() -> Array[Dictionary]:
	## Get all choices available from current node
	var connections = _get_connections_from(_current_node_id)
	return _gather_choices(connections)

func select_choice(choice_id: String) -> Dictionary:
	## Select a choice and follow its connection
	## Returns the next speaker node data
	var choice_node = _get_node(choice_id)
	if choice_node.is_empty():
		push_error("[DialogueManager] Choice not found: %s" % choice_id)
		return {}

	if choice_node.get("type", "") != NODE_CHOICE:
		push_error("[DialogueManager] Node is not a Choice: %s" % choice_id)
		return {}

	_current_node_id = choice_id
	_visited_nodes.append(choice_id)

	var connections = _get_connections_from(choice_id)
	if connections.is_empty():
		dialogue_ended.emit("normal")
		return {}

	var next_id = connections[0].get("to", "")
	return _move_to_node(next_id)

func get_scene_id() -> String:
	## Get the ID of the current dialogue scene
	return _dialogue_data.get("id", "")

func get_scene_title() -> String:
	## Get the title of the current dialogue scene
	return _dialogue_data.get("title", "")

func get_trigger_contract() -> String:
	## Get the contract that triggers this scene
	return _dialogue_data.get("trigger_contract", "")

func is_loaded() -> bool:
	return _is_loaded

# ===== INTERNAL METHODS =====
func _find_start_node() -> String:
	## Find the Start node ID in the dialogue
	var nodes = _dialogue_data.get("nodes", {})
	for node_id in nodes.keys():
		var node = nodes[node_id]
		if node.get("type", "") == NODE_START:
			return node_id
	return ""

func _get_node(node_id: String) -> Dictionary:
	## Get a node by ID
	var nodes = _dialogue_data.get("nodes", {})
	return nodes.get(node_id, {})

func _get_connections_from(node_id: String) -> Array[Dictionary]:
	## Get all connections from a node
	var node = _get_node(node_id)
	var connections = node.get("connections", [])
	var result: Array[Dictionary] = []
	for conn in connections:
		result.append(conn)
	return result

func _move_to_node(node_id: String) -> Dictionary:
	## Move to a node and return its data
	if node_id.is_empty():
		push_error("[DialogueManager] Empty node ID")
		return {}

	var node = _get_node(node_id)
	if node.is_empty():
		push_error("[DialogueManager] Node not found: %s" % node_id)
		return {}

	_current_node_id = node_id
	_visited_nodes.append(node_id)

	var node_type = node.get("type", "")

	if node_type == NODE_END:
		var end_type = node.get("end_type", "normal")
		dialogue_ended.emit(end_type)
		return node

	# Add node_id to the data for reference
	var node_data = node.duplicate()
	node_data["node_id"] = node_id
	node_reached.emit(node_data)
	return node_data

func _gather_choices(connections: Array[Dictionary]) -> Array[Dictionary]:
	## Gather choice data from connections
	var choices: Array[Dictionary] = []
	for conn in connections:
		var target_id = conn.get("to", "")
		var target_node = _get_node(target_id)
		if target_node.get("type", "") == NODE_CHOICE:
			var choice_data = target_node.duplicate()
			choice_data["node_id"] = target_id
			choices.append(choice_data)
	return choices
