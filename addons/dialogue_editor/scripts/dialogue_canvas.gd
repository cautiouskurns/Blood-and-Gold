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

# Phase 2 Advanced Node Scripts
const SkillCheckNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/skill_check_node.gd")
const FlagCheckNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/flag_check_node.gd")
const FlagSetNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/flag_set_node.gd")
const QuestNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/quest_node.gd")
const ReputationNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/reputation_node.gd")
const ItemNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/item_node.gd")
const SetExpressionNodeScript = preload("res://addons/dialogue_editor/scripts/nodes/set_expression_node.gd")

# Node Groups
const NodeGroupScript = preload("res://addons/dialogue_editor/scripts/groups/node_group.gd")

signal canvas_changed()  # Emitted when any change is made (for dirty tracking)
signal zoom_changed(new_zoom: float)  # Emitted when zoom level changes
signal dialogue_node_selected(node: GraphNode)  # Renamed to avoid conflict with GraphEdit
signal dialogue_node_deselected()  # Renamed to avoid conflict with GraphEdit
signal undo_redo_changed()  # Emitted when undo/redo state changes
signal save_as_template_requested()  # Emitted when user requests to save selection as template
signal group_selected(group: Control)  # Emitted when a group is selected

# Undo/Redo system
var _undo_redo: UndoRedo

# Zoom configuration
const ZOOM_MIN := 0.25
const ZOOM_MAX := 2.0
const ZOOM_STEP := 0.1

# Snapping configuration
const SNAP_DISTANCE := 20

# Performance thresholds
const LARGE_TREE_THRESHOLD := 500  # Node count above which performance optimizations kick in
const VERY_LARGE_TREE_THRESHOLD := 1000  # Node count above which warnings are shown

# Node ID counter for generating unique IDs
var _next_node_id: int = 1

# Performance state
var _is_large_tree: bool = false

# Context menu
var _context_menu: PopupMenu
var _context_menu_position: Vector2
var _template_submenu: PopupMenu
var _available_templates: Array = []  # Cache of available templates for submenu

# Zoom tracking
var _last_zoom: float = 1.0

# Movement tracking for undo/redo
var _node_drag_start_positions: Dictionary = {}  # node_name -> Vector2
var _is_dragging: bool = false

# Node Groups
var _groups_container: Control  # Container for groups (renders behind nodes)
var _next_group_id: int = 1
var _group_title_edit_dialog: AcceptDialog
var _editing_group: Control = null  # Currently editing group title
var _group_drag_start_position: Vector2  # Group position when drag started
var _group_drag_node_positions: Dictionary = {}  # node_name -> starting Vector2


func _ready() -> void:
	# Initialize undo/redo system
	_ensure_undo_redo()

	# Configure GraphEdit properties
	_setup_graph_edit()
	_setup_context_menu()
	_setup_groups_container()
	_setup_group_title_dialog()
	_connect_signals()


## Ensure undo/redo system is initialized.
func _ensure_undo_redo() -> void:
	if not _undo_redo:
		_undo_redo = UndoRedo.new()
		_undo_redo.max_steps = 100


func _process(_delta: float) -> void:
	# Track zoom changes
	if zoom != _last_zoom:
		_last_zoom = zoom
		zoom_changed.emit(zoom)

	# Update groups container transform to match canvas scroll/zoom
	_update_groups_transform()


## Update the groups container transform to match the canvas scroll and zoom.
func _update_groups_transform() -> void:
	if not _groups_container:
		return

	# Apply the same transformation as the canvas content
	# Groups are in canvas coordinates, need to transform to screen coordinates
	_groups_container.position = -scroll_offset * zoom
	_groups_container.scale = Vector2(zoom, zoom)


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

	_context_menu.id_pressed.connect(_on_context_menu_id_pressed)

	# Create template submenu (will be added to context menu when populated)
	_template_submenu = PopupMenu.new()
	_template_submenu.name = "TemplateSubmenu"
	_template_submenu.id_pressed.connect(_on_template_submenu_id_pressed)


func _setup_groups_container() -> void:
	# Create a container for groups that renders behind nodes
	# Groups are positioned in canvas coordinates (affected by zoom/scroll)
	_groups_container = Control.new()
	_groups_container.name = "GroupsContainer"
	_groups_container.mouse_filter = Control.MOUSE_FILTER_PASS
	_groups_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_groups_container)
	# Move to back so it renders behind nodes
	move_child(_groups_container, 0)


func _setup_group_title_dialog() -> void:
	_group_title_edit_dialog = AcceptDialog.new()
	_group_title_edit_dialog.name = "GroupTitleDialog"
	_group_title_edit_dialog.title = "Edit Group Name"
	_group_title_edit_dialog.size = Vector2(300, 100)

	var title_edit = LineEdit.new()
	title_edit.name = "TitleEdit"
	title_edit.placeholder_text = "Enter group name..."
	title_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_group_title_edit_dialog.add_child(title_edit)
	_group_title_edit_dialog.confirmed.connect(_on_group_title_confirmed)
	add_child(_group_title_edit_dialog)


## Populate context menu based on current selection state.
func _populate_context_menu() -> void:
	_context_menu.clear()

	var selected = get_selected_nodes()
	var has_selection = selected.size() > 0

	# If nodes are selected, show selection-specific options first
	if has_selection:
		_context_menu.add_item("Create Group from Selection", 101)
		_context_menu.add_item("Save as Template...", 100)
		_context_menu.add_separator()

	# Core node types
	_context_menu.add_item("Add Start Node", 0)
	_context_menu.add_item("Add Speaker Node", 1)
	_context_menu.add_item("Add Choice Node", 2)
	_context_menu.add_item("Add Branch Node", 3)
	_context_menu.add_item("Add End Node", 4)
	_context_menu.add_separator()

	# Advanced node types (Phase 2)
	_context_menu.add_item("Add Skill Check", 20)
	_context_menu.add_item("Add Flag Check", 21)
	_context_menu.add_item("Add Set Flag", 22)
	_context_menu.add_item("Add Quest", 23)
	_context_menu.add_item("Add Reputation", 24)
	_context_menu.add_item("Add Item", 25)
	_context_menu.add_item("Add Set Variables", 26)
	_context_menu.add_separator()

	# Insert Template submenu
	_populate_template_submenu()
	if _available_templates.size() > 0:
		_context_menu.add_submenu_node_item("Insert Template", _template_submenu)
		_context_menu.add_separator()

	_context_menu.add_item("Paste", 10)


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

	# Node movement tracking for undo/redo
	begin_node_move.connect(_on_begin_node_move)
	end_node_move.connect(_on_end_node_move)


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

	# Create the connection with undo/redo support
	_ensure_undo_redo()
	_undo_redo.create_action("Connect Nodes")
	_undo_redo.add_do_method(self._do_connect_nodes.bind(String(from_node), from_port, String(to_node), to_port))
	_undo_redo.add_undo_method(self._undo_connect_nodes.bind(String(from_node), from_port, String(to_node), to_port))
	_undo_redo.commit_action()
	undo_redo_changed.emit()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	# Disconnect with undo/redo support
	_ensure_undo_redo()
	_undo_redo.create_action("Disconnect Nodes")
	_undo_redo.add_do_method(self._do_disconnect_nodes.bind(String(from_node), from_port, String(to_node), to_port))
	_undo_redo.add_undo_method(self._do_connect_nodes.bind(String(from_node), from_port, String(to_node), to_port))
	_undo_redo.commit_action()
	undo_redo_changed.emit()


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


## Do method for connecting nodes (used by undo/redo).
func _do_connect_nodes(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	var error = connect_node(from_node, from_port, to_node, to_port)
	if error == OK:
		_track_connection_added(from_node, from_port, to_node, to_port)
		canvas_changed.emit()
		print("DialogueCanvas: Connected %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])


## Undo method for connecting nodes (disconnects them).
func _undo_connect_nodes(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	_do_disconnect_nodes(from_node, from_port, to_node, to_port)


## Do method for disconnecting nodes (used by undo/redo).
func _do_disconnect_nodes(from_node: String, from_port: int, to_node: String, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	_track_connection_removed(from_node, from_port, to_node, to_port)
	canvas_changed.emit()
	print("DialogueCanvas: Disconnected %s:%d -> %s:%d" % [from_node, from_port, to_node, to_port])


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
# NODE MOVEMENT (UNDO/REDO)
# =============================================================================

func _on_begin_node_move() -> void:
	_is_dragging = true
	_node_drag_start_positions.clear()

	# Store starting positions of all selected nodes
	for child in get_children():
		if child is DialogueNodeScript and child.selected:
			_node_drag_start_positions[child.name] = child.position_offset


func _on_end_node_move() -> void:
	if not _is_dragging:
		return
	_is_dragging = false

	# Check if any nodes actually moved
	var moved_nodes: Array[Dictionary] = []
	for node_name in _node_drag_start_positions:
		var node = get_node_or_null(NodePath(node_name))
		if node and node is DialogueNodeScript:
			var start_pos = _node_drag_start_positions[node_name]
			var end_pos = node.position_offset
			if start_pos != end_pos:
				moved_nodes.append({
					"name": node_name,
					"start_pos": start_pos,
					"end_pos": end_pos
				})

	_node_drag_start_positions.clear()

	if moved_nodes.is_empty():
		return

	# Create undo action for the movement
	_ensure_undo_redo()
	var action_name = "Move %d Node(s)" % moved_nodes.size() if moved_nodes.size() > 1 else "Move Node"
	_undo_redo.create_action(action_name)

	for move_data in moved_nodes:
		_undo_redo.add_do_method(self._do_move_node.bind(move_data.name, move_data.end_pos))
		_undo_redo.add_undo_method(self._do_move_node.bind(move_data.name, move_data.start_pos))

	# Nodes are already at end positions, so we don't call do for the first time
	# Instead, we just commit without executing
	_undo_redo.commit_action(false)
	undo_redo_changed.emit()
	canvas_changed.emit()


## Do method for moving a node (used by undo/redo).
func _do_move_node(node_name: String, position: Vector2) -> void:
	var node = get_node_or_null(NodePath(node_name))
	if node and node is DialogueNodeScript:
		node.position_offset = position
		canvas_changed.emit()


# =============================================================================
# CONTEXT MENU
# =============================================================================

func _on_popup_request(position: Vector2) -> void:
	_context_menu_position = position
	_populate_context_menu()
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
		# Phase 2 Advanced Nodes
		20:  # Add Skill Check
			_create_dialogue_node("SkillCheck", local_pos)
		21:  # Add Flag Check
			_create_dialogue_node("FlagCheck", local_pos)
		22:  # Add Set Flag
			_create_dialogue_node("FlagSet", local_pos)
		23:  # Add Quest
			_create_dialogue_node("Quest", local_pos)
		24:  # Add Reputation
			_create_dialogue_node("Reputation", local_pos)
		25:  # Add Item
			_create_dialogue_node("Item", local_pos)
		26:  # Add SetExpression
			_create_dialogue_node("SetExpression", local_pos)
		# Template operations
		100:  # Save as Template
			save_as_template_requested.emit()
		101:  # Create Group from Selection
			create_group_from_selection()


## Populate the Insert Template submenu with available templates.
func _populate_template_submenu() -> void:
	_template_submenu.clear()
	_available_templates.clear()

	# Get template manager instance
	var manager = DialogueTemplateManager.get_instance()
	if not manager:
		return

	var all_templates = manager.get_all_templates()
	if all_templates.is_empty():
		return

	# Group templates by category
	var templates_by_category := {}
	for template in all_templates:
		var category = template.category if not template.category.is_empty() else "custom"
		if not templates_by_category.has(category):
			templates_by_category[category] = []
		templates_by_category[category].append(template)

	# Add templates to submenu grouped by category
	var template_id := 0
	var sorted_categories = templates_by_category.keys()
	sorted_categories.sort()

	for category in sorted_categories:
		# Add category header (disabled item)
		if template_id > 0:
			_template_submenu.add_separator()
		_template_submenu.add_item("— %s —" % category.capitalize(), -1)
		_template_submenu.set_item_disabled(_template_submenu.get_item_count() - 1, true)

		# Add templates in this category
		var category_templates = templates_by_category[category]
		for template in category_templates:
			var label = template.template_name
			if template.is_built_in:
				label += " (built-in)"
			_template_submenu.add_item(label, template_id)
			_available_templates.append(template)
			template_id += 1


## Handle template selection from submenu.
func _on_template_submenu_id_pressed(id: int) -> void:
	if id < 0 or id >= _available_templates.size():
		return

	var template = _available_templates[id]
	var local_pos = (scroll_offset + _context_menu_position) / zoom
	insert_template(template, local_pos)


## Insert a template at the specified canvas position.
## Creates all nodes from the template with unique IDs, positions them, and creates connections.
## Optionally auto-connects to a selected node's output.
func insert_template(template: DialogueTemplateData, insert_position: Vector2, auto_connect_from: GraphNode = null) -> Array[GraphNode]:
	if not template or template.nodes.is_empty():
		push_warning("DialogueCanvas: Cannot insert empty template")
		return []

	_ensure_undo_redo()
	_undo_redo.create_action("Insert Template '%s'" % template.template_name)

	# Get nodes at the target position
	var positioned_nodes = template.get_nodes_at_position(insert_position)

	# Generate new unique IDs for all nodes and build mapping
	var id_mapping := {}  # old_id -> new_id
	var created_nodes: Array[GraphNode] = []
	var new_node_names: Array[String] = []

	for node_data in positioned_nodes:
		var old_id = node_data.get("id", "")
		var node_type = node_data.get("type", "Speaker")
		var new_name = "%s_%d" % [node_type, _next_node_id]
		_next_node_id += 1

		id_mapping[old_id] = new_name
		new_node_names.append(new_name)

	# Create all nodes (using undo/redo methods)
	var node_index := 0
	for node_data in positioned_nodes:
		var node_type = node_data.get("type", "Speaker")
		var position = Vector2(
			node_data.get("position_x", 0.0),
			node_data.get("position_y", 0.0)
		)
		var new_name = new_node_names[node_index]

		# Add do/undo methods for node creation
		_undo_redo.add_do_method(self._do_create_node_from_template.bind(node_type, new_name, position, node_data))
		_undo_redo.add_undo_method(self._undo_create_node.bind(new_name))

		node_index += 1

	# Get remapped connections
	var remapped_connections = template.get_connections_remapped(id_mapping)

	# Add do/undo methods for connections
	for conn in remapped_connections:
		_undo_redo.add_do_method(self._do_connect_nodes.bind(conn.from_node, conn.from_port, conn.to_node, conn.to_port))
		_undo_redo.add_undo_method(self._do_disconnect_nodes.bind(conn.from_node, conn.from_port, conn.to_node, conn.to_port))

	# Auto-connect from selected node if provided
	if auto_connect_from and auto_connect_from is DialogueNodeScript:
		# Find the first entry point in the template (node with no incoming connections)
		var entry_node_name = _find_template_entry_point(template, id_mapping)
		if not entry_node_name.is_empty() and auto_connect_from.can_provide_output():
			# Find the first available output port
			var from_port = 0  # Default to first port
			_undo_redo.add_do_method(self._do_connect_nodes.bind(auto_connect_from.name, from_port, entry_node_name, 0))
			_undo_redo.add_undo_method(self._do_disconnect_nodes.bind(auto_connect_from.name, from_port, entry_node_name, 0))

	# Add do method to select all new nodes after creation
	_undo_redo.add_do_method(self._do_select_nodes.bind(new_node_names))
	_undo_redo.add_undo_method(self.deselect_all_nodes)

	_undo_redo.commit_action()
	undo_redo_changed.emit()

	# Get created nodes for return
	for node_name in new_node_names:
		var node = get_node_or_null(NodePath(node_name))
		if node:
			created_nodes.append(node)

	print("DialogueCanvas: Inserted template '%s' with %d nodes" % [template.template_name, created_nodes.size()])
	return created_nodes


## Create a node from template data (includes deserialization).
func _do_create_node_from_template(type: String, node_name: String, position: Vector2, node_data: Dictionary) -> void:
	var node = _do_create_node_internal(type, node_name, position)
	if node:
		# Update the ID in node_data to use new name before deserializing
		var data_copy = node_data.duplicate()
		data_copy["id"] = node_name
		data_copy["position_x"] = position.x
		data_copy["position_y"] = position.y
		node.deserialize(data_copy)


## Find the entry point node in a template (node with no incoming connections).
## Returns the new (remapped) node name.
func _find_template_entry_point(template: DialogueTemplateData, id_mapping: Dictionary) -> String:
	# Build set of nodes that have incoming connections
	var nodes_with_incoming := {}
	for conn in template.connections:
		var to_node = conn.get("to_node", "")
		nodes_with_incoming[to_node] = true

	# Find first node without incoming connections (prefer Start nodes)
	for node in template.nodes:
		var old_id = node.get("id", "")
		var node_type = node.get("type", "")
		if node_type == "Start" and not nodes_with_incoming.has(old_id):
			return id_mapping.get(old_id, "")

	# Fallback: any node without incoming connections
	for node in template.nodes:
		var old_id = node.get("id", "")
		if not nodes_with_incoming.has(old_id):
			return id_mapping.get(old_id, "")

	# No entry point found, return first node
	if not template.nodes.is_empty():
		var first_id = template.nodes[0].get("id", "")
		return id_mapping.get(first_id, "")

	return ""


## Select multiple nodes by name.
func _do_select_nodes(node_names: Array[String]) -> void:
	deselect_all_nodes()
	for node_name in node_names:
		var node = get_node_or_null(NodePath(node_name))
		if node and node is DialogueNodeScript:
			node.selected = true


func _create_dialogue_node(type: String, position: Vector2, use_undo_redo: bool = true) -> GraphNode:
	var node_name = "%s_%d" % [type, _next_node_id]

	if use_undo_redo:
		# Create with undo/redo support
		_ensure_undo_redo()
		_undo_redo.create_action("Add %s Node" % type)
		_undo_redo.add_do_method(self._do_create_node.bind(type, node_name, position))
		_undo_redo.add_undo_method(self._undo_create_node.bind(node_name))
		_undo_redo.commit_action()
		undo_redo_changed.emit()
		return get_node_or_null(NodePath(node_name))
	else:
		# Create directly without undo/redo (used for deserialization)
		return _do_create_node_internal(type, node_name, position)


## Internal method to actually create a node.
func _do_create_node_internal(type: String, node_name: String, position: Vector2) -> GraphNode:
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
		# Phase 2 Advanced Nodes
		"SkillCheck":
			node = SkillCheckNodeScript.new()
		"FlagCheck":
			node = FlagCheckNodeScript.new()
		"FlagSet":
			node = FlagSetNodeScript.new()
		"Quest":
			node = QuestNodeScript.new()
		"Reputation":
			node = ReputationNodeScript.new()
		"Item":
			node = ItemNodeScript.new()
		"SetExpression":
			node = SetExpressionNodeScript.new()
		_:
			push_error("DialogueCanvas: Unknown node type: %s" % type)
			return null

	# Configure the node
	node.name = node_name
	node.node_id = node_name
	node.position_offset = position

	# Connect to data changed signal
	node.data_changed.connect(_on_node_data_changed.bind(node))

	add_child(node)
	_next_node_id += 1
	canvas_changed.emit()
	print("DialogueCanvas: Added %s node at %s" % [type, position])
	return node


## Do method for creating a node (used by undo/redo).
func _do_create_node(type: String, node_name: String, position: Vector2) -> void:
	_do_create_node_internal(type, node_name, position)


## Undo method for creating a node (deletes it).
func _undo_create_node(node_name: String) -> void:
	var node = get_node_or_null(NodePath(node_name))
	if node and node is DialogueNodeScript:
		# Remove all connections to/from this node
		var connections_to_remove: Array[Dictionary] = []
		for conn in get_connection_list():
			if String(conn.from_node) == node_name or String(conn.to_node) == node_name:
				connections_to_remove.append(conn)

		for conn in connections_to_remove:
			disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			_track_connection_removed(conn.from_node, conn.from_port, conn.to_node, conn.to_port)

		node.clear_connections()
		node.queue_free()
		canvas_changed.emit()
		print("DialogueCanvas: Undid creation of node %s" % node_name)


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
	# Accept drops from the template library
	if data is Dictionary and data.get("type") == "dialogue_template":
		return true
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "dialogue_node":
		var node_type = data.get("node_type", "Speaker")
		# Convert screen position to canvas position
		var canvas_pos = (scroll_offset + at_position) / zoom
		add_dialogue_node(node_type, canvas_pos)
	elif data is Dictionary and data.get("type") == "dialogue_template":
		var template = data.get("template")
		if template:
			# Convert screen position to canvas position
			var canvas_pos = (scroll_offset + at_position) / zoom
			insert_template(template, canvas_pos)


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
	if nodes.is_empty():
		return

	# Ensure undo/redo is initialized
	_ensure_undo_redo()

	# Create a single undo action for all deletions
	var action_name = "Delete %d Node(s)" % nodes.size() if nodes.size() > 1 else "Delete Node"
	_undo_redo.create_action(action_name)

	for node_name in nodes:
		var node = get_node_or_null(NodePath(node_name))
		if node and node is DialogueNodeScript:
			# Serialize node data for undo
			var node_data = node.serialize()
			var node_type = node.node_type

			# Gather connections to/from this node
			var node_connections: Array[Dictionary] = []
			for conn in get_connection_list():
				if String(conn.from_node) == String(node_name) or String(conn.to_node) == String(node_name):
					node_connections.append({
						"from_node": String(conn.from_node),
						"from_port": conn.from_port,
						"to_node": String(conn.to_node),
						"to_port": conn.to_port
					})

			# Add do/undo methods
			_undo_redo.add_do_method(self._do_delete_node.bind(String(node_name)))
			_undo_redo.add_undo_method(self._undo_delete_node.bind(node_type, node_data, node_connections))

	_undo_redo.commit_action()
	undo_redo_changed.emit()


## Do method for deleting a node (used by undo/redo).
func _do_delete_node(node_name: String) -> void:
	var node = get_node_or_null(NodePath(node_name))
	if node and node is DialogueNodeScript:
		# Remove all connections to/from this node
		var connections_to_remove: Array[Dictionary] = []
		for conn in get_connection_list():
			if String(conn.from_node) == node_name or String(conn.to_node) == node_name:
				connections_to_remove.append(conn)

		for conn in connections_to_remove:
			disconnect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			_track_connection_removed(conn.from_node, conn.from_port, conn.to_node, conn.to_port)

		node.clear_connections()
		node.queue_free()
		canvas_changed.emit()
		print("DialogueCanvas: Deleted node %s" % node_name)


## Undo method for deleting a node (recreates it).
func _undo_delete_node(node_type: String, node_data: Dictionary, connections: Array[Dictionary]) -> void:
	# Recreate the node
	var position = Vector2(
		node_data.get("position_x", 0),
		node_data.get("position_y", 0)
	)
	var node_name = node_data.get("id", "")

	# We need to create the node without using undo/redo (since we're already in an undo action)
	var node = _do_create_node_internal(node_type, node_name, position)
	if node:
		node.deserialize(node_data)

		# Restore connections
		for conn in connections:
			connect_node(conn.from_node, conn.from_port, conn.to_node, conn.to_port)
			_track_connection_added(conn.from_node, conn.from_port, conn.to_node, conn.to_port)

		canvas_changed.emit()
		print("DialogueCanvas: Restored node %s" % node_name)


# =============================================================================
# PUBLIC API
# =============================================================================

func clear_canvas(clear_undo_history: bool = true) -> void:
	"""Remove all nodes, connections, and groups."""
	# Clear connections first
	clear_connections()

	# Remove all DialogueNode children and their connection tracking
	for child in get_children():
		if child is DialogueNodeScript:
			child.clear_connections()
			child.queue_free()

	# Clear groups
	clear_groups()

	_next_node_id = 1

	# Clear undo history when starting fresh
	if clear_undo_history and _undo_redo:
		_undo_redo.clear_history()
		undo_redo_changed.emit()

	canvas_changed.emit()


func _sync_next_node_id() -> void:
	"""Update _next_node_id to be higher than any existing node IDs to prevent collisions."""
	var max_id := 0

	for child in get_children():
		if child is DialogueNodeScript:
			# Extract numeric ID from node name (e.g., "Speaker_42" -> 42)
			var node_name = child.name
			var underscore_pos = node_name.rfind("_")
			if underscore_pos > 0:
				var id_str = node_name.substr(underscore_pos + 1)
				if id_str.is_valid_int():
					var id_num = id_str.to_int()
					if id_num > max_id:
						max_id = id_num

	# Set _next_node_id to one higher than the max found
	_next_node_id = max_id + 1


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
		"groups": [],
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

	# Serialize groups
	data.groups = serialize_groups()

	return data


func deserialize(data: Dictionary) -> void:
	"""Load a dialogue tree from a Dictionary."""
	# Clear existing content (without undo tracking)
	clear_canvas(false)

	# Check tree size for performance handling
	var node_count = data.nodes.size() if data.has("nodes") else 0
	_is_large_tree = node_count >= LARGE_TREE_THRESHOLD

	# Disable minimap for very large trees (performance optimization)
	if node_count >= VERY_LARGE_TREE_THRESHOLD:
		minimap_enabled = false
		push_warning("DialogueEditor: Very large dialogue tree (%d nodes). Minimap disabled for performance." % node_count)

	# Restore view settings
	if data.has("scroll_offset"):
		scroll_offset = Vector2(data.scroll_offset.x, data.scroll_offset.y)
	if data.has("zoom"):
		zoom = data.zoom

	# Create nodes (without undo/redo - we're loading, not user action)
	var node_map := {}  # Maps old node IDs to new node names
	if data.has("nodes"):
		for node_data in data.nodes:
			var node_type = node_data.get("type", "Speaker")
			var position = Vector2(
				node_data.get("position_x", 0),
				node_data.get("position_y", 0)
			)

			var node = _create_dialogue_node(node_type, position, false)  # false = no undo/redo
			if node:
				node.deserialize(node_data)
				node_map[node_data.get("id", "")] = node.name

	# Restore connections (without undo tracking)
	if data.has("connections"):
		for conn in data.connections:
			var from_name = node_map.get(conn.from_node, conn.from_node)
			var to_name = node_map.get(conn.to_node, conn.to_node)
			connect_node(from_name, conn.from_port, to_name, conn.to_port)
			_track_connection_added(from_name, conn.from_port, to_name, conn.to_port)

	# Restore groups
	clear_groups()
	if data.has("groups"):
		for group_data in data.groups:
			_create_group_from_data(group_data)

	# Update _next_node_id to avoid collisions with existing nodes
	_sync_next_node_id()

	# Clear undo history after loading a file
	_undo_redo.clear_history()
	undo_redo_changed.emit()
	canvas_changed.emit()


## Check if current tree is considered large (for performance decisions).
func is_large_tree() -> bool:
	return _is_large_tree


## Get performance status for UI display.
func get_performance_status() -> Dictionary:
	var count = get_node_count()
	return {
		"node_count": count,
		"is_large": count >= LARGE_TREE_THRESHOLD,
		"is_very_large": count >= VERY_LARGE_TREE_THRESHOLD,
		"minimap_enabled": minimap_enabled
	}


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


# =============================================================================
# UNDO/REDO PUBLIC API
# =============================================================================

## Perform an undo operation.
func undo() -> void:
	if _undo_redo and _undo_redo.has_undo():
		_undo_redo.undo()
		undo_redo_changed.emit()
		canvas_changed.emit()


## Perform a redo operation.
func redo() -> void:
	if _undo_redo and _undo_redo.has_redo():
		_undo_redo.redo()
		undo_redo_changed.emit()
		canvas_changed.emit()


## Check if undo is available.
func has_undo() -> bool:
	return _undo_redo and _undo_redo.has_undo()


## Check if redo is available.
func has_redo() -> bool:
	return _undo_redo and _undo_redo.has_redo()


## Get the name of the current undo action.
func get_current_action_name() -> String:
	if _undo_redo and _undo_redo.has_undo():
		return _undo_redo.get_current_action_name()
	return ""


## Get the name of the next redo action.
func get_redo_action_name() -> String:
	# UndoRedo doesn't directly expose this, but we can check if redo is available
	if _undo_redo and _undo_redo.has_redo():
		return "Redo"
	return ""


## Record a property change for undo/redo.
## Call this before making a property change to a node.
func begin_property_change(node: GraphNode, property_name: String, old_value: Variant) -> void:
	if not node or not _undo_redo:
		return

	# Store the pending change info
	_pending_property_change = {
		"node_name": node.name,
		"property": property_name,
		"old_value": old_value
	}


## Complete the property change for undo/redo.
## Call this after making a property change to a node.
func end_property_change(node: GraphNode, property_name: String, new_value: Variant) -> void:
	if not node or not _undo_redo:
		return

	if not _pending_property_change or _pending_property_change.node_name != node.name:
		return

	var old_value = _pending_property_change.old_value
	_pending_property_change = {}

	if old_value == new_value:
		return

	_ensure_undo_redo()
	_undo_redo.create_action("Change %s" % property_name.capitalize())
	_undo_redo.add_do_method(self._do_set_property.bind(node.name, property_name, new_value))
	_undo_redo.add_undo_method(self._do_set_property.bind(node.name, property_name, old_value))
	_undo_redo.commit_action(false)  # Don't execute, property is already changed
	undo_redo_changed.emit()


## Do method for setting a property (used by undo/redo).
func _do_set_property(node_name: String, property_name: String, value: Variant) -> void:
	var node = get_node_or_null(NodePath(node_name))
	if node:
		node.set(property_name, value)
		canvas_changed.emit()


# Pending property change for undo/redo
var _pending_property_change: Dictionary = {}


# =============================================================================
# AUTO-LAYOUT
# =============================================================================

## Auto-layout nodes in a readable left-to-right tree structure.
## Dynamically calculates spacing based on actual node sizes to prevent overlap.
func auto_layout() -> void:
	var nodes = get_all_dialogue_nodes()
	if nodes.is_empty():
		return

	# Padding between nodes
	const HORIZONTAL_PADDING := 80  # Gap between layers
	const VERTICAL_PADDING := 40    # Gap between nodes in same layer
	const START_X := 100
	const START_Y := 100

	# Find start node
	var start_node = get_start_node()
	if not start_node:
		# No start node - just arrange all nodes in a grid
		_layout_as_grid(nodes)
		return

	# Assign nodes to layers using BFS
	var layers: Dictionary = {}  # layer_index -> Array of nodes
	var node_layers: Dictionary = {}  # node_name -> layer_index
	var visited: Dictionary = {}
	var queue: Array[Dictionary] = []

	# Start from the start node at layer 0
	queue.append({"node": start_node, "layer": 0})
	visited[start_node.name] = true

	while not queue.is_empty():
		var current = queue.pop_front()
		var node = current.node
		var layer = current.layer

		# Assign this node to its layer
		node_layers[node.name] = layer
		if not layers.has(layer):
			layers[layer] = []
		layers[layer].append(node)

		# Get all nodes connected from this node's outputs
		var connections = get_connections_from(node.name)
		for conn in connections:
			var target_name = conn.to_node
			if not visited.has(target_name):
				var target_node = get_node_or_null(NodePath(target_name))
				if target_node and target_node is DialogueNodeScript:
					visited[target_name] = true
					queue.append({"node": target_node, "layer": layer + 1})

	# Handle orphaned nodes (not connected to start) - put them in their own layers at the end
	var max_layer = 0
	for layer_idx in layers.keys():
		max_layer = max(max_layer, layer_idx)

	var orphans: Array[GraphNode] = []
	for node in nodes:
		if not visited.has(node.name):
			orphans.append(node)

	if not orphans.is_empty():
		max_layer += 1
		layers[max_layer] = orphans

	# Store old positions for undo
	var old_positions: Dictionary = {}
	for node in nodes:
		old_positions[node.name] = node.position_offset

	# Calculate the maximum width for each layer and position accordingly
	var layer_x_positions: Dictionary = {}  # layer_index -> x position
	var current_x := START_X

	# Get sorted layer indices
	var sorted_layers = layers.keys()
	sorted_layers.sort()

	for layer_idx in sorted_layers:
		layer_x_positions[layer_idx] = current_x

		# Find max width in this layer
		var max_width := 0.0
		for node in layers[layer_idx]:
			# Use node.size if available, otherwise use a default
			var node_width = node.size.x if node.size.x > 0 else 280.0
			max_width = max(max_width, node_width)

		# Move x position for next layer
		current_x += max_width + HORIZONTAL_PADDING

	# Position nodes by layer with dynamic vertical spacing
	for layer_idx in sorted_layers:
		var layer_nodes: Array = layers[layer_idx]
		var x = layer_x_positions[layer_idx]

		# Calculate y positions based on actual node heights
		var current_y := START_Y
		for node in layer_nodes:
			node.position_offset = Vector2(x, current_y)
			# Get actual node height, use default if not available
			var node_height = node.size.y if node.size.y > 0 else 150.0
			current_y += node_height + VERTICAL_PADDING

	# Create undo action for the layout change
	_ensure_undo_redo()
	_undo_redo.create_action("Auto Layout")

	for node in nodes:
		var old_pos = old_positions[node.name]
		var new_pos = node.position_offset
		if old_pos != new_pos:
			_undo_redo.add_do_method(self._do_move_node.bind(node.name, new_pos))
			_undo_redo.add_undo_method(self._do_move_node.bind(node.name, old_pos))

	_undo_redo.commit_action(false)  # Nodes are already moved
	undo_redo_changed.emit()
	canvas_changed.emit()
	print("DialogueCanvas: Auto-layout complete (%d layers, %d nodes)" % [layers.size(), nodes.size()])


## Fallback grid layout when no start node exists.
func _layout_as_grid(nodes: Array[GraphNode]) -> void:
	const HORIZONTAL_PADDING := 80
	const VERTICAL_PADDING := 40
	const COLUMNS := 4
	const START_X := 100
	const START_Y := 100

	var old_positions: Dictionary = {}
	for node in nodes:
		old_positions[node.name] = node.position_offset

	# Find max node dimensions for uniform grid
	var max_width := 280.0
	var max_height := 150.0
	for node in nodes:
		if node.size.x > 0:
			max_width = max(max_width, node.size.x)
		if node.size.y > 0:
			max_height = max(max_height, node.size.y)

	var cell_width = max_width + HORIZONTAL_PADDING
	var cell_height = max_height + VERTICAL_PADDING

	for i in nodes.size():
		var row = i / COLUMNS
		var col = i % COLUMNS
		nodes[i].position_offset = Vector2(
			START_X + col * cell_width,
			START_Y + row * cell_height
		)

	# Create undo action
	_ensure_undo_redo()
	_undo_redo.create_action("Auto Layout (Grid)")

	for node in nodes:
		var old_pos = old_positions[node.name]
		var new_pos = node.position_offset
		if old_pos != new_pos:
			_undo_redo.add_do_method(self._do_move_node.bind(node.name, new_pos))
			_undo_redo.add_undo_method(self._do_move_node.bind(node.name, old_pos))

	_undo_redo.commit_action(false)
	undo_redo_changed.emit()
	canvas_changed.emit()


# =============================================================================
# SELECTION OPERATIONS
# =============================================================================

## Get all currently selected nodes.
func get_selected_nodes() -> Array[GraphNode]:
	var selected: Array[GraphNode] = []
	for child in get_children():
		if child is DialogueNodeScript and child.selected:
			selected.append(child)
	return selected


## Select all dialogue nodes on the canvas.
func select_all_nodes() -> void:
	for child in get_children():
		if child is DialogueNodeScript:
			child.selected = true


## Deselect all dialogue nodes on the canvas.
func deselect_all_nodes() -> void:
	for child in get_children():
		if child is DialogueNodeScript:
			child.selected = false
	dialogue_node_deselected.emit()


## Delete all selected nodes.
func delete_selected_nodes() -> void:
	var selected = get_selected_nodes()
	if selected.is_empty():
		return

	var node_names: Array[StringName] = []
	for node in selected:
		node_names.append(StringName(node.name))

	# Trigger the delete request handler
	_on_delete_nodes_request(node_names)


## Duplicate all selected nodes with offset.
func duplicate_selected_nodes() -> void:
	var selected = get_selected_nodes()
	if selected.is_empty():
		return

	_ensure_undo_redo()
	_undo_redo.create_action("Duplicate %d Node(s)" % selected.size() if selected.size() > 1 else "Duplicate Node")

	var new_nodes: Array[GraphNode] = []
	var offset := Vector2(50, 50)  # Offset for duplicated nodes

	# First, create all duplicated nodes
	for node in selected:
		var node_type = node.node_type
		var new_position = node.position_offset + offset
		var node_data = node.serialize()

		# Create new node (internal, no undo tracking)
		var new_node = _create_dialogue_node(node_type, new_position, false)
		if new_node:
			# Copy properties from original (except ID and position)
			var original_id = node_data.get("id", "")
			node_data["id"] = new_node.name  # Use new ID
			node_data["position_x"] = new_position.x
			node_data["position_y"] = new_position.y
			new_node.deserialize(node_data)
			new_nodes.append(new_node)

			# Add undo/redo actions
			_undo_redo.add_do_reference(new_node)
			_undo_redo.add_undo_method(self._do_delete_node.bind(new_node.name))

	_undo_redo.commit_action(false)  # Nodes already created
	undo_redo_changed.emit()

	# Deselect originals, select duplicates
	for node in selected:
		node.selected = false
	for node in new_nodes:
		node.selected = true

	canvas_changed.emit()
	print("DialogueCanvas: Duplicated %d node(s)" % new_nodes.size())


## Serialize all selected nodes to an array of dictionaries.
## Used for creating templates from selection.
func serialize_selected_nodes() -> Array:
	var selected = get_selected_nodes()
	var serialized: Array = []

	for node in selected:
		if node is DialogueNodeScript:
			serialized.append(node.serialize())

	return serialized


## Get all connections that are internal to the selected nodes.
## Returns only connections where both from_node and to_node are selected.
func get_selected_internal_connections() -> Array:
	var selected = get_selected_nodes()
	if selected.size() < 2:
		return []

	# Build set of selected node names
	var selected_names := {}
	for node in selected:
		selected_names[node.name] = true

	# Find internal connections
	var internal_connections: Array = []
	for conn in get_connection_list():
		var from_name = String(conn.from_node)
		var to_name = String(conn.to_node)

		if selected_names.has(from_name) and selected_names.has(to_name):
			internal_connections.append({
				"from_node": from_name,
				"from_port": conn.from_port,
				"to_node": to_name,
				"to_port": conn.to_port
			})

	return internal_connections


## Check if the current selection is valid for creating a template.
## Returns a dictionary with "valid" bool and "reason" string.
func validate_selection_for_template() -> Dictionary:
	var selected = get_selected_nodes()

	if selected.is_empty():
		return {"valid": false, "reason": "No nodes selected"}

	if selected.size() < 2:
		return {"valid": false, "reason": "Select at least 2 nodes"}

	var internal_connections = get_selected_internal_connections()
	if internal_connections.is_empty():
		return {"valid": false, "reason": "Selected nodes should be connected"}

	return {"valid": true, "reason": ""}


# =============================================================================
# NODE GROUPS
# =============================================================================

## Predefined group colors for variety.
const GROUP_COLORS: Array[Color] = [
	Color(0.3, 0.5, 0.7, 0.25),   # Blue
	Color(0.3, 0.7, 0.4, 0.25),   # Green
	Color(0.7, 0.5, 0.3, 0.25),   # Orange
	Color(0.6, 0.3, 0.6, 0.25),   # Purple
	Color(0.7, 0.3, 0.3, 0.25),   # Red
	Color(0.7, 0.7, 0.3, 0.25),   # Yellow
	Color(0.3, 0.7, 0.7, 0.25),   # Cyan
]


## Create a new group around the selected nodes.
func create_group_from_selection() -> Control:
	var selected = get_selected_nodes()
	if selected.is_empty():
		print("DialogueCanvas: No nodes selected to create group")
		return null

	# Calculate bounding box of selected nodes
	var bounds = _calculate_selection_bounds(selected)

	# Add padding around the bounding box
	const PADDING := 30
	bounds = bounds.grow(PADDING)

	# Create the group with undo/redo
	var group_id = "Group_%d" % _next_group_id
	var group_name = "Group %d" % _next_group_id
	var color_index = (_next_group_id - 1) % GROUP_COLORS.size()
	var group_color = GROUP_COLORS[color_index]

	_ensure_undo_redo()
	_undo_redo.create_action("Create Group")
	_undo_redo.add_do_method(self._do_create_group.bind(group_id, group_name, group_color, bounds.position, bounds.size, selected))
	_undo_redo.add_undo_method(self._undo_create_group.bind(group_id))
	_undo_redo.commit_action()
	undo_redo_changed.emit()

	return get_group_by_id(group_id)


## Calculate the bounding box of the selected nodes.
func _calculate_selection_bounds(nodes: Array[GraphNode]) -> Rect2:
	if nodes.is_empty():
		return Rect2()

	var min_pos = nodes[0].position_offset
	var max_pos = nodes[0].position_offset + nodes[0].size

	for node in nodes:
		var node_pos = node.position_offset
		var node_end = node_pos + node.size

		min_pos.x = min(min_pos.x, node_pos.x)
		min_pos.y = min(min_pos.y, node_pos.y)
		max_pos.x = max(max_pos.x, node_end.x)
		max_pos.y = max(max_pos.y, node_end.y)

	return Rect2(min_pos, max_pos - min_pos)


## Do method for creating a group (used by undo/redo).
func _do_create_group(group_id: String, group_name: String, color: Color, position: Vector2, group_size: Vector2, nodes: Array[GraphNode]) -> void:
	var group = NodeGroupScript.new()
	group.name = group_id
	group.group_id = group_id
	group.group_name = group_name
	group.group_color = color
	group.position = position
	group.size = group_size

	# Add contained node IDs
	for node in nodes:
		group.contained_node_ids.append(node.name)

	# Connect signals
	group.group_changed.connect(_on_group_changed.bind(group))
	group.title_edit_requested.connect(_on_group_title_edit_requested)
	group.move_started.connect(_on_group_move_started.bind(group))
	group.move_ended.connect(_on_group_move_ended.bind(group))

	_groups_container.add_child(group)
	_next_group_id += 1
	canvas_changed.emit()
	print("DialogueCanvas: Created group '%s' with %d nodes" % [group_name, nodes.size()])


## Undo method for creating a group (deletes it).
func _undo_create_group(group_id: String) -> void:
	var group = get_group_by_id(group_id)
	if group:
		group.queue_free()
		canvas_changed.emit()
		print("DialogueCanvas: Undid creation of group %s" % group_id)


## Create a group directly (for deserialization).
func _create_group_from_data(data: Dictionary) -> Control:
	var group = NodeGroupScript.new()
	group.deserialize(data)
	group.name = group.group_id

	# Connect signals
	group.group_changed.connect(_on_group_changed.bind(group))
	group.title_edit_requested.connect(_on_group_title_edit_requested)
	group.move_started.connect(_on_group_move_started.bind(group))
	group.move_ended.connect(_on_group_move_ended.bind(group))

	_groups_container.add_child(group)

	# Update _next_group_id if needed
	var id_num = _extract_group_id_number(group.group_id)
	if id_num >= _next_group_id:
		_next_group_id = id_num + 1

	return group


## Extract the numeric ID from a group ID string.
func _extract_group_id_number(group_id: String) -> int:
	var underscore_pos = group_id.rfind("_")
	if underscore_pos > 0:
		var id_str = group_id.substr(underscore_pos + 1)
		if id_str.is_valid_int():
			return id_str.to_int()
	return 0


## Get a group by its ID.
func get_group_by_id(group_id: String) -> Control:
	if not _groups_container:
		return null
	return _groups_container.get_node_or_null(NodePath(group_id))


## Get all groups.
func get_all_groups() -> Array[Control]:
	var groups: Array[Control] = []
	if _groups_container:
		for child in _groups_container.get_children():
			if child is NodeGroupScript:
				groups.append(child)
	return groups


## Delete a group.
func delete_group(group: Control) -> void:
	if not group or not group is NodeGroupScript:
		return

	var group_id = group.group_id
	var group_data = group.serialize()

	_ensure_undo_redo()
	_undo_redo.create_action("Delete Group")
	_undo_redo.add_do_method(self._do_delete_group.bind(group_id))
	_undo_redo.add_undo_method(self._undo_delete_group.bind(group_data))
	_undo_redo.commit_action()
	undo_redo_changed.emit()


## Do method for deleting a group.
func _do_delete_group(group_id: String) -> void:
	var group = get_group_by_id(group_id)
	if group:
		group.queue_free()
		canvas_changed.emit()
		print("DialogueCanvas: Deleted group %s" % group_id)


## Undo method for deleting a group.
func _undo_delete_group(group_data: Dictionary) -> void:
	_create_group_from_data(group_data)
	canvas_changed.emit()


## Handle group changed signal.
func _on_group_changed(group: Control) -> void:
	# If we're dragging this group, move contained nodes in real-time
	if _group_drag_node_positions.size() > 0:
		var delta = group.position - _group_drag_start_position
		for node_id in _group_drag_node_positions:
			var node = get_node_or_null(NodePath(node_id))
			if node and node is GraphNode:
				var start_pos: Vector2 = _group_drag_node_positions[node_id]
				node.position_offset = start_pos + delta

	canvas_changed.emit()


## Handle group move started - store initial positions.
func _on_group_move_started(group: Control) -> void:
	_group_drag_start_position = group.position
	_group_drag_node_positions.clear()

	# Store starting positions of all contained nodes
	for node_id in group.contained_node_ids:
		var node = get_node_or_null(NodePath(node_id))
		if node and node is GraphNode:
			_group_drag_node_positions[node_id] = node.position_offset


## Handle group move ended - finalize node movements.
func _on_group_move_ended(group: Control) -> void:
	_group_drag_node_positions.clear()
	canvas_changed.emit()


## Handle group title edit request.
func _on_group_title_edit_requested(group: Control) -> void:
	_editing_group = group
	var title_edit = _group_title_edit_dialog.get_node("TitleEdit") as LineEdit
	if title_edit:
		title_edit.text = group.group_name
		title_edit.select_all()
	_group_title_edit_dialog.popup_centered()


## Handle group title confirmed.
func _on_group_title_confirmed() -> void:
	if not _editing_group:
		return

	var title_edit = _group_title_edit_dialog.get_node("TitleEdit") as LineEdit
	if title_edit:
		var old_name = _editing_group.group_name
		var new_name = title_edit.text.strip_edges()
		if new_name.is_empty():
			new_name = "Group"

		if old_name != new_name:
			_ensure_undo_redo()
			_undo_redo.create_action("Rename Group")
			_undo_redo.add_do_method(self._do_rename_group.bind(_editing_group.group_id, new_name))
			_undo_redo.add_undo_method(self._do_rename_group.bind(_editing_group.group_id, old_name))
			_undo_redo.commit_action()
			undo_redo_changed.emit()

	_editing_group = null


## Do method for renaming a group.
func _do_rename_group(group_id: String, new_name: String) -> void:
	var group = get_group_by_id(group_id)
	if group:
		group.group_name = new_name
		canvas_changed.emit()


## Serialize all groups.
func serialize_groups() -> Array:
	var serialized: Array = []
	for group in get_all_groups():
		serialized.append(group.serialize())
	return serialized


## Clear all groups.
func clear_groups() -> void:
	if _groups_container:
		for child in _groups_container.get_children():
			child.queue_free()
	_next_group_id = 1