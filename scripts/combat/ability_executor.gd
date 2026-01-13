## AbilityExecutor - Executes ability effects
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.3-implement-player-abilities.md
class_name AbilityExecutor
extends RefCounted

# ===== PRELOADS =====
const DamageNumberScene = preload("res://scenes/UI/DamageNumber.tscn")

# ===== STATIC METHODS =====
static func execute(user: Unit, ability: Ability, target: Unit = null) -> Dictionary:
	## Execute an ability and return results
	var result = {
		"success": false,
		"damage_dealt": 0,
		"status_applied": "",
		"targets_affected": [],
		"message": "",
		"hit": false,
		"roll": 0,
		"total_attack": 0,
	}

	# NOTE: Ability usage is tracked by CombatManager.execute_ability()
	# Do not call user.use_ability() here to avoid double-counting

	match ability.ability_type:
		Ability.AbilityType.MELEE_ATTACK:
			result = _execute_melee_attack(user, ability, target)
		Ability.AbilityType.SOLDIER_BUFF:
			result = _execute_soldier_buff(user, ability)
		Ability.AbilityType.ARC_ATTACK:
			result = _execute_arc_attack(user, ability)  # Task 2.4: Cleave
		Ability.AbilityType.ENEMY_TAUNT:
			result = _execute_taunt(user, ability)  # Task 2.4: Taunt
		Ability.AbilityType.PASSIVE:
			# Passive abilities are not executed directly - they trigger automatically
			result.message = "Passive ability cannot be executed directly"
			push_warning("[AbilityExecutor] Attempted to execute passive ability: %s" % ability.id)
		Ability.AbilityType.BACKSTAB:
			result = _execute_backstab(user, ability, target)  # Task 2.5: Backstab
		Ability.AbilityType.SELF_BUFF:
			result = _execute_self_buff(user, ability)  # Task 2.5: Poison Blade
		Ability.AbilityType.TELEPORT:
			# Teleport is executed via execute_on_tile, not execute
			result.message = "Teleport requires tile target, use execute_on_tile"
			push_warning("[AbilityExecutor] Teleport called without tile target: %s" % ability.id)
		Ability.AbilityType.ALLY_HEAL:
			result = _execute_heal(user, ability, target)  # Task 2.6: Heal
		Ability.AbilityType.PARTY_BUFF:
			result = _execute_party_buff(user, ability)  # Task 2.6: Bless
		Ability.AbilityType.RANGED_ATTACK:
			result = _execute_ranged_attack(user, ability, target)  # Task 2.6: Smite
		_:
			push_error("[AbilityExecutor] Unknown ability type: %s" % ability.ability_type)

	return result

static func _execute_melee_attack(user: Unit, ability: Ability, target: Unit) -> Dictionary:
	## Execute a melee attack ability (Basic Attack, Power Attack, Shield Bash)
	var result = {
		"success": false,
		"damage_dealt": 0,
		"status_applied": "",
		"targets_affected": [],
		"hit": false,
		"roll": 0,
		"total_attack": 0,
		"target_defense": 0,
		"is_critical": false,
		"message": ""
	}

	if not target or not target.is_alive():
		result.message = "Invalid target"
		return result

	# Check adjacency
	if not AttackResolver.is_adjacent(user, target):
		result.message = "Target not adjacent"
		return result

	result.targets_affected = [target]

	# Get base attack bonus (includes any buffs already)
	var base_attack_bonus = user.get_attack_bonus()
	# Apply ability modifier
	var attack_bonus = base_attack_bonus + ability.attack_modifier

	# Roll attack (d20)
	result.roll = randi_range(1, 20)
	result.total_attack = result.roll + attack_bonus
	result.target_defense = target.get_defense()

	# Check for critical hit (natural 20)
	result.is_critical = (result.roll == 20)

	# Check for hit
	result.hit = result.total_attack >= result.target_defense or result.is_critical

	if result.hit:
		# Calculate damage with multiplier
		var base_damage = randi_range(1, user.get_damage_die()) + user.get_damage_modifier()

		# Add Poison Blade bonus if active (Task 2.5)
		var poison_bonus = user.get_poison_blade_bonus()
		base_damage += poison_bonus

		var modified_damage = int(base_damage * ability.damage_multiplier) + ability.bonus_damage

		# Critical hit doubles damage
		if result.is_critical:
			modified_damage *= 2

		result.damage_dealt = max(1, modified_damage)
		result.success = true

		# Spawn damage number (green tint if poison active)
		if poison_bonus > 0:
			_spawn_damage_number_colored(target, result.damage_dealt, result.is_critical, false)
		else:
			_spawn_damage_number(target, result.damage_dealt, result.is_critical)

		# Apply damage
		target.take_damage(result.damage_dealt)

		# Consume Poison Blade charge if active (Task 2.5)
		if poison_bonus > 0:
			user.consume_poison_blade_charge()

		# Apply status effect if ability has one and target still alive
		if not ability.applies_status.is_empty() and target.is_alive():
			StatusEffectManager.apply_effect(
				target,
				ability.applies_status,
				ability.status_duration,
				ability.status_value
			)
			result.status_applied = ability.applies_status

		result.message = "%s hits %s for %d damage" % [
			user.unit_name, target.unit_name, result.damage_dealt
		]
		if not result.status_applied.is_empty():
			result.message += " (applied %s)" % result.status_applied
	else:
		# Spawn miss indicator
		_spawn_miss_number(target)
		result.message = "%s misses %s" % [user.unit_name, target.unit_name]

	# Log combat
	print("[Combat] %s uses %s on %s" % [user.unit_name, ability.display_name, target.unit_name])
	print("[Combat] Attack roll: %d + %d = %d vs DEF %d -> %s" % [
		result.roll, attack_bonus, result.total_attack, result.target_defense,
		"HIT" if result.hit else "MISS"
	])
	if result.hit:
		print("[Combat] %s deals %d damage to %s%s" % [
			ability.display_name, result.damage_dealt, target.unit_name,
			" (CRITICAL!)" if result.is_critical else ""
		])
		if not result.status_applied.is_empty():
			print("[Combat] %s is %s for %d turn(s)" % [
				target.unit_name, result.status_applied, ability.status_duration
			])

	return result

static func _execute_soldier_buff(user: Unit, ability: Ability) -> Dictionary:
	## Execute a soldier buff ability (Rally)
	var result = {
		"success": true,
		"damage_dealt": 0,
		"status_applied": ability.applies_status,
		"targets_affected": [],
		"hit": true,
		"roll": 0,
		"total_attack": 0,
		"message": "",
		"buff_applied": true
	}

	# Get all friendly soldiers for the user's faction
	var soldiers = CombatManager.get_friendly_soldiers(user)

	for soldier in soldiers:
		if soldier.is_alive():
			StatusEffectManager.apply_effect(
				soldier,
				ability.applies_status,
				ability.status_duration,
				ability.status_value
			)
			result.targets_affected.append(soldier)

	result.message = "%s uses %s - %d soldiers gain +%d attack for %d turns" % [
		user.unit_name,
		ability.display_name,
		result.targets_affected.size(),
		ability.status_value,
		ability.status_duration
	]

	print("[Combat] %s uses %s" % [user.unit_name, ability.display_name])
	print("[Combat] %d soldiers gain +%d attack for %d turns" % [
		result.targets_affected.size(), ability.status_value, ability.status_duration
	])

	return result

static func _spawn_damage_number(target: Unit, damage: int, is_critical: bool) -> void:
	## Create floating damage number at target
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display damage
	damage_number.show_damage(damage, is_critical)

static func _spawn_miss_number(target: Unit) -> void:
	## Create floating miss indicator at target
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display miss
	damage_number.show_miss()

# ===== TASK 2.4: THORNE ABILITIES =====

static func _execute_arc_attack(user: Unit, ability: Ability) -> Dictionary:
	## Execute an arc attack ability (Cleave - Task 2.4)
	## Hits up to max_targets adjacent enemies
	var result = {
		"success": false,
		"damage_dealt": 0,
		"status_applied": "",
		"targets_affected": [],
		"hit": false,
		"roll": 0,
		"total_attack": 0,
		"message": "",
		"hits": [],  # Array of individual hit results
		"total_damage": 0
	}

	# Get all adjacent enemies
	var adjacent_enemies = CombatManager.get_adjacent_enemies(user)

	if adjacent_enemies.is_empty():
		result.message = "No adjacent enemies"
		return result

	# Limit to max_targets
	var targets: Array[Unit] = []
	for i in range(min(ability.max_targets, adjacent_enemies.size())):
		targets.append(adjacent_enemies[i])

	result.targets_affected = targets

	# Get base attack bonus
	var base_attack_bonus = user.get_attack_bonus()
	var attack_bonus = base_attack_bonus + ability.attack_modifier

	# Single attack roll for all targets (Cleave uses one swing)
	result.roll = randi_range(1, 20)
	result.total_attack = result.roll + attack_bonus
	var is_critical = (result.roll == 20)

	# Track hits and damage
	var hit_count = 0
	var total_damage = 0

	for target in targets:
		var target_defense = target.get_defense()
		var target_hit = result.total_attack >= target_defense or is_critical

		if target_hit:
			# Calculate damage with multiplier
			var base_damage = randi_range(1, user.get_damage_die()) + user.get_damage_modifier()
			var modified_damage = int(base_damage * ability.damage_multiplier) + ability.bonus_damage

			if is_critical:
				modified_damage *= 2

			var damage = max(1, modified_damage)
			total_damage += damage
			hit_count += 1

			# Spawn damage number and apply damage
			_spawn_damage_number(target, damage, is_critical)
			target.take_damage(damage)

			result.hits.append({
				"target": target,
				"damage": damage,
				"hit": true,
				"critical": is_critical
			})

			print("[Cleave] Hit %s for %d damage%s" % [
				target.unit_name, damage, " (CRITICAL!)" if is_critical else ""
			])
		else:
			_spawn_miss_number(target)
			result.hits.append({
				"target": target,
				"damage": 0,
				"hit": false,
				"critical": false
			})
			print("[Cleave] Missed %s" % target.unit_name)

	result.success = hit_count > 0
	result.hit = hit_count > 0
	result.damage_dealt = total_damage
	result.total_damage = total_damage

	result.message = "%s cleaves %d enemies for %d total damage (%d hits)" % [
		user.unit_name, targets.size(), total_damage, hit_count
	]

	print("[Combat] %s uses %s" % [user.unit_name, ability.display_name])
	print("[Combat] Attack roll: %d + %d = %d -> Hit %d/%d targets for %d total damage" % [
		result.roll, attack_bonus, result.total_attack, hit_count, targets.size(), total_damage
	])

	return result

static func _execute_taunt(user: Unit, ability: Ability) -> Dictionary:
	## Execute Taunt ability (Task 2.4)
	## Forces all enemies within range to attack user for duration turns
	var result = {
		"success": true,
		"damage_dealt": 0,
		"status_applied": "TAUNTED",
		"targets_affected": [],
		"hit": true,
		"roll": 0,
		"total_attack": 0,
		"message": "",
		"taunt_applied": true
	}

	# Get all enemies within taunt range
	var enemies_in_range = CombatManager.get_enemies_in_range(user, ability.ability_range)

	for enemy in enemies_in_range:
		if enemy.is_alive():
			# Apply taunt effect using StatusEffectManager's special method
			StatusEffectManager.apply_taunt(enemy, user, ability.status_duration)
			result.targets_affected.append(enemy)

	result.message = "%s taunts %d enemies for %d turn(s)" % [
		user.unit_name,
		result.targets_affected.size(),
		ability.status_duration
	]

	print("[Combat] %s uses %s" % [user.unit_name, ability.display_name])
	print("[Combat] %d enemies taunted within %d tiles for %d turn(s)" % [
		result.targets_affected.size(), ability.ability_range, ability.status_duration
	])

	# Log each taunted enemy
	for enemy in result.targets_affected:
		print("[Combat] %s is now taunted - must attack %s" % [enemy.unit_name, user.unit_name])

	return result

# ===== TASK 2.5: LYRA ABILITIES =====

static func execute_on_tile(user: Unit, ability: Ability, tile_position: Vector2i) -> Dictionary:
	## Execute an ability that targets a tile (Task 2.5: Shadowstep)
	var result = {
		"success": false,
		"from_position": user.grid_position,
		"to_position": tile_position,
		"message": ""
	}

	match ability.ability_type:
		Ability.AbilityType.TELEPORT:
			result = _execute_teleport(user, ability, tile_position)
		_:
			result.message = "Ability type does not support tile targeting"
			push_warning("[AbilityExecutor] Ability %s does not support tile targeting" % ability.id)

	return result

static func _execute_backstab(user: Unit, ability: Ability, target: Unit) -> Dictionary:
	## Execute Backstab attack - double damage if behind target (Task 2.5)
	var result = {
		"success": false,
		"damage_dealt": 0,
		"status_applied": "",
		"targets_affected": [],
		"hit": false,
		"roll": 0,
		"total_attack": 0,
		"target_defense": 0,
		"is_critical": false,
		"is_backstab": false,
		"message": ""
	}

	if not target or not target.is_alive():
		result.message = "Invalid target"
		return result

	# Check adjacency
	if not AttackResolver.is_adjacent(user, target):
		result.message = "Target not adjacent"
		return result

	result.targets_affected = [target]

	# Check if behind target for backstab bonus
	result.is_backstab = target.is_behind(user)
	var damage_multiplier = ability.backstab_multiplier if result.is_backstab else 1.0

	# Get base attack bonus (includes any buffs already)
	var base_attack_bonus = user.get_attack_bonus()
	var attack_bonus = base_attack_bonus + ability.attack_modifier

	# Roll attack (d20)
	result.roll = randi_range(1, 20)
	result.total_attack = result.roll + attack_bonus
	result.target_defense = target.get_defense()

	# Check for critical hit (natural 20)
	result.is_critical = (result.roll == 20)

	# Check for hit
	result.hit = result.total_attack >= result.target_defense or result.is_critical

	if result.hit:
		# Calculate base damage
		var base_damage = randi_range(1, user.get_damage_die()) + user.get_damage_modifier()

		# Add Poison Blade bonus if active (applied before multiplier)
		var poison_bonus = user.get_poison_blade_bonus()
		base_damage += poison_bonus

		# Apply backstab multiplier
		var modified_damage = int(base_damage * damage_multiplier) + ability.bonus_damage

		# Critical hit doubles damage
		if result.is_critical:
			modified_damage *= 2

		result.damage_dealt = max(1, modified_damage)
		result.success = true

		# Spawn damage number (purple for backstab)
		_spawn_damage_number_colored(target, result.damage_dealt, result.is_critical, result.is_backstab)

		# Apply damage
		target.take_damage(result.damage_dealt)

		# Consume Poison Blade charge if active
		if poison_bonus > 0:
			user.consume_poison_blade_charge()

		if result.is_backstab:
			result.message = "%s BACKSTABS %s for %d damage!" % [
				user.unit_name, target.unit_name, result.damage_dealt
			]
			print("[Combat] BACKSTAB! %s deals %d damage to %s%s%s" % [
				user.unit_name, result.damage_dealt, target.unit_name,
				" (CRITICAL!)" if result.is_critical else "",
				" (+%d poison)" % poison_bonus if poison_bonus > 0 else ""
			])
		else:
			result.message = "%s hits %s for %d damage (not behind)" % [
				user.unit_name, target.unit_name, result.damage_dealt
			]
			print("[Combat] %s uses Backstab on %s (not behind) for %d damage%s" % [
				user.unit_name, target.unit_name, result.damage_dealt,
				" (+%d poison)" % poison_bonus if poison_bonus > 0 else ""
			])
	else:
		# Spawn miss indicator
		_spawn_miss_number(target)
		result.message = "%s misses %s" % [user.unit_name, target.unit_name]
		print("[Combat] %s misses Backstab on %s" % [user.unit_name, target.unit_name])

	# Log combat
	print("[Combat] Attack roll: %d + %d = %d vs DEF %d -> %s" % [
		result.roll, attack_bonus, result.total_attack, result.target_defense,
		"HIT" if result.hit else "MISS"
	])

	return result

static func _execute_teleport(user: Unit, ability: Ability, destination: Vector2i) -> Dictionary:
	## Execute Teleport ability (Task 2.5: Shadowstep)
	var result = {
		"success": false,
		"from_position": user.grid_position,
		"to_position": destination,
		"distance": 0,
		"message": ""
	}

	# Check range
	var distance = CombatManager._calculate_grid_distance(user.grid_position, destination)
	result.distance = distance

	if distance > ability.ability_range:
		result.message = "Destination out of range (%d > %d)" % [distance, ability.ability_range]
		return result

	if distance == 0:
		result.message = "Already at destination"
		return result

	# Check if destination is occupied
	if CombatManager.is_tile_occupied(destination):
		result.message = "Destination tile occupied"
		return result

	# Execute teleport
	CombatManager.teleport_unit(user, destination)
	result.success = true

	result.message = "%s shadowsteps to %s" % [user.unit_name, destination]
	print("[Combat] %s uses Shadowstep: %s -> %s (%d tiles)" % [
		user.unit_name, result.from_position, result.to_position, distance
	])

	return result

static func _execute_self_buff(user: Unit, ability: Ability) -> Dictionary:
	## Execute self-buff ability (Task 2.5: Poison Blade)
	var result = {
		"success": true,
		"damage_dealt": 0,
		"status_applied": ability.applies_status,
		"targets_affected": [user],
		"hit": true,
		"roll": 0,
		"total_attack": 0,
		"message": "",
		"buff_applied": true,
		"attacks_remaining": ability.status_value,
		"bonus_damage": ability.bonus_damage
	}

	# Apply Poison Blade effect directly to the unit
	user.apply_poison_blade(ability.status_value, ability.bonus_damage)

	result.message = "%s applies %s - next %d attacks deal +%d damage" % [
		user.unit_name,
		ability.display_name,
		ability.status_value,
		ability.bonus_damage
	]

	print("[Combat] %s uses %s: +%d damage for %d attacks" % [
		user.unit_name, ability.display_name, ability.bonus_damage, ability.status_value
	])

	return result

static func _spawn_damage_number_colored(target: Unit, damage: int, is_critical: bool, is_backstab: bool) -> void:
	## Create floating damage number at target with optional backstab color (Task 2.5)
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display damage with color based on backstab
	if is_backstab:
		damage_number.show_damage_colored(damage, is_critical, Color("#9b59b6"))  # Purple for backstab
	else:
		damage_number.show_damage(damage, is_critical)

# ===== TASK 2.6: MATTHIAS ABILITIES =====

static func _execute_heal(user: Unit, ability: Ability, target: Unit) -> Dictionary:
	## Execute healing ability (Task 2.6: Matthias Heal)
	## Rolls heal_dice_count d(heal_dice_size) + heal_bonus HP
	var result = {
		"success": false,
		"heal_amount": 0,
		"targets_affected": [],
		"hit": true,  # Heals always succeed
		"roll": 0,
		"message": ""
	}

	if not target or not target.is_alive():
		result.message = "Invalid target"
		return result

	# Check range
	var distance = CombatManager._calculate_grid_distance(user.grid_position, target.grid_position)
	if distance > ability.ability_range:
		result.message = "Target out of range"
		return result

	# Check if trying to self-heal when not allowed
	if ability.exclude_self and target == user:
		result.message = "Cannot heal self with this ability"
		return result

	result.targets_affected = [target]

	# Roll healing: dice_count x d(dice_size) + bonus
	var heal_total = ability.heal_bonus
	for i in range(ability.heal_dice_count):
		var roll = randi_range(1, ability.heal_dice_size)
		heal_total += roll
		result.roll += roll  # Track total dice rolled

	# Calculate actual healing (capped at max HP)
	var actual_heal = min(heal_total, target.max_hp - target.current_hp)
	result.heal_amount = actual_heal
	result.success = true

	# Apply healing
	if actual_heal > 0:
		target.heal(actual_heal)
		_spawn_heal_number(target, actual_heal)
		result.message = "%s heals %s for %d HP" % [
			user.unit_name, target.unit_name, actual_heal
		]
	else:
		# Target at full HP
		_spawn_full_hp_indicator(target)
		result.message = "%s is already at full HP" % target.unit_name

	print("[Combat] %s uses %s on %s" % [user.unit_name, ability.display_name, target.unit_name])
	print("[Combat] Heal roll: %dd%d+%d = %d HP (actual: %d, target HP: %d/%d)" % [
		ability.heal_dice_count, ability.heal_dice_size, ability.heal_bonus,
		heal_total, actual_heal, target.current_hp, target.max_hp
	])

	return result

static func _execute_party_buff(user: Unit, ability: Ability) -> Dictionary:
	## Execute party-wide buff ability (Task 2.6: Matthias Bless)
	var result = {
		"success": true,
		"damage_dealt": 0,
		"status_applied": ability.applies_status,
		"targets_affected": [],
		"hit": true,
		"roll": 0,
		"total_attack": 0,
		"message": "",
		"buff_applied": true
	}

	# Get ALL friendly units (not just soldiers like Rally)
	var friendly_units = CombatManager.get_all_friendly_units(user)

	for friendly in friendly_units:
		if friendly.is_alive():
			StatusEffectManager.apply_effect(
				friendly,
				ability.applies_status,
				ability.status_duration,
				ability.status_value
			)
			result.targets_affected.append(friendly)

	result.message = "%s blesses %d allies with +%d to all rolls for %d turns" % [
		user.unit_name,
		result.targets_affected.size(),
		ability.status_value,
		ability.status_duration
	]

	print("[Combat] %s uses %s" % [user.unit_name, ability.display_name])
	print("[Combat] %d party members gain +%d to rolls for %d turns" % [
		result.targets_affected.size(), ability.status_value, ability.status_duration
	])

	# Log each blessed unit
	for friendly in result.targets_affected:
		print("[Combat] %s is now BLESSED" % friendly.unit_name)

	return result

static func _execute_ranged_attack(user: Unit, ability: Ability, target: Unit) -> Dictionary:
	## Execute ranged attack ability (Task 2.6: Matthias Smite)
	## Can be auto-hit (no attack roll) or use standard attack roll
	var result = {
		"success": false,
		"damage_dealt": 0,
		"status_applied": "",
		"targets_affected": [],
		"hit": false,
		"roll": 0,
		"total_attack": 0,
		"target_defense": 0,
		"is_critical": false,
		"message": ""
	}

	if not target or not target.is_alive():
		result.message = "Invalid target"
		return result

	# Check if target is enemy
	if target.is_enemy == user.is_enemy:
		result.message = "Cannot attack allies"
		return result

	# Check range
	var distance = CombatManager._calculate_grid_distance(user.grid_position, target.grid_position)
	if distance > ability.ability_range:
		result.message = "Target out of range (%d > %d)" % [distance, ability.ability_range]
		return result

	result.targets_affected = [target]

	# Check if auto-hit (like Smite) or requires attack roll
	if ability.auto_hit:
		result.hit = true
		result.roll = 0  # No roll for auto-hit
		result.total_attack = 0
		result.target_defense = 0
	else:
		# Standard attack roll
		var base_attack_bonus = user.get_attack_bonus()
		var attack_bonus = base_attack_bonus + ability.attack_modifier

		result.roll = randi_range(1, 20)
		result.total_attack = result.roll + attack_bonus
		result.target_defense = target.get_defense()
		result.is_critical = (result.roll == 20)
		result.hit = result.total_attack >= result.target_defense or result.is_critical

	if result.hit:
		# Calculate damage
		var damage_die = ability.fixed_damage_die if ability.fixed_damage_die > 0 else user.get_damage_die()
		var base_damage = randi_range(1, damage_die)

		# For holy damage (Smite), don't add user's damage modifier
		if ability.fixed_damage_die > 0:
			# Fixed damage die = holy/magic damage, no STR modifier
			pass
		else:
			base_damage += user.get_damage_modifier()

		var modified_damage = int(base_damage * ability.damage_multiplier) + ability.bonus_damage

		# Critical hit doubles damage (only if not auto-hit)
		if result.is_critical and not ability.auto_hit:
			modified_damage *= 2

		result.damage_dealt = max(1, modified_damage)
		result.success = true

		# Spawn holy damage number (light gold)
		_spawn_holy_damage_number(target, result.damage_dealt)

		# Apply damage
		target.take_damage(result.damage_dealt)

		result.message = "%s smites %s for %d holy damage" % [
			user.unit_name, target.unit_name, result.damage_dealt
		]
	else:
		# Spawn miss indicator
		_spawn_miss_number(target)
		result.message = "%s's smite misses %s" % [user.unit_name, target.unit_name]

	# Log combat
	print("[Combat] %s uses %s on %s" % [user.unit_name, ability.display_name, target.unit_name])
	if ability.auto_hit:
		print("[Combat] Auto-hit: %d holy damage" % result.damage_dealt)
	else:
		print("[Combat] Attack roll: %d + %d = %d vs DEF %d -> %s" % [
			result.roll, result.total_attack - result.roll, result.total_attack, result.target_defense,
			"HIT" if result.hit else "MISS"
		])
	if result.hit:
		print("[Combat] %s deals %d holy damage to %s%s" % [
			ability.display_name, result.damage_dealt, target.unit_name,
			" (CRITICAL!)" if result.is_critical else ""
		])

	return result

static func _spawn_heal_number(target: Unit, amount: int) -> void:
	## Create floating heal number at target (Task 2.6)
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display heal
	damage_number.show_heal(amount)

static func _spawn_holy_damage_number(target: Unit, amount: int) -> void:
	## Create floating holy damage number at target (Task 2.6: Smite)
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display holy damage
	damage_number.show_holy_damage(amount)

static func _spawn_full_hp_indicator(target: Unit) -> void:
	## Create floating "Full HP" indicator at target (Task 2.6)
	var damage_number = DamageNumberScene.instantiate() as DamageNumber

	# Add to scene tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)

	# Position above target
	damage_number.global_position = target.global_position + Vector2(0, -30)

	# Display "Full HP" in green
	damage_number.show_text("Full HP", Color("#27ae60"))
