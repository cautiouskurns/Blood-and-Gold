## OrderPanel - UI panel for issuing orders to soldiers
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.10-soldier-order-system-ui.md
## Task 2.10: Soldier Order System UI
class_name OrderPanel
extends Control

# ===== SIGNALS =====
signal order_assignment_started(order: Unit.SoldierOrder)
signal order_assignment_cancelled()
signal order_assigned(soldier: Unit, order: Unit.SoldierOrder)

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.15
const TOOLTIP_DELAY: float = 0.5

# Panel styling
const PANEL_BG_COLOR: Color = Color("#1a1a2e")
const PANEL_BG_OPACITY: float = 0.85
const PANEL_BORDER_COLOR: Color = Color("#4a4a6a")

# Button styling
const BUTTON_BG_DEFAULT: Color = Color("#2d2d44")
const BUTTON_BG_HOVER: Color = Color("#3d3d5c")
const BUTTON_BG_SELECTED: Color = Color("#4a90d9")
const BUTTON_BG_DISABLED: Color = Color("#1d1d2e")

# Order colors (match unit.gd ORDER_COLORS)
const ORDER_COLORS: Dictionary = {
	Unit.SoldierOrder.HOLD: Color("#e74c3c"),      # Red - defensive
	Unit.SoldierOrder.ADVANCE: Color("#2ecc71"),   # Green - aggressive
	Unit.SoldierOrder.FOCUS_FIRE: Color("#f39c12"), # Orange - targeted
	Unit.SoldierOrder.RETREAT: Color("#9b59b6"),   # Purple - withdraw
	Unit.SoldierOrder.PROTECT: Color("#3498db"),   # Blue - guardian
}

# Order descriptions for tooltips
const ORDER_DESCRIPTIONS: Dictionary = {
	Unit.SoldierOrder.HOLD: "Stay in position. Attack any enemy that comes into range.",
	Unit.SoldierOrder.ADVANCE: "Move toward the nearest enemy and attack when adjacent.",
	Unit.SoldierOrder.FOCUS_FIRE: "All soldiers with this order attack the same target.",
	Unit.SoldierOrder.RETREAT: "Fall back toward the starting edge of the map.",
	Unit.SoldierOrder.PROTECT: "Stay near and guard a specific ally.",
}

# Order display names
const ORDER_NAMES: Dictionary = {
	Unit.SoldierOrder.HOLD: "HOLD",
	Unit.SoldierOrder.ADVANCE: "ADVANCE",
	Unit.SoldierOrder.FOCUS_FIRE: "FOCUS",
	Unit.SoldierOrder.RETREAT: "RETREAT",
	Unit.SoldierOrder.PROTECT: "PROTECT",
}

# ===== STATE =====
enum PanelState { IDLE, ASSIGNING }
var _panel_state: PanelState = PanelState.IDLE
var _pending_order: Unit.SoldierOrder = Unit.SoldierOrder.HOLD
var _is_enabled: bool = true
var _fade_tween: Tween = null

# Button references
var _order_buttons: Dictionary = {}  # Unit.SoldierOrder -> Button
var _button_tweens: Dictionary = {}  # Unit.SoldierOrder -> Tween (for pulse animation)

# Tooltip state
var _tooltip_timer: Timer = null
var _hovered_order: int = -1
var _tooltip_popup: PanelContainer = null
var _tooltip_label: RichTextLabel = null

# ===== NODE REFERENCES =====
@onready var panel_container: PanelContainer = $PanelContainer
@onready var button_grid: GridContainer = $PanelContainer/VBoxContainer/ButtonGrid
@onready var protect_button: Button = $PanelContainer/VBoxContainer/ProtectButton
@onready var status_label: Label = $PanelContainer/VBoxContainer/StatusLabel
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false
	modulate.a = 0.0
	_setup_panel_style()
	_setup_buttons()
	_setup_tooltip()
	_connect_signals()
	# Register with CombatManager for click routing
	CombatManager.set_order_panel(self)
	print("[OrderPanel] Initialized")

func _unhandled_input(event: InputEvent) -> void:
	## Handle cancel inputs during assignment mode
	if _panel_state != PanelState.ASSIGNING:
		return

	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			exit_assignment_mode()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			exit_assignment_mode()
			get_viewport().set_input_as_handled()

# ===== SETUP =====
func _setup_panel_style() -> void:
	## Configure panel background style
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_BG_COLOR
	style.bg_color.a = PANEL_BG_OPACITY
	style.border_color = PANEL_BORDER_COLOR
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel_container.add_theme_stylebox_override("panel", style)

	# Style title
	title_label.add_theme_color_override("font_color", Color("#f0c040"))

func _setup_buttons() -> void:
	## Setup order buttons with styling and connections
	# Get buttons from grid
	var advance_btn = button_grid.get_node("AdvanceButton") as Button
	var hold_btn = button_grid.get_node("HoldButton") as Button
	var focus_btn = button_grid.get_node("FocusFireButton") as Button
	var retreat_btn = button_grid.get_node("RetreatButton") as Button

	# Store references
	_order_buttons[Unit.SoldierOrder.ADVANCE] = advance_btn
	_order_buttons[Unit.SoldierOrder.HOLD] = hold_btn
	_order_buttons[Unit.SoldierOrder.FOCUS_FIRE] = focus_btn
	_order_buttons[Unit.SoldierOrder.RETREAT] = retreat_btn
	_order_buttons[Unit.SoldierOrder.PROTECT] = protect_button

	# Setup each button
	for order in _order_buttons:
		var button: Button = _order_buttons[order]
		_style_button(button, order)
		button.pressed.connect(_on_order_button_pressed.bind(order))
		button.mouse_entered.connect(_on_button_hover_start.bind(order))
		button.mouse_exited.connect(_on_button_hover_end.bind(order))

func _style_button(button: Button, order: Unit.SoldierOrder) -> void:
	## Apply styling to an order button
	var color = ORDER_COLORS.get(order, Color.WHITE)

	# Normal style
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = BUTTON_BG_DEFAULT
	normal_style.corner_radius_top_left = 4
	normal_style.corner_radius_top_right = 4
	normal_style.corner_radius_bottom_left = 4
	normal_style.corner_radius_bottom_right = 4
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = color.darkened(0.3)
	button.add_theme_stylebox_override("normal", normal_style)

	# Hover style
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = BUTTON_BG_HOVER
	hover_style.border_color = color
	button.add_theme_stylebox_override("hover", hover_style)

	# Pressed style
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = BUTTON_BG_SELECTED
	pressed_style.border_color = color.lightened(0.2)
	button.add_theme_stylebox_override("pressed", pressed_style)

	# Disabled style
	var disabled_style = normal_style.duplicate()
	disabled_style.bg_color = BUTTON_BG_DISABLED
	disabled_style.border_color = Color(0.3, 0.3, 0.3)
	button.add_theme_stylebox_override("disabled", disabled_style)

	# Text color
	button.add_theme_color_override("font_color", Color("#e0e0e0"))
	button.add_theme_color_override("font_hover_color", color.lightened(0.3))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))

func _setup_tooltip() -> void:
	## Setup tooltip popup
	_tooltip_popup = PanelContainer.new()
	_tooltip_popup.visible = false
	_tooltip_popup.z_index = 100

	# Style tooltip
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1a1a2e", 0.95)
	style.border_color = Color("#4a4a6a")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	_tooltip_popup.add_theme_stylebox_override("panel", style)

	# Add label
	_tooltip_label = RichTextLabel.new()
	_tooltip_label.bbcode_enabled = true
	_tooltip_label.fit_content = true
	_tooltip_label.custom_minimum_size = Vector2(180, 0)
	_tooltip_label.scroll_active = false
	_tooltip_popup.add_child(_tooltip_label)

	# Add to scene
	add_child(_tooltip_popup)

	# Setup timer
	_tooltip_timer = Timer.new()
	_tooltip_timer.one_shot = true
	_tooltip_timer.timeout.connect(_show_tooltip)
	add_child(_tooltip_timer)

func _connect_signals() -> void:
	## Connect to CombatManager signals
	CombatManager.turn_started.connect(_on_turn_started)
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_started.connect(_on_battle_started)
	CombatManager.battle_ended.connect(_on_battle_ended)
	CombatManager.battle_won.connect(_on_battle_won)
	CombatManager.battle_lost.connect(_on_battle_lost)
	print("[OrderPanel] Connected to CombatManager signals")

# ===== PUBLIC API =====
func show_panel() -> void:
	## Show the order panel
	if visible and modulate.a > 0.9:
		return

	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	visible = true
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)
	_update_button_states()
	print("[OrderPanel] Showing panel")

func hide_panel() -> void:
	## Hide the order panel
	if not visible:
		return

	exit_assignment_mode()

	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_callback(func(): visible = false)

func set_panel_enabled(enabled: bool) -> void:
	## Enable or disable the panel
	_is_enabled = enabled
	_update_button_states()

	if not enabled:
		exit_assignment_mode()

func enter_assignment_mode(order: Unit.SoldierOrder) -> void:
	## Enter order assignment mode
	if not _is_enabled:
		return

	# Exit previous mode if any
	if _panel_state == PanelState.ASSIGNING:
		_clear_button_highlight(_pending_order)

	_panel_state = PanelState.ASSIGNING
	_pending_order = order

	# Visual feedback
	_highlight_selected_button(order)
	status_label.text = "Click soldier..."
	status_label.add_theme_color_override("font_color", ORDER_COLORS.get(order, Color.WHITE))

	# Highlight valid soldiers
	_highlight_valid_soldiers()

	order_assignment_started.emit(order)
	print("[OrderPanel] Assignment mode: %s" % ORDER_NAMES.get(order, "???"))

func exit_assignment_mode() -> void:
	## Exit order assignment mode
	if _panel_state != PanelState.ASSIGNING:
		return

	_clear_button_highlight(_pending_order)
	_clear_soldier_highlights()

	_panel_state = PanelState.IDLE
	status_label.text = ""

	order_assignment_cancelled.emit()
	print("[OrderPanel] Assignment mode cancelled")

func assign_order_to_soldier(soldier: Unit, order: Unit.SoldierOrder) -> void:
	## Assign an order to a soldier
	if not is_instance_valid(soldier) or not soldier.is_soldier:
		return

	soldier.set_order(order)
	order_assigned.emit(soldier, order)

	# Visual feedback on soldier
	_flash_soldier(soldier)

	print("[OrderPanel] Assigned %s to %s" % [ORDER_NAMES.get(order, "???"), soldier.unit_name])

func try_assign_order_to_unit(unit: Unit) -> bool:
	## Called when a unit is clicked during assignment mode
	## Returns true if order was assigned
	if _panel_state != PanelState.ASSIGNING:
		return false

	if not is_instance_valid(unit):
		exit_assignment_mode()
		return false

	if not unit.is_soldier:
		print("[OrderPanel] Cannot assign order to non-soldier: %s" % unit.unit_name)
		exit_assignment_mode()
		return false

	# Assign the order
	assign_order_to_soldier(unit, _pending_order)

	# Exit assignment mode
	exit_assignment_mode()

	return true

func is_assigning() -> bool:
	## Check if panel is in assignment mode
	return _panel_state == PanelState.ASSIGNING

# ===== INTERNAL METHODS =====
func _update_button_states() -> void:
	## Update button enabled states
	var has_soldiers = _has_soldiers_in_battle()
	var can_interact = _is_enabled and has_soldiers

	for order in _order_buttons:
		var button: Button = _order_buttons[order]
		button.disabled = not can_interact

func _has_soldiers_in_battle() -> bool:
	## Check if there are any friendly soldiers in battle
	var units = get_tree().get_nodes_in_group("units")
	for node in units:
		var unit = node as Unit
		if unit and is_instance_valid(unit) and unit.is_alive():
			if unit.is_soldier and not unit.is_enemy:
				return true
	return false

func _highlight_selected_button(order: Unit.SoldierOrder) -> void:
	## Highlight the selected order button with pulse animation
	var button: Button = _order_buttons.get(order)
	if not button:
		return

	var color = ORDER_COLORS.get(order, Color.WHITE)

	# Create pulsing highlight
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(button, "modulate", color.lightened(0.5), 0.4)
	tween.tween_property(button, "modulate", Color.WHITE, 0.4)

	_button_tweens[order] = tween

func _clear_button_highlight(order: Unit.SoldierOrder) -> void:
	## Clear highlight from a button
	if _button_tweens.has(order):
		var tween = _button_tweens[order]
		if tween and tween.is_running():
			tween.kill()
		_button_tweens.erase(order)

	var button: Button = _order_buttons.get(order)
	if button:
		button.modulate = Color.WHITE

func _highlight_valid_soldiers() -> void:
	## Highlight all friendly soldiers as valid targets
	var units = get_tree().get_nodes_in_group("units")
	for node in units:
		var unit = node as Unit
		if unit and is_instance_valid(unit) and unit.is_alive():
			if unit.is_soldier and not unit.is_enemy:
				_highlight_soldier(unit)

func _highlight_soldier(unit: Unit) -> void:
	## Add highlight to a soldier
	var sprite = unit.get_node_or_null("Sprite2D")
	if not sprite:
		return

	# Store original modulate
	if not sprite.has_meta("order_original_modulate"):
		sprite.set_meta("order_original_modulate", sprite.modulate)

	# Green highlight for valid target
	var highlight_color = Color("#2ecc71")
	sprite.modulate = highlight_color

	# Pulse effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate", highlight_color.lightened(0.3), 0.3)
	tween.tween_property(sprite, "modulate", highlight_color, 0.3)
	sprite.set_meta("order_highlight_tween", tween)

func _clear_soldier_highlights() -> void:
	## Remove highlights from all soldiers
	var units = get_tree().get_nodes_in_group("units")
	for node in units:
		var unit = node as Unit
		if not unit:
			continue

		var sprite = unit.get_node_or_null("Sprite2D")
		if not sprite:
			continue

		# Stop tween
		if sprite.has_meta("order_highlight_tween"):
			var tween = sprite.get_meta("order_highlight_tween")
			if tween and tween.is_running():
				tween.kill()
			sprite.remove_meta("order_highlight_tween")

		# Restore original color
		if sprite.has_meta("order_original_modulate"):
			sprite.modulate = sprite.get_meta("order_original_modulate")
			sprite.remove_meta("order_original_modulate")
		else:
			sprite.modulate = Color.WHITE

func _flash_soldier(unit: Unit) -> void:
	## Brief flash effect when order is assigned
	var sprite = unit.get_node_or_null("Sprite2D")
	if not sprite:
		return

	var original = sprite.modulate
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE * 2.0, 0.1)
	tween.tween_property(sprite, "modulate", original, 0.2)

# ===== TOOLTIP =====
func _on_button_hover_start(order: Unit.SoldierOrder) -> void:
	## Start tooltip timer on hover
	_hovered_order = order
	_tooltip_timer.start(TOOLTIP_DELAY)

func _on_button_hover_end(_order: Unit.SoldierOrder) -> void:
	## Cancel tooltip on hover end
	_hovered_order = -1
	_tooltip_timer.stop()
	_tooltip_popup.visible = false

func _show_tooltip() -> void:
	## Show tooltip for hovered button
	if _hovered_order < 0:
		return

	var order = _hovered_order as Unit.SoldierOrder
	var button: Button = _order_buttons.get(order)
	if not button:
		return

	var description = ORDER_DESCRIPTIONS.get(order, "")
	var name = ORDER_NAMES.get(order, "???")
	var color = ORDER_COLORS.get(order, Color.WHITE)

	_tooltip_label.text = "[b][color=#%s]%s[/color][/b]\n%s" % [
		color.to_html(false),
		name,
		description
	]

	# Position tooltip to the left of the panel
	var button_rect = button.get_global_rect()
	_tooltip_popup.position = Vector2(
		button_rect.position.x - _tooltip_popup.size.x - 10,
		button_rect.position.y
	)

	# Clamp to screen
	_tooltip_popup.position.x = maxf(_tooltip_popup.position.x, 10)
	_tooltip_popup.position.y = clampf(_tooltip_popup.position.y, 10,
		get_viewport_rect().size.y - _tooltip_popup.size.y - 10)

	_tooltip_popup.visible = true

# ===== SIGNAL HANDLERS =====
func _on_order_button_pressed(order: Unit.SoldierOrder) -> void:
	## Handle order button click
	if not _is_enabled:
		return

	# Hide tooltip
	_tooltip_popup.visible = false
	_tooltip_timer.stop()

	if _panel_state == PanelState.ASSIGNING and _pending_order == order:
		# Clicking same order cancels
		exit_assignment_mode()
	else:
		# Enter assignment mode for this order
		enter_assignment_mode(order)

func _on_turn_started(unit: Unit) -> void:
	## Enable panel on friendly turn
	if unit and not unit.is_enemy:
		set_panel_enabled(true)
	else:
		set_panel_enabled(false)

func _on_turn_ended(_unit: Unit) -> void:
	## Check if we should disable panel
	pass  # Panel state updated on next turn_started

func _on_battle_started(_units: Array[Unit]) -> void:
	## Show panel when battle starts
	show_panel()
	# Start disabled until first friendly turn
	set_panel_enabled(false)

func _on_battle_ended() -> void:
	## Hide panel when battle ends
	hide_panel()

func _on_battle_won(_gold: int) -> void:
	## Hide panel on victory
	hide_panel()

func _on_battle_lost() -> void:
	## Hide panel on defeat
	hide_panel()
