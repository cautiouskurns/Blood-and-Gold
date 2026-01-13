@tool
extends VBoxContainer
## Shape properties panel for the Character Assembler.
## Displays and allows editing of selected shape properties.

signal property_changed(property: String, value: Variant)

# UI References
var _pos_x_spin: SpinBox
var _pos_y_spin: SpinBox
var _width_spin: SpinBox
var _height_spin: SpinBox
var _rotation_spin: SpinBox
var _color_btn: ColorPickerButton

# State
var _current_shape: Dictionary = {}
var _updating: bool = false


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_set_enabled(false)


func _setup_ui() -> void:
	# Header
	var header = Label.new()
	header.text = "SHAPE PROPERTIES"
	header.add_theme_font_size_override("font_size", 32)
	add_child(header)

	add_child(HSeparator.new())

	# Position
	var pos_label = Label.new()
	pos_label.text = "Position"
	pos_label.add_theme_font_size_override("font_size", 28)
	add_child(pos_label)

	var pos_container = HBoxContainer.new()
	add_child(pos_container)

	var x_label = Label.new()
	x_label.text = "X:"
	x_label.add_theme_font_size_override("font_size", 28)
	pos_container.add_child(x_label)

	_pos_x_spin = SpinBox.new()
	_pos_x_spin.min_value = -128
	_pos_x_spin.max_value = 128
	_pos_x_spin.step = 1
	_pos_x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(_pos_x_spin)

	var y_label = Label.new()
	y_label.text = "Y:"
	y_label.add_theme_font_size_override("font_size", 28)
	pos_container.add_child(y_label)

	_pos_y_spin = SpinBox.new()
	_pos_y_spin.min_value = -128
	_pos_y_spin.max_value = 128
	_pos_y_spin.step = 1
	_pos_y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(_pos_y_spin)

	# Size
	var size_label = Label.new()
	size_label.text = "Size"
	size_label.add_theme_font_size_override("font_size", 28)
	add_child(size_label)

	var size_container = HBoxContainer.new()
	add_child(size_container)

	var w_label = Label.new()
	w_label.text = "W:"
	w_label.add_theme_font_size_override("font_size", 28)
	size_container.add_child(w_label)

	_width_spin = SpinBox.new()
	_width_spin.min_value = 1
	_width_spin.max_value = 128
	_width_spin.step = 1
	_width_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_container.add_child(_width_spin)

	var h_label = Label.new()
	h_label.text = "H:"
	h_label.add_theme_font_size_override("font_size", 28)
	size_container.add_child(h_label)

	_height_spin = SpinBox.new()
	_height_spin.min_value = 1
	_height_spin.max_value = 128
	_height_spin.step = 1
	_height_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_container.add_child(_height_spin)

	# Rotation
	var rot_container = HBoxContainer.new()
	add_child(rot_container)

	var rot_label = Label.new()
	rot_label.text = "Rotation:"
	rot_label.add_theme_font_size_override("font_size", 28)
	rot_container.add_child(rot_label)

	_rotation_spin = SpinBox.new()
	_rotation_spin.min_value = -180
	_rotation_spin.max_value = 180
	_rotation_spin.step = 1
	_rotation_spin.suffix = "°"
	_rotation_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rot_container.add_child(_rotation_spin)

	# Color
	var color_container = HBoxContainer.new()
	add_child(color_container)

	var color_label = Label.new()
	color_label.text = "Color:"
	color_label.add_theme_font_size_override("font_size", 28)
	color_container.add_child(color_label)

	_color_btn = ColorPickerButton.new()
	_color_btn.custom_minimum_size = Vector2(60, 30)
	_color_btn.edit_alpha = true
	_color_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_container.add_child(_color_btn)


func _connect_signals() -> void:
	_pos_x_spin.value_changed.connect(_on_pos_x_changed)
	_pos_y_spin.value_changed.connect(_on_pos_y_changed)
	_width_spin.value_changed.connect(_on_width_changed)
	_height_spin.value_changed.connect(_on_height_changed)
	_rotation_spin.value_changed.connect(_on_rotation_changed)
	_color_btn.color_changed.connect(_on_color_changed)


func _set_enabled(enabled: bool) -> void:
	_pos_x_spin.editable = enabled
	_pos_y_spin.editable = enabled
	_width_spin.editable = enabled
	_height_spin.editable = enabled
	_rotation_spin.editable = enabled
	_color_btn.disabled = not enabled


func _on_pos_x_changed(value: float) -> void:
	if _updating:
		return
	property_changed.emit("position_x", value)


func _on_pos_y_changed(value: float) -> void:
	if _updating:
		return
	property_changed.emit("position_y", value)


func _on_width_changed(value: float) -> void:
	if _updating:
		return
	property_changed.emit("width", value)


func _on_height_changed(value: float) -> void:
	if _updating:
		return
	property_changed.emit("height", value)


func _on_rotation_changed(value: float) -> void:
	if _updating:
		return
	property_changed.emit("rotation", value)


func _on_color_changed(color: Color) -> void:
	if _updating:
		return
	property_changed.emit("color", color)


# =============================================================================
# PUBLIC API
# =============================================================================

## Display properties for a shape.
func show_shape(shape: Dictionary) -> void:
	_updating = true
	_current_shape = shape
	_set_enabled(true)

	_pos_x_spin.value = shape.get("position", [0, 0])[0]
	_pos_y_spin.value = shape.get("position", [0, 0])[1]
	_width_spin.value = shape.get("size", [8, 8])[0]
	_height_spin.value = shape.get("size", [8, 8])[1]
	_rotation_spin.value = shape.get("rotation", 0.0)

	var c = shape.get("color", [1, 1, 1, 1])
	_color_btn.color = Color(c[0], c[1], c[2], c[3])

	_updating = false


## Clear the properties display.
func clear() -> void:
	_updating = true
	_current_shape = {}
	_set_enabled(false)

	_pos_x_spin.value = 0
	_pos_y_spin.value = 0
	_width_spin.value = 8
	_height_spin.value = 8
	_rotation_spin.value = 0
	_color_btn.color = Color.WHITE

	_updating = false


## Show properties for multiple shapes (displays "(multiple)" for differing values).
func show_multiple(shapes: Array) -> void:
	if shapes.is_empty():
		clear()
		return

	if shapes.size() == 1:
		show_shape(shapes[0])
		return

	_updating = true
	_set_enabled(true)

	# For multiple selection, show first shape's values
	var first = shapes[0]
	_pos_x_spin.value = first.get("position", [0, 0])[0]
	_pos_y_spin.value = first.get("position", [0, 0])[1]
	_width_spin.value = first.get("size", [8, 8])[0]
	_height_spin.value = first.get("size", [8, 8])[1]
	_rotation_spin.value = first.get("rotation", 0.0)

	var c = first.get("color", [1, 1, 1, 1])
	_color_btn.color = Color(c[0], c[1], c[2], c[3])

	_updating = false
