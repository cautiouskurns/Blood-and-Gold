## TurnManager - Manages combat turn order and sequencing
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.8-turn-system-framework.md
class_name TurnManager
extends Node

# ===== SIGNALS =====
signal battle_started(units: Array[Unit])
signal turn_started(unit: Unit)
signal turn_ended(unit: Unit)
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal battle_won(gold_earned: int)
signal battle_lost()

# ===== CONSTANTS =====
const D20_MIN: int = 1
const D20_MAX: int = 20
const ENEMY_TURN_DELAY: float = 0.3
const VICTORY_GOLD_REWARD: int = 100  # Placeholder reward (Task 1.9)

# ===== STATE =====
var _turn_order: Array[Unit] = []
var _current_turn_index: int = 0
var _current_round: int = 0
var _is_battle_active: bool = false

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[TurnManager] Ready")

# ===== PUBLIC API =====
func start_battle(units: Array[Unit]) -> void:
	## Initialize turn order and start combat
	if units.is_empty():
		push_error("[TurnManager] Cannot start battle with no units")
		return

	_is_battle_active = true
	_current_round = 1
	_roll_initiative(units)

	print("[TurnManager] Battle started - %d units" % _turn_order.size())
	_print_initiative_order()

	battle_started.emit(_turn_order.duplicate())
	round_started.emit(_current_round)

	# Start first turn
	_current_turn_index = 0
	_start_current_turn()

func end_current_turn() -> void:
	## End the current unit's turn and advance to next
	if not _is_battle_active:
		return

	var current_unit = get_current_unit()
	if current_unit:
		print("[TurnManager] Turn ended: %s" % current_unit.unit_name)
		turn_ended.emit(current_unit)

	_advance_to_next_turn()

func remove_unit(unit: Unit) -> void:
	## Remove a unit from turn order (death)
	var index = _turn_order.find(unit)
	if index == -1:
		return

	_turn_order.remove_at(index)
	print("[TurnManager] Removed from turn order: %s" % unit.unit_name)

	# Check for battle end before adjusting turn index (Task 1.9)
	if _check_battle_end():
		return  # Battle ended, don't continue turn processing

	# Adjust current index if needed
	if index < _current_turn_index:
		_current_turn_index -= 1
	elif index == _current_turn_index:
		# Current unit died, don't increment index (next unit will be at same index)
		_current_turn_index = mini(_current_turn_index, _turn_order.size() - 1)
		# If battle still active, start next turn
		if _is_battle_active and not _turn_order.is_empty():
			_start_current_turn()

func end_battle() -> void:
	## End combat completely
	_is_battle_active = false
	round_ended.emit(_current_round)
	print("[TurnManager] Battle ended after %d rounds" % _current_round)

func get_current_unit() -> Unit:
	## Get the unit whose turn it currently is
	if _turn_order.is_empty() or _current_turn_index >= _turn_order.size():
		return null
	return _turn_order[_current_turn_index]

func get_turn_order() -> Array[Unit]:
	## Get the current turn order
	return _turn_order.duplicate()

func is_battle_active() -> bool:
	return _is_battle_active

func get_current_round() -> int:
	return _current_round

# ===== INTERNAL METHODS =====
func _roll_initiative(units: Array[Unit]) -> void:
	## Roll initiative for all units and sort by result
	var initiative_rolls: Array[Dictionary] = []

	for unit in units:
		if not is_instance_valid(unit) or not unit.is_alive():
			continue

		# Use unit's DEX modifier from stats system (Task 2.1)
		var dex_mod = unit.get_dex_mod()
		var roll = randi_range(D20_MIN, D20_MAX)
		var total = roll + dex_mod

		initiative_rolls.append({
			"unit": unit,
			"roll": roll,
			"modifier": dex_mod,
			"total": total
		})

		print("[TurnManager] %s rolled %d + %d (DEX) = %d" % [
			unit.unit_name, roll, dex_mod, total
		])

	# Sort by total (descending), with friendly units winning ties
	initiative_rolls.sort_custom(_compare_initiative)

	# Extract sorted units
	_turn_order.clear()
	for data in initiative_rolls:
		_turn_order.append(data["unit"])

func _compare_initiative(a: Dictionary, b: Dictionary) -> bool:
	## Compare initiative rolls (higher goes first, friendly wins ties)
	if a["total"] != b["total"]:
		return a["total"] > b["total"]

	# Tie-breaker: friendly units go before enemies
	var a_friendly = a["unit"].is_friendly()
	var b_friendly = b["unit"].is_friendly()
	if a_friendly != b_friendly:
		return a_friendly  # true if a is friendly, false if b is friendly

	# Still tied: random (use unit name as stable tie-breaker)
	return a["unit"].unit_name < b["unit"].unit_name

func _advance_to_next_turn() -> void:
	## Move to the next unit in turn order
	_current_turn_index += 1

	# Check if round is complete
	if _current_turn_index >= _turn_order.size():
		_current_turn_index = 0
		round_ended.emit(_current_round)
		_current_round += 1
		round_started.emit(_current_round)
		print("[TurnManager] === Round %d ===" % _current_round)

	_start_current_turn()

func _start_current_turn() -> void:
	## Start the current unit's turn
	var unit = get_current_unit()
	if not unit:
		return

	print("[TurnManager] Turn %d: %s" % [_current_turn_index + 1, unit.unit_name])
	turn_started.emit(unit)

	# If enemy, auto-skip turn (placeholder for Phase 2 AI)
	if unit.is_enemy:
		print("[TurnManager] Enemy turn skipped (AI placeholder)")
		# Small delay before ending enemy turn for visual feedback
		await get_tree().create_timer(ENEMY_TURN_DELAY).timeout
		end_current_turn()

func _print_initiative_order() -> void:
	## Debug print the initiative order
	var order_str = "Initiative order: "
	for i in range(_turn_order.size()):
		if i > 0:
			order_str += ", "
		order_str += _turn_order[i].unit_name
	print("[TurnManager] %s" % order_str)

# ===== BATTLE END CHECK (Task 1.9) =====
func _check_battle_end() -> bool:
	## Check if victory or defeat conditions are met
	## Returns true if battle ended
	if not _is_battle_active:
		return false

	var party_alive = _count_living_party()
	var enemies_alive = _count_living_enemies()

	print("[TurnManager] Battle check - Party: %d, Enemies: %d" % [party_alive, enemies_alive])

	# Check defeat first (if party is wiped, defeat even if enemies also died)
	if party_alive == 0:
		_trigger_defeat()
		return true

	# Check victory
	if enemies_alive == 0:
		_trigger_victory()
		return true

	return false

func _count_living_party() -> int:
	## Count living party members (not soldiers - soldiers dying doesn't cause defeat)
	var count = 0
	for unit in _turn_order:
		if is_instance_valid(unit) and unit.is_friendly() and not unit.is_soldier:
			count += 1
	return count

func _count_living_enemies() -> int:
	## Count living enemy units
	var count = 0
	for unit in _turn_order:
		if is_instance_valid(unit) and unit.is_enemy:
			count += 1
	return count

func _trigger_victory() -> void:
	## Handle victory condition
	print("[TurnManager] === VICTORY! ===")
	_is_battle_active = false
	battle_won.emit(VICTORY_GOLD_REWARD)

func _trigger_defeat() -> void:
	## Handle defeat condition
	print("[TurnManager] === DEFEAT ===")
	_is_battle_active = false
	battle_lost.emit()
