@tool
extends Control
## Main panel for the Procedural Character Assembler.
## Manages the toolbar, canvas, shape tools, layers, and file operations.

const CharacterProjectScript = preload("res://addons/character_assembler/scripts/character_project.gd")

# Default save directory for character projects
const DEFAULT_PROJECT_DIR := "res://data/characters/"

# Node references - Toolbar
@onready var toolbar: HBoxContainer = $Margin/VBox/Toolbar
@onready var new_btn: Button = $Margin/VBox/Toolbar/NewBtn
@onready var open_btn: Button = $Margin/VBox/Toolbar/OpenBtn
@onready var save_btn: Button = $Margin/VBox/Toolbar/SaveBtn
@onready var save_as_btn: Button = $Margin/VBox/Toolbar/SaveAsBtn
@onready var load_ref_btn: Button = $Margin/VBox/Toolbar/LoadRefBtn
@onready var clear_ref_btn: Button = $Margin/VBox/Toolbar/ClearRefBtn
@onready var opacity_slider: HSlider = $Margin/VBox/Toolbar/OpacitySlider
@onready var canvas_size_spin: SpinBox = $Margin/VBox/Toolbar/CanvasSizeSpinBox

# Node references - Canvas area
@onready var character_canvas = $"Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasContainer/CharacterCanvas"
@onready var fit_btn: Button = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/FitBtn
@onready var zoom_1x_btn: Button = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/Zoom1xBtn
@onready var zoom_2x_btn: Button = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/Zoom2xBtn
@onready var zoom_4x_btn: Button = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/Zoom4xBtn
@onready var zoom_8x_btn: Button = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/Zoom8xBtn
@onready var grid_check: CheckBox = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/GridCheck
@onready var snap_check: CheckBox = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/SnapCheck
@onready var zoom_percent_label: Label = $Margin/VBox/OuterHSplit/InnerHSplit/CenterVBox/CanvasToolbar/ZoomPercentLabel

# Node references - Panels
@onready var shape_tools_panel = $Margin/VBox/OuterHSplit/LeftPanel/LeftScroll/ShapeToolsPanel
@onready var layer_panel = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/LayerPanel
@onready var shape_properties_panel = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/ShapePropertiesPanel
@onready var direction_manager = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/DirectionManager
@onready var body_part_tagger = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/BodyPartTagger
@onready var pose_editor = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/PoseEditor
@onready var animation_generator = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/AnimationGenerator
@onready var export_manager = $Margin/VBox/OuterHSplit/InnerHSplit/RightPanel/RightScroll/RightVBox/ExportManager

# Node references - Status bar
@onready var project_name_label: Label = $Margin/VBox/StatusBar/ProjectNameLabel
@onready var status_label: Label = $Margin/VBox/StatusBar/StatusLabel

# File dialogs
var _open_dialog: FileDialog
var _save_dialog: FileDialog
var _ref_dialog: FileDialog
var _confirm_dialog: ConfirmationDialog
var _pending_action: String = ""

# State
var current_project: RefCounted = null
var current_file_path: String = ""
var is_dirty: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_h_size_flags(Control.SIZE_EXPAND_FILL)
	set_v_size_flags(Control.SIZE_EXPAND_FILL)
	custom_minimum_size = Vector2(800, 600)

	_setup_dialogs()
	_connect_toolbar_signals()
	_connect_canvas_signals()
	_connect_panel_signals()
	_ensure_project_directory()
	_new_project()
	_update_status_bar()


func _setup_dialogs() -> void:
	# Open file dialog
	_open_dialog = FileDialog.new()
	_open_dialog.name = "OpenDialog"
	_open_dialog.title = "Open Character Project"
	_open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_open_dialog.access = FileDialog.ACCESS_RESOURCES
	_open_dialog.filters = PackedStringArray(["*.charproj ; Character Project"])
	_open_dialog.current_dir = DEFAULT_PROJECT_DIR
	_open_dialog.file_selected.connect(_on_open_file_selected)
	add_child(_open_dialog)

	# Save file dialog
	_save_dialog = FileDialog.new()
	_save_dialog.name = "SaveDialog"
	_save_dialog.title = "Save Character Project"
	_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_save_dialog.access = FileDialog.ACCESS_RESOURCES
	_save_dialog.filters = PackedStringArray(["*.charproj ; Character Project"])
	_save_dialog.current_dir = DEFAULT_PROJECT_DIR
	_save_dialog.file_selected.connect(_on_save_file_selected)
	add_child(_save_dialog)

	# Reference image dialog
	_ref_dialog = FileDialog.new()
	_ref_dialog.name = "RefDialog"
	_ref_dialog.title = "Load Reference Image"
	_ref_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_ref_dialog.access = FileDialog.ACCESS_RESOURCES
	_ref_dialog.filters = PackedStringArray(["*.png, *.jpg, *.jpeg, *.webp ; Image Files"])
	_ref_dialog.file_selected.connect(_on_ref_file_selected)
	add_child(_ref_dialog)

	# Confirmation dialog
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


func _ensure_project_directory() -> void:
	if not DirAccess.dir_exists_absolute(DEFAULT_PROJECT_DIR):
		var err = DirAccess.make_dir_recursive_absolute(DEFAULT_PROJECT_DIR)
		if err == OK:
			print("CharacterAssembler: Created project directory: %s" % DEFAULT_PROJECT_DIR)


func _connect_toolbar_signals() -> void:
	if new_btn:
		new_btn.pressed.connect(_on_new_pressed)
		new_btn.tooltip_text = "New Project (Ctrl+N)"
	if open_btn:
		open_btn.pressed.connect(_on_open_pressed)
		open_btn.tooltip_text = "Open Project (Ctrl+O)"
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)
		save_btn.tooltip_text = "Save Project (Ctrl+S)"
	if save_as_btn:
		save_as_btn.pressed.connect(_on_save_as_pressed)
		save_as_btn.tooltip_text = "Save As (Ctrl+Shift+S)"
	if load_ref_btn:
		load_ref_btn.pressed.connect(_on_load_ref_pressed)
		load_ref_btn.tooltip_text = "Load reference image"
	if clear_ref_btn:
		clear_ref_btn.pressed.connect(_on_clear_ref_pressed)
		clear_ref_btn.tooltip_text = "Clear reference image"
	if opacity_slider:
		opacity_slider.value_changed.connect(_on_opacity_changed)
	if canvas_size_spin:
		canvas_size_spin.value_changed.connect(_on_canvas_size_changed)

	# Zoom buttons
	if fit_btn:
		fit_btn.pressed.connect(func(): character_canvas.fit_to_view())
	if zoom_1x_btn:
		zoom_1x_btn.pressed.connect(func(): character_canvas.set_zoom(1.0))
	if zoom_2x_btn:
		zoom_2x_btn.pressed.connect(func(): character_canvas.set_zoom(2.0))
	if zoom_4x_btn:
		zoom_4x_btn.pressed.connect(func(): character_canvas.set_zoom(4.0))
	if zoom_8x_btn:
		zoom_8x_btn.pressed.connect(func(): character_canvas.set_zoom(8.0))

	# Grid and snap
	if grid_check:
		grid_check.toggled.connect(func(pressed): character_canvas.grid_enabled = pressed)
	if snap_check:
		snap_check.toggled.connect(func(pressed): character_canvas.snap_to_grid = pressed)


func _connect_canvas_signals() -> void:
	if character_canvas:
		character_canvas.shape_added.connect(_on_shape_added)
		character_canvas.shape_removed.connect(_on_shape_removed)
		character_canvas.shape_selected.connect(_on_shape_selected)
		character_canvas.shape_modified.connect(_on_shape_modified)
		character_canvas.canvas_changed.connect(_on_canvas_changed)
		character_canvas.zoom_changed.connect(_on_zoom_changed)
		character_canvas.pivot_clicked.connect(_on_pivot_clicked)


func _connect_panel_signals() -> void:
	if shape_tools_panel:
		shape_tools_panel.tool_changed.connect(_on_tool_changed)
		shape_tools_panel.color_changed.connect(_on_color_changed)
		print("CharacterAssembler: Connected shape_tools_panel signals")
	else:
		push_warning("CharacterAssembler: shape_tools_panel is null!")

	if layer_panel:
		layer_panel.layer_selected.connect(_on_layer_selected)
		layer_panel.layer_order_changed.connect(_on_layer_order_changed)
		layer_panel.delete_requested.connect(_on_delete_requested)
		print("CharacterAssembler: Connected layer_panel signals")
	else:
		push_warning("CharacterAssembler: layer_panel is null!")

	if shape_properties_panel:
		shape_properties_panel.property_changed.connect(_on_property_changed)
		print("CharacterAssembler: Connected shape_properties_panel signals")
	else:
		push_warning("CharacterAssembler: shape_properties_panel is null!")

	if direction_manager:
		direction_manager.direction_changed.connect(_on_direction_changed)
		direction_manager.shapes_updated.connect(_on_direction_shapes_updated)
		direction_manager.request_copy_from_current.connect(_on_direction_copy_request)
		print("CharacterAssembler: Connected direction_manager signals")
	else:
		push_warning("CharacterAssembler: direction_manager is null!")

	if body_part_tagger:
		body_part_tagger.body_parts_changed.connect(_on_body_parts_changed)
		body_part_tagger.pivot_mode_changed.connect(_on_pivot_mode_changed)
		body_part_tagger.body_part_selected.connect(_on_body_part_selected)
		print("CharacterAssembler: Connected body_part_tagger signals")
	else:
		push_warning("CharacterAssembler: body_part_tagger is null!")

	if pose_editor:
		pose_editor.pose_changed.connect(_on_pose_changed)
		pose_editor.pose_selected.connect(_on_pose_selected)
		pose_editor.preview_requested.connect(_on_pose_preview_requested)
		print("CharacterAssembler: Connected pose_editor signals")
	else:
		push_warning("CharacterAssembler: pose_editor is null!")

	if animation_generator:
		animation_generator.animation_generated.connect(_on_animation_generated)
		animation_generator.animation_selected.connect(_on_animation_selected)
		animation_generator.preview_frame_changed.connect(_on_animation_preview_frame_changed)
		print("CharacterAssembler: Connected animation_generator signals")
	else:
		push_warning("CharacterAssembler: animation_generator is null!")

	if export_manager:
		export_manager.export_requested.connect(_on_export_requested)
		print("CharacterAssembler: Connected export_manager signals")
	else:
		push_warning("CharacterAssembler: export_manager is null!")


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventKey and event.pressed:
		var handled := false

		if event.ctrl_pressed:
			match event.keycode:
				KEY_N:
					_on_new_pressed()
					handled = true
				KEY_O:
					_on_open_pressed()
					handled = true
				KEY_S:
					if event.shift_pressed:
						_on_save_as_pressed()
					else:
						_on_save_pressed()
					handled = true
		else:
			match event.keycode:
				KEY_DELETE, KEY_BACKSPACE:
					if character_canvas:
						character_canvas.delete_selected()
					handled = true

		if handled:
			get_viewport().set_input_as_handled()


# =============================================================================
# PROJECT MANAGEMENT
# =============================================================================

func _new_project() -> void:
	current_project = CharacterProjectScript.new()
	current_file_path = ""
	is_dirty = false

	if character_canvas:
		character_canvas.load_from_project(current_project)
		character_canvas.clear_pivot_points()
		character_canvas.clear_highlight()

	if canvas_size_spin:
		canvas_size_spin.value = current_project.canvas_size

	if opacity_slider:
		opacity_slider.value = current_project.reference_opacity * 100

	if body_part_tagger:
		body_part_tagger.load_from_project({})

	if pose_editor:
		pose_editor.load_from_project([])

	if animation_generator:
		animation_generator.load_from_project({})
		_update_animation_generator()

	if direction_manager:
		direction_manager.load_direction_views({})
		_update_direction_manager()

	_update_export_manager()
	_update_layers()
	_update_status_bar()
	print("CharacterAssembler: New project created")


func _on_new_pressed() -> void:
	if is_dirty:
		_pending_action = "new"
		_confirm_dialog.popup_centered()
	else:
		_do_new()


func _do_new() -> void:
	_new_project()


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
	if current_project and not current_project.character_id.is_empty():
		_save_dialog.current_file = current_project.character_id + ".charproj"
	else:
		_save_dialog.current_file = "new_character.charproj"
	_save_dialog.popup_centered_ratio(0.7)


# =============================================================================
# REFERENCE IMAGE
# =============================================================================

func _on_load_ref_pressed() -> void:
	_ref_dialog.popup_centered_ratio(0.7)


func _on_ref_file_selected(path: String) -> void:
	if character_canvas and character_canvas.load_reference_image(path):
		current_project.reference_image_path = path
		mark_dirty()


func _on_clear_ref_pressed() -> void:
	if character_canvas:
		character_canvas.clear_reference_image()
		current_project.reference_image_path = ""
		mark_dirty()


func _on_opacity_changed(value: float) -> void:
	if character_canvas:
		character_canvas.reference_opacity = value / 100.0
		current_project.reference_opacity = value / 100.0


func _on_canvas_size_changed(value: float) -> void:
	if character_canvas:
		character_canvas.canvas_size = int(value)
		current_project.canvas_size = int(value)
		mark_dirty()
	_update_direction_manager()
	_update_status_bar()


# =============================================================================
# CANVAS SIGNALS
# =============================================================================

func _on_shape_added(index: int) -> void:
	mark_dirty()
	_sync_to_project()
	_update_layers()
	_update_status_bar()


func _on_shape_removed(index: int) -> void:
	mark_dirty()
	_sync_to_project()
	_update_layers()
	_update_status_bar()


func _on_shape_selected(indices: Array[int]) -> void:
	if layer_panel:
		layer_panel.select_layers(indices)

	if shape_properties_panel:
		if indices.is_empty():
			shape_properties_panel.clear()
		elif indices.size() == 1:
			var shape = character_canvas.shapes[indices[0]]
			shape_properties_panel.show_shape(shape)
		else:
			var shapes = []
			for idx in indices:
				shapes.append(character_canvas.shapes[idx])
			shape_properties_panel.show_multiple(shapes)

	# Update body part tagger with selected shapes
	if body_part_tagger:
		body_part_tagger.set_selected_shapes(indices)


func _on_shape_modified(index: int) -> void:
	mark_dirty()
	_sync_to_project()
	_update_layers()

	# Update properties panel
	if shape_properties_panel and index in character_canvas.selected_indices:
		shape_properties_panel.show_shape(character_canvas.shapes[index])


func _on_canvas_changed() -> void:
	mark_dirty()
	_sync_to_project()
	_update_layers()
	_update_status_bar()
	# Update current direction view with canvas changes
	if direction_manager and character_canvas and body_part_tagger:
		direction_manager.update_from_editor(
			character_canvas.shapes,
			body_part_tagger.save_to_project()
		)


func _on_zoom_changed(zoom: float) -> void:
	if zoom_percent_label:
		zoom_percent_label.text = "%d%%" % int(zoom * 100)


# =============================================================================
# TOOL PANEL SIGNALS
# =============================================================================

func _on_tool_changed(tool_id: int) -> void:
	if character_canvas:
		character_canvas.set_tool(tool_id)


func _on_color_changed(color: Color) -> void:
	if character_canvas:
		character_canvas.set_color(color)


# =============================================================================
# LAYER PANEL SIGNALS
# =============================================================================

func _on_layer_selected(index: int) -> void:
	if character_canvas:
		character_canvas.selected_indices = [index]
		character_canvas.shape_selected.emit(character_canvas.selected_indices)
		character_canvas.queue_redraw()


func _on_layer_order_changed() -> void:
	if character_canvas:
		# Get selected indices from layer panel
		var selected = layer_panel.get_selected_indices()
		if selected.is_empty():
			return

		# Move up or down based on which button was pressed
		# For now, move up
		character_canvas.move_layer_up()
		_update_layers()


func _on_delete_requested() -> void:
	if character_canvas:
		character_canvas.delete_selected()


# =============================================================================
# SHAPE PROPERTIES SIGNALS
# =============================================================================

func _on_property_changed(property: String, value: Variant) -> void:
	if not character_canvas or character_canvas.selected_indices.is_empty():
		return

	for index in character_canvas.selected_indices:
		if index >= 0 and index < character_canvas.shapes.size():
			var shape = character_canvas.shapes[index]
			match property:
				"position_x":
					shape.position[0] = value
				"position_y":
					shape.position[1] = value
				"width":
					shape.size[0] = value
				"height":
					shape.size[1] = value
				"rotation":
					shape.rotation = value
				"color":
					shape.color = [value.r, value.g, value.b, value.a]

	character_canvas.queue_redraw()
	mark_dirty()
	_sync_to_project()
	_update_layers()


# =============================================================================
# BODY PART TAGGER SIGNALS
# =============================================================================

func _on_body_parts_changed() -> void:
	mark_dirty()
	_sync_body_parts_to_project()
	_update_canvas_pivots()
	_update_status_bar()
	_update_animation_generator()  # Update body parts in animation generator


func _on_pivot_mode_changed(enabled: bool) -> void:
	if character_canvas:
		character_canvas.set_pivot_mode(enabled)


func _on_body_part_selected(part_name: String) -> void:
	if body_part_tagger and character_canvas:
		# Highlight the shapes belonging to the selected body part
		var shape_indices = body_part_tagger.get_shapes_for_part(part_name)
		character_canvas.highlight_body_part(part_name, shape_indices)


func _on_pivot_clicked(canvas_pos: Vector2) -> void:
	if body_part_tagger:
		body_part_tagger.set_pivot_from_canvas(canvas_pos)


func _sync_body_parts_to_project() -> void:
	if current_project and body_part_tagger:
		current_project.body_parts = body_part_tagger.save_to_project()


func _update_canvas_pivots() -> void:
	if character_canvas and body_part_tagger:
		character_canvas.load_pivot_points(body_part_tagger.body_parts)


# =============================================================================
# DIRECTION MANAGER SIGNALS
# =============================================================================

func _on_direction_changed(direction: DirectionView.Direction) -> void:
	# When direction changes, load that direction's data into the canvas
	if not direction_manager or not character_canvas:
		return

	var view := direction_manager.get_direction_view(direction)
	if view and view.is_configured:
		# Load direction-specific shapes
		character_canvas.shapes = view.shapes.duplicate(true)
		if not view.body_parts.is_empty():
			if body_part_tagger:
				body_part_tagger.load_from_project(view.body_parts)
		character_canvas.queue_redraw()
		_update_layers()
	else:
		# If direction not configured, show empty canvas (or keep current?)
		pass

	_update_status_bar()


func _on_direction_shapes_updated(direction: DirectionView.Direction, shapes: Array) -> void:
	# When a direction's shapes are updated (e.g., auto-generated)
	mark_dirty()

	# If this is the current direction, update the canvas
	if direction_manager and direction_manager.get_current_direction() == direction:
		if character_canvas:
			character_canvas.shapes = shapes.duplicate(true)
			character_canvas.queue_redraw()
			_update_layers()


func _on_direction_copy_request() -> void:
	# Copy current canvas shapes to the selected direction
	if not direction_manager or not character_canvas:
		return

	var current_shapes = character_canvas.shapes.duplicate(true)
	var current_body_parts = {}
	if body_part_tagger:
		current_body_parts = body_part_tagger.save_to_project()

	direction_manager.update_from_editor(current_shapes, current_body_parts)
	mark_dirty()


func _update_direction_manager() -> void:
	if direction_manager and character_canvas:
		direction_manager.set_canvas_size(character_canvas.canvas_size)


func _sync_direction_views_to_project() -> void:
	if current_project and direction_manager:
		current_project.direction_views = direction_manager.save_direction_views()


# =============================================================================
# POSE EDITOR SIGNALS
# =============================================================================

func _on_pose_changed(pose: Pose) -> void:
	mark_dirty()
	_sync_poses_to_project()
	_update_pose_preview()
	_update_animation_generator()  # Update available poses in animation generator


func _on_pose_selected(pose: Pose) -> void:
	_update_pose_preview()


func _on_pose_preview_requested() -> void:
	_update_pose_preview()


func _update_pose_preview() -> void:
	if not character_canvas or not pose_editor or not body_part_tagger:
		return

	var current_pose = pose_editor.get_current_pose()
	if current_pose:
		character_canvas.set_pose_preview(current_pose, body_part_tagger.body_parts)
	else:
		character_canvas.clear_pose_preview()


func _sync_poses_to_project() -> void:
	if current_project and pose_editor:
		current_project.poses = pose_editor.save_to_project()


# =============================================================================
# ANIMATION GENERATOR SIGNALS
# =============================================================================

func _on_animation_generated(animation: AnimationData) -> void:
	mark_dirty()
	_sync_animations_to_project()
	print("CharacterAssembler: Animation generated: %s" % animation.animation_name)


func _on_animation_selected(animation: AnimationData) -> void:
	# When an animation is selected, preview its first frame
	if animation and animation.is_generated and not animation.generated_frames.is_empty():
		_preview_animation_frame(animation, 0)


func _on_animation_preview_frame_changed(frame_index: int) -> void:
	# Update canvas to show the current frame of the previewed animation
	if animation_generator:
		var current_anim = animation_generator.get_selected_animation()
		if current_anim and current_anim.is_generated:
			_preview_animation_frame(current_anim, frame_index)


func _preview_animation_frame(animation: AnimationData, frame_index: int) -> void:
	if not character_canvas or not body_part_tagger:
		return

	if frame_index < 0 or frame_index >= animation.generated_frames.size():
		character_canvas.clear_pose_preview()
		return

	var frame_rotations = animation.generated_frames[frame_index]
	var temp_pose = Pose.new("preview_frame", frame_rotations)
	character_canvas.set_pose_preview(temp_pose, body_part_tagger.body_parts)


func _sync_animations_to_project() -> void:
	if current_project and animation_generator:
		current_project.animations = animation_generator.save_to_project()


func _update_animation_generator() -> void:
	if animation_generator:
		# Update character data for preview
		if character_canvas:
			animation_generator.set_character_data(
				character_canvas.shapes,
				body_part_tagger.body_parts if body_part_tagger else {},
				character_canvas.canvas_size
			)
		# Update available poses
		if pose_editor:
			animation_generator.set_available_poses(pose_editor.get_all_poses())


# =============================================================================
# EXPORT MANAGER SIGNALS
# =============================================================================

func _on_export_requested(options: ExportManager.ExportOptions) -> void:
	if not current_project:
		if export_manager:
			export_manager.set_status("No project to export", true)
		return

	# Collect all necessary data
	var shapes: Array = []
	var body_parts: Dictionary = {}
	var animations: Array[AnimationData] = []
	var direction_views: Dictionary = {}
	var body_parts_per_direction: Dictionary = {}
	var canvas_size: int = current_project.canvas_size

	# Get current shapes and body parts
	if character_canvas:
		shapes = character_canvas.shapes.duplicate(true)

	if body_part_tagger:
		body_parts = body_part_tagger.save_to_project()

	# Get animations
	if animation_generator:
		animations = animation_generator.get_all_animations()

	# Get direction views if exporting all directions
	if options.export_all_directions and direction_manager:
		for dir_key in DirectionView.Direction.keys():
			var dir_enum: DirectionView.Direction = DirectionView.Direction[dir_key]
			var view := direction_manager.get_direction_view(dir_enum)
			if view and view.is_configured:
				direction_views[dir_key.to_lower()] = view
				body_parts_per_direction[dir_key.to_lower()] = view.body_parts

	# Validate we have something to export
	if animations.is_empty():
		if export_manager:
			export_manager.set_status("No animations to export", true)
		return

	var has_generated := false
	for anim in animations:
		if anim.is_generated:
			has_generated = true
			break

	if not has_generated:
		if export_manager:
			export_manager.set_status("No generated animations to export", true)
		return

	# Create and show export dialog
	var dialog := ExportDialog.new()
	dialog.export_finished.connect(_on_export_finished)
	add_child(dialog)
	dialog.popup_centered()

	# Execute the export
	dialog.execute_export(
		options,
		shapes,
		body_parts,
		animations,
		canvas_size,
		direction_views,
		body_parts_per_direction
	)


func _on_export_finished(success: bool, results: Dictionary) -> void:
	if export_manager:
		if success:
			var message := "Export complete"
			if results.has("frames_exported") and results.frames_exported > 0:
				message += " (%d frames)" % results.frames_exported
			export_manager.set_status(message)
		else:
			export_manager.set_status("Export failed", true)


func _update_export_manager() -> void:
	if export_manager and current_project:
		export_manager.set_character_name(current_project.character_id)
		if not current_file_path.is_empty():
			var export_dir := current_file_path.get_base_dir().path_join("exports")
			export_manager.set_output_directory(export_dir)


# =============================================================================
# FILE OPERATIONS
# =============================================================================

func _on_open_file_selected(path: String) -> void:
	_load_from_file(path)


func _on_save_file_selected(path: String) -> void:
	if not path.ends_with(".charproj"):
		path += ".charproj"
	_save_to_file(path)

	if _pending_action == "save_then_new":
		_pending_action = ""
		_do_new()
	elif _pending_action == "save_then_open":
		_pending_action = ""
		_do_open()


func _save_to_file(path: String) -> void:
	if not current_project:
		push_error("CharacterAssembler: No project to save")
		return

	_sync_to_project()

	if current_project.character_id.is_empty():
		current_project.character_id = path.get_file().get_basename()

	var err = current_project.save_to_file(path)
	if err == OK:
		current_file_path = path
		is_dirty = false
		_update_status_bar()
		print("CharacterAssembler: Saved to %s" % path)
	else:
		push_error("CharacterAssembler: Failed to save: %s (error: %d)" % [path, err])


func _load_from_file(path: String) -> void:
	var project = CharacterProjectScript.load_from_file(path)
	if project == null:
		push_error("CharacterAssembler: Failed to load: %s" % path)
		return

	current_project = project
	current_file_path = path
	is_dirty = false

	if character_canvas:
		character_canvas.load_from_project(current_project)

	if canvas_size_spin:
		canvas_size_spin.value = current_project.canvas_size

	if opacity_slider:
		opacity_slider.value = current_project.reference_opacity * 100

	# Load body parts into tagger
	if body_part_tagger:
		body_part_tagger.load_from_project(current_project.body_parts)

	# Load poses into editor
	if pose_editor:
		pose_editor.load_from_project(current_project.poses)

	# Load animations into generator
	if animation_generator:
		animation_generator.load_from_project(current_project.animations)
		_update_animation_generator()

	# Load direction views
	if direction_manager:
		direction_manager.load_direction_views(current_project.direction_views)
		_update_direction_manager()

	# Update canvas with pivot points
	_update_canvas_pivots()

	_update_export_manager()
	_update_layers()
	_update_status_bar()
	print("CharacterAssembler: Loaded from %s" % path)


func _sync_to_project() -> void:
	if current_project and character_canvas:
		character_canvas.save_to_project(current_project)
	_sync_body_parts_to_project()
	_sync_poses_to_project()
	_sync_animations_to_project()
	_sync_direction_views_to_project()
	# Also sync primary direction with main shapes
	if current_project:
		current_project.sync_primary_direction()


# =============================================================================
# CONFIRMATION DIALOG
# =============================================================================

func _on_confirm_save() -> void:
	_confirm_dialog.hide()
	if current_file_path.is_empty():
		if _pending_action == "new":
			_pending_action = "save_then_new"
		elif _pending_action == "open":
			_pending_action = "save_then_open"
		call_deferred("_on_save_as_pressed")
	else:
		_save_to_file(current_file_path)
		call_deferred("_continue_pending_action")


func _on_confirm_custom_action(action: StringName) -> void:
	if action == "dont_save":
		is_dirty = false
		_confirm_dialog.hide()
		call_deferred("_continue_pending_action")


func _on_confirm_canceled() -> void:
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
# UI UPDATES
# =============================================================================

func _update_layers() -> void:
	if layer_panel and character_canvas:
		layer_panel.update_layers(character_canvas.shapes, character_canvas.selected_indices)


func _update_status_bar() -> void:
	if project_name_label and current_project:
		var name_text = current_project.character_id if not current_project.character_id.is_empty() else "(untitled)"
		var dirty_marker = "*" if is_dirty else ""
		project_name_label.text = "Project: %s%s" % [name_text, dirty_marker]

	if status_label and current_project:
		var shape_count = character_canvas.get_shape_count() if character_canvas else 0
		var body_parts_count = 0
		if body_part_tagger:
			body_parts_count = RigValidator.get_configured_count(body_part_tagger.body_parts)
		status_label.text = "Canvas: %dx%d | Shapes: %d | Body Parts: %d/14" % [
			current_project.canvas_size,
			current_project.canvas_size,
			shape_count,
			body_parts_count
		]

	# Also update validation in tagger
	if body_part_tagger and character_canvas:
		body_part_tagger.update_validation(character_canvas.get_shape_count())


# =============================================================================
# PUBLIC API
# =============================================================================

func mark_dirty() -> void:
	is_dirty = true
	_update_status_bar()


func has_unsaved_changes() -> bool:
	return is_dirty


func get_project() -> RefCounted:
	return current_project


func get_current_file_path() -> String:
	return current_file_path
