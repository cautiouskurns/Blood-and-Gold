@tool
class_name DialogueExporter
extends RefCounted
## Exports dialogue trees to game-readable JSON format.
## Strips editor-only data and converts to runtime format.

const EXPORT_VERSION := 1
const FILE_EXTENSION := "json"
const DEFAULT_EXPORT_DIR := "res://data/dialogue/"


## Export a dialogue tree from canvas data to game-readable JSON.
## Returns the exported Dictionary for further processing, or null on error.
static func export_from_canvas(canvas: GraphEdit, dialogue_id: String) -> Dictionary:
	if not canvas or not canvas.has_method("serialize"):
		push_error("DialogueExporter: Invalid canvas")
		return {}

	# Get the serialized canvas data
	var canvas_data = canvas.serialize()

	# Build the export structure
	var export_data := {
		"version": EXPORT_VERSION,
		"dialogue_id": dialogue_id,
		"start_node": "",
		"nodes": {}
	}

	# Create a map of node names to their data
	var node_map := {}
	var start_node_id := ""

	for node_data in canvas_data.get("nodes", []):
		var node_id = node_data.get("id", "")
		var node_type = node_data.get("type", "")

		if node_type == "Start":
			start_node_id = node_id
			continue  # Start node is just a pointer, not exported as a node

		# Convert node to runtime format
		var runtime_node := _convert_node_to_runtime(node_data)
		runtime_node["next"] = []  # Will be populated from connections
		node_map[node_id] = runtime_node

	# Process connections to build "next" arrays
	for conn in canvas_data.get("connections", []):
		var from_node = conn.get("from_node", "")
		var from_port = conn.get("from_port", 0)
		var to_node = conn.get("to_node", "")

		# If connection is from Start node, set the start_node pointer
		if from_node == start_node_id:
			export_data["start_node"] = to_node
			continue

		# Add to the "next" array of the source node
		if node_map.has(from_node):
			var next_entry := {"target": to_node}

			# Handle conditional outputs for branching nodes
			var from_type = _get_node_type(canvas_data.get("nodes", []), from_node)
			match from_type:
				"Branch", "FlagCheck":
					# Port 3 is True, Port 4 is False
					next_entry["condition"] = "true" if from_port == 3 else "false"
				"SkillCheck":
					# Port 3 is Success, Port 4 is Fail
					next_entry["condition"] = "success" if from_port == 3 else "fail"
				"Item":
					# Check if Item node is in "Check" mode (has conditional outputs)
					var item_data = _get_node_data(canvas_data.get("nodes", []), from_node)
					if item_data.get("item_action", "") == "Check":
						# Port 3 is Has Item, Port 4 is Missing
						next_entry["condition"] = "has_item" if from_port == 3 else "missing"

			node_map[from_node]["next"].append(next_entry)

	# Add all nodes to export
	export_data["nodes"] = node_map

	# Validate we have a start node
	if export_data["start_node"].is_empty():
		push_warning("DialogueExporter: No start node connection found")

	return export_data


## Convert a single node from editor format to runtime format.
static func _convert_node_to_runtime(node_data: Dictionary) -> Dictionary:
	var node_type = node_data.get("type", "")
	var runtime := {
		"type": node_type.to_lower()
	}

	match node_type:
		"Speaker":
			runtime["speaker"] = node_data.get("speaker", "NPC")
			runtime["text"] = node_data.get("text", "")
			if node_data.has("portrait") and not node_data.portrait.is_empty():
				runtime["portrait"] = node_data.portrait

		"Choice":
			runtime["text"] = node_data.get("text", "")

		"Branch":
			# Export as expression (unified runtime format)
			# The Branch node's serialize() method always generates an expression
			runtime["expression"] = node_data.get("expression", "")
			# Also export mode for debugging purposes
			runtime["condition_mode"] = node_data.get("condition_mode", "simple")
			# Keep legacy format for backward compatibility with old runtime code
			runtime["condition_type"] = _get_condition_type_name(node_data.get("condition_type", 0))
			runtime["condition_key"] = node_data.get("condition_key", "")
			runtime["condition_value"] = node_data.get("condition_value", "")

		"End":
			runtime["end_type"] = _get_end_type_name(node_data.get("end_type", 0))
			if node_data.has("custom_action") and not node_data.custom_action.is_empty():
				runtime["custom_action"] = node_data.custom_action

		# Phase 2 Advanced Nodes
		"SkillCheck":
			runtime["skill"] = node_data.get("skill", "Persuasion")
			runtime["difficulty_class"] = node_data.get("difficulty_class", 10)
			if node_data.get("skill") == "Custom":
				runtime["custom_skill"] = node_data.get("custom_skill", "")

		"FlagCheck":
			runtime["flag_name"] = node_data.get("flag_name", "")
			runtime["operator"] = node_data.get("operator", "==")
			runtime["flag_value"] = node_data.get("flag_value", "true")

		"FlagSet":
			runtime["flag_name"] = node_data.get("flag_name", "")
			runtime["flag_value"] = node_data.get("flag_value", "true")

		"Quest":
			runtime["quest_id"] = node_data.get("quest_id", "")
			runtime["action"] = node_data.get("quest_action", "Start").to_lower()
			if node_data.get("quest_action") == "Update":
				runtime["update_text"] = node_data.get("update_text", "")

		"Reputation":
			runtime["faction"] = node_data.get("faction", "Player Faction")
			runtime["amount"] = node_data.get("amount", 0)
			if node_data.get("faction") == "Custom":
				runtime["custom_faction"] = node_data.get("custom_faction", "")

		"Item":
			runtime["action"] = node_data.get("item_action", "Give").to_lower()
			runtime["item_id"] = node_data.get("item_id", "")
			runtime["quantity"] = node_data.get("quantity", 1)

		"SetExpression":
			# Export all variable assignments
			var assignments: Array = []
			for assignment in node_data.get("assignments", []):
				var variable = assignment.get("variable", "")
				var expression = assignment.get("expression", "")
				if not variable.is_empty():
					assignments.append({
						"variable": variable,
						"expression": expression
					})
			runtime["assignments"] = assignments

	return runtime


## Get the type of a node by its ID from the nodes array.
static func _get_node_type(nodes: Array, node_id: String) -> String:
	for node in nodes:
		if node.get("id", "") == node_id:
			return node.get("type", "")
	return ""


## Get full node data by its ID from the nodes array.
static func _get_node_data(nodes: Array, node_id: String) -> Dictionary:
	for node in nodes:
		if node.get("id", "") == node_id:
			return node
	return {}


## Convert condition type enum to string.
static func _get_condition_type_name(condition_type: int) -> String:
	match condition_type:
		0: return "flag_check"
		1: return "skill_check"
		2: return "item_check"
		3: return "reputation_check"
		4: return "custom"
		_: return "flag_check"


## Convert end type enum to string.
static func _get_end_type_name(end_type: int) -> String:
	match end_type:
		0: return "normal"
		1: return "combat"
		2: return "trade"
		3: return "exit_game"
		4: return "custom"
		_: return "normal"


## Export dialogue to a JSON file.
static func export_to_file(canvas: GraphEdit, dialogue_id: String, path: String) -> Error:
	var export_data = export_from_canvas(canvas, dialogue_id)
	if export_data.is_empty():
		return ERR_INVALID_DATA

	# Convert to JSON string
	var json_string = JSON.stringify(export_data, "\t")

	# Write to file
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("DialogueExporter: Failed to open file for writing: %s (error: %d)" % [path, err])
		return err

	file.store_string(json_string)
	file.close()

	print("DialogueExporter: Exported to %s" % path)
	return OK


## Get the default export path for a dialogue.
static func get_default_export_path(dialogue_id: String) -> String:
	if dialogue_id.is_empty():
		dialogue_id = "unnamed_dialogue"
	return DEFAULT_EXPORT_DIR + dialogue_id + "." + FILE_EXTENSION


## Get file filter string for file dialogs.
static func get_file_filter() -> String:
	return "*.%s;JSON Files" % FILE_EXTENSION


## Validate exported data structure.
static func validate_export(export_data: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	if not export_data.has("dialogue_id") or export_data.dialogue_id.is_empty():
		errors.append("Missing dialogue_id")

	if not export_data.has("start_node") or export_data.start_node.is_empty():
		errors.append("Missing start_node - ensure a Start node is connected")

	if not export_data.has("nodes") or export_data.nodes.is_empty():
		errors.append("No nodes to export")

	# Check that start_node points to a valid node
	if export_data.has("start_node") and not export_data.start_node.is_empty():
		if not export_data.get("nodes", {}).has(export_data.start_node):
			errors.append("start_node '%s' does not exist in nodes" % export_data.start_node)

	# Check for dead ends (non-End nodes with no next)
	# Note: Action nodes (flagset, quest, reputation, item with give/take) should have connections
	for node_id in export_data.get("nodes", {}):
		var node = export_data.nodes[node_id]
		var node_type = node.get("type", "")

		# End nodes don't need outgoing connections
		if node_type == "end":
			continue

		# Check if node has any outgoing connections
		if node.get("next", []).is_empty():
			errors.append("Node '%s' (%s) has no outgoing connections (dead end)" % [node_id, node_type])

		# For branching nodes, check both branches are connected
		if node_type in ["branch", "flagcheck", "skillcheck"]:
			var next_conditions = []
			for next_node in node.get("next", []):
				if next_node.has("condition"):
					next_conditions.append(next_node.condition)

			if node_type in ["branch", "flagcheck"]:
				if "true" not in next_conditions:
					errors.append("Node '%s' (%s) missing 'true' branch connection" % [node_id, node_type])
				if "false" not in next_conditions:
					errors.append("Node '%s' (%s) missing 'false' branch connection" % [node_id, node_type])
			elif node_type == "skillcheck":
				if "success" not in next_conditions:
					errors.append("Node '%s' (skill check) missing 'success' branch connection" % node_id)
				if "fail" not in next_conditions:
					errors.append("Node '%s' (skill check) missing 'fail' branch connection" % node_id)

		# For Item check action, verify both outputs
		if node_type == "item" and node.get("action", "") == "check":
			var next_conditions = []
			for next_node in node.get("next", []):
				if next_node.has("condition"):
					next_conditions.append(next_node.condition)
			if "has_item" not in next_conditions:
				errors.append("Node '%s' (item check) missing 'has_item' branch connection" % node_id)
			if "missing" not in next_conditions:
				errors.append("Node '%s' (item check) missing 'missing' branch connection" % node_id)

	return errors
