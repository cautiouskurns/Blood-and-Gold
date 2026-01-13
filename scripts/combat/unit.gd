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
signal order_changed(unit: Unit, new_order: int)  # Task 2.8: Soldier order changed

# ===== ENUMS =====
enum UnitType { PLAYER, THORNE, LYRA, MATTHIAS, ENEMY, INFANTRY, ARCHER, BANDIT_ARCHER, BANDIT_LEADER, IRONMARK_SOLDIER, IRONMARK_KNIGHT }

# ===== CONSTANTS =====
const SPRITE_SIZE: int = 56
const MOVE_DURATION_PER_TILE: float = 0.15  # Seconds per tile (Task 1.5)
const DEATH_FADE_DURATION: float = 0.5  # Death animation duration (Task 1.7)

# ===== PRELOADS =====
const DamageNumberScene = preload("res://scenes/UI/DamageNumber.tscn")
const UnitNameplateScene = preload("res://scenes/UI/UnitNameplate.tscn")

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

# Order icon dimensions (Task 2.8)
const ORDER_ICON_SIZE: int = 24
const ORDER_ICON_OFFSET_Y: int = -55  # Above HP bar

# Order icon colors (Task 2.8)
const ORDER_COLORS: Dictionary = {
	0: Color("#e74c3c"),  # HOLD - Red/defensive
	1: Color("#2ecc71"),  # ADVANCE - Green/aggressive
	2: Color("#f39c12"),  # FOCUS_FIRE - Orange/targeted
	3: Color("#9b59b6"),  # RETREAT - Purple/withdraw
	4: Color("#3498db"),  # PROTECT - Blue/guardian
}

# Unit colors from spec
const UNIT_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#3498db"),    # Blue
	UnitType.THORNE: Color("#2980b9"),    # Dark Blue
	UnitType.LYRA: Color("#9b59b6"),      # Purple
	UnitType.MATTHIAS: Color("#f39c12"),  # Orange
	UnitType.ENEMY: Color("#e74c3c"),     # Red
	UnitType.INFANTRY: Color("#1abc9c"),  # Teal (soldier)
	UnitType.ARCHER: Color("#16a085"),    # Dark Teal (soldier)
	UnitType.BANDIT_ARCHER: Color("#27ae60"),   # Forest Green (Task 2.15)
	UnitType.BANDIT_LEADER: Color("#c0392b"),   # Crimson Red (Task 2.15)
	UnitType.IRONMARK_SOLDIER: Color("#2980b9"),  # Royal Blue (Task 2.15)
	UnitType.IRONMARK_KNIGHT: Color("#2980b9"),   # Royal Blue (Task 2.15)
}

const UNIT_BORDER_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#2980b9"),
	UnitType.THORNE: Color("#1f618d"),
	UnitType.LYRA: Color("#7d3c98"),
	UnitType.MATTHIAS: Color("#d68910"),
	UnitType.ENEMY: Color("#c0392b"),
	UnitType.INFANTRY: Color("#17a589"),
	UnitType.ARCHER: Color("#138d75"),
	UnitType.BANDIT_ARCHER: Color("#1e8449"),     # Dark Green (Task 2.15)
	UnitType.BANDIT_LEADER: Color("#922b21"),     # Dark Red (Task 2.15)
	UnitType.IRONMARK_SOLDIER: Color("#1f618d"),  # Dark Blue (Task 2.15)
	UnitType.IRONMARK_KNIGHT: Color("#1a5276"),   # Deep Blue (Task 2.15)
}

const UNIT_LETTERS: Dictionary = {
	UnitType.PLAYER: "P",
	UnitType.THORNE: "T",
	UnitType.LYRA: "L",
	UnitType.MATTHIAS: "M",
	UnitType.ENEMY: "E",
	UnitType.INFANTRY: "I",
	UnitType.ARCHER: "A",
	UnitType.BANDIT_ARCHER: "B",     # Task 2.15: B for Bowman (avoid conflict with friendly Archer)
	UnitType.BANDIT_LEADER: "C",     # Task 2.15: C for Captain (avoid conflict with Lyra)
	UnitType.IRONMARK_SOLDIER: "S",  # Task 2.15: S for Soldier
	UnitType.IRONMARK_KNIGHT: "K",   # Task 2.15: K for Knight
}

# ===== EXPORTED PROPERTIES =====
@export var unit_type: UnitType = UnitType.PLAYER
@export var unit_name: String = "Unit"
@export var is_enemy: bool = false
@export var is_soldier: bool = false  # Soldiers dying doesn't trigger defeat (Task 1.9)
@export var is_bandit: bool = false   # Task 2.15: For Rally Bandits targeting
@export var is_ironmark: bool = false # Task 2.15: For Shield Wall calculation
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
@export var damage_bonus: int = 0  # Task 2.15: Additional flat damage bonus
@export var uses_finesse: bool = false  # Uses DEX for attacks instead of STR
@export var weapon_range: int = 1  # 1 = melee, 8 = shortbow, 10 = crossbow (Task 2.7)
@export var is_ranged_weapon: bool = false  # True for bows, crossbows (Task 2.7)

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
var _nameplate: UnitNameplate = null  # Task 4.3: Floating nameplate

# ===== FACING DIRECTION (Task 2.5) =====
var facing_direction: Vector2i = Vector2i(0, 1)  # Default facing South (down)

# ===== SOLDIER ORDER SYSTEM (Task 2.8) =====
enum SoldierOrder { HOLD, ADVANCE, FOCUS_FIRE, RETREAT, PROTECT }
var current_order: SoldierOrder = SoldierOrder.HOLD
var _order_icon: Sprite2D = null  # Reference to order icon node

# ===== POISON BLADE STATE (Task 2.5) =====
var _poison_blade_charges: int = 0   # Number of attacks remaining with poison
var _poison_blade_damage: int = 0    # Bonus damage per attack

# ===== ATTACK OF OPPORTUNITY STATE (Task 2.13) =====
var _opportunity_attack_used: bool = false  # True if this unit has used their AoO this turn

# ===== ABILITY DATA (Task 2.2) =====
var _abilities: Array[Dictionary] = []

# ===== ABILITY USAGE TRACKING (Task 2.3) =====
var _ability_uses: Dictionary = {}  # ability_id -> times used this battle
var _ability_resources: Dictionary = {}  # ability_id -> Ability resource (cached)

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
	## Calculate defense value: 10 + DEX mod + armor bonus + Shield Wall if applicable
	var base_defense = 10 + get_dex_mod() + armor_bonus

	# Task 2.15: Shield Wall passive for Ironmark units
	if is_ironmark and _has_adjacent_ironmark_ally():
		base_defense += 2
		# Note: Shield Wall bonus doesn't stack - just +2 total

	return base_defense

func _has_adjacent_ironmark_ally() -> bool:
	## Task 2.15: Check if there's an adjacent Ironmark ally for Shield Wall
	var adjacent_units = _get_adjacent_units()
	for unit in adjacent_units:
		if unit.is_ironmark and unit != self and unit.is_alive():
			return true
	return false

func _get_adjacent_units() -> Array[Unit]:
	## Get all units adjacent to this unit (8-directional)
	var adjacent: Array[Unit] = []
	var units = get_tree().get_nodes_in_group("units")

	for node in units:
		var unit = node as Unit
		if unit and is_instance_valid(unit) and unit != self:
			if is_adjacent_to(unit):
				adjacent.append(unit)

	return adjacent

func get_melee_attack_bonus() -> int:
	## Calculate melee attack bonus: STR mod + skill rank
	return get_str_mod() + skill_rank

func get_ranged_attack_bonus() -> int:
	## Calculate ranged attack bonus: DEX mod + skill rank
	return get_dex_mod() + skill_rank

func get_attack_bonus() -> int:
	## Get appropriate attack bonus based on finesse property
	## Includes status effect bonuses (Task 2.3)
	var base_bonus: int = 0
	if uses_finesse:
		base_bonus = get_ranged_attack_bonus()
	else:
		base_bonus = get_melee_attack_bonus()

	# Add attack buff from status effects
	var buff_bonus = get_attack_buff()
	return base_bonus + buff_bonus

func get_damage_modifier() -> int:
	## Get damage modifier (STR or DEX for finesse weapons) + flat bonus
	var stat_mod: int = get_str_mod()
	if uses_finesse:
		stat_mod = get_dex_mod()
	return stat_mod + damage_bonus

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
			weapon_damage_die = 6  # Shortbow 1d6 (Task 2.7)
			uses_finesse = true  # Uses DEX for attacks
			weapon_range = 8  # Shortbow range (Task 2.7)
			is_ranged_weapon = true  # Task 2.7
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
			weapon_damage_die = 6  # Shortbow 1d6
			uses_finesse = true  # Uses DEX for ranged
			weapon_range = 8  # Shortbow range (Task 2.7)
			is_ranged_weapon = true  # Task 2.7
			skill_rank = 1

		# ===== TASK 2.15: NEW ENEMY TYPES =====

		UnitType.BANDIT_ARCHER:
			# Role: Ranged threat, forces advancement
			# Stats: HP 10, DEF 11, ATK 1d6 (range 8), Move 5
			strength = 10
			dexterity = 14  # +2 for ranged accuracy
			constitution = 8
			intelligence = 8
			wisdom = 10
			charisma = 8
			max_hp = 10
			armor_bonus = 1  # DEF 11: 10 + 2(DEX) - 1 offset = 11, so armor_bonus 1
			movement_range = 5
			weapon_damage_die = 6  # 1d6
			damage_bonus = 0
			uses_finesse = true
			weapon_range = 8
			is_ranged_weapon = true
			skill_rank = 1

		UnitType.BANDIT_LEADER:
			# Role: Priority target, buff provider
			# Stats: HP 30, DEF 14, ATK 1d8+3, Move 5
			strength = 14  # +2 for melee
			dexterity = 12  # +1 for DEF
			constitution = 12
			intelligence = 10
			wisdom = 10
			charisma = 14  # Leaders have charisma
			max_hp = 30
			armor_bonus = 3  # DEF 14: 10 + 1(DEX) + 3 = 14
			movement_range = 5
			weapon_damage_die = 8  # 1d8
			damage_bonus = 1  # +3 total: +2 STR + 1 bonus = +3
			uses_finesse = false
			skill_rank = 2

		UnitType.IRONMARK_SOLDIER:
			# Role: Defensive formation unit, shield wall
			# Stats: HP 25, DEF 15 (heavy armor), ATK 1d8+2, Move 4
			strength = 14  # +2
			dexterity = 10  # 0
			constitution = 14
			intelligence = 8
			wisdom = 10
			charisma = 8
			max_hp = 25
			armor_bonus = 5  # DEF 15: 10 + 0(DEX) + 5 = 15 (Shield Wall adds +2)
			movement_range = 4  # Slower due to heavy armor
			weapon_damage_die = 8  # 1d8 spear
			damage_bonus = 0  # +2 total from STR
			uses_finesse = false
			skill_rank = 1

		UnitType.IRONMARK_KNIGHT:
			# Role: Elite mini-boss, aggressive threat
			# Stats: HP 40, DEF 17 (full plate), ATK 1d10+4, Move 5
			strength = 16  # +3
			dexterity = 10  # 0
			constitution = 16
			intelligence = 10
			wisdom = 12
			charisma = 14
			max_hp = 40
			armor_bonus = 7  # DEF 17: 10 + 0(DEX) + 7 = 17
			movement_range = 5
			weapon_damage_die = 10  # 1d10 lance/sword
			damage_bonus = 1  # +4 total: +3 STR + 1 bonus = +4
			uses_finesse = false
			skill_rank = 2

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
				{"id": "ranged_attack", "name": "Shoot", "icon": ""},  # Task 2.7: Ranged attack
				{"id": "backstab", "name": "Backstab", "icon": ""},
				{"id": "shadowstep", "name": "Shadowstep", "icon": ""},
				{"id": "poison_blade", "name": "Poison Blade", "icon": ""},
			]
		UnitType.MATTHIAS:
			_abilities = [
				{"id": "matthias_heal", "name": "Heal", "icon": ""},
				{"id": "matthias_bless", "name": "Bless", "icon": ""},
				{"id": "matthias_smite", "name": "Smite", "icon": ""},
				{"id": "matthias_basic_attack", "name": "Attack", "icon": ""},
			]
		UnitType.ENEMY:
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]
		UnitType.ARCHER:
			# Task 2.7: Archers use ranged attack
			_abilities = [
				{"id": "ranged_attack", "name": "Shoot", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]
		UnitType.INFANTRY:
			# Task 2.8: Infantry use basic melee attack
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]

		# ===== TASK 2.15: NEW ENEMY TYPE ABILITIES =====

		UnitType.BANDIT_ARCHER:
			# Ranged enemy - shoots from distance
			_abilities = [
				{"id": "ranged_attack", "name": "Shoot", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]

		UnitType.BANDIT_LEADER:
			# Leader with Rally and Power Attack
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "rally_bandits", "name": "Rally Bandits", "icon": ""},
				{"id": "power_attack", "name": "Power Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
			]

		UnitType.IRONMARK_SOLDIER:
			# Defensive soldier with Shield Wall (passive)
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
				{"id": "none2", "name": "", "icon": ""},
				{"id": "none3", "name": "", "icon": ""},
			]
			# Shield Wall is a passive - handled in get_defense()

		UnitType.IRONMARK_KNIGHT:
			# Elite with Charge and Intimidate
			_abilities = [
				{"id": "basic_attack", "name": "Attack", "icon": ""},
				{"id": "charge", "name": "Charge", "icon": ""},
				{"id": "intimidate", "name": "Intimidate", "icon": ""},
				{"id": "none1", "name": "", "icon": ""},
			]

		_:
			# Default basic attack only for other units
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
	## Check if an ability can be used (Task 2.3 update)
	if ability_id.is_empty():
		return false
	# "none" abilities are always unavailable
	if ability_id.begins_with("none"):
		return false
	# Check if ability exists for this unit
	var has_ability = false
	for ability in _abilities:
		if ability.get("id") == ability_id:
			has_ability = true
			break
	if not has_ability:
		return false

	# Check uses_per_battle limit using Ability resource
	var ability_res = get_ability_resource(ability_id)
	if ability_res:
		return ability_res.is_available_for_unit(self)
	return true

# ===== ABILITY USAGE API (Task 2.3) =====
func use_ability(ability_id: String) -> void:
	## Record that an ability was used this battle
	if not _ability_uses.has(ability_id):
		_ability_uses[ability_id] = 0
	_ability_uses[ability_id] += 1
	print("[Unit] %s used ability %s (%d times)" % [unit_name, ability_id, _ability_uses[ability_id]])

func get_ability_uses(ability_id: String) -> int:
	## Get how many times an ability has been used this battle
	return _ability_uses.get(ability_id, 0)

func reset_ability_uses() -> void:
	## Reset ability usage counts (call at battle start)
	_ability_uses.clear()
	print("[Unit] %s ability uses reset" % unit_name)

func get_ability_resource(ability_id: String) -> Resource:
	## Get the Ability resource for a given ability ID
	## Returns null if not found
	if _ability_resources.has(ability_id):
		return _ability_resources[ability_id]

	# Try to load the ability resource
	var path = "res://resources/abilities/%s.tres" % ability_id
	if ResourceLoader.exists(path):
		var ability_res = load(path)
		_ability_resources[ability_id] = ability_res
		return ability_res
	return null

# ===== STATUS EFFECT API (Task 2.3) =====
func is_stunned() -> bool:
	## Check if unit is currently stunned
	if not Engine.has_singleton("StatusEffectManager"):
		# Fallback: check autoload
		var sem = get_node_or_null("/root/StatusEffectManager")
		if sem:
			return sem.has_effect(self, "STUNNED")
		return false
	return false

func get_attack_buff() -> int:
	## Get current attack buff value from status effects
	## Includes both ATTACK_BUFF and BLESSED (Task 2.6)
	var sem = get_node_or_null("/root/StatusEffectManager")
	if sem:
		return sem.get_roll_modifier(self)
	return 0

func get_all_status_effects() -> Array:
	## Get all active status effects on this unit
	var sem = get_node_or_null("/root/StatusEffectManager")
	if sem:
		return sem.get_unit_effects(self)
	return []

# ===== FACING DIRECTION API (Task 2.5) =====
func get_facing_direction() -> Vector2i:
	## Get the direction this unit is facing
	return facing_direction

func set_facing_direction(direction: Vector2i) -> void:
	## Set facing direction (normalizes to -1, 0, or 1 per axis)
	if direction != Vector2i.ZERO:
		facing_direction = direction.sign()

func _update_facing_from_movement(from: Vector2i, to: Vector2i) -> void:
	## Update facing based on movement direction
	var delta = to - from
	if delta != Vector2i.ZERO:
		set_facing_direction(delta)

func is_behind(attacker: Unit) -> bool:
	## Check if attacker is positioned behind this unit (Task 2.5: Backstab)
	## Behind = attacker is in the opposite direction of facing
	var direction_to_attacker = attacker.grid_position - grid_position

	# Normalize to get direction
	var attack_from = direction_to_attacker.sign()

	# Behind = opposite of facing direction (180 degrees)
	var behind_direction = -facing_direction

	# For strict backstab: only directly behind (not diagonal)
	# attacker must be in exactly the opposite direction of facing
	return attack_from == behind_direction

# ===== SOLDIER ORDER API (Task 2.8) =====
func set_order(order: SoldierOrder) -> void:
	## Set the soldier's current order and update visual
	if not is_soldier:
		return
	var old_order = current_order
	current_order = order
	_update_order_icon()
	if old_order != order:
		order_changed.emit(self, order)
		print("[Unit] %s order changed: %s -> %s" % [
			unit_name,
			SoldierOrder.keys()[old_order],
			SoldierOrder.keys()[order]
		])

func get_order() -> SoldierOrder:
	## Get the soldier's current order
	return current_order

func get_order_name() -> String:
	## Get the order name as string
	return SoldierOrder.keys()[current_order]

func _setup_order_icon() -> void:
	## Create order icon sprite for soldiers (Task 2.8)
	if not is_soldier:
		return

	# Create order icon sprite
	_order_icon = Sprite2D.new()
	_order_icon.name = "OrderIcon"
	_order_icon.position = Vector2(0, ORDER_ICON_OFFSET_Y)
	_order_icon.centered = true
	add_child(_order_icon)

	# Generate initial icon
	_update_order_icon()
	print("[Unit] Order icon created for %s (order: %s)" % [unit_name, get_order_name()])

func _update_order_icon() -> void:
	## Update order icon visual based on current order
	if not _order_icon or not is_soldier:
		return

	var icon_color = ORDER_COLORS.get(current_order, Color.WHITE)
	var texture = _generate_order_icon_texture(icon_color)
	_order_icon.texture = texture

func _generate_order_icon_texture(color: Color) -> ImageTexture:
	## Generate a simple order icon texture
	var size = ORDER_ICON_SIZE
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)

	# Draw icon based on order type
	match current_order:
		SoldierOrder.HOLD:
			# Shield shape (defensive)
			_draw_shield_icon(image, size, color)
		SoldierOrder.ADVANCE:
			# Sword/arrow shape (aggressive)
			_draw_sword_icon(image, size, color)
		SoldierOrder.FOCUS_FIRE:
			# Crosshair shape (targeted)
			_draw_crosshair_icon(image, size, color)
		SoldierOrder.RETREAT:
			# Arrow pointing back
			_draw_retreat_icon(image, size, color)
		SoldierOrder.PROTECT:
			# Shield with plus
			_draw_protect_icon(image, size, color)

	return ImageTexture.create_from_image(image)

func _draw_shield_icon(image: Image, size: int, color: Color) -> void:
	## Draw a shield icon (HOLD order)
	var center = size / 2
	for x in range(size):
		for y in range(size):
			var dx = abs(x - center)
			var dy = y - 2
			# Shield shape: wider at top, narrows at bottom
			var is_shield = dy >= 0 and dy < size - 4 and dx <= (size/2 - 2 - dy/3)
			if is_shield:
				image.set_pixel(x, y, color)

func _draw_sword_icon(image: Image, size: int, color: Color) -> void:
	## Draw a sword pointing up icon (ADVANCE order)
	var center = size / 2
	for x in range(size):
		for y in range(size):
			# Blade (vertical line)
			var is_blade = abs(x - center) <= 1 and y >= 2 and y < size - 6
			# Crossguard (horizontal line)
			var is_guard = abs(y - (size - 6)) <= 1 and abs(x - center) <= 4
			# Handle
			var is_handle = abs(x - center) <= 1 and y >= size - 6 and y < size - 2
			if is_blade or is_guard or is_handle:
				image.set_pixel(x, y, color)

func _draw_crosshair_icon(image: Image, size: int, color: Color) -> void:
	## Draw a crosshair icon (FOCUS_FIRE order)
	var center = size / 2
	for x in range(size):
		for y in range(size):
			# Horizontal line
			var is_h_line = abs(y - center) <= 1 and (x < center - 3 or x > center + 3)
			# Vertical line
			var is_v_line = abs(x - center) <= 1 and (y < center - 3 or y > center + 3)
			# Center dot
			var dist = sqrt(pow(x - center, 2) + pow(y - center, 2))
			var is_center = dist <= 2
			if is_h_line or is_v_line or is_center:
				image.set_pixel(x, y, color)

func _draw_retreat_icon(image: Image, size: int, color: Color) -> void:
	## Draw an arrow pointing down-left (RETREAT order)
	var center = size / 2
	for x in range(size):
		for y in range(size):
			# Arrow shaft (diagonal)
			var on_shaft = abs((x - 4) - (y - 4)) <= 1 and x >= 4 and x < size - 4 and y >= 4 and y < size - 4
			# Arrow head
			var head_x = 4
			var head_y = size - 6
			var is_head = (abs(x - head_x) <= 3 and abs(y - head_y) <= 1) or (abs(y - head_y) <= 3 and abs(x - head_x) <= 1)
			if on_shaft or is_head:
				image.set_pixel(x, y, color)

func _draw_protect_icon(image: Image, size: int, color: Color) -> void:
	## Draw a shield with plus (PROTECT order)
	var center = size / 2
	for x in range(size):
		for y in range(size):
			var dx = abs(x - center)
			var dy = y - 2
			# Shield shape
			var is_shield = dy >= 0 and dy < size - 4 and dx <= (size/2 - 2 - dy/3)
			# Plus sign inside
			var is_plus = is_shield and ((abs(x - center) <= 1 and dy >= 4 and dy < size - 8) or (abs(dy - (size/2 - 2)) <= 1 and dx <= 4))
			if is_shield:
				# Outline only for shield, filled plus
				var is_outline = dx >= (size/2 - 3 - dy/3) or dy <= 1 or dy >= size - 6
				if is_outline or is_plus:
					image.set_pixel(x, y, color)

# ===== POISON BLADE API (Task 2.5) =====
func apply_poison_blade(attacks: int, bonus_damage: int) -> void:
	## Apply Poison Blade buff
	_poison_blade_charges = attacks
	_poison_blade_damage = bonus_damage
	print("[Unit] %s Poison Blade active: +%d damage for %d attacks" % [
		unit_name, bonus_damage, attacks
	])

func get_poison_blade_bonus() -> int:
	## Get current Poison Blade bonus (0 if not active)
	if _poison_blade_charges > 0:
		return _poison_blade_damage
	return 0

func consume_poison_blade_charge() -> void:
	## Use one Poison Blade charge after an attack
	if _poison_blade_charges > 0:
		_poison_blade_charges -= 1
		print("[Unit] %s Poison Blade: %d charges remaining" % [
			unit_name, _poison_blade_charges
		])
		if _poison_blade_charges == 0:
			_poison_blade_damage = 0
			print("[Unit] %s Poison Blade expired" % unit_name)

func has_poison_blade() -> bool:
	## Check if Poison Blade is currently active
	return _poison_blade_charges > 0

func get_poison_blade_charges() -> int:
	## Get remaining Poison Blade charges
	return _poison_blade_charges

# ===== ATTACK OF OPPORTUNITY API (Task 2.13) =====
func can_perform_opportunity_attack() -> bool:
	## Check if this unit can perform an attack of opportunity
	## Only melee units can perform AoO, and only once per turn
	if not is_alive():
		return false
	if is_ranged_weapon:
		return false  # Ranged units cannot perform AoO
	if _opportunity_attack_used:
		return false  # Already used AoO this turn
	return true

func mark_opportunity_attack_used() -> void:
	## Mark that this unit has used their opportunity attack this turn
	_opportunity_attack_used = true
	print("[Unit] %s used their opportunity attack this turn" % unit_name)

func reset_opportunity_attack() -> void:
	## Reset opportunity attack flag (called at start of unit's turn)
	_opportunity_attack_used = false

func has_used_opportunity_attack() -> bool:
	## Check if unit has already used their AoO this turn
	return _opportunity_attack_used

func is_adjacent_to(other: Unit) -> bool:
	## Check if this unit is adjacent to another unit (8-directional)
	if not other or not is_instance_valid(other):
		return false
	var diff = other.grid_position - grid_position
	return abs(diff.x) <= 1 and abs(diff.y) <= 1 and diff != Vector2i.ZERO

# ===== TELEPORT API (Task 2.5) =====
func teleport_to(destination: Vector2i) -> void:
	## Instantly teleport to a grid position (for Shadowstep)
	var old_position = grid_position
	grid_position = destination

	# Update facing based on teleport direction
	_update_facing_from_movement(old_position, destination)

	# Snap to new position immediately
	if combat_grid:
		position = combat_grid.grid_to_world(destination)

	print("[Unit] %s teleported from %s to %s" % [unit_name, old_position, destination])
	unit_moved.emit(self, old_position, destination)

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
	_spawn_nameplate()  # Task 4.3: Floating nameplate
	_setup_order_icon()  # Task 2.8: Order icon for soldiers
	add_to_group("units")

	# Set enemy flag based on unit type (Task 2.15: includes all enemy types)
	is_enemy = (unit_type == UnitType.ENEMY or
		unit_type == UnitType.BANDIT_ARCHER or
		unit_type == UnitType.BANDIT_LEADER or
		unit_type == UnitType.IRONMARK_SOLDIER or
		unit_type == UnitType.IRONMARK_KNIGHT)

	# Set soldier flag based on unit type (Task 1.9)
	is_soldier = (unit_type == UnitType.INFANTRY or unit_type == UnitType.ARCHER)

	# Task 2.15: Set faction flags for ability targeting
	is_bandit = (unit_type == UnitType.ENEMY or
		unit_type == UnitType.BANDIT_ARCHER or
		unit_type == UnitType.BANDIT_LEADER)

	is_ironmark = (unit_type == UnitType.IRONMARK_SOLDIER or
		unit_type == UnitType.IRONMARK_KNIGHT)

	# Debug print stats
	print("[Unit] %s stats: STR %d(%+d) DEX %d(%+d) HP %d DEF %d ATK %+d Move %d" % [
		unit_name, strength, get_str_mod(), dexterity, get_dex_mod(),
		max_hp, get_defense(), get_attack_bonus(), movement_range
	])

func _exit_tree() -> void:
	## Cleanup when unit is removed from scene tree (e.g., map change)
	# Clean up nameplate which is parented to root
	if _nameplate and is_instance_valid(_nameplate):
		_nameplate.queue_free()
		_nameplate = null

func _update_visual() -> void:
	## Update sprite and label based on unit type
	_generate_sprite_texture()
	_update_letter_label()

func _generate_sprite_texture() -> void:
	## Generate a distinctive sprite for the unit using UnitSpriteGenerator
	## Task 5.1: Programmatic Visual Assets
	var texture = UnitSpriteGenerator.generate_sprite(unit_type)
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
	click_area.input_pickable = true
	click_area.input_event.connect(_on_click_area_input_event)
	print("[Unit] Click detection setup for %s (input_pickable=%s, is_enemy=%s)" % [
		unit_name, click_area.input_pickable, is_enemy
	])

func _spawn_nameplate() -> void:
	## Spawn floating nameplate above unit (Task 4.3)
	if UnitNameplateScene:
		_nameplate = UnitNameplateScene.instantiate()
		# Add to root canvas layer so it appears above game elements
		get_tree().root.add_child.call_deferred(_nameplate)
		# Setup after adding to tree
		_nameplate.call_deferred("setup", self)
		print("[Unit] Nameplate spawned for %s" % unit_name)

func _on_click_area_input_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	## Handle click input on unit
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("[Unit] LEFT CLICK on %s (is_enemy=%s, is_targeting=%s)" % [
				unit_name, is_enemy, CombatManager.is_targeting_ability()
			])
			_handle_click()
			# Mark input as handled to prevent other handlers from processing it
			viewport.set_input_as_handled()

func _handle_click() -> void:
	## Process click on this unit
	unit_clicked.emit(self)

	print("[Unit] _handle_click on %s, is_targeting=%s, is_assigning_order=%s, turn_state=%s" % [
		unit_name,
		CombatManager.is_targeting_ability(),
		CombatManager.is_assigning_order(),
		CombatManager.get_turn_state()
	])

	# Check if we're in order assignment mode (Task 2.10)
	if CombatManager.is_assigning_order():
		print("[Unit] In order assignment mode, attempting to assign order to %s" % unit_name)
		if CombatManager.try_assign_order(self):
			print("[Unit] SUCCESS: Order assigned to: %s" % unit_name)
		else:
			print("[Unit] FAILED: Cannot assign order to: %s (not a soldier or invalid)" % unit_name)
		return

	# Check if we're in ability targeting mode (Task 2.3)
	if CombatManager.is_targeting_ability():
		print("[Unit] In targeting mode, attempting to select %s as target" % unit_name)
		# Try to select this unit as the ability target
		if CombatManager.select_ability_target(self):
			print("[Unit] SUCCESS: Selected as ability target: %s" % unit_name)
		else:
			print("[Unit] FAILED: Not a valid ability target: %s" % unit_name)
		return

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
	## Apply damage to unit and update HP bar (Task 2.4: includes Last Stand check)
	var new_hp = current_hp - amount

	# Check for lethal damage and Last Stand (Task 2.4)
	if new_hp <= 0:
		if _check_last_stand():
			new_hp = 1  # Survive at 1 HP
			_on_last_stand_triggered()
			print("[Unit] %s Last Stand triggered! HP set to 1" % unit_name)

	current_hp = max(0, new_hp)
	_update_hp_bar()
	unit_damaged.emit(self, amount)

	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	## Heal unit and update HP bar
	current_hp = min(max_hp, current_hp + amount)
	_update_hp_bar()

# ===== LAST STAND (Task 2.4) =====
func _check_last_stand() -> bool:
	## Check if Last Stand should trigger
	# Must have Last Stand ability
	if not has_ability("last_stand"):
		return false

	# Must not have used it already
	if get_ability_uses("last_stand") >= 1:
		return false

	return true

func _on_last_stand_triggered() -> void:
	## Handle Last Stand activation (Task 2.4)
	# Mark ability as used
	use_ability("last_stand")

	# Apply Last Stand visual indicator status effect
	var sem = get_node_or_null("/root/StatusEffectManager")
	if sem:
		sem.apply_effect(self, "LAST_STAND", 1, 0)

	# TODO: Spawn "LAST STAND!" floating text
	# TODO: Visual golden glow effect

	print("[Unit] %s's Last Stand activated! Surviving at 1 HP" % unit_name)

func has_ability(ability_id: String) -> bool:
	## Check if this unit has a specific ability (Task 2.4)
	for ability in _abilities:
		if ability.get("id") == ability_id:
			return true
	return false

func _die() -> void:
	## Handle unit death with fade animation
	unit_died.emit(self)

	# Disable click detection
	if click_area:
		click_area.input_pickable = false

	# Nameplate handles its own cleanup via unit_died signal (Task 4.3)

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

	# Update facing direction based on last movement direction (Task 2.5)
	_update_facing_from_movement(old_pos, final_coords)

	movement_finished.emit(self)
	unit_moved.emit(self, old_pos, final_coords)

# ===== ATTACK HANDLING (Task 1.7, Task 2.7) =====
func can_attack(target: Unit) -> bool:
	## Check if this unit can attack the target (supports melee and ranged)
	if target == null or target == self:
		return false
	if not is_alive() or not target.is_alive():
		return false
	if target.is_friendly() == is_friendly():
		return false  # No friendly fire

	# Task 2.7: Use ranged attack check for range and LoS
	if not AttackResolver.can_attack_at_range(self, target):
		return false

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
		# Task 2.11: Check for PROTECT interception
		var actual_target = target
		var interception = CombatManager.try_intercept_attack(target, result.damage)
		if interception.intercepted and interception.protector:
			actual_target = interception.protector
			print("[Unit] %s intercepts attack on %s!" % [actual_target.unit_name, target.unit_name])
			# Spawn intercept indicator on protector
			_spawn_intercept_indicator(actual_target)

		actual_target.take_damage(result.damage)
		actual_target.attack_received.emit(self, result.damage)

	# Log the attack (Task 2.12: include terrain bonus info)
	var terrain_attack_str = ""
	var terrain_defense_str = ""
	if result.terrain_attack_bonus > 0:
		terrain_attack_str = " (+%d high ground)" % result.terrain_attack_bonus
	if result.terrain_defense_bonus > 0:
		terrain_defense_str = " (+%d cover)" % result.terrain_defense_bonus

	print("[Unit] %s attacks %s: Roll %d + %d%s = %d vs DEF %d%s -> %s for %d damage%s" % [
		unit_name,
		target.unit_name,
		result.roll,
		result.total_attack - result.roll - result.terrain_attack_bonus,
		terrain_attack_str,
		result.total_attack,
		result.target_defense,
		terrain_defense_str,
		"HIT" if result.hit else "MISS",
		result.damage,
		" (CRITICAL!)" if result.is_critical else ""
	])

func _spawn_damage_number(target: Unit, result: AttackResolver.AttackResult) -> void:
	## Create floating damage number at target
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target (must be after adding to tree)
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display appropriate text
	if result.hit:
		damage_number.show_damage(result.damage, result.is_critical)
	else:
		damage_number.show_miss()

func _spawn_intercept_indicator(protector: Unit) -> void:
	## Show visual feedback when a soldier intercepts an attack (Task 2.11: PROTECT)
	# Create a damage number to show "BLOCKED!" text
	var indicator = DamageNumberScene.instantiate() as DamageNumber
	# Add to tree FIRST (required for global_position to work correctly)
	protector.get_parent().add_child(indicator)
	indicator.global_position = protector.global_position + Vector2(0, -50)
	# Blue color for protection intercept
	indicator.show_text("BLOCKED!", Color(0.2, 0.6, 1.0))

	# Brief flash on protector
	var tween = protector.create_tween()
	tween.tween_property(protector, "modulate", Color(0.5, 0.5, 1.0), 0.1)
	tween.tween_property(protector, "modulate", Color.WHITE, 0.2)

# ===== STATIC HELPERS =====
static func get_unit_display_name(type: UnitType) -> String:
	## Get display name for unit type
	match type:
		UnitType.PLAYER: return "Player"
		UnitType.THORNE: return "Thorne"
		UnitType.LYRA: return "Lyra"
		UnitType.MATTHIAS: return "Matthias"
		UnitType.ENEMY: return "Bandit"
		UnitType.INFANTRY: return "Infantry"
		UnitType.ARCHER: return "Archer"
		UnitType.BANDIT_ARCHER: return "Bandit Archer"
		UnitType.BANDIT_LEADER: return "Bandit Leader"
		UnitType.IRONMARK_SOLDIER: return "Ironmark Soldier"
		UnitType.IRONMARK_KNIGHT: return "Ironmark Knight"
		_: return "Unknown"
