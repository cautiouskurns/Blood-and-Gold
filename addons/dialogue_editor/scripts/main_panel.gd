@tool
extends Control
## Main panel for the Dialogue Tree Editor.
## Manages the toolbar, node palette, canvas, file operations, and status bar.

const DialogueTreeDataScript = preload("res://addons/dialogue_editor/scripts/dialogue_tree_data.gd")

# Default save directory
const DEFAULT_DIALOGUE_DIR := "res://data/dialogue/"

# Node references
@onready var dialogue_canvas: GraphEdit = $Margin/HSplit/RightPanel/DialogueCanvas
@onready var dialogue_id_label: Label = $Margin/HSplit/RightPanel/StatusBar/DialogueIdLabel
@onready var node_count_label: Label = $Margin/HSplit/RightPanel/StatusBar/NodeCountLabel
@onready var zoom_label: Label = $Margin/HSplit/RightPanel/StatusBar/ZoomLabel
@onready var node_palette: VBoxContainer = $Margin/HSplit/LeftPanel/VBox/Scroll/NodeList

# Toolbar buttons
@onready var new_btn: Button = $Margin/HSplit/RightPanel/Toolbar/NewBtn
@onready var open_btn: Button = $Margin/HSplit/RightPanel/Toolbar/OpenBtn
@onready var save_btn: Button = $Margin/HSplit/RightPanel/Toolbar/SaveBtn
@onready var export_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ExportBtn
@onready var validate_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ValidateBtn
@onready var reset_view_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ResetViewBtn

# File dialogs
var _open_dialog: FileDialog
var _save_dialog: FileDialog
var _confirm_dialog: ConfirmationDialog
var _pending_action: String = ""  # Tracks what to do after confirmation

# State
var current_file_path: String = ""
var dialogue_id: String = ""
var is_dirty: bool = false


func _ready() -> void:
	# Force the panel to fill the entire main screen area
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_h_size_flags(Control.SIZE_EXPAND_FILL)
	set_v_size_flags(Control.SIZE_EXPAND_FILL)
	custom_minimum_size = Vector2(800, 600)

	_setup_dialogs()
	_connect_toolbar_signals()
	_connect_canvas_signals()
	_connect_palette_signals()
	_update_status_bar()

	# Ensure default dialogue directory exists
	_ensure_dialogue_directory()


func _input(event: InputEvent) -> void:
	# Handle keyboard shortcuts when this panel is visible
	if not is_visible_in_tree():
		return

	if event is InputEventKey and event.pressed:
		var handled := false

		if event.ctrl_pressed:
			match event.keycode:
				KEY_N:  # Ctrl+N - New
					_on_new_pressed()
					handled = true
				KEY_O:  # Ctrl+O - Open
					_on_open_pressed()
					handled = true
				KEY_S:  # Ctrl+S - Save / Ctrl+Shift+S - Save As
					if event.shift_pressed:
						_on_save_as_pressed()
					else:
						_on_save_pressed()
					handled = true

		if handled:
			get_viewport().set_input_as_handled()


func _setup_dialogs() -> void:
	# Open file dialog
	_open_dialog = FileDialog.new()
	_open_dialog.name = "OpenDialog"
	_open_dialog.title = "Open Dialogue Tree"
	_open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_open_dialog.access = FileDialog.ACCESS_RESOURCES
	_open_dialog.filters = PackedStringArray([DialogueTreeDataScript.get_file_filter()])
	_open_dialog.current_dir = DEFAULT_DIALOGUE_DIR
	_open_dialog.file_selected.connect(_on_open_file_selected)
	add_child(_open_dialog)

	# Save file dialog
	_save_dialog = FileDialog.new()
	_save_dialog.name = "SaveDialog"
	_save_dialog.title = "Save Dialogue Tree"
	_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_save_dialog.access = FileDialog.ACCESS_RESOURCES
	_save_dialog.filters = PackedStringArray([DialogueTreeDataScript.get_file_filter()])
	_save_dialog.current_dir = DEFAULT_DIALOGUE_DIR
	_save_dialog.file_selected.connect(_on_save_file_selected)
	add_child(_save_dialog)

	# Confirmation dialog for unsaved changes
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.name = "ConfirmDialog"
	_confirm_dialog.title = "Unsaved Changes"
	_confirm_dialog.dialog_text = "You have unsaved changes. Do you want to save before continuing?"
	_confirm_dialog.ok_button_text = "Save"
	_confirm_dialog.add_button("Don't Save", true, "dont_save")
	_confirm_dialog.confirmed.connect(_on_confirm_save)
	_confirm_dialog.custom_action.connect(_on_confirm_custom_action)
	_confirm_dialog.canceled.connect(_on_confirm_canceled)
	add_child(_confirm_dialog)


func _ensure_dialogue_directory() -> void:
	if not DirAccess.dir_exists_absolute(DEFAULT_DIALOGUE_DIR):
		var err = DirAccess.make_dir_recursive_absolute(DEFAULT_DIALOGUE_DIR)
		if err == OK:
			print("DialogueEditor: Created dialogue directory: %s" % DEFAULT_DIALOGUE_DIR)
		else:
			push_warning("DialogueEditor: Could not create dialogue directory: %s" % DEFAULT_DIALOGUE_DIR)


func _connect_palette_signals() -> void:
	if node_palette and node_palette.has_signal("node_button_clicked"):
		node_palette.node_button_clicked.connect(_on_palette_node_clicked)


func _connect_toolbar_signals() -> void:
	if new_btn:
		new_btn.pressed.connect(_on_new_pressed)
		new_btn.tooltip_text = "New Dialogue (Ctrl+N)"
	if open_btn:
		open_btn.pressed.connect(_on_open_pressed)
		open_btn.tooltip_text = "Open Dialogue (Ctrl+O)"
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)
		save_btn.tooltip_text = "Save Dialogue (Ctrl+S)"
	if export_btn:
		export_btn.pressed.connect(_on_export_pressed)
		export_btn.tooltip_text = "Export to JSON (Ctrl+E)"
	if validate_btn:
		validate_btn.pressed.connect(_on_validate_pressed)
		validate_btn.tooltip_text = "Validate Tree"
	if reset_view_btn:
		reset_view_btn.pressed.connect(_on_reset_view_pressed)
		reset_view_btn.tooltip_text = "Reset View"


func _connect_canvas_signals() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_signal("canvas_changed"):
			dialogue_canvas.canvas_changed.connect(_on_canvas_changed)
		if dialogue_canvas.has_signal("zoom_changed"):
			dialogue_canvas.zoom_changed.connect(_on_zoom_changed)


func _process(_delta: float) -> void:
	# Update node count periodically
	if dialogue_canvas and node_count_label and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("get_node_count"):
			var count = dialogue_canvas.get_node_count()
			node_count_label.text = "Nodes: %d" % count


# =============================================================================
# TOOLBAR HANDLERS
# =============================================================================

func _on_new_pressed() -> void:
	if is_dirty:
		_pending_action = "new"
		_confirm_dialog.popup_centered()
	else:
		_do_new()


func _do_new() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("clear_canvas"):
			dialogue_canvas.clear_canvas()
	dialogue_id = ""
	current_file_path = ""
	is_dirty = false
	_update_status_bar()
	print("DialogueEditor: New dialogue created")


func _on_open_pressed() -> void:
	if is_dirty:
		_pending_action = "open"
		_confirm_dialog.popup_centered()
	else:
		_do_open()


func _do_open() -> void:
	_open_dialog.popup_centered_ratio(0.7)


func _on_save_pressed() -> void:
	if current_file_path.is_empty():
		_on_save_as_pressed()
	else:
		_save_to_file(current_file_path)


func _on_save_as_pressed() -> void:
	# Set a default filename based on dialogue_id
	if dialogue_id.is_empty():
		_save_dialog.current_file = "new_dialogue.dtree"
	else:
		_save_dialog.current_file = dialogue_id + ".dtree"
	_save_dialog.popup_centered_ratio(0.7)


func _on_export_pressed() -> void:
	# TODO: Export to JSON (Feature 1.7)
	print("DialogueEditor: Export JSON (Feature 1.7)")


func _on_validate_pressed() -> void:
	# TODO: Validate tree (Feature 2.4)
	print("DialogueEditor: Validate (Feature 2.4)")


func _on_reset_view_pressed() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("reset_view"):
			dialogue_canvas.reset_view()
			_update_status_bar()
			print("DialogueEditor: View reset")


# =============================================================================
# FILE OPERATIONS
# =============================================================================

func _on_open_file_selected(path: String) -> void:
	_load_from_file(path)


func _on_save_file_selected(path: String) -> void:
	# Ensure .dtree extension
	if not path.ends_with(".dtree"):
		path += ".dtree"
	_save_to_file(path)

	# If we were doing a save before another action, continue that action
	if _pending_action == "save_then_new":
		_pending_action = ""
		_do_new()
	elif _pending_action == "save_then_open":
		_pending_action = ""
		_do_open()


func _save_to_file(path: String) -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_error("DialogueEditor: Canvas not available for saving")
		return

	if not dialogue_canvas.has_method("serialize"):
		push_error("DialogueEditor: Canvas does not have serialize method")
		return

	# Create dialogue tree data
	var tree_data = DialogueTreeDataScript.new()

	# Set metadata
	tree_data.dialogue_id = DialogueTreeDataScript.get_dialogue_id_from_path(path)
	if dialogue_id.is_empty():
		dialogue_id = tree_data.dialogue_id

	# Populate from canvas
	var canvas_data = dialogue_canvas.serialize()
	tree_data.populate_from_canvas(canvas_data)

	# Save to file
	var err = tree_data.save_to_file(path)
	if err == OK:
		current_file_path = path
		dialogue_id = tree_data.dialogue_id
		is_dirty = false
		_update_status_bar()
		print("DialogueEditor: Saved to %s" % path)
	else:
		push_error("DialogueEditor: Failed to save: %s (error: %d)" % [path, err])


func _load_from_file(path: String) -> void:
	var tree_data = DialogueTreeDataScript.load_from_file(path)
	if tree_data == null:
		push_error("DialogueEditor: Failed to load: %s" % path)
		return

	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_error("DialogueEditor: Canvas not available for loading")
		return

	if not dialogue_canvas.has_method("deserialize"):
		push_error("DialogueEditor: Canvas does not have deserialize method")
		return

	# Load into canvas
	var canvas_data = tree_data.to_canvas_data()
	dialogue_canvas.deserialize(canvas_data)

	# Update state
	current_file_path = path
	dialogue_id = tree_data.dialogue_id
	is_dirty = false
	_update_status_bar()
	print("DialogueEditor: Loaded from %s" % path)


# =============================================================================
# CONFIRMATION DIALOG HANDLERS
# =============================================================================

func _on_confirm_save() -> void:
	# User chose "Save"
	if current_file_path.is_empty():
		# Need to do Save As first, then continue pending action
		if _pending_action == "new":
			_pending_action = "save_then_new"
		elif _pending_action == "open":
			_pending_action = "save_then_open"
		_on_save_as_pressed()
	else:
		_save_to_file(current_file_path)
		_continue_pending_action()


func _on_confirm_custom_action(action: StringName) -> void:
	if action == "dont_save":
		# User chose "Don't Save" - continue without saving
		is_dirty = false
		_continue_pending_action()


func _on_confirm_canceled() -> void:
	# User canceled - don't do anything
	_pending_action = ""


func _continue_pending_action() -> void:
	match _pending_action:
		"new":
			_pending_action = ""
			_do_new()
		"open":
			_pending_action = ""
			_do_open()
		_:
			_pending_action = ""


# =============================================================================
# CANVAS SIGNAL HANDLERS
# =============================================================================

func _on_canvas_changed() -> void:
	is_dirty = true
	_update_status_bar()


func _on_zoom_changed(_new_zoom: float) -> void:
	_update_status_bar()


func _on_palette_node_clicked(node_type: String) -> void:
	# Add the node at the center of the canvas
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("add_dialogue_node_at_center"):
			dialogue_canvas.add_dialogue_node_at_center(node_type)


# =============================================================================
# STATUS BAR
# =============================================================================

func _update_status_bar() -> void:
	if dialogue_id_label:
		var id_text = dialogue_id if not dialogue_id.is_empty() else "(none)"
		var dirty_marker = "*" if is_dirty else ""
		dialogue_id_label.text = "dialogue_id: %s%s" % [id_text, dirty_marker]

	if zoom_label and dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("get_zoom_percent"):
			zoom_label.text = "Zoom: %d%%" % dialogue_canvas.get_zoom_percent()


# =============================================================================
# PUBLIC API
# =============================================================================

## Check if there are unsaved changes.
func has_unsaved_changes() -> bool:
	return is_dirty


## Get the current dialogue ID.
func get_dialogue_id() -> String:
	return dialogue_id


## Get the current file path.
func get_current_file_path() -> String:
	return current_file_path
