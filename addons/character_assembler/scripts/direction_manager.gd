@tool
extends VBoxContainer
class_name DirectionManager
## Main panel for managing multi-direction character views.
## Provides view switching, auto-generation, and direction configuration.

signal direction_changed(direction: DirectionView.Direction)
signal shapes_updated(direction: DirectionView.Direction, shapes: Array)
signal request_copy_from_current()  # Request to copy current editor state to selected direction

## Generation modes for creating direction views.
enum GenerationMode {
	AUTO,         # Automatically generate from flips
	SEMI_MANUAL,  # Auto-generate but allow manual adjustments
	FULL_MANUAL,  # Each direction is fully manual
}

# Current state
var current_direction: DirectionView.Direction = DirectionView.Direction.SOUTH
var generation_mode: GenerationMode = GenerationMode.SEMI_MANUAL
var direction_views: Dictionary = {}  # Direction -> DirectionView
var canvas_size: int = 64

# UI References
var _direction_tabs: TabBar
var _mode_selector: OptionButton
var _auto_generate_btn: Button
var _copy_current_btn: Button
var _clear_direction_btn: Button
var _four_up_preview: FourUpPreview
var _status_label: Label


func _ready() -> void:
	_setup_ui()
	_initialize_direction_views()


func _setup_ui() -> void:
	# Header
	var header := Label.new()
	header.text = "Direction Manager"
	header.add_theme_font_size_override("font_size", 14)
	add_child(header)

	# Direction tabs
	_direction_tabs = TabBar.new()
	_direction_tabs.tab_alignment = TabBar.ALIGNMENT_CENTER
	for direction in DirectionView.get_all_directions():
		_direction_tabs.add_tab(DirectionView.get_direction_name(direction))
	_direction_tabs.tab_changed.connect(_on_direction_tab_changed)
	add_child(_direction_tabs)

	# Mode selector row
	var mode_row := HBoxContainer.new()
	add_child(mode_row)

	var mode_label := Label.new()
	mode_label.text = "Mode:"
	mode_row.add_child(mode_label)

	_mode_selector = OptionButton.new()
	_mode_selector.add_item("Auto-Flip", GenerationMode.AUTO)
	_mode_selector.add_item("Semi-Manual", GenerationMode.SEMI_MANUAL)
	_mode_selector.add_item("Full Manual", GenerationMode.FULL_MANUAL)
	_mode_selector.selected = GenerationMode.SEMI_MANUAL
	_mode_selector.item_selected.connect(_on_mode_changed)
	_mode_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_row.add_child(_mode_selector)

	# Action buttons row
	var action_row := HBoxContainer.new()
	add_child(action_row)

	_auto_generate_btn = Button.new()
	_auto_generate_btn.text = "Auto-Generate"
	_auto_generate_btn.tooltip_text = "Generate this direction from source direction"
	_auto_generate_btn.pressed.connect(_on_auto_generate_pressed)
	_auto_generate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(_auto_generate_btn)

	_copy_current_btn = Button.new()
	_copy_current_btn.text = "Copy Current"
	_copy_current_btn.tooltip_text = "Copy current editor shapes to this direction"
	_copy_current_btn.pressed.connect(_on_copy_current_pressed)
	_copy_current_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(_copy_current_btn)

	_clear_direction_btn = Button.new()
	_clear_direction_btn.text = "Clear"
	_clear_direction_btn.tooltip_text = "Clear this direction's data"
	_clear_direction_btn.pressed.connect(_on_clear_direction_pressed)
	action_row.add_child(_clear_direction_btn)

	# Four-up preview
	var preview_label := Label.new()
	preview_label.text = "All Directions Preview:"
	add_child(preview_label)

	_four_up_preview = FourUpPreview.new()
	_four_up_preview.custom_minimum_size = Vector2(250, 250)
	_four_up_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_four_up_preview.direction_selected.connect(_on_preview_direction_selected)
	add_child(_four_up_preview)

	# Status label
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	add_child(_status_label)

	_update_ui_state()


func _initialize_direction_views() -> void:
	# Create empty DirectionViews for all directions
	for direction in DirectionView.get_all_directions():
		direction_views[direction] = DirectionView.new(direction)

	# South is the primary direction, mark it as configured if it has data
	_update_four_up_preview()


func _on_direction_tab_changed(tab_index: int) -> void:
	var directions := DirectionView.get_all_directions()
	if tab_index >= 0 and tab_index < directions.size():
		current_direction = directions[tab_index]
		_four_up_preview.set_selected_direction(current_direction)
		_update_ui_state()
		direction_changed.emit(current_direction)


func _on_preview_direction_selected(direction: DirectionView.Direction) -> void:
	current_direction = direction
	# Update tab to match
	var directions := DirectionView.get_all_directions()
	for i in range(directions.size()):
		if directions[i] == direction:
			_direction_tabs.current_tab = i
			break
	_update_ui_state()
	direction_changed.emit(current_direction)


func _on_mode_changed(index: int) -> void:
	generation_mode = index as GenerationMode
	_update_ui_state()


func _on_auto_generate_pressed() -> void:
	var source_direction := AutoFlip.get_auto_source(current_direction)
	var source_view: DirectionView = direction_views.get(source_direction)

	if not source_view or not source_view.is_configured:
		_status_label.text = "Source direction (%s) not configured!" % DirectionView.get_direction_name(source_direction)
		return

	if not AutoFlip.can_auto_generate(source_direction, current_direction):
		_status_label.text = "Cannot auto-generate %s from %s" % [
			DirectionView.get_direction_name(current_direction),
			DirectionView.get_direction_name(source_direction)
		]
		return

	# Generate the flipped view
	var flip_mode := AutoFlip.get_recommended_flip_mode(source_direction, current_direction)
	var flipped_view := AutoFlip.generate_flipped_view(
		source_view,
		current_direction,
		flip_mode,
		canvas_size
	)

	direction_views[current_direction] = flipped_view
	_update_four_up_preview()
	_update_ui_state()

	shapes_updated.emit(current_direction, flipped_view.shapes)
	_status_label.text = "Generated %s from %s" % [
		DirectionView.get_direction_name(current_direction),
		DirectionView.get_direction_name(source_direction)
	]


func _on_copy_current_pressed() -> void:
	request_copy_from_current.emit()


func _on_clear_direction_pressed() -> void:
	var view: DirectionView = direction_views.get(current_direction)
	if view:
		view.clear()
		_update_four_up_preview()
		_update_ui_state()
		shapes_updated.emit(current_direction, [])
		_status_label.text = "%s cleared" % DirectionView.get_direction_name(current_direction)


func _update_ui_state() -> void:
	var view: DirectionView = direction_views.get(current_direction)
	var is_configured := view != null and view.is_configured
	var is_south := current_direction == DirectionView.Direction.SOUTH

	# Auto-generate only available for non-South directions in appropriate modes
	_auto_generate_btn.disabled = is_south or generation_mode == GenerationMode.FULL_MANUAL

	# Update button text based on mode
	if generation_mode == GenerationMode.AUTO:
		_auto_generate_btn.text = "Auto-Generate"
	else:
		_auto_generate_btn.text = "Re-Generate"

	# Clear only available if configured
	_clear_direction_btn.disabled = not is_configured

	# Update status
	_update_status_label()


func _update_status_label() -> void:
	var configured_count := 0
	for direction in direction_views:
		var view: DirectionView = direction_views[direction]
		if view and view.is_configured:
			configured_count += 1

	var current_view: DirectionView = direction_views.get(current_direction)
	var current_status := ""

	if current_view:
		if current_view.is_configured:
			if current_view.is_auto_generated:
				current_status = "(Auto from %s)" % current_view.source_direction.capitalize()
			else:
				current_status = "(Manual)"
		else:
			current_status = "(Not configured)"

	_status_label.text = "%s %s | %d/4 directions" % [
		DirectionView.get_direction_name(current_direction),
		current_status,
		configured_count
	]


func _update_four_up_preview() -> void:
	_four_up_preview.set_direction_views(direction_views, canvas_size)


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the canvas size for rendering.
func set_canvas_size(p_canvas_size: int) -> void:
	canvas_size = p_canvas_size
	_update_four_up_preview()


## Get the current direction.
func get_current_direction() -> DirectionView.Direction:
	return current_direction


## Set the current direction.
func set_current_direction(direction: DirectionView.Direction) -> void:
	current_direction = direction
	var directions := DirectionView.get_all_directions()
	for i in range(directions.size()):
		if directions[i] == direction:
			_direction_tabs.current_tab = i
			break
	_four_up_preview.set_selected_direction(direction)
	_update_ui_state()


## Get the DirectionView for a specific direction.
func get_direction_view(direction: DirectionView.Direction) -> DirectionView:
	return direction_views.get(direction)


## Get all direction views.
func get_all_direction_views() -> Dictionary:
	return direction_views


## Update the shapes for a specific direction.
func set_direction_shapes(direction: DirectionView.Direction, shapes: Array, body_parts: Dictionary = {}) -> void:
	var view: DirectionView = direction_views.get(direction)
	if not view:
		view = DirectionView.new(direction)
		direction_views[direction] = view

	view.shapes = shapes.duplicate(true)
	if not body_parts.is_empty():
		view.body_parts = body_parts.duplicate(true)
	view.is_configured = not shapes.is_empty()
	view.is_auto_generated = false

	_update_four_up_preview()
	_update_ui_state()


## Update direction data from the main editor.
## Called when the user edits shapes in the main canvas.
func update_from_editor(shapes: Array, body_parts: Dictionary) -> void:
	set_direction_shapes(current_direction, shapes, body_parts)


## Load direction views from saved data.
func load_direction_views(data: Dictionary) -> void:
	direction_views.clear()

	for direction_key in data:
		var direction := DirectionView.direction_from_key(direction_key)
		var view := DirectionView.from_dict(data[direction_key])
		direction_views[direction] = view

	# Ensure all directions have a view
	for direction in DirectionView.get_all_directions():
		if not direction_views.has(direction):
			direction_views[direction] = DirectionView.new(direction)

	_update_four_up_preview()
	_update_ui_state()


## Save direction views to dictionary.
func save_direction_views() -> Dictionary:
	var data: Dictionary = {}

	for direction in direction_views:
		var view: DirectionView = direction_views[direction]
		if view.is_configured:
			data[view.get_key()] = view.to_dict()

	return data


## Get shapes for the current direction.
func get_current_shapes() -> Array:
	var view: DirectionView = direction_views.get(current_direction)
	if view:
		return view.shapes
	return []


## Get body parts for the current direction.
func get_current_body_parts() -> Dictionary:
	var view: DirectionView = direction_views.get(current_direction)
	if view:
		return view.body_parts
	return {}


## Check if current direction is configured.
func is_current_configured() -> bool:
	var view: DirectionView = direction_views.get(current_direction)
	return view != null and view.is_configured


## Auto-generate all missing directions from configured ones.
func auto_generate_all() -> void:
	var generated_count := 0

	# First, try to generate West from East
	if _try_auto_generate(DirectionView.Direction.WEST, DirectionView.Direction.EAST):
		generated_count += 1

	# Try to generate East from West (if West was manually created)
	if _try_auto_generate(DirectionView.Direction.EAST, DirectionView.Direction.WEST):
		generated_count += 1

	# North from South is less reliable but can be attempted
	if _try_auto_generate(DirectionView.Direction.NORTH, DirectionView.Direction.SOUTH):
		generated_count += 1

	_update_four_up_preview()
	_update_ui_state()

	if generated_count > 0:
		_status_label.text = "Auto-generated %d direction(s)" % generated_count
	else:
		_status_label.text = "No directions could be auto-generated"


func _try_auto_generate(target: DirectionView.Direction, source: DirectionView.Direction) -> bool:
	var target_view: DirectionView = direction_views.get(target)
	var source_view: DirectionView = direction_views.get(source)

	# Skip if target already configured or source not available
	if target_view and target_view.is_configured:
		return false
	if not source_view or not source_view.is_configured:
		return false

	var flip_mode := AutoFlip.get_recommended_flip_mode(source, target)
	var flipped := AutoFlip.generate_flipped_view(source_view, target, flip_mode, canvas_size)
	direction_views[target] = flipped

	shapes_updated.emit(target, flipped.shapes)
	return true
