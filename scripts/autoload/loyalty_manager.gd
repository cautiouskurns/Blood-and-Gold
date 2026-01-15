## LoyaltyManager - Tracks companion loyalty values and stat modifiers
## Part of: Blood & Gold Prototype
## Task 3.9: Loyalty System Implementation
## Spec: docs/features/3.9-loyalty-system-implementation.md
extends Node

# ===== SIGNALS =====
signal loyalty_changed(companion_id: String, new_value: int, delta: int)
signal loyalty_threshold_crossed(companion_id: String, old_tier: String, new_tier: String)
signal companion_left(companion_id: String, loyalty_at_departure: int)

# ===== CONSTANTS =====
const DEFAULT_LOYALTY: int = 50
const MIN_LOYALTY: int = 0
const MAX_LOYALTY: int = 100

# Loyalty tier thresholds (minimum value for each tier)
const TIER_HOSTILE: int = 0      # 0-9
const TIER_DISLOYAL: int = 10    # 10-29
const TIER_NEUTRAL: int = 30     # 30-49
const TIER_LOYAL: int = 50       # 50-69
const TIER_DEVOTED: int = 70     # 70-89
const TIER_BONDED: int = 90      # 90-100

# Threshold where companion considers leaving
const DEPARTURE_WARNING_THRESHOLD: int = 10
# Threshold where companion immediately leaves
const DEPARTURE_IMMEDIATE_THRESHOLD: int = 0

# Stat modifiers per tier (multiplied with base stats)
const STAT_MODIFIERS: Dictionary = {
	"hostile": -0.20,   # -20% to combat stats
	"disloyal": -0.10,  # -10% to combat stats
	"neutral": 0.0,     # No modifier
	"loyal": 0.0,       # No modifier
	"devoted": 0.10,    # +10% to combat stats
	"bonded": 0.20,     # +20% to combat stats
}

# Tier colors for UI display
const TIER_COLORS: Dictionary = {
	"hostile": Color("#c0392b"),   # Dark red
	"disloyal": Color("#e74c3c"),  # Red
	"neutral": Color("#f39c12"),   # Orange/Yellow
	"loyal": Color("#27ae60"),     # Green
	"devoted": Color("#2980b9"),   # Blue
	"bonded": Color("#9b59b6"),    # Purple (legendary)
}

# ===== COMPANION DATA =====
# Companion IDs match Unit.UnitType names (lowercase)
var _loyalty: Dictionary = {
	"thorne": DEFAULT_LOYALTY,
	"lyra": DEFAULT_LOYALTY,
	"matthias": DEFAULT_LOYALTY,
}

# Companions who have left the party due to low loyalty
var _companions_left: Array[String] = []

# Reaction quotes for loyalty changes
const REACTION_QUOTES: Dictionary = {
	"thorne": {
		"positive": "Your leadership grows stronger.",
		"negative": "I question this path we walk.",
		"neutral": "Noted.",
		"hostile": "I won't stand for this much longer...",
		"devoted": "I'd follow you into the abyss itself!",
	},
	"lyra": {
		"positive": "Faith guides your hand well.",
		"negative": "The Light tests us all...",
		"neutral": "As you say.",
		"hostile": "My faith demands better than this...",
		"devoted": "The Light shines through you, Captain.",
	},
	"matthias": {
		"positive": "Now that's the captain I follow!",
		"negative": "I expected better from you.",
		"neutral": "If you say so.",
		"hostile": "I'm starting to regret signing on...",
		"devoted": "Best decision I ever made, joining up!",
	}
}

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[LoyaltyManager] Initialized with %d companions" % _loyalty.size())

# ===== PUBLIC API - LOYALTY GETTERS =====
func get_loyalty(companion_id: String) -> int:
	## Get current loyalty value for a companion (0-100)
	return _loyalty.get(companion_id.to_lower(), DEFAULT_LOYALTY)

func get_loyalty_tier(companion_id: String) -> String:
	## Get the current loyalty tier name for a companion
	var loyalty = get_loyalty(companion_id)
	return _get_tier_for_value(loyalty)

func get_loyalty_status(companion_id: String) -> String:
	## Alias for get_loyalty_tier for backward compatibility
	return get_loyalty_tier(companion_id).capitalize()

func get_loyalty_color(companion_id: String) -> Color:
	## Get color for loyalty display based on tier
	var tier = get_loyalty_tier(companion_id)
	return TIER_COLORS.get(tier, Color.WHITE)

func get_all_companions() -> Array[String]:
	## Get list of all companion IDs (including those who left)
	var result: Array[String] = []
	for key in _loyalty.keys():
		result.append(key)
	return result

func get_active_companions() -> Array[String]:
	## Get list of companions still in the party
	var result: Array[String] = []
	for key in _loyalty.keys():
		if not has_companion_left(key):
			result.append(key)
	return result

func has_companion_left(companion_id: String) -> bool:
	## Check if a companion has left the party
	return companion_id.to_lower() in _companions_left

func get_departed_companions() -> Array[String]:
	## Get list of companions who have left
	return _companions_left.duplicate()

# ===== PUBLIC API - LOYALTY MODIFIERS =====
func set_loyalty(companion_id: String, value: int) -> void:
	## Set loyalty to an absolute value (clamped to 0-100)
	var id = companion_id.to_lower()

	# Can't modify loyalty for companions who left
	if has_companion_left(id):
		push_warning("[LoyaltyManager] Cannot modify loyalty for departed companion: %s" % id)
		return

	var old_value = _loyalty.get(id, DEFAULT_LOYALTY)
	var new_value = clampi(value, MIN_LOYALTY, MAX_LOYALTY)
	_loyalty[id] = new_value

	var delta = new_value - old_value
	loyalty_changed.emit(id, new_value, delta)
	_check_tier_change(id, old_value, new_value)
	_check_departure(id, new_value)

	print("[LoyaltyManager] %s loyalty set to %d" % [id, new_value])

func modify_loyalty(companion_id: String, delta: int) -> void:
	## Modify loyalty by a delta amount
	var id = companion_id.to_lower()

	# Can't modify loyalty for companions who left
	if has_companion_left(id):
		push_warning("[LoyaltyManager] Cannot modify loyalty for departed companion: %s" % id)
		return

	var old_value = _loyalty.get(id, DEFAULT_LOYALTY)
	var new_value = clampi(old_value + delta, MIN_LOYALTY, MAX_LOYALTY)
	_loyalty[id] = new_value

	loyalty_changed.emit(id, new_value, delta)
	_check_tier_change(id, old_value, new_value)
	_check_departure(id, new_value)

	var sign_str = "+" if delta > 0 else ""
	print("[LoyaltyManager] %s loyalty %s%d (now %d)" % [id, sign_str, delta, new_value])

# ===== PUBLIC API - STAT MODIFIERS =====
func get_stat_modifier(companion_id: String) -> float:
	## Get the stat modifier for a companion based on their loyalty tier
	## Returns a value like -0.20, 0.0, or +0.20
	var tier = get_loyalty_tier(companion_id)
	return STAT_MODIFIERS.get(tier, 0.0)

func get_stat_modifier_percent(companion_id: String) -> int:
	## Get the stat modifier as a percentage (-20, 0, +20, etc.)
	return int(get_stat_modifier(companion_id) * 100)

func apply_stat_modifier(companion_id: String, base_value: int) -> int:
	## Apply loyalty stat modifier to a base value
	## Example: apply_stat_modifier("thorne", 10) returns 12 if Bonded (+20%)
	var modifier = get_stat_modifier(companion_id)
	var modified = base_value * (1.0 + modifier)
	return roundi(modified)

func apply_stat_modifier_float(companion_id: String, base_value: float) -> float:
	## Apply loyalty stat modifier to a float base value
	var modifier = get_stat_modifier(companion_id)
	return base_value * (1.0 + modifier)

# ===== PUBLIC API - REACTION QUOTES =====
func get_reaction_quote(companion_id: String, delta: int) -> String:
	## Get a reaction quote based on loyalty change
	var id = companion_id.to_lower()
	var quotes = REACTION_QUOTES.get(id, {})
	var tier = get_loyalty_tier(id)

	# Special quotes for extreme tiers
	if tier == "hostile" and delta < 0:
		return quotes.get("hostile", quotes.get("negative", "..."))
	elif tier == "devoted" or tier == "bonded":
		if delta > 0:
			return quotes.get("devoted", quotes.get("positive", "..."))

	# Standard reaction quotes
	if delta > 0:
		return quotes.get("positive", "...")
	elif delta < 0:
		return quotes.get("negative", "...")
	else:
		return quotes.get("neutral", "...")

func get_tier_description(tier: String) -> String:
	## Get a description of what a loyalty tier means
	match tier.to_lower():
		"hostile":
			return "On the verge of leaving. Combat effectiveness severely reduced."
		"disloyal":
			return "Unhappy with leadership. Combat effectiveness reduced."
		"neutral":
			return "Neither loyal nor disloyal. Standard performance."
		"loyal":
			return "Content with their place. Standard performance."
		"devoted":
			return "Deeply committed to the company. Enhanced combat effectiveness."
		"bonded":
			return "Unshakeable loyalty. Maximum combat effectiveness."
		_:
			return "Unknown tier."

# ===== INTERNAL METHODS =====
func _get_tier_for_value(loyalty: int) -> String:
	## Determine which tier a loyalty value falls into
	if loyalty >= TIER_BONDED:
		return "bonded"
	elif loyalty >= TIER_DEVOTED:
		return "devoted"
	elif loyalty >= TIER_LOYAL:
		return "loyal"
	elif loyalty >= TIER_NEUTRAL:
		return "neutral"
	elif loyalty >= TIER_DISLOYAL:
		return "disloyal"
	else:
		return "hostile"

func _check_tier_change(companion_id: String, old_value: int, new_value: int) -> void:
	## Check if loyalty tier changed and emit signal
	var old_tier = _get_tier_for_value(old_value)
	var new_tier = _get_tier_for_value(new_value)

	if old_tier != new_tier:
		loyalty_threshold_crossed.emit(companion_id, old_tier, new_tier)
		print("[LoyaltyManager] %s tier changed: %s -> %s" % [companion_id, old_tier, new_tier])

func _check_departure(companion_id: String, loyalty: int) -> void:
	## Check if companion should leave due to low loyalty
	if loyalty <= DEPARTURE_IMMEDIATE_THRESHOLD:
		_companion_leaves(companion_id, loyalty)

func _companion_leaves(companion_id: String, loyalty: int) -> void:
	## Handle a companion leaving the party
	if has_companion_left(companion_id):
		return

	_companions_left.append(companion_id.to_lower())
	companion_left.emit(companion_id, loyalty)
	print("[LoyaltyManager] %s has LEFT the company! (loyalty: %d)" % [companion_id, loyalty])

# ===== TIER INFORMATION =====
func get_tier_threshold(tier: String) -> int:
	## Get the minimum loyalty value for a tier
	match tier.to_lower():
		"hostile": return TIER_HOSTILE
		"disloyal": return TIER_DISLOYAL
		"neutral": return TIER_NEUTRAL
		"loyal": return TIER_LOYAL
		"devoted": return TIER_DEVOTED
		"bonded": return TIER_BONDED
		_: return 0

func get_next_tier(current_tier: String) -> String:
	## Get the tier above the current one
	match current_tier.to_lower():
		"hostile": return "disloyal"
		"disloyal": return "neutral"
		"neutral": return "loyal"
		"loyal": return "devoted"
		"devoted": return "bonded"
		"bonded": return "bonded"  # Already max
		_: return "neutral"

func get_previous_tier(current_tier: String) -> String:
	## Get the tier below the current one
	match current_tier.to_lower():
		"bonded": return "devoted"
		"devoted": return "loyal"
		"loyal": return "neutral"
		"neutral": return "disloyal"
		"disloyal": return "hostile"
		"hostile": return "hostile"  # Already min
		_: return "neutral"

func get_progress_to_next_tier(companion_id: String) -> float:
	## Get progress percentage toward next tier (0.0 to 1.0)
	var loyalty = get_loyalty(companion_id)
	var current_tier = get_loyalty_tier(companion_id)
	var next_tier = get_next_tier(current_tier)

	if current_tier == next_tier:
		return 1.0  # Already at max tier

	var current_min = get_tier_threshold(current_tier)
	var next_min = get_tier_threshold(next_tier)
	var range_size = next_min - current_min

	if range_size <= 0:
		return 1.0

	return float(loyalty - current_min) / float(range_size)

# ===== SAVE/LOAD =====
func get_save_data() -> Dictionary:
	## Get data for saving
	return {
		"loyalty": _loyalty.duplicate(),
		"companions_left": _companions_left.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	## Load data from save
	# Load loyalty values
	_loyalty.clear()
	var loyalty_data = data.get("loyalty", {})
	for key in loyalty_data.keys():
		_loyalty[key] = loyalty_data[key]

	# Load departed companions
	_companions_left.clear()
	var departed = data.get("companions_left", [])
	for id in departed:
		_companions_left.append(id)

	print("[LoyaltyManager] Loaded save data (%d companions, %d departed)" % [_loyalty.size(), _companions_left.size()])

func reset_to_default() -> void:
	## Reset all loyalty to default values
	_loyalty = {
		"thorne": DEFAULT_LOYALTY,
		"lyra": DEFAULT_LOYALTY,
		"matthias": DEFAULT_LOYALTY,
	}
	_companions_left.clear()
	print("[LoyaltyManager] Reset to default values")
