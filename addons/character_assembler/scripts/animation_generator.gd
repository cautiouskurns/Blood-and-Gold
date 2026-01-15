@tool
extends VBoxContainer
class_name AnimationGenerator
## Animation generator panel for creating animations from templates.
## Allows selecting templates, assigning poses, and generating animation frames.

signal animation_generated(animation: AnimationData)
signal animation_selected(animation: AnimationData)
signal preview_frame_changed(frame_index: int)

# Available templates
var templates: Array[AnimationTemplate] = []
var current_template: AnimationTemplate = null

# Available poses from pose editor
var available_poses: Dictionary = {}  # pose_name -> Pose

# Character data for preview
var shapes: Array = []
var body_parts: Dictionary = {}
var canvas_size: int = 64

# Generated animations
var animations: Dictionary = {}  # animation_name -> AnimationData
var current_animation: AnimationData = null

# UI References
var _header: Label
var _template_dropdown: OptionButton
var _required_poses_container: VBoxContainer
var _pose_assignment_rows: Dictionary = {}  # slot_name -> {dropdown: OptionButton, status: Label}

var _settings_container: HBoxContainer
var _frame_count_spin: SpinBox
var _fps_dropdown: OptionButton
var _loop_check: CheckBox

var _preview: AnimationPreview
var _playback_container: HBoxContainer
var _play_btn: Button
var _stop_btn: Button
var _prev_frame_btn: Button
var _next_frame_btn: Button
var _frame_slider: HSlider
var _frame_label: Label

var _generate_btn: Button
var _animation_name_edit: LineEdit

var _animations_list: ItemList
var _generate_all_btn: Button
var _delete_anim_btn: Button

var _updating: bool = false


func _ready() -> void:
	_load_templates()
	_setup_ui()
	_connect_signals()
	_update_ui_state()


func _load_templates() -> void:
	templates = AnimationTemplate.get_all_builtin_templates()


func _setup_ui() -> void:
	# Header
	_header = Label.new()
	_header.text = "ANIMATION GENERATOR"
	_header.add_theme_font_size_override("font_size", 32)
	add_child(_header)

	add_child(HSeparator.new())

	# Template selection
	var template_row := HBoxContainer.new()
	template_row.add_theme_constant_override("separation", 8)
	add_child(template_row)

	var template_label := Label.new()
	template_label.text = "Template:"
	template_label.add_theme_font_size_override("font_size", 28)
	template_row.add_child(template_label)

	_template_dropdown = OptionButton.new()
	_template_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_template_dropdown.add_theme_font_size_override("font_size", 28)
	template_row.add_child(_template_dropdown)

	# Populate template dropdown
	for template in templates:
		_template_dropdown.add_item(template.template_name)

	add_child(HSeparator.new())

	# Required poses section
	var poses_label := Label.new()
	poses_label.text = "REQUIRED POSES:"
	poses_label.add_theme_font_size_override("font_size", 28)
	add_child(poses_label)

	_required_poses_container = VBoxContainer.new()
	_required_poses_container.add_theme_constant_override("separation", 4)
	add_child(_required_poses_container)

	add_child(HSeparator.new())

	# Settings section
	var settings_label := Label.new()
	settings_label.text = "SETTINGS:"
	settings_label.add_theme_font_size_override("font_size", 28)
	add_child(settings_label)

	_settings_container = HBoxContainer.new()
	_settings_container.add_theme_constant_override("separation", 16)
	add_child(_settings_container)

	# Frame count
	var frame_label := Label.new()
	frame_label.text = "Frames:"
	frame_label.add_theme_font_size_override("font_size", 24)
	_settings_container.add_child(frame_label)

	_frame_count_spin = SpinBox.new()
	_frame_count_spin.min_value = 2
	_frame_count_spin.max_value = 32
	_frame_count_spin.value = 8
	_settings_container.add_child(_frame_count_spin)

	# FPS
	var fps_label := Label.new()
	fps_label.text = "FPS:"
	fps_label.add_theme_font_size_override("font_size", 24)
	_settings_container.add_child(fps_label)

	_fps_dropdown = OptionButton.new()
	_fps_dropdown.add_item("6", 6)
	_fps_dropdown.add_item("8", 8)
	_fps_dropdown.add_item("10", 10)
	_fps_dropdown.add_item("12", 12)
	_fps_dropdown.add_item("15", 15)
	_fps_dropdown.add_item("24", 24)
	_fps_dropdown.select(3)  # Default to 12 FPS
	_settings_container.add_child(_fps_dropdown)

	# Loop
	_loop_check = CheckBox.new()
	_loop_check.text = "Loop"
	_loop_check.button_pressed = true
	_loop_check.add_theme_font_size_override("font_size", 24)
	_settings_container.add_child(_loop_check)

	add_child(HSeparator.new())

	# Animation name
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)
	add_child(name_row)

	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.add_theme_font_size_override("font_size", 24)
	name_row.add_child(name_label)

	_animation_name_edit = LineEdit.new()
	_animation_name_edit.placeholder_text = "animation_name"
	_animation_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(_animation_name_edit)

	# Generate button
	_generate_btn = Button.new()
	_generate_btn.text = "Generate Animation"
	_generate_btn.add_theme_font_size_override("font_size", 28)
	add_child(_generate_btn)

	add_child(HSeparator.new())

	# Preview section
	var preview_label := Label.new()
	preview_label.text = "PREVIEW:"
	preview_label.add_theme_font_size_override("font_size", 28)
	add_child(preview_label)

	_preview = AnimationPreview.new()
	_preview.custom_minimum_size = Vector2(200, 200)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_preview)

	# Playback controls
	_playback_container = HBoxContainer.new()
	_playback_container.add_theme_constant_override("separation", 8)
	add_child(_playback_container)

	_prev_frame_btn = Button.new()
	_prev_frame_btn.text = "◀"
	_prev_frame_btn.tooltip_text = "Previous frame"
	_playback_container.add_child(_prev_frame_btn)

	_play_btn = Button.new()
	_play_btn.text = "▶ Play"
	_play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_playback_container.add_child(_play_btn)

	_stop_btn = Button.new()
	_stop_btn.text = "■ Stop"
	_playback_container.add_child(_stop_btn)

	_next_frame_btn = Button.new()
	_next_frame_btn.text = "▶"
	_next_frame_btn.tooltip_text = "Next frame"
	_playback_container.add_child(_next_frame_btn)

	# Frame slider
	var slider_row := HBoxContainer.new()
	slider_row.add_theme_constant_override("separation", 8)
	add_child(slider_row)

	_frame_slider = HSlider.new()
	_frame_slider.min_value = 0
	_frame_slider.max_value = 7
	_frame_slider.step = 1
	_frame_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_row.add_child(_frame_slider)

	_frame_label = Label.new()
	_frame_label.text = "1/8"
	_frame_label.custom_minimum_size = Vector2(60, 0)
	_frame_label.add_theme_font_size_override("font_size", 24)
	slider_row.add_child(_frame_label)

	add_child(HSeparator.new())

	# Generated animations list
	var list_label := Label.new()
	list_label.text = "GENERATED ANIMATIONS:"
	list_label.add_theme_font_size_override("font_size", 28)
	add_child(list_label)

	_animations_list = ItemList.new()
	_animations_list.custom_minimum_size = Vector2(0, 120)
	_animations_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_animations_list)

	# List buttons
	var list_btns := HBoxContainer.new()
	list_btns.add_theme_constant_override("separation", 8)
	add_child(list_btns)

	_generate_all_btn = Button.new()
	_generate_all_btn.text = "Generate All"
	_generate_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_btns.add_child(_generate_all_btn)

	_delete_anim_btn = Button.new()
	_delete_anim_btn.text = "Delete"
	list_btns.add_child(_delete_anim_btn)


func _connect_signals() -> void:
	_template_dropdown.item_selected.connect(_on_template_selected)
	_generate_btn.pressed.connect(_on_generate_pressed)

	_play_btn.pressed.connect(_on_play_pressed)
	_stop_btn.pressed.connect(_on_stop_pressed)
	_prev_frame_btn.pressed.connect(_on_prev_frame_pressed)
	_next_frame_btn.pressed.connect(_on_next_frame_pressed)
	_frame_slider.value_changed.connect(_on_frame_slider_changed)

	_preview.frame_changed.connect(_on_preview_frame_changed)

	_animations_list.item_selected.connect(_on_animation_list_selected)
	_generate_all_btn.pressed.connect(_on_generate_all_pressed)
	_delete_anim_btn.pressed.connect(_on_delete_animation_pressed)

	_frame_count_spin.value_changed.connect(_on_settings_changed)
	_fps_dropdown.item_selected.connect(_on_settings_changed)
	_loop_check.toggled.connect(_on_settings_changed)


func _on_template_selected(index: int) -> void:
	if index < 0 or index >= templates.size():
		return

	current_template = templates[index]
	_update_required_poses_ui()
	_update_settings_from_template()
	_update_animation_name()
	_update_ui_state()


func _update_required_poses_ui() -> void:
	if _required_poses_container == null:
		return
	# Clear existing rows
	for child in _required_poses_container.get_children():
		child.queue_free()
	_pose_assignment_rows.clear()

	if current_template == null:
		return

	# Create row for each required pose
	for slot_name in current_template.required_poses:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_required_poses_container.add_child(row)

		# Slot label
		var label := Label.new()
		label.text = slot_name + ":"
		label.custom_minimum_size = Vector2(120, 0)
		label.add_theme_font_size_override("font_size", 24)
		row.add_child(label)

		# Pose dropdown
		var dropdown := OptionButton.new()
		dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dropdown.add_theme_font_size_override("font_size", 24)
		dropdown.add_item("(none)")
		row.add_child(dropdown)

		# Populate with available poses
		for pose_name in available_poses:
			dropdown.add_item(pose_name)

		# Try to auto-assign matching pose
		_try_auto_assign(dropdown, slot_name)

		# Connect signal
		dropdown.item_selected.connect(_on_pose_assignment_changed.bind(slot_name))

		# Status indicator
		var status := Label.new()
		status.text = "✓" if dropdown.selected > 0 else "✗"
		status.add_theme_font_size_override("font_size", 24)
		status.add_theme_color_override("font_color", Color.GREEN if dropdown.selected > 0 else Color.RED)
		row.add_child(status)

		_pose_assignment_rows[slot_name] = {
			"dropdown": dropdown,
			"status": status
		}


func _try_auto_assign(dropdown: OptionButton, slot_name: String) -> void:
	# Try to find a matching pose by name
	var slot_lower := slot_name.to_lower()

	for i in range(1, dropdown.item_count):
		var pose_name: String = dropdown.get_item_text(i)
		var pose_lower := pose_name.to_lower()

		# Check for exact or partial match
		if pose_lower == slot_lower or slot_lower in pose_lower or pose_lower in slot_lower:
			dropdown.select(i)
			return

	# Check for common aliases
	var aliases := {
		"idle": ["idle", "stand", "neutral"],
		"walk_left": ["walk_l", "walk_left", "walkleft"],
		"walk_right": ["walk_r", "walk_right", "walkright"],
		"run_left": ["run_l", "run_left", "runleft", "walk_l", "walk_left"],
		"run_right": ["run_r", "run_right", "runright", "walk_r", "walk_right"],
		"attack_windup": ["attack_windup", "windup", "wind_up", "sword_ready", "attack_ready"],
		"attack_swing": ["attack_swing", "swing", "attack", "sword_swing"],
		"hurt": ["hurt", "damage", "hit", "pain"],
		"death": ["death", "dead", "die", "collapse"],
		"breathe_in": ["breathe", "idle"],
		"victory": ["victory", "win", "celebrate"],
		"crouch": ["crouch", "duck", "squat"],
		"jump_up": ["jump", "jump_up", "leap"],
		"jump_down": ["fall", "jump_down", "land"],
	}

	if slot_lower in aliases:
		for alias in aliases[slot_lower]:
			for i in range(1, dropdown.item_count):
				var pose_name: String = dropdown.get_item_text(i)
				if pose_name.to_lower() == alias:
					dropdown.select(i)
					return


func _update_settings_from_template() -> void:
	if current_template == null:
		return

	_frame_count_spin.value = current_template.default_frame_count
	_loop_check.button_pressed = current_template.loop

	# Find and select matching FPS
	var target_fps := current_template.default_fps
	for i in range(_fps_dropdown.item_count):
		if _fps_dropdown.get_item_id(i) == target_fps:
			_fps_dropdown.select(i)
			break


func _update_animation_name() -> void:
	if current_template == null:
		return

	var base_name := current_template.template_name.to_lower().replace(" ", "_")
	_animation_name_edit.text = base_name


func _on_pose_assignment_changed(index: int, slot_name: String) -> void:
	if slot_name in _pose_assignment_rows:
		var row = _pose_assignment_rows[slot_name]
		var assigned := index > 0
		row.status.text = "✓" if assigned else "✗"
		row.status.add_theme_color_override("font_color", Color.GREEN if assigned else Color.RED)

	_update_ui_state()


func _on_settings_changed(_value = null) -> void:
	_update_ui_state()


func _on_generate_pressed() -> void:
	if current_template == null:
		return

	# Gather pose assignments
	var pose_assignments: Dictionary = {}
	for slot_name in _pose_assignment_rows:
		var dropdown: OptionButton = _pose_assignment_rows[slot_name].dropdown
		if dropdown.selected > 0:
			pose_assignments[slot_name] = dropdown.get_item_text(dropdown.selected)

	# Check all required poses are assigned
	if not current_template.validate_assignments(pose_assignments):
		push_warning("AnimationGenerator: Not all required poses are assigned")
		return

	# Create animation
	var anim_name := _animation_name_edit.text.strip_edges()
	if anim_name.is_empty():
		anim_name = current_template.template_name.to_lower().replace(" ", "_")

	var animation := AnimationData.new(anim_name, current_template.template_name)
	animation.frame_count = int(_frame_count_spin.value)
	animation.fps = _fps_dropdown.get_item_id(_fps_dropdown.selected)
	animation.loop = _loop_check.button_pressed
	animation.pose_assignments = pose_assignments

	# Generate frames
	var frames := PoseInterpolator.generate_animation_frames(
		current_template,
		pose_assignments,
		available_poses
	)

	animation.set_generated_frames(frames)

	# Store animation
	animations[anim_name] = animation
	current_animation = animation

	# Update preview
	_preview.set_animation_frames(frames, animation.fps, animation.loop)
	_frame_slider.max_value = max(0, frames.size() - 1)
	_update_frame_label()

	# Update list
	_update_animations_list()

	animation_generated.emit(animation)
	print("AnimationGenerator: Generated '%s' with %d frames" % [anim_name, frames.size()])


func _on_play_pressed() -> void:
	if _preview.is_animation_playing():
		_preview.pause()
		_play_btn.text = "▶ Play"
	else:
		_preview.play()
		_play_btn.text = "⏸ Pause"


func _on_stop_pressed() -> void:
	_preview.stop()
	_play_btn.text = "▶ Play"
	_frame_slider.value = 0
	_update_frame_label()


func _on_prev_frame_pressed() -> void:
	_preview.prev_frame()
	_frame_slider.value = _preview.get_current_frame()


func _on_next_frame_pressed() -> void:
	_preview.next_frame()
	_frame_slider.value = _preview.get_current_frame()


func _on_frame_slider_changed(value: float) -> void:
	if _updating:
		return
	_preview.go_to_frame(int(value))
	_update_frame_label()


func _on_preview_frame_changed(frame_index: int) -> void:
	_updating = true
	_frame_slider.value = frame_index
	_updating = false
	_update_frame_label()
	preview_frame_changed.emit(frame_index)


func _update_frame_label() -> void:
	var current := _preview.get_current_frame() + 1
	var total := _preview.get_frame_count()
	_frame_label.text = "%d/%d" % [current, max(1, total)]


func _on_animation_list_selected(index: int) -> void:
	var anim_name := _animations_list.get_item_text(index)
	if anim_name in animations:
		current_animation = animations[anim_name]

		# Load into preview
		_preview.set_animation_frames(
			current_animation.generated_frames,
			current_animation.fps,
			current_animation.loop
		)
		_frame_slider.max_value = max(0, current_animation.generated_frames.size() - 1)
		_update_frame_label()

		animation_selected.emit(current_animation)


func _on_generate_all_pressed() -> void:
	# Generate animations for all templates with auto-assigned poses
	for template in templates:
		_template_dropdown.select(templates.find(template))
		_on_template_selected(templates.find(template))

		# Check if we can generate (all poses assigned)
		var can_generate := true
		for slot_name in _pose_assignment_rows:
			var dropdown: OptionButton = _pose_assignment_rows[slot_name].dropdown
			if dropdown.selected <= 0:
				can_generate = false
				break

		if can_generate:
			_on_generate_pressed()


func _on_delete_animation_pressed() -> void:
	var selected := _animations_list.get_selected_items()
	if selected.is_empty():
		return

	var anim_name := _animations_list.get_item_text(selected[0])
	animations.erase(anim_name)

	if current_animation and current_animation.animation_name == anim_name:
		current_animation = null
		_preview.clear_animation()

	_update_animations_list()


func _update_animations_list() -> void:
	if _animations_list == null:
		return
	_animations_list.clear()

	for anim_name in animations:
		var anim: AnimationData = animations[anim_name]
		var status := "✓" if anim.is_generated else "○"
		var text := "%s %s (%d frames, %d FPS)" % [status, anim_name, anim.frame_count, anim.fps]
		_animations_list.add_item(text)


func _update_ui_state() -> void:
	# Ensure UI is initialized
	if _generate_btn == null:
		return

	var has_template := current_template != null
	var all_assigned := true

	if has_template:
		for slot_name in _pose_assignment_rows:
			var dropdown: OptionButton = _pose_assignment_rows[slot_name].dropdown
			if dropdown.selected <= 0:
				all_assigned = false
				break

	_generate_btn.disabled = not has_template or not all_assigned
	if _delete_anim_btn and _animations_list:
		_delete_anim_btn.disabled = _animations_list.get_selected_items().is_empty()

	var has_preview := _preview.get_frame_count() > 0 if _preview else false
	if _play_btn:
		_play_btn.disabled = not has_preview
	if _stop_btn:
		_stop_btn.disabled = not has_preview
	if _prev_frame_btn:
		_prev_frame_btn.disabled = not has_preview
	if _next_frame_btn:
		_next_frame_btn.disabled = not has_preview
	if _frame_slider:
		_frame_slider.editable = has_preview


# =============================================================================
# PUBLIC API
# =============================================================================

## Set available poses from pose editor.
## Accepts either Array[Pose] or Dictionary.
func set_available_poses(poses) -> void:
	if poses is Array:
		# Convert Array[Pose] to Dictionary
		available_poses.clear()
		for pose in poses:
			if pose is Pose:
				available_poses[pose.pose_name] = pose
	elif poses is Dictionary:
		available_poses = poses
	_update_required_poses_ui()


## Set character data for preview.
func set_character_data(p_shapes: Array, p_body_parts: Dictionary, p_canvas_size: int) -> void:
	shapes = p_shapes
	body_parts = p_body_parts
	canvas_size = p_canvas_size
	if _preview:
		_preview.set_character_data(p_shapes, p_body_parts, p_canvas_size)


## Load animations from project data.
func load_from_project(animations_data: Dictionary) -> void:
	animations.clear()
	for anim_name in animations_data:
		var data = animations_data[anim_name]
		if data is Dictionary:
			animations[anim_name] = AnimationData.from_dict(data)
	_update_animations_list()


## Save animations to project data.
func save_to_project() -> Dictionary:
	var result: Dictionary = {}
	for anim_name in animations:
		result[anim_name] = animations[anim_name].to_dict()
	return result


## Get all generated animations.
func get_animations() -> Dictionary:
	return animations


## Get the currently selected animation.
func get_selected_animation() -> AnimationData:
	return current_animation


## Refresh the UI.
func refresh() -> void:
	_update_required_poses_ui()
	_update_animations_list()
	_update_ui_state()
