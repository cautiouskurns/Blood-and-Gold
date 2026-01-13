## SoldierAI - Handles autonomous turn execution for soldiers
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.8-soldier-unit-type-infantry.md, docs/features/2.9-soldier-unit-type-archer.md
## Task 2.8: Soldiers follow standing orders (HOLD, ADVANCE, etc.)
## Task 2.9: Archers retreat when enemies get close, attack from range
class_name SoldierAI
extends RefCounted

# ===== CONSTANTS =====
const MOVE_DELAY: float = 0.1  # Small delay between move and attack for visual clarity
const TURN_DELAY: float = 0.3  # Delay before ending turn for visual feedback
const RETREAT_DISTANCE: int = 3  # How far archers try to retreat (Task 2.9)

# ===== MAIN ENTRY POINT =====
static func execute_turn(soldier: Unit, combat_grid: CombatGrid) -> void:
	## Execute a soldier's turn based on their current order
	## Called by TurnManager when it's a soldier's turn
	if not is_instance_valid(soldier) or not soldier.is_alive():
		_end_soldier_turn()
		return

	if not soldier.is_soldier:
		push_error("[SoldierAI] execute_turn called on non-soldier: %s" % soldier.unit_name)
		_end_soldier_turn()
		return

	print("[SoldierAI] Executing turn for %s (Order: %s, Ranged: %s)" % [
		soldier.unit_name,
		soldier.get_order_name(),
		soldier.is_ranged_weapon
	])

	# Task 2.9: Archers have special behavior - check retreat first
	if soldier.is_ranged_weapon:
		await _execute_archer_turn(soldier, combat_grid)
	else:
		# Infantry and other melee soldiers
		await _execute_melee_soldier_turn(soldier, combat_grid)

	# End turn after action
	await soldier.get_tree().create_timer(TURN_DELAY).timeout
	_end_soldier_turn()

static func _execute_melee_soldier_turn(soldier: Unit, combat_grid: CombatGrid) -> void:
	## Execute turn for melee soldiers (infantry)
	match soldier.current_order:
		Unit.SoldierOrder.HOLD:
			await _execute_hold_order(soldier, combat_grid)
		Unit.SoldierOrder.ADVANCE:
			await _execute_advance_order(soldier, combat_grid)
		Unit.SoldierOrder.FOCUS_FIRE:
			await _execute_focus_fire_order(soldier, combat_grid)
		Unit.SoldierOrder.RETREAT:
			await _execute_retreat_order(soldier, combat_grid)
		Unit.SoldierOrder.PROTECT:
			await _execute_protect_order(soldier, combat_grid)
		_:
			print("[SoldierAI] Unknown order, defaulting to HOLD")
			await _execute_hold_order(soldier, combat_grid)

# ===== ARCHER-SPECIFIC BEHAVIOR (Task 2.9) =====
static func _execute_archer_turn(soldier: Unit, combat_grid: CombatGrid) -> void:
	## Execute turn for archer soldiers - retreat if threatened, then attack from range
	print("[SoldierAI] Archer %s executing turn" % soldier.unit_name)

	# Step 1: Check if we need to retreat (enemies adjacent)
	var retreated = false
	if _should_archer_retreat(soldier):
		print("[SoldierAI] Archer %s threatened by adjacent enemy, attempting retreat" % soldier.unit_name)
		retreated = await _execute_archer_retreat(soldier, combat_grid)
		if retreated:
			await soldier.get_tree().create_timer(MOVE_DELAY).timeout

	# Step 2: Execute order (with ranged behavior)
	match soldier.current_order:
		Unit.SoldierOrder.HOLD:
			await _execute_archer_hold_order(soldier, combat_grid)
		Unit.SoldierOrder.ADVANCE:
			await _execute_archer_advance_order(soldier, combat_grid, retreated)
		Unit.SoldierOrder.FOCUS_FIRE:
			# Use shared FOCUS_FIRE behavior (works for both ranged and melee)
			await _execute_focus_fire_order(soldier, combat_grid)
		Unit.SoldierOrder.RETREAT:
			# Archers retreat toward map edge, don't shoot
			await _execute_retreat_order(soldier, combat_grid)
		Unit.SoldierOrder.PROTECT:
			# Archers can protect allies too
			await _execute_protect_order(soldier, combat_grid)
		_:
			# Unknown orders default to hold behavior for archers
			await _execute_archer_hold_order(soldier, combat_grid)

static func _should_archer_retreat(soldier: Unit) -> bool:
	## Check if any enemy is adjacent (within 1 tile) - archers should retreat
	var enemies = _get_all_enemies(soldier)
	for enemy in enemies:
		var dist = _get_tile_distance(soldier.grid_position, enemy.grid_position)
		if dist <= 1:
			return true
	return false

static func _execute_archer_retreat(soldier: Unit, combat_grid: CombatGrid) -> bool:
	## Move archer away from adjacent enemies
	## Returns true if movement occurred
	if not combat_grid:
		return false

	# Find the closest threatening enemy
	var closest_threat: Unit = null
	var closest_dist: int = 999
	var enemies = _get_all_enemies(soldier)

	for enemy in enemies:
		var dist = _get_tile_distance(soldier.grid_position, enemy.grid_position)
		if dist <= 1 and dist < closest_dist:
			closest_dist = dist
			closest_threat = enemy

	if not closest_threat:
		return false

	# Calculate retreat direction (opposite of threat)
	var retreat_direction = soldier.grid_position - closest_threat.grid_position
	if retreat_direction == Vector2i.ZERO:
		retreat_direction = Vector2i(1, 0)  # Default direction if on same tile (shouldn't happen)

	# Find best retreat position
	var retreat_pos = _find_retreat_position(soldier, retreat_direction, combat_grid, enemies)

	if retreat_pos == soldier.grid_position:
		print("[SoldierAI] Archer %s cannot retreat (no valid position)" % soldier.unit_name)
		return false

	# Update occupied tiles before moving
	var all_units: Array[Unit] = []
	for node in soldier.get_tree().get_nodes_in_group("units"):
		var unit = node as Unit
		if unit and is_instance_valid(unit):
			all_units.append(unit)
	combat_grid.update_occupied_tiles(all_units)

	# Get path to retreat position
	var path = combat_grid.pathfinding.get_path(soldier.grid_position, retreat_pos, soldier)
	if path.size() < 2:
		print("[SoldierAI] Archer %s no valid retreat path" % soldier.unit_name)
		return false

	# Limit path to movement range
	var limited_path: Array[Vector2i] = []
	limited_path.append(path[0])
	for i in range(1, mini(path.size(), soldier.movement_range + 1)):
		limited_path.append(path[i])

	print("[SoldierAI] Archer %s retreating: %s" % [soldier.unit_name, limited_path])
	soldier.move_along_path(limited_path)
	await soldier.movement_finished
	return true

static func _find_retreat_position(soldier: Unit, retreat_dir: Vector2i, combat_grid: CombatGrid, enemies: Array[Unit]) -> Vector2i:
	## Find the best position to retreat to
	var current_pos = soldier.grid_position
	var best_pos = current_pos
	var best_score: float = -999.0

	# Normalize retreat direction
	var norm_dir = retreat_dir.sign()
	if norm_dir == Vector2i.ZERO:
		norm_dir = Vector2i(1, 0)

	# Check positions in retreat direction and nearby
	var candidates: Array[Vector2i] = []

	# Primary retreat direction
	for dist in range(1, RETREAT_DISTANCE + 1):
		candidates.append(current_pos + norm_dir * dist)

	# Also check diagonal and perpendicular directions
	var perpendicular = Vector2i(norm_dir.y, -norm_dir.x)
	for dist in range(1, RETREAT_DISTANCE + 1):
		candidates.append(current_pos + perpendicular * dist)
		candidates.append(current_pos - perpendicular * dist)
		candidates.append(current_pos + norm_dir * dist + perpendicular)
		candidates.append(current_pos + norm_dir * dist - perpendicular)

	for candidate in candidates:
		if not combat_grid.is_valid_position(candidate):
			continue
		if CombatManager.is_tile_occupied(candidate):
			continue

		# Score based on distance from all enemies
		var min_enemy_dist = 999
		for enemy in enemies:
			var dist = _get_tile_distance(candidate, enemy.grid_position)
			min_enemy_dist = mini(min_enemy_dist, dist)

		# Higher score = better (farther from enemies)
		var score = float(min_enemy_dist)

		# Bonus for being in retreat direction
		var dir_to_candidate = candidate - current_pos
		if dir_to_candidate.sign() == norm_dir:
			score += 0.5

		if score > best_score:
			best_score = score
			best_pos = candidate

	return best_pos

static func _execute_archer_hold_order(soldier: Unit, _combat_grid: CombatGrid) -> void:
	## HOLD for archers: Stay in place, shoot enemies in range
	print("[SoldierAI] Archer %s executing HOLD order" % soldier.unit_name)

	var target = _find_target_in_range(soldier)
	if target:
		print("[SoldierAI] Archer %s shooting target in range: %s" % [soldier.unit_name, target.unit_name])
		soldier.perform_attack(target)
	else:
		print("[SoldierAI] Archer %s holding position (no targets in range)" % soldier.unit_name)

static func _execute_archer_advance_order(soldier: Unit, combat_grid: CombatGrid, already_moved: bool) -> void:
	## ADVANCE for archers: Move to firing position if needed, shoot enemies
	print("[SoldierAI] Archer %s executing ADVANCE order (already_moved: %s)" % [soldier.unit_name, already_moved])

	# First check if we have a target in range
	var target = _find_target_in_range(soldier)
	if target:
		print("[SoldierAI] Archer %s has target in range, shooting: %s" % [soldier.unit_name, target.unit_name])
		soldier.perform_attack(target)
		return

	# No target in range - if we already moved (retreat), just end turn
	if already_moved:
		print("[SoldierAI] Archer %s already moved, no targets in range" % soldier.unit_name)
		return

	# Try to move toward nearest enemy to get in range
	var nearest = _find_nearest_enemy(soldier)
	if not nearest:
		print("[SoldierAI] Archer %s no enemies found" % soldier.unit_name)
		return

	# Move toward a position where we can shoot the enemy
	var moved = await _move_to_firing_position(soldier, nearest, combat_grid)

	if moved:
		await soldier.get_tree().create_timer(MOVE_DELAY).timeout
		# Try to shoot after moving
		target = _find_target_in_range(soldier)
		if target:
			print("[SoldierAI] Archer %s now in range, shooting: %s" % [soldier.unit_name, target.unit_name])
			soldier.perform_attack(target)

static func _find_target_in_range(soldier: Unit) -> Unit:
	## Find an enemy within weapon range
	var enemies = _get_all_enemies(soldier)
	var best_target: Unit = null
	var best_dist: int = 999

	for enemy in enemies:
		var dist = _get_tile_distance(soldier.grid_position, enemy.grid_position)
		if dist <= soldier.weapon_range and dist < best_dist:
			best_dist = dist
			best_target = enemy

	return best_target

static func _move_to_firing_position(soldier: Unit, target: Unit, combat_grid: CombatGrid) -> bool:
	## Move to a position where we can shoot the target
	## Returns true if movement occurred
	if not combat_grid:
		return false

	# Update occupied tiles
	var all_units: Array[Unit] = []
	for node in soldier.get_tree().get_nodes_in_group("units"):
		var unit = node as Unit
		if unit and is_instance_valid(unit):
			all_units.append(unit)
	combat_grid.update_occupied_tiles(all_units)

	# Find positions within range of target that we can path to
	var target_pos = target.grid_position
	var weapon_range = soldier.weapon_range
	var enemies = _get_all_enemies(soldier)

	# Find positions at optimal range (not too close, within weapon range)
	var best_pos: Vector2i = soldier.grid_position
	var best_path: Array[Vector2i] = []
	var best_score: float = -999.0

	# Check tiles at various ranges
	for dx in range(-weapon_range, weapon_range + 1):
		for dy in range(-weapon_range, weapon_range + 1):
			var candidate = target_pos + Vector2i(dx, dy)
			var dist_to_target = _get_tile_distance(candidate, target_pos)

			# Must be within weapon range but not adjacent (archers prefer distance)
			if dist_to_target < 2 or dist_to_target > weapon_range:
				continue

			if not combat_grid.is_valid_position(candidate):
				continue
			if CombatManager.is_tile_occupied(candidate) and candidate != soldier.grid_position:
				continue

			# Check pathfinding
			var path = combat_grid.pathfinding.get_path(soldier.grid_position, candidate, soldier)
			if path.size() < 2:
				continue

			# Score: prefer farther from enemies, shorter path
			var min_enemy_dist = 999
			for enemy in enemies:
				var d = _get_tile_distance(candidate, enemy.grid_position)
				min_enemy_dist = mini(min_enemy_dist, d)

			var score = float(min_enemy_dist) - float(path.size()) * 0.1

			if score > best_score and path.size() <= soldier.movement_range + 1:
				best_score = score
				best_pos = candidate
				best_path = path

	if best_path.is_empty() or best_path.size() < 2:
		print("[SoldierAI] Archer %s no valid firing position found" % soldier.unit_name)
		return false

	# Limit path to movement range
	var limited_path: Array[Vector2i] = []
	limited_path.append(best_path[0])
	for i in range(1, mini(best_path.size(), soldier.movement_range + 1)):
		limited_path.append(best_path[i])

	print("[SoldierAI] Archer %s moving to firing position: %s" % [soldier.unit_name, limited_path])
	soldier.move_along_path(limited_path)
	await soldier.movement_finished
	return true

# ===== ORDER IMPLEMENTATIONS =====
static func _execute_hold_order(soldier: Unit, combat_grid: CombatGrid) -> void:
	## HOLD: Stay in position, attack adjacent enemies
	print("[SoldierAI] %s executing HOLD order" % soldier.unit_name)

	# Find adjacent enemy
	var target = _find_adjacent_enemy(soldier)
	if target:
		print("[SoldierAI] %s attacking adjacent enemy: %s" % [soldier.unit_name, target.unit_name])
		soldier.perform_attack(target)
	else:
		print("[SoldierAI] %s holding position (no adjacent enemies)" % soldier.unit_name)

static func _execute_advance_order(soldier: Unit, combat_grid: CombatGrid) -> void:
	## ADVANCE: Move toward nearest enemy, attack if adjacent
	print("[SoldierAI] %s executing ADVANCE order" % soldier.unit_name)

	# First check for adjacent enemy (attack without moving)
	var adjacent_target = _find_adjacent_enemy(soldier)
	if adjacent_target:
		print("[SoldierAI] %s already adjacent to enemy, attacking: %s" % [
			soldier.unit_name, adjacent_target.unit_name
		])
		soldier.perform_attack(adjacent_target)
		return

	# Find nearest enemy to move toward
	var target = _find_nearest_enemy(soldier)
	if not target:
		print("[SoldierAI] %s no enemies found, standing idle" % soldier.unit_name)
		return

	# Move toward target
	var moved = await _move_toward_target(soldier, target, combat_grid)

	# After moving, check if now adjacent and can attack
	if moved:
		await soldier.get_tree().create_timer(MOVE_DELAY).timeout

	var new_adjacent_target = _find_adjacent_enemy(soldier)
	if new_adjacent_target:
		print("[SoldierAI] %s now adjacent, attacking: %s" % [
			soldier.unit_name, new_adjacent_target.unit_name
		])
		soldier.perform_attack(new_adjacent_target)

static func _execute_focus_fire_order(soldier: Unit, combat_grid: CombatGrid) -> void:
	## FOCUS_FIRE: Attack designated target, ignoring closer enemies
	## If no target designated or target dead, fall back to ADVANCE behavior
	print("[SoldierAI] %s executing FOCUS_FIRE order" % soldier.unit_name)

	var target = CombatManager.get_focus_fire_target()

	# Check if we have a valid target
	if not target or not is_instance_valid(target) or not target.is_alive():
		print("[SoldierAI] %s no valid FOCUS_FIRE target, falling back to ADVANCE" % soldier.unit_name)
		await _execute_advance_order(soldier, combat_grid)
		return

	var dist = _get_tile_distance(soldier.grid_position, target.grid_position)

	if soldier.is_ranged_weapon:
		# Ranged soldier: Check if target in weapon range
		if dist <= soldier.weapon_range:
			print("[SoldierAI] %s shooting FOCUS_FIRE target: %s" % [soldier.unit_name, target.unit_name])
			soldier.perform_attack(target)
		else:
			# Move toward target to get in range
			var moved = await _move_toward_target(soldier, target, combat_grid)
			if moved:
				await soldier.get_tree().create_timer(MOVE_DELAY).timeout

			# Check range again after moving
			dist = _get_tile_distance(soldier.grid_position, target.grid_position)
			if dist <= soldier.weapon_range:
				print("[SoldierAI] %s now in range, shooting FOCUS_FIRE target: %s" % [soldier.unit_name, target.unit_name])
				soldier.perform_attack(target)
			else:
				print("[SoldierAI] %s still out of range for FOCUS_FIRE target" % soldier.unit_name)
	else:
		# Melee soldier: Must be adjacent to attack
		if dist == 1:
			print("[SoldierAI] %s attacking FOCUS_FIRE target: %s" % [soldier.unit_name, target.unit_name])
			soldier.perform_attack(target)
		else:
			# Move toward target
			var moved = await _move_toward_target(soldier, target, combat_grid)
			if moved:
				await soldier.get_tree().create_timer(MOVE_DELAY).timeout

			# Check if now adjacent
			dist = _get_tile_distance(soldier.grid_position, target.grid_position)
			if dist == 1:
				print("[SoldierAI] %s now adjacent, attacking FOCUS_FIRE target: %s" % [soldier.unit_name, target.unit_name])
				soldier.perform_attack(target)
			else:
				print("[SoldierAI] %s still not adjacent to FOCUS_FIRE target" % soldier.unit_name)

static func _execute_retreat_order(soldier: Unit, combat_grid: CombatGrid) -> void:
	## RETREAT: Move toward starting map edge (Y=0 for player soldiers)
	## Soldiers retreating do NOT attack
	print("[SoldierAI] %s executing RETREAT order" % soldier.unit_name)

	if not combat_grid:
		print("[SoldierAI] %s cannot retreat (no combat grid)" % soldier.unit_name)
		return

	var current_pos = soldier.grid_position

	# Determine retreat destination (Y=0 for player soldiers, max Y for enemies)
	var target_y: int = 0
	if soldier.is_enemy:
		# Enemies retreat toward bottom of map
		target_y = combat_grid.grid_size.y - 1

	# Already at retreat edge?
	if current_pos.y == target_y:
		print("[SoldierAI] %s already at map edge, standing idle" % soldier.unit_name)
		return

	# Update occupied tiles
	var all_units: Array[Unit] = []
	for node in soldier.get_tree().get_nodes_in_group("units"):
		var unit = node as Unit
		if unit and is_instance_valid(unit):
			all_units.append(unit)
	combat_grid.update_occupied_tiles(all_units)

	# Try to find path toward retreat edge
	var destination = Vector2i(current_pos.x, target_y)
	var path = combat_grid.pathfinding.get_path(current_pos, destination, soldier)

	# If direct path blocked, try nearby columns
	if path.size() < 2:
		for offset in [1, -1, 2, -2, 3, -3]:
			var alt_x = current_pos.x + offset
			if alt_x >= 0 and alt_x < combat_grid.grid_size.x:
				destination = Vector2i(alt_x, target_y)
				path = combat_grid.pathfinding.get_path(current_pos, destination, soldier)
				if path.size() >= 2:
					break

	if path.size() < 2:
		print("[SoldierAI] %s cannot retreat (no valid path)" % soldier.unit_name)
		return

	# Limit path to movement range
	var limited_path: Array[Vector2i] = []
	limited_path.append(path[0])
	for i in range(1, mini(path.size(), soldier.movement_range + 1)):
		limited_path.append(path[i])

	print("[SoldierAI] %s retreating along path: %s" % [soldier.unit_name, limited_path])
	soldier.move_along_path(limited_path)
	await soldier.movement_finished

	# RETREAT soldiers do NOT attack - they are fleeing!

static func _execute_protect_order(soldier: Unit, combat_grid: CombatGrid) -> void:
	## PROTECT: Stay adjacent to protected ally, attack enemies in range
	## Attack interception handled by CombatManager during damage resolution
	print("[SoldierAI] %s executing PROTECT order" % soldier.unit_name)

	var ally = CombatManager.get_protected_ally(soldier)

	# Check if we have a valid ally to protect
	if not ally or not is_instance_valid(ally) or not ally.is_alive():
		print("[SoldierAI] %s no valid ally to protect, defaulting to HOLD" % soldier.unit_name)
		await _execute_hold_order(soldier, combat_grid)
		return

	var dist_to_ally = _get_tile_distance(soldier.grid_position, ally.grid_position)

	# Step 1: Move to adjacent position if not already adjacent
	if dist_to_ally > 1:
		print("[SoldierAI] %s moving to protect %s (current distance: %d)" % [
			soldier.unit_name, ally.unit_name, dist_to_ally
		])

		var protect_pos = _find_protect_position(soldier, ally, combat_grid)
		if protect_pos != soldier.grid_position:
			# Update occupied tiles before pathfinding
			var all_units: Array[Unit] = []
			for node in soldier.get_tree().get_nodes_in_group("units"):
				var unit = node as Unit
				if unit and is_instance_valid(unit):
					all_units.append(unit)
			combat_grid.update_occupied_tiles(all_units)

			var path = combat_grid.pathfinding.get_path(soldier.grid_position, protect_pos, soldier)
			if path.size() >= 2:
				# Limit path to movement range
				var limited_path: Array[Vector2i] = []
				limited_path.append(path[0])
				for i in range(1, mini(path.size(), soldier.movement_range + 1)):
					limited_path.append(path[i])

				print("[SoldierAI] %s moving to protect position: %s" % [soldier.unit_name, limited_path])
				soldier.move_along_path(limited_path)
				await soldier.movement_finished
				await soldier.get_tree().create_timer(MOVE_DELAY).timeout

	# Step 2: Attack enemy in range (while protecting)
	var target: Unit = null
	if soldier.is_ranged_weapon:
		target = _find_target_in_range(soldier)
	else:
		target = _find_adjacent_enemy(soldier)

	if target:
		print("[SoldierAI] %s attacking while protecting %s" % [soldier.unit_name, ally.unit_name])
		soldier.perform_attack(target)
	else:
		print("[SoldierAI] %s guarding %s (no enemies in range)" % [soldier.unit_name, ally.unit_name])

static func _find_protect_position(soldier: Unit, ally: Unit, combat_grid: CombatGrid) -> Vector2i:
	## Find best adjacent tile to protected ally
	## Prefer tiles between ally and nearest enemy (to intercept attacks)
	var ally_pos = ally.grid_position
	var enemies = _get_all_enemies(soldier)

	# Get all adjacent tiles to ally
	var adjacent_tiles: Array[Vector2i] = [
		ally_pos + Vector2i(1, 0),
		ally_pos + Vector2i(-1, 0),
		ally_pos + Vector2i(0, 1),
		ally_pos + Vector2i(0, -1),
		ally_pos + Vector2i(1, 1),
		ally_pos + Vector2i(-1, 1),
		ally_pos + Vector2i(1, -1),
		ally_pos + Vector2i(-1, -1),
	]

	var best_pos = soldier.grid_position
	var best_score: float = -999.0

	for tile in adjacent_tiles:
		if not combat_grid.is_valid_position(tile):
			continue
		# Allow current position, but check occupation for other tiles
		if CombatManager.is_tile_occupied(tile) and tile != soldier.grid_position:
			continue

		# Score: prefer tiles closer to nearest enemy (to intercept)
		var min_enemy_dist: int = 999
		for enemy in enemies:
			var d = _get_tile_distance(tile, enemy.grid_position)
			min_enemy_dist = mini(min_enemy_dist, d)

		# Lower enemy distance = higher score (we want to be between ally and enemies)
		var score = -float(min_enemy_dist)

		# Bonus for tiles on the "enemy side" of the ally
		if enemies.size() > 0:
			var nearest_enemy = enemies[0]
			for enemy in enemies:
				if _get_tile_distance(ally_pos, enemy.grid_position) < _get_tile_distance(ally_pos, nearest_enemy.grid_position):
					nearest_enemy = enemy

			# Direction from ally to nearest enemy
			var enemy_dir = nearest_enemy.grid_position - ally_pos
			var tile_dir = tile - ally_pos
			# Bonus if tile is in same direction as enemy
			if enemy_dir.sign() == tile_dir.sign():
				score += 2.0

		if score > best_score:
			best_score = score
			best_pos = tile

	return best_pos

# ===== HELPER METHODS =====
static func _find_nearest_enemy(soldier: Unit) -> Unit:
	## Find the closest enemy unit by tile distance
	var enemies = _get_all_enemies(soldier)
	if enemies.is_empty():
		return null

	var nearest: Unit = null
	var nearest_dist: int = 999

	for enemy in enemies:
		var dist = _get_tile_distance(soldier.grid_position, enemy.grid_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	return nearest

static func _find_adjacent_enemy(soldier: Unit) -> Unit:
	## Find an enemy adjacent to the soldier (within 1 tile)
	var enemies = _get_all_enemies(soldier)

	for enemy in enemies:
		var dist = _get_tile_distance(soldier.grid_position, enemy.grid_position)
		if dist == 1:
			return enemy

	return null

static func _get_all_enemies(soldier: Unit) -> Array[Unit]:
	## Get all living enemy units
	var enemies: Array[Unit] = []
	var units = soldier.get_tree().get_nodes_in_group("units")

	for node in units:
		var unit = node as Unit
		if unit and is_instance_valid(unit) and unit.is_alive():
			# Enemy of this soldier
			if unit.is_enemy != soldier.is_enemy:
				enemies.append(unit)

	return enemies

static func _get_tile_distance(from: Vector2i, to: Vector2i) -> int:
	## Calculate Chebyshev distance (king moves) between two tiles
	return maxi(absi(to.x - from.x), absi(to.y - from.y))

static func _move_toward_target(soldier: Unit, target: Unit, combat_grid: CombatGrid) -> bool:
	## Move soldier toward target using pathfinding
	## Returns true if movement occurred
	if not combat_grid:
		print("[SoldierAI] No combat grid, cannot pathfind")
		return false

	# Update occupied tiles before pathfinding
	var all_units: Array[Unit] = []
	for node in soldier.get_tree().get_nodes_in_group("units"):
		var unit = node as Unit
		if unit and is_instance_valid(unit):
			all_units.append(unit)
	combat_grid.update_occupied_tiles(all_units)

	# Get path to target (or adjacent to target)
	var path = _get_path_toward_target(soldier, target, combat_grid)

	if path.is_empty() or path.size() < 2:
		print("[SoldierAI] %s no valid path to %s" % [soldier.unit_name, target.unit_name])
		return false

	# Limit path to movement range
	var move_range = soldier.movement_range
	var limited_path: Array[Vector2i] = []
	limited_path.append(path[0])  # Start position

	for i in range(1, mini(path.size(), move_range + 1)):
		limited_path.append(path[i])

	if limited_path.size() < 2:
		return false

	print("[SoldierAI] %s moving along path: %s" % [soldier.unit_name, limited_path])

	# Execute movement
	soldier.move_along_path(limited_path)

	# Wait for movement to complete
	await soldier.movement_finished
	return true

static func _get_path_toward_target(soldier: Unit, target: Unit, combat_grid: CombatGrid) -> Array[Vector2i]:
	## Get pathfinding path toward target, stopping adjacent to target
	var pathfinding = combat_grid.pathfinding
	if not pathfinding:
		return []

	# Try to find path to a tile adjacent to target
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
		if CombatManager.is_tile_occupied(adj_tile) and adj_tile != soldier.grid_position:
			continue

		var path = pathfinding.get_path(soldier.grid_position, adj_tile, soldier)
		if path.size() >= 2 and path.size() < best_length:
			best_path = path
			best_length = path.size()

	return best_path

static func _end_soldier_turn() -> void:
	## End the soldier's turn via CombatManager
	CombatManager.end_current_turn()
