@tool
class_name DiceParser
extends RefCounted
## Utility class for parsing and validating dice notation (e.g., "2d6+3").
## Supports standard RPG dice formats: XdY, XdY+Z, XdY-Z
## Spec: docs/tools/data-table-editor-roadmap.md - Feature 2.4

# Regex pattern for dice notation: XdY or XdY+Z or XdY-Z
# Examples: 1d6, 2d8+3, 1d20-1, 3d6
const DICE_PATTERN := "^(\\d+)d(\\d+)([\\+\\-]\\d+)?$"

static var _regex: RegEx = null


## Initialize the regex (lazy loading).
static func _get_regex() -> RegEx:
	if _regex == null:
		_regex = RegEx.new()
		_regex.compile(DICE_PATTERN)
	return _regex


## Validate if a string is valid dice notation.
## @param notation: The dice notation string to validate (e.g., "2d6+3")
## @return: True if valid, false otherwise
static func is_valid(notation: String) -> bool:
	if notation.is_empty():
		return false

	var regex = _get_regex()
	var result = regex.search(notation.strip_edges())
	return result != null


## Parse dice notation into components.
## @param notation: The dice notation string (e.g., "2d6+3")
## @return: Dictionary with {valid: bool, count: int, sides: int, modifier: int}
static func parse(notation: String) -> Dictionary:
	var result = {
		"valid": false,
		"count": 0,
		"sides": 0,
		"modifier": 0,
		"notation": notation.strip_edges()
	}

	if notation.is_empty():
		return result

	var regex = _get_regex()
	var match_result = regex.search(notation.strip_edges())

	if match_result == null:
		return result

	result.valid = true
	result.count = int(match_result.get_string(1))
	result.sides = int(match_result.get_string(2))

	# Parse modifier if present
	var modifier_str = match_result.get_string(3)
	if not modifier_str.is_empty():
		result.modifier = int(modifier_str)

	return result


## Calculate the average roll for dice notation.
## Formula: count * (sides + 1) / 2 + modifier
## @param notation: The dice notation string (e.g., "2d6+3")
## @return: The average roll as a float, or -1 if invalid
static func calculate_average(notation: String) -> float:
	var parsed = parse(notation)
	if not parsed.valid:
		return -1.0

	# Average of a single die = (1 + sides) / 2
	# For multiple dice: count * (sides + 1) / 2
	var dice_average = parsed.count * (parsed.sides + 1.0) / 2.0
	return dice_average + parsed.modifier


## Calculate the minimum possible roll.
## @param notation: The dice notation string
## @return: The minimum roll, or -1 if invalid
static func calculate_min(notation: String) -> int:
	var parsed = parse(notation)
	if not parsed.valid:
		return -1

	# Minimum is rolling all 1s
	return parsed.count + parsed.modifier


## Calculate the maximum possible roll.
## @param notation: The dice notation string
## @return: The maximum roll, or -1 if invalid
static func calculate_max(notation: String) -> int:
	var parsed = parse(notation)
	if not parsed.valid:
		return -1

	# Maximum is rolling all max values
	return parsed.count * parsed.sides + parsed.modifier


## Get a formatted tooltip string for dice notation.
## @param notation: The dice notation string
## @return: Tooltip string with avg/min/max, or error message if invalid
static func get_tooltip(notation: String) -> String:
	if notation.is_empty():
		return "Empty dice notation"

	var parsed = parse(notation)
	if not parsed.valid:
		return "Invalid dice notation: %s\nExpected format: XdY or XdY+Z (e.g., 2d6+3)" % notation

	var avg = calculate_average(notation)
	var min_roll = calculate_min(notation)
	var max_roll = calculate_max(notation)

	return "Avg: %.1f | Min: %d | Max: %d" % [avg, min_roll, max_roll]


## Validate and return detailed error information.
## @param notation: The dice notation string
## @return: Dictionary with {valid: bool, error: String}
static func validate(notation: String) -> Dictionary:
	if notation.is_empty():
		return {"valid": false, "error": "Dice notation cannot be empty"}

	var parsed = parse(notation)
	if not parsed.valid:
		return {
			"valid": false,
			"error": "Invalid format. Expected XdY or XdY+Z (e.g., 1d6, 2d8+3)"
		}

	# Additional validation
	if parsed.count <= 0:
		return {"valid": false, "error": "Dice count must be at least 1"}

	if parsed.sides <= 0:
		return {"valid": false, "error": "Dice sides must be at least 1"}

	if parsed.count > 100:
		return {"valid": false, "error": "Dice count cannot exceed 100"}

	if parsed.sides > 100:
		return {"valid": false, "error": "Dice sides cannot exceed 100"}

	return {"valid": true, "error": ""}
