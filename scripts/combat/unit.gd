## Unit - Base class for all combat units (party, soldiers, enemies)
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.2-unit-placeholder-sprites.md
class_name Unit
extends Node2D

# ===== SIGNALS =====
signal unit_clicked(unit: Unit)
signal unit_moved(unit: Unit, from: Vector2i, to: Vector2i)
signal unit_damaged(unit: Unit, amount: int)
signal unit_died(unit: Unit)
signal movement_started(unit: Unit)
signal movement_finished(unit: Unit)
signal attack_initiated(attacker: Unit, target: Unit)
signal attack_received(attacker: Unit, damage: int)

# ===== ENUMS =====
enum UnitType { PLAYER, THORNE, LYRA, MATTHIAS, ENEMY, INFANTRY, ARCHER }

# ===== CONSTANTS =====
const SPRITE_SIZE: int = 56
const MOVE_DURATION_PER_TILE: float = 0.15  # Seconds per tile (Task 1.5)
const DEATH_FADE_DURATION: float = 0.5  # Death animation duration (Task 1.7)

# ===== PRELOADS =====
const DamageNumberScene = preload("res://scenes/UI/DamageNumber.tscn")

# HP Bar colors from spec (Task 1.3)
const COLOR_HP_HEALTHY: Color = Color("#27ae60")    # Green - HP > 25%
const COLOR_HP_CRITICAL: Color = Color("#c0392b")   # Red - HP <= 25%
const COLOR_HP_BACKGROUND: Color = Color("#7f1d1d") # Dark red background

# Selection colors from spec (Task 1.4)
const COLOR_SELECTION: Color = Color("#f1c40f")     # Yellow selection outline
const SELECTION_OUTLINE_WIDTH: int = 3
const CLICK_RADIUS: int = 28  # Half of sprite size

# HP Bar dimensions from spec
const HP_BAR_WIDTH: int = 48
const HP_BAR_HEIGHT: int = 6
const HP_BAR_OFFSET_Y: int = -40
const LOW_HP_THRESHOLD: float = 0.25  # 25%

# Unit colors from spec
const UNIT_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#3498db"),    # Blue
	UnitType.THORNE: Color("#2980b9"),    # Dark Blue
	UnitType.LYRA: Color("#9b59b6"),      # Purple
	UnitType.MATTHIAS: Color("#f39c12"),  # Orange
	UnitType.ENEMY: Color("#e74c3c"),     # Red
	UnitType.INFANTRY: Color("#1abc9c"),  # Teal (soldier)
	UnitType.ARCHER: Color("#16a085"),    # Dark Teal (soldier)
}

const UNIT_BORDER_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#2980b9"),
	UnitType.THORNE: Color("#1f618d"),
	UnitType.LYRA: Color("#7d3c98"),
	UnitType.MATTHIAS: Color("#d68910"),
	UnitType.ENEMY: Color("#c0392b"),
	UnitType.INFANTRY: Color("#17a589"),
	UnitType.ARCHER: Color("#138d75"),
}

const UNIT_LETTERS: Dictionary = {
	UnitType.PLAYER: "P",
	UnitType.THORNE: "T",
	UnitType.LYRA: "L",
	UnitType.MATTHIAS: "M",
	UnitType.ENEMY: "E",
	UnitType.INFANTRY: "I",
	UnitType.ARCHER: "A",
}

# ===== EXPORTED PROPERTIES =====
@export var unit_type: UnitType = UnitType.PLAYER
@export var unit_name: String = "Unit"
@export var is_enemy: bool = false
@export var is_soldier: bool = false  # Soldiers dying doesn't trigger defeat (Task 1.9)
@export var max_hp: int = 30
@export var movement_range: int = 5  # Tiles per turn (Task 1.5)

# ===== STATS (Task 2.1) =====
# Core stats (D&D style)
@export var strength: int = 10
@export var dexterity: int = 10
@export var constitution: int = 10
@export var intelligence: int = 10
@export var wisdom: int = 10
@export var charisma: int = 10

# Derived stats
@export var armor_bonus: int = 0
@export var skill_rank: int = 2  # Base skill rank for attacks
@export var weapon_damage_die: int = 6  # e.g., 6 for 1d6
@export var uses_finesse: bool = false  # Uses DEX for attacks instead of STR

# ===== NODE REFERENCES =====
@onready var sprite: Sprite2D = $Sprite2D
@onready var letter_label: Label = $LetterLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var selection_indicator: Sprite2D = $SelectionIndicator
@onready var click_area: Area2D = $ClickArea

# ===== INTERNAL STATE =====
var grid_position: Vector2i = Vector2i.ZERO
var current_hp: int = 30
var combat_grid: CombatGrid = null
var is_selected: bool = false
var _is_moving: bool = false
var _movement_tween: Tween

# ===== ABILITY DATA (Task 2.2) =====
var _abilities: Array[Dictionary] = []

# ===== STAT MODIFIERS (Task 2.1) =====
func get_stat_modifier(stat_value: int) -> int:
	## Calculate D&D-style modifier: floor((stat - 10) / 2)
	return int(floor((stat_value - 10) / 2.0))

func get_str_mod() -> int:
	return get_stat_modifier(strength)

func get_dex_mod() -> int:
	return get_stat_modifier(dexterity)

func get_con_mod() -> int:
	return get_stat_modifier(constitution)

func get_int_mod() -> int:
	return get_stat_modifier(intelligence)

func get_wis_mod() -> int:
	return get_stat_modifier(wisdom)

func get_cha_mod() -> int:
	return get_stat_modifier(charisma)

# ===== COMBAT CALCULATIONS (Task 2.1) =====
func get_defense() -> int:
	## Calculate defense value: 10 + DEX mod + armor bonus
	return 10 + get_dex_mod() + armor_bonus

func get_melee_attack_bonus() -> int:
	## Calculate melee attack bonus: STR mod + skill rank
	return get_str_mod() + skill_rank

func get_ranged_attack_bonus() -> int:
	## Calculate ranged attack bonus: DEX mod + skill rank
	return get_dex_mod() + skill_rank

func get_attack_bonus() -> int:
	## Get appropriate attack bonus based on finesse property
	if uses_finesse:
		return get_ranged_attack_bonus()
	return get_melee_attack_bonus()

func get_damage_modifier() -> int:
	## Get damage modifier (STR or DEX for finesse weapons)
	if uses_finesse:
		return get_dex_mod()
	return get_str_mod()

func get_damage_die() -> int:
	## Get weapon damage die
	return weapon_damage_die

# ===== STATS CONFIGURATION (Task 2.1) =====
func _configure_stats_for_type() -> void:
	## Set stats based on unit type (from GDD)
	match unit_type:
		UnitType.PLAYER:
			strength = 14
			dexterity = 12
			constitution = 14
			intelligence = 10
			wisdom = 10
			charisma = 12
			max_hp = 35
			armor_bonus = 3  # Chain Shirt
			movement_range = 5
			weapon_damage_die = 8  # Sword 1d8
			uses_finesse = false
			skill_rank = 2

		UnitType.THORNE:
			strength = 16
			dexterity = 10
			constitution = 14
			intelligence = 10
			wisdom = 12
			charisma = 8
			max_hp = 40
			armor_bonus = 5  # Plate
			movement_range = 4
			weapon_damage_die = 8  # Sword 1d8
			uses_finesse = false
			skill_rank = 2

		UnitType.LYRA:
			strength = 10
			dexterity = 16
			constitution = 10
			intelligence = 14
			wisdom = 12
			charisma = 12
			max_hp = 25
			armor_bonus = 2  # Leather
			movement_range = 6
			weapon_damage_die = 4  # Dagger 1d4
			uses_finesse = true  # Uses DEX for attacks
			skill_rank = 2

		UnitType.MATTHIAS:
			strength = 10
			dexterity = 10
			constitution = 12
			intelligence = 12
			wisdom = 16
			charisma = 14
			max_hp = 30
			armor_bonus = 4  # Scale Mail
			movement_range = 5
			weapon_damage_die = 6  # Staff 1d6
			uses_finesse = false
			skill_rank = 2

		UnitType.ENEMY:
			strength = 12
			dexterity = 12
			constitution = 10
			intelligence = 8
			wisdom = 8
			charisma = 8
			max_hp = 15
			armor_bonus = 2  # Light armor
			movement_range = 5
			weapon_damage_die = 6  # 1d6
			uses_finesse = false
			skill_rank = 1

		UnitType.INFANTRY:
			strength = 12
			dexterity = 10
			constitution = 12
			intelligence = 8
			wisdom = 10
			charisma = 8
			max_hp = 20
			armor_bonus = 3  # Medium armor
			movement_range = 4
			weapon_damage_die = 6  # 1d6
			uses_finesse = false
			skill_rank = 1

		UnitType.ARCHER:
			strength = 10
			dexterity = 12
			constitution = 10
			intelligence = 10
			wisdom = 10
			charisma = 8
			max_hp = 15
			armor_bonus = 1  # Light armor
			movement_range = 5
			weapon_damage_die = 6  # Bow 1d6
			uses_finesse = true  # Uses DEX for ranged
			skill_rank = 1

# ===== ABILITY CONFIGURATION (Task 2.2) =====
func _init_abilities() -> void:
	## Initialize abilities based on unit type (from GDD)
	match unit_type:
		UnitType.PLAYER:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "power_attack", "name": "Power Attack", "icon": ""},
				{"id": "shield_bash", "name": "Shield Bash", "icon": ""},
				{"id": "rally", "name": "Rally", "icon": ""},
			]
		UnitType.THORNE:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "cleave", "name": "Cleave", "icon": ""},
				{"id": "taunt", "name": "Taunt", "icon": ""},
				{"id": "last_stand", "name": "Last Stand", "icon": ""},
			]
		UnitType.LYRA:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "backstab", "name": "Backstab", "icon": ""},
				{"id": "shadowstep", "name": "Shadowstep", "icon": ""},
				{"id": "poison_blade", "name": "Poison Blade", "icon": ""},
			]
		UnitType.MATTHIAS:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "heal", "name": "Heal", "icon": ""},
				{"id": "bless", "name": "Bless", "icon": ""},
				{"id": "smite", "name": "Smite", "icon": ""},
			]
		UnitType.ENEMY:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]
		_:
			# Default basic attack only for soldiers/other units
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]

func get_abilities() -> Array[Dictionary]:
	## Get this unit's abilities
	return _abilities.duplicate()

func is_ability_available(ability_id: String) -> bool:
	## Check if an ability can be used
	## For now, all valid abilities are available (future: cooldowns, costs, targets)
	if ability_id.is_empty():
		return false
	# "none" abilities are always unavailable
	if ability_id.begins_with("none"):
		return false
	# Check if ability exists for this unit
	for ability in _abilities:
		if ability.get("id") == ability_id:
			return true
	return false

# ===== LIFECYCLE =====
func _ready() -> void:
	# Configure stats based on unit type FIRST
	_configure_stats_for_type()
	current_hp = max_hp
	_init_abilities()  # Initialize abilities (Task 2.2)
	_update_visual()
	_setup_hp_bar()
	_update_hp_bar()
	_setup_selection_indicator()
	_setup_click_detection()
	add_to_group("units")

	# Set enemy flag based on unit type
	is_enemy = (unit_type == UnitType.ENEMY)

	# Set soldier flag based on unit type (Task 1.9)
	is_soldier = (unit_type == UnitType.INFANTRY or unit_type == UnitType.ARCHER)

	# Debug print stats
	print("[Unit] %s stats: STR %d(%+d) DEX %d(%+d) HP %d DEF %d ATK %+d Move %d" % [
		unit_name, strength, get_str_mod(), dexterity, get_dex_mod(),
		max_hp, get_defense(), get_attack_bonus(), movement_range
	])

func _update_visual() -> void:
	## Update sprite and label based on unit type
	_generate_sprite_texture()
	_update_letter_label()

func _generate_sprite_texture() -> void:
	## Generate a colored square texture for the unit
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)

	var fill_color = UNIT_COLORS.get(unit_type, Color.WHITE)
	var border_color = UNIT_BORDER_COLORS.get(unit_type, Color.GRAY)

	# Draw filled rectangle with 2px border
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var is_border = (x < 2 or x >= SPRITE_SIZE - 2 or y < 2 or y >= SPRITE_SIZE - 2)
			var color = border_color if is_border else fill_color
			image.set_pixel(x, y, color)

	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.centered = true

func _update_letter_label() -> void:
	## Update the letter label with unit's identifier
	var letter = UNIT_LETTERS.get(unit_type, "?")
	letter_label.text = letter
	letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# ===== HP BAR MANAGEMENT =====
func _setup_hp_bar() -> void:
	## Configure HP bar styling with custom StyleBoxFlat for colors
	if not hp_bar:
		return

	# Set HP bar size and position (centered above unit)
	hp_bar.custom_minimum_size = Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT)
	hp_bar.size = Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT)
	hp_bar.position = Vector2(-HP_BAR_WIDTH / 2, HP_BAR_OFFSET_Y)

	# Configure ProgressBar properties
	hp_bar.min_value = 0
	hp_bar.max_value = 100
	hp_bar.show_percentage = false

	# Apply background style (dark red - represents missing health)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = COLOR_HP_BACKGROUND
	bg_style.corner_radius_top_left = 1
	bg_style.corner_radius_top_right = 1
	bg_style.corner_radius_bottom_left = 1
	bg_style.corner_radius_bottom_right = 1
	hp_bar.add_theme_stylebox_override("background", bg_style)

func _update_hp_bar() -> void:
	## Update HP bar value and color based on current HP
	if not hp_bar:
		return

	# Calculate percentage and update bar value
	var hp_percent = get_hp_percentage()
	hp_bar.value = hp_percent * 100

	# Update fill color based on HP threshold
	_update_hp_bar_color(hp_percent)

func _update_hp_bar_color(hp_percent: float) -> void:
	## Update the HP bar fill color based on current HP percentage
	var fill_style = StyleBoxFlat.new()

	# Use critical (red) color when HP is at or below 25%
	if hp_percent <= LOW_HP_THRESHOLD:
		fill_style.bg_color = COLOR_HP_CRITICAL
	else:
		fill_style.bg_color = COLOR_HP_HEALTHY

	fill_style.corner_radius_top_left = 1
	fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = 1
	fill_style.corner_radius_bottom_right = 1
	hp_bar.add_theme_stylebox_override("fill", fill_style)

# ===== SELECTION MANAGEMENT (Task 1.4) =====
func _setup_selection_indicator() -> void:
	## Create yellow outline texture for selection indicator
	if not selection_indicator:
		return

	var indicator_size = SPRITE_SIZE + (SELECTION_OUTLINE_WIDTH * 2)
	var image = Image.create(indicator_size, indicator_size, false, Image.FORMAT_RGBA8)

	# Draw hollow rectangle (outline only)
	for x in range(indicator_size):
		for y in range(indicator_size):
			var is_outline = (
				x < SELECTION_OUTLINE_WIDTH or
				x >= indicator_size - SELECTION_OUTLINE_WIDTH or
				y < SELECTION_OUTLINE_WIDTH or
				y >= indicator_size - SELECTION_OUTLINE_WIDTH
			)
			if is_outline:
				image.set_pixel(x, y, COLOR_SELECTION)
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)

	var texture = ImageTexture.create_from_image(image)
	selection_indicator.texture = texture
	selection_indicator.centered = true
	selection_indicator.visible = false  # Hidden by default

func _setup_click_detection() -> void:
	## Configure Area2D for click detection
	if not click_area:
		push_error("[Unit] ClickArea not found for %s" % unit_name)
		return
	click_area.input_event.connect(_on_click_area_input_event)
	print("[Unit] Click detection setup for %s" % unit_name)

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	## Handle click input on unit
	if event is InputEventMouseButton:
		print("[Unit] Mouse event on %s: button=%d pressed=%s" % [unit_name, event.button_index, event.pressed])
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click()

func _handle_click() -> void:
	## Process click on this unit
	unit_clicked.emit(self)

	# Let CombatManager handle selection logic
	if not is_enemy and is_alive():
		CombatManager.select_unit(self)
	else:
		# Clicking enemy or dead unit deselects
		CombatManager.deselect_unit()

func select() -> void:
	## Mark this unit as selected and show indicator
	is_selected = true
	if selection_indicator:
		selection_indicator.visible = true

func deselect() -> void:
	## Mark this unit as not selected and hide indicator
	is_selected = false
	if selection_indicator:
		selection_indicator.visible = false

# ===== PUBLIC API =====
func place_on_grid(coords: Vector2i) -> void:
	## Place unit on grid at specified coordinates
	var old_position = grid_position
	grid_position = coords

	if combat_grid:
		position = combat_grid.grid_to_world(coords)

	if old_position != coords:
		unit_moved.emit(self, old_position, coords)

func get_grid_position() -> Vector2i:
	## Get current grid position
	return grid_position

func set_combat_grid(grid: CombatGrid) -> void:
	## Set reference to the combat grid
	combat_grid = grid

func snap_to_grid() -> void:
	## Snap unit to its current grid position
	if combat_grid:
		position = combat_grid.grid_to_world(grid_position)

func set_unit_type(type: UnitType) -> void:
	## Change unit type and update visuals
	unit_type = type
	is_enemy = (type == UnitType.ENEMY)
	_update_visual()

func take_damage(amount: int) -> void:
	## Apply damage to unit and update HP bar
	current_hp = max(0, current_hp - amount)
	_update_hp_bar()
	unit_damaged.emit(self, amount)

	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	## Heal unit and update HP bar
	current_hp = min(max_hp, current_hp + amount)
	_update_hp_bar()

func _die() -> void:
	## Handle unit death with fade animation
	unit_died.emit(self)

	# Disable click detection
	if click_area:
		click_area.input_pickable = false

	# Fade out animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, DEATH_FADE_DURATION)
	tween.tween_callback(queue_free)

func get_hp_percentage() -> float:
	## Get HP as percentage (0.0 to 1.0)
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)

func is_alive() -> bool:
	## Check if unit is still alive
	return current_hp > 0

func is_friendly() -> bool:
	## Check if unit is friendly (not enemy)
	return not is_enemy

# ===== MOVEMENT (Task 1.5) =====
func is_moving() -> bool:
	## Check if unit is currently animating movement
	return _is_moving

func move_along_path(path: Array[Vector2i]) -> void:
	## Animate unit movement along a path
	if path.size() < 2:
		return  # Need at least start and end

	_is_moving = true
	movement_started.emit(self)

	# Cancel any existing tween
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()

	_movement_tween = create_tween()
	_movement_tween.set_ease(Tween.EASE_IN_OUT)
	_movement_tween.set_trans(Tween.TRANS_LINEAR)

	# Animate through each tile in path (skip first - we're already there)
	for i in range(1, path.size()):
		var target_coords = path[i]
		var target_pos = combat_grid.grid_to_world(target_coords)
		_movement_tween.tween_property(self, "position", target_pos, MOVE_DURATION_PER_TILE)

	# Update grid position to final destination
	var final_coords = path[path.size() - 1]
	_movement_tween.tween_callback(_on_movement_complete.bind(final_coords))

func _on_movement_complete(final_coords: Vector2i) -> void:
	## Called when movement animation finishes
	var old_pos = grid_position
	grid_position = final_coords
	_is_moving = false
	movement_finished.emit(self)
	unit_moved.emit(self, old_pos, final_coords)

# ===== ATTACK HANDLING (Task 1.7) =====
func can_attack(target: Unit) -> bool:
	## Check if this unit can attack the target
	if target == null or target == self:
		return false
	if not is_alive() or not target.is_alive():
		return false
	if not AttackResolver.is_adjacent(self, target):
		return false
	if target.is_friendly() == is_friendly():
		return false  # No friendly fire
	return true

func perform_attack(target: Unit) -> void:
	## Execute an attack against the target
	if not can_attack(target):
		return

	attack_initiated.emit(self, target)

	# Resolve the attack
	var result = AttackResolver.resolve_attack(self, target)

	# Spawn damage number
	_spawn_damage_number(target, result)

	# Apply damage if hit
	if result.hit:
		target.take_damage(result.damage)
		target.attack_received.emit(self, result.damage)

	# Log the attack
	print("[Unit] %s attacks %s: Roll %d + %d = %d vs DEF %d -> %s for %d damage%s" % [
		unit_name,
		target.unit_name,
		result.roll,
		result.total_attack - result.roll,
		result.total_attack,
		result.target_defense,
		"HIT" if result.hit else "MISS",
		result.damage,
		" (CRITICAL!)" if result.is_critical else ""
	])

func _spawn_damage_number(target: Unit, result: AttackResolver.AttackResult) -> void:
	## Create floating damage number at target
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Add to scene tree (use parent of target so it's in world space)
	target.get_parent().add_child(damage_number)

	# Display appropriate text
	if result.hit:
		damage_number.show_damage(result.damage, result.is_critical)
	else:
		damage_number.show_miss()

# ===== STATIC HELPERS =====
static func get_unit_display_name(type: UnitType) -> String:
	## Get display name for unit type
	match type:
		UnitType.PLAYER: return "Player"
		UnitType.THORNE: return "Thorne"
		UnitType.LYRA: return "Lyra"
		UnitType.MATTHIAS: return "Matthias"
		UnitType.ENEMY: return "Enemy"
		UnitType.INFANTRY: return "Infantry"
		UnitType.ARCHER: return "Archer"
		_: return "Unknown"
