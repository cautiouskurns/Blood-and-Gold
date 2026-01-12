## AttackResolver - Handles attack rolls and damage calculation
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.7-basic-melee-attack.md
class_name AttackResolver
extends RefCounted

# ===== ATTACK RESULT CLASS =====
class AttackResult:
	var hit: bool = false
	var damage: int = 0
	var roll: int = 0
	var total_attack: int = 0
	var target_defense: int = 0
	var is_critical: bool = false

# ===== PUBLIC API =====
static func resolve_attack(attacker: Unit, target: Unit) -> AttackResult:
	## Roll attack and calculate damage
	var result = AttackResult.new()

	# Get attacker stats
	var attack_bonus = _get_attack_bonus(attacker)
	var damage_dice = _get_damage_dice(attacker)
	var damage_modifier = _get_damage_modifier(attacker)

	# Get target defense
	result.target_defense = _get_defense(target)

	# Roll attack (d20)
	result.roll = randi_range(1, 20)
	result.total_attack = result.roll + attack_bonus

	# Check for hit
	result.hit = result.total_attack >= result.target_defense

	# Natural 20 = critical hit (always hits)
	if result.roll == 20:
		result.is_critical = true
		result.hit = true

	# Calculate damage on hit
	if result.hit:
		result.damage = _roll_damage(damage_dice, damage_modifier)
		if result.is_critical:
			result.damage *= 2

	return result

static func is_adjacent(attacker: Unit, target: Unit) -> bool:
	## Check if two units are adjacent (within 1 tile, including diagonals)
	var diff = target.grid_position - attacker.grid_position
	return abs(diff.x) <= 1 and abs(diff.y) <= 1 and diff != Vector2i.ZERO

# ===== INTERNAL HELPERS =====
static func _get_attack_bonus(unit: Unit) -> int:
	## Get total attack bonus for a unit
	## Prototype: Hardcoded based on unit type from GDD
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return 4  # STR 14 (+2) + Skill (+2)
		Unit.UnitType.THORNE:
			return 5  # STR 16 (+3) + Skill (+2)
		Unit.UnitType.LYRA:
			return 5  # DEX 16 (+3) + Skill (+2) - finesse
		Unit.UnitType.MATTHIAS:
			return 2  # STR 10 (+0) + Skill (+2)
		Unit.UnitType.ENEMY:
			return 3  # Bandit attack bonus
		Unit.UnitType.INFANTRY:
			return 3
		Unit.UnitType.ARCHER:
			return 3
		_:
			return 0

static func _get_defense(unit: Unit) -> int:
	## Get defense value for a unit
	## Defense = 10 + DEX modifier + Armor bonus
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return 14  # 10 + DEX 12 (+1) + Chain Shirt (+3)
		Unit.UnitType.THORNE:
			return 16  # 10 + DEX 10 (+0) + Plate (+6)
		Unit.UnitType.LYRA:
			return 15  # 10 + DEX 16 (+3) + Leather (+2)
		Unit.UnitType.MATTHIAS:
			return 13  # 10 + DEX 10 (+0) + Chain Shirt (+3)
		Unit.UnitType.ENEMY:
			return 12  # Bandit defense
		Unit.UnitType.INFANTRY:
			return 13
		Unit.UnitType.ARCHER:
			return 11
		_:
			return 10

static func _get_damage_dice(unit: Unit) -> int:
	## Get weapon damage die (e.g., 8 for 1d8)
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return 8  # Sword 1d8
		Unit.UnitType.THORNE:
			return 8  # Sword 1d8
		Unit.UnitType.LYRA:
			return 4  # Dagger 1d4
		Unit.UnitType.MATTHIAS:
			return 6  # Staff 1d6
		Unit.UnitType.ENEMY:
			return 6  # Bandit weapon 1d6
		Unit.UnitType.INFANTRY:
			return 6
		Unit.UnitType.ARCHER:
			return 6
		_:
			return 6

static func _get_damage_modifier(unit: Unit) -> int:
	## Get damage modifier (usually STR, or DEX for finesse)
	match unit.unit_type:
		Unit.UnitType.PLAYER:
			return 2  # STR 14 (+2)
		Unit.UnitType.THORNE:
			return 3  # STR 16 (+3)
		Unit.UnitType.LYRA:
			return 3  # DEX 16 (+3) - finesse
		Unit.UnitType.MATTHIAS:
			return 0  # STR 10 (+0)
		Unit.UnitType.ENEMY:
			return 2  # Bandit STR
		Unit.UnitType.INFANTRY:
			return 1
		Unit.UnitType.ARCHER:
			return 0
		_:
			return 0

static func _roll_damage(dice: int, modifier: int) -> int:
	## Roll damage: 1d[dice] + modifier
	return randi_range(1, dice) + modifier
