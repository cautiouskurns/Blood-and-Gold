@tool
class_name ExpressionContext
extends RefCounted
## Manages test values for expression evaluation in the Dialogue Editor.
## Provides a convenient interface for setting up game state for testing dialogue conditions.

signal context_changed
signal variable_added(name: String, value: Variant)
signal variable_removed(name: String)
signal variable_changed(name: String, old_value: Variant, new_value: Variant)

# =============================================================================
# CONTEXT DATA
# =============================================================================

## Core variable values.
var _variables: Dictionary = {}

## Player stats (convenience wrapper).
var _player: Dictionary = {}

## Inventory items: { item_id: quantity }
var _items: Dictionary = {}

## Game flags: { flag_name: bool }
var _flags: Dictionary = {}

## Quest states: { quest_id: { state: String, ... } }
var _quests: Dictionary = {}

## Variable metadata (type hints, descriptions).
var _metadata: Dictionary = {}


# =============================================================================
# PUBLIC API - VARIABLES
# =============================================================================

## Set a variable value.
func set_variable(name: String, value: Variant) -> void:
	var old_value = _variables.get(name)
	var is_new = not _variables.has(name)

	_variables[name] = value

	if is_new:
		variable_added.emit(name, value)
	elif old_value != value:
		variable_changed.emit(name, old_value, value)

	context_changed.emit()


## Get a variable value.
func get_variable(name: String, default: Variant = null) -> Variant:
	return _variables.get(name, default)


## Check if a variable exists.
func has_variable(name: String) -> bool:
	return _variables.has(name)


## Remove a variable.
func remove_variable(name: String) -> void:
	if _variables.has(name):
		_variables.erase(name)
		variable_removed.emit(name)
		context_changed.emit()


## Get all variable names.
func get_variable_names() -> Array[String]:
	var names: Array[String] = []
	for key in _variables.keys():
		names.append(str(key))
	return names


## Set multiple variables at once.
func set_variables(vars: Dictionary) -> void:
	for key in vars:
		set_variable(str(key), vars[key])


## Clear all variables.
func clear_variables() -> void:
	_variables.clear()
	context_changed.emit()


# =============================================================================
# PUBLIC API - PLAYER
# =============================================================================

## Set a player stat.
func set_player_stat(stat: String, value: Variant) -> void:
	_player[stat] = value
	context_changed.emit()


## Get a player stat.
func get_player_stat(stat: String, default: Variant = null) -> Variant:
	return _player.get(stat, default)


## Set multiple player stats.
func set_player_stats(stats: Dictionary) -> void:
	for key in stats:
		_player[str(key)] = stats[key]
	context_changed.emit()


## Common player stats shortcuts.
func set_player_level(level: int) -> void:
	set_player_stat("level", level)


func set_player_health(health: int) -> void:
	set_player_stat("health", health)


func set_player_gold(gold: int) -> void:
	set_player_stat("gold", gold)
	# Also set as top-level variable for convenience
	set_variable("gold", gold)


func set_player_reputation(reputation: int) -> void:
	set_player_stat("reputation", reputation)
	set_variable("reputation", reputation)


# =============================================================================
# PUBLIC API - INVENTORY
# =============================================================================

## Add an item to inventory.
func add_item(item_id: String, quantity: int = 1) -> void:
	_items[item_id] = _items.get(item_id, 0) + quantity
	context_changed.emit()


## Remove an item from inventory.
func remove_item(item_id: String, quantity: int = 1) -> void:
	if _items.has(item_id):
		_items[item_id] = max(0, _items[item_id] - quantity)
		if _items[item_id] == 0:
			_items.erase(item_id)
		context_changed.emit()


## Set item quantity directly.
func set_item_count(item_id: String, quantity: int) -> void:
	if quantity <= 0:
		_items.erase(item_id)
	else:
		_items[item_id] = quantity
	context_changed.emit()


## Check if player has item.
func has_item(item_id: String) -> bool:
	return _items.get(item_id, 0) > 0


## Get item count.
func get_item_count(item_id: String) -> int:
	return _items.get(item_id, 0)


## Get all items.
func get_items() -> Dictionary:
	return _items.duplicate()


## Clear inventory.
func clear_inventory() -> void:
	_items.clear()
	context_changed.emit()


# =============================================================================
# PUBLIC API - FLAGS
# =============================================================================

## Set a flag.
func set_flag(flag_name: String, value: bool = true) -> void:
	_flags[flag_name] = value
	context_changed.emit()


## Get a flag value.
func get_flag(flag_name: String, default: bool = false) -> bool:
	return _flags.get(flag_name, default)


## Check if flag is set and true.
func has_flag(flag_name: String) -> bool:
	return _flags.get(flag_name, false) == true


## Toggle a flag.
func toggle_flag(flag_name: String) -> void:
	_flags[flag_name] = not _flags.get(flag_name, false)
	context_changed.emit()


## Get all flags.
func get_flags() -> Dictionary:
	return _flags.duplicate()


## Clear all flags.
func clear_flags() -> void:
	_flags.clear()
	context_changed.emit()


# =============================================================================
# PUBLIC API - QUESTS
# =============================================================================

## Quest states.
const QUEST_NOT_STARTED = "not_started"
const QUEST_ACTIVE = "active"
const QUEST_COMPLETE = "complete"
const QUEST_FAILED = "failed"


## Set quest state.
func set_quest_state(quest_id: String, state: String) -> void:
	if not _quests.has(quest_id):
		_quests[quest_id] = {}
	_quests[quest_id]["state"] = state
	context_changed.emit()


## Get quest state.
func get_quest_state(quest_id: String) -> String:
	if _quests.has(quest_id):
		return _quests[quest_id].get("state", QUEST_NOT_STARTED)
	return QUEST_NOT_STARTED


## Check if quest is complete.
func is_quest_complete(quest_id: String) -> bool:
	return get_quest_state(quest_id) == QUEST_COMPLETE


## Start a quest.
func start_quest(quest_id: String) -> void:
	set_quest_state(quest_id, QUEST_ACTIVE)


## Complete a quest.
func complete_quest(quest_id: String) -> void:
	set_quest_state(quest_id, QUEST_COMPLETE)


## Fail a quest.
func fail_quest(quest_id: String) -> void:
	set_quest_state(quest_id, QUEST_FAILED)


## Get all quests.
func get_quests() -> Dictionary:
	return _quests.duplicate(true)


## Clear all quests.
func clear_quests() -> void:
	_quests.clear()
	context_changed.emit()


# =============================================================================
# PUBLIC API - METADATA
# =============================================================================

## Set metadata for a variable (type hint, description, etc.).
func set_variable_metadata(name: String, metadata: Dictionary) -> void:
	_metadata[name] = metadata


## Get metadata for a variable.
func get_variable_metadata(name: String) -> Dictionary:
	return _metadata.get(name, {})


## Get expected type for a variable.
func get_variable_type(name: String) -> String:
	return _metadata.get(name, {}).get("type", "any")


## Get description for a variable.
func get_variable_description(name: String) -> String:
	return _metadata.get(name, {}).get("description", "")


# =============================================================================
# CONTEXT BUILDING
# =============================================================================

## Build the full context dictionary for the evaluator.
func build_context() -> Dictionary:
	var context = _variables.duplicate(true)

	# Add player data
	if not _player.is_empty():
		context["player"] = _player.duplicate(true)
		# Also add common player stats at top level for convenience
		for key in ["level", "health", "gold", "reputation"]:
			if _player.has(key) and not context.has(key):
				context[key] = _player[key]

	# Add inventory
	if not _items.is_empty():
		context["items"] = _items.duplicate()
		context["inventory"] = _items.duplicate()

	# Add flags
	if not _flags.is_empty():
		context["flags"] = _flags.duplicate()

	# Add quests
	if not _quests.is_empty():
		context["quests"] = _quests.duplicate(true)

	return context


## Create an evaluator with this context.
func create_evaluator() -> ExpressionEvaluator:
	var evaluator = ExpressionEvaluator.new()
	evaluator.set_context(build_context())
	return evaluator


## Evaluate an expression using this context.
func evaluate(expression: String) -> ExpressionEvaluator.EvaluationResult:
	var evaluator = create_evaluator()
	return evaluator.evaluate_string(expression)


## Check if an expression is true using this context.
func check(expression: String) -> bool:
	return ExpressionEvaluator.check(expression, build_context())


# =============================================================================
# SERIALIZATION
# =============================================================================

## Serialize context to dictionary (for saving).
func to_dict() -> Dictionary:
	return {
		"variables": _variables.duplicate(true),
		"player": _player.duplicate(true),
		"items": _items.duplicate(),
		"flags": _flags.duplicate(),
		"quests": _quests.duplicate(true),
		"metadata": _metadata.duplicate(true)
	}


## Load context from dictionary.
func from_dict(data: Dictionary) -> void:
	_variables = data.get("variables", {}).duplicate(true)
	_player = data.get("player", {}).duplicate(true)
	_items = data.get("items", {}).duplicate()
	_flags = data.get("flags", {}).duplicate()
	_quests = data.get("quests", {}).duplicate(true)
	_metadata = data.get("metadata", {}).duplicate(true)
	context_changed.emit()


## Clear all context data.
func clear() -> void:
	_variables.clear()
	_player.clear()
	_items.clear()
	_flags.clear()
	_quests.clear()
	_metadata.clear()
	context_changed.emit()


# =============================================================================
# PRESET CONTEXTS
# =============================================================================

## Create a default test context with common values.
static func create_default() -> ExpressionContext:
	var context = ExpressionContext.new()

	# Default player stats
	context.set_player_stats({
		"level": 5,
		"health": 100,
		"max_health": 100,
		"gold": 50,
		"reputation": 25
	})

	# A few sample items
	context.add_item("gold_coin", 50)
	context.add_item("health_potion", 3)

	# A few sample flags
	context.set_flag("tutorial_complete", true)
	context.set_flag("met_blacksmith", false)

	return context


## Create an empty context.
static func create_empty() -> ExpressionContext:
	return ExpressionContext.new()


# =============================================================================
# DEBUG
# =============================================================================

func _to_string() -> String:
	var parts = []
	if not _variables.is_empty():
		parts.append("vars: %d" % _variables.size())
	if not _player.is_empty():
		parts.append("player: %d stats" % _player.size())
	if not _items.is_empty():
		parts.append("items: %d" % _items.size())
	if not _flags.is_empty():
		parts.append("flags: %d" % _flags.size())
	if not _quests.is_empty():
		parts.append("quests: %d" % _quests.size())
	return "ExpressionContext(%s)" % ", ".join(parts)
