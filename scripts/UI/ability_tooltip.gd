## AbilityTooltip - Tooltip showing detailed ability information
## Part of: Blood & Gold Prototype
## Spec: docs/features/4.3-combat-ui-polish.md
class_name AbilityTooltip
extends PanelContainer

# ===== CONSTANTS =====
const TOOLTIP_WIDTH: float = 250.0
const FADE_DURATION: float = 0.15
const HOVER_DELAY: float = 0.3

# Colors
const COLOR_BG: Color = Color("#0d0d1a")
const COLOR_BORDER: Color = Color("#f1c40f")
const COLOR_TITLE: Color = Color("#f1c40f")
const COLOR_DESCRIPTION: Color = Color("#ffffff")
const COLOR_STAT: Color = Color("#bdc3c7")
const COLOR_WARNING: Color = Color("#e67e22")
const COLOR_AVAILABLE: Color = Color("#27ae60")
const COLOR_UNAVAILABLE: Color = Color("#e74c3c")

# ===== NODE REFERENCES =====
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var description_label: RichTextLabel = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var stats_container: VBoxContainer = $MarginContainer/VBoxContainer/StatsContainer
@onready var uses_label: Label = $MarginContainer/VBoxContainer/UsesContainer/UsesLabel
@onready var warnings_container: VBoxContainer = $MarginContainer/VBoxContainer/WarningsContainer

# ===== STATE =====
var _hover_timer: float = 0.0
var _is_hovering: bool = false
var _pending_ability: Dictionary = {}
var _pending_unit: Unit = null
var _fade_tween: Tween = null

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_style()

func _process(delta: float) -> void:
	if _is_hovering and not visible:
		_hover_timer += delta
		if _hover_timer >= HOVER_DELAY:
			_show_tooltip()

func _setup_style() -> void:
	## Configure tooltip visual style
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.bg_color.a = 0.95
	style.border_color = COLOR_BORDER
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 4
	add_theme_stylebox_override("panel", style)

# ===== PUBLIC API =====
func prepare_tooltip(ability_data: Dictionary, unit: Unit) -> void:
	## Prepare tooltip content (called on hover start)
	_pending_ability = ability_data
	_pending_unit = unit
	_is_hovering = true
	_hover_timer = 0.0

func cancel_hover() -> void:
	## Cancel hover (called on hover end)
	_is_hovering = false
	_hover_timer = 0.0
	_pending_ability = {}
	_pending_unit = null
	_hide_tooltip()

func show_immediately(ability_data: Dictionary, unit: Unit, at_position: Vector2) -> void:
	## Show tooltip immediately without delay
	_pending_ability = ability_data
	_pending_unit = unit
	position = _clamp_to_screen(at_position)
	_populate_content()
	_show_tooltip()

func hide_tooltip() -> void:
	## Public hide method
	_hide_tooltip()

# ===== INTERNAL METHODS =====
func _show_tooltip() -> void:
	## Show the tooltip with fade in
	if _pending_ability.is_empty():
		return

	_populate_content()
	visible = true

	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func _hide_tooltip() -> void:
	## Hide the tooltip with fade out
	if not visible:
		return

	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_callback(func(): visible = false)

func _populate_content() -> void:
	## Fill tooltip with ability information
	var ability_id = _pending_ability.get("id", "")
	var ability_name = _pending_ability.get("name", "Unknown")

	# Title
	title_label.text = ability_name.to_upper()
	title_label.add_theme_color_override("font_color", COLOR_TITLE)

	# Load ability resource for detailed info
	var ability_res: Resource = null
	if _pending_unit:
		ability_res = _pending_unit.get_ability_resource(ability_id)

	# Description
	if ability_res:
		description_label.text = ability_res.description
	else:
		description_label.text = "No description available."
	description_label.add_theme_color_override("default_color", COLOR_DESCRIPTION)

	# Stats
	_populate_stats(ability_res)

	# Uses remaining
	_populate_uses(ability_id, ability_res)

	# Warnings
	_populate_warnings(ability_res)

func _populate_stats(ability_res: Resource) -> void:
	## Populate ability stats section
	# Clear existing
	for child in stats_container.get_children():
		child.queue_free()

	if not ability_res:
		return

	# Damage info
	if ability_res.ability_type in [
		Ability.AbilityType.MELEE_ATTACK,
		Ability.AbilityType.BACKSTAB,
		Ability.AbilityType.RANGED_ATTACK,
		Ability.AbilityType.ARC_ATTACK
	]:
		var damage_text = "Normal attack"
		if ability_res.damage_multiplier != 1.0:
			damage_text = "%.0f%% damage" % (ability_res.damage_multiplier * 100)
		if ability_res.bonus_damage > 0:
			damage_text += " +%d" % ability_res.bonus_damage
		if ability_res.attack_modifier != 0:
			damage_text += " (%+d to hit)" % ability_res.attack_modifier
		_add_stat("Damage", damage_text)

	# Range
	if ability_res.ability_range > 0:
		if ability_res.ability_range == 1:
			_add_stat("Range", "Adjacent (1 tile)")
		else:
			_add_stat("Range", "%d tiles" % ability_res.ability_range)

	# Arc
	if ability_res.ability_type == Ability.AbilityType.ARC_ATTACK:
		_add_stat("Arc", "%d degrees" % ability_res.arc_angle)
		_add_stat("Max Targets", "%d" % ability_res.max_targets)

	# Backstab multiplier
	if ability_res.requires_behind and ability_res.backstab_multiplier > 1.0:
		_add_stat("Backstab", "%.0fx damage from behind" % ability_res.backstab_multiplier)

	# Status effect
	if ability_res.applies_status and ability_res.applies_status != "":
		_add_stat("Applies", ability_res.applies_status)
		if ability_res.status_duration > 0:
			_add_stat("Duration", "%d turns" % ability_res.status_duration)
		if ability_res.status_value > 0:
			if ability_res.applies_status == "POISON_BLADE":
				_add_stat("Charges", "%d attacks" % ability_res.status_value)
			else:
				_add_stat("Value", "+%d" % ability_res.status_value)

	# Teleport range
	if ability_res.ability_type == Ability.AbilityType.TELEPORT:
		_add_stat("Teleport", "%d tile range" % ability_res.ability_range)

	# Heal amount
	if ability_res.ability_type == Ability.AbilityType.ALLY_HEAL:
		_add_stat("Healing", "%dd%d" % [ability_res.heal_dice_count, ability_res.heal_dice_size])

func _add_stat(stat_name: String, stat_value: String) -> void:
	## Add a stat row
	var row = HBoxContainer.new()

	var name_lbl = Label.new()
	name_lbl.text = stat_name + ":"
	name_lbl.add_theme_color_override("font_color", COLOR_STAT)
	name_lbl.add_theme_font_size_override("font_size", 11)
	row.add_child(name_lbl)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var value_lbl = Label.new()
	value_lbl.text = stat_value
	value_lbl.add_theme_color_override("font_color", COLOR_DESCRIPTION)
	value_lbl.add_theme_font_size_override("font_size", 11)
	row.add_child(value_lbl)

	stats_container.add_child(row)

func _populate_uses(ability_id: String, ability_res: Resource) -> void:
	## Populate uses remaining
	if not ability_res or ability_res.uses_per_battle <= 0:
		uses_label.text = "Unlimited uses"
		uses_label.add_theme_color_override("font_color", COLOR_STAT)
		return

	var uses_remaining = ability_res.uses_per_battle
	if _pending_unit:
		uses_remaining = ability_res.uses_per_battle - _pending_unit.get_ability_uses(ability_id)

	uses_label.text = "Uses: %d/%d per battle" % [uses_remaining, ability_res.uses_per_battle]

	if uses_remaining > 0:
		uses_label.add_theme_color_override("font_color", COLOR_AVAILABLE)
	else:
		uses_label.add_theme_color_override("font_color", COLOR_UNAVAILABLE)

func _populate_warnings(ability_res: Resource) -> void:
	## Populate warning messages
	# Clear existing
	for child in warnings_container.get_children():
		child.queue_free()

	if not ability_res:
		return

	if ability_res.ends_turn:
		_add_warning("Ends turn")

	if ability_res.requires_behind:
		_add_warning("Requires attacking from behind")

	if ability_res.targets_soldiers_only:
		_add_warning("Targets soldiers only")

func _add_warning(warning_text: String) -> void:
	## Add a warning label
	var warning = Label.new()
	warning.text = "! " + warning_text
	warning.add_theme_color_override("font_color", COLOR_WARNING)
	warning.add_theme_font_size_override("font_size", 10)
	warnings_container.add_child(warning)

func _clamp_to_screen(pos: Vector2) -> Vector2:
	## Ensure tooltip stays within screen bounds
	var viewport_size = get_viewport_rect().size

	# Use current size or estimate (250x180 is typical tooltip size)
	var tooltip_size = size if size.x > 0 else Vector2(TOOLTIP_WIDTH, 180)

	# Clamp position
	var clamped = pos

	# Right edge
	if clamped.x + tooltip_size.x > viewport_size.x - 10:
		clamped.x = viewport_size.x - tooltip_size.x - 10

	# Bottom edge
	if clamped.y + tooltip_size.y > viewport_size.y - 10:
		clamped.y = pos.y - tooltip_size.y - 10  # Show above instead

	# Left edge
	clamped.x = max(10, clamped.x)

	# Top edge
	clamped.y = max(10, clamped.y)

	return clamped

# ===== STATIC POSITIONING =====
func position_above(global_pos: Vector2, offset_amount: float = 10.0) -> void:
	## Position tooltip above a point
	var tooltip_size = size if size.x > 0 else Vector2(TOOLTIP_WIDTH, 180)
	position = _clamp_to_screen(Vector2(global_pos.x - tooltip_size.x / 2, global_pos.y - tooltip_size.y - offset_amount))
