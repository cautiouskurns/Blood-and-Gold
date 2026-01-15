@tool
extends VBoxContainer
class_name ExportManager
## UI panel for exporting character animations.
## Provides options for format, scale, and background settings.

signal export_requested(options: ExportOptions)
signal export_complete(success: bool, message: String)

## Export configuration options.
class ExportOptions:
	var export_sprite_sheet: bool = true
	var export_individual_frames: bool = false
	var export_godot_scene: bool = true
	var export_metadata: bool = true
	var scale: int = 1
	var background_type: FrameRenderer.BackgroundType = FrameRenderer.BackgroundType.TRANSPARENT
	var background_color: Color = Color.MAGENTA
	var output_directory: String = ""
	var character_name: String = ""
	var export_all_directions: bool = true

# UI elements
var _header_label: Label
var _format_section: VBoxContainer
var _sprite_sheet_check: CheckBox
var _individual_frames_check: CheckBox
var _godot_scene_check: CheckBox
var _metadata_check: CheckBox

var _settings_section: VBoxContainer
var _scale_label: Label
var _scale_option: OptionButton
var _background_label: Label
var _background_option: OptionButton
var _color_picker: ColorPickerButton
var _directions_check: CheckBox

var _output_section: VBoxContainer
var _output_path_edit: LineEdit
var _browse_btn: Button
var _name_edit: LineEdit

var _export_btn: Button
var _status_label: Label

# State
var _current_options: ExportOptions


func _ready() -> void:
	_current_options = ExportOptions.new()
	_setup_ui()


func _setup_ui() -> void:
	# Header
	_header_label = Label.new()
	_header_label.text = "Export"
	_header_label.add_theme_font_size_override("font_size", 16)
	add_child(_header_label)

	# Format section
	_format_section = VBoxContainer.new()
	add_child(_format_section)

	var format_label := Label.new()
	format_label.text = "Export Formats:"
	_format_section.add_child(format_label)

	_sprite_sheet_check = CheckBox.new()
	_sprite_sheet_check.text = "Sprite Sheet (PNG)"
	_sprite_sheet_check.button_pressed = true
	_sprite_sheet_check.toggled.connect(_on_sprite_sheet_toggled)
	_format_section.add_child(_sprite_sheet_check)

	_individual_frames_check = CheckBox.new()
	_individual_frames_check.text = "Individual Frames (PNG)"
	_individual_frames_check.button_pressed = false
	_individual_frames_check.toggled.connect(_on_individual_frames_toggled)
	_format_section.add_child(_individual_frames_check)

	_godot_scene_check = CheckBox.new()
	_godot_scene_check.text = "Godot Scene (.tscn + .tres)"
	_godot_scene_check.button_pressed = true
	_godot_scene_check.toggled.connect(_on_godot_scene_toggled)
	_format_section.add_child(_godot_scene_check)

	_metadata_check = CheckBox.new()
	_metadata_check.text = "Metadata (JSON)"
	_metadata_check.button_pressed = true
	_metadata_check.toggled.connect(_on_metadata_toggled)
	_format_section.add_child(_metadata_check)

	# Separator
	var sep1 := HSeparator.new()
	add_child(sep1)

	# Settings section
	_settings_section = VBoxContainer.new()
	add_child(_settings_section)

	var settings_label := Label.new()
	settings_label.text = "Settings:"
	_settings_section.add_child(settings_label)

	# Scale
	var scale_hbox := HBoxContainer.new()
	_settings_section.add_child(scale_hbox)

	_scale_label = Label.new()
	_scale_label.text = "Scale:"
	_scale_label.custom_minimum_size.x = 80
	scale_hbox.add_child(_scale_label)

	_scale_option = OptionButton.new()
	_scale_option.add_item("1x (Original)")
	_scale_option.add_item("2x")
	_scale_option.add_item("4x")
	_scale_option.add_item("8x")
	_scale_option.selected = 0
	_scale_option.item_selected.connect(_on_scale_selected)
	scale_hbox.add_child(_scale_option)

	# Background
	var bg_hbox := HBoxContainer.new()
	_settings_section.add_child(bg_hbox)

	_background_label = Label.new()
	_background_label.text = "Background:"
	_background_label.custom_minimum_size.x = 80
	bg_hbox.add_child(_background_label)

	_background_option = OptionButton.new()
	_background_option.add_item("Transparent")
	_background_option.add_item("Solid Color")
	_background_option.selected = 0
	_background_option.item_selected.connect(_on_background_selected)
	bg_hbox.add_child(_background_option)

	_color_picker = ColorPickerButton.new()
	_color_picker.color = Color.MAGENTA
	_color_picker.custom_minimum_size = Vector2(32, 24)
	_color_picker.visible = false
	_color_picker.color_changed.connect(_on_color_changed)
	bg_hbox.add_child(_color_picker)

	# Directions
	_directions_check = CheckBox.new()
	_directions_check.text = "Export All Directions"
	_directions_check.button_pressed = true
	_directions_check.toggled.connect(_on_directions_toggled)
	_settings_section.add_child(_directions_check)

	# Separator
	var sep2 := HSeparator.new()
	add_child(sep2)

	# Output section
	_output_section = VBoxContainer.new()
	add_child(_output_section)

	var output_label := Label.new()
	output_label.text = "Output:"
	_output_section.add_child(output_label)

	# Character name
	var name_hbox := HBoxContainer.new()
	_output_section.add_child(name_hbox)

	var name_label := Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size.x = 80
	name_hbox.add_child(name_label)

	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "character_name"
	_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_edit.text_changed.connect(_on_name_changed)
	name_hbox.add_child(_name_edit)

	# Output path
	var path_hbox := HBoxContainer.new()
	_output_section.add_child(path_hbox)

	var path_label := Label.new()
	path_label.text = "Path:"
	path_label.custom_minimum_size.x = 80
	path_hbox.add_child(path_label)

	_output_path_edit = LineEdit.new()
	_output_path_edit.placeholder_text = "res://exports/"
	_output_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_output_path_edit.text_changed.connect(_on_path_changed)
	path_hbox.add_child(_output_path_edit)

	_browse_btn = Button.new()
	_browse_btn.text = "..."
	_browse_btn.pressed.connect(_on_browse_pressed)
	path_hbox.add_child(_browse_btn)

	# Export button
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(btn_hbox)

	_export_btn = Button.new()
	_export_btn.text = "Export"
	_export_btn.custom_minimum_size = Vector2(120, 32)
	_export_btn.pressed.connect(_on_export_pressed)
	btn_hbox.add_child(_export_btn)

	# Status
	_status_label = Label.new()
	_status_label.text = ""
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_status_label)


## Set the character name for export.
func set_character_name(name: String) -> void:
	_current_options.character_name = name
	if _name_edit:
		_name_edit.text = name


## Set the default output directory.
func set_output_directory(path: String) -> void:
	_current_options.output_directory = path
	if _output_path_edit:
		_output_path_edit.text = path


## Get current export options.
func get_options() -> ExportOptions:
	return _current_options


## Set status message.
func set_status(message: String, is_error: bool = false) -> void:
	if _status_label:
		_status_label.text = message
		if is_error:
			_status_label.add_theme_color_override("font_color", Color.RED)
		else:
			_status_label.remove_theme_color_override("font_color")


# Signal handlers
func _on_sprite_sheet_toggled(pressed: bool) -> void:
	_current_options.export_sprite_sheet = pressed


func _on_individual_frames_toggled(pressed: bool) -> void:
	_current_options.export_individual_frames = pressed


func _on_godot_scene_toggled(pressed: bool) -> void:
	_current_options.export_godot_scene = pressed


func _on_metadata_toggled(pressed: bool) -> void:
	_current_options.export_metadata = pressed


func _on_scale_selected(index: int) -> void:
	match index:
		0: _current_options.scale = 1
		1: _current_options.scale = 2
		2: _current_options.scale = 4
		3: _current_options.scale = 8


func _on_background_selected(index: int) -> void:
	if index == 0:
		_current_options.background_type = FrameRenderer.BackgroundType.TRANSPARENT
		_color_picker.visible = false
	else:
		_current_options.background_type = FrameRenderer.BackgroundType.SOLID_COLOR
		_color_picker.visible = true


func _on_color_changed(color: Color) -> void:
	_current_options.background_color = color


func _on_directions_toggled(pressed: bool) -> void:
	_current_options.export_all_directions = pressed


func _on_name_changed(new_name: String) -> void:
	_current_options.character_name = new_name


func _on_path_changed(new_path: String) -> void:
	_current_options.output_directory = new_path


func _on_browse_pressed() -> void:
	# Create file dialog for directory selection
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.title = "Select Export Directory"

	dialog.dir_selected.connect(func(dir: String):
		_output_path_edit.text = dir
		_current_options.output_directory = dir
		dialog.queue_free()
	)

	dialog.canceled.connect(func():
		dialog.queue_free()
	)

	# Add to scene temporarily
	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


func _on_export_pressed() -> void:
	# Validate options
	if _current_options.character_name.is_empty():
		set_status("Please enter a character name", true)
		return

	if _current_options.output_directory.is_empty():
		set_status("Please select an output directory", true)
		return

	if not _current_options.export_sprite_sheet and not _current_options.export_individual_frames:
		set_status("Please select at least one export format", true)
		return

	set_status("Exporting...")
	export_requested.emit(_current_options)
