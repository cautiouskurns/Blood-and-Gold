@tool
class_name DialogueValidator
extends RefCounted
## Validates dialogue trees for structural issues.
## Detects orphan nodes, dead ends, missing Start, unreachable nodes, and empty fields.

# Validation issue severity levels
enum Severity {
	ERROR,    # Must fix before export
	WARNING,  # Should fix but not blocking
	INFO      # Informational notice
}

# Validation issue types
enum IssueType {
	MISSING_START,       # No Start node in tree
	MULTIPLE_STARTS,     # More than one Start node
	ORPHAN_NODE,         # No incoming connections (except Start)
	DEAD_END,            # Non-End node with no outgoing connections
	UNREACHABLE,         # Not connected to Start via any path
	EMPTY_REQUIRED,      # Required field is empty
	CIRCULAR_REFERENCE,  # Node connects back to itself
	INVALID_CONNECTION,  # Connection to non-existent node
}

## Represents a single validation issue.
class ValidationIssue:
	var type: IssueType
	var severity: Severity
	var node_id: String
	var message: String
	var field: String  # Optional: which field has the issue

	func _init(p_type: IssueType, p_severity: Severity, p_node_id: String, p_message: String, p_field: String = "") -> void:
		type = p_type
		severity = p_severity
		node_id = p_node_id
		message = p_message
		field = p_field

	func get_severity_name() -> String:
		match severity:
			Severity.ERROR: return "Error"
			Severity.WARNING: return "Warning"
			Severity.INFO: return "Info"
		return "Unknown"

	func get_icon_name() -> String:
		match severity:
			Severity.ERROR: return "StatusError"
			Severity.WARNING: return "StatusWarning"
			Severity.INFO: return "NodeInfo"
		return "NodeInfo"


# Reference to canvas for validation
var _canvas: GraphEdit = null

# Cached node data during validation
var _nodes: Dictionary = {}  # node_id -> node_data
var _connections: Array = []  # Array of connection info


## Setup with canvas reference.
func setup(canvas: GraphEdit) -> void:
	_canvas = canvas


## Run all validations and return array of ValidationIssue.
func validate() -> Array[ValidationIssue]:
	var issues: Array[ValidationIssue] = []

	if not _canvas:
		return issues

	# Cache node data and connections
	_cache_canvas_data()

	# Run all validation checks
	_validate_start_nodes(issues)
	_validate_orphan_nodes(issues)
	_validate_dead_ends(issues)
	_validate_unreachable_nodes(issues)
	_validate_empty_fields(issues)
	_validate_connections(issues)
	_validate_circular_references(issues)

	return issues


## Run validation and return only errors (blocking issues).
func validate_errors_only() -> Array[ValidationIssue]:
	var all_issues = validate()
	var errors: Array[ValidationIssue] = []

	for issue in all_issues:
		if issue.severity == Severity.ERROR:
			errors.append(issue)

	return errors


## Check if tree has any errors (blocking issues).
func has_errors() -> bool:
	return not validate_errors_only().is_empty()


## Get count of issues by severity.
func get_issue_counts() -> Dictionary:
	var issues = validate()
	var counts = {
		"errors": 0,
		"warnings": 0,
		"info": 0,
		"total": issues.size()
	}

	for issue in issues:
		match issue.severity:
			Severity.ERROR: counts["errors"] += 1
			Severity.WARNING: counts["warnings"] += 1
			Severity.INFO: counts["info"] += 1

	return counts


# =============================================================================
# CACHING
# =============================================================================

func _cache_canvas_data() -> void:
	_nodes.clear()
	_connections.clear()

	if not _canvas:
		return

	# Cache all nodes
	for child in _canvas.get_children():
		if child is GraphNode and child.has_method("serialize"):
			var data = child.serialize()
			_nodes[child.name] = {
				"node": child,
				"data": data,
				"type": data.get("type", "Unknown")
			}

	# Cache all connections
	for conn in _canvas.get_connection_list():
		_connections.append({
			"from_node": conn["from_node"],
			"from_port": conn["from_port"],
			"to_node": conn["to_node"],
			"to_port": conn["to_port"]
		})


# =============================================================================
# VALIDATION CHECKS
# =============================================================================

func _validate_start_nodes(issues: Array[ValidationIssue]) -> void:
	var start_nodes: Array[String] = []

	# Find all Start nodes
	for node_id in _nodes:
		var node_info = _nodes[node_id]
		if node_info["type"] == "Start":
			start_nodes.append(node_id)

	# Check for missing Start
	if start_nodes.is_empty():
		issues.append(ValidationIssue.new(
			IssueType.MISSING_START,
			Severity.ERROR,
			"",
			"No Start node found. Add a Start node to define where dialogue begins."
		))

	# Check for multiple Starts
	elif start_nodes.size() > 1:
		for start_id in start_nodes:
			issues.append(ValidationIssue.new(
				IssueType.MULTIPLE_STARTS,
				Severity.ERROR,
				start_id,
				"Multiple Start nodes found. Only one Start node is allowed."
			))


func _validate_orphan_nodes(issues: Array[ValidationIssue]) -> void:
	# Get all nodes that have incoming connections
	var nodes_with_incoming: Dictionary = {}
	for conn in _connections:
		nodes_with_incoming[conn["to_node"]] = true

	# Check each node
	for node_id in _nodes:
		var node_info = _nodes[node_id]
		var node_type = node_info["type"]

		# Start nodes shouldn't have incoming connections
		if node_type == "Start":
			continue

		# Check if this node has any incoming connections
		if node_id not in nodes_with_incoming:
			issues.append(ValidationIssue.new(
				IssueType.ORPHAN_NODE,
				Severity.WARNING,
				node_id,
				"Node '%s' has no incoming connections. It may be orphaned." % node_id
			))


func _validate_dead_ends(issues: Array[ValidationIssue]) -> void:
	# Get all nodes that have outgoing connections
	var nodes_with_outgoing: Dictionary = {}
	for conn in _connections:
		nodes_with_outgoing[conn["from_node"]] = true

	# Check each node
	for node_id in _nodes:
		var node_info = _nodes[node_id]
		var node_type = node_info["type"]

		# End nodes are supposed to have no outgoing connections
		if node_type == "End":
			continue

		# Check if this node has any outgoing connections
		if node_id not in nodes_with_outgoing:
			# Determine severity based on node type
			var severity = Severity.WARNING
			var message = "Node '%s' (%s) has no outgoing connections." % [node_id, node_type]

			# Some nodes MUST have outgoing connections
			if node_type in ["Start", "Speaker", "FlagSet", "Quest", "Reputation"]:
				severity = Severity.ERROR
				message += " This node type requires at least one connection."
			else:
				message += " Dialogue will stop here."

			issues.append(ValidationIssue.new(
				IssueType.DEAD_END,
				severity,
				node_id,
				message
			))


func _validate_unreachable_nodes(issues: Array[ValidationIssue]) -> void:
	# Find Start node
	var start_id: String = ""
	for node_id in _nodes:
		if _nodes[node_id]["type"] == "Start":
			start_id = node_id
			break

	if start_id.is_empty():
		return  # Already reported in _validate_start_nodes

	# Build reachability from Start using BFS
	var reachable: Dictionary = {}
	var queue: Array[String] = [start_id]

	while not queue.is_empty():
		var current = queue.pop_front()
		if current in reachable:
			continue
		reachable[current] = true

		# Find all nodes connected from this one
		for conn in _connections:
			if conn["from_node"] == current:
				var next_node = conn["to_node"]
				if next_node not in reachable and next_node in _nodes:
					queue.append(next_node)

	# Check for unreachable nodes
	for node_id in _nodes:
		if node_id not in reachable:
			var node_type = _nodes[node_id]["type"]
			issues.append(ValidationIssue.new(
				IssueType.UNREACHABLE,
				Severity.WARNING,
				node_id,
				"Node '%s' (%s) is not reachable from the Start node." % [node_id, node_type]
			))


func _validate_empty_fields(issues: Array[ValidationIssue]) -> void:
	for node_id in _nodes:
		var node_info = _nodes[node_id]
		var node_type = node_info["type"]
		var data = node_info["data"]

		# Check based on node type
		match node_type:
			"Speaker":
				_check_required_field(issues, node_id, data, "text", "Dialogue text")
				_check_required_field(issues, node_id, data, "speaker", "Speaker name")

			"Choice":
				_check_required_field(issues, node_id, data, "choice_text", "Choice text")

			"Branch":
				_check_required_field(issues, node_id, data, "condition_key", "Condition key")

			"FlagCheck":
				_check_required_field(issues, node_id, data, "flag_name", "Flag name")

			"FlagSet":
				_check_required_field(issues, node_id, data, "flag_name", "Flag name")

			"Quest":
				_check_required_field(issues, node_id, data, "quest_id", "Quest ID")

			"SkillCheck":
				_check_required_field(issues, node_id, data, "skill", "Skill type")

			"Item":
				_check_required_field(issues, node_id, data, "item_id", "Item ID")

			"Reputation":
				# Check if using custom faction that's empty
				var faction = data.get("faction", "")
				if faction == "Custom":
					_check_required_field(issues, node_id, data, "custom_faction", "Custom faction name")


func _check_required_field(issues: Array[ValidationIssue], node_id: String, data: Dictionary, field: String, field_name: String) -> void:
	var value = data.get(field, "")
	if value is String and value.strip_edges().is_empty():
		issues.append(ValidationIssue.new(
			IssueType.EMPTY_REQUIRED,
			Severity.WARNING,
			node_id,
			"'%s' is empty in node '%s'." % [field_name, node_id],
			field
		))


func _validate_connections(issues: Array[ValidationIssue]) -> void:
	# Check for connections to non-existent nodes
	for conn in _connections:
		var from_node = conn["from_node"]
		var to_node = conn["to_node"]

		if from_node not in _nodes:
			issues.append(ValidationIssue.new(
				IssueType.INVALID_CONNECTION,
				Severity.ERROR,
				from_node,
				"Connection from non-existent node '%s'." % from_node
			))

		if to_node not in _nodes:
			issues.append(ValidationIssue.new(
				IssueType.INVALID_CONNECTION,
				Severity.ERROR,
				to_node,
				"Connection to non-existent node '%s'." % to_node
			))

		# Check for self-connections (circular to same node)
		if from_node == to_node:
			issues.append(ValidationIssue.new(
				IssueType.CIRCULAR_REFERENCE,
				Severity.ERROR,
				from_node,
				"Node '%s' connects to itself." % from_node
			))


func _validate_circular_references(issues: Array[ValidationIssue]) -> void:
	"""Detect cycles in the dialogue graph using DFS."""
	# Build adjacency list
	var adjacency: Dictionary = {}
	for node_id in _nodes:
		adjacency[node_id] = []

	for conn in _connections:
		var from_node = conn["from_node"]
		var to_node = conn["to_node"]
		if from_node in adjacency and to_node in _nodes:
			adjacency[from_node].append(to_node)

	# DFS to detect cycles (excluding self-loops which are handled in _validate_connections)
	var visited: Dictionary = {}
	var rec_stack: Dictionary = {}  # Nodes in current recursion stack
	var path: Array[String] = []

	for node_id in _nodes:
		if node_id not in visited:
			var cycle = _dfs_find_cycle(node_id, adjacency, visited, rec_stack, path)
			if not cycle.is_empty():
				# Report the cycle (only once per unique cycle)
				var cycle_str = " -> ".join(cycle)
				issues.append(ValidationIssue.new(
					IssueType.CIRCULAR_REFERENCE,
					Severity.WARNING,
					cycle[0],
					"Circular reference detected: %s" % cycle_str
				))


func _dfs_find_cycle(node: String, adjacency: Dictionary, visited: Dictionary,
					 rec_stack: Dictionary, path: Array[String]) -> Array[String]:
	"""DFS helper to find cycles. Returns the cycle path if found, empty array otherwise."""
	visited[node] = true
	rec_stack[node] = true
	path.append(node)

	if adjacency.has(node):
		for neighbor in adjacency[node]:
			# Skip self-loops (handled elsewhere)
			if neighbor == node:
				continue

			if neighbor not in visited:
				var cycle = _dfs_find_cycle(neighbor, adjacency, visited, rec_stack, path)
				if not cycle.is_empty():
					return cycle
			elif rec_stack.get(neighbor, false):
				# Found a cycle - extract the cycle portion from path
				var cycle_start = path.find(neighbor)
				if cycle_start >= 0:
					var cycle_path: Array[String] = []
					for i in range(cycle_start, path.size()):
						cycle_path.append(path[i])
					cycle_path.append(neighbor)  # Complete the cycle
					return cycle_path

	rec_stack[node] = false
	path.pop_back()
	return []


# =============================================================================
# UTILITY
# =============================================================================

## Get all node IDs with issues.
func get_nodes_with_issues() -> Array[String]:
	var issues = validate()
	var node_ids: Array[String] = []

	for issue in issues:
		if not issue.node_id.is_empty() and issue.node_id not in node_ids:
			node_ids.append(issue.node_id)

	return node_ids


## Get issues for a specific node.
func get_issues_for_node(node_id: String) -> Array[ValidationIssue]:
	var all_issues = validate()
	var node_issues: Array[ValidationIssue] = []

	for issue in all_issues:
		if issue.node_id == node_id:
			node_issues.append(issue)

	return node_issues


## Get a summary string for display.
func get_summary() -> String:
	var counts = get_issue_counts()

	if counts["total"] == 0:
		return "No issues found"

	var parts: Array[String] = []
	if counts["errors"] > 0:
		parts.append("%d error%s" % [counts["errors"], "s" if counts["errors"] != 1 else ""])
	if counts["warnings"] > 0:
		parts.append("%d warning%s" % [counts["warnings"], "s" if counts["warnings"] != 1 else ""])
	if counts["info"] > 0:
		parts.append("%d info" % counts["info"])

	return ", ".join(parts)
