## CombatManager - Global combat state management
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.4-click-to-select-unit.md, docs/features/1.8-turn-system-framework.md
## Handles: Unit selection, movement (Task 1.5), turn management (Task 1.8), combat flow
extends Node

# ===== TURN STATE ENUM =====
enum TurnState {
	INACTIVE,          # No battle active
	WAITING_FOR_INPUT, # Current unit can act
	MOVING,            # Unit is moving
	TARGETING,         # Selecting target for ability (Task 2.3)
	ACTING,            # Unit is performing action
	TURN_END,          # Turn is ending
	BATTLE_ENDED       # Battle has concluded (Task 1.9)
}

# ===== SIGNALS =====
signal unit_selected(unit: Unit)
signal unit_deselected(unit: Unit)
signal selection_changed(old_unit: Unit, new_unit: Unit)
signal movement_started(unit: Unit)
signal movement_finished(unit: Unit)
signal turn_state_changed(old_state: TurnState, new_state: TurnState)
signal battle_started(units: Array[Unit])
signal battle_ended()
signal battle_won(gold_earned: int)  # Task 1.9
signal battle_lost()                  # Task 1.9
signal turn_started(unit: Unit)
signal turn_ended(unit: Unit)
signal attack_executed(attacker: Unit, target: Unit, hit: bool, damage: int)
signal ability_targeting_started(ability_id: String, valid_targets: Array[Unit])
signal ability_targeting_cancelled()
signal ability_executed(user: Unit, ability_id: String, result: Dictionary)
signal unit_teleported(unit: Unit, from: Vector2i, to: Vector2i)  # Task 2.5: Shadowstep
signal tile_targeting_started(ability_id: String, valid_tiles: Array[Vector2i])  # Task 2.5
signal opportunity_attack_triggered(attacker: Unit, target: Unit)  # Task 2.13
signal opportunity_attack_completed(attacker: Unit, target: Unit, damage: int)  # Task 2.13

# ===== STATE =====
var selected_unit: Unit = null
var _moving_unit: Unit = null

# ===== ABILITY TARGETING STATE (Task 2.3) =====
var _pending_ability_id: String = ""
var _pending_ability: Resource = null  # Ability resource
var _valid_targets: Array[Unit] = []

# ===== TILE TARGETING STATE (Task 2.5) =====
var _valid_teleport_tiles: Array[Vector2i] = []  # For Shadowstep targeting

# ===== TURN STATE =====
var _turn_state: TurnState = TurnState.INACTIVE
var _current_turn_unit: Unit = null
var _turn_manager: TurnManager = null

# ===== SOLDIER ORDER STATE (Task 2.11) =====
var _focus_fire_target: Unit = null           # Target for FOCUS_FIRE orders
var _protected_allies: Dictionary = {}        # Mapping of soldier -> protected ally
var _interception_used: Dictionary = {}       # Track which soldiers have intercepted this round

# ===== GRID REFERENCE (Task 2.7) =====
var _combat_grid: CombatGrid = null

# ===== ORDER PANEL REFERENCE (Task 2.10) =====
var _order_panel: OrderPanel = null

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[CombatManager] Initialized")

func _unhandled_input(event: InputEvent) -> void:
	## Handle global input for combat (Task 2.3)
	# Cancel ability targeting on right-click or ESC
	if _turn_state == TurnState.TARGETING:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_ability_targeting()
				get_viewport().set_input_as_handled()
		elif event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.pressed:
				cancel_ability_targeting()
				get_viewport().set_input_as_handled()

# ===== TURN STATE MANAGEMENT =====
func set_turn_state(new_state: TurnState) -> void:
	## Change the current turn state
	var old_state = _turn_state
	_turn_state = new_state
	turn_state_changed.emit(old_state, new_state)
	print("[CombatManager] State: %s -> %s" % [
		TurnState.keys()[old_state],
		TurnState.keys()[new_state]
	])

func get_turn_state() -> TurnState:
	return _turn_state

func is_waiting_for_input() -> bool:
	return _turn_state == TurnState.WAITING_FOR_INPUT

func can_unit_act(unit: Unit) -> bool:
	## Check if a unit is allowed to act right now
	# Allow actions in WAITING_FOR_INPUT or TARGETING state
	if _turn_state != TurnState.WAITING_FOR_INPUT and _turn_state != TurnState.TARGETING:
		return false
	return unit == _current_turn_unit

func get_current_turn_unit() -> Unit:
	## Get the unit whose turn it is
	return _current_turn_unit

func is_battle_active() -> bool:
	## Check if a battle is currently in progress
	return _turn_state != TurnState.INACTIVE

# ===== TURN MANAGER INTEGRATION =====
func start_battle(units: Array[Unit]) -> void:
	## Start a new battle with the given units
	if _turn_manager:
		_turn_manager.queue_free()

	_turn_manager = TurnManager.new()
	_turn_manager.name = "TurnManager"
	add_child(_turn_manager)

	# Connect turn manager signals
	_turn_manager.battle_started.connect(_on_battle_started)
	_turn_manager.turn_started.connect(_on_turn_started)
	_turn_manager.turn_ended.connect(_on_turn_ended)
	_turn_manager.round_started.connect(_on_round_started)
	_turn_manager.round_ended.connect(_on_round_ended)
	_turn_manager.battle_won.connect(_on_battle_won)    # Task 1.9
	_turn_manager.battle_lost.connect(_on_battle_lost)  # Task 1.9

	# Task 2.8: Pass combat grid reference for soldier AI
	if _combat_grid:
		_turn_manager.set_combat_grid(_combat_grid)

	_turn_manager.start_battle(units)

func end_battle() -> void:
	## End the current battle
	if _turn_manager:
		_turn_manager.end_battle()
	set_turn_state(TurnState.INACTIVE)
	_current_turn_unit = null
	deselect_unit()
	battle_ended.emit()
	print("[CombatManager] Battle ended")

func end_current_turn() -> void:
	## End the current unit's turn manually
	if _turn_manager:
		set_turn_state(TurnState.TURN_END)
		_turn_manager.end_current_turn()

func get_turn_manager() -> TurnManager:
	return _turn_manager

func get_turn_order() -> Array[Unit]:
	## Get the current turn order
	if _turn_manager:
		return _turn_manager.get_turn_order()
	return []

# ===== TURN MANAGER SIGNAL HANDLERS =====
func _on_battle_started(units: Array[Unit]) -> void:
	battle_started.emit(units)

func _on_turn_started(unit: Unit) -> void:
	_current_turn_unit = unit

	# Set state to WAITING_FOR_INPUT first (before selection, so movement range shows)
	set_turn_state(TurnState.WAITING_FOR_INPUT)

	# Auto-select if friendly unit
	if unit.is_friendly():
		select_unit(unit)

	# Emit turn started signal for UI updates
	turn_started.emit(unit)

func _on_turn_ended(unit: Unit) -> void:
	set_turn_state(TurnState.TURN_END)
	_current_turn_unit = null
	deselect_unit()

	# Emit turn ended signal for UI updates
	turn_ended.emit(unit)

func _on_round_started(round_number: int) -> void:
	print("[CombatManager] Round %d started" % round_number)
	# Task 2.11: Reset PROTECT interception flags at the start of each round
	reset_interception_flags()

func _on_round_ended(round_number: int) -> void:
	print("[CombatManager] Round %d ended" % round_number)

# ===== BATTLE END HANDLERS (Task 1.9) =====
func _on_battle_won(gold_earned: int) -> void:
	## Handle victory from TurnManager
	set_turn_state(TurnState.BATTLE_ENDED)
	_current_turn_unit = null
	deselect_unit()
	battle_won.emit(gold_earned)
	print("[CombatManager] Battle won! Gold: %d" % gold_earned)

func _on_battle_lost() -> void:
	## Handle defeat from TurnManager
	set_turn_state(TurnState.BATTLE_ENDED)
	_current_turn_unit = null
	deselect_unit()
	battle_lost.emit()
	print("[CombatManager] Battle lost!")

# ===== SELECTION API =====
func select_unit(unit: Unit) -> void:
	## Select a unit, deselecting any previously selected unit
	if unit == null:
		deselect_unit()
		return

	# Can only select friendly, living units during their turn
	if not unit.is_alive():
		deselect_unit()
		return

	# During battle, can only select the current turn unit (if friendly)
	if is_battle_active() and unit != _current_turn_unit:
		print("[CombatManager] Cannot select - not this unit's turn")
		return

	# Can only select enemies for targeting (handled elsewhere)
	if unit.is_enemy:
		return

	# Don't re-select already selected unit (but don't deselect either)
	if unit == selected_unit:
		return

	var old_unit = selected_unit

	# Deselect previous unit
	if selected_unit != null:
		selected_unit.deselect()
		unit_deselected.emit(selected_unit)

	# Select new unit
	selected_unit = unit
	selected_unit.select()
	unit_selected.emit(selected_unit)
	selection_changed.emit(old_unit, selected_unit)

	print("[CombatManager] Selected: %s" % unit.unit_name)

func deselect_unit() -> void:
	## Deselect the currently selected unit
	if selected_unit == null:
		return

	var old_unit = selected_unit
	selected_unit.deselect()
	selected_unit = null

	unit_deselected.emit(old_unit)
	selection_changed.emit(old_unit, null)

	print("[CombatManager] Deselected")

func get_selected_unit() -> Unit:
	## Get the currently selected unit (or null)
	return selected_unit

func has_selection() -> bool:
	## Check if any unit is selected
	return selected_unit != null

func is_unit_selected(unit: Unit) -> bool:
	## Check if a specific unit is selected
	return selected_unit == unit

# ===== MOVEMENT API (Task 1.5) =====
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	## Initiate unit movement along a path
	if unit == null or path.size() < 2:
		return

	# Check if unit can act
	if is_battle_active() and not can_unit_act(unit):
		print("[CombatManager] Cannot move - not this unit's turn")
		return

	# Don't allow movement if another unit is moving
	if is_unit_moving():
		print("[CombatManager] Cannot move - another unit is already moving")
		return

	# Task 2.13: Check for opportunity attacks before movement
	var aoo_attackers = check_opportunity_attacks(unit, path)
	if not aoo_attackers.is_empty():
		print("[CombatManager] %d enemy units will get opportunity attacks" % aoo_attackers.size())
		# Execute AoO - returns false if unit died
		var unit_survived = execute_opportunity_attacks(aoo_attackers, unit)
		if not unit_survived:
			print("[CombatManager] %s killed by opportunity attack - movement cancelled" % unit.unit_name)
			# Unit died, movement cancelled
			# Don't change turn state - turn will end via unit death handling
			return

	# Set state to Moving
	set_turn_state(TurnState.MOVING)

	_moving_unit = unit
	movement_started.emit(unit)

	# Connect to unit's movement finished signal
	unit.movement_finished.connect(_on_unit_movement_finished, CONNECT_ONE_SHOT)

	# Start the movement animation
	unit.move_along_path(path)

	print("[CombatManager] %s starting movement to %s" % [unit.unit_name, path[path.size() - 1]])

func _on_unit_movement_finished(unit: Unit) -> void:
	## Called when a unit completes its movement
	_moving_unit = null
	movement_finished.emit(unit)

	# Return to waiting for input (can still attack after moving)
	# Don't deselect - player should be able to act after moving
	if _current_turn_unit == unit:
		set_turn_state(TurnState.WAITING_FOR_INPUT)

	print("[CombatManager] %s finished movement at %s" % [unit.unit_name, unit.grid_position])

func is_unit_moving() -> bool:
	## Check if any unit is currently moving
	return _moving_unit != null

func get_moving_unit() -> Unit:
	## Get the currently moving unit (or null)
	return _moving_unit

# ===== ATTACK API (Task 1.7) =====
func attempt_attack(attacker: Unit, target: Unit) -> bool:
	## Attempt to attack a target, return true if attack executed
	if attacker == null or target == null:
		return false

	# Check if it's the attacker's turn
	if is_battle_active() and not can_unit_act(attacker):
		print("[CombatManager] Cannot attack - not this unit's turn")
		return false

	# Check if attack is valid (adjacency, alive, not friendly fire)
	if not attacker.can_attack(target):
		print("[CombatManager] Invalid attack: %s cannot attack %s" % [
			attacker.unit_name if attacker else "null",
			target.unit_name if target else "null"
		])
		return false

	# Set state to Acting
	set_turn_state(TurnState.ACTING)

	# Execute the attack
	attacker.perform_attack(target)

	# Emit attack signal for UI/logging
	# Note: We'd need to get the result from the attack, but for now just emit basic info
	attack_executed.emit(attacker, target, target.is_alive(), 0)

	# Attack ends the turn
	_on_action_completed(attacker)

	return true

func start_unit_action(unit: Unit, _action_type: String, _target: Unit) -> void:
	## Start a unit action (attack/ability) - legacy placeholder
	if not can_unit_act(unit):
		print("[CombatManager] Unit cannot act - not their turn")
		return

	set_turn_state(TurnState.ACTING)

func _on_action_completed(_unit: Unit) -> void:
	## Called when a unit completes their action
	# Actions end the turn
	if _turn_manager:
		_turn_manager.end_current_turn()

# ===== ABILITY HELPER METHODS (Task 2.3) =====
func has_adjacent_enemies(unit: Unit) -> bool:
	## Check if the unit has any adjacent enemies
	if not unit or not _turn_manager:
		return false

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Check if enemy and adjacent
		if other.is_enemy != unit.is_enemy:
			if AttackResolver.is_adjacent(unit, other):
				return true
	return false

func get_adjacent_enemies(unit: Unit) -> Array[Unit]:
	## Get all adjacent enemy units
	var enemies: Array[Unit] = []
	if not unit or not _turn_manager:
		return enemies

	var turn_order = _turn_manager.get_turn_order()
	print("[CombatManager] Checking adjacent enemies for %s at %s" % [unit.unit_name, unit.grid_position])
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		if other.is_enemy != unit.is_enemy:
			var is_adj = AttackResolver.is_adjacent(unit, other)
			print("[CombatManager]   %s at %s - adjacent=%s" % [other.unit_name, other.grid_position, is_adj])
			if is_adj:
				enemies.append(other)
	return enemies

func get_friendly_soldiers(unit: Unit) -> Array[Unit]:
	## Get all friendly soldier units for the given unit's faction
	var soldiers: Array[Unit] = []
	if not unit or not _turn_manager:
		return soldiers

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Same faction and is a soldier
		if other.is_enemy == unit.is_enemy and other.is_soldier:
			soldiers.append(other)
	return soldiers

func get_all_friendly_units(unit: Unit) -> Array[Unit]:
	## Get all friendly units (including party members)
	var friendlies: Array[Unit] = []
	if not unit or not _turn_manager:
		return friendlies

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		if other.is_enemy == unit.is_enemy:
			friendlies.append(other)
	return friendlies

func get_enemies_in_range(unit: Unit, range_tiles: int) -> Array[Unit]:
	## Get all enemy units within specified range (Task 2.4: for Taunt)
	var enemies: Array[Unit] = []
	if not unit or not _turn_manager:
		return enemies

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Check if enemy
		if other.is_enemy != unit.is_enemy:
			# Calculate grid distance
			var distance = _calculate_grid_distance(unit.grid_position, other.grid_position)
			if distance <= range_tiles:
				enemies.append(other)
	return enemies

func _calculate_grid_distance(pos1: Vector2i, pos2: Vector2i) -> int:
	## Calculate Chebyshev distance (allows diagonal movement)
	return max(abs(pos1.x - pos2.x), abs(pos1.y - pos2.y))

# ===== ALLY RANGE HELPER METHODS (Task 2.6) =====
func get_allies_in_range(unit: Unit, range_tiles: int, exclude_self: bool = false) -> Array[Unit]:
	## Get all friendly units within specified range (Task 2.6: for Heal)
	var allies: Array[Unit] = []
	if not unit or not _turn_manager:
		return allies

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Check if same faction
		if other.is_enemy == unit.is_enemy:
			# Skip self if exclude_self is true
			if exclude_self and other == unit:
				continue
			# Calculate grid distance
			var distance = _calculate_grid_distance(unit.grid_position, other.grid_position)
			if distance <= range_tiles:
				allies.append(other)
	return allies

func has_allies_in_range(unit: Unit, range_tiles: int, exclude_self: bool = false) -> bool:
	## Check if there are any friendly units within range (Task 2.6)
	var allies = get_allies_in_range(unit, range_tiles, exclude_self)
	return allies.size() > 0

func has_enemies_in_range_check(unit: Unit, range_tiles: int) -> bool:
	## Check if there are any enemy units within range (Task 2.6)
	var enemies = get_enemies_in_range(unit, range_tiles)
	return enemies.size() > 0

# ===== TAUNT HELPER METHODS (Task 2.4) =====
func is_unit_taunted(unit: Unit) -> bool:
	## Check if a unit is currently taunted
	if not is_instance_valid(unit):
		return false
	return StatusEffectManager.has_effect(unit, "TAUNTED")

func get_taunt_target(unit: Unit) -> Unit:
	## Get the unit that a taunted unit must attack (Task 2.4)
	## Returns null if unit is not taunted or taunt source is dead
	if not is_instance_valid(unit):
		return null

	var taunt_source = StatusEffectManager.get_taunt_source(unit)
	if taunt_source and is_instance_valid(taunt_source) and taunt_source.is_alive():
		return taunt_source
	return null

func notify_unit_death(unit: Unit) -> void:
	## Notify turn manager that a unit has died
	if _turn_manager:
		_turn_manager.remove_unit(unit)

# ===== TELEPORT HELPER METHODS (Task 2.5) =====
func has_valid_teleport_tiles(unit: Unit, range_tiles: int) -> bool:
	## Check if there are valid teleport destinations (for Shadowstep availability)
	var valid_tiles = get_valid_teleport_tiles(unit, range_tiles)
	return valid_tiles.size() > 0

func get_valid_teleport_tiles(unit: Unit, range_tiles: int) -> Array[Vector2i]:
	## Get all valid teleport destinations within range (Task 2.5: Shadowstep)
	## Valid tiles: within range, not occupied, optionally on grid
	var valid_tiles: Array[Vector2i] = []
	if not unit:
		return valid_tiles

	var unit_pos = unit.grid_position

	# Check all tiles within Chebyshev distance (allows diagonal)
	for dx in range(-range_tiles, range_tiles + 1):
		for dy in range(-range_tiles, range_tiles + 1):
			if dx == 0 and dy == 0:
				continue  # Can't teleport to current position

			var check_pos = Vector2i(unit_pos.x + dx, unit_pos.y + dy)

			# Check if within range (Chebyshev distance)
			var distance = max(abs(dx), abs(dy))
			if distance > range_tiles:
				continue

			# Check if tile is occupied
			if is_tile_occupied(check_pos):
				continue

			# Check if tile is within grid bounds (if we have grid reference)
			if unit.combat_grid and not unit.combat_grid.is_valid_position(check_pos):
				continue

			valid_tiles.append(check_pos)

	return valid_tiles

func is_tile_occupied(position: Vector2i) -> bool:
	## Check if a grid position is occupied by any unit (Task 2.5)
	if not _turn_manager:
		return false

	var turn_order = _turn_manager.get_turn_order()
	for unit in turn_order:
		if is_instance_valid(unit) and unit.is_alive():
			if unit.grid_position == position:
				return true
	return false

# ===== LINE OF SIGHT HELPERS (Task 2.7) =====
func set_combat_grid(grid: CombatGrid) -> void:
	## Set reference to combat grid for LoS checks
	_combat_grid = grid
	print("[CombatManager] Combat grid reference set")

# ===== ORDER PANEL METHODS (Task 2.10) =====

func set_order_panel(panel: OrderPanel) -> void:
	## Set reference to order panel for order assignment
	_order_panel = panel
	print("[CombatManager] Order panel reference set")

func is_assigning_order() -> bool:
	## Check if currently in order assignment mode
	if _order_panel:
		return _order_panel.is_assigning()
	return false

func try_assign_order(unit: Unit) -> bool:
	## Attempt to assign pending order to a unit
	## Returns true if order was assigned, false otherwise
	if _order_panel and _order_panel.is_assigning():
		return _order_panel.try_assign_order_to_unit(unit)
	return false

func get_combat_grid() -> CombatGrid:
	## Get the combat grid reference
	# Try stored reference first
	if _combat_grid:
		return _combat_grid
	# Fallback: try to get from current turn unit
	if _current_turn_unit and _current_turn_unit.combat_grid:
		return _current_turn_unit.combat_grid
	# Last resort: try to get from any unit in battle
	if _turn_manager:
		var units = _turn_manager.get_turn_order()
		for unit in units:
			if is_instance_valid(unit) and unit.combat_grid:
				return unit.combat_grid
	return null

func is_tile_blocked_for_los(position: Vector2i) -> bool:
	## Check if a tile blocks line of sight (obstacles only, NOT units)
	## Returns true if tile blocks LoS, false otherwise
	var grid = get_combat_grid()
	if not grid:
		# No grid reference, assume not blocked
		return false

	# Check if out of bounds (blocks LoS)
	if not grid.is_valid_position(position):
		return true

	# Check if tile is an obstacle
	return grid.is_obstacle(position)

func get_enemies_in_range_with_los(unit: Unit, range_tiles: int) -> Array[Unit]:
	## Get all enemy units within range AND with clear line of sight (Task 2.7)
	var enemies: Array[Unit] = []
	if not unit or not _turn_manager:
		return enemies

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Check if enemy
		if other.is_enemy != unit.is_enemy:
			# Use AttackResolver's range and LoS check
			if AttackResolver.can_attack_at_range(unit, other):
				enemies.append(other)
	return enemies

func teleport_unit(unit: Unit, destination: Vector2i) -> void:
	## Execute teleport for a unit (Task 2.5: Shadowstep)
	if not unit:
		return

	var from_position = unit.grid_position
	unit.teleport_to(destination)
	unit_teleported.emit(unit, from_position, destination)
	print("[CombatManager] %s teleported from %s to %s" % [unit.unit_name, from_position, destination])

func get_valid_teleport_tiles_for_targeting() -> Array[Vector2i]:
	## Get cached valid teleport tiles for current targeting
	return _valid_teleport_tiles

# ===== SOLDIER ORDER METHODS (Task 2.11) =====

func set_focus_fire_target(target: Unit) -> void:
	## Set the FOCUS_FIRE target for all soldiers with that order
	_focus_fire_target = target
	if target:
		print("[CombatManager] FOCUS_FIRE target set: %s" % target.unit_name)
	else:
		print("[CombatManager] FOCUS_FIRE target cleared")

func clear_focus_fire_target() -> void:
	## Clear the FOCUS_FIRE target
	_focus_fire_target = null
	print("[CombatManager] FOCUS_FIRE target cleared")

func get_focus_fire_target() -> Unit:
	## Get the current FOCUS_FIRE target
	if _focus_fire_target and is_instance_valid(_focus_fire_target) and _focus_fire_target.is_alive():
		return _focus_fire_target
	return null

func set_protected_ally(soldier: Unit, ally: Unit) -> void:
	## Set a PROTECT relationship between soldier and ally
	if soldier and ally:
		_protected_allies[soldier] = ally
		print("[CombatManager] PROTECT set: %s protecting %s" % [soldier.unit_name, ally.unit_name])

func clear_protected_ally(soldier: Unit) -> void:
	## Clear a PROTECT relationship for a soldier
	if soldier in _protected_allies:
		var ally = _protected_allies[soldier]
		_protected_allies.erase(soldier)
		print("[CombatManager] PROTECT cleared: %s no longer protecting %s" % [
			soldier.unit_name, ally.unit_name if ally else "unknown"
		])

func get_protected_ally(soldier: Unit) -> Unit:
	## Get the ally a soldier is protecting (or null)
	if soldier in _protected_allies:
		var ally = _protected_allies[soldier]
		if is_instance_valid(ally) and ally.is_alive():
			return ally
		else:
			# Ally died, clear the relationship
			_protected_allies.erase(soldier)
	return null

func get_protector_for_unit(unit: Unit) -> Unit:
	## Get the soldier protecting a specific unit (if any)
	for soldier in _protected_allies:
		if is_instance_valid(soldier) and soldier.is_alive():
			var protected = _protected_allies[soldier]
			if protected == unit:
				return soldier
	return null

func reset_interception_flags() -> void:
	## Reset interception flags at the start of a new round
	_interception_used.clear()
	print("[CombatManager] Interception flags reset for new round")

func can_soldier_intercept(soldier: Unit) -> bool:
	## Check if a soldier can still intercept an attack this round
	if not soldier or not is_instance_valid(soldier):
		return false
	return not (soldier in _interception_used)

func mark_interception_used(soldier: Unit) -> void:
	## Mark that a soldier has used their interception this round
	if soldier:
		_interception_used[soldier] = true
		print("[CombatManager] %s has used interception this round" % soldier.unit_name)

func try_intercept_attack(target: Unit, damage: int) -> Dictionary:
	## Check if a PROTECT soldier can intercept an attack on target
	## Returns {intercepted: bool, protector: Unit or null}
	var protector = get_protector_for_unit(target)
	if not protector:
		return {"intercepted": false, "protector": null}

	# Check if protector is adjacent to target
	var dist = max(abs(protector.grid_position.x - target.grid_position.x),
				   abs(protector.grid_position.y - target.grid_position.y))
	if dist > 1:
		print("[CombatManager] Protector %s not adjacent to %s (dist=%d)" % [
			protector.unit_name, target.unit_name, dist
		])
		return {"intercepted": false, "protector": null}

	# Check if protector can still intercept this round
	if not can_soldier_intercept(protector):
		print("[CombatManager] %s already used interception this round" % protector.unit_name)
		return {"intercepted": false, "protector": null}

	# Intercept!
	mark_interception_used(protector)
	print("[CombatManager] %s intercepts attack on %s!" % [protector.unit_name, target.unit_name])
	return {"intercepted": true, "protector": protector}

# ===== ATTACK OF OPPORTUNITY METHODS (Task 2.13) =====

func check_opportunity_attacks(moving_unit: Unit, path: Array[Vector2i]) -> Array[Unit]:
	## Check if moving along path triggers any opportunity attacks
	## Returns array of enemies who will get AoO (each can only attack once)
	var attackers: Array[Unit] = []
	if not moving_unit or path.size() < 2:
		return attackers

	# Track which enemies we've already added (avoid duplicates)
	var added_enemies: Dictionary = {}

	# Get the first position in the path (starting position)
	var current_pos = path[0]

	# Check each step in the path
	for i in range(1, path.size()):
		var next_pos = path[i]

		# Get all enemies adjacent to current position
		var adjacent_enemies = _get_enemies_adjacent_to_position(moving_unit, current_pos)

		for enemy in adjacent_enemies:
			# Skip if already added this enemy
			if enemy in added_enemies:
				continue

			# Check if moving to next_pos LEAVES this enemy's adjacency
			if not _is_adjacent_to_position(next_pos, enemy.grid_position):
				# This move triggers AoO from this enemy
				if enemy.can_perform_opportunity_attack():
					attackers.append(enemy)
					added_enemies[enemy] = true
					print("[CombatManager] %s leaving %s's threat zone triggers AoO" % [
						moving_unit.unit_name, enemy.unit_name
					])

		current_pos = next_pos

	return attackers

func _get_enemies_adjacent_to_position(unit: Unit, pos: Vector2i) -> Array[Unit]:
	## Get all enemy units adjacent to a specific grid position
	var enemies: Array[Unit] = []
	if not unit or not _turn_manager:
		return enemies

	var turn_order = _turn_manager.get_turn_order()
	for other in turn_order:
		if not is_instance_valid(other) or not other.is_alive():
			continue
		# Check if enemy (different faction)
		if other.is_enemy != unit.is_enemy:
			# Check if adjacent to position
			if _is_adjacent_to_position(pos, other.grid_position):
				enemies.append(other)

	return enemies

func _is_adjacent_to_position(pos1: Vector2i, pos2: Vector2i) -> bool:
	## Check if two positions are adjacent (8-directional, Chebyshev distance = 1)
	var diff = pos2 - pos1
	return abs(diff.x) <= 1 and abs(diff.y) <= 1 and diff != Vector2i.ZERO

func execute_opportunity_attacks(attackers: Array[Unit], target: Unit) -> bool:
	## Execute all opportunity attacks against a target
	## Returns true if target survives, false if target died
	if attackers.is_empty() or not target:
		return true

	for attacker in attackers:
		if not is_instance_valid(attacker) or not attacker.is_alive():
			continue
		if not is_instance_valid(target) or not target.is_alive():
			# Target already dead
			return false

		# Emit signal before attack
		opportunity_attack_triggered.emit(attacker, target)

		# Spawn "OPPORTUNITY!" indicator
		_spawn_opportunity_indicator(attacker)

		# Perform the attack
		print("[CombatManager] %s performs opportunity attack on %s!" % [
			attacker.unit_name, target.unit_name
		])

		# Use the existing attack system
		var result = AttackResolver.resolve_attack(attacker, target)

		# Spawn damage number on target
		_spawn_aoo_damage_number(target, result)

		# Apply damage if hit
		var damage_dealt = 0
		if result.hit:
			target.take_damage(result.damage)
			damage_dealt = result.damage

		# Mark that attacker used their AoO
		attacker.mark_opportunity_attack_used()

		# Emit completion signal
		opportunity_attack_completed.emit(attacker, target, damage_dealt)

		# Log the attack
		print("[CombatManager] AoO: %s vs %s - Roll %d + %d = %d vs DEF %d -> %s for %d damage" % [
			attacker.unit_name,
			target.unit_name,
			result.roll,
			result.total_attack - result.roll,
			result.total_attack,
			result.target_defense,
			"HIT" if result.hit else "MISS",
			result.damage if result.hit else 0
		])

		# Check if target died
		if not target.is_alive():
			print("[CombatManager] %s killed by opportunity attack!" % target.unit_name)
			return false

	return true

func _spawn_opportunity_indicator(attacker: Unit) -> void:
	## Spawn "OPPORTUNITY!" floating text above attacker
	var DamageNumberScene = preload("res://scenes/UI/DamageNumber.tscn")
	var indicator = DamageNumberScene.instantiate() as DamageNumber
	# Add to tree FIRST (required for global_position to work correctly)
	attacker.get_parent().add_child(indicator)
	indicator.global_position = attacker.global_position + Vector2(0, -50)
	# Orange color for opportunity attack
	indicator.show_text("OPPORTUNITY!", Color(1.0, 0.6, 0.0))

	# Brief flash on attacker (orange)
	var tween = attacker.create_tween()
	tween.tween_property(attacker, "modulate", Color(1.0, 0.7, 0.3), 0.1)
	tween.tween_property(attacker, "modulate", Color.WHITE, 0.2)

func _spawn_aoo_damage_number(target: Unit, result: AttackResolver.AttackResult) -> void:
	## Spawn damage number for AoO attack result
	var DamageNumberScene = preload("res://scenes/UI/DamageNumber.tscn")
	var damage_number = DamageNumberScene.instantiate() as DamageNumber
	# Add to tree FIRST (required for global_position to work correctly)
	target.get_parent().add_child(damage_number)
	damage_number.global_position = target.global_position + Vector2(0, -30)

	if result.hit:
		damage_number.show_damage(result.damage, result.is_critical)
	else:
		damage_number.show_miss()

# ===== ABILITY EXECUTION API (Task 2.3) =====
func execute_ability(user: Unit, ability_id: String, target: Unit = null) -> bool:
	## Execute an ability for a unit
	if not user or not is_battle_active():
		return false

	# Check if it's the user's turn
	if not can_unit_act(user):
		print("[CombatManager] Cannot use ability - not this unit's turn")
		return false

	# Load the ability resource
	var ability = user.get_ability_resource(ability_id)
	if not ability:
		print("[CombatManager] Ability not found: %s" % ability_id)
		return false

	# Check if ability is available
	if not user.is_ability_available(ability_id):
		print("[CombatManager] Ability not available: %s" % ability_id)
		return false

	# Set state to Acting
	set_turn_state(TurnState.ACTING)

	# Execute using AbilityExecutor
	var result = AbilityExecutor.execute(user, ability, target)

	# Record ability use
	user.use_ability(ability_id)

	print("[CombatManager] %s used %s - %s" % [
		user.unit_name,
		ability.display_name,
		"Hit!" if result.get("hit", false) else ("Buffed" if result.get("buff_applied", false) else "Missed")
	])

	# Emit ability executed signal
	ability_executed.emit(user, ability_id, result)

	# If ability ends turn, complete the action
	if ability.ends_turn:
		_on_action_completed(user)

	return true

# ===== ABILITY SELECTION API (Task 2.3) =====
func select_ability(ability_id: String) -> void:
	## Called when player selects an ability from the ability bar
	# Allow selecting ability from WAITING_FOR_INPUT or TARGETING state (to switch abilities)
	if not _current_turn_unit:
		print("[CombatManager] Cannot select ability - no current unit")
		return

	if _turn_state != TurnState.WAITING_FOR_INPUT and _turn_state != TurnState.TARGETING:
		print("[CombatManager] Cannot select ability - not in valid state")
		return

	# If already targeting, cancel current targeting first
	if _turn_state == TurnState.TARGETING:
		_pending_ability_id = ""
		_pending_ability = null
		_valid_targets.clear()
		_valid_teleport_tiles.clear()

	var ability = _current_turn_unit.get_ability_resource(ability_id)
	if not ability:
		print("[CombatManager] Ability not found: %s" % ability_id)
		return

	if not _current_turn_unit.is_ability_available(ability_id):
		print("[CombatManager] Ability not available: %s" % ability_id)
		return

	# Check if ability requires a target
	print("[CombatManager] Ability %s requires_target=%s, target_type=%s, ability_type=%s" % [
		ability_id, ability.requires_target, ability.target_type, ability.ability_type
	])

	# Handle SELF_BUFF abilities - execute immediately (Task 2.5)
	if ability.ability_type == Ability.AbilityType.SELF_BUFF:
		print("[CombatManager] Executing self-buff %s immediately" % ability_id)
		execute_ability(_current_turn_unit, ability_id, null)
		return

	# Handle PARTY_BUFF abilities - execute immediately (Task 2.6: Bless)
	if ability.ability_type == Ability.AbilityType.PARTY_BUFF:
		print("[CombatManager] Executing party buff %s immediately" % ability_id)
		execute_ability(_current_turn_unit, ability_id, null)
		return

	# Handle TELEPORT abilities - target tiles instead of units (Task 2.5)
	if ability.ability_type == Ability.AbilityType.TELEPORT:
		_pending_ability_id = ability_id
		_pending_ability = ability
		_valid_teleport_tiles = get_valid_teleport_tiles(_current_turn_unit, ability.ability_range)

		print("[CombatManager] Found %d valid teleport tiles for %s" % [_valid_teleport_tiles.size(), ability_id])

		if _valid_teleport_tiles.is_empty():
			print("[CombatManager] No valid teleport tiles for %s" % ability_id)
			cancel_ability_targeting()
			return

		set_turn_state(TurnState.TARGETING)
		tile_targeting_started.emit(ability_id, _valid_teleport_tiles)
		print("[CombatManager] TILE TARGETING mode activated for %s - click a highlighted tile!" % ability_id)
		return

	if ability.requires_target:
		# Enter targeting mode
		_pending_ability_id = ability_id
		_pending_ability = ability
		_valid_targets = _get_valid_targets_for_ability(ability)

		print("[CombatManager] Found %d valid targets for %s" % [_valid_targets.size(), ability_id])

		if _valid_targets.is_empty():
			print("[CombatManager] No valid targets for %s - need adjacent enemy!" % ability_id)
			cancel_ability_targeting()
			return

		set_turn_state(TurnState.TARGETING)
		ability_targeting_started.emit(ability_id, _valid_targets)
		print("[CombatManager] TARGETING mode activated for %s - click a red highlighted enemy!" % ability_id)
	else:
		# Execute immediately (no target needed - e.g., Rally)
		print("[CombatManager] Executing %s immediately (no target needed)" % ability_id)
		execute_ability(_current_turn_unit, ability_id, null)

func cancel_ability_targeting() -> void:
	## Cancel ability targeting and return to waiting for input
	if _turn_state != TurnState.TARGETING:
		return

	_pending_ability_id = ""
	_pending_ability = null
	_valid_targets.clear()
	_valid_teleport_tiles.clear()  # Task 2.5
	set_turn_state(TurnState.WAITING_FOR_INPUT)
	ability_targeting_cancelled.emit()
	print("[CombatManager] Ability targeting cancelled")

func select_teleport_tile(tile_position: Vector2i) -> bool:
	## Called when player clicks a tile while in teleport targeting mode (Task 2.5)
	print("[CombatManager] select_teleport_tile called for %s" % tile_position)

	if _turn_state != TurnState.TARGETING:
		print("[CombatManager] FAILED: Not in TARGETING state")
		return false

	if _pending_ability_id.is_empty():
		print("[CombatManager] FAILED: No pending ability")
		return false

	if not tile_position in _valid_teleport_tiles:
		print("[CombatManager] FAILED: Tile not in valid teleport tiles")
		return false

	var ability_id = _pending_ability_id
	print("[CombatManager] Executing teleport %s to %s" % [ability_id, tile_position])

	# Execute the teleport ability
	var success = execute_ability_on_tile(_current_turn_unit, ability_id, tile_position)

	# Clear targeting state if execution succeeded
	if success:
		_pending_ability_id = ""
		_pending_ability = null
		_valid_teleport_tiles.clear()
	else:
		print("[CombatManager] Teleport execution failed, keeping targeting state")

	return success

func execute_ability_on_tile(user: Unit, ability_id: String, tile_position: Vector2i) -> bool:
	## Execute an ability that targets a tile (Task 2.5: Shadowstep)
	if not user or not is_battle_active():
		return false

	if not can_unit_act(user):
		print("[CombatManager] Cannot use ability - not this unit's turn")
		return false

	var ability = user.get_ability_resource(ability_id)
	if not ability:
		print("[CombatManager] Ability not found: %s" % ability_id)
		return false

	if not user.is_ability_available(ability_id):
		print("[CombatManager] Ability not available: %s" % ability_id)
		return false

	# Set state to Acting
	set_turn_state(TurnState.ACTING)

	# Execute using AbilityExecutor with tile target
	var result = AbilityExecutor.execute_on_tile(user, ability, tile_position)

	# Record ability use
	user.use_ability(ability_id)

	print("[CombatManager] %s used %s on tile %s - %s" % [
		user.unit_name,
		ability.display_name,
		tile_position,
		"Success" if result.get("success", false) else "Failed"
	])

	# Emit ability executed signal
	ability_executed.emit(user, ability_id, result)

	# If ability ends turn, complete the action
	if ability.ends_turn:
		_on_action_completed(user)
	else:
		# Return to waiting for input if ability doesn't end turn (Shadowstep)
		set_turn_state(TurnState.WAITING_FOR_INPUT)

	return result.get("success", false)

func select_ability_target(target: Unit) -> bool:
	## Called when player clicks a target while in targeting mode
	print("[CombatManager] select_ability_target called for %s" % (target.unit_name if target else "null"))
	print("[CombatManager] Current state: %s, pending ability: %s, valid targets: %d" % [
		TurnState.keys()[_turn_state], _pending_ability_id, _valid_targets.size()
	])

	if _turn_state != TurnState.TARGETING:
		print("[CombatManager] FAILED: Not in TARGETING state")
		return false

	if _pending_ability_id.is_empty():
		print("[CombatManager] FAILED: No pending ability")
		return false

	if not target in _valid_targets:
		print("[CombatManager] FAILED: Target not in valid_targets list")
		for vt in _valid_targets:
			print("[CombatManager]   Valid target: %s" % vt.unit_name)
		return false

	var ability_id = _pending_ability_id
	print("[CombatManager] Executing ability %s on %s" % [ability_id, target.unit_name])

	# Execute the ability on the target FIRST
	var success = execute_ability(_current_turn_unit, ability_id, target)

	# Only clear targeting state if execution succeeded
	if success:
		_pending_ability_id = ""
		_pending_ability = null
		_valid_targets.clear()
	else:
		print("[CombatManager] Ability execution failed, keeping targeting state")

	return success

func is_targeting_ability() -> bool:
	## Check if we're in ability targeting mode
	return _turn_state == TurnState.TARGETING

func get_pending_ability_id() -> String:
	## Get the ability being targeted
	return _pending_ability_id

func get_valid_targets() -> Array[Unit]:
	## Get valid targets for current ability
	return _valid_targets

func _get_valid_targets_for_ability(ability: Resource) -> Array[Unit]:
	## Get valid targets based on ability's target type
	var targets: Array[Unit] = []

	match ability.target_type:
		Ability.TargetType.NONE:
			pass
		Ability.TargetType.ENEMY_ADJACENT:
			targets = get_adjacent_enemies(_current_turn_unit)
		Ability.TargetType.ENEMY_RANGE:
			# Task 2.7: Use LoS check for ranged targets if unit has ranged weapon
			if _current_turn_unit.is_ranged_weapon:
				targets = get_enemies_in_range_with_los(_current_turn_unit, ability.ability_range)
			else:
				targets = get_enemies_in_range(_current_turn_unit, ability.ability_range)
		Ability.TargetType.ALLY:
			targets = get_all_friendly_units(_current_turn_unit)
		Ability.TargetType.ALLY_RANGE:
			# Task 2.6: Get allies within range, excluding self if specified
			targets = get_allies_in_range(_current_turn_unit, ability.ability_range, ability.exclude_self)
		_:
			pass

	return targets
