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

# ===== STATE =====
var selected_unit: Unit = null
var _moving_unit: Unit = null

# ===== TURN STATE =====
var _turn_state: TurnState = TurnState.INACTIVE
var _current_turn_unit: Unit = null
var _turn_manager: TurnManager = null

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[CombatManager] Initialized")

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
	if _turn_state != TurnState.WAITING_FOR_INPUT:
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
