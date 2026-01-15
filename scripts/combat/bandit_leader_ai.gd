## BanditLeaderAI - Specialized AI for Bandit Leader with Rally Bandits ability
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.4-contract-clear-the-ruins.md
## Extends base EnemyAI behavior with Rally Bandits ability tracking
class_name BanditLeaderAI
extends Node

# ===== SIGNALS =====
signal rally_used(leader: Unit, affected_count: int)
signal rally_ready(leader: Unit)

# ===== CONSTANTS =====
const RALLY_COOLDOWN_TURNS: int = 3
const RALLY_RANGE_TILES: int = 5
const RALLY_ATK_BONUS: int = 2
const RALLY_DURATION_TURNS: int = 2
const RALLY_MIN_ALLIES: int = 3  # Minimum allies in range to use Rally

# ===== STATE =====
var _leader: Unit = null
var _rally_cooldown: int = 0
var _is_initialized: bool = false

# ===== LIFECYCLE =====
func initialize(leader: Unit) -> void:
	## Initialize the AI tracker for a specific leader unit
	_leader = leader
	_rally_cooldown = 0  # Rally available immediately at battle start
	_is_initialized = true

	# Connect to turn events to track cooldown
	if not CombatManager.turn_ended.is_connected(_on_turn_ended):
		CombatManager.turn_ended.connect(_on_turn_ended)

	print("[BanditLeaderAI] Initialized for %s" % leader.unit_name)

func _on_turn_ended(unit: Unit) -> void:
	## Track cooldown reduction at end of leader's turn
	if not _is_initialized or not is_instance_valid(_leader):
		return

	if unit == _leader:
		if _rally_cooldown > 0:
			_rally_cooldown -= 1
			print("[BanditLeaderAI] Rally cooldown: %d turns remaining" % _rally_cooldown)

			if _rally_cooldown == 0:
				rally_ready.emit(_leader)
				print("[BanditLeaderAI] Rally Bandits is ready!")

# ===== PUBLIC API =====
func can_use_rally() -> bool:
	## Check if Rally Bandits can be used
	if not _is_initialized or not is_instance_valid(_leader) or not _leader.is_alive():
		return false

	if _rally_cooldown > 0:
		return false

	# Check for enough allies in range
	var allies_in_range = _get_allies_in_rally_range()
	return allies_in_range.size() >= RALLY_MIN_ALLIES

func should_use_rally() -> bool:
	## Determine if the leader should use Rally this turn (AI decision)
	if not can_use_rally():
		return false

	var allies_in_range = _get_allies_in_rally_range()

	# Use Rally if we have enough allies (tactical decision)
	return allies_in_range.size() >= RALLY_MIN_ALLIES

func execute_rally() -> bool:
	## Execute Rally Bandits ability
	## Returns true if rally was used successfully
	if not can_use_rally():
		print("[BanditLeaderAI] Cannot use Rally - on cooldown or not enough allies")
		return false

	var allies = _get_allies_in_rally_range()

	if allies.is_empty():
		print("[BanditLeaderAI] No allies in range for Rally")
		return false

	# Apply buff to all allies in range
	for ally in allies:
		StatusEffectManager.apply_effect(
			ally,
			StatusEffectManager.EFFECT_ATTACK_BUFF,
			RALLY_DURATION_TURNS,
			RALLY_ATK_BONUS
		)
		print("[BanditLeaderAI] Buffed %s with +%d attack for %d turns" % [
			ally.unit_name, RALLY_ATK_BONUS, RALLY_DURATION_TURNS
		])

	# Set cooldown
	_rally_cooldown = RALLY_COOLDOWN_TURNS

	# Emit signal
	rally_used.emit(_leader, allies.size())

	print("[BanditLeaderAI] Rally Bandits! Buffed %d allies. Cooldown: %d turns" % [
		allies.size(), _rally_cooldown
	])

	return true

func get_rally_cooldown() -> int:
	## Get remaining cooldown turns
	return _rally_cooldown

func get_allies_in_range_count() -> int:
	## Get count of allies currently in rally range
	return _get_allies_in_rally_range().size()

# ===== INTERNAL METHODS =====
func _get_allies_in_rally_range() -> Array[Unit]:
	## Get all allied enemy units within rally range
	var allies: Array[Unit] = []

	if not is_instance_valid(_leader):
		return allies

	var leader_pos = _leader.grid_position
	var all_units = _leader.get_tree().get_nodes_in_group("units")

	for node in all_units:
		var unit = node as Unit
		if not unit or not is_instance_valid(unit):
			continue

		# Skip non-enemies (only buff enemy allies)
		if not unit.is_enemy:
			continue

		# Skip the leader itself
		if unit == _leader:
			continue

		# Skip dead units
		if not unit.is_alive():
			continue

		# Check distance
		var distance = _get_tile_distance(leader_pos, unit.grid_position)
		if distance <= RALLY_RANGE_TILES:
			allies.append(unit)

	return allies

func _get_tile_distance(from: Vector2i, to: Vector2i) -> int:
	## Calculate Chebyshev distance (king moves) between two tiles
	return maxi(absi(to.x - from.x), absi(to.y - from.y))

# ===== STATIC HELPER =====
static func execute_leader_turn_with_rally(
	leader: Unit,
	leader_ai: BanditLeaderAI,
	combat_grid: CombatGrid
) -> void:
	## Execute a leader's turn with Rally Bandits consideration
	## Call this instead of EnemyAI.execute_turn for the leader

	if not is_instance_valid(leader) or not leader.is_alive():
		return

	# Check if we should Rally first
	if leader_ai and leader_ai.should_use_rally():
		print("[BanditLeaderAI] Leader using Rally Bandits!")
		leader_ai.execute_rally()

		# Visual feedback delay
		await leader.get_tree().create_timer(0.5).timeout

	# Then execute normal leader behavior (from EnemyAI)
	await EnemyAI.execute_turn(leader, combat_grid)
