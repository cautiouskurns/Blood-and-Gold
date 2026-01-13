## EnemyAI - Handles autonomous turn execution for enemy units
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.14-enemy-ai-basic.md
## Task 2.14: Enemies act automatically with role-based behaviors
class_name EnemyAI
extends RefCounted

# ===== CONSTANTS =====
const MOVE_DELAY: float = 0.15      # Seconds per tile during movement
const ACTION_DELAY: float = 0.2     # Pause before action
const TURN_END_DELAY: float = 0.3   # Pause after action before ending turn

# AI Role identifiers
const ROLE_MELEE: String = "melee"
const ROLE_RANGED: String = "ranged"
const ROLE_LEADER: String = "leader"
const ROLE_TANK: String = "tank"

# Aggro weight constants
const AGGRO_LOW_HP: int = 50         # Target has lowest HP%
const AGGRO_HIGH_THREAT: int = 30    # Target dealt most damage this battle
const AGGRO_IN_RANGE: int = 20       # Target is within weapon range
const AGGRO_NEAREST: int = 10        # Target is nearest by tile distance
const AGGRO_SOLDIER_PENALTY: int = -10  # Prefer party members over soldiers

# Ranged AI constants
const ARCHER_PREFERRED_RANGE_MIN: int = 5
const ARCHER_PREFERRED_RANGE_MAX: int = 8
const ARCHER_RETREAT_THRESHOLD: int = 3  # Retreat if enemy closer than this

# Enemy role mapping (based on UnitType)
# Task 2.15: Map new enemy types to AI roles
const ENEMY_ROLES: Dictionary = {
	# UnitType enum values:
	# 4 = ENEMY (Bandit Melee) -> melee
	# 7 = BANDIT_ARCHER -> ranged
	# 8 = BANDIT_LEADER -> leader
	# 9 = IRONMARK_SOLDIER -> tank
	# 10 = IRONMARK_KNIGHT -> melee (aggressive charger)
	4: ROLE_MELEE,          # ENEMY (Bandit Melee)
	7: ROLE_RANGED,         # BANDIT_ARCHER
	8: ROLE_LEADER,         # BANDIT_LEADER
	9: ROLE_TANK,           # IRONMARK_SOLDIER (Shield Wall, hold formation)
	10: ROLE_MELEE,         # IRONMARK_KNIGHT (aggressive melee, TODO: charge behavior)
}

# ===== MAIN ENTRY POINT =====
static func execute_turn(enemy: Unit, combat_grid: CombatGrid) -> void:
	## Execute an enemy's turn based on their AI role
	## Called by TurnManager when it's an enemy's turn
	if not is_instance_valid(enemy) or not enemy.is_alive():
		print("[EnemyAI] Invalid or dead enemy, ending turn")
		await _wait(enemy, TURN_END_DELAY)
		return

	if not enemy.is_enemy:
		push_error("[EnemyAI] execute_turn called on non-enemy: %s" % enemy.unit_name)
		await _wait(enemy, TURN_END_DELAY)
		return

	var role = _determine_role(enemy)
	print("[EnemyAI] Executing turn for %s (Role: %s, Ranged: %s)" % [
		enemy.unit_name, role, enemy.is_ranged_weapon
	])

	# Get all potential targets
	var targets = _get_valid_targets(enemy)
	if targets.is_empty():
		print("[EnemyAI] %s has no valid targets, ending turn" % enemy.unit_name)
		await _wait(enemy, TURN_END_DELAY)
		return

	# Select target based on role and aggro priority
	var target = _select_target(enemy, targets, role)

	if target:
		print("[EnemyAI] %s targeting %s" % [enemy.unit_name, target.unit_name])
		await _execute_role_behavior(enemy, target, role, combat_grid)
	else:
		print("[EnemyAI] %s could not select a target" % enemy.unit_name)

	# End turn after action
	await _wait(enemy, TURN_END_DELAY)
	print("[EnemyAI] %s turn complete" % enemy.unit_name)

# ===== ROLE DETERMINATION =====
static func _determine_role(enemy: Unit) -> String:
	## Determine AI role based on enemy properties
	# Check role mapping first
	if ENEMY_ROLES.has(enemy.unit_type):
		return ENEMY_ROLES[enemy.unit_type]

	# Fallback: determine by weapon type
	if enemy.is_ranged_weapon:
		return ROLE_RANGED

	# Default to melee behavior
	return ROLE_MELEE

# ===== TARGET SELECTION =====
static func _select_target(enemy: Unit, targets: Array[Unit], role: String) -> Unit:
	## Select the best target based on role and aggro priority
	if targets.is_empty():
		return null

	var best_target: Unit = null
	var best_priority: int = -9999

	for target in targets:
		var priority = _calculate_target_priority(enemy, target, role)
		if priority > best_priority:
			best_priority = priority
			best_target = target

	return best_target

static func _calculate_target_priority(enemy: Unit, target: Unit, role: String) -> int:
	## Calculate aggro priority for a potential target
	var priority: int = 0
	var distance = _get_tile_distance(enemy.grid_position, target.grid_position)

	# Priority 1: Low HP targets (all roles prioritize wounded targets)
	var hp_percent = target.get_hp_percentage()
	if hp_percent < 1.0:
		# Scale bonus based on how low HP is
		priority += int(AGGRO_LOW_HP * (1.0 - hp_percent))

	# Priority 2: High threat targets (track damage dealt - simplified for prototype)
	# Note: For prototype, we skip damage tracking and use other factors

	# Priority 3: In weapon range
	if distance <= enemy.weapon_range:
		priority += AGGRO_IN_RANGE

	# Priority 4: Nearest target (higher bonus for closer targets)
	var max_range = 20  # Arbitrary max for normalization
	var distance_bonus = int(AGGRO_NEAREST * (1.0 - float(distance) / float(max_range)))
	priority += distance_bonus

	# Priority 5: Prefer party members over soldiers
	if target.is_soldier:
		priority += AGGRO_SOLDIER_PENALTY

	# Role-specific adjustments
	match role:
		ROLE_LEADER:
			# Leaders target highest threat (simplified: lowest HP% party member)
			if not target.is_soldier and hp_percent < 0.5:
				priority += 20
		ROLE_RANGED:
			# Ranged units prefer targets they can hit without moving
			if distance >= 2 and distance <= enemy.weapon_range:
				priority += 15

	return priority

# ===== ROLE BEHAVIORS =====
static func _execute_role_behavior(enemy: Unit, target: Unit, role: String, combat_grid: CombatGrid) -> void:
	## Execute behavior based on AI role
	match role:
		ROLE_MELEE:
			await _execute_melee_behavior(enemy, target, combat_grid)
		ROLE_RANGED:
			await _execute_ranged_behavior(enemy, target, combat_grid)
		ROLE_LEADER:
			await _execute_leader_behavior(enemy, target, combat_grid)
		ROLE_TANK:
			await _execute_tank_behavior(enemy, target, combat_grid)
		_:
			# Default to melee
			await _execute_melee_behavior(enemy, target, combat_grid)

# ===== MELEE BEHAVIOR =====
static func _execute_melee_behavior(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> void:
	## MELEE: Move toward target and attack when adjacent
	print("[EnemyAI] %s executing MELEE behavior" % enemy.unit_name)

	var distance = _get_tile_distance(enemy.grid_position, target.grid_position)

	# Already adjacent? Attack without moving
	if distance == 1:
		print("[EnemyAI] %s already adjacent, attacking %s" % [enemy.unit_name, target.unit_name])
		await _wait(enemy, ACTION_DELAY)
		enemy.perform_attack(target)
		return

	# Move toward target
	var moved = await _move_toward_target(enemy, target, combat_grid)

	if moved:
		await _wait(enemy, ACTION_DELAY)

	# Check if now adjacent and can attack
	distance = _get_tile_distance(enemy.grid_position, target.grid_position)
	if distance == 1:
		print("[EnemyAI] %s now adjacent, attacking %s" % [enemy.unit_name, target.unit_name])
		enemy.perform_attack(target)
	else:
		print("[EnemyAI] %s could not reach %s (distance: %d)" % [
			enemy.unit_name, target.unit_name, distance
		])

# ===== RANGED BEHAVIOR =====
static func _execute_ranged_behavior(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> void:
	## RANGED: Maintain distance and shoot from range
	print("[EnemyAI] %s executing RANGED behavior" % enemy.unit_name)

	var distance = _get_tile_distance(enemy.grid_position, target.grid_position)
	var targets = _get_valid_targets(enemy)

	# Check if enemy is too close - need to retreat
	var needs_retreat = _should_ranged_retreat(enemy, targets)

	if needs_retreat:
		print("[EnemyAI] %s retreating from nearby threats" % enemy.unit_name)
		var retreated = await _execute_ranged_retreat(enemy, combat_grid, targets)
		if retreated:
			await _wait(enemy, ACTION_DELAY)

	# Update distance after potential retreat
	distance = _get_tile_distance(enemy.grid_position, target.grid_position)

	# Check if target is in range and has LoS
	if distance <= enemy.weapon_range and distance >= 2:
		if AttackResolver.has_line_of_sight(enemy.grid_position, target.grid_position):
			print("[EnemyAI] %s shooting %s from range %d" % [
				enemy.unit_name, target.unit_name, distance
			])
			await _wait(enemy, ACTION_DELAY)
			enemy.perform_attack(target)
			return

	# Not in range or no LoS - try to find a firing position
	if not needs_retreat:
		var moved = await _move_to_firing_position(enemy, target, combat_grid)
		if moved:
			await _wait(enemy, ACTION_DELAY)
			# Try to attack after moving
			distance = _get_tile_distance(enemy.grid_position, target.grid_position)
			if distance <= enemy.weapon_range and AttackResolver.has_line_of_sight(enemy.grid_position, target.grid_position):
				print("[EnemyAI] %s now in range, shooting %s" % [enemy.unit_name, target.unit_name])
				enemy.perform_attack(target)
			else:
				print("[EnemyAI] %s still cannot attack (distance: %d)" % [enemy.unit_name, distance])
	else:
		# Cornered - forced to melee
		if distance == 1:
			print("[EnemyAI] %s cornered, using melee attack on %s" % [enemy.unit_name, target.unit_name])
			await _wait(enemy, ACTION_DELAY)
			enemy.perform_attack(target)

static func _should_ranged_retreat(enemy: Unit, targets: Array[Unit]) -> bool:
	## Check if any target is too close (within retreat threshold)
	for target in targets:
		var dist = _get_tile_distance(enemy.grid_position, target.grid_position)
		if dist < ARCHER_RETREAT_THRESHOLD:
			return true
	return false

static func _execute_ranged_retreat(enemy: Unit, combat_grid: CombatGrid, targets: Array[Unit]) -> bool:
	## Move ranged enemy away from nearby threats
	if not combat_grid:
		return false

	# Find the closest threatening target
	var closest_threat: Unit = null
	var closest_dist: int = 999

	for target in targets:
		var dist = _get_tile_distance(enemy.grid_position, target.grid_position)
		if dist < ARCHER_RETREAT_THRESHOLD and dist < closest_dist:
			closest_dist = dist
			closest_threat = target

	if not closest_threat:
		return false

	# Calculate retreat direction (away from threat)
	var retreat_direction = enemy.grid_position - closest_threat.grid_position
	if retreat_direction == Vector2i.ZERO:
		retreat_direction = Vector2i(0, 1)  # Default: retreat south

	# Find best retreat position
	var retreat_pos = _find_retreat_position(enemy, retreat_direction.sign(), combat_grid, targets)

	if retreat_pos == enemy.grid_position:
		print("[EnemyAI] %s cannot retreat (no valid position)" % enemy.unit_name)
		return false

	# Execute movement
	return await _move_to_position(enemy, retreat_pos, combat_grid)

static func _find_retreat_position(enemy: Unit, retreat_dir: Vector2i, combat_grid: CombatGrid, targets: Array[Unit]) -> Vector2i:
	## Find the best position to retreat to
	var current_pos = enemy.grid_position
	var best_pos = current_pos
	var best_score: float = -999.0

	var norm_dir = retreat_dir.sign()
	if norm_dir == Vector2i.ZERO:
		norm_dir = Vector2i(0, 1)

	# Check positions in retreat direction and nearby
	var candidates: Array[Vector2i] = []

	for dist in range(1, 4):  # Check up to 3 tiles away
		candidates.append(current_pos + norm_dir * dist)
		# Also check perpendicular
		var perp = Vector2i(norm_dir.y, -norm_dir.x)
		candidates.append(current_pos + perp * dist)
		candidates.append(current_pos - perp * dist)
		candidates.append(current_pos + norm_dir * dist + perp)
		candidates.append(current_pos + norm_dir * dist - perp)

	for candidate in candidates:
		if not combat_grid.is_valid_position(candidate):
			continue
		if CombatManager.is_tile_occupied(candidate):
			continue

		# Score based on distance from all targets
		var min_target_dist = 999
		for target in targets:
			var d = _get_tile_distance(candidate, target.grid_position)
			min_target_dist = mini(min_target_dist, d)

		var score = float(min_target_dist)

		# Bonus for preferred range
		if min_target_dist >= ARCHER_PREFERRED_RANGE_MIN and min_target_dist <= ARCHER_PREFERRED_RANGE_MAX:
			score += 5.0

		if score > best_score:
			best_score = score
			best_pos = candidate

	return best_pos

static func _move_to_firing_position(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> bool:
	## Move to a position where we can shoot the target
	if not combat_grid:
		return false

	var target_pos = target.grid_position
	var weapon_range = enemy.weapon_range
	var targets = _get_valid_targets(enemy)

	var best_pos = enemy.grid_position
	var best_path: Array[Vector2i] = []
	var best_score: float = -999.0

	# Check tiles at various ranges
	for dx in range(-weapon_range, weapon_range + 1):
		for dy in range(-weapon_range, weapon_range + 1):
			var candidate = target_pos + Vector2i(dx, dy)
			var dist_to_target = _get_tile_distance(candidate, target_pos)

			# Must be within weapon range but not too close
			if dist_to_target < 2 or dist_to_target > weapon_range:
				continue

			if not combat_grid.is_valid_position(candidate):
				continue
			if CombatManager.is_tile_occupied(candidate) and candidate != enemy.grid_position:
				continue

			# Check LoS from candidate to target
			if not AttackResolver.has_line_of_sight(candidate, target_pos):
				continue

			# Check pathfinding
			_update_occupied_tiles(enemy, combat_grid)
			var path = combat_grid.pathfinding.get_path(enemy.grid_position, candidate, enemy)
			if path.size() < 2:
				continue

			# Score: prefer farther from other targets, shorter path, at preferred range
			var min_enemy_dist = 999
			for t in targets:
				var d = _get_tile_distance(candidate, t.grid_position)
				min_enemy_dist = mini(min_enemy_dist, d)

			var score = float(min_enemy_dist) - float(path.size()) * 0.1

			# Bonus for preferred range
			if dist_to_target >= ARCHER_PREFERRED_RANGE_MIN and dist_to_target <= ARCHER_PREFERRED_RANGE_MAX:
				score += 3.0

			if score > best_score and path.size() <= enemy.movement_range + 1:
				best_score = score
				best_pos = candidate
				best_path = path

	if best_path.is_empty() or best_path.size() < 2:
		return false

	# Limit path to movement range
	var limited_path = _limit_path(best_path, enemy.movement_range)

	print("[EnemyAI] %s moving to firing position: %s" % [enemy.unit_name, limited_path])
	enemy.move_along_path(limited_path)
	await enemy.movement_finished
	return true

# ===== LEADER BEHAVIOR =====
static func _execute_leader_behavior(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> void:
	## LEADER: Stay protected, use buff abilities, then attack
	print("[EnemyAI] %s executing LEADER behavior" % enemy.unit_name)

	# TODO: Check for Rally Bandits ability when abilities are implemented for enemies
	# For now, leaders act like ranged units if ranged, or melee if melee

	if enemy.is_ranged_weapon:
		await _execute_ranged_behavior(enemy, target, combat_grid)
	else:
		# Leaders try to stay back - don't rush forward unless necessary
		var distance = _get_tile_distance(enemy.grid_position, target.grid_position)

		if distance == 1:
			# Already adjacent, attack
			print("[EnemyAI] Leader %s attacking adjacent target %s" % [enemy.unit_name, target.unit_name])
			await _wait(enemy, ACTION_DELAY)
			enemy.perform_attack(target)
		else:
			# Don't advance aggressively - wait for targets to come closer
			print("[EnemyAI] Leader %s holding position (distance: %d)" % [enemy.unit_name, distance])

# ===== TANK BEHAVIOR =====
static func _execute_tank_behavior(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> void:
	## TANK: Hold position, form shield wall, attack approaching enemies
	print("[EnemyAI] %s executing TANK behavior" % enemy.unit_name)

	var distance = _get_tile_distance(enemy.grid_position, target.grid_position)

	# Tank: Attack adjacent enemies, don't move unless absolutely necessary
	if distance == 1:
		print("[EnemyAI] Tank %s attacking adjacent target %s" % [enemy.unit_name, target.unit_name])
		await _wait(enemy, ACTION_DELAY)
		enemy.perform_attack(target)
	else:
		# Tanks hold position - no movement
		print("[EnemyAI] Tank %s holding position (no adjacent targets)" % enemy.unit_name)

# ===== MOVEMENT HELPERS =====
static func _move_toward_target(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> bool:
	## Move enemy toward target using pathfinding
	if not combat_grid:
		return false

	_update_occupied_tiles(enemy, combat_grid)

	# Get path to adjacent tile of target
	var path = _get_path_to_adjacent(enemy, target, combat_grid)

	if path.is_empty() or path.size() < 2:
		print("[EnemyAI] %s no valid path to %s" % [enemy.unit_name, target.unit_name])
		return false

	# Limit path to movement range
	var limited_path = _limit_path(path, enemy.movement_range)

	if limited_path.size() < 2:
		return false

	print("[EnemyAI] %s moving along path: %s" % [enemy.unit_name, limited_path])
	enemy.move_along_path(limited_path)
	await enemy.movement_finished
	return true

static func _move_to_position(enemy: Unit, destination: Vector2i, combat_grid: CombatGrid) -> bool:
	## Move enemy to a specific position
	if not combat_grid:
		return false

	_update_occupied_tiles(enemy, combat_grid)

	var path = combat_grid.pathfinding.get_path(enemy.grid_position, destination, enemy)

	if path.size() < 2:
		return false

	var limited_path = _limit_path(path, enemy.movement_range)

	if limited_path.size() < 2:
		return false

	print("[EnemyAI] %s moving to position: %s" % [enemy.unit_name, limited_path])
	enemy.move_along_path(limited_path)
	await enemy.movement_finished
	return true

static func _get_path_to_adjacent(enemy: Unit, target: Unit, combat_grid: CombatGrid) -> Array[Vector2i]:
	## Get path to a tile adjacent to target
	var target_pos = target.grid_position
	var adjacent_tiles = [
		target_pos + Vector2i(1, 0),
		target_pos + Vector2i(-1, 0),
		target_pos + Vector2i(0, 1),
		target_pos + Vector2i(0, -1),
		target_pos + Vector2i(1, 1),
		target_pos + Vector2i(-1, 1),
		target_pos + Vector2i(1, -1),
		target_pos + Vector2i(-1, -1),
	]

	var best_path: Array[Vector2i] = []
	var best_length: int = 999

	for adj_tile in adjacent_tiles:
		if not combat_grid.is_valid_position(adj_tile):
			continue
		if CombatManager.is_tile_occupied(adj_tile) and adj_tile != enemy.grid_position:
			continue

		var path = combat_grid.pathfinding.get_path(enemy.grid_position, adj_tile, enemy)
		if path.size() >= 2 and path.size() < best_length:
			best_path = path
			best_length = path.size()

	return best_path

static func _limit_path(path: Array[Vector2i], movement_range: int) -> Array[Vector2i]:
	## Limit path to movement range
	var limited: Array[Vector2i] = []
	limited.append(path[0])

	for i in range(1, mini(path.size(), movement_range + 1)):
		limited.append(path[i])

	return limited

static func _update_occupied_tiles(enemy: Unit, combat_grid: CombatGrid) -> void:
	## Update occupied tiles for pathfinding
	var all_units: Array[Unit] = []
	for node in enemy.get_tree().get_nodes_in_group("units"):
		var unit = node as Unit
		if unit and is_instance_valid(unit):
			all_units.append(unit)
	combat_grid.update_occupied_tiles(all_units)

# ===== TARGET HELPERS =====
static func _get_valid_targets(enemy: Unit) -> Array[Unit]:
	## Get all valid targets (living friendly units)
	var targets: Array[Unit] = []
	var units = enemy.get_tree().get_nodes_in_group("units")

	for node in units:
		var unit = node as Unit
		if unit and is_instance_valid(unit) and unit.is_alive():
			# Target non-enemies (friendly units)
			if not unit.is_enemy:
				targets.append(unit)

	return targets

# ===== UTILITY HELPERS =====
static func _get_tile_distance(from: Vector2i, to: Vector2i) -> int:
	## Calculate Chebyshev distance (king moves) between two tiles
	return maxi(absi(to.x - from.x), absi(to.y - from.y))

static func _wait(enemy: Unit, duration: float) -> void:
	## Wait for a duration using the enemy's scene tree
	if is_instance_valid(enemy):
		await enemy.get_tree().create_timer(duration).timeout
