@tool
extends VBoxContainer
class_name PoseEditor
## Pose editor panel for the Character Assembler.
## Allows creating, editing, and managing character poses.

signal pose_changed(pose: Pose)
signal pose_selected(pose: Pose)
signal preview_requested()

# UI References
var _header: Label
var _pose_dropdown: OptionButton
var _new_btn: Button
var _duplicate_btn: Button
var _delete_btn: Button
var _rotations_header: Label
var _rotations_container: VBoxContainer
var _reset_all_btn: Button
var _mirror_btn: Button
var _quick_poses_container: HBoxContainer
var _quick_poses_label: Label

# State
var poses: Array[Pose] = []
var current_pose: Pose = null
var body_parts: Dictionary = {}
var _rotation_sliders: Dictionary = {}  # part_name -> RotationSlider
var _updating: bool = false


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_create_default_poses()
	_update_ui_state()


func _setup_ui() -> void:
	# Header
	_header = Label.new()
	_header.text = "POSE EDITOR"
	_header.add_theme_font_size_override("font_size", 32)
	add_child(_header)

	add_child(HSeparator.new())

	# Pose selection row
	var pose_row := HBoxContainer.new()
	pose_row.add_theme_constant_override("separation", 8)
	add_child(pose_row)

	var pose_label := Label.new()
	pose_label.text = "Pose:"
	pose_label.add_theme_font_size_override("font_size", 28)
	pose_row.add_child(pose_label)

	_pose_dropdown = OptionButton.new()
	_pose_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pose_dropdown.add_theme_font_size_override("font_size", 28)
	pose_row.add_child(_pose_dropdown)

	# Buttons row
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	add_child(btn_row)

	_new_btn = Button.new()
	_new_btn.text = "+ New"
	_new_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_new_btn)

	_duplicate_btn = Button.new()
	_duplicate_btn.text = "Duplicate"
	_duplicate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_duplicate_btn)

	_delete_btn = Button.new()
	_delete_btn.text = "Delete"
	_delete_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_delete_btn)

	add_child(HSeparator.new())

	# Rotations header
	_rotations_header = Label.new()
	_rotations_header.text = "ROTATIONS:"
	_rotations_header.add_theme_font_size_override("font_size", 30)
	add_child(_rotations_header)

	# Rotations container (scrollable)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 400)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_rotations_container = VBoxContainer.new()
	_rotations_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rotations_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_rotations_container)

	# Create rotation sliders for all body parts
	_create_rotation_sliders()

	add_child(HSeparator.new())

	# Action buttons row
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	add_child(action_row)

	_reset_all_btn = Button.new()
	_reset_all_btn.text = "Reset All"
	_reset_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(_reset_all_btn)

	_mirror_btn = Button.new()
	_mirror_btn.text = "Mirror L↔R"
	_mirror_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(_mirror_btn)

	add_child(HSeparator.new())

	# Quick poses section
	_quick_poses_label = Label.new()
	_quick_poses_label.text = "QUICK SELECT:"
	_quick_poses_label.add_theme_font_size_override("font_size", 28)
	add_child(_quick_poses_label)

	_quick_poses_container = HBoxContainer.new()
	_quick_poses_container.add_theme_constant_override("separation", 4)
	add_child(_quick_poses_container)


func _create_rotation_sliders() -> void:
	for part_name in BodyPart.PART_NAMES:
		var slider := RotationSlider.new(part_name)
		_rotations_container.add_child(slider)
		_rotation_sliders[part_name] = slider
		slider.value_changed.connect(_on_rotation_changed)
		slider.reset_requested.connect(_on_part_reset)


func _connect_signals() -> void:
	_pose_dropdown.item_selected.connect(_on_pose_selected)
	_new_btn.pressed.connect(_on_new_pressed)
	_duplicate_btn.pressed.connect(_on_duplicate_pressed)
	_delete_btn.pressed.connect(_on_delete_pressed)
	_reset_all_btn.pressed.connect(_on_reset_all_pressed)
	_mirror_btn.pressed.connect(_on_mirror_pressed)


func _create_default_poses() -> void:
	# Create default poses
	var default_poses_data := [
		{"name": "Idle", "rotations": {}},
		{"name": "Walk_L", "rotations": {
			"L Upper Arm": -15.0, "L Lower Arm": 5.0,
			"R Upper Arm": 15.0, "R Lower Arm": -5.0,
			"L Upper Leg": 20.0, "L Lower Leg": -10.0,
			"R Upper Leg": -15.0, "R Lower Leg": 5.0
		}},
		{"name": "Walk_R", "rotations": {
			"L Upper Arm": 15.0, "L Lower Arm": -5.0,
			"R Upper Arm": -15.0, "R Lower Arm": 5.0,
			"L Upper Leg": -15.0, "L Lower Leg": 5.0,
			"R Upper Leg": 20.0, "R Lower Leg": -10.0
		}},
		{"name": "Attack_Windup", "rotations": {
			"Torso": -10.0,
			"R Upper Arm": -90.0, "R Lower Arm": -45.0,
			"L Upper Arm": 15.0
		}},
		{"name": "Attack_Swing", "rotations": {
			"Torso": 15.0,
			"R Upper Arm": 45.0, "R Lower Arm": 15.0,
			"L Upper Arm": -10.0
		}},
		{"name": "Hurt", "rotations": {
			"Torso": -15.0,
			"Head": 20.0,
			"L Upper Arm": 30.0, "R Upper Arm": 30.0
		}},
		{"name": "Death", "rotations": {
			"Torso": 90.0,
			"Head": 45.0,
			"L Upper Arm": 60.0, "L Lower Arm": 30.0,
			"R Upper Arm": 45.0, "R Lower Arm": 20.0,
			"L Upper Leg": 30.0, "R Upper Leg": 15.0
		}}
	]

	for data in default_poses_data:
		var pose := Pose.new(data.name, data.rotations)
		poses.append(pose)

	_update_pose_dropdown()
	_update_quick_poses()

	# Select first pose
	if not poses.is_empty():
		_select_pose(0)


func _update_pose_dropdown() -> void:
	_pose_dropdown.clear()
	for pose in poses:
		_pose_dropdown.add_item(pose.pose_name)


func _update_quick_poses() -> void:
	# Clear existing buttons
	for child in _quick_poses_container.get_children():
		child.queue_free()

	# Create quick select buttons for each pose
	for i in range(poses.size()):
		var pose := poses[i]
		var btn := Button.new()
		btn.text = pose.pose_name
		btn.pressed.connect(_on_quick_pose_selected.bind(i))
		_quick_poses_container.add_child(btn)


func _select_pose(index: int) -> void:
	if index < 0 or index >= poses.size():
		return

	_updating = true
	current_pose = poses[index]
	_pose_dropdown.selected = index

	# Update all sliders
	for part_name in _rotation_sliders:
		var slider: RotationSlider = _rotation_sliders[part_name]
		slider.set_value(current_pose.get_rotation(part_name))

	_updating = false
	pose_selected.emit(current_pose)
	preview_requested.emit()


func _on_pose_selected(index: int) -> void:
	if _updating:
		return
	_select_pose(index)


func _on_new_pressed() -> void:
	# Create a new pose with a unique name
	var base_name := "New_Pose"
	var counter := 1
	var name := base_name

	while _pose_name_exists(name):
		counter += 1
		name = "%s_%d" % [base_name, counter]

	var new_pose := Pose.new(name)
	poses.append(new_pose)
	_update_pose_dropdown()
	_update_quick_poses()
	_select_pose(poses.size() - 1)


func _on_duplicate_pressed() -> void:
	if current_pose == null:
		return

	var new_name := current_pose.pose_name + "_copy"
	var counter := 1
	while _pose_name_exists(new_name):
		counter += 1
		new_name = "%s_copy%d" % [current_pose.pose_name, counter]

	var new_pose := current_pose.duplicate_pose(new_name)
	poses.append(new_pose)
	_update_pose_dropdown()
	_update_quick_poses()
	_select_pose(poses.size() - 1)


func _on_delete_pressed() -> void:
	if current_pose == null or poses.size() <= 1:
		return

	var index := poses.find(current_pose)
	if index >= 0:
		poses.remove_at(index)
		_update_pose_dropdown()
		_update_quick_poses()
		_select_pose(max(0, index - 1))


func _on_reset_all_pressed() -> void:
	if current_pose == null:
		return

	current_pose.reset_all()
	_select_pose(poses.find(current_pose))
	pose_changed.emit(current_pose)


func _on_mirror_pressed() -> void:
	if current_pose == null:
		return

	current_pose.mirror()
	_select_pose(poses.find(current_pose))
	pose_changed.emit(current_pose)


func _on_rotation_changed(part_name: String, degrees: float) -> void:
	if _updating or current_pose == null:
		return

	current_pose.set_rotation(part_name, degrees)
	pose_changed.emit(current_pose)
	preview_requested.emit()


func _on_part_reset(part_name: String) -> void:
	if current_pose == null:
		return

	current_pose.reset_part(part_name)
	pose_changed.emit(current_pose)
	preview_requested.emit()


func _on_quick_pose_selected(index: int) -> void:
	_select_pose(index)


func _pose_name_exists(name: String) -> bool:
	for pose in poses:
		if pose.pose_name == name:
			return true
	return false


func _update_ui_state() -> void:
	var has_pose := current_pose != null
	var has_multiple := poses.size() > 1

	_duplicate_btn.disabled = not has_pose
	_delete_btn.disabled = not has_pose or not has_multiple
	_reset_all_btn.disabled = not has_pose
	_mirror_btn.disabled = not has_pose

	for slider in _rotation_sliders.values():
		slider.set_slider_enabled(has_pose)


# =============================================================================
# PUBLIC API
# =============================================================================

## Set body parts reference for validation.
func set_body_parts(parts: Dictionary) -> void:
	body_parts = parts


## Get the current pose.
func get_current_pose() -> Pose:
	return current_pose


## Get all poses.
func get_poses() -> Array[Pose]:
	return poses


## Load poses from project data.
func load_from_project(poses_data: Array) -> void:
	poses.clear()

	for data in poses_data:
		if data is Dictionary:
			poses.append(Pose.from_dict(data))

	# If no poses loaded, create defaults
	if poses.is_empty():
		_create_default_poses()
	else:
		_update_pose_dropdown()
		_update_quick_poses()
		if not poses.is_empty():
			_select_pose(0)


## Save poses to project data.
func save_to_project() -> Array:
	var result := []
	for pose in poses:
		result.append(pose.to_dict())
	return result


## Highlight a body part slider.
func highlight_part(part_name: String) -> void:
	for name in _rotation_sliders:
		var slider: RotationSlider = _rotation_sliders[name]
		slider.set_highlighted(name == part_name)


## Clear all highlights.
func clear_highlights() -> void:
	for slider in _rotation_sliders.values():
		slider.set_highlighted(false)


## Refresh the display.
func refresh() -> void:
	_update_ui_state()
	if current_pose:
		_select_pose(poses.find(current_pose))
