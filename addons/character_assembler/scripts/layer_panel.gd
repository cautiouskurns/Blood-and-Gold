@tool
extends VBoxContainer
## Layer panel for the Character Assembler.
## Displays shapes as layers and allows reordering and deletion.

signal layer_selected(index: int)
signal layer_visibility_changed(index: int, visible: bool)
signal layer_order_changed()
signal delete_requested()

# UI References
var _layer_list: ItemList
var _up_btn: Button
var _down_btn: Button
var _delete_btn: Button

# State
var _shapes: Array = []
var _selected_indices: Array[int] = []


func _ready() -> void:
	_setup_ui()
	_connect_signals()


func _setup_ui() -> void:
	# Header
	var header = Label.new()
	header.text = "LAYERS"
	header.add_theme_font_size_override("font_size", 32)
	add_child(header)

	add_child(HSeparator.new())

	# Layer list
	_layer_list = ItemList.new()
	_layer_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_layer_list.custom_minimum_size = Vector2(0, 150)
	_layer_list.select_mode = ItemList.SELECT_MULTI
	_layer_list.add_theme_font_size_override("font_size", 28)
	_layer_list.tooltip_text = "Shape layers - higher layers render on top\nCtrl+click to multi-select, Shift+click for range"
	add_child(_layer_list)

	# Buttons
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 4)
	add_child(btn_container)

	_up_btn = Button.new()
	_up_btn.text = "Up"
	_up_btn.tooltip_text = "Move layer up (Page Up)"
	_up_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_container.add_child(_up_btn)

	_down_btn = Button.new()
	_down_btn.text = "Down"
	_down_btn.tooltip_text = "Move layer down (Page Down)"
	_down_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_container.add_child(_down_btn)

	_delete_btn = Button.new()
	_delete_btn.text = "Delete"
	_delete_btn.tooltip_text = "Delete selected (Delete)"
	_delete_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_container.add_child(_delete_btn)


func _connect_signals() -> void:
	_layer_list.item_selected.connect(_on_item_selected)
	_layer_list.multi_selected.connect(_on_multi_selected)
	_up_btn.pressed.connect(_on_up_pressed)
	_down_btn.pressed.connect(_on_down_pressed)
	_delete_btn.pressed.connect(_on_delete_pressed)


func _on_item_selected(index: int) -> void:
	_update_selected_from_list()


func _on_multi_selected(index: int, selected: bool) -> void:
	_update_selected_from_list()


func _update_selected_from_list() -> void:
	_selected_indices.clear()
	for i in range(_layer_list.item_count):
		if _layer_list.is_selected(i):
			# Map from list index (reversed) to shape index
			var shape_index = _layer_list.item_count - 1 - i
			_selected_indices.append(shape_index)

	if not _selected_indices.is_empty():
		layer_selected.emit(_selected_indices[0])


func _on_up_pressed() -> void:
	layer_order_changed.emit()


func _on_down_pressed() -> void:
	layer_order_changed.emit()


func _on_delete_pressed() -> void:
	delete_requested.emit()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not _layer_list.has_focus():
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_DELETE, KEY_BACKSPACE:
				delete_requested.emit()
				get_viewport().set_input_as_handled()
			KEY_PAGEUP:
				layer_order_changed.emit()
				get_viewport().set_input_as_handled()
			KEY_PAGEDOWN:
				layer_order_changed.emit()
				get_viewport().set_input_as_handled()


# =============================================================================
# PUBLIC API
# =============================================================================

## Update the layer list from shapes array.
func update_layers(shapes: Array, selected: Array[int]) -> void:
	_shapes = shapes
	_selected_indices = selected
	_refresh_list()


func _refresh_list() -> void:
	_layer_list.clear()

	# Sort shapes by layer (descending - highest layer at top)
	var indexed_shapes = []
	for i in range(_shapes.size()):
		indexed_shapes.append({"index": i, "shape": _shapes[i]})

	indexed_shapes.sort_custom(func(a, b):
		return a.shape.get("layer", 0) > b.shape.get("layer", 0)
	)

	# Add items to list
	for data in indexed_shapes:
		var shape = data.shape
		var shape_index = data.index
		var type = shape.get("type", "unknown")
		var layer = shape.get("layer", 0)
		var color = Color(shape.color[0], shape.color[1], shape.color[2])

		var text = "[%02d] %s" % [layer, type.capitalize()]
		var idx = _layer_list.add_item(text)

		# Set item color icon
		_layer_list.set_item_icon_modulate(idx, color)

		# Store shape index as metadata
		_layer_list.set_item_metadata(idx, shape_index)

		# Select if in selected indices
		if shape_index in _selected_indices:
			_layer_list.select(idx, false)


## Select layers by shape indices.
func select_layers(indices: Array[int]) -> void:
	_selected_indices = indices
	_layer_list.deselect_all()

	for i in range(_layer_list.item_count):
		var shape_index = _layer_list.get_item_metadata(i)
		if shape_index in indices:
			_layer_list.select(i, false)


## Get selected shape indices.
func get_selected_indices() -> Array[int]:
	var result: Array[int] = []
	for i in range(_layer_list.item_count):
		if _layer_list.is_selected(i):
			result.append(_layer_list.get_item_metadata(i))
	return result
