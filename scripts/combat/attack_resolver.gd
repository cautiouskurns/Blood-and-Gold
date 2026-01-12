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

# ===== RANGED ATTACK SUPPORT (Task 2.7) =====
static func get_distance(from: Vector2i, to: Vector2i) -> int:
	## Calculate Chebyshev distance (king moves) between two positions
	return maxi(absi(to.x - from.x), absi(to.y - from.y))

static func can_attack_at_range(attacker: Unit, target: Unit) -> bool:
	## Check if attacker can attack target considering weapon range and LoS
	var distance = get_distance(attacker.grid_position, target.grid_position)

	# Check if within weapon range
	if distance > attacker.weapon_range:
		return false

	# Melee weapons (range 1) don't need LoS check
	if attacker.weapon_range == 1:
		return distance == 1

	# Ranged weapons need line of sight check
	if attacker.is_ranged_weapon and distance > 1:
		if not has_line_of_sight(attacker.grid_position, target.grid_position):
			return false

	return true

static func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	## Check if there's a clear line of sight using Bresenham algorithm
	## Returns true if no obstacles block the path
	var points = get_line_points(from, to)

	for point in points:
		# Skip start and end points (attacker and target positions)
		if point == from or point == to:
			continue
		# Check if tile blocks line of sight
		if CombatManager.is_tile_blocked_for_los(point):
			return false

	return true

static func get_line_points(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	## Bresenham's line algorithm - returns all points on the line
	var points: Array[Vector2i] = []

	var dx = absi(to.x - from.x)
	var dy = absi(to.y - from.y)
	var sx = 1 if from.x < to.x else -1
	var sy = 1 if from.y < to.y else -1
	var err = dx - dy

	var x = from.x
	var y = from.y

	while true:
		points.append(Vector2i(x, y))

		if x == to.x and y == to.y:
			break

		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy

	return points

static func get_valid_targets_in_range(attacker: Unit, enemies: Array[Unit]) -> Array[Unit]:
	## Filter enemies to only those within weapon range and LoS (Task 2.7)
	var valid_targets: Array[Unit] = []

	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.is_alive():
			continue
		if can_attack_at_range(attacker, enemy):
			valid_targets.append(enemy)

	return valid_targets

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
