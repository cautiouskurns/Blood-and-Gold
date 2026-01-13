@tool
extends VBoxContainer
## Shape tools panel for the Character Assembler.
## Provides tool selection, color picker, and palette management.

signal tool_changed(tool: int)
signal color_changed(color: Color)

const ColorPaletteScript = preload("res://addons/character_assembler/scripts/color_palette.gd")

# Tool buttons
var _select_btn: Button
var _rect_btn: Button
var _circle_btn: Button
var _ellipse_btn: Button
var _triangle_btn: Button
var _tool_buttons: Array[Button] = []

# Color UI
var _color_picker_btn: ColorPickerButton
var _color_grid: GridContainer
var _palette_dropdown: OptionButton

# State
var current_tool: int = 0  # CharacterCanvas.Tool.SELECT
var current_color: Color = Color.WHITE
var _palettes: Array = []


func _ready() -> void:
	_setup_ui()
	_load_palettes()
	_connect_signals()


func _setup_ui() -> void:
	# Tools section
	var tools_label = Label.new()
	tools_label.text = "TOOLS"
	tools_label.add_theme_font_size_override("font_size", 14)
	add_child(tools_label)

	add_child(HSeparator.new())

	# Tool buttons container
	var tools_container = VBoxContainer.new()
	tools_container.add_theme_constant_override("separation", 4)
	add_child(tools_container)

	# Create tool buttons
	_select_btn = _create_tool_button("Select (V)", 0, tools_container)
	_rect_btn = _create_tool_button("Rectangle (R)", 1, tools_container)
	_circle_btn = _create_tool_button("Circle (C)", 2, tools_container)
	_ellipse_btn = _create_tool_button("Ellipse (E)", 3, tools_container)
	_triangle_btn = _create_tool_button("Triangle (T)", 4, tools_container)

	_tool_buttons = [_select_btn, _rect_btn, _circle_btn, _ellipse_btn, _triangle_btn]
	_update_tool_buttons()

	add_child(Control.new())  # Spacer

	# Colors section
	var colors_label = Label.new()
	colors_label.text = "COLORS"
	colors_label.add_theme_font_size_override("font_size", 14)
	add_child(colors_label)

	add_child(HSeparator.new())

	# Current color picker
	var color_row = HBoxContainer.new()
	add_child(color_row)

	var current_label = Label.new()
	current_label.text = "Current:"
	color_row.add_child(current_label)

	_color_picker_btn = ColorPickerButton.new()
	_color_picker_btn.custom_minimum_size = Vector2(60, 30)
	_color_picker_btn.color = current_color
	_color_picker_btn.edit_alpha = true
	color_row.add_child(_color_picker_btn)

	add_child(Control.new())  # Spacer

	# Palette dropdown
	var palette_label = Label.new()
	palette_label.text = "Palette:"
	add_child(palette_label)

	_palette_dropdown = OptionButton.new()
	add_child(_palette_dropdown)

	add_child(Control.new())  # Spacer

	# Color grid
	_color_grid = GridContainer.new()
	_color_grid.columns = 4
	_color_grid.add_theme_constant_override("h_separation", 4)
	_color_grid.add_theme_constant_override("v_separation", 4)
	add_child(_color_grid)


func _create_tool_button(text: String, tool_id: int, parent: Node) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(_on_tool_button_pressed.bind(tool_id))
	parent.add_child(btn)
	return btn


func _load_palettes() -> void:
	_palettes = ColorPaletteScript.get_builtin_palettes()

	_palette_dropdown.clear()
	for palette in _palettes:
		_palette_dropdown.add_item(palette.palette_name)

	if not _palettes.is_empty():
		_update_color_grid(_palettes[0])


func _connect_signals() -> void:
	_color_picker_btn.color_changed.connect(_on_color_picker_changed)
	_palette_dropdown.item_selected.connect(_on_palette_selected)


func _on_tool_button_pressed(tool_id: int) -> void:
	current_tool = tool_id
	_update_tool_buttons()
	tool_changed.emit(tool_id)


func _update_tool_buttons() -> void:
	for i in range(_tool_buttons.size()):
		_tool_buttons[i].button_pressed = (i == current_tool)


func _on_color_picker_changed(color: Color) -> void:
	current_color = color
	color_changed.emit(color)


func _on_palette_selected(index: int) -> void:
	if index >= 0 and index < _palettes.size():
		_update_color_grid(_palettes[index])


func _update_color_grid(palette: Resource) -> void:
	# Clear existing color buttons
	for child in _color_grid.get_children():
		child.queue_free()

	# Create new color buttons
	for color in palette.colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(28, 28)

		# Create a ColorRect as child for better color display
		var color_rect = ColorRect.new()
		color_rect.color = color
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(color_rect)

		btn.pressed.connect(_on_palette_color_pressed.bind(color))
		btn.tooltip_text = "#%s" % color.to_html(false)
		_color_grid.add_child(btn)


func _on_palette_color_pressed(color: Color) -> void:
	current_color = color
	_color_picker_btn.color = color
	color_changed.emit(color)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var handled = false
		match event.keycode:
			KEY_V:
				_on_tool_button_pressed(0)  # Select
				handled = true
			KEY_R:
				_on_tool_button_pressed(1)  # Rectangle
				handled = true
			KEY_C:
				_on_tool_button_pressed(2)  # Circle
				handled = true
			KEY_E:
				_on_tool_button_pressed(3)  # Ellipse
				handled = true
			KEY_T:
				_on_tool_button_pressed(4)  # Triangle
				handled = true

		if handled:
			get_viewport().set_input_as_handled()


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the current tool.
func set_tool(tool_id: int) -> void:
	current_tool = tool_id
	_update_tool_buttons()


## Set the current color.
func set_color(color: Color) -> void:
	current_color = color
	_color_picker_btn.color = color


## Get the current color.
func get_color() -> Color:
	return current_color
