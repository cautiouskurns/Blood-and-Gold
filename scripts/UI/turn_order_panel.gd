## TurnOrderPanel - Displays combat turn sequence
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.6-turn-order-ui-panel.md
extends Control

# ===== SIGNALS =====
signal turn_order_ready(units: Array)

# ===== CONSTANTS =====
const ICON_SIZE: Vector2 = Vector2(40, 40)
const ICON_SPACING: int = 4
const PANEL_PADDING: int = 8
const TRANSITION_DURATION: float = 0.2
const FADE_DURATION: float = 0.3
const COLOR_PANEL_BG: Color = Color("#1a1a2e", 0.8)
const COLOR_CURRENT_TURN: Color = Color("#f1c40f")

# ===== PRELOADS =====
const TurnOrderIconScene = preload("res://scenes/UI/TurnOrderIcon.tscn")

# ===== NODE REFERENCES =====
@onready var panel_bg: Panel = $PanelBackground
@onready var icon_container: HBoxContainer = $PanelBackground/IconContainer

# ===== INTERNAL STATE =====
var _icons: Array[Control] = []
var _units: Array[Unit] = []
var _current_turn_index: int = 0

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false  # Hidden until battle starts
	_setup_panel_style()
	print("[TurnOrderPanel] Ready")

func _setup_panel_style() -> void:
	## Configure panel background styling
	if not panel_bg:
		return

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_BG
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = PANEL_PADDING
	style.content_margin_right = PANEL_PADDING
	style.content_margin_top = PANEL_PADDING
	style.content_margin_bottom = PANEL_PADDING
	panel_bg.add_theme_stylebox_override("panel", style)

# ===== PUBLIC API =====
func initialize_turn_order(units: Array[Unit]) -> void:
	## Setup panel with units in initiative order
	## Units should already be sorted by initiative (highest first)
	_clear_icons()
	_units = units.duplicate()

	for unit in _units:
		var icon = _create_icon(unit)
		_icons.append(icon)
		icon_container.add_child(icon)

		# Connect to unit death signal
		if not unit.unit_died.is_connected(_on_unit_died):
			unit.unit_died.connect(_on_unit_died)

	_current_turn_index = 0
	_update_current_turn_highlight()
	visible = true
	turn_order_ready.emit(_units)
	print("[TurnOrderPanel] Initialized with %d units" % _units.size())

func advance_turn() -> void:
	## Move to next unit in turn order
	if _icons.is_empty():
		return

	# Animate out the current icon
	var current_icon = _icons[0]
	_animate_icon_out(current_icon)
	_icons.remove_at(0)

	# Remove from units list too
	if not _units.is_empty():
		_units.remove_at(0)

	# If more turns remain, highlight new current
	if not _icons.is_empty():
		_update_current_turn_highlight()
		print("[TurnOrderPanel] Advanced to next turn: %s" % _units[0].unit_name if not _units.is_empty() else "none")

func remove_unit(unit: Unit) -> void:
	## Remove a unit from turn order (death)
	for i in range(_icons.size()):
		var icon = _icons[i]
		if icon.get_unit() == unit:
			_icons.remove_at(i)
			_animate_icon_death(icon)

			# Also remove from units list
			for j in range(_units.size()):
				if _units[j] == unit:
					_units.remove_at(j)
					break
			break

	# Update highlight if needed
	if not _icons.is_empty():
		_update_current_turn_highlight()

	print("[TurnOrderPanel] Removed unit: %s" % unit.unit_name)

func get_current_unit() -> Unit:
	## Get the unit whose turn it currently is
	if _units.is_empty():
		return null
	return _units[0]

func get_turn_order() -> Array[Unit]:
	## Get the current turn order
	return _units

func hide_panel() -> void:
	## Hide panel at end of battle
	visible = false
	_clear_icons()
	_units.clear()
	print("[TurnOrderPanel] Hidden")

func show_panel() -> void:
	## Show the panel
	visible = true

# ===== INTERNAL METHODS =====
func _create_icon(unit: Unit) -> Control:
	## Create a turn order icon for a unit
	var icon = TurnOrderIconScene.instantiate()
	icon.custom_minimum_size = ICON_SIZE
	icon.setup(unit)
	return icon

func _clear_icons() -> void:
	## Remove all icons from the panel
	for icon in _icons:
		if is_instance_valid(icon):
			icon.queue_free()
	_icons.clear()

	# Also clear any remaining children in container
	if icon_container:
		for child in icon_container.get_children():
			child.queue_free()

func _update_current_turn_highlight() -> void:
	## Highlight the first icon as current turn
	for i in range(_icons.size()):
		if is_instance_valid(_icons[i]):
			_icons[i].set_current_turn(i == 0)

func _animate_icon_out(icon: Control) -> void:
	## Animate icon sliding out when turn ends
	if not is_instance_valid(icon):
		return

	var tween = create_tween()
	tween.tween_property(icon, "modulate:a", 0.0, TRANSITION_DURATION)
	tween.tween_callback(func():
		if is_instance_valid(icon):
			icon.queue_free()
	)

func _animate_icon_death(icon: Control) -> void:
	## Animate icon fading out when unit dies
	if not is_instance_valid(icon):
		return

	var tween = create_tween()
	tween.tween_property(icon, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func():
		if is_instance_valid(icon):
			icon.queue_free()
	)

# ===== SIGNAL HANDLERS =====
func _on_unit_died(unit: Unit) -> void:
	## Handle unit death signal
	remove_unit(unit)
