@tool
extends VBoxContainer
## Node palette for the Dialogue Tree Editor.
## Provides draggable buttons to create dialogue nodes on the canvas.

const SpeakerColorsScript = preload("res://addons/dialogue_editor/scripts/speaker_colors.gd")

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

# Phase 2 Advanced Node Types
const PHASE2_NODE_TYPES = {
	"SkillCheck": {
		"description": "Skill check with DC",
		"color": Color.PURPLE,
		"icon": "Dice"
	},
	"FlagCheck": {
		"description": "Check game flag value",
		"color": Color.YELLOW,
		"icon": "Search"
	},
	"FlagSet": {
		"description": "Set game flag value",
		"color": Color.GOLD,
		"icon": "Edit"
	},
	"Quest": {
		"description": "Quest state management",
		"color": Color.ROYAL_BLUE,
		"icon": "Notebook"
	},
	"Reputation": {
		"description": "Modify faction reputation",
		"color": Color.MEDIUM_PURPLE,
		"icon": "Star"
	},
	"Item": {
		"description": "Give/take/check items",
		"color": Color.ORANGE,
		"icon": "Briefcase"
	},
	"SetExpression": {
		"description": "Set multiple variables",
		"color": Color.MEDIUM_SLATE_BLUE,
		"icon": "Script"
	}
}

# Reference to buttons for styling
var _node_buttons: Dictionary = {}

# Color legend container
var _color_legend_container: VBoxContainer = null


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

	# Add separator for Phase 2 nodes
	var phase2_sep = HSeparator.new()
	add_child(phase2_sep)

	var phase2_label = Label.new()
	phase2_label.text = "Advanced Nodes"
	phase2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase2_label.add_theme_font_size_override("font_size", 12)
	add_child(phase2_label)

	var sep2 = HSeparator.new()
	add_child(sep2)

	# Create buttons for Phase 2 node types
	for node_type in PHASE2_NODE_TYPES:
		var btn = _create_node_button_from_dict(node_type, PHASE2_NODE_TYPES[node_type])
		add_child(btn)
		_node_buttons[node_type] = btn

	# Add speaker color legend
	_create_color_legend()


func _create_node_button(node_type: String) -> Button:
	return _create_node_button_from_dict(node_type, NODE_TYPES[node_type])


func _create_node_button_from_dict(node_type: String, node_info: Dictionary) -> Button:
	var btn = Button.new()
	btn.text = node_type
	btn.tooltip_text = node_info.description
	btn.custom_minimum_size = Vector2(0, 32)

	# Style the button with the node's color
	var style = StyleBoxFlat.new()
	style.bg_color = node_info.color.darkened(0.6)
	style.border_color = node_info.color
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	btn.add_theme_stylebox_override("normal", style)

	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = node_info.color.darkened(0.4)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = style.duplicate()
	pressed_style.bg_color = node_info.color.darkened(0.2)
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

	# Get color from whichever dictionary has this node type
	var node_color: Color
	if NODE_TYPES.has(node_type):
		node_color = NODE_TYPES[node_type].color
	elif PHASE2_NODE_TYPES.has(node_type):
		node_color = PHASE2_NODE_TYPES[node_type].color
	else:
		node_color = Color.WHITE

	var style = StyleBoxFlat.new()
	style.bg_color = node_color.darkened(0.4)
	style.border_color = node_color
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


func _create_color_legend() -> void:
	# Add separator before legend
	var sep = HSeparator.new()
	add_child(sep)

	# Legend header
	var header = Label.new()
	header.text = "Speaker Colors"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 12)
	add_child(header)

	var sep2 = HSeparator.new()
	add_child(sep2)

	# Create container for legend items
	_color_legend_container = VBoxContainer.new()
	_color_legend_container.name = "ColorLegend"
	add_child(_color_legend_container)

	# Add legend items for common speakers
	var legend = SpeakerColorsScript.get_simple_legend()
	for speaker in legend:
		var color = legend[speaker]
		_add_legend_item(speaker, color)


func _add_legend_item(speaker: String, color: Color) -> void:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 20)

	# Color swatch
	var swatch = Panel.new()
	swatch.custom_minimum_size = Vector2(16, 16)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	swatch.add_theme_stylebox_override("panel", style)
	row.add_child(swatch)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(8, 0)
	row.add_child(spacer)

	# Label
	var label = Label.new()
	label.text = speaker
	label.add_theme_font_size_override("font_size", 11)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	_color_legend_container.add_child(row)


func refresh_color_legend() -> void:
	"""Refresh the color legend when colors change."""
	if _color_legend_container:
		# Clear existing items
		for child in _color_legend_container.get_children():
			child.queue_free()

		# Rebuild legend
		var legend = SpeakerColorsScript.get_simple_legend()
		for speaker in legend:
			var color = legend[speaker]
			_add_legend_item(speaker, color)
