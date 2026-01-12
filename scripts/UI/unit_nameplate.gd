## UnitNameplate - Floating nameplate above a unit showing name, HP, and status
## Part of: Blood & Gold Prototype
## Spec: docs/features/4.3-combat-ui-polish.md
class_name UnitNameplate
extends Control

# ===== CONSTANTS =====
const HP_BAR_WIDTH: int = 60
const HP_BAR_HEIGHT: int = 6
const STATUS_ICON_SIZE: int = 16
const STATUS_ICON_SPACING: int = 2
const FADE_DURATION: float = 0.3

# HP bar colors by faction
const COLOR_HP_PARTY: Color = Color("#3498db")      # Blue
const COLOR_HP_ENEMY: Color = Color("#e74c3c")      # Red
const COLOR_HP_SOLDIER: Color = Color("#27ae60")    # Green
const COLOR_HP_LOW: Color = Color("#e67e22")        # Orange
const COLOR_HP_BACKGROUND: Color = Color("#2c3e50") # Dark
const LOW_HP_THRESHOLD: float = 0.25

# Text colors
const COLOR_TEXT_PARTY: Color = Color("#f1c40f")    # Gold
const COLOR_TEXT_ENEMY: Color = Color("#ffffff")    # White
const COLOR_TEXT_SOLDIER: Color = Color("#ffffff")  # White

# ===== NODE REFERENCES =====
@onready var name_label: Label = $VBoxContainer/NameContainer/NameLabel
@onready var class_label: Label = $VBoxContainer/NameContainer/ClassLabel
@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar
@onready var status_container: HBoxContainer = $VBoxContainer/StatusContainer

# ===== STATE =====
var attached_unit: Unit = null

# ===== LIFECYCLE =====
func _ready() -> void:
	# Initial setup
	modulate.a = 0.0
	_setup_hp_bar_style()

func _process(_delta: float) -> void:
	# Follow attached unit
	if attached_unit and is_instance_valid(attached_unit):
		_update_position()

# ===== PUBLIC API =====
func setup(unit: Unit) -> void:
	## Initialize nameplate for a unit
	attached_unit = unit

	# Set name and class
	name_label.text = _truncate_name(unit.unit_name, 15)
	class_label.text = _get_class_abbreviation(unit)

	# Set colors based on faction
	_apply_faction_colors()

	# Initialize HP bar
	_update_hp_bar()

	# Update status icons
	_update_status_icons()

	# Connect to unit signals
	if not unit.unit_damaged.is_connected(_on_unit_damaged):
		unit.unit_damaged.connect(_on_unit_damaged)
	if not unit.unit_died.is_connected(_on_unit_died):
		unit.unit_died.connect(_on_unit_died)

	# Position above unit
	_update_position()

	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

	print("[UnitNameplate] Setup for %s" % unit.unit_name)

func update_hp() -> void:
	## Update HP bar display
	_update_hp_bar()

func update_status() -> void:
	## Refresh status effect icons
	_update_status_icons()

# ===== INTERNAL METHODS =====
func _update_position() -> void:
	## Position nameplate above unit
	if not attached_unit:
		return

	# Position centered above the unit sprite
	global_position = attached_unit.global_position + Vector2(-size.x / 2, -70)

func _update_hp_bar() -> void:
	## Update HP bar value and color
	if not attached_unit:
		return

	hp_bar.max_value = attached_unit.max_hp
	hp_bar.value = attached_unit.current_hp

	# Update color based on HP percentage
	var hp_percent = attached_unit.get_hp_percentage()
	_update_hp_bar_fill_color(hp_percent)

func _update_hp_bar_fill_color(hp_percent: float) -> void:
	## Update HP bar fill color based on HP and faction
	var fill_style = StyleBoxFlat.new()

	# Use low HP color if below threshold
	if hp_percent <= LOW_HP_THRESHOLD:
		fill_style.bg_color = COLOR_HP_LOW
	elif attached_unit.is_enemy:
		fill_style.bg_color = COLOR_HP_ENEMY
	elif attached_unit.is_soldier:
		fill_style.bg_color = COLOR_HP_SOLDIER
	else:
		fill_style.bg_color = COLOR_HP_PARTY

	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", fill_style)

func _setup_hp_bar_style() -> void:
	## Configure HP bar background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = COLOR_HP_BACKGROUND
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = 2
	bg_style.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", bg_style)

func _apply_faction_colors() -> void:
	## Apply text colors based on faction
	var text_color: Color
	if attached_unit.is_enemy:
		text_color = COLOR_TEXT_ENEMY
	elif attached_unit.is_soldier:
		text_color = COLOR_TEXT_SOLDIER
	else:
		text_color = COLOR_TEXT_PARTY

	name_label.add_theme_color_override("font_color", text_color)
	class_label.add_theme_color_override("font_color", text_color.darkened(0.2))

func _update_status_icons() -> void:
	## Refresh status effect icons
	# Clear existing icons
	for child in status_container.get_children():
		child.queue_free()

	if not attached_unit:
		return

	# Get status effects from StatusEffectManager
	var effects = attached_unit.get_all_status_effects()

	for effect in effects:
		var icon = _create_status_icon(effect)
		if icon:
			status_container.add_child(icon)

func _create_status_icon(effect: Dictionary) -> TextureRect:
	## Create a status icon for an effect
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(STATUS_ICON_SIZE, STATUS_ICON_SIZE)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Create colored placeholder icon based on effect type
	var image = Image.create(STATUS_ICON_SIZE, STATUS_ICON_SIZE, false, Image.FORMAT_RGBA8)
	var color = _get_status_color(effect.get("type", ""))

	# Draw circle
	var center = Vector2(STATUS_ICON_SIZE / 2, STATUS_ICON_SIZE / 2)
	var radius = STATUS_ICON_SIZE / 2 - 1
	for x in range(STATUS_ICON_SIZE):
		for y in range(STATUS_ICON_SIZE):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				image.set_pixel(x, y, color)

	icon.texture = ImageTexture.create_from_image(image)

	# Set tooltip
	icon.tooltip_text = "%s (%d)" % [effect.get("type", "Unknown"), effect.get("duration", 0)]

	return icon

func _get_status_color(effect_type: String) -> Color:
	## Get color for status effect type
	match effect_type:
		"ATTACK_BUFF", "BLESSED":
			return Color("#27ae60")  # Green - buff
		"TAUNTED":
			return Color("#e74c3c")  # Red - debuff
		"STUNNED":
			return Color("#9b59b6")  # Purple - control
		"LAST_STAND":
			return Color("#f1c40f")  # Gold - special
		"POISON_BLADE":
			return Color("#16a085")  # Teal - self buff
		_:
			return Color("#95a5a6")  # Gray - unknown

func _truncate_name(name: String, max_length: int) -> String:
	## Truncate name with ellipsis if too long
	if name.length() > max_length:
		return name.substr(0, max_length - 3) + "..."
	return name

func _get_class_abbreviation(unit: Unit) -> String:
	## Get short class/role indicator
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return "Leader"
		Unit.UnitType.THORNE:
			return "Fighter"
		Unit.UnitType.LYRA:
			return "Rogue"
		Unit.UnitType.MATTHIAS:
			return "Cleric"
		Unit.UnitType.INFANTRY:
			return "Infantry"
		Unit.UnitType.ARCHER:
			return "Archer"
		Unit.UnitType.ENEMY:
			return "Enemy"
		_:
			return ""

# ===== SIGNAL HANDLERS =====
func _on_unit_damaged(_unit: Unit, _amount: int) -> void:
	## Handle unit damage
	_update_hp_bar()

	# Flash effect
	var tween = create_tween()
	tween.tween_property(hp_bar, "modulate", Color.RED, 0.1)
	tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.1)

func _on_unit_died(_unit: Unit) -> void:
	## Handle unit death - fade out and remove
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(queue_free)
