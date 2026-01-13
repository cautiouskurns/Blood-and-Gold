@tool
extends HBoxContainer
class_name RotationSlider
## Custom rotation slider component for body part rotation control.

signal value_changed(part_name: String, degrees: float)
signal reset_requested(part_name: String)

var _part_name: String = ""
var _label: Label
var _slider: HSlider
var _spin: SpinBox
var _reset_btn: Button

var _updating: bool = false


func _init(part_name: String = "") -> void:
	_part_name = part_name


func _ready() -> void:
	_setup_ui()
	_connect_signals()


func _setup_ui() -> void:
	# Part name label
	_label = Label.new()
	_label.text = _part_name + ":"
	_label.custom_minimum_size = Vector2(120, 0)
	_label.add_theme_font_size_override("font_size", 24)
	add_child(_label)

	# Rotation slider
	_slider = HSlider.new()
	_slider.min_value = -180
	_slider.max_value = 180
	_slider.step = 1
	_slider.value = 0
	_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slider.custom_minimum_size = Vector2(150, 0)
	add_child(_slider)

	# Numeric spinbox
	_spin = SpinBox.new()
	_spin.min_value = -180
	_spin.max_value = 180
	_spin.step = 1
	_spin.value = 0
	_spin.suffix = "°"
	_spin.custom_minimum_size = Vector2(80, 0)
	add_child(_spin)

	# Reset button
	_reset_btn = Button.new()
	_reset_btn.text = "↺"
	_reset_btn.tooltip_text = "Reset to 0°"
	_reset_btn.custom_minimum_size = Vector2(32, 0)
	add_child(_reset_btn)


func _connect_signals() -> void:
	_slider.value_changed.connect(_on_slider_changed)
	_spin.value_changed.connect(_on_spin_changed)
	_reset_btn.pressed.connect(_on_reset_pressed)


func _on_slider_changed(value: float) -> void:
	if _updating:
		return
	_updating = true
	_spin.value = value
	_updating = false
	value_changed.emit(_part_name, value)


func _on_spin_changed(value: float) -> void:
	if _updating:
		return
	_updating = true
	_slider.value = value
	_updating = false
	value_changed.emit(_part_name, value)


func _on_reset_pressed() -> void:
	set_value(0.0)
	reset_requested.emit(_part_name)


## Get the current rotation value.
func get_value() -> float:
	return _slider.value


## Set the rotation value.
func set_value(degrees: float) -> void:
	_updating = true
	_slider.value = degrees
	_spin.value = degrees
	_updating = false


## Get the body part name.
func get_part_name() -> String:
	return _part_name


## Set enabled state.
func set_slider_enabled(enabled: bool) -> void:
	_slider.editable = enabled
	_spin.editable = enabled
	_reset_btn.disabled = not enabled


## Highlight this slider (e.g., when hovering over body part).
func set_highlighted(highlighted: bool) -> void:
	if highlighted:
		_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	else:
		_label.remove_theme_color_override("font_color")
