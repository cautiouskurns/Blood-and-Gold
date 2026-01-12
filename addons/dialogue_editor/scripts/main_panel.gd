@tool
extends Control
## Main panel for the Dialogue Tree Editor.
## Contains the toolbar, node palette, canvas, and status bar.

# UI References
@onready var toolbar: HBoxContainer = $MarginContainer/VBoxContainer/Toolbar
@onready var new_button: Button = $MarginContainer/VBoxContainer/Toolbar/NewButton
@onready var open_button: Button = $MarginContainer/VBoxContainer/Toolbar/OpenButton
@onready var save_button: Button = $MarginContainer/VBoxContainer/Toolbar/SaveButton
@onready var export_button: Button = $MarginContainer/VBoxContainer/Toolbar/ExportButton
@onready var undo_button: Button = $MarginContainer/VBoxContainer/Toolbar/UndoButton
@onready var redo_button: Button = $MarginContainer/VBoxContainer/Toolbar/RedoButton
@onready var validate_button: Button = $MarginContainer/VBoxContainer/Toolbar/ValidateButton
@onready var test_button: Button = $MarginContainer/VBoxContainer/Toolbar/TestButton

@onready var node_palette: PanelContainer = $MarginContainer/VBoxContainer/HSplitContainer/NodePalette
@onready var canvas_container: PanelContainer = $MarginContainer/VBoxContainer/HSplitContainer/CanvasContainer

@onready var dialogue_id_label: Label = $MarginContainer/VBoxContainer/StatusBar/DialogueIdLabel
@onready var node_count_label: Label = $MarginContainer/VBoxContainer/StatusBar/NodeCountLabel
@onready var zoom_label: Label = $MarginContainer/VBoxContainer/StatusBar/ZoomLabel

# Current dialogue tree state
var current_file_path: String = ""
var is_dirty: bool = false
var dialogue_id: String = ""


func _ready() -> void:
	# Connect toolbar buttons
	new_button.pressed.connect(_new_dialogue)
	open_button.pressed.connect(_open_dialogue)
	save_button.pressed.connect(_save_dialogue)
	export_button.pressed.connect(_export_json)
	undo_button.pressed.connect(_undo)
	redo_button.pressed.connect(_redo)
	validate_button.pressed.connect(_validate_tree)
	test_button.pressed.connect(_play_dialogue)


# Placeholder functions - will be implemented in later features

func _new_dialogue() -> void:
	print("DialogueEditor: New dialogue (Feature 1.6)")


func _open_dialogue() -> void:
	print("DialogueEditor: Open dialogue (Feature 1.6)")


func _save_dialogue() -> void:
	print("DialogueEditor: Save dialogue (Feature 1.6)")


func _export_json() -> void:
	print("DialogueEditor: Export JSON (Feature 1.7)")


func _undo() -> void:
	print("DialogueEditor: Undo (Feature 1.8)")


func _redo() -> void:
	print("DialogueEditor: Redo (Feature 1.8)")


func _play_dialogue() -> void:
	print("DialogueEditor: Play dialogue (Feature 2.2)")


func _validate_tree() -> void:
	print("DialogueEditor: Validate tree (Feature 2.4)")


# Status bar updates

func update_dialogue_id(id: String) -> void:
	dialogue_id = id
	dialogue_id_label.text = "dialogue_id: " + (id if id else "(none)")


func update_node_count(count: int) -> void:
	node_count_label.text = "Nodes: " + str(count)


func update_zoom(zoom_percent: int) -> void:
	zoom_label.text = "Zoom: " + str(zoom_percent) + "%"


func set_dirty(dirty: bool) -> void:
	is_dirty = dirty
