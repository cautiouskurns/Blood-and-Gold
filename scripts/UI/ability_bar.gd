## AbilityBar - Displays 4 ability buttons for selected unit
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.2-ability-ui-panel.md
class_name AbilityBar
extends Control

# ===== SIGNALS =====
signal ability_selected(ability_id: String, ability_data: Dictionary)

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.15
const NUM_ABILITIES: int = 4
const ICON_SIZE: Vector2 = Vector2(48, 48)

# Panel styling
const PANEL_BG_COLOR: Color = Color("#1a1a2e")
const PANEL_BG_OPACITY: float = 0.9

# Unavailable state visuals
const COLOR_AVAILABLE: Color = Color.WHITE
const COLOR_UNAVAILABLE: Color = Color(0.4, 0.4, 0.4, 1.0)
const COLOR_NAME_AVAILABLE: Color = Color.WHITE
const COLOR_NAME_UNAVAILABLE: Color = Color(0.4, 0.4, 0.4, 1.0)

# ===== NODE REFERENCES =====
@onready var panel: PanelContainer = $PanelContainer
@onready var button_container: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer

# Array of ability button references
var _ability_buttons: Array[Dictionary] = []

# ===== INTERNAL STATE =====
var _current_unit: Unit = null
var _abilities: Array[Dictionary] = []
var _fade_tween: Tween = null

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false
	modulate.a = 0.0
	_setup_button_references()
	_connect_signals()
	_setup_panel_style()
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
			print("[AbilityBar] Button %d setup complete" % i)

func _connect_signals() -> void:
	## Connect to CombatManager signals
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
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

	var ability = _abilities[index]
	var ability_id = ability.get("id", "")

	# Check availability
	if not _current_unit or not _current_unit.is_ability_available(ability_id):
		print("[AbilityBar] Ability %s is unavailable" % ability.get("name", ability_id))
		return

	print("[AbilityBar] Ability selected: %s (id: %s)" % [ability.get("name", ability_id), ability_id])
	ability_selected.emit(ability_id, ability)
