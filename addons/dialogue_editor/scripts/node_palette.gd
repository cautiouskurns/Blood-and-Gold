@tool
extends VBoxContainer
## Node palette for the Dialogue Tree Editor.
## Provides draggable buttons to create dialogue nodes on the canvas.

signal node_drag_started(node_type: String)
signal node_button_clicked(node_type: String)

# Node type definitions with display info
const NODE_TYPES = {
	"Start": {
		"description": "Entry point for dialogue",
		"color": Color.GREEN,
		"icon": "PlayStart"
	},
	"Speaker": {
		"description": "NPC dialogue line",
		"color": Color.CYAN,
		"icon": "AudioStreamPlayer"
	},
	"Choice": {
		"description": "Player response option",
		"color": Color.DODGER_BLUE,
		"icon": "GuiOptionArrow"
	},
	"Branch": {
		"description": "Conditional branch",
		"color": Color.ORANGE,
		"icon": "FileTree"
	},
	"End": {
		"description": "End dialogue",
		"color": Color.RED,
		"icon": "Stop"
	}
}

# Reference to buttons for styling
var _node_buttons: Dictionary = {}


func _ready() -> void:
	print("NodePalette: _ready called, child_count=%d" % get_child_count())
	call_deferred("_create_node_buttons")


func _enter_tree() -> void:
	print("NodePalette: _enter_tree called")


func _create_node_buttons() -> void:
	# Skip if buttons already exist
	if _node_buttons.size() > 0:
		print("NodePalette: Buttons already exist, skipping")
		return

	print("NodePalette: Creating %d node type buttons" % NODE_TYPES.size())

	# Add section header
	var header = Label.new()
	header.text = "MVP Nodes"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 12)
	add_child(header)

	var sep = HSeparator.new()
	add_child(sep)

	# Create buttons for each node type
	for node_type in NODE_TYPES:
		var btn = _create_node_button(node_type)
		add_child(btn)
		_node_buttons[node_type] = btn

	# Add separator for future Phase 2 nodes
	var phase2_sep = HSeparator.new()
	add_child(phase2_sep)

	var phase2_label = Label.new()
	phase2_label.text = "Phase 2 Nodes"
	phase2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase2_label.add_theme_font_size_override("font_size", 12)
	phase2_label.modulate = Color(1, 1, 1, 0.5)
	add_child(phase2_label)

	# Placeholder for Phase 2 nodes
	var coming_soon = Label.new()
	coming_soon.text = "(Coming in Phase 2)"
	coming_soon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coming_soon.add_theme_font_size_override("font_size", 10)
	coming_soon.modulate = Color(1, 1, 1, 0.3)
	add_child(coming_soon)


func _create_node_button(node_type: String) -> Button:
	var btn = Button.new()
	btn.text = node_type
	btn.tooltip_text = NODE_TYPES[node_type].description
	btn.custom_minimum_size = Vector2(0, 32)

	# Style the button with the node's color
	var style = StyleBoxFlat.new()
	style.bg_color = NODE_TYPES[node_type].color.darkened(0.6)
	style.border_color = NODE_TYPES[node_type].color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	btn.add_theme_stylebox_override("normal", style)

	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = NODE_TYPES[node_type].color.darkened(0.4)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = style.duplicate()
	pressed_style.bg_color = NODE_TYPES[node_type].color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Store node type in button metadata for drag
	btn.set_meta("node_type", node_type)

	# Also allow click to add (fallback)
	btn.pressed.connect(_on_node_button_pressed.bind(node_type))

	# Connect to gui_input for drag detection
	btn.gui_input.connect(_on_button_gui_input.bind(btn, node_type))

	return btn


func _on_button_gui_input(event: InputEvent, btn: Button, node_type: String) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Start drag
		var preview = _create_drag_preview(node_type)
		btn.force_drag({
			"type": "dialogue_node",
			"node_type": node_type
		}, preview)
		node_drag_started.emit(node_type)


func _create_drag_preview(node_type: String) -> Control:
	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(120, 40)

	var style = StyleBoxFlat.new()
	style.bg_color = NODE_TYPES[node_type].color.darkened(0.4)
	style.border_color = NODE_TYPES[node_type].color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	preview.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = node_type
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.add_child(label)

	return preview


func _on_node_button_pressed(node_type: String) -> void:
	# Emit signal so main panel can handle adding node at center of canvas
	node_button_clicked.emit(node_type)
	print("NodePalette: Clicked %s" % node_type)
