@tool
class_name DialogueTemplateData
extends Resource
## Resource class representing a dialogue template that can be saved/loaded.
## Templates contain a group of nodes and connections that can be inserted into any dialogue tree.
## Uses .dttemplate file extension (JSON format internally).

const FILE_VERSION := 1
const FILE_EXTENSION := "dttemplate"

## Template metadata
@export var template_name: String = ""
@export var description: String = ""
@export var author: String = ""
@export var tags: PackedStringArray = []
@export var created_date: String = ""
@export var modified_date: String = ""

## Category for organization (e.g., "conversation", "quest", "shop")
@export var category: String = "custom"

## Whether this is a built-in (read-only) template
@export var is_built_in: bool = false

## Serialized node data (array of node dictionaries)
## Each node contains: id, type, position_x, position_y, and type-specific data
## Positions are relative to the center of the template (normalized to origin)
@export var nodes: Array = []

## Connection data (array of connection dictionaries)
## Each connection: {from_node, from_port, to_node, to_port}
## Node IDs reference the template-internal IDs (will be remapped on insert)
@export var connections: Array = []

## Variable placeholders used in this template
## Format: [{name: "SPEAKER", description: "NPC speaker name", default: "Merchant"}]
@export var placeholders: Array = []

## Preview data for UI display
@export var node_count: int = 0
@export var preview_description: String = ""


## Create a new empty template with given name.
static func create_new(name: String) -> DialogueTemplateData:
	var data = DialogueTemplateData.new()
	data.template_name = name
	data.created_date = Time.get_datetime_string_from_system()
	data.modified_date = data.created_date
	return data


## Create a template from selected nodes on a canvas.
## The nodes array should contain serialized node dictionaries.
## The connections array should contain connection dictionaries.
static func create_from_selection(
	name: String,
	selected_nodes: Array,
	selected_connections: Array,
	desc: String = ""
) -> DialogueTemplateData:
	var data = DialogueTemplateData.new()
	data.template_name = name
	data.description = desc
	data.created_date = Time.get_datetime_string_from_system()
	data.modified_date = data.created_date

	# Normalize positions relative to center
	var center := _calculate_center(selected_nodes)

	for node in selected_nodes:
		var normalized_node = node.duplicate()
		normalized_node["position_x"] = node.get("position_x", 0.0) - center.x
		normalized_node["position_y"] = node.get("position_y", 0.0) - center.y
		data.nodes.append(normalized_node)

	# Copy connections (they reference template-internal node IDs)
	for conn in selected_connections:
		data.connections.append(conn.duplicate())

	data.node_count = data.nodes.size()
	data._generate_preview_description()
	data._detect_placeholders()

	return data


## Calculate the center point of a group of nodes.
static func _calculate_center(nodes_data: Array) -> Vector2:
	if nodes_data.is_empty():
		return Vector2.ZERO

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for node in nodes_data:
		var x = node.get("position_x", 0.0)
		var y = node.get("position_y", 0.0)
		min_pos.x = min(min_pos.x, x)
		min_pos.y = min(min_pos.y, y)
		max_pos.x = max(max_pos.x, x)
		max_pos.y = max(max_pos.y, y)

	return (min_pos + max_pos) / 2.0


## Generate a preview description based on node types.
func _generate_preview_description() -> void:
	var type_counts := {}
	for node in nodes:
		var node_type = node.get("type", "Unknown")
		type_counts[node_type] = type_counts.get(node_type, 0) + 1

	var parts := []
	for node_type in type_counts:
		var count = type_counts[node_type]
		if count == 1:
			parts.append("1 %s" % node_type)
		else:
			parts.append("%d %ss" % [count, node_type])

	preview_description = ", ".join(parts)


## Detect variable placeholders in node text.
## Looks for {{PLACEHOLDER}} patterns in speaker text and choice text.
func _detect_placeholders() -> void:
	placeholders.clear()
	var found_placeholders := {}

	var placeholder_regex = RegEx.new()
	placeholder_regex.compile("\\{\\{([A-Z_][A-Z0-9_]*)\\}\\}")

	for node in nodes:
		# Check speaker text
		var text = node.get("text", "")
		if not text.is_empty():
			var matches = placeholder_regex.search_all(text)
			for match_result in matches:
				var placeholder_name = match_result.get_string(1)
				if not found_placeholders.has(placeholder_name):
					found_placeholders[placeholder_name] = {
						"name": placeholder_name,
						"description": "",
						"default": ""
					}

		# Check speaker name
		var speaker = node.get("speaker", "")
		if speaker.begins_with("{{") and speaker.ends_with("}}"):
			var placeholder_name = speaker.trim_prefix("{{").trim_suffix("}}")
			if not found_placeholders.has(placeholder_name):
				found_placeholders[placeholder_name] = {
					"name": placeholder_name,
					"description": "Speaker name placeholder",
					"default": "NPC"
				}

	for placeholder_name in found_placeholders:
		placeholders.append(found_placeholders[placeholder_name])


## Validate the template data.
## Returns a Dictionary with "valid" bool and "errors" array.
func validate() -> Dictionary:
	var errors := []

	if template_name.is_empty():
		errors.append("Template name is required")

	if nodes.is_empty():
		errors.append("Template must contain at least one node")

	# Check that all connection node IDs exist in nodes
	var node_ids := {}
	for node in nodes:
		var node_id = node.get("id", "")
		if node_id.is_empty():
			errors.append("Node missing ID")
		else:
			node_ids[node_id] = true

	for conn in connections:
		var from_node = conn.get("from_node", "")
		var to_node = conn.get("to_node", "")
		if not node_ids.has(from_node):
			errors.append("Connection references unknown node: %s" % from_node)
		if not node_ids.has(to_node):
			errors.append("Connection references unknown node: %s" % to_node)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}


## Save the template to a .dttemplate file (JSON format).
func save_to_file(path: String) -> Error:
	if is_built_in:
		push_error("DialogueTemplateData: Cannot save built-in template")
		return ERR_UNAUTHORIZED

	modified_date = Time.get_datetime_string_from_system()

	var json_data := {
		"version": FILE_VERSION,
		"metadata": {
			"template_name": template_name,
			"description": description,
			"author": author,
			"tags": Array(tags),
			"category": category,
			"created_date": created_date,
			"modified_date": modified_date
		},
		"content": {
			"nodes": nodes,
			"connections": connections,
			"placeholders": placeholders
		},
		"preview": {
			"node_count": node_count,
			"preview_description": preview_description
		}
	}

	var json_string = JSON.stringify(json_data, "\t")

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("DialogueTemplateData: Failed to open file for writing: %s (error: %d)" % [path, err])
		return err

	file.store_string(json_string)
	file.close()

	print("DialogueTemplateData: Saved to %s" % path)
	return OK


## Load a template from a .dttemplate file.
static func load_from_file(path: String) -> DialogueTemplateData:
	if not FileAccess.file_exists(path):
		push_error("DialogueTemplateData: File does not exist: %s" % path)
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("DialogueTemplateData: Failed to open file for reading: %s (error: %d)" % [path, err])
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("DialogueTemplateData: Failed to parse JSON: %s (line %d)" % [json.get_error_message(), json.get_error_line()])
		return null

	var json_data = json.get_data()
	if not json_data is Dictionary:
		push_error("DialogueTemplateData: Invalid file format - expected Dictionary")
		return null

	return _parse_json_data(json_data, path)


## Parse JSON data into a DialogueTemplateData resource.
static func _parse_json_data(json_data: Dictionary, source_path: String = "") -> DialogueTemplateData:
	# Validate version
	var version = json_data.get("version", 0)
	if version > FILE_VERSION:
		push_warning("DialogueTemplateData: File version %d is newer than supported version %d" % [version, FILE_VERSION])

	var data = DialogueTemplateData.new()

	# Load metadata
	var metadata = json_data.get("metadata", {})
	data.template_name = metadata.get("template_name", "")
	data.description = metadata.get("description", "")
	data.author = metadata.get("author", "")
	data.category = metadata.get("category", "custom")
	data.created_date = metadata.get("created_date", "")
	data.modified_date = metadata.get("modified_date", "")

	# Load tags
	var tags_array = metadata.get("tags", [])
	data.tags = PackedStringArray()
	for tag in tags_array:
		data.tags.append(tag)

	# Load content
	var content = json_data.get("content", {})
	data.nodes = []
	for node in content.get("nodes", []):
		data.nodes.append(node)

	data.connections = []
	for conn in content.get("connections", []):
		data.connections.append(conn)

	data.placeholders = []
	for placeholder in content.get("placeholders", []):
		data.placeholders.append(placeholder)

	# Load preview data
	var preview = json_data.get("preview", {})
	data.node_count = preview.get("node_count", data.nodes.size())
	data.preview_description = preview.get("preview_description", "")

	# Regenerate preview if missing
	if data.preview_description.is_empty():
		data._generate_preview_description()

	# Check if this is from addon folder (built-in)
	if source_path.begins_with("res://addons/"):
		data.is_built_in = true

	print("DialogueTemplateData: Loaded template '%s' from %s (nodes: %d)" % [data.template_name, source_path, data.nodes.size()])
	return data


## Get nodes with positions offset by the given amount.
## Used when inserting template into canvas at a specific position.
func get_nodes_at_position(insert_position: Vector2) -> Array:
	var offset_nodes := []
	for node in nodes:
		var offset_node = node.duplicate()
		offset_node["position_x"] = node.get("position_x", 0.0) + insert_position.x
		offset_node["position_y"] = node.get("position_y", 0.0) + insert_position.y
		offset_nodes.append(offset_node)
	return offset_nodes


## Get connections with node IDs remapped using the provided mapping.
## id_mapping: Dictionary mapping old IDs to new IDs
func get_connections_remapped(id_mapping: Dictionary) -> Array:
	var remapped_connections := []
	for conn in connections:
		var from_node = conn.get("from_node", "")
		var to_node = conn.get("to_node", "")

		# Only include connection if both nodes exist in mapping
		if id_mapping.has(from_node) and id_mapping.has(to_node):
			remapped_connections.append({
				"from_node": id_mapping[from_node],
				"from_port": conn.get("from_port", 0),
				"to_node": id_mapping[to_node],
				"to_port": conn.get("to_port", 0)
			})

	return remapped_connections


## Replace placeholder values in node data.
## replacements: Dictionary mapping placeholder names to replacement values
func apply_placeholder_replacements(replacements: Dictionary) -> void:
	var placeholder_regex = RegEx.new()
	placeholder_regex.compile("\\{\\{([A-Z_][A-Z0-9_]*)\\}\\}")

	for i in range(nodes.size()):
		var node = nodes[i]

		# Replace in text fields
		if node.has("text"):
			var text = node["text"]
			for match_result in placeholder_regex.search_all(text):
				var placeholder_name = match_result.get_string(1)
				if replacements.has(placeholder_name):
					text = text.replace("{{%s}}" % placeholder_name, replacements[placeholder_name])
			nodes[i]["text"] = text

		# Replace speaker name
		if node.has("speaker"):
			var speaker = node["speaker"]
			if speaker.begins_with("{{") and speaker.ends_with("}}"):
				var placeholder_name = speaker.trim_prefix("{{").trim_suffix("}}")
				if replacements.has(placeholder_name):
					nodes[i]["speaker"] = replacements[placeholder_name]


## Get the bounding box size of the template.
func get_bounds_size() -> Vector2:
	if nodes.is_empty():
		return Vector2.ZERO

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for node in nodes:
		var x = node.get("position_x", 0.0)
		var y = node.get("position_y", 0.0)
		min_pos.x = min(min_pos.x, x)
		min_pos.y = min(min_pos.y, y)
		# Assume average node size of 200x100
		max_pos.x = max(max_pos.x, x + 200)
		max_pos.y = max(max_pos.y, y + 100)

	return max_pos - min_pos


## Get file filter string for file dialogs.
static func get_file_filter() -> String:
	return "*.%s;Dialogue Template Files" % FILE_EXTENSION


## Get the template ID (filename without extension).
func get_template_id() -> String:
	return template_name.to_snake_case()
