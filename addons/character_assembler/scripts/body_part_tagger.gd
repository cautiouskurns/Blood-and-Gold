@tool
extends VBoxContainer
class_name BodyPartTagger
## Body part tagger panel for the Character Assembler.
## Allows tagging shapes with body parts, setting pivots, and viewing rig hierarchy.

signal body_parts_changed()
signal pivot_mode_changed(enabled: bool)
signal body_part_selected(part_name: String)

# UI References
var _selected_label: Label
var _part_dropdown: OptionButton
var _pivot_x_spin: SpinBox
var _pivot_y_spin: SpinBox
var _set_pivot_btn: Button
var _parent_dropdown: OptionButton
var _apply_btn: Button
var _clear_btn: Button
var _rig_tree: RigTreeView
var _validation_label: RichTextLabel
var _progress_bar: ProgressBar
var _progress_label: Label

# State
var body_parts: Dictionary = {}  # part_name -> BodyPart
var _selected_shapes: Array[int] = []
var _pivot_mode: bool = false
var _current_part_name: String = ""
var _updating: bool = false


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	# Initialize current part to first item in dropdown
	_current_part_name = BodyPart.PART_NAMES[0]
	_update_pivot_hint()
	_update_parent_dropdown()
	_update_ui_state()


func _setup_ui() -> void:
	# Header
	var header := Label.new()
	header.text = "BODY PART TAGGER"
	header.add_theme_font_size_override("font_size", 32)
	add_child(header)

	add_child(HSeparator.new())

	# Selected shapes info
	_selected_label = Label.new()
	_selected_label.text = "Selected Shapes: None"
	_selected_label.add_theme_font_size_override("font_size", 28)
	add_child(_selected_label)

	add_child(Control.new())  # Spacer

	# Body part dropdown
	var part_row := HBoxContainer.new()
	add_child(part_row)

	var part_label := Label.new()
	part_label.text = "Assign to:"
	part_label.add_theme_font_size_override("font_size", 28)
	part_row.add_child(part_label)

	_part_dropdown = OptionButton.new()
	_part_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_part_dropdown.add_theme_font_size_override("font_size", 28)
	for part_name in BodyPart.PART_NAMES:
		_part_dropdown.add_item(part_name)
	part_row.add_child(_part_dropdown)

	add_child(Control.new())  # Spacer

	# Pivot point section
	var pivot_header := Label.new()
	pivot_header.text = "Pivot Point:"
	pivot_header.add_theme_font_size_override("font_size", 28)
	add_child(pivot_header)

	var pivot_row := HBoxContainer.new()
	add_child(pivot_row)

	var x_label := Label.new()
	x_label.text = "X:"
	x_label.add_theme_font_size_override("font_size", 28)
	pivot_row.add_child(x_label)

	_pivot_x_spin = SpinBox.new()
	_pivot_x_spin.min_value = -128
	_pivot_x_spin.max_value = 128
	_pivot_x_spin.step = 1
	_pivot_x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pivot_row.add_child(_pivot_x_spin)

	var y_label := Label.new()
	y_label.text = "Y:"
	y_label.add_theme_font_size_override("font_size", 28)
	pivot_row.add_child(y_label)

	_pivot_y_spin = SpinBox.new()
	_pivot_y_spin.min_value = -128
	_pivot_y_spin.max_value = 128
	_pivot_y_spin.step = 1
	_pivot_y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pivot_row.add_child(_pivot_y_spin)

	_set_pivot_btn = Button.new()
	_set_pivot_btn.text = "Set on Canvas"
	_set_pivot_btn.toggle_mode = true
	_set_pivot_btn.tooltip_text = "Click on canvas to set pivot point"
	add_child(_set_pivot_btn)

	var pivot_hint := Label.new()
	pivot_hint.name = "PivotHint"
	pivot_hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	pivot_hint.add_theme_font_size_override("font_size", 24)
	add_child(pivot_hint)

	add_child(Control.new())  # Spacer

	# Parent dropdown
	var parent_row := HBoxContainer.new()
	add_child(parent_row)

	var parent_label := Label.new()
	parent_label.text = "Parent:"
	parent_label.add_theme_font_size_override("font_size", 28)
	parent_row.add_child(parent_label)

	_parent_dropdown = OptionButton.new()
	_parent_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_parent_dropdown.add_theme_font_size_override("font_size", 28)
	_parent_dropdown.add_item("None (Root)")
	for part_name in BodyPart.PART_NAMES:
		_parent_dropdown.add_item(part_name)
	parent_row.add_child(_parent_dropdown)

	add_child(Control.new())  # Spacer

	# Action buttons
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	add_child(btn_row)

	_apply_btn = Button.new()
	_apply_btn.text = "Apply Tags"
	_apply_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_apply_btn)

	_clear_btn = Button.new()
	_clear_btn.text = "Clear Tags"
	_clear_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_clear_btn)

	add_child(HSeparator.new())

	# Rig tree section
	var tree_header := Label.new()
	tree_header.text = "CURRENT RIG:"
	tree_header.add_theme_font_size_override("font_size", 30)
	add_child(tree_header)

	_rig_tree = RigTreeView.new()
	_rig_tree.custom_minimum_size = Vector2(0, 400)
	_rig_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_rig_tree)

	add_child(HSeparator.new())

	# Validation section
	var val_header := Label.new()
	val_header.text = "VALIDATION:"
	val_header.add_theme_font_size_override("font_size", 30)
	add_child(val_header)

	_validation_label = RichTextLabel.new()
	_validation_label.custom_minimum_size = Vector2(0, 250)
	_validation_label.bbcode_enabled = true
	_validation_label.fit_content = false
	_validation_label.scroll_active = true
	_validation_label.add_theme_font_size_override("normal_font_size", 28)
	_validation_label.add_theme_font_size_override("bold_font_size", 28)
	add_child(_validation_label)

	add_child(HSeparator.new())

	# Progress section
	var progress_row := HBoxContainer.new()
	add_child(progress_row)

	var prog_label := Label.new()
	prog_label.text = "Progress:"
	prog_label.add_theme_font_size_override("font_size", 28)
	progress_row.add_child(prog_label)

	_progress_label = Label.new()
	_progress_label.text = "0/14"
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_progress_label.add_theme_font_size_override("font_size", 28)
	progress_row.add_child(_progress_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0
	_progress_bar.max_value = 14
	_progress_bar.value = 0
	_progress_bar.show_percentage = false
	add_child(_progress_bar)


func _connect_signals() -> void:
	_part_dropdown.item_selected.connect(_on_part_selected)
	_pivot_x_spin.value_changed.connect(_on_pivot_changed)
	_pivot_y_spin.value_changed.connect(_on_pivot_changed)
	_set_pivot_btn.toggled.connect(_on_set_pivot_toggled)
	_parent_dropdown.item_selected.connect(_on_parent_selected)
	_apply_btn.pressed.connect(_on_apply_pressed)
	_clear_btn.pressed.connect(_on_clear_pressed)
	_rig_tree.body_part_selected.connect(_on_tree_part_selected)


func _on_part_selected(index: int) -> void:
	if _updating:
		return

	_current_part_name = BodyPart.PART_NAMES[index]
	_update_pivot_hint()
	_update_parent_dropdown()
	_load_part_data()


func _on_pivot_changed(_value: float) -> void:
	if _updating:
		return
	# Pivot will be saved when Apply is pressed


func _on_set_pivot_toggled(pressed: bool) -> void:
	_pivot_mode = pressed
	pivot_mode_changed.emit(pressed)


func _on_parent_selected(index: int) -> void:
	if _updating:
		return
	# Parent will be saved when Apply is pressed


func _on_apply_pressed() -> void:
	print("BodyPartTagger: Apply pressed - part='%s', shapes=%s" % [_current_part_name, _selected_shapes])

	if _current_part_name.is_empty():
		push_warning("BodyPartTagger: No body part selected")
		return

	if _selected_shapes.is_empty():
		push_warning("BodyPartTagger: No shapes selected")
		return

	# Get or create the body part
	var part: BodyPart
	if _current_part_name in body_parts:
		part = body_parts[_current_part_name]
	else:
		part = BodyPart.new(_current_part_name)
		body_parts[_current_part_name] = part

	# Clear existing shapes and add selected ones
	part.shape_indices.clear()
	for idx in _selected_shapes:
		part.add_shape(idx)

	# Set pivot
	part.set_pivot(Vector2(_pivot_x_spin.value, _pivot_y_spin.value))

	# Set parent
	var parent_idx := _parent_dropdown.selected
	if parent_idx == 0:
		part.parent_name = ""
	else:
		part.parent_name = BodyPart.PART_NAMES[parent_idx - 1]

	body_parts_changed.emit()
	_update_tree()
	_update_validation()
	_update_progress()

	print("BodyPartTagger: Applied tags for %s with %d shapes" % [_current_part_name, part.shape_indices.size()])


func _on_clear_pressed() -> void:
	if _current_part_name.is_empty():
		return

	if _current_part_name in body_parts:
		body_parts.erase(_current_part_name)
		body_parts_changed.emit()
		_update_tree()
		_update_validation()
		_update_progress()

		print("BodyPartTagger: Cleared tags for %s" % _current_part_name)


func _on_tree_part_selected(part_name: String) -> void:
	# Update dropdown to match tree selection
	var index := BodyPart.PART_NAMES.find(part_name)
	if index >= 0:
		_updating = true
		_part_dropdown.selected = index
		_current_part_name = part_name
		_update_pivot_hint()
		_update_parent_dropdown()
		_load_part_data()
		_updating = false

	body_part_selected.emit(part_name)


func _update_pivot_hint() -> void:
	var hint_label = get_node_or_null("PivotHint")
	if hint_label and not _current_part_name.is_empty():
		var hint := BodyPart.get_pivot_hint(_current_part_name)
		hint_label.text = "Suggested: %s" % hint


func _update_parent_dropdown() -> void:
	if _current_part_name.is_empty():
		return

	_updating = true

	# Set default parent
	var default_parent := BodyPart.get_default_parent(_current_part_name)
	if default_parent.is_empty():
		_parent_dropdown.selected = 0
	else:
		var parent_index := BodyPart.PART_NAMES.find(default_parent)
		if parent_index >= 0:
			_parent_dropdown.selected = parent_index + 1

	_updating = false


func _load_part_data() -> void:
	if _current_part_name.is_empty():
		return

	_updating = true

	if _current_part_name in body_parts:
		var part: BodyPart = body_parts[_current_part_name]

		_pivot_x_spin.value = part.pivot.x
		_pivot_y_spin.value = part.pivot.y

		if part.parent_name.is_empty():
			_parent_dropdown.selected = 0
		else:
			var parent_index := BodyPart.PART_NAMES.find(part.parent_name)
			if parent_index >= 0:
				_parent_dropdown.selected = parent_index + 1
	else:
		_pivot_x_spin.value = 0
		_pivot_y_spin.value = 0
		_update_parent_dropdown()

	_updating = false


func _update_tree() -> void:
	_rig_tree.update_tree(body_parts)


func _update_validation() -> void:
	var total_shapes := 0  # Will be set by main panel
	var issues := RigValidator.validate(body_parts, total_shapes)

	var text := ""
	var shown := 0
	for issue in issues:
		if shown >= 5:
			text += "[color=#888888]... and %d more[/color]\n" % (issues.size() - shown)
			break

		var color := RigValidator.get_issue_color(issue.type)
		var color_hex := color.to_html(false)
		var icon := ""
		match issue.type:
			RigValidator.IssueType.ERROR: icon = "[color=#e05050]✗[/color]"
			RigValidator.IssueType.WARNING: icon = "[color=#e0b020]⚠[/color]"
			RigValidator.IssueType.INFO: icon = "[color=#808080]○[/color]"

		var part_prefix := ""
		if not issue.part_name.is_empty():
			part_prefix = "[b]%s:[/b] " % issue.part_name

		text += "%s %s%s\n" % [icon, part_prefix, issue.message]
		shown += 1

	if issues.is_empty():
		text = "[color=#40c040]✓ Rig configuration valid[/color]"

	_validation_label.text = text


func _update_progress() -> void:
	var configured := RigValidator.get_configured_count(body_parts)
	_progress_bar.value = configured
	_progress_label.text = "%d/14" % configured


func _update_ui_state() -> void:
	var has_selection := not _selected_shapes.is_empty()
	var has_part := not _current_part_name.is_empty()

	_apply_btn.disabled = not (has_selection and has_part)
	_clear_btn.disabled = not has_part or _current_part_name not in body_parts


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the selected shape indices (called from main panel).
func set_selected_shapes(indices: Array[int]) -> void:
	_selected_shapes = indices
	print("BodyPartTagger: set_selected_shapes called with %s" % [indices])

	if indices.is_empty():
		_selected_label.text = "Selected Shapes: None"
	elif indices.size() == 1:
		_selected_label.text = "Selected Shapes: 1 shape"
	else:
		_selected_label.text = "Selected Shapes: %d shapes" % indices.size()

	_update_ui_state()


## Set pivot from canvas click.
func set_pivot_from_canvas(pos: Vector2) -> void:
	_pivot_x_spin.value = pos.x
	_pivot_y_spin.value = pos.y

	# Turn off pivot mode
	_set_pivot_btn.button_pressed = false


## Load body parts from project.
func load_from_project(project_body_parts: Dictionary) -> void:
	body_parts = project_body_parts.duplicate(true)

	# Convert raw dictionaries to BodyPart objects
	for key in body_parts.keys():
		var data = body_parts[key]
		if data is Dictionary:
			body_parts[key] = BodyPart.from_dict(data)

	_update_tree()
	_update_validation()
	_update_progress()


## Save body parts to project.
func save_to_project() -> Dictionary:
	var result := {}
	for part_name in body_parts:
		var part: BodyPart = body_parts[part_name]
		result[part_name] = part.to_dict()
	return result


## Get shapes for a specific body part.
func get_shapes_for_part(part_name: String) -> Array[int]:
	if part_name in body_parts:
		return body_parts[part_name].shape_indices
	return []


## Check if pivot mode is active.
func is_pivot_mode() -> bool:
	return _pivot_mode


## Get current selected body part name.
func get_current_part() -> String:
	return _current_part_name


## Update validation with total shape count.
func update_validation(total_shapes: int) -> void:
	var issues := RigValidator.validate(body_parts, total_shapes)

	var text := ""
	var shown := 0
	for issue in issues:
		if shown >= 5:
			text += "[color=#888888]... and %d more[/color]\n" % (issues.size() - shown)
			break

		var icon := ""
		match issue.type:
			RigValidator.IssueType.ERROR: icon = "[color=#e05050]✗[/color]"
			RigValidator.IssueType.WARNING: icon = "[color=#e0b020]⚠[/color]"
			RigValidator.IssueType.INFO: icon = "[color=#808080]○[/color]"

		var part_prefix := ""
		if not issue.part_name.is_empty():
			part_prefix = "[b]%s:[/b] " % issue.part_name

		text += "%s %s%s\n" % [icon, part_prefix, issue.message]
		shown += 1

	if issues.is_empty():
		text = "[color=#40c040]✓ Rig configuration valid[/color]"

	_validation_label.text = text


## Refresh the display.
func refresh() -> void:
	_update_tree()
	_update_progress()
