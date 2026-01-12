## AbilityBar - Displays 4 ability buttons for selected unit
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.2-ability-ui-panel.md, docs/features/4.3-combat-ui-polish.md
class_name AbilityBar
extends Control

# ===== SIGNALS =====
signal ability_selected(ability_id: String, ability_data: Dictionary)
signal ability_hover_started(ability_index: int, ability_data: Dictionary)
signal ability_hover_ended(ability_index: int)

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.15
const NUM_ABILITIES: int = 4
const ICON_SIZE: Vector2 = Vector2(64, 64)

# Panel styling
const PANEL_BG_COLOR: Color = Color("#1a1a2e")
const PANEL_BG_OPACITY: float = 0.9

# Unavailable state visuals
const COLOR_AVAILABLE: Color = Color.WHITE
const COLOR_UNAVAILABLE: Color = Color(0.4, 0.4, 0.4, 1.0)
const COLOR_NAME_AVAILABLE: Color = Color.WHITE
const COLOR_NAME_UNAVAILABLE: Color = Color(0.4, 0.4, 0.4, 1.0)

# Selected state visuals (targeting mode)
const COLOR_SELECTED: Color = Color("#f1c40f")  # Yellow/gold highlight
const COLOR_TARGETING_BORDER: Color = Color("#e74c3c")  # Red for targets

# ===== NODE REFERENCES =====
@onready var panel: PanelContainer = $PanelContainer
@onready var button_container: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer

# Array of ability button references
var _ability_buttons: Array[Dictionary] = []

# ===== INTERNAL STATE =====
var _current_unit: Unit = null
var _abilities: Array[Dictionary] = []
var _fade_tween: Tween = null
var _selected_ability_index: int = -1  # Currently selected ability for targeting

# ===== TOOLTIP STATE (Task 4.3) =====
var _tooltip: AbilityTooltip = null
var _hovered_button_index: int = -1
const AbilityTooltipScene = preload("res://scenes/UI/AbilityTooltip.tscn")

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false
	modulate.a = 0.0
	_setup_button_references()
	_connect_signals()
	_setup_panel_style()
	_setup_tooltip()
	print("[AbilityBar] Initialized")

func _setup_button_references() -> void:
	## Cache references to ability button components
	for i in range(NUM_ABILITIES):
		var button_vbox = button_container.get_child(i) as VBoxContainer
		if button_vbox:
			var icon_button = button_vbox.get_node("IconButton") as TextureButton
			var name_label = button_vbox.get_node("NameLabel") as Label
			_ability_buttons.append({
				"container": button_vbox,
				"icon": icon_button,
				"label": name_label,
				"index": i
			})
			# Connect button press
			icon_button.pressed.connect(_on_ability_pressed.bind(i))
			# Connect hover events (Task 4.3: Tooltips)
			icon_button.mouse_entered.connect(_on_button_hover_start.bind(i))
			icon_button.mouse_exited.connect(_on_button_hover_end.bind(i))
			print("[AbilityBar] Button %d setup complete" % i)

func _connect_signals() -> void:
	## Connect to CombatManager signals
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.ability_executed.connect(_on_ability_executed)
	CombatManager.ability_targeting_started.connect(_on_targeting_started)
	CombatManager.ability_targeting_cancelled.connect(_on_targeting_cancelled)
	print("[AbilityBar] Connected to CombatManager signals")

func _setup_panel_style() -> void:
	## Configure panel background style
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_BG_COLOR
	style.bg_color.a = PANEL_BG_OPACITY
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

# ===== PUBLIC API =====
func show_for_unit(unit: Unit) -> void:
	## Show ability bar for the specified unit
	if not unit or unit.is_enemy:
		hide_bar()
		return

	_current_unit = unit
	_abilities = unit.get_abilities()
	_populate_buttons()
	_show_bar()
	print("[AbilityBar] Showing for %s with %d abilities" % [unit.unit_name, _abilities.size()])

func hide_bar() -> void:
	## Hide the ability bar
	if not visible:
		return

	# Cancel any running fade tween
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_callback(func():
		visible = false
		_current_unit = null
	)

func refresh() -> void:
	## Refresh availability states without repopulating
	if _current_unit:
		_update_availability_states()

# ===== INTERNAL METHODS =====
func _show_bar() -> void:
	## Animate bar appearing
	# Cancel any running fade tween
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	visible = true
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func _populate_buttons() -> void:
	## Fill ability buttons with unit's ability data
	for i in range(NUM_ABILITIES):
		if i >= _ability_buttons.size():
			continue

		var button_data = _ability_buttons[i]
		var icon_button: TextureButton = button_data["icon"]
		var name_label: Label = button_data["label"]

		if i < _abilities.size():
			var ability = _abilities[i]
			# Set icon (placeholder or real)
			icon_button.texture_normal = _get_ability_icon(ability)
			icon_button.custom_minimum_size = ICON_SIZE
			name_label.text = ability.get("name", "???")

			# Set availability
			var is_available = _current_unit.is_ability_available(ability.get("id", ""))
			_set_button_availability(button_data, is_available)
		else:
			# Empty slot
			icon_button.texture_normal = _create_placeholder_icon()
			name_label.text = ""
			_set_button_availability(button_data, false)

func _get_ability_icon(ability: Dictionary) -> Texture2D:
	## Get icon texture for ability (placeholder for now)
	var icon_path = ability.get("icon", "")
	if icon_path and ResourceLoader.exists(icon_path):
		return load(icon_path)
	# Return placeholder icon
	return _create_placeholder_icon()

func _create_placeholder_icon() -> Texture2D:
	## Create a placeholder icon texture
	var image = Image.create(int(ICON_SIZE.x), int(ICON_SIZE.y), false, Image.FORMAT_RGBA8)

	# Fill with a darker background
	image.fill(Color(0.2, 0.2, 0.3, 1.0))

	# Draw a simple border
	for x in range(int(ICON_SIZE.x)):
		for y in range(int(ICON_SIZE.y)):
			var is_border = (x < 2 or x >= int(ICON_SIZE.x) - 2 or y < 2 or y >= int(ICON_SIZE.y) - 2)
			if is_border:
				image.set_pixel(x, y, Color(0.4, 0.4, 0.5, 1.0))

	return ImageTexture.create_from_image(image)

func _set_button_availability(button_data: Dictionary, is_available: bool) -> void:
	## Set visual state for available/unavailable
	var icon_button: TextureButton = button_data["icon"]
	var name_label: Label = button_data["label"]

	icon_button.disabled = not is_available
	icon_button.modulate = COLOR_AVAILABLE if is_available else COLOR_UNAVAILABLE
	name_label.add_theme_color_override("font_color",
		COLOR_NAME_AVAILABLE if is_available else COLOR_NAME_UNAVAILABLE)

func _update_availability_states() -> void:
	## Update availability without full repopulate
	for i in range(NUM_ABILITIES):
		if i >= _ability_buttons.size() or i >= _abilities.size():
			continue
		var ability = _abilities[i]
		var is_available = _current_unit.is_ability_available(ability.get("id", ""))
		_set_button_availability(_ability_buttons[i], is_available)

# ===== SIGNAL HANDLERS =====
func _on_unit_selected(unit: Unit) -> void:
	## Handle unit selection
	show_for_unit(unit)

func _on_unit_deselected(_unit: Unit) -> void:
	## Handle unit deselection
	hide_bar()

func _on_ability_pressed(index: int) -> void:
	## Handle ability button click
	if index >= _abilities.size():
		return

	# Hide tooltip immediately when clicking (Task 4.3)
	if _tooltip:
		_tooltip.cancel_hover()

	var ability = _abilities[index]
	var ability_id = ability.get("id", "")

	# Check availability
	if not _current_unit or not _current_unit.is_ability_available(ability_id):
		print("[AbilityBar] Ability %s is unavailable" % ability.get("name", ability_id))
		return

	print("[AbilityBar] Ability selected: %s (id: %s)" % [ability.get("name", ability_id), ability_id])
	ability_selected.emit(ability_id, ability)

	# Tell CombatManager to handle ability selection (Task 2.3)
	CombatManager.select_ability(ability_id)

func _on_ability_executed(_user: Unit, _ability_id: String, _result: Dictionary) -> void:
	## Refresh availability after ability use
	_clear_selection_highlight()
	_clear_target_highlights()
	_hide_attack_range_overlay()  # Task 2.7
	refresh()

func _on_targeting_started(ability_id: String, valid_targets: Array[Unit]) -> void:
	## Visual feedback that we're in targeting mode
	print("[AbilityBar] _on_targeting_started called: %s with %d targets" % [ability_id, valid_targets.size()])

	# Find and highlight the selected ability button
	for i in range(_abilities.size()):
		if _abilities[i].get("id", "") == ability_id:
			_selected_ability_index = i
			_highlight_selected_button(i)
			print("[AbilityBar] Highlighted button %d for %s" % [i, ability_id])
			break

	# Task 2.7: Show attack range overlay for ranged units
	if _current_unit and _current_unit.is_ranged_weapon and _current_unit.combat_grid:
		_current_unit.combat_grid.show_attack_range(_current_unit)

	# Highlight valid targets
	_highlight_valid_targets(valid_targets)
	print("[AbilityBar] Targeting mode: %s - click a RED highlighted enemy to attack!" % ability_id)

func _on_targeting_cancelled() -> void:
	## Reset visual state when targeting is cancelled
	_clear_selection_highlight()
	_clear_target_highlights()
	# Task 2.7: Hide attack range overlay
	_hide_attack_range_overlay()

func _highlight_selected_button(index: int) -> void:
	## Highlight the selected ability button
	if index < 0 or index >= _ability_buttons.size():
		return

	var button_data = _ability_buttons[index]
	var icon_button: TextureButton = button_data["icon"]

	# Apply golden highlight
	icon_button.modulate = COLOR_SELECTED

	# Also add a pulsing effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(icon_button, "modulate", COLOR_SELECTED * 1.2, 0.5)
	tween.tween_property(icon_button, "modulate", COLOR_SELECTED, 0.5)

	# Store tween reference for cleanup
	button_data["highlight_tween"] = tween

func _clear_selection_highlight() -> void:
	## Clear the selection highlight from all buttons
	_selected_ability_index = -1

	for button_data in _ability_buttons:
		# Kill any running highlight tween
		if button_data.has("highlight_tween"):
			var tween = button_data["highlight_tween"]
			if tween and tween.is_running():
				tween.kill()
			button_data.erase("highlight_tween")

	# Refresh availability to restore proper colors
	_update_availability_states()

func _highlight_valid_targets(targets: Array[Unit]) -> void:
	## Highlight valid target units with pulsing red effect on SPRITE only
	## (not the whole unit, to avoid affecting health bars)
	for target in targets:
		if is_instance_valid(target):
			print("[AbilityBar] Highlighting target: %s" % target.unit_name)

			# Get the sprite child node
			var sprite = target.get_node_or_null("Sprite2D")
			if not sprite:
				continue

			# Store original modulate for restoration
			if not sprite.has_meta("original_modulate"):
				sprite.set_meta("original_modulate", sprite.modulate)

			# Add a red tint to indicate valid target
			sprite.modulate = COLOR_TARGETING_BORDER

			# Add pulsing effect to make it more noticeable
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(sprite, "modulate", Color(1.5, 0.3, 0.3, 1.0), 0.4)
			tween.tween_property(sprite, "modulate", COLOR_TARGETING_BORDER, 0.4)
			sprite.set_meta("highlight_tween", tween)

func _clear_target_highlights() -> void:
	## Clear highlights from all unit sprites
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		var sprite = unit.get_node_or_null("Sprite2D")
		if not sprite:
			continue

		# Stop any pulsing tween
		if sprite.has_meta("highlight_tween"):
			var tween = sprite.get_meta("highlight_tween")
			if tween and tween.is_running():
				tween.kill()
			sprite.remove_meta("highlight_tween")

		# Restore original color
		if sprite.has_meta("original_modulate"):
			sprite.modulate = sprite.get_meta("original_modulate")
			sprite.remove_meta("original_modulate")
		else:
			sprite.modulate = Color.WHITE

func _hide_attack_range_overlay() -> void:
	## Hide attack range overlay from combat grid (Task 2.7)
	if _current_unit and _current_unit.combat_grid:
		_current_unit.combat_grid.hide_attack_range()

# ===== TOOLTIP METHODS (Task 4.3) =====
func _setup_tooltip() -> void:
	## Create and configure the ability tooltip
	_tooltip = AbilityTooltipScene.instantiate()
	# Add to CanvasLayer or root to ensure it appears above everything
	get_tree().root.add_child.call_deferred(_tooltip)

func _on_button_hover_start(index: int) -> void:
	## Handle mouse entering ability button
	if index >= _abilities.size():
		return

	_hovered_button_index = index
	var ability = _abilities[index]

	# Get button position for tooltip placement
	var button_data = _ability_buttons[index]
	var icon_button: TextureButton = button_data["icon"]
	var button_rect = icon_button.get_global_rect()

	# Position tooltip above the button
	var tooltip_pos = Vector2(
		button_rect.position.x + button_rect.size.x / 2 - 125,  # Center the 250px tooltip
		button_rect.position.y - 10  # Above button
	)

	# Prepare and show tooltip
	if _tooltip and _current_unit:
		_tooltip.prepare_tooltip(ability, _current_unit)
		_tooltip.position = tooltip_pos

	# Emit signal
	ability_hover_started.emit(index, ability)

func _on_button_hover_end(index: int) -> void:
	## Handle mouse leaving ability button
	_hovered_button_index = -1

	# Hide tooltip
	if _tooltip:
		_tooltip.cancel_hover()

	# Emit signal
	ability_hover_ended.emit(index)
