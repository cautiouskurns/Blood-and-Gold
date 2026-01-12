@tool
class_name DialogueNode
extends GraphNode
## Base class for all dialogue tree nodes.
## Provides common functionality for serialization, styling, and ID management.

signal data_changed()
signal connection_changed()

# Node data that will be serialized
var node_id: String = ""
var node_type: String = "base"

# Connection tracking
var incoming_connections: Array[Dictionary] = []  # [{from_node, from_port, to_port}]
var outgoing_connections: Array[Dictionary] = []  # [{to_node, from_port, to_port}]

# Slot type constants - used for connection validation
enum SlotType {
	FLOW = 0,       # Standard dialogue flow
	CHOICE = 1,     # Player choice connections
	BRANCH_TRUE = 2, # Branch true output
	BRANCH_FALSE = 3 # Branch false output
}

# Slot colors for visual distinction
const SLOT_COLOR_FLOW := Color("#4CAF50")      # Green for standard flow
const SLOT_COLOR_CHOICE := Color("#2196F3")    # Blue for player choices
const SLOT_COLOR_BRANCH_TRUE := Color("#8BC34A")   # Light green for branch true
const SLOT_COLOR_BRANCH_FALSE := Color("#F44336")  # Red for branch false
const SLOT_COLOR_END := Color("#E91E63")       # Pink/red for end nodes


func _ready() -> void:
	_setup_node()
	_setup_slots()
	_connect_signals()


func _setup_node() -> void:
	# Override in subclasses to set title, color, etc.
	pass


func _setup_slots() -> void:
	# Override in subclasses to configure input/output slots
	pass


func _connect_signals() -> void:
	# Connect to position changes for dirty tracking
	position_offset_changed.connect(_on_position_changed)


func _on_position_changed() -> void:
	data_changed.emit()


## Set the unique ID for this node.
func set_node_id(id: String) -> void:
	node_id = id
	name = id


## Get the unique ID for this node.
func get_node_id() -> String:
	return node_id


## Serialize this node's data to a dictionary.
func serialize() -> Dictionary:
	return {
		"id": node_id,
		"type": node_type,
		"position_x": position_offset.x,
		"position_y": position_offset.y
	}


## Deserialize data from a dictionary into this node.
func deserialize(data: Dictionary) -> void:
	if data.has("id"):
		set_node_id(data.id)
	if data.has("position_x") and data.has("position_y"):
		position_offset = Vector2(data.position_x, data.position_y)
	elif data.has("position"):
		# Legacy format support
		position_offset = Vector2(data.position.x, data.position.y)


## Apply a color theme to this node.
func apply_color_theme(base_color: Color) -> void:
	# Normal panel style
	var style = StyleBoxFlat.new()
	style.bg_color = base_color.darkened(0.7)
	style.border_color = base_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel", style)

	# Selected panel style - brighter border and glow effect
	var selected_style = StyleBoxFlat.new()
	selected_style.bg_color = base_color.darkened(0.6)
	selected_style.border_color = Color.WHITE
	selected_style.set_border_width_all(3)
	selected_style.set_corner_radius_all(4)
	add_theme_stylebox_override("panel_selected", selected_style)

	# Title bar color
	var titlebar_style = StyleBoxFlat.new()
	titlebar_style.bg_color = base_color.darkened(0.4)
	titlebar_style.set_corner_radius_all(4)
	add_theme_stylebox_override("titlebar", titlebar_style)

	# Selected title bar - brighter
	var titlebar_selected_style = StyleBoxFlat.new()
	titlebar_selected_style.bg_color = base_color.darkened(0.2)
	titlebar_selected_style.set_corner_radius_all(4)
	add_theme_stylebox_override("titlebar_selected", titlebar_selected_style)


## Helper to emit data_changed signal
func _emit_data_changed() -> void:
	data_changed.emit()


# =============================================================================
# CONNECTION TRACKING
# =============================================================================

## Add an incoming connection to this node.
func add_incoming_connection(from_node: String, from_port: int, to_port: int) -> void:
	var conn := {"from_node": from_node, "from_port": from_port, "to_port": to_port}
	if conn not in incoming_connections:
		incoming_connections.append(conn)
		connection_changed.emit()


## Remove an incoming connection from this node.
func remove_incoming_connection(from_node: String, from_port: int, to_port: int) -> void:
	var conn := {"from_node": from_node, "from_port": from_port, "to_port": to_port}
	incoming_connections.erase(conn)
	connection_changed.emit()


## Add an outgoing connection from this node.
func add_outgoing_connection(to_node: String, from_port: int, to_port: int) -> void:
	var conn := {"to_node": to_node, "from_port": from_port, "to_port": to_port}
	if conn not in outgoing_connections:
		outgoing_connections.append(conn)
		connection_changed.emit()


## Remove an outgoing connection from this node.
func remove_outgoing_connection(to_node: String, from_port: int, to_port: int) -> void:
	var conn := {"to_node": to_node, "from_port": from_port, "to_port": to_port}
	outgoing_connections.erase(conn)
	connection_changed.emit()


## Check if this node has any incoming connection on the specified port.
func has_incoming_on_port(port: int) -> bool:
	for conn in incoming_connections:
		if conn.to_port == port:
			return true
	return false


## Get all outgoing connections from a specific port.
func get_outgoing_from_port(port: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for conn in outgoing_connections:
		if conn.from_port == port:
			result.append(conn)
	return result


## Clear all connection tracking (used when clearing canvas).
func clear_connections() -> void:
	incoming_connections.clear()
	outgoing_connections.clear()
	connection_changed.emit()


## Check if this node can accept an input connection (override in subclasses).
func can_accept_input() -> bool:
	return true  # Most nodes can accept input


## Check if this node can provide output connections (override in subclasses).
func can_provide_output() -> bool:
	return true  # Most nodes can provide output


## Get the slot type for output port (override in subclasses for special behavior).
func get_output_slot_type(port: int) -> SlotType:
	return SlotType.FLOW


## Get the slot type for input port (override in subclasses for special behavior).
func get_input_slot_type(port: int) -> SlotType:
	return SlotType.FLOW
