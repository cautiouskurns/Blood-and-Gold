@tool
class_name DialogueTreeData
extends Resource
## Resource class representing a dialogue tree that can be saved/loaded.
## Uses .dtree file extension (JSON format internally).

const FILE_VERSION := 1
const FILE_EXTENSION := "dtree"

# Metadata
@export var dialogue_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var author: String = ""
@export var created_date: String = ""
@export var modified_date: String = ""

# Canvas state
@export var scroll_offset_x: float = 0.0
@export var scroll_offset_y: float = 0.0
@export var zoom: float = 1.0

# Node data (using untyped arrays for JSON compatibility)
@export var nodes: Array = []
@export var connections: Array = []


## Create a new empty dialogue tree with given ID.
static func create_new(id: String) -> DialogueTreeData:
	var data = DialogueTreeData.new()
	data.dialogue_id = id
	data.display_name = id.capitalize().replace("_", " ")
	data.created_date = Time.get_datetime_string_from_system()
	data.modified_date = data.created_date
	return data


## Save the dialogue tree to a .dtree file (JSON format).
func save_to_file(path: String) -> Error:
	modified_date = Time.get_datetime_string_from_system()

	var json_data := {
		"version": FILE_VERSION,
		"metadata": {
			"dialogue_id": dialogue_id,
			"display_name": display_name,
			"description": description,
			"author": author,
			"created_date": created_date,
			"modified_date": modified_date
		},
		"canvas": {
			"scroll_offset_x": scroll_offset_x,
			"scroll_offset_y": scroll_offset_y,
			"zoom": zoom
		},
		"nodes": nodes,
		"connections": connections
	}

	var json_string = JSON.stringify(json_data, "\t")

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("DialogueTreeData: Failed to open file for writing: %s (error: %d)" % [path, err])
		return err

	file.store_string(json_string)
	file.close()

	print("DialogueTreeData: Saved to %s" % path)
	return OK


## Load a dialogue tree from a .dtree file.
static func load_from_file(path: String) -> DialogueTreeData:
	if not FileAccess.file_exists(path):
		push_error("DialogueTreeData: File does not exist: %s" % path)
		return null

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		var err = FileAccess.get_open_error()
		push_error("DialogueTreeData: Failed to open file for reading: %s (error: %d)" % [path, err])
		return null

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("DialogueTreeData: Failed to parse JSON: %s (line %d)" % [json.get_error_message(), json.get_error_line()])
		return null

	var json_data = json.get_data()
	if not json_data is Dictionary:
		push_error("DialogueTreeData: Invalid file format - expected Dictionary")
		return null

	# Validate version
	var version = json_data.get("version", 0)
	if version > FILE_VERSION:
		push_warning("DialogueTreeData: File version %d is newer than supported version %d" % [version, FILE_VERSION])

	# Create and populate the resource
	var data = DialogueTreeData.new()

	# Load metadata
	var metadata = json_data.get("metadata", {})
	data.dialogue_id = metadata.get("dialogue_id", "")
	data.display_name = metadata.get("display_name", "")
	data.description = metadata.get("description", "")
	data.author = metadata.get("author", "")
	data.created_date = metadata.get("created_date", "")
	data.modified_date = metadata.get("modified_date", "")

	# Load canvas state
	var canvas = json_data.get("canvas", {})
	data.scroll_offset_x = canvas.get("scroll_offset_x", 0.0)
	data.scroll_offset_y = canvas.get("scroll_offset_y", 0.0)
	data.zoom = canvas.get("zoom", 1.0)

	# Load nodes and connections
	data.nodes = []
	for node in json_data.get("nodes", []):
		data.nodes.append(node)

	data.connections = []
	for conn in json_data.get("connections", []):
		data.connections.append(conn)

	print("DialogueTreeData: Loaded from %s (dialogue_id: %s, nodes: %d)" % [path, data.dialogue_id, data.nodes.size()])
	return data


## Populate this resource from canvas serialization data.
func populate_from_canvas(canvas_data: Dictionary) -> void:
	# Canvas state
	if canvas_data.has("scroll_offset"):
		scroll_offset_x = canvas_data.scroll_offset.get("x", 0.0)
		scroll_offset_y = canvas_data.scroll_offset.get("y", 0.0)
	zoom = canvas_data.get("zoom", 1.0)

	# Nodes
	nodes.clear()
	for node in canvas_data.get("nodes", []):
		nodes.append(node)

	# Connections
	connections.clear()
	for conn in canvas_data.get("connections", []):
		connections.append(conn)


## Convert to canvas-compatible dictionary for deserialization.
func to_canvas_data() -> Dictionary:
	return {
		"version": FILE_VERSION,
		"scroll_offset": {"x": scroll_offset_x, "y": scroll_offset_y},
		"zoom": zoom,
		"nodes": nodes,
		"connections": connections
	}


## Get file filter string for file dialogs.
static func get_file_filter() -> String:
	return "*.%s;Dialogue Tree Files" % FILE_EXTENSION


## Extract dialogue ID from file path.
static func get_dialogue_id_from_path(path: String) -> String:
	return path.get_file().get_basename()
