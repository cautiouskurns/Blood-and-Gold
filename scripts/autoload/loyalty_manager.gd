## LoyaltyManager - Tracks companion loyalty values
## Part of: Blood & Gold Prototype
## Task 3.5: Border Dispute (stub for Task 3.9 Loyalty System)
extends Node

# ===== SIGNALS =====
signal loyalty_changed(companion_id: String, new_value: int, delta: int)
signal loyalty_threshold_crossed(companion_id: String, threshold: String, is_above: bool)

# ===== CONSTANTS =====
const DEFAULT_LOYALTY: int = 50
const MIN_LOYALTY: int = -100
const MAX_LOYALTY: int = 100

# Threshold names
const THRESHOLD_HOSTILE: int = -50
const THRESHOLD_COLD: int = -25
const THRESHOLD_NEUTRAL: int = 0
const THRESHOLD_WARM: int = 25
const THRESHOLD_DEVOTED: int = 50

# ===== COMPANION DATA =====
# Companion IDs match Unit.UnitType names (lowercase)
var _loyalty: Dictionary = {
	"thorne": DEFAULT_LOYALTY,
	"lyra": DEFAULT_LOYALTY,
	"matthias": DEFAULT_LOYALTY,
}

# Reaction quotes for loyalty changes
const REACTION_QUOTES: Dictionary = {
	"thorne": {
		"positive": "Your leadership grows stronger.",
		"negative": "I question this path we walk.",
		"neutral": "Noted."
	},
	"lyra": {
		"positive": "Faith guides your hand well.",
		"negative": "The Light tests us all...",
		"neutral": "As you say."
	},
	"matthias": {
		"positive": "Now that's the captain I follow!",
		"negative": "I expected better from you.",
		"neutral": "If you say so."
	}
}

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[LoyaltyManager] Initialized with %d companions" % _loyalty.size())

# ===== PUBLIC API =====
func get_loyalty(companion_id: String) -> int:
	## Get current loyalty value for a companion
	return _loyalty.get(companion_id.to_lower(), DEFAULT_LOYALTY)

func set_loyalty(companion_id: String, value: int) -> void:
	## Set loyalty to an absolute value (clamped)
	var id = companion_id.to_lower()
	var old_value = _loyalty.get(id, DEFAULT_LOYALTY)
	var new_value = clampi(value, MIN_LOYALTY, MAX_LOYALTY)
	_loyalty[id] = new_value

	var delta = new_value - old_value
	loyalty_changed.emit(id, new_value, delta)
	_check_thresholds(id, old_value, new_value)

	print("[LoyaltyManager] %s loyalty set to %d" % [id, new_value])

func modify_loyalty(companion_id: String, delta: int) -> void:
	## Modify loyalty by a delta amount
	var id = companion_id.to_lower()
	var old_value = _loyalty.get(id, DEFAULT_LOYALTY)
	var new_value = clampi(old_value + delta, MIN_LOYALTY, MAX_LOYALTY)
	_loyalty[id] = new_value

	loyalty_changed.emit(id, new_value, delta)
	_check_thresholds(id, old_value, new_value)

	var sign_str = "+" if delta > 0 else ""
	print("[LoyaltyManager] %s loyalty %s%d (now %d)" % [id, sign_str, delta, new_value])

func get_loyalty_status(companion_id: String) -> String:
	## Get a text status for loyalty level
	var loyalty = get_loyalty(companion_id)
	if loyalty <= THRESHOLD_HOSTILE:
		return "Hostile"
	elif loyalty <= THRESHOLD_COLD:
		return "Cold"
	elif loyalty < THRESHOLD_WARM:
		return "Neutral"
	elif loyalty < THRESHOLD_DEVOTED:
		return "Warm"
	else:
		return "Devoted"

func get_loyalty_color(companion_id: String) -> Color:
	## Get color for loyalty display
	var loyalty = get_loyalty(companion_id)
	if loyalty <= THRESHOLD_HOSTILE:
		return Color("#e74c3c")  # Red
	elif loyalty <= THRESHOLD_COLD:
		return Color("#e67e22")  # Orange
	elif loyalty < THRESHOLD_WARM:
		return Color("#f1c40f")  # Yellow
	elif loyalty < THRESHOLD_DEVOTED:
		return Color("#2ecc71")  # Green
	else:
		return Color("#3498db")  # Blue

func get_reaction_quote(companion_id: String, delta: int) -> String:
	## Get a reaction quote based on loyalty change
	var id = companion_id.to_lower()
	var quotes = REACTION_QUOTES.get(id, {})

	if delta > 0:
		return quotes.get("positive", "...")
	elif delta < 0:
		return quotes.get("negative", "...")
	else:
		return quotes.get("neutral", "...")

func get_all_companions() -> Array[String]:
	## Get list of all companion IDs
	var result: Array[String] = []
	for key in _loyalty.keys():
		result.append(key)
	return result

# ===== INTERNAL METHODS =====
func _check_thresholds(companion_id: String, old_value: int, new_value: int) -> void:
	## Check if any loyalty thresholds were crossed
	var thresholds = [
		{"value": THRESHOLD_HOSTILE, "name": "hostile"},
		{"value": THRESHOLD_COLD, "name": "cold"},
		{"value": THRESHOLD_NEUTRAL, "name": "neutral"},
		{"value": THRESHOLD_WARM, "name": "warm"},
		{"value": THRESHOLD_DEVOTED, "name": "devoted"},
	]

	for threshold in thresholds:
		var crossed_up = old_value < threshold.value and new_value >= threshold.value
		var crossed_down = old_value >= threshold.value and new_value < threshold.value

		if crossed_up:
			loyalty_threshold_crossed.emit(companion_id, threshold.name, true)
		elif crossed_down:
			loyalty_threshold_crossed.emit(companion_id, threshold.name, false)

# ===== SAVE/LOAD =====
func get_save_data() -> Dictionary:
	return _loyalty.duplicate()

func load_save_data(data: Dictionary) -> void:
	_loyalty.clear()
	for key in data.keys():
		_loyalty[key] = data[key]
	print("[LoyaltyManager] Loaded save data")

func reset_to_default() -> void:
	_loyalty = {
		"thorne": DEFAULT_LOYALTY,
		"lyra": DEFAULT_LOYALTY,
		"matthias": DEFAULT_LOYALTY,
	}
	print("[LoyaltyManager] Reset to default values")
