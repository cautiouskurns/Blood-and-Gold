@tool
extends GraphEdit
## Visual canvas for dialogue tree editing.
## Handles node placement, connections, pan/zoom, and context menus.

# Preload node scripts for reliable instantiation in @tool scripts
const DialogueNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/dialogue_node.gd")
const StartNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/start_node.gd")
const SpeakerNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/speaker_node.gd")
const ChoiceNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/choice_node.gd")
const BranchNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/branch_node.gd")
const EndNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/end_node.gd")

signal canvas_changed()  # Emitted when any change is made (for dirty tracking)
signal zoom_changed(new_zoom: float)  # Emitted when zoom level changes
signal dialogue_node_selected(node: GraphNode)  # Renamed to avoid conflict with GraphEdit
signal dialogue_node_deselected()  # Renamed to avoid conflict with GraphEdit

# Zoom configuration
const ZOOM_MIN := 0.25
const ZOOM_MAX := 2.0
const ZOOM_STEP := 0.1

# Snapping configuration
const SNAP_DISTANCE := 20

# Node ID counter for generating unique IDs
var _next_node_id: int = 1

# Context menu
var _context_menu: PopupMenu
var _context_menu_position: Vector2

# Zoom tracking
var _last_zoom: float = 1.0


func _ready() -> void:
	# Configure GraphEdit properties
	_setup_graph_edit()
	_setup_context_menu()
	_connect_signals()


func _process(_delta: float) -> void:
	# Track zoom changes
	if zoom != _last_zoom:
		_last_zoom = zoom
		zoom_changed.emit(zoom)


func _setup_graph_edit() -> void:
	# Grid and snapping
	snapping_enabled = true
	snapping_distance = SNAP_DISTANCE
	show_grid = true

	# Zoom limits
	zoom_min = ZOOM_MIN
	zoom_max = ZOOM_MAX
	zoom_step = ZOOM_STEP

	# Minimap
	minimap_enabled = true
	minimap_size = Vector2(200, 150)
	minimap_opacity = 0.65

	# Panning is built into GraphEdit (middle mouse or right mouse drag)
	# Connection behavior - right-click on connection to delete
	right_disconnects = true

	# Connection line styling - bezier curve
	connection_lines_curvature = 0.5
	connection_lines_thickness = 2.0
	connection_lines_antialiased = true

	# Register valid connection types
	_setup_valid_connection_types()


func _setup_context_menu() -> void:
	_context_menu = PopupMenu.new()
	_context_menu.name = "ContextMenu"
	add_child(_context_menu)

	# Add menu items (placeholders for Feature 1.3)
	_context_menu.add_item("Add Start Node", 0)
	_context_menu.add_item("Add Speaker Node", 1)
	_context_menu.add_item("Add Choice Node", 2)
	_context_menu.add_item("Add Branch Node", 3)
	_context_menu.add_item("Add End Node", 4)
	_context_menu.add_separator()
	_context_menu.add_item("Paste", 10)

	_context_menu.id_pressed.connect(_on_context_menu_id_pressed)


func _connect_signals() -> void:
	# Connection handling
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)

	# Node selection
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)

	# Right-click for context menu
	popup_request.connect(_on_popup_request)

	# Delete nodes
	delete_nodes_request.connect(_on_delete_nodes_request)


# =============================================================================
# CONNECTION TYPES SETUP
# =============================================================================

func _setup_valid_connection_types() -> void:
	# Define which slot types can connect to which
	# All flow types can connect to flow inputs
	add_valid_connection_type(DialogueNodeScript.SlotType.FLOW, DialogueNodeScript.SlotType.FLOW)
	add_valid_connection_type(DialogueNodeScript.SlotType.CHOICE, DialogueNodeScript.SlotType.FLOW)
	add_valid_connection_type(DialogueNodeScript.SlotType.BRANCH_TRUE, DialogueNodeScript.SlotType.FLOW)
	add_valid_connection_type(DialogueNodeScript.SlotType.BRANCH_FALSE, DialogueNodeScript.SlotType.FLOW)


# =============================================================================
# CONNECTION HANDLING
# =============================================================================

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# Prevent self-connections
	if from_node == to_node:
		print("DialogueCanvas: Cannot connect node to itself")
		return

	# Get the actual nodes
	var source_node = get_node_or_null(NodePath(from_node))
	var target_node = get_node_or_null(NodePath(to_node))

	if not source_node or not target_node:
		return

	# Check if source can provide output
	if source_node is DialogueNodeScript and not source_node.can_provide_output():
		print("DialogueCanvas: %s cannot provide output connections" % from_node)
		return

	# Check if target can accept input
	if target_node is DialogueNodeScript and not target_node.can_accept_input():
		print("DialogueCanvas: %s cannot accept input connections" % to_node)
		return

	# Prevent multiple connections to the same input slot
	if _has_incoming_connection(to_node, to_port):
		print("DialogueCanvas: Input slot %d on %s already has a connection" % [to_port, to_node])
		return

	# Check if connection already exists
	for conn in get_connection_list():
		if conn.from_node == from_node and conn.from_port == from_port and conn.to_node == to_node and conn.to_port == to_port:
			return

	# Create the connection
	var error = connect_node(from_node, from_port, to_node, to_port)
	if error == OK:
		# Update node connection tracking
		_track_connection_added(from_node, from_port, to_node, to_port)
		canvas_changed.emit()
		print("DialogueCanvas: Connected %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	# Update node connection tracking
	_track_connection_removed(from_node, from_port, to_node, to_port)
	canvas_changed.emit()
	print("DialogueCanvas: Disconnected %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])


## Check if a target node already has an incoming connection on the specified port.
func _has_incoming_connection(node_name: StringName, port: int) -> bool:
	for conn in get_connection_list():
		if conn.to_node == node_name and conn.to_port == port:
			return true
	return false


## Track when a connection is added.
func _track_connection_added(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var source = get_node_or_null(NodePath(from_node))
	var target = get_node_or_null(NodePath(to_node))

	if source is DialogueNodeScript:
		source.add_outgoing_connection(String(to_node), from_port, to_port)

	if target is DialogueNodeScript:
		target.add_incoming_connection(String(from_node), from_port, to_port)


## Track when a connection is removed.
func _track_connection_removed(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var source = get_node_or_null(NodePath(from_node))
	var target = get_node_or_null(NodePath(to_node))

	if source is DialogueNodeScript:
		source.remove_outgoing_connection(String(to_node), from_port, to_port)

	if target is DialogueNodeScript:
		target.remove_incoming_connection(String(from_node), from_port, to_port)


# =============================================================================
# NODE SELECTION
# =============================================================================

func _on_node_selected(node: Node) -> void:
	if node is GraphNode:
		dialogue_node_selected.emit(node)
		print("DialogueCanvas: Selected node %s" % node.name)


func _on_node_deselected(node: Node) -> void:
	dialogue_node_deselected.emit()


# =============================================================================
# CONTEXT MENU
# =============================================================================

func _on_popup_request(position: Vector2) -> void:
	_context_menu_position = position
	_context_menu.position = get_screen_position() + position
	_context_menu.popup()


func _on_context_menu_id_pressed(id: int) -> void:
	var local_pos = (scroll_offset + _context_menu_position) / zoom

	match id:
		0:  # Add Start Node
			_create_dialogue_node("Start", local_pos)
		1:  # Add Speaker Node
			_create_dialogue_node("Speaker", local_pos)
		2:  # Add Choice Node
			_create_dialogue_node("Choice", local_pos)
		3:  # Add Branch Node
			_create_dialogue_node("Branch", local_pos)
		4:  # Add End Node
			_create_dialogue_node("End", local_pos)
		10:  # Paste
			print("DialogueCanvas: Paste (not implemented)")


func _create_dialogue_node(type: String, position: Vector2) -> GraphNode:
	var node: GraphNode

	# Create the appropriate node type using preloaded scripts
	match type:
		"Start":
			node = StartNodeScript.new()
		"Speaker":
			node = SpeakerNodeScript.new()
		"Choice":
			node = ChoiceNodeScript.new()
		"Branch":
			node = BranchNodeScript.new()
		"End":
			node = EndNodeScript.new()
		_:
			push_error("DialogueCanvas: Unknown node type: %s" % type)
			return null

	# Configure the node
	node.name = "%s_%d" % [type, _next_node_id]
	node.node_id = node.name
	node.position_offset = position

	# Connect to data changed signal
	node.data_changed.connect(_on_node_data_changed.bind(node))

	add_child(node)
	_next_node_id += 1
	canvas_changed.emit()
	print("DialogueCanvas: Added %s node at %s" % [type, position])
	return node


func _on_node_data_changed(node: GraphNode) -> void:
	canvas_changed.emit()
	print("DialogueCanvas: Node %s data changed" % node.name)


# =============================================================================
# DRAG AND DROP
# =============================================================================

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Accept drops from the node palette
	if data is Dictionary and data.get("type") == "dialogue_node":
		return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "dialogue_node":
		var node_type = data.get("node_type", "Speaker")
		# Convert screen position to canvas position
		var canvas_pos = (scroll_offset + at_position) / zoom
		add_dialogue_node(node_type, canvas_pos)


## Public method to add a dialogue node at the specified position.
func add_dialogue_node(node_type: String, position: Vector2) -> GraphNode:
	return _create_dialogue_node(node_type, position)


## Add a dialogue node at the center of the visible canvas.
func add_dialogue_node_at_center(node_type: String) -> GraphNode:
	var center_pos = (scroll_offset + size / 2) / zoom
	return _create_dialogue_node(node_type, center_pos)


# =============================================================================
# NODE DELETION
# =============================================================================

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node = get_node_or_null(NodePath(node_name))
		if node and node is DialogueNodeScript:
			# Remove all connections to/from this node and update tracking
			var connections_to_remove: Array[Dictionary] = []
			for conn in get_connection_list():
				if conn.from_node == node_name or conn.to_node == node_name:
					connections_to_remove.append(conn)

			for conn in connections_to_remove:
				disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
				_track_connection_removed(conn.from_node, conn.from_port, conn.to_node, conn.to_port)

			# Clear the node's own tracking
			node.clear_connections()
			node.queue_free()
			print("DialogueCanvas: Deleted node %s" % node_name)

	canvas_changed.emit()


# =============================================================================
# PUBLIC API
# =============================================================================

func clear_canvas() -> void:
	"""Remove all nodes and connections."""
	# Clear connections first
	clear_connections()

	# Remove all DialogueNode children and their connection tracking
	for child in get_children():
		if child is DialogueNodeScript:
			child.clear_connections()
			child.queue_free()

	_next_node_id = 1
	canvas_changed.emit()


func get_node_count() -> int:
	"""Return the number of dialogue nodes on the canvas."""
	var count = 0
	for child in get_children():
		if child is DialogueNodeScript:
			count += 1
	return count


func get_all_dialogue_nodes() -> Array[GraphNode]:
	"""Return all dialogue nodes on the canvas."""
	var nodes: Array[GraphNode] = []
	for child in get_children():
		if child is DialogueNodeScript:
			nodes.append(child)
	return nodes


func serialize() -> Dictionary:
	"""Serialize the entire dialogue tree to a Dictionary."""
	var data := {
		"version": 1,
		"nodes": [],
		"connections": [],
		"scroll_offset": {"x": scroll_offset.x, "y": scroll_offset.y},
		"zoom": zoom
	}

	# Serialize all nodes
	for node in get_all_dialogue_nodes():
		data.nodes.append(node.serialize())

	# Serialize connections
	for conn in get_connection_list():
		data.connections.append({
			"from_node": String(conn.from_node),
			"from_port": conn.from_port,
			"to_node": String(conn.to_node),
			"to_port": conn.to_port
		})

	return data


func deserialize(data: Dictionary) -> void:
	"""Load a dialogue tree from a Dictionary."""
	# Clear existing content
	clear_canvas()

	# Restore view settings
	if data.has("scroll_offset"):
		scroll_offset = Vector2(data.scroll_offset.x, data.scroll_offset.y)
	if data.has("zoom"):
		zoom = data.zoom

	# Create nodes
	var node_map := {}  # Maps old node IDs to new node names
	if data.has("nodes"):
		for node_data in data.nodes:
			var node_type = node_data.get("type", "Speaker")
			var position = Vector2(
				node_data.get("position_x", 0),
				node_data.get("position_y", 0)
			)

			var node = _create_dialogue_node(node_type, position)
			if node:
				node.deserialize(node_data)
				node_map[node_data.get("id", "")] = node.name

	# Restore connections
	if data.has("connections"):
		for conn in data.connections:
			var from_name = node_map.get(conn.from_node, conn.from_node)
			var to_name = node_map.get(conn.to_node, conn.to_node)
			connect_node(from_name, conn.from_port, to_name, conn.to_port)

	canvas_changed.emit()


func get_zoom_percent() -> int:
	"""Return current zoom as percentage."""
	return int(zoom * 100)


func reset_view() -> void:
	"""Reset zoom and scroll to default."""
	zoom = 1.0
	scroll_offset = Vector2.ZERO


## Get all outgoing connections from a specific node.
func get_connections_from(node_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for conn in get_connection_list():
		if String(conn.from_node) == node_name:
			result.append({
				"from_port": conn.from_port,
				"to_node": String(conn.to_node),
				"to_port": conn.to_port
			})
	return result


## Get all incoming connections to a specific node.
func get_connections_to(node_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for conn in get_connection_list():
		if String(conn.to_node) == node_name:
			result.append({
				"from_node": String(conn.from_node),
				"from_port": conn.from_port,
				"to_port": conn.to_port
			})
	return result


## Find the Start node in the dialogue tree.
func get_start_node() -> GraphNode:
	for child in get_children():
		if child is StartNodeScript:
			return child
	return null


## Check if the dialogue tree is valid (has exactly one Start node).
func has_valid_start() -> bool:
	var start_count := 0
	for child in get_children():
		if child is StartNodeScript:
			start_count += 1
	return start_count == 1


## Get all nodes that have no incoming connections (orphans, except Start).
func get_orphan_nodes() -> Array[GraphNode]:
	var orphans: Array[GraphNode] = []
	for child in get_children():
		if child is DialogueNodeScript and not child is StartNodeScript:
			var has_incoming := false
			for conn in get_connection_list():
				if String(conn.to_node) == child.name:
					has_incoming = true
					break
			if not has_incoming:
				orphans.append(child)
	return orphans


## Get all nodes that have no outgoing connections (dead ends, except End).
func get_dead_end_nodes() -> Array[GraphNode]:
	var dead_ends: Array[GraphNode] = []
	for child in get_children():
		if child is DialogueNodeScript and not child is EndNodeScript:
			var has_outgoing := false
			for conn in get_connection_list():
				if String(conn.from_node) == child.name:
					has_outgoing = true
					break
			if not has_outgoing:
				dead_ends.append(child)
	return dead_ends
