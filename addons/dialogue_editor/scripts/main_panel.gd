@tool
extends Control
## Main panel for the Dialogue Tree Editor.
## Manages the toolbar, node palette, canvas, file operations, and status bar.

const DialogueTreeDataScript = preload("res://addons/dialogue_editor/scripts/dialogue_tree_data.gd")
const DialogueExporterScript = preload("res://addons/dialogue_editor/scripts/dialogue_exporter.gd")
const TestPanelScript = preload("res://addons/dialogue_editor/scripts/test_panel.gd")
const SearchManagerScript = preload("res://addons/dialogue_editor/scripts/search_manager.gd")
const ValidationPanelScript = preload("res://addons/dialogue_editor/scripts/validation_panel.gd")
const DialogueValidatorScript = preload("res://addons/dialogue_editor/scripts/dialogue_validator.gd")
const AutoSaveManagerScript = preload("res://addons/dialogue_editor/scripts/auto_save_manager.gd")
const PropertyPanelScript = preload("res://addons/dialogue_editor/scripts/property_panel.gd")
const ErrorHandlerScript = preload("res://addons/dialogue_editor/scripts/error_handler.gd")
const SaveTemplateDialogScript = preload("res://addons/dialogue_editor/scripts/templates/save_template_dialog.gd")
const TemplateLibraryPanelScript = preload("res://addons/dialogue_editor/scripts/template_library_panel.gd")
const VariableBrowserPanelScript = preload("res://addons/dialogue_editor/scripts/ui/variable_browser_panel.gd")

# Default save directory
const DEFAULT_DIALOGUE_DIR := "res://data/dialogue/"

# Node references
@onready var dialogue_canvas: GraphEdit = $Margin/HSplit/RightPanel/DialogueCanvas
@onready var dialogue_id_label: Label = $Margin/HSplit/RightPanel/StatusBar/DialogueIdLabel
@onready var node_count_label: Label = $Margin/HSplit/RightPanel/StatusBar/NodeCountLabel
@onready var zoom_label: Label = $Margin/HSplit/RightPanel/StatusBar/ZoomLabel
@onready var node_palette: VBoxContainer = $Margin/HSplit/LeftPanel/VBox/Scroll/NodeList
@onready var template_library: VBoxContainer = $Margin/HSplit/LeftPanel/VBox/TemplateScroll/TemplateLibrary

# Toolbar buttons
@onready var new_btn: Button = $Margin/HSplit/RightPanel/Toolbar/NewBtn
@onready var open_btn: Button = $Margin/HSplit/RightPanel/Toolbar/OpenBtn
@onready var save_btn: Button = $Margin/HSplit/RightPanel/Toolbar/SaveBtn
@onready var export_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ExportBtn
@onready var test_btn: Button = $Margin/HSplit/RightPanel/Toolbar/TestBtn
@onready var validate_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ValidateBtn
@onready var reset_view_btn: Button = $Margin/HSplit/RightPanel/Toolbar/ResetViewBtn
@onready var auto_layout_btn: Button = $Margin/HSplit/RightPanel/Toolbar/AutoLayoutBtn
@onready var help_btn: Button = $Margin/HSplit/RightPanel/Toolbar/HelpBtn
@onready var whats_this_btn: Button = $Margin/HSplit/RightPanel/Toolbar/WhatsThisBtn

# Search UI
@onready var search_field: OptionButton = $Margin/HSplit/RightPanel/Toolbar/SearchField
@onready var search_edit: LineEdit = $Margin/HSplit/RightPanel/Toolbar/SearchEdit
@onready var find_prev_btn: Button = $Margin/HSplit/RightPanel/Toolbar/FindPrevBtn
@onready var find_next_btn: Button = $Margin/HSplit/RightPanel/Toolbar/FindNextBtn
@onready var search_result_label: Label = $Margin/HSplit/RightPanel/Toolbar/SearchResultLabel
@onready var filter_dropdown: OptionButton = $Margin/HSplit/RightPanel/Toolbar/FilterDropdown

# Search manager
var _search_manager: RefCounted = null

# Auto-save manager
var _auto_save_manager: RefCounted = null
var _auto_save_status_label: Label = null
var _recovery_dialog: ConfirmationDialog = null

# Validation panel
var _validation_panel: PanelContainer = null
var _validation_vsplit: VSplitContainer = null
var _is_validating: bool = false
var _validate_before_export: bool = true  # Option to validate before export

# Test panel
var _test_panel: PanelContainer = null
var _test_hsplit: HSplitContainer = null
var _is_testing: bool = false

# Property panel
var _property_panel: PanelContainer = null
var _property_panel_container: Control = null

# File dialogs
var _open_dialog: FileDialog
var _save_dialog: FileDialog
var _export_dialog: FileDialog
var _confirm_dialog: ConfirmationDialog
var _pending_action: String = ""  # Tracks what to do after confirmation

# Template dialog
var _save_template_dialog: ConfirmationDialog

# Variable browser panel
var _variable_browser_panel: VBoxContainer = null
var _variable_browser_vsplit: VSplitContainer = null

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
	_setup_template_dialog()
	_setup_search_manager()
	_setup_auto_save()
	_setup_property_panel()
	_setup_notifications()
	_setup_template_library()
	_setup_variable_browser_panel()
	_connect_toolbar_signals()
	_connect_canvas_signals()
	_connect_palette_signals()
	_connect_search_signals()
	_connect_template_library_signals()
	_update_status_bar()

	# Ensure default dialogue directory exists
	_ensure_dialogue_directory()

	# Check for crash recovery after a brief delay (to ensure canvas is ready)
	call_deferred("_check_for_recovery")


func _input(event: InputEvent) -> void:
	# Handle keyboard shortcuts when this panel is visible
	if not is_visible_in_tree():
		return

	if event is InputEventKey and event.pressed:
		var handled := false

		# F5 - Toggle test mode
		if event.keycode == KEY_F5 and not event.ctrl_pressed:
			_toggle_test_mode()
			handled = true

		# F3 - Find Next / Shift+F3 - Find Previous
		if event.keycode == KEY_F3 and not event.ctrl_pressed:
			if event.shift_pressed:
				_on_find_previous()
			else:
				_on_find_next()
			handled = true

		# F1 - Show Help
		if event.keycode == KEY_F1 and not event.ctrl_pressed:
			_show_help_dialog()
			handled = true

		# Delete - Delete selected nodes
		if event.keycode == KEY_DELETE and not event.ctrl_pressed:
			_delete_selected_nodes()
			handled = true

		# Escape - Deselect all
		if event.keycode == KEY_ESCAPE and not event.ctrl_pressed:
			_deselect_all_nodes()
			handled = true

		# 1-5 - Quick add node types (when not in text field)
		if not _is_text_field_focused():
			match event.keycode:
				KEY_1:  # 1 - Add Start node
					_quick_add_node("Start")
					handled = true
				KEY_2:  # 2 - Add Speaker node
					_quick_add_node("Speaker")
					handled = true
				KEY_3:  # 3 - Add Choice node
					_quick_add_node("Choice")
					handled = true
				KEY_4:  # 4 - Add Branch node
					_quick_add_node("Branch")
					handled = true
				KEY_5:  # 5 - Add End node
					_quick_add_node("End")
					handled = true

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
				KEY_E:  # Ctrl+E - Export
					_on_export_pressed()
					handled = true
				KEY_Z:  # Ctrl+Z - Undo / Ctrl+Shift+Z - Redo
					if event.shift_pressed:
						_on_redo_pressed()
					else:
						_on_undo_pressed()
					handled = true
				KEY_Y:  # Ctrl+Y - Redo (alternative)
					_on_redo_pressed()
					handled = true
				KEY_D:  # Ctrl+D - Duplicate selected
					_duplicate_selected_nodes()
					handled = true
				KEY_A:  # Ctrl+A - Select all
					_select_all_nodes()
					handled = true
				KEY_T:  # Ctrl+Shift+T - Save selection as template
					if event.shift_pressed:
						_on_save_as_template_requested()
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

	# Export file dialog
	_export_dialog = FileDialog.new()
	_export_dialog.name = "ExportDialog"
	_export_dialog.title = "Export Dialogue to JSON"
	_export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_export_dialog.access = FileDialog.ACCESS_RESOURCES
	_export_dialog.filters = PackedStringArray([DialogueExporterScript.get_file_filter()])
	_export_dialog.current_dir = DialogueExporterScript.DEFAULT_EXPORT_DIR
	_export_dialog.file_selected.connect(_on_export_file_selected)
	add_child(_export_dialog)

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


func _setup_template_dialog() -> void:
	# Create save template dialog
	_save_template_dialog = SaveTemplateDialogScript.new()
	_save_template_dialog.name = "SaveTemplateDialog"
	_save_template_dialog.template_saved.connect(_on_template_saved)
	add_child(_save_template_dialog)


func _setup_template_library() -> void:
	# Template library is created from scene, just ensure it's initialized
	if template_library:
		# Refresh templates on startup
		template_library.refresh()


func _setup_variable_browser_panel() -> void:
	# Create the variable browser panel
	_variable_browser_panel = VariableBrowserPanelScript.new()
	_variable_browser_panel.name = "VariableBrowserPanel"
	_variable_browser_panel.custom_minimum_size = Vector2(0, 120)

	# Set the GraphEdit reference
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		_variable_browser_panel.set_graph_edit(dialogue_canvas)

	# Connect signals
	_variable_browser_panel.variable_selected.connect(_on_variable_selected)
	_variable_browser_panel.test_value_changed.connect(_on_variable_test_value_changed)

	# Add to the left panel, below the template library
	var left_panel = get_node_or_null("Margin/HSplit/LeftPanel/VBox")
	if left_panel:
		# Add a separator
		var sep = HSeparator.new()
		left_panel.add_child(sep)

		# Add the panel
		left_panel.add_child(_variable_browser_panel)

	# Initial scan
	call_deferred("_refresh_variable_browser")


func _refresh_variable_browser() -> void:
	if _variable_browser_panel and dialogue_canvas:
		_variable_browser_panel.set_graph_edit(dialogue_canvas)
		_variable_browser_panel.scan_variables()


func _on_variable_selected(variable_name: String, node_names: Array) -> void:
	# Highlight nodes that use this variable
	_highlight_nodes_using_variable(node_names)


func _on_variable_test_value_changed(variable_name: String, value: Variant) -> void:
	# Test values are stored in the panel and used during test mode
	print("DialogueEditor: Variable '%s' test value changed to: %s" % [variable_name, str(value)])

	# Update Property Panel preview with new test values
	if _variable_browser_panel and _property_panel:
		var test_values = _variable_browser_panel.get_test_values()
		_property_panel.set_test_values(test_values)


func _highlight_nodes_using_variable(node_names: Array) -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		return

	# Deselect all nodes first
	for child in dialogue_canvas.get_children():
		if child is GraphNode:
			child.selected = false

	# Select nodes that use this variable
	for node_name in node_names:
		var node = dialogue_canvas.get_node_or_null(NodePath(node_name))
		if node and node is GraphNode:
			node.selected = true

	# If only one node, center on it
	if node_names.size() == 1:
		var node = dialogue_canvas.get_node_or_null(NodePath(node_names[0]))
		if node and node is GraphNode:
			var node_center = node.position_offset + node.size / 2
			var viewport_size = dialogue_canvas.size
			var target_scroll = node_center * dialogue_canvas.zoom - viewport_size / 2
			dialogue_canvas.scroll_offset = target_scroll


func _connect_template_library_signals() -> void:
	if template_library:
		template_library.template_selected.connect(_on_template_library_template_selected)
		template_library.template_drag_started.connect(_on_template_library_drag_started)


func _ensure_dialogue_directory() -> void:
	if not DirAccess.dir_exists_absolute(DEFAULT_DIALOGUE_DIR):
		var err = DirAccess.make_dir_recursive_absolute(DEFAULT_DIALOGUE_DIR)
		if err == OK:
			print("DialogueEditor: Created dialogue directory: %s" % DEFAULT_DIALOGUE_DIR)
		else:
			push_warning("DialogueEditor: Could not create dialogue directory: %s" % DEFAULT_DIALOGUE_DIR)


func _ensure_export_directory() -> void:
	var export_dir = DialogueExporterScript.DEFAULT_EXPORT_DIR
	if not DirAccess.dir_exists_absolute(export_dir):
		var err = DirAccess.make_dir_recursive_absolute(export_dir)
		if err == OK:
			print("DialogueEditor: Created export directory: %s" % export_dir)
		else:
			push_warning("DialogueEditor: Could not create export directory: %s" % export_dir)


func _setup_search_manager() -> void:
	_search_manager = SearchManagerScript.new()
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		_search_manager.setup(dialogue_canvas)

	# Connect search manager signals
	_search_manager.search_completed.connect(_on_search_completed)
	_search_manager.result_selected.connect(_on_search_result_selected)
	_search_manager.filter_changed.connect(_on_filter_changed)


func _setup_auto_save() -> void:
	_auto_save_manager = AutoSaveManagerScript.new()
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		_auto_save_manager.setup(self, dialogue_canvas)

	# Connect auto-save signals
	_auto_save_manager.auto_saved.connect(_on_auto_saved)
	_auto_save_manager.auto_save_failed.connect(_on_auto_save_failed)

	# Create auto-save status label in status bar
	_create_auto_save_status_label()

	# Create recovery dialog
	_create_recovery_dialog()


func _create_auto_save_status_label() -> void:
	var status_bar = get_node_or_null("Margin/HSplit/RightPanel/StatusBar")
	if not status_bar:
		return

	# Add separator
	var sep = VSeparator.new()
	status_bar.add_child(sep)

	# Add auto-save label
	_auto_save_status_label = Label.new()
	_auto_save_status_label.name = "AutoSaveLabel"
	_auto_save_status_label.text = "Auto-save: Ready"
	_auto_save_status_label.tooltip_text = "Auto-save status (saves every 60s when changes detected)"
	_auto_save_status_label.add_theme_font_size_override("font_size", 12)
	status_bar.add_child(_auto_save_status_label)


func _create_recovery_dialog() -> void:
	_recovery_dialog = ConfirmationDialog.new()
	_recovery_dialog.name = "RecoveryDialog"
	_recovery_dialog.title = "Recover Auto-Saved Work"
	_recovery_dialog.dialog_text = "An auto-saved version of your work was found. Would you like to recover it?"
	_recovery_dialog.ok_button_text = "Recover"
	_recovery_dialog.add_button("Discard", true, "discard")
	_recovery_dialog.confirmed.connect(_on_recovery_confirmed)
	_recovery_dialog.custom_action.connect(_on_recovery_custom_action)
	add_child(_recovery_dialog)


func _check_for_recovery() -> void:
	if not _auto_save_manager:
		return

	var recovery_data = _auto_save_manager.check_for_recovery()
	if recovery_data.has_recovery and not recovery_data.recoveries.is_empty():
		# Store recovery info for dialog
		var recovery = recovery_data.recoveries[0]
		_recovery_dialog.set_meta("recovery_data", recovery)

		# Update dialog text with details
		var original_path = recovery.get("original_path", "Unknown")
		var dialogue_id_rec = recovery.get("dialogue_id", "Unknown")
		_recovery_dialog.dialog_text = "An auto-saved version was found:\n\nDialogue: %s\nOriginal file: %s\n\nWould you like to recover this work?" % [dialogue_id_rec, original_path]

		_recovery_dialog.popup_centered()


func _on_recovery_confirmed() -> void:
	if not _recovery_dialog.has_meta("recovery_data"):
		return

	var recovery = _recovery_dialog.get_meta("recovery_data")
	var temp_path = recovery.get("temp_path", "")

	if temp_path.is_empty():
		return

	# Load the recovered data
	var result = _auto_save_manager.load_recovery(temp_path)
	if result.success:
		# Apply to canvas
		if dialogue_canvas and dialogue_canvas.has_method("deserialize"):
			var data = result.data
			dialogue_canvas.deserialize(data)
			dialogue_id = data.get("metadata", {}).get("dialogue_id", "recovered")
			current_file_path = recovery.get("original_path", "")
			is_dirty = true  # Mark as dirty since it's recovered
			_auto_save_manager.set_current_file(current_file_path, dialogue_id)
			_update_status_bar()
			print("DialogueEditor: Recovered from auto-save")


func _on_recovery_custom_action(action: StringName) -> void:
	if action == "discard":
		if _recovery_dialog.has_meta("recovery_data"):
			var recovery = _recovery_dialog.get_meta("recovery_data")
			var temp_path = recovery.get("temp_path", "")
			if not temp_path.is_empty():
				_auto_save_manager.discard_recovery(temp_path)
				print("DialogueEditor: Discarded auto-save recovery")


func _on_auto_saved(temp_path: String) -> void:
	_update_auto_save_status()


func _on_auto_save_failed(error: String) -> void:
	if _auto_save_status_label:
		_auto_save_status_label.text = "Auto-save: Failed"
		_auto_save_status_label.modulate = Color.RED


func _update_auto_save_status() -> void:
	if not _auto_save_status_label or not _auto_save_manager:
		return

	if not _auto_save_manager.is_enabled():
		_auto_save_status_label.text = "Auto-save: Off"
		_auto_save_status_label.modulate = Color(1, 1, 1, 0.5)
	else:
		var time_str = _auto_save_manager.get_last_save_time_string()
		if time_str == "Never":
			_auto_save_status_label.text = "Auto-save: Ready"
		else:
			_auto_save_status_label.text = "Auto-save: %s" % time_str
		_auto_save_status_label.modulate = Color.WHITE


func _setup_property_panel() -> void:
	# Create the property panel
	_property_panel = PropertyPanelScript.new()
	_property_panel.name = "PropertyPanel"

	# Connect property change signal
	_property_panel.property_changed.connect(_on_property_changed)

	# Connect preview-related signals
	_property_panel.request_test_values.connect(_on_property_panel_request_test_values)
	_property_panel.request_variable_browser_focus.connect(_on_property_panel_request_variable_browser_focus)

	# Create a container that will clip the property panel for slide animation
	# This container is positioned at the right edge and overlays the canvas
	_property_panel_container = Control.new()
	_property_panel_container.name = "PropertyPanelContainer"
	_property_panel_container.clip_contents = true
	_property_panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks through to canvas

	# Add property panel to container (it handles its own mouse filtering)
	_property_panel_container.add_child(_property_panel)

	# Add the container to the root MainPanel (self) which is a Control
	# This allows proper anchor-based positioning as an overlay
	add_child(_property_panel_container)

	# Position the container at the right edge of the panel
	# Use anchors: right edge anchored to right, full height
	_property_panel_container.anchor_left = 1.0
	_property_panel_container.anchor_right = 1.0
	_property_panel_container.anchor_top = 0.0
	_property_panel_container.anchor_bottom = 1.0

	# Offset from anchors: extend 320px to the left from right edge
	# Leave some space at top for toolbar and bottom for status bar
	_property_panel_container.offset_left = -320
	_property_panel_container.offset_right = 0
	_property_panel_container.offset_top = 35  # Below toolbar
	_property_panel_container.offset_bottom = -25  # Above status bar


func _on_property_changed(node: GraphNode, property: String, value: Variant) -> void:
	# Mark document as dirty when property changes
	is_dirty = true
	if _auto_save_manager:
		_auto_save_manager.mark_dirty()
	_update_status_bar()
	_refresh_validation()


func _on_property_panel_request_test_values() -> void:
	# Provide test values from Variable Browser to Property Panel for preview
	if _variable_browser_panel and _property_panel:
		var test_values = _variable_browser_panel.get_test_values()
		_property_panel.set_test_values(test_values)


func _on_property_panel_request_variable_browser_focus() -> void:
	# Focus and expand the Variable Browser panel
	if _variable_browser_panel:
		# Make sure it's expanded
		if _variable_browser_panel.is_collapsed():
			_variable_browser_panel.set_collapsed(false)

		# Scroll to make it visible (if in a scroll container)
		var left_panel = get_node_or_null("Margin/HSplit/LeftPanel/VBox")
		if left_panel:
			# Find the scroll container if any
			var scroll = left_panel.get_parent()
			if scroll is ScrollContainer:
				# Ensure variable browser is visible
				scroll.ensure_control_visible(_variable_browser_panel)


func _connect_search_signals() -> void:
	if search_edit:
		search_edit.text_changed.connect(_on_search_text_changed)
		search_edit.text_submitted.connect(_on_search_submitted)
		search_edit.tooltip_text = "Search nodes (F3 / Shift+F3)"

	if search_field:
		search_field.item_selected.connect(_on_search_field_changed)

	if find_prev_btn:
		find_prev_btn.pressed.connect(_on_find_previous)

	if find_next_btn:
		find_next_btn.pressed.connect(_on_find_next)

	if filter_dropdown:
		filter_dropdown.item_selected.connect(_on_filter_selected)


func _connect_palette_signals() -> void:
	if node_palette and node_palette.has_signal("node_button_clicked"):
		node_palette.node_button_clicked.connect(_on_palette_node_clicked)


func _connect_toolbar_signals() -> void:
	# File operations
	if new_btn:
		new_btn.pressed.connect(_on_new_pressed)
		new_btn.tooltip_text = "New Dialogue\nCreate a new empty dialogue tree.\nShortcut: Ctrl+N"
	if open_btn:
		open_btn.pressed.connect(_on_open_pressed)
		open_btn.tooltip_text = "Open Dialogue\nOpen an existing .dtree file.\nShortcut: Ctrl+O"
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)
		save_btn.tooltip_text = "Save Dialogue\nSave the current dialogue tree to .dtree file.\nShortcut: Ctrl+S (Save), Ctrl+Shift+S (Save As)"
	if export_btn:
		export_btn.pressed.connect(_on_export_pressed)
		export_btn.tooltip_text = "Export to JSON\nExport dialogue to JSON format for game use.\nShortcut: Ctrl+E"

	# Testing and validation
	if test_btn:
		test_btn.pressed.connect(_toggle_test_mode)
		test_btn.tooltip_text = "Test Dialogue\nPlay through the dialogue in the editor.\nShortcut: F5"
	if validate_btn:
		validate_btn.pressed.connect(_on_validate_pressed)
		validate_btn.tooltip_text = "Validate Tree\nCheck for structural issues like orphan nodes,\ndead ends, and missing connections."

	# View controls
	if reset_view_btn:
		reset_view_btn.pressed.connect(_on_reset_view_pressed)
		reset_view_btn.tooltip_text = "Reset View\nReset canvas zoom to 100% and center position."
	if auto_layout_btn:
		auto_layout_btn.pressed.connect(_on_auto_layout_pressed)
		auto_layout_btn.tooltip_text = "Auto Layout\nAutomatically arrange nodes in a tree layout\nstarting from the Start node."

	# Help
	if help_btn:
		help_btn.pressed.connect(_show_help_dialog.bind(0))
		help_btn.tooltip_text = "Help & Documentation\nOpen comprehensive help with Quick Start,\nKeyboard Shortcuts, and Node Reference.\nShortcut: F1"

	# What's This?
	if whats_this_btn:
		_whats_this_btn = whats_this_btn
		whats_this_btn.pressed.connect(_toggle_whats_this_mode)
		whats_this_btn.tooltip_text = "What's This?\nClick this, then click any element\nto see help about it."

	# Setup search field tooltips
	_setup_search_tooltips()


func _setup_search_tooltips() -> void:
	if search_field:
		search_field.tooltip_text = "Search Field\nSelect which field to search in:\n- All: Search all text fields\n- Node ID: Search by node identifier\n- Speaker: Search by speaker name\n- Text: Search dialogue text only\n- Type: Search by node type"

	if search_edit:
		search_edit.tooltip_text = "Search Box\nType to search for nodes.\nShortcut: F3 (next), Shift+F3 (previous)"

	if find_prev_btn:
		find_prev_btn.tooltip_text = "Find Previous\nJump to the previous search result.\nShortcut: Shift+F3"

	if find_next_btn:
		find_next_btn.tooltip_text = "Find Next\nJump to the next search result.\nShortcut: F3"

	if search_result_label:
		search_result_label.tooltip_text = "Search Results\nShows current result position out of total matches."

	if filter_dropdown:
		filter_dropdown.tooltip_text = "Type Filter\nShow only specific node types on the canvas.\nSelect 'All Types' to show everything."


func _connect_canvas_signals() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_signal("canvas_changed"):
			dialogue_canvas.canvas_changed.connect(_on_canvas_changed)
		if dialogue_canvas.has_signal("zoom_changed"):
			dialogue_canvas.zoom_changed.connect(_on_zoom_changed)
		if dialogue_canvas.has_signal("dialogue_node_selected"):
			dialogue_canvas.dialogue_node_selected.connect(_on_dialogue_node_selected)
		if dialogue_canvas.has_signal("dialogue_node_deselected"):
			dialogue_canvas.dialogue_node_deselected.connect(_on_dialogue_node_deselected)
		if dialogue_canvas.has_signal("save_as_template_requested"):
			dialogue_canvas.save_as_template_requested.connect(_on_save_as_template_requested)


func _process(_delta: float) -> void:
	# Update node count periodically
	if dialogue_canvas and node_count_label and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("get_node_count"):
			var count = dialogue_canvas.get_node_count()
			node_count_label.text = "Nodes: %d" % count

	# Update auto-save status periodically
	_update_auto_save_status()


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
	if _auto_save_manager:
		_auto_save_manager.set_current_file("", "")
		_auto_save_manager.mark_clean()
	_update_status_bar()
	_clear_search()
	_update_filter_dropdown()
	_refresh_variable_browser()
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
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_warning("DialogueEditor: No canvas available for export")
		return

	# Validate before export (if enabled)
	if not _run_validation_for_export():
		return  # Validation failed, export blocked

	# Ensure export directory exists
	_ensure_export_directory()

	# Set default filename based on dialogue_id
	var export_id = dialogue_id if not dialogue_id.is_empty() else "unnamed_dialogue"
	_export_dialog.current_file = export_id + ".json"
	_export_dialog.popup_centered_ratio(0.7)


func _on_validate_pressed() -> void:
	if _is_validating:
		_hide_validation_panel()
	else:
		_show_validation_panel()


func _on_undo_pressed() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("undo") and dialogue_canvas.has_method("has_undo"):
			if dialogue_canvas.has_undo():
				dialogue_canvas.undo()
				print("DialogueEditor: Undo")


func _on_redo_pressed() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("redo") and dialogue_canvas.has_method("has_redo"):
			if dialogue_canvas.has_redo():
				dialogue_canvas.redo()
				print("DialogueEditor: Redo")


func _on_reset_view_pressed() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("reset_view"):
			dialogue_canvas.reset_view()
			_update_status_bar()
			print("DialogueEditor: View reset")


func _on_auto_layout_pressed() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("auto_layout"):
			dialogue_canvas.auto_layout()
			print("DialogueEditor: Auto layout applied")


# =============================================================================
# NODE OPERATIONS (KEYBOARD SHORTCUTS)
# =============================================================================

func _delete_selected_nodes() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("delete_selected_nodes"):
			dialogue_canvas.delete_selected_nodes()


func _select_all_nodes() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("select_all_nodes"):
			dialogue_canvas.select_all_nodes()


func _deselect_all_nodes() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("deselect_all_nodes"):
			dialogue_canvas.deselect_all_nodes()
	# Also hide property panel
	if _property_panel:
		_property_panel.hide_panel()


func _duplicate_selected_nodes() -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("duplicate_selected_nodes"):
			dialogue_canvas.duplicate_selected_nodes()


func _quick_add_node(node_type: String) -> void:
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("add_dialogue_node_at_center"):
			dialogue_canvas.add_dialogue_node_at_center(node_type)
			print("DialogueEditor: Quick added %s node" % node_type)


func _is_text_field_focused() -> bool:
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		return focused is LineEdit or focused is TextEdit
	return false


# =============================================================================
# HELP SYSTEM
# =============================================================================

var _help_dialog: AcceptDialog = null
var _whats_this_mode: bool = false
var _whats_this_btn: Button = null

func _show_help_dialog(tab_index: int = 0) -> void:
	if not _help_dialog:
		_create_help_dialog()
	var tabs = _help_dialog.get_node_or_null("TabContainer")
	if tabs:
		tabs.current_tab = tab_index
	_help_dialog.popup_centered()


func _create_help_dialog() -> void:
	_help_dialog = AcceptDialog.new()
	_help_dialog.name = "HelpDialog"
	_help_dialog.title = "Dialogue Editor - Help"
	_help_dialog.dialog_text = ""
	_help_dialog.min_size = Vector2(800, 700)

	# Create tab container
	var tabs = TabContainer.new()
	tabs.name = "TabContainer"
	tabs.custom_minimum_size = Vector2(780, 600)

	# Tab 1: Quick Start
	var quick_start = _create_quick_start_tab()
	quick_start.name = "Quick Start"
	tabs.add_child(quick_start)

	# Tab 2: Keyboard Shortcuts
	var shortcuts = _create_shortcuts_tab()
	shortcuts.name = "Shortcuts"
	tabs.add_child(shortcuts)

	# Tab 3: Node Reference
	var node_ref = _create_node_reference_tab()
	node_ref.name = "Node Types"
	tabs.add_child(node_ref)

	# Tab 4: Troubleshooting
	var troubleshoot = _create_troubleshooting_tab()
	troubleshoot.name = "Troubleshooting"
	tabs.add_child(troubleshoot)

	_help_dialog.add_child(tabs)
	add_child(_help_dialog)


func _create_quick_start_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_add_help_title(vbox, "Quick Start Guide")

	_add_help_paragraph(vbox, """Welcome to the Dialogue Tree Editor! This tool lets you create branching conversations visually.

1. CREATE A NEW DIALOGUE
   Click 'New' or press Ctrl+N to start fresh.

2. ADD A START NODE
   Every dialogue needs exactly one Start node. Right-click the canvas or press '1' to add one.

3. ADD SPEAKER NODES
   Press '2' or drag 'Speaker' from the palette. Connect it to the Start node by dragging from the output (right) to the input (left).

4. ADD PLAYER CHOICES
   Use Choice nodes (press '3') for player dialogue options. Connect multiple choices from a single Speaker node.

5. END THE CONVERSATION
   Add End nodes (press '5') at the end of each dialogue path.

6. SAVE AND EXPORT
   - Ctrl+S saves as .dtree (editor format)
   - Ctrl+E exports as .json (game format)""")

	_add_help_section(vbox, "Canvas Controls")
	_add_help_paragraph(vbox, """- Pan: Middle mouse button or right-click drag
- Zoom: Scroll wheel
- Select: Left-click on node
- Multi-select: Ctrl+click or drag selection box
- Connect: Drag from output to input slot
- Delete connection: Right-click on connection line""")

	_add_help_section(vbox, "Testing Your Dialogue")
	_add_help_paragraph(vbox, """Press F5 to test your dialogue in the editor. The test panel lets you:
- Play through dialogue making choices
- See current node highlighted
- Track simulated game state changes
- Jump to any node for testing""")

	scroll.add_child(vbox)
	return scroll


func _create_shortcuts_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_add_help_title(vbox, "Keyboard Shortcuts")

	_add_shortcut_section(vbox, "File Operations")
	_add_shortcut_row(vbox, "Ctrl+N", "New dialogue")
	_add_shortcut_row(vbox, "Ctrl+O", "Open dialogue")
	_add_shortcut_row(vbox, "Ctrl+S", "Save dialogue")
	_add_shortcut_row(vbox, "Ctrl+Shift+S", "Save As...")
	_add_shortcut_row(vbox, "Ctrl+E", "Export to JSON")

	_add_shortcut_section(vbox, "Edit Operations")
	_add_shortcut_row(vbox, "Ctrl+Z", "Undo")
	_add_shortcut_row(vbox, "Ctrl+Shift+Z", "Redo")
	_add_shortcut_row(vbox, "Ctrl+Y", "Redo (alternative)")
	_add_shortcut_row(vbox, "Delete", "Delete selected nodes")
	_add_shortcut_row(vbox, "Ctrl+D", "Duplicate selected nodes")
	_add_shortcut_row(vbox, "Ctrl+A", "Select all nodes")
	_add_shortcut_row(vbox, "Ctrl+Shift+T", "Save selection as template")
	_add_shortcut_row(vbox, "Escape", "Deselect all nodes")

	_add_shortcut_section(vbox, "Quick Add Nodes")
	_add_shortcut_row(vbox, "1", "Add Start node")
	_add_shortcut_row(vbox, "2", "Add Speaker node")
	_add_shortcut_row(vbox, "3", "Add Choice node")
	_add_shortcut_row(vbox, "4", "Add Branch node")
	_add_shortcut_row(vbox, "5", "Add End node")

	_add_shortcut_section(vbox, "Navigation & Testing")
	_add_shortcut_row(vbox, "F1", "Show this help")
	_add_shortcut_row(vbox, "F3", "Find next search result")
	_add_shortcut_row(vbox, "Shift+F3", "Find previous search result")
	_add_shortcut_row(vbox, "F5", "Toggle test mode")

	scroll.add_child(vbox)
	return scroll


func _create_node_reference_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_add_help_title(vbox, "Node Types Reference")

	_add_help_section(vbox, "Core Nodes")

	_add_node_description(vbox, "Start (Green)", """Entry point for dialogue. Every tree needs exactly one.
- Outputs: 1 (flow)
- No inputs or fields""")

	_add_node_description(vbox, "Speaker (Colored by speaker)", """NPC dialogue line shown to player.
- Inputs: 1 | Outputs: 1
- Fields: Speaker dropdown, Text (500 char max), Portrait (optional)""")

	_add_node_description(vbox, "Choice (Blue)", """Player dialogue option.
- Inputs: 1 | Outputs: 1
- Fields: Choice text
- Connect multiple from one Speaker for branching""")

	_add_node_description(vbox, "Branch (Yellow)", """Conditional branching based on game state.
- Inputs: 1 | Outputs: 2 (True/False)
- Fields: Condition key, Operator, Value""")

	_add_node_description(vbox, "End (Red)", """Terminates dialogue.
- Inputs: 1 | No outputs
- Fields: End type (normal, combat, trade, exit)""")

	_add_help_section(vbox, "Advanced Nodes")

	_add_node_description(vbox, "Skill Check (Purple)", """Test player skill vs difficulty.
- Inputs: 1 | Outputs: 2 (Success/Fail)
- Fields: Skill type, DC (difficulty class)""")

	_add_node_description(vbox, "Flag Check (Cyan)", """Check game flag/variable.
- Inputs: 1 | Outputs: 2 (True/False)
- Fields: Flag name, Operator, Value""")

	_add_node_description(vbox, "Flag Set (Cyan)", """Set game flag/variable.
- Inputs: 1 | Outputs: 1
- Fields: Flag name, Value""")

	_add_node_description(vbox, "Quest (Gold)", """Quest state manipulation.
- Inputs: 1 | Outputs: 1
- Fields: Quest ID, Action (start/complete/fail/update)""")

	_add_node_description(vbox, "Reputation (Magenta)", """Modify faction reputation.
- Inputs: 1 | Outputs: 1
- Fields: Faction, Amount (+/-)""")

	_add_node_description(vbox, "Item (Brown)", """Give, take, or check items.
- Inputs: 1 | Outputs: 1-2
- Fields: Action (give/take/check), Item ID, Quantity""")

	scroll.add_child(vbox)
	return scroll


func _create_troubleshooting_tab() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_add_help_title(vbox, "Troubleshooting")

	_add_help_section(vbox, "Validation Errors")

	_add_help_paragraph(vbox, """'No Start node found'
- Every dialogue needs exactly one Start node
- Add a Start node and connect it to your dialogue

'Dead end detected'
- A non-End node has no outgoing connections
- Connect it to another node or an End node

'Orphan node detected'
- A node has no incoming connections
- Either connect it to the dialogue flow or delete it

'Circular reference warning'
- Nodes form a loop (may be intentional for repeating options)
- Check connections if this is unexpected""")

	_add_help_section(vbox, "Common Issues")

	_add_help_paragraph(vbox, """Portrait not showing
- Check the file path is correct
- Ensure the image file exists
- Use supported formats: PNG, JPG, WebP

Large dialogue trees are slow
- Minimap auto-disables for 1000+ nodes
- Consider splitting very large dialogues
- Use search (Ctrl+F) to navigate instead of scrolling

File won't load
- File may be corrupted - check for backup
- Ensure file is valid JSON format
- Check auto-save folder for recovery""")

	_add_help_section(vbox, "Recovery")

	_add_help_paragraph(vbox, """Auto-save Recovery
- On crash, recovery dialog appears on next launch
- Choose 'Recover' to restore work
- Auto-save location: user://dialogue_editor_autosave/

Manual Backup
- .dtree files are JSON - can be edited manually
- Keep backups of important dialogue files""")

	_add_help_section(vbox, "Getting More Help")

	_add_help_paragraph(vbox, """Full Documentation
See: docs/tools/dialogue-tree-editor-guide.md

Export Format Reference
See the documentation for complete JSON export format specification.""")

	scroll.add_child(vbox)
	return scroll


func _add_help_title(parent: VBoxContainer, title: String) -> void:
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color(1.0, 0.9, 0.5)
	parent.add_child(label)
	var sep = HSeparator.new()
	parent.add_child(sep)


func _add_help_section(parent: VBoxContainer, title: String) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	parent.add_child(spacer)

	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 18)
	label.modulate = Color(0.7, 0.9, 1.0)
	parent.add_child(label)


func _add_help_paragraph(parent: VBoxContainer, text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(750, 0)
	parent.add_child(label)


func _add_node_description(parent: VBoxContainer, node_name: String, description: String) -> void:
	var hbox = HBoxContainer.new()

	var name_label = Label.new()
	name_label.text = node_name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.modulate = Color(0.9, 0.9, 0.6)
	name_label.custom_minimum_size = Vector2(200, 0)
	hbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(530, 0)
	hbox.add_child(desc_label)

	parent.add_child(hbox)


func _add_shortcut_section(parent: VBoxContainer, title: String) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	parent.add_child(spacer)

	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 18)
	label.modulate = Color(1.0, 0.9, 0.5)
	parent.add_child(label)


func _add_shortcut_row(parent: VBoxContainer, shortcut: String, description: String) -> void:
	var row = HBoxContainer.new()

	var key_label = Label.new()
	key_label.text = shortcut
	key_label.custom_minimum_size = Vector2(180, 0)
	key_label.add_theme_font_size_override("font_size", 14)
	key_label.modulate = Color(0.7, 0.9, 1.0)
	row.add_child(key_label)

	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 14)
	row.add_child(desc_label)

	parent.add_child(row)


# =============================================================================
# WHAT'S THIS? MODE
# =============================================================================

func _toggle_whats_this_mode() -> void:
	_whats_this_mode = not _whats_this_mode
	if _whats_this_btn:
		_whats_this_btn.button_pressed = _whats_this_mode
	if _whats_this_mode:
		Input.set_default_cursor_shape(Input.CURSOR_HELP)
		show_notification("What's This? mode: Click on any element for help", 0, 3.0)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _handle_whats_this_click(control: Control) -> bool:
	"""Handle click in What's This? mode. Returns true if handled."""
	if not _whats_this_mode:
		return false

	# Exit What's This mode
	_toggle_whats_this_mode()

	# Show help based on what was clicked
	var help_text = _get_whats_this_help(control)
	if not help_text.is_empty():
		_show_whats_this_popup(help_text)

	return true


func _get_whats_this_help(control: Control) -> String:
	if not control:
		return ""

	# Check by node name or type
	var name = control.name.to_lower()

	if "new" in name:
		return "New Button\nCreate a new empty dialogue tree.\nShortcut: Ctrl+N"
	elif "open" in name:
		return "Open Button\nOpen an existing .dtree file.\nShortcut: Ctrl+O"
	elif "save" in name:
		return "Save Button\nSave the current dialogue tree.\nShortcut: Ctrl+S (Save) or Ctrl+Shift+S (Save As)"
	elif "export" in name:
		return "Export Button\nExport dialogue to JSON for game use.\nShortcut: Ctrl+E"
	elif "test" in name:
		return "Test Button\nPlay through dialogue in the editor.\nShortcut: F5"
	elif "validate" in name:
		return "Validate Button\nCheck for structural issues in the dialogue tree."
	elif "reset" in name and "view" in name:
		return "Reset View\nReset canvas zoom and scroll position."
	elif "auto" in name and "layout" in name:
		return "Auto Layout\nAutomatically arrange nodes in a tree layout."
	elif "help" in name:
		return "Help Button\nOpen help documentation.\nShortcut: F1"
	elif "search" in name:
		return "Search\nFind nodes by text content, speaker, or ID.\nShortcut: F3 (next), Shift+F3 (previous)"
	elif "filter" in name:
		return "Filter\nShow only specific node types on the canvas."
	elif control is GraphEdit:
		return "Canvas\nVisual workspace for building dialogue trees.\n- Pan: Middle mouse or right-click drag\n- Zoom: Scroll wheel\n- Connect: Drag from output to input"
	elif control is GraphNode:
		return "Dialogue Node\nPart of the dialogue tree.\n- Click to select\n- Drag connections between nodes\n- Delete: Select and press Delete"

	return ""


func _show_whats_this_popup(text: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "What's This?"
	dialog.dialog_text = text
	dialog.min_size = Vector2(400, 150)
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)


# =============================================================================
# NOTIFICATION SYSTEM
# =============================================================================

var _notification_container: VBoxContainer = null
const NOTIFICATION_COLORS = {
	0: Color(0.3, 0.5, 0.8, 0.95),   # INFO - Blue
	1: Color(0.3, 0.7, 0.4, 0.95),   # SUCCESS - Green
	2: Color(0.8, 0.6, 0.2, 0.95),   # WARNING - Orange
	3: Color(0.8, 0.3, 0.3, 0.95),   # ERROR - Red
}

func _setup_notifications() -> void:
	# Create notification container at bottom of screen
	_notification_container = VBoxContainer.new()
	_notification_container.name = "NotificationContainer"
	_notification_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Position at bottom-right
	_notification_container.anchor_left = 1.0
	_notification_container.anchor_right = 1.0
	_notification_container.anchor_top = 1.0
	_notification_container.anchor_bottom = 1.0
	_notification_container.offset_left = -420
	_notification_container.offset_right = -20
	_notification_container.offset_top = -200
	_notification_container.offset_bottom = -20

	_notification_container.alignment = BoxContainer.ALIGNMENT_END
	add_child(_notification_container)

	# Connect to error handler
	var handler = ErrorHandlerScript.get_instance()
	handler.notification_requested.connect(_on_notification_requested)


func _on_notification_requested(message: String, type: int, duration: float) -> void:
	if not _notification_container:
		return

	# Create notification panel
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Style based on type
	var style = StyleBoxFlat.new()
	style.bg_color = NOTIFICATION_COLORS.get(type, NOTIFICATION_COLORS[0])
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)

	# Add message label
	var label = Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(label)

	_notification_container.add_child(panel)

	# Fade out and remove after duration
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)


## Show a notification (convenience method).
func show_notification(message: String, type: int = 0, duration: float = 3.0) -> void:
	_on_notification_requested(message, type, duration)


# =============================================================================
# TEST MODE
# =============================================================================

func _toggle_test_mode() -> void:
	if _is_testing:
		_stop_test_mode()
	else:
		_start_test_mode()


func _start_test_mode() -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_warning("DialogueEditor: No canvas available for testing")
		return

	# Check if we have a start node
	if dialogue_canvas.has_method("get_start_node"):
		var start_node = dialogue_canvas.get_start_node()
		if not start_node:
			push_warning("DialogueEditor: No Start node found. Add a Start node to test.")
			return

	# Create test panel if it doesn't exist
	if not _test_panel:
		_create_test_panel()

	# Show the test panel
	_test_panel.visible = true
	_is_testing = true

	# Update button text
	if test_btn:
		test_btn.text = "Stop Test"

	# Start the test
	_test_panel.start_test(dialogue_canvas)
	print("DialogueEditor: Test mode started")


func _stop_test_mode() -> void:
	if _test_panel:
		_test_panel.stop_test()
		_test_panel.visible = false

	_is_testing = false

	# Update button text
	if test_btn:
		test_btn.text = "Test (F5)"

	print("DialogueEditor: Test mode stopped")


func _create_test_panel() -> void:
	# Create the test panel using the script
	_test_panel = TestPanelScript.new()
	_test_panel.name = "TestPanel"
	_test_panel.visible = false

	# Connect signals
	_test_panel.test_stopped.connect(_on_test_stopped)
	_test_panel.node_highlighted.connect(_on_test_node_highlighted)

	# We need to restructure the layout to add the test panel to the right
	# Get the right panel (parent of canvas)
	var right_panel = dialogue_canvas.get_parent()
	if right_panel:
		# Create a new HSplit to hold the canvas area and test panel
		_test_hsplit = HSplitContainer.new()
		_test_hsplit.name = "TestHSplit"
		_test_hsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_test_hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Get the canvas's position in the parent
		var canvas_index = dialogue_canvas.get_index()

		# Reparent the canvas to the new HSplit
		dialogue_canvas.reparent(_test_hsplit)

		# Add the test panel to the HSplit
		_test_hsplit.add_child(_test_panel)

		# Add the HSplit to the right panel where the canvas was
		right_panel.add_child(_test_hsplit)
		right_panel.move_child(_test_hsplit, canvas_index)

		# Set split offset (canvas takes more space)
		_test_hsplit.split_offset = -350


func _on_test_stopped() -> void:
	_is_testing = false
	if test_btn:
		test_btn.text = "Test (F5)"


func _on_test_node_highlighted(node_id: String) -> void:
	# Optionally scroll to the highlighted node
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		var node = dialogue_canvas.get_node_or_null(NodePath(node_id))
		if node and node is GraphNode:
			# Center view on the node (optional enhancement)
			pass


# =============================================================================
# VALIDATION
# =============================================================================

func _show_validation_panel() -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_warning("DialogueEditor: No canvas available for validation")
		return

	# Create validation panel if it doesn't exist
	if not _validation_panel:
		_create_validation_panel()

	# Show the validation panel
	_validation_panel.visible = true
	_is_validating = true

	# Update button text
	if validate_btn:
		validate_btn.text = "Hide Validation"

	# Run validation
	_validation_panel.validate()

	# Update warning icons on nodes
	_update_node_warning_icons()

	print("DialogueEditor: Validation panel shown")


func _hide_validation_panel() -> void:
	if _validation_panel:
		_validation_panel.visible = false

	_is_validating = false

	# Update button text
	if validate_btn:
		validate_btn.text = "Validate"

	# Clear warning icons
	_clear_node_warning_icons()

	print("DialogueEditor: Validation panel hidden")


func _create_validation_panel() -> void:
	# Create the validation panel using the script
	_validation_panel = ValidationPanelScript.new()
	_validation_panel.name = "ValidationPanel"
	_validation_panel.visible = false
	_validation_panel.custom_minimum_size = Vector2(300, 150)

	# Setup with canvas reference
	_validation_panel.setup(dialogue_canvas)

	# Connect signals
	_validation_panel.issue_selected.connect(_on_validation_issue_selected)
	_validation_panel.panel_closed.connect(_on_validation_panel_closed)

	# Add validation panel below the canvas using a VSplit
	# Get the parent that contains the canvas (could be test HSplit or RightPanel)
	var canvas_parent = dialogue_canvas.get_parent()
	if canvas_parent:
		# Create a new VSplit to hold the canvas area and validation panel
		_validation_vsplit = VSplitContainer.new()
		_validation_vsplit.name = "ValidationVSplit"
		_validation_vsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_validation_vsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Get the canvas's position in the parent
		var canvas_index = dialogue_canvas.get_index()

		# Reparent the canvas to the new VSplit
		dialogue_canvas.reparent(_validation_vsplit)

		# Add the validation panel to the VSplit (below canvas)
		_validation_vsplit.add_child(_validation_panel)

		# Add the VSplit to the parent where the canvas was
		canvas_parent.add_child(_validation_vsplit)
		canvas_parent.move_child(_validation_vsplit, canvas_index)

		# Set split offset (canvas takes more space, validation at bottom)
		_validation_vsplit.split_offset = -200


func _on_validation_issue_selected(node_id: String) -> void:
	# Jump to and select the problem node
	_select_and_center_node(node_id)


func _on_validation_panel_closed() -> void:
	_is_validating = false
	if validate_btn:
		validate_btn.text = "Validate"
	_clear_node_warning_icons()


func _select_and_center_node(node_id: String) -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		return

	var node = dialogue_canvas.get_node_or_null(NodePath(node_id))
	if not node or not node is GraphNode:
		return

	# Deselect all nodes first
	for child in dialogue_canvas.get_children():
		if child is GraphNode:
			child.selected = false

	# Select the target node
	node.selected = true

	# Center the view on the node
	var node_center = node.position_offset + node.size / 2
	var viewport_size = dialogue_canvas.size
	var target_scroll = node_center * dialogue_canvas.zoom - viewport_size / 2

	dialogue_canvas.scroll_offset = target_scroll


func _update_node_warning_icons() -> void:
	if not _validation_panel or not dialogue_canvas:
		return

	# Get nodes with issues
	var nodes_with_issues = _validation_panel.get_nodes_with_issues()

	# Add warning indicators to each problematic node
	for node_id in nodes_with_issues:
		var node = dialogue_canvas.get_node_or_null(NodePath(node_id))
		if node and node is GraphNode:
			_add_warning_icon_to_node(node)


func _add_warning_icon_to_node(node: GraphNode) -> void:
	# Check if warning icon already exists
	if node.has_node("ValidationWarning"):
		return

	# Create warning icon
	var warning_container = HBoxContainer.new()
	warning_container.name = "ValidationWarning"
	warning_container.size_flags_horizontal = Control.SIZE_SHRINK_END

	var warning_icon = TextureRect.new()
	warning_icon.name = "WarningIcon"
	warning_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	warning_icon.custom_minimum_size = Vector2(16, 16)

	# Get warning icon from editor theme
	if Engine.is_editor_hint():
		var base_control = EditorInterface.get_base_control()
		if base_control:
			warning_icon.texture = base_control.get_theme_icon("StatusWarning", "EditorIcons")

	warning_container.add_child(warning_icon)

	# Add to node's titlebar area (insert at beginning)
	node.add_child(warning_container)
	node.move_child(warning_container, 0)


func _clear_node_warning_icons() -> void:
	if not dialogue_canvas:
		return

	# Remove warning icons from all nodes
	for child in dialogue_canvas.get_children():
		if child is GraphNode:
			var warning = child.get_node_or_null("ValidationWarning")
			if warning:
				warning.queue_free()


func _run_validation_for_export() -> bool:
	"""Run validation before export and return true if export should proceed."""
	if not _validate_before_export:
		return true

	# Create a temporary validator
	var validator = DialogueValidatorScript.new()
	validator.setup(dialogue_canvas)

	# Check for errors only (warnings don't block export)
	var errors = validator.validate_errors_only()

	if errors.is_empty():
		return true

	# Show validation panel with errors
	_show_validation_panel()

	# Show error message
	push_warning("DialogueEditor: Export blocked due to %d validation error(s). Fix errors before exporting." % errors.size())

	return false


func _refresh_validation() -> void:
	"""Refresh validation if the panel is visible."""
	if _is_validating and _validation_panel and _validation_panel.visible:
		_clear_node_warning_icons()
		_validation_panel.validate()
		_update_node_warning_icons()


# =============================================================================
# SEARCH & FILTER
# =============================================================================

func _on_search_text_changed(new_text: String) -> void:
	if _search_manager:
		var field = _get_search_field()
		_search_manager.search(new_text, field)


func _on_search_submitted(_text: String) -> void:
	# When Enter is pressed, go to next result
	_on_find_next()


func _on_search_field_changed(_index: int) -> void:
	# Re-run search with new field
	if search_edit and _search_manager:
		var field = _get_search_field()
		_search_manager.search(search_edit.text, field)


func _on_find_next() -> void:
	if _search_manager:
		# If no current search and there's text, search first
		if not _search_manager.has_results() and search_edit and not search_edit.text.is_empty():
			var field = _get_search_field()
			_search_manager.search(search_edit.text, field)
		else:
			_search_manager.find_next()


func _on_find_previous() -> void:
	if _search_manager:
		# If no current search and there's text, search first
		if not _search_manager.has_results() and search_edit and not search_edit.text.is_empty():
			var field = _get_search_field()
			_search_manager.search(search_edit.text, field)
		else:
			_search_manager.find_previous()


func _on_search_completed(results: Array[String], total: int) -> void:
	if search_result_label:
		if total == 0:
			search_result_label.text = "0/0"
		else:
			search_result_label.text = "0/%d" % total


func _on_search_result_selected(_node_id: String, index: int, total: int) -> void:
	if search_result_label:
		search_result_label.text = "%d/%d" % [index + 1, total]


func _on_filter_changed() -> void:
	# Refresh filter dropdown items if needed
	pass


func _on_filter_selected(index: int) -> void:
	if not _search_manager:
		return

	if index == 0:
		# "All Types" selected
		_search_manager.clear_filter()
	else:
		# Get the selected type from dropdown
		var type_name = filter_dropdown.get_item_text(index)
		_search_manager.set_type_filter(type_name)


func _get_search_field() -> int:
	if search_field:
		return search_field.selected
	return 0  # ALL


func _update_filter_dropdown() -> void:
	if not filter_dropdown or not _search_manager:
		return

	# Remember current selection
	var current_text = ""
	if filter_dropdown.selected > 0:
		current_text = filter_dropdown.get_item_text(filter_dropdown.selected)

	# Clear and rebuild
	filter_dropdown.clear()
	filter_dropdown.add_item("All Types")

	# Get available types from canvas
	var types = _search_manager.get_available_types()
	for type_name in types:
		filter_dropdown.add_item(type_name)

	# Restore selection if possible
	if not current_text.is_empty():
		for i in filter_dropdown.item_count:
			if filter_dropdown.get_item_text(i) == current_text:
				filter_dropdown.select(i)
				break


func _clear_search() -> void:
	if _search_manager:
		_search_manager.clear_search()
		_search_manager.clear_filter()

	if search_edit:
		search_edit.text = ""

	if search_result_label:
		search_result_label.text = "0/0"

	if filter_dropdown:
		filter_dropdown.select(0)


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


func _on_export_file_selected(path: String) -> void:
	# Ensure .json extension
	if not path.ends_with(".json"):
		path += ".json"
	_export_to_file(path)


func _export_to_file(path: String) -> void:
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		push_error("DialogueEditor: Canvas not available for export")
		return

	# Determine dialogue_id for export
	var export_id = dialogue_id
	if export_id.is_empty():
		export_id = path.get_file().get_basename()

	# Validate before export
	var export_data = DialogueExporterScript.export_from_canvas(dialogue_canvas, export_id)
	if export_data.is_empty():
		push_error("DialogueEditor: Failed to generate export data")
		return

	# Validate the export
	var validation_errors = DialogueExporterScript.validate_export(export_data)
	if not validation_errors.is_empty():
		push_warning("DialogueEditor: Export validation warnings:")
		for error in validation_errors:
			push_warning("  - %s" % error)

	# Export to file
	var err = DialogueExporterScript.export_to_file(dialogue_canvas, export_id, path)
	if err == OK:
		print("DialogueEditor: Exported to %s" % path)
	else:
		push_error("DialogueEditor: Export failed (error: %d)" % err)


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
		if _auto_save_manager:
			_auto_save_manager.mark_clean()
			_auto_save_manager.set_current_file(path, dialogue_id)
			_auto_save_manager.on_clean_exit()  # Clean up auto-save since we saved properly
		_update_status_bar()
		print("DialogueEditor: Saved to %s" % path)
	else:
		push_error("DialogueEditor: Failed to save: %s (error: %d)" % [path, err])


func _load_from_file(path: String) -> void:
	# Validate file exists
	if not FileAccess.file_exists(path):
		ErrorHandlerScript.error("File not found: %s" % path.get_file())
		return

	var tree_data = DialogueTreeDataScript.load_from_file(path)
	if tree_data == null:
		ErrorHandlerScript.error("Failed to load file: %s\nThe file may be corrupted or in an invalid format." % path.get_file())
		return

	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		ErrorHandlerScript.error("Canvas not available for loading")
		return

	if not dialogue_canvas.has_method("deserialize"):
		ErrorHandlerScript.error("Canvas does not have deserialize method")
		return

	# Validate structure before loading
	var canvas_data = tree_data.to_canvas_data()
	var validation = ErrorHandlerScript.validate_dtree_structure(canvas_data)
	if not validation.valid:
		ErrorHandlerScript.error("Invalid file structure:\n" + "\n".join(validation.errors))
		return

	# Show warnings but continue loading
	for warning_msg in validation.warnings:
		ErrorHandlerScript.warning(warning_msg)

	# Check for circular references
	var cycles = ErrorHandlerScript.detect_circular_references(canvas_data.nodes, canvas_data.connections)
	if not cycles.is_empty():
		ErrorHandlerScript.warning("Circular references detected:\n" + "\n".join(cycles))

	# Load into canvas
	dialogue_canvas.deserialize(canvas_data)

	# Update state
	current_file_path = path
	dialogue_id = tree_data.dialogue_id
	is_dirty = false
	if _auto_save_manager:
		_auto_save_manager.set_current_file(path, dialogue_id)
		_auto_save_manager.mark_clean()
	_update_status_bar()
	_clear_search()
	_update_filter_dropdown()
	_refresh_variable_browser()

	# Show success notification
	var node_count = canvas_data.nodes.size() if canvas_data.has("nodes") else 0
	ErrorHandlerScript.success("Loaded %s (%d nodes)" % [path.get_file(), node_count])


# =============================================================================
# CONFIRMATION DIALOG HANDLERS
# =============================================================================

func _on_confirm_save() -> void:
	# User chose "Save"
	_confirm_dialog.hide()
	if current_file_path.is_empty():
		# Need to do Save As first, then continue pending action
		if _pending_action == "new":
			_pending_action = "save_then_new"
		elif _pending_action == "open":
			_pending_action = "save_then_open"
		# Use call_deferred to ensure dialog is fully closed
		call_deferred("_on_save_as_pressed")
	else:
		_save_to_file(current_file_path)
		# Use call_deferred to ensure dialog is fully closed
		call_deferred("_continue_pending_action")


func _on_confirm_custom_action(action: StringName) -> void:
	if action == "dont_save":
		# User chose "Don't Save" - continue without saving
		is_dirty = false
		_confirm_dialog.hide()
		# Use call_deferred to ensure dialog is fully closed before opening another
		call_deferred("_continue_pending_action")


func _on_confirm_canceled() -> void:
	# User canceled - don't do anything
	_pending_action = ""


func _continue_pending_action() -> void:
	var action = _pending_action
	_pending_action = ""
	match action:
		"new":
			_do_new()
		"open":
			_do_open()


# =============================================================================
# CANVAS SIGNAL HANDLERS
# =============================================================================

func _on_canvas_changed() -> void:
	is_dirty = true
	if _auto_save_manager:
		_auto_save_manager.mark_dirty()
	_update_status_bar()
	_update_filter_dropdown()
	_refresh_validation()
	_refresh_variable_browser()


func _on_zoom_changed(_new_zoom: float) -> void:
	_update_status_bar()


func _on_dialogue_node_selected(node: GraphNode) -> void:
	if _property_panel:
		_property_panel.show_for_node(node)


func _on_dialogue_node_deselected() -> void:
	if _property_panel:
		_property_panel.hide_panel()


func _on_palette_node_clicked(node_type: String) -> void:
	# Add the node at the center of the canvas
	if dialogue_canvas and dialogue_canvas.is_inside_tree():
		if dialogue_canvas.has_method("add_dialogue_node_at_center"):
			dialogue_canvas.add_dialogue_node_at_center(node_type)


# =============================================================================
# TEMPLATE SYSTEM
# =============================================================================

func _on_save_as_template_requested() -> void:
	"""Handle request to save selection as a template."""
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		show_notification("Canvas not available", 3, 3.0)
		return

	# Validate selection
	if dialogue_canvas.has_method("validate_selection_for_template"):
		var validation = dialogue_canvas.validate_selection_for_template()
		if not validation.valid:
			show_notification(validation.reason, 2, 3.0)
			return

	# Get serialized selection data
	var nodes: Array = []
	var connections: Array = []

	if dialogue_canvas.has_method("serialize_selected_nodes"):
		nodes = dialogue_canvas.serialize_selected_nodes()

	if dialogue_canvas.has_method("get_selected_internal_connections"):
		connections = dialogue_canvas.get_selected_internal_connections()

	if nodes.is_empty():
		show_notification("No nodes selected", 2, 3.0)
		return

	# Show the save template dialog
	if _save_template_dialog:
		_save_template_dialog.show_for_selection(nodes, connections)


func _on_template_saved(template) -> void:
	"""Handle successful template save."""
	show_notification("Template '%s' saved successfully" % template.template_name, 1, 3.0)
	print("DialogueEditor: Template saved: %s" % template.template_name)
	# Refresh template library to show the new template
	if template_library:
		template_library.refresh()


func _on_template_library_template_selected(template) -> void:
	"""Handle template selection from library (double-click to insert)."""
	if not dialogue_canvas or not dialogue_canvas.is_inside_tree():
		return

	# Insert template at center of visible canvas area
	if dialogue_canvas.has_method("insert_template"):
		var viewport_center = dialogue_canvas.size / 2
		var canvas_pos = (dialogue_canvas.scroll_offset + viewport_center) / dialogue_canvas.zoom
		dialogue_canvas.insert_template(template, canvas_pos)
		show_notification("Inserted template: %s" % template.template_name, 1, 2.0)


func _on_template_library_drag_started(template) -> void:
	"""Handle template drag start from library."""
	# This is informational - the actual drag handling is done by the canvas
	pass


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
