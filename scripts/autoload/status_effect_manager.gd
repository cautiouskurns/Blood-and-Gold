## StatusEffectManager - Manages status effects on all units
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.3-implement-player-abilities.md
extends Node

# ===== EFFECT TYPES =====
const EFFECT_STUNNED = "STUNNED"
const EFFECT_ATTACK_BUFF = "ATTACK_BUFF"
const EFFECT_TAUNTED = "TAUNTED"           # Task 2.4: Forces enemy to attack taunt source
const EFFECT_LAST_STAND = "LAST_STAND"     # Task 2.4: Indicator that Last Stand is active
const EFFECT_BLESSED = "BLESSED"           # Task 2.6: +2 to all d20 rolls (Matthias's Bless)

# ===== SIGNALS =====
signal effect_applied(unit: Unit, effect_type: String, duration: int, value: int)
signal effect_removed(unit: Unit, effect_type: String)
signal effect_tick(unit: Unit, effect_type: String, remaining: int)

# ===== STATE =====
# Dictionary of unit_id -> Array of active effects
# Each effect: {type: String, duration: int, value: int}
var _effects: Dictionary = {}

# ===== LIFECYCLE =====
func _ready() -> void:
	# Connect to CombatManager for turn events
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_ended.connect(_on_battle_ended)
	print("[StatusEffectManager] Ready")

# ===== PUBLIC API =====
func apply_effect(target: Unit, effect_type: String, duration: int, value: int = 0) -> void:
	## Apply a status effect to a unit
	if not is_instance_valid(target):
		return

	var unit_id = target.get_instance_id()

	if not _effects.has(unit_id):
		_effects[unit_id] = []

	# Check if effect already exists (refresh duration)
	for effect in _effects[unit_id]:
		if effect.type == effect_type:
			effect.duration = max(effect.duration, duration)  # Refresh to longer duration
			effect.value = value  # Update value
			print("[StatusEffect] Refreshed %s on %s (%d turns)" % [effect_type, target.unit_name, duration])
			effect_applied.emit(target, effect_type, duration, value)
			return

	# Add new effect
	_effects[unit_id].append({
		"type": effect_type,
		"duration": duration,
		"value": value,
	})

	print("[StatusEffect] Applied %s to %s for %d turns (value: %d)" % [
		effect_type, target.unit_name, duration, value
	])
	effect_applied.emit(target, effect_type, duration, value)

func has_effect(unit: Unit, effect_type: String) -> bool:
	## Check if unit has a specific effect
	if not is_instance_valid(unit):
		return false

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return false

	for effect in _effects[unit_id]:
		if effect.type == effect_type:
			return true
	return false

func get_effect_value(unit: Unit, effect_type: String) -> int:
	## Get the value of an effect (e.g., +2 attack from ATTACK_BUFF)
	if not is_instance_valid(unit):
		return 0

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return 0

	for effect in _effects[unit_id]:
		if effect.type == effect_type:
			return effect.value
	return 0

func remove_effect(unit: Unit, effect_type: String) -> void:
	## Remove a specific effect from a unit
	if not is_instance_valid(unit):
		return

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return

	for i in range(_effects[unit_id].size() - 1, -1, -1):
		if _effects[unit_id][i].type == effect_type:
			_effects[unit_id].remove_at(i)
			effect_removed.emit(unit, effect_type)
			print("[StatusEffect] Removed %s from %s" % [effect_type, unit.unit_name])
			return

func clear_all_effects() -> void:
	## Clear all effects (battle end)
	_effects.clear()
	print("[StatusEffectManager] All effects cleared")

func get_unit_effects(unit: Unit) -> Array:
	## Get all effects on a unit
	if not is_instance_valid(unit):
		return []

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return []

	return _effects[unit_id].duplicate()

func get_roll_modifier(unit: Unit) -> int:
	## Get total modifier to all d20 rolls from status effects (Task 2.6)
	## Includes ATTACK_BUFF and BLESSED
	var modifier: int = 0

	# Add attack buff
	modifier += get_effect_value(unit, EFFECT_ATTACK_BUFF)

	# Add blessed buff
	modifier += get_effect_value(unit, EFFECT_BLESSED)

	return modifier

func get_taunt_source(unit: Unit) -> Unit:
	## Get the unit that taunted this unit (Task 2.4)
	## Returns null if unit is not taunted
	if not is_instance_valid(unit):
		return null

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return null

	for effect in _effects[unit_id]:
		if effect.type == EFFECT_TAUNTED:
			# The "value" stores the taunt source's instance_id
			var source_id = effect.value
			# We need to find the unit with this instance ID
			var units = get_tree().get_nodes_in_group("units")
			for u in units:
				if u.get_instance_id() == source_id:
					return u
	return null

func apply_taunt(target: Unit, source: Unit, duration: int) -> void:
	## Apply taunt effect to target, storing source unit reference (Task 2.4)
	if not is_instance_valid(target) or not is_instance_valid(source):
		return

	# Use source's instance_id as the value
	apply_effect(target, EFFECT_TAUNTED, duration, source.get_instance_id())
	print("[StatusEffect] %s is taunted by %s for %d turns" % [
		target.unit_name, source.unit_name, duration
	])

# ===== SIGNAL HANDLERS =====
func _on_turn_ended(unit: Unit) -> void:
	## Tick effects at end of unit's turn
	if not is_instance_valid(unit):
		return

	var unit_id = unit.get_instance_id()
	if not _effects.has(unit_id):
		return

	# Tick down durations and remove expired
	var effects_to_remove: Array[int] = []

	for i in range(_effects[unit_id].size()):
		var effect = _effects[unit_id][i]
		effect.duration -= 1

		if effect.duration <= 0:
			effects_to_remove.append(i)
			print("[StatusEffect] %s expired on %s" % [effect.type, unit.unit_name])
		else:
			effect_tick.emit(unit, effect.type, effect.duration)

	# Remove expired effects (reverse order to maintain indices)
	for i in range(effects_to_remove.size() - 1, -1, -1):
		var effect = _effects[unit_id][effects_to_remove[i]]
		effect_removed.emit(unit, effect.type)
		_effects[unit_id].remove_at(effects_to_remove[i])

	# Clean up empty arrays
	if _effects[unit_id].is_empty():
		_effects.erase(unit_id)

func _on_battle_ended() -> void:
	## Clear all effects when battle ends
	clear_all_effects()
