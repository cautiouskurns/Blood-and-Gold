@tool
class_name DialogueErrorHandler
extends RefCounted
## Centralized error handling and notification system for the Dialogue Editor.
## Provides toast-style notifications and error logging.

signal notification_requested(message: String, type: NotificationType, duration: float)

enum NotificationType {
	INFO,
	SUCCESS,
	WARNING,
	ERROR
}

# Singleton-style instance for global access
static var _instance: DialogueErrorHandler = null

static func get_instance() -> DialogueErrorHandler:
	if not _instance:
		_instance = DialogueErrorHandler.new()
	return _instance


## Show an info notification.
static func info(message: String, duration: float = 3.0) -> void:
	get_instance().notification_requested.emit(message, NotificationType.INFO, duration)
	print("DialogueEditor [INFO]: %s" % message)


## Show a success notification.
static func success(message: String, duration: float = 3.0) -> void:
	get_instance().notification_requested.emit(message, NotificationType.SUCCESS, duration)
	print("DialogueEditor [SUCCESS]: %s" % message)


## Show a warning notification.
static func warning(message: String, duration: float = 4.0) -> void:
	get_instance().notification_requested.emit(message, NotificationType.WARNING, duration)
	push_warning("DialogueEditor: %s" % message)


## Show an error notification.
static func error(message: String, duration: float = 5.0) -> void:
	get_instance().notification_requested.emit(message, NotificationType.ERROR, duration)
	push_error("DialogueEditor: %s" % message)


## Validate a file path exists and is readable.
static func validate_file_path(path: String, file_type: String = "file") -> Dictionary:
	var result = {"valid": false, "error": ""}

	if path.is_empty():
		result.error = "%s path is empty" % file_type.capitalize()
		return result

	if not FileAccess.file_exists(path):
		result.error = "%s not found: %s" % [file_type.capitalize(), path]
		return result

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		result.error = "Cannot read %s: %s (Error: %d)" % [file_type, path, FileAccess.get_open_error()]
		return result

	file.close()
	result.valid = true
	return result


## Safely parse JSON with error handling.
static func safe_parse_json(json_text: String, source_name: String = "JSON") -> Dictionary:
	var result = {"success": false, "data": null, "error": ""}

	if json_text.is_empty():
		result.error = "%s is empty" % source_name
		return result

	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		result.error = "%s parse error at line %d: %s" % [source_name, json.get_error_line(), json.get_error_message()]
		return result

	if json.data == null:
		result.error = "%s parsed to null" % source_name
		return result

	result.success = true
	result.data = json.data
	return result


## Validate dialogue tree data structure.
static func validate_dtree_structure(data: Dictionary) -> Dictionary:
	var result = {"valid": false, "errors": [], "warnings": []}

	# Check required top-level keys
	if not data.has("version"):
		result.errors.append("Missing 'version' field")

	if not data.has("nodes"):
		result.errors.append("Missing 'nodes' field")
	elif not data.nodes is Array:
		result.errors.append("'nodes' must be an array")

	if not data.has("connections"):
		result.warnings.append("Missing 'connections' field (will use empty)")
	elif not data.connections is Array:
		result.errors.append("'connections' must be an array")

	# Validate node structure
	if data.has("nodes") and data.nodes is Array:
		var node_ids := {}
		for i in data.nodes.size():
			var node = data.nodes[i]
			if not node is Dictionary:
				result.errors.append("Node %d is not a dictionary" % i)
				continue

			if not node.has("id"):
				result.errors.append("Node %d missing 'id' field" % i)
			elif node.id in node_ids:
				result.errors.append("Duplicate node ID: %s" % node.id)
			else:
				node_ids[node.id] = true

			if not node.has("type"):
				result.errors.append("Node %d missing 'type' field" % i)

	# Validate connection structure
	if data.has("connections") and data.connections is Array:
		for i in data.connections.size():
			var conn = data.connections[i]
			if not conn is Dictionary:
				result.errors.append("Connection %d is not a dictionary" % i)
				continue

			for key in ["from_node", "from_port", "to_node", "to_port"]:
				if not conn.has(key):
					result.errors.append("Connection %d missing '%s' field" % [i, key])

	result.valid = result.errors.is_empty()
	return result


## Detect circular references in node connections.
static func detect_circular_references(nodes: Array, connections: Array) -> Array[String]:
	var cycles: Array[String] = []

	# Build adjacency list
	var adjacency: Dictionary = {}
	var node_ids: Array[String] = []

	for node in nodes:
		if node is Dictionary and node.has("id"):
			var id = str(node.id)
			node_ids.append(id)
			adjacency[id] = []

	for conn in connections:
		if conn is Dictionary:
			var from_node = str(conn.get("from_node", ""))
			var to_node = str(conn.get("to_node", ""))
			if from_node in adjacency:
				adjacency[from_node].append(to_node)

	# DFS to detect cycles
	var visited: Dictionary = {}
	var rec_stack: Dictionary = {}
	var path: Array[String] = []

	for node_id in node_ids:
		if _dfs_detect_cycle(node_id, adjacency, visited, rec_stack, path, cycles):
			break  # Found a cycle, stop searching

	return cycles


static func _dfs_detect_cycle(node: String, adjacency: Dictionary, visited: Dictionary,
							   rec_stack: Dictionary, path: Array[String], cycles: Array[String]) -> bool:
	visited[node] = true
	rec_stack[node] = true
	path.append(node)

	if adjacency.has(node):
		for neighbor in adjacency[node]:
			if not visited.has(neighbor):
				if _dfs_detect_cycle(neighbor, adjacency, visited, rec_stack, path, cycles):
					return true
			elif rec_stack.has(neighbor) and rec_stack[neighbor]:
				# Found a cycle - record it
				var cycle_start = path.find(neighbor)
				if cycle_start >= 0:
					var cycle_path = path.slice(cycle_start)
					cycle_path.append(neighbor)
					cycles.append(" -> ".join(cycle_path))
				return true

	rec_stack[node] = false
	path.pop_back()
	return false


## Sanitize text for safe display (handle special characters).
static func sanitize_display_text(text: String, max_length: int = 0) -> String:
	var result = text

	# Replace potentially problematic characters for display
	result = result.replace("\t", "    ")  # Tabs to spaces

	# Truncate if needed (but preserve data)
	if max_length > 0 and result.length() > max_length:
		result = result.substr(0, max_length - 3) + "..."

	return result


## Generate a unique node ID that doesn't conflict with existing IDs.
static func generate_unique_node_id(existing_ids: Array, base_name: String = "node") -> String:
	var counter = 1
	var new_id = "%s_%d" % [base_name, counter]

	while new_id in existing_ids:
		counter += 1
		new_id = "%s_%d" % [base_name, counter]

	return new_id
