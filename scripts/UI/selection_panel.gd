## SelectionPanel - Right-side panel showing detailed unit information
## Part of: Blood & Gold Prototype
## Spec: docs/features/4.3-combat-ui-polish.md
class_name SelectionPanel
extends PanelContainer

# ===== CONSTANTS =====
const SLIDE_DURATION: float = 0.2
const PANEL_WIDTH: float = 220.0
const HIDDEN_OFFSET: float = 240.0

# Colors
const COLOR_PANEL_BG: Color = Color("#1a1a2e")
const COLOR_BORDER: Color = Color("#f1c40f")
const COLOR_STAT_LABEL: Color = Color("#bdc3c7")
const COLOR_STAT_VALUE: Color = Color("#ffffff")
const COLOR_HP_HEALTHY: Color = Color("#27ae60")
const COLOR_HP_LOW: Color = Color("#e74c3c")
const COLOR_SECTION_HEADER: Color = Color("#f1c40f")

# ===== NODE REFERENCES =====
@onready var portrait_rect: TextureRect = $MarginContainer/VBoxContainer/PortraitSection/Portrait
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameSection/UnitName
@onready var class_label: Label = $MarginContainer/VBoxContainer/NameSection/ClassLabel
@onready var hp_label: Label = $MarginContainer/VBoxContainer/StatsSection/HPRow/HPValue
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/StatsSection/HPBar
@onready var stats_grid: GridContainer = $MarginContainer/VBoxContainer/StatsSection/StatsGrid
@onready var combat_stats_container: HBoxContainer = $MarginContainer/VBoxContainer/CombatStatsSection
@onready var abilities_container: VBoxContainer = $MarginContainer/VBoxContainer/AbilitiesSection/AbilitiesContainer
@onready var status_container: VBoxContainer = $MarginContainer/VBoxContainer/StatusSection/StatusContainer

# ===== STATE =====
var current_unit: Unit = null
var _is_visible: bool = false
var _slide_tween: Tween = null

# ===== LIFECYCLE =====
func _ready() -> void:
	# Start hidden off-screen
	position.x = HIDDEN_OFFSET
	modulate.a = 0.0
	visible = false

	_setup_panel_style()
	_connect_signals()
	print("[SelectionPanel] Initialized")

func _setup_panel_style() -> void:
	## Configure panel background and border
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_BG
	style.bg_color.a = 0.95
	style.border_color = COLOR_BORDER
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)

func _connect_signals() -> void:
	## Connect to CombatManager signals
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.ability_executed.connect(_on_ability_executed)

# ===== PUBLIC API =====
func show_unit(unit: Unit) -> void:
	## Display detailed information for a unit
	if not unit:
		hide_panel()
		return

	current_unit = unit

	# Update display
	_update_portrait(unit)
	_update_name_section(unit)
	_update_hp_section(unit)
	_update_stats_section(unit)
	_update_combat_stats(unit)
	_update_abilities_section(unit)
	_update_status_section(unit)

	# Show panel if hidden
	if not _is_visible:
		_slide_in()

	print("[SelectionPanel] Showing unit: %s" % unit.unit_name)

func hide_panel() -> void:
	## Hide the selection panel
	if _is_visible:
		_slide_out()
	current_unit = null

func refresh() -> void:
	## Refresh display for current unit
	if current_unit and is_instance_valid(current_unit):
		show_unit(current_unit)

# ===== DISPLAY UPDATE METHODS =====
func _update_portrait(unit: Unit) -> void:
	## Update portrait display
	# Generate placeholder portrait based on unit type
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)

	var color = _get_unit_color(unit)
	image.fill(color)

	# Draw border
	for x in range(64):
		for y in range(64):
			var is_border = (x < 3 or x >= 61 or y < 3 or y >= 61)
			if is_border:
				image.set_pixel(x, y, color.darkened(0.3))

	# Draw letter in center
	portrait_rect.texture = ImageTexture.create_from_image(image)

func _update_name_section(unit: Unit) -> void:
	## Update name and class display
	name_label.text = unit.unit_name.to_upper()
	class_label.text = _get_unit_class_string(unit)

	# Color based on faction
	if unit.is_enemy:
		name_label.add_theme_color_override("font_color", Color("#e74c3c"))
	else:
		name_label.add_theme_color_override("font_color", COLOR_SECTION_HEADER)

func _update_hp_section(unit: Unit) -> void:
	## Update HP display
	hp_label.text = "%d / %d" % [unit.current_hp, unit.max_hp]
	hp_bar.max_value = unit.max_hp
	hp_bar.value = unit.current_hp

	# Color based on HP percentage
	var hp_percent = unit.get_hp_percentage()
	var hp_color = COLOR_HP_LOW if hp_percent <= 0.25 else COLOR_HP_HEALTHY
	hp_label.add_theme_color_override("font_color", hp_color)

	# Style HP bar fill
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = hp_color
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", fill_style)

func _update_stats_section(unit: Unit) -> void:
	## Update core stats display
	# Clear existing stat rows
	for child in stats_grid.get_children():
		child.queue_free()

	# Add stat rows (hide some stats for enemies)
	if not unit.is_enemy:
		_add_stat_row("STR", "%d (%+d)" % [unit.strength, unit.get_str_mod()])
		_add_stat_row("DEX", "%d (%+d)" % [unit.dexterity, unit.get_dex_mod()])
		_add_stat_row("CON", "%d (%+d)" % [unit.constitution, unit.get_con_mod()])
		_add_stat_row("WIS", "%d (%+d)" % [unit.wisdom, unit.get_wis_mod()])
	else:
		# Show limited info for enemies
		_add_stat_row("STR", "???")
		_add_stat_row("DEX", "???")
		_add_stat_row("CON", "???")
		_add_stat_row("WIS", "???")

func _add_stat_row(stat_name: String, stat_value: String) -> void:
	## Add a stat row to the stats grid
	var name_lbl = Label.new()
	name_lbl.text = stat_name + ":"
	name_lbl.add_theme_color_override("font_color", COLOR_STAT_LABEL)
	name_lbl.add_theme_font_size_override("font_size", 11)
	stats_grid.add_child(name_lbl)

	var value_lbl = Label.new()
	value_lbl.text = stat_value
	value_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)
	value_lbl.add_theme_font_size_override("font_size", 11)
	stats_grid.add_child(value_lbl)

func _update_combat_stats(unit: Unit) -> void:
	## Update attack, defense, movement display
	# Clear existing
	for child in combat_stats_container.get_children():
		child.queue_free()

	# Attack
	var attack_lbl = Label.new()
	if not unit.is_enemy:
		attack_lbl.text = "ATK: %+d" % unit.get_attack_bonus()
	else:
		attack_lbl.text = "ATK: ???"
	attack_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)
	attack_lbl.add_theme_font_size_override("font_size", 11)
	combat_stats_container.add_child(attack_lbl)

	# Defense
	var def_lbl = Label.new()
	def_lbl.text = "DEF: %d" % unit.get_defense()
	def_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)
	def_lbl.add_theme_font_size_override("font_size", 11)
	combat_stats_container.add_child(def_lbl)

	# Movement
	var move_lbl = Label.new()
	move_lbl.text = "MOV: %d" % unit.movement_range
	move_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)
	move_lbl.add_theme_font_size_override("font_size", 11)
	combat_stats_container.add_child(move_lbl)

func _update_abilities_section(unit: Unit) -> void:
	## Update abilities list
	# Clear existing
	for child in abilities_container.get_children():
		child.queue_free()

	if unit.is_enemy:
		var no_info = Label.new()
		no_info.text = "Unknown abilities"
		no_info.add_theme_color_override("font_color", COLOR_STAT_LABEL)
		no_info.add_theme_font_size_override("font_size", 10)
		abilities_container.add_child(no_info)
		return

	var abilities = unit.get_abilities()
	for ability_data in abilities:
		var ability_id = ability_data.get("id", "")
		if ability_id.is_empty() or ability_id.begins_with("none"):
			continue

		var ability_row = HBoxContainer.new()
		ability_row.add_theme_constant_override("separation", 8)

		# Ability name
		var name_lbl = Label.new()
		name_lbl.text = ability_data.get("name", "???")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 10)

		# Check availability
		var is_available = unit.is_ability_available(ability_id)
		if is_available:
			name_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)
		else:
			name_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

		ability_row.add_child(name_lbl)

		# Uses indicator
		var ability_res = unit.get_ability_resource(ability_id)
		if ability_res and ability_res.uses_per_battle > 0:
			var uses_remaining = ability_res.uses_per_battle - unit.get_ability_uses(ability_id)
			var uses_lbl = Label.new()
			uses_lbl.text = "%d/%d" % [uses_remaining, ability_res.uses_per_battle]
			uses_lbl.add_theme_font_size_override("font_size", 9)
			if uses_remaining > 0:
				uses_lbl.add_theme_color_override("font_color", COLOR_HP_HEALTHY)
			else:
				uses_lbl.add_theme_color_override("font_color", COLOR_HP_LOW)
			ability_row.add_child(uses_lbl)

		abilities_container.add_child(ability_row)

func _update_status_section(unit: Unit) -> void:
	## Update status effects list
	# Clear existing
	for child in status_container.get_children():
		child.queue_free()

	var effects = unit.get_all_status_effects()

	if effects.is_empty():
		var no_effects = Label.new()
		no_effects.text = "No active effects"
		no_effects.add_theme_color_override("font_color", COLOR_STAT_LABEL)
		no_effects.add_theme_font_size_override("font_size", 10)
		status_container.add_child(no_effects)
		return

	for effect in effects:
		var effect_row = HBoxContainer.new()

		# Effect name
		var name_lbl = Label.new()
		name_lbl.text = effect.get("type", "Unknown")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 10)

		# Color based on buff/debuff
		var effect_type = effect.get("type", "")
		if effect_type in ["ATTACK_BUFF", "BLESSED", "POISON_BLADE", "LAST_STAND"]:
			name_lbl.add_theme_color_override("font_color", COLOR_HP_HEALTHY)
		elif effect_type in ["TAUNTED", "STUNNED"]:
			name_lbl.add_theme_color_override("font_color", COLOR_HP_LOW)
		else:
			name_lbl.add_theme_color_override("font_color", COLOR_STAT_VALUE)

		effect_row.add_child(name_lbl)

		# Duration
		var duration = effect.get("duration", 0)
		if duration > 0:
			var dur_lbl = Label.new()
			dur_lbl.text = "%d turns" % duration
			dur_lbl.add_theme_font_size_override("font_size", 9)
			dur_lbl.add_theme_color_override("font_color", COLOR_STAT_LABEL)
			effect_row.add_child(dur_lbl)

		status_container.add_child(effect_row)

# ===== ANIMATION METHODS =====
func _slide_in() -> void:
	## Animate panel sliding in from right
	_is_visible = true
	visible = true

	if _slide_tween and _slide_tween.is_running():
		_slide_tween.kill()

	_slide_tween = create_tween()
	_slide_tween.set_parallel(true)
	_slide_tween.tween_property(self, "position:x", 0.0, SLIDE_DURATION).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(self, "modulate:a", 1.0, SLIDE_DURATION)

func _slide_out() -> void:
	## Animate panel sliding out to right
	_is_visible = false

	if _slide_tween and _slide_tween.is_running():
		_slide_tween.kill()

	_slide_tween = create_tween()
	_slide_tween.set_parallel(true)
	_slide_tween.tween_property(self, "position:x", HIDDEN_OFFSET, SLIDE_DURATION).set_ease(Tween.EASE_IN)
	_slide_tween.tween_property(self, "modulate:a", 0.0, SLIDE_DURATION)
	_slide_tween.chain().tween_callback(func(): visible = false)

# ===== HELPER METHODS =====
func _get_unit_color(unit: Unit) -> Color:
	## Get color for unit type
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return Color("#3498db")
		Unit.UnitType.THORNE:
			return Color("#2980b9")
		Unit.UnitType.LYRA:
			return Color("#9b59b6")
		Unit.UnitType.MATTHIAS:
			return Color("#f39c12")
		Unit.UnitType.INFANTRY:
			return Color("#1abc9c")
		Unit.UnitType.ARCHER:
			return Color("#16a085")
		Unit.UnitType.ENEMY:
			return Color("#e74c3c")
		_:
			return Color("#95a5a6")

func _get_unit_class_string(unit: Unit) -> String:
	## Get class/role string for unit
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return "Mercenary Leader"
		Unit.UnitType.THORNE:
			return "Fighter - Heavy Melee"
		Unit.UnitType.LYRA:
			return "Rogue - Assassin"
		Unit.UnitType.MATTHIAS:
			return "Cleric - Healer"
		Unit.UnitType.INFANTRY:
			return "Soldier - Infantry"
		Unit.UnitType.ARCHER:
			return "Soldier - Archer"
		Unit.UnitType.ENEMY:
			return "Hostile"
		_:
			return "Unknown"

# ===== SIGNAL HANDLERS =====
func _on_unit_selected(unit: Unit) -> void:
	## Handle unit selection
	show_unit(unit)

func _on_unit_deselected(_unit: Unit) -> void:
	## Handle unit deselection
	hide_panel()

func _on_ability_executed(_user: Unit, _ability_id: String, _result: Dictionary) -> void:
	## Refresh after ability use
	refresh()
