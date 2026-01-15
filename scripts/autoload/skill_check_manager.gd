## SkillCheckManager - Handles D20-style skill checks
## Part of: Blood & Gold Prototype
## Task 3.5: Border Dispute - First skill check implementation
extends Node

# ===== SIGNALS =====
signal check_started(stat: String, dc: int, bonus: int)
signal check_completed(stat: String, dc: int, roll: int, total: int, success: bool)

# ===== CONSTANTS =====
const DICE_SIDES: int = 20
const CRITICAL_SUCCESS: int = 20  # Natural 20 always succeeds
const CRITICAL_FAILURE: int = 1   # Natural 1 always fails

# ===== STAT BONUSES =====
# Placeholder stat bonuses - in full implementation, these would come from player character
var _stat_bonuses: Dictionary = {
	"STR": 2,  # Strength
	"DEX": 1,  # Dexterity
	"CON": 1,  # Constitution
	"INT": 0,  # Intelligence
	"WIS": 0,  # Wisdom
	"CHA": 2,  # Charisma - default player is charismatic leader
}

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[SkillCheckManager] Initialized")

# ===== PUBLIC API =====
func perform_check(stat: String, dc: int) -> Dictionary:
	## Perform a skill check and return the result
	## Returns: {roll, bonus, total, dc, success, is_critical_success, is_critical_failure}

	var bonus = get_stat_bonus(stat)
	var roll = _roll_d20()
	var total = roll + bonus

	# Check for criticals
	var is_crit_success = roll == CRITICAL_SUCCESS
	var is_crit_failure = roll == CRITICAL_FAILURE

	# Determine success (crits override normal calculation)
	var success: bool
	if is_crit_success:
		success = true
	elif is_crit_failure:
		success = false
	else:
		success = total >= dc

	var result = {
		"stat": stat,
		"roll": roll,
		"bonus": bonus,
		"total": total,
		"dc": dc,
		"success": success,
		"is_critical_success": is_crit_success,
		"is_critical_failure": is_crit_failure,
	}

	check_started.emit(stat, dc, bonus)
	check_completed.emit(stat, dc, roll, total, success)

	print("[SkillCheckManager] %s check: d20(%d) + %d = %d vs DC %d -> %s%s" % [
		stat, roll, bonus, total, dc,
		"SUCCESS" if success else "FAILURE",
		" (CRITICAL!)" if is_crit_success or is_crit_failure else ""
	])

	return result

func get_stat_bonus(stat: String) -> int:
	## Get the bonus for a given stat
	return _stat_bonuses.get(stat.to_upper(), 0)

func set_stat_bonus(stat: String, bonus: int) -> void:
	## Set the bonus for a stat (for character progression)
	_stat_bonuses[stat.to_upper()] = bonus
	print("[SkillCheckManager] %s bonus set to %d" % [stat, bonus])

func get_success_chance(stat: String, dc: int) -> float:
	## Calculate the probability of success (0.0 to 1.0)
	var bonus = get_stat_bonus(stat)
	var needed_roll = dc - bonus

	# Account for critical rules
	if needed_roll <= 1:
		# Only critical failure (1) can fail
		return 0.95  # 19/20 chance
	elif needed_roll >= 20:
		# Only critical success (20) can succeed
		return 0.05  # 1/20 chance
	else:
		# Normal calculation: (21 - needed_roll) / 20
		return (21.0 - needed_roll) / 20.0

func get_difficulty_description(dc: int) -> String:
	## Get a text description for a DC
	if dc <= 5:
		return "Trivial"
	elif dc <= 10:
		return "Easy"
	elif dc <= 15:
		return "Medium"
	elif dc <= 20:
		return "Hard"
	elif dc <= 25:
		return "Very Hard"
	else:
		return "Nearly Impossible"

# ===== INTERNAL METHODS =====
func _roll_d20() -> int:
	## Roll a d20 (1-20)
	return randi_range(1, DICE_SIDES)

# ===== SAVE/LOAD =====
func get_save_data() -> Dictionary:
	return _stat_bonuses.duplicate()

func load_save_data(data: Dictionary) -> void:
	for key in data.keys():
		_stat_bonuses[key] = data[key]
	print("[SkillCheckManager] Loaded save data")
