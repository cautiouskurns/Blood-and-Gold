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
	## Get total attack bonus from unit's stats (Task 2.1)
	return unit.get_attack_bonus()

static func _get_defense(unit: Unit) -> int:
	## Get defense value from unit's stats (Task 2.1)
	return unit.get_defense()

static func _get_damage_dice(unit: Unit) -> int:
	## Get weapon damage die from unit's stats (Task 2.1)
	return unit.get_damage_die()

static func _get_damage_modifier(unit: Unit) -> int:
	## Get damage modifier from unit's stats (Task 2.1)
	return unit.get_damage_modifier()

static func _roll_damage(dice: int, modifier: int) -> int:
	## Roll damage: 1d[dice] + modifier
	return randi_range(1, dice) + modifier
