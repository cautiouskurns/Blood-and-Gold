@tool
extends EditorScript
## Test script for ExpressionEvaluator
## Run with: Script → Run (Ctrl+Shift+X) in Godot editor

const ExpressionEvaluatorScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_evaluator.gd")
const ExpressionContextScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_context.gd")


func _run() -> void:
	print("\n" + "=".repeat(60))
	print("EXPRESSION EVALUATOR TESTS")
	print("=".repeat(60))

	var all_passed = true

	# ==========================================================================
	# BASIC LITERALS
	# ==========================================================================
	print("\n--- Literal Values ---")

	all_passed = _test_eval("42", {}, 42) and all_passed
	all_passed = _test_eval("3.14", {}, 3.14) and all_passed
	all_passed = _test_eval('"hello"', {}, "hello") and all_passed
	all_passed = _test_eval("true", {}, true) and all_passed
	all_passed = _test_eval("false", {}, false) and all_passed

	# ==========================================================================
	# COMPARISON OPERATORS
	# ==========================================================================
	print("\n--- Comparison Operators ---")

	all_passed = _test_eval("5 > 3", {}, true) and all_passed
	all_passed = _test_eval("3 > 5", {}, false) and all_passed
	all_passed = _test_eval("5 >= 5", {}, true) and all_passed
	all_passed = _test_eval("5 < 10", {}, true) and all_passed
	all_passed = _test_eval("5 <= 5", {}, true) and all_passed
	all_passed = _test_eval("5 == 5", {}, true) and all_passed
	all_passed = _test_eval("5 != 3", {}, true) and all_passed
	all_passed = _test_eval('"hello" == "hello"', {}, true) and all_passed
	all_passed = _test_eval('"hello" != "world"', {}, true) and all_passed

	# ==========================================================================
	# ARITHMETIC OPERATORS
	# ==========================================================================
	print("\n--- Arithmetic Operators ---")

	all_passed = _test_eval("2 + 3", {}, 5.0) and all_passed
	all_passed = _test_eval("10 - 4", {}, 6.0) and all_passed
	all_passed = _test_eval("3 * 4", {}, 12.0) and all_passed
	all_passed = _test_eval("15 / 3", {}, 5.0) and all_passed
	all_passed = _test_eval("17 % 5", {}, 2.0) and all_passed
	all_passed = _test_eval("2 + 3 * 4", {}, 14.0) and all_passed  # Precedence
	all_passed = _test_eval("(2 + 3) * 4", {}, 20.0) and all_passed  # Grouping

	# String concatenation
	all_passed = _test_eval('"hello" + " world"', {}, "hello world") and all_passed

	# ==========================================================================
	# LOGICAL OPERATORS
	# ==========================================================================
	print("\n--- Logical Operators ---")

	all_passed = _test_eval("true and true", {}, true) and all_passed
	all_passed = _test_eval("true and false", {}, false) and all_passed
	all_passed = _test_eval("false or true", {}, true) and all_passed
	all_passed = _test_eval("false or false", {}, false) and all_passed
	all_passed = _test_eval("not true", {}, false) and all_passed
	all_passed = _test_eval("not false", {}, true) and all_passed
	all_passed = _test_eval("true and true or false", {}, true) and all_passed
	all_passed = _test_eval("(true or false) and true", {}, true) and all_passed

	# ==========================================================================
	# UNARY OPERATORS
	# ==========================================================================
	print("\n--- Unary Operators ---")

	all_passed = _test_eval("-5", {}, -5.0) and all_passed
	all_passed = _test_eval("--5", {}, 5.0) and all_passed
	all_passed = _test_eval("not not true", {}, true) and all_passed

	# ==========================================================================
	# VARIABLES
	# ==========================================================================
	print("\n--- Variables ---")

	all_passed = _test_eval("x", {"x": 42}, 42) and all_passed
	all_passed = _test_eval("name", {"name": "Alice"}, "Alice") and all_passed
	all_passed = _test_eval("x + y", {"x": 10, "y": 20}, 30.0) and all_passed
	all_passed = _test_eval("reputation >= 50", {"reputation": 60}, true) and all_passed
	all_passed = _test_eval("reputation >= 50", {"reputation": 40}, false) and all_passed

	# Missing variable (default to null in non-strict mode)
	all_passed = _test_eval("missing_var", {}, null) and all_passed

	# ==========================================================================
	# MEMBER ACCESS (DOT NOTATION)
	# ==========================================================================
	print("\n--- Member Access ---")

	all_passed = _test_eval("player.health", {"player": {"health": 100}}, 100) and all_passed
	all_passed = _test_eval("player.stats.strength", {"player": {"stats": {"strength": 15}}}, 15) and all_passed
	all_passed = _test_eval("player.health > 50", {"player": {"health": 100}}, true) and all_passed

	# ==========================================================================
	# INDEX ACCESS
	# ==========================================================================
	print("\n--- Index Access ---")

	all_passed = _test_eval("items[0]", {"items": ["sword", "shield", "potion"]}, "sword") and all_passed
	all_passed = _test_eval("items[2]", {"items": ["sword", "shield", "potion"]}, "potion") and all_passed
	all_passed = _test_eval("scores[1] > 50", {"scores": [30, 75, 90]}, true) and all_passed

	# ==========================================================================
	# FUNCTION CALLS - BUILT-IN FUNCTIONS
	# ==========================================================================
	print("\n--- Built-in Functions ---")

	# has_item
	all_passed = _test_eval('has_item("key")', {"items": {"key": 1}}, true) and all_passed
	all_passed = _test_eval('has_item("key")', {"items": {"sword": 1}}, false) and all_passed
	all_passed = _test_eval('has_item("key")', {"inventory": [{"id": "key"}]}, true) and all_passed

	# count
	all_passed = _test_eval('count("potion")', {"items": {"potion": 5}}, 5) and all_passed
	all_passed = _test_eval('count("missing")', {"items": {}}, 0) and all_passed

	# has_flag
	all_passed = _test_eval('has_flag("tutorial_done")', {"flags": {"tutorial_done": true}}, true) and all_passed
	all_passed = _test_eval('has_flag("tutorial_done")', {"flags": {"tutorial_done": false}}, false) and all_passed
	all_passed = _test_eval('has_flag("missing")', {"flags": {}}, false) and all_passed

	# quest_state
	all_passed = _test_eval('quest_state("main")', {"quests": {"main": {"state": "active"}}}, "active") and all_passed
	all_passed = _test_eval('quest_state("main") == "active"', {"quests": {"main": {"state": "active"}}}, true) and all_passed
	all_passed = _test_eval('quest_complete("main")', {"quests": {"main": {"state": "complete"}}}, true) and all_passed

	# Math functions
	all_passed = _test_eval("min(5, 10)", {}, 5.0) and all_passed
	all_passed = _test_eval("max(5, 10)", {}, 10.0) and all_passed
	all_passed = _test_eval("abs(-5)", {}, 5.0) and all_passed
	all_passed = _test_eval("clamp(15, 0, 10)", {}, 10.0) and all_passed
	all_passed = _test_eval("floor(3.7)", {}, 3.0) and all_passed
	all_passed = _test_eval("ceil(3.2)", {}, 4.0) and all_passed
	all_passed = _test_eval("round(3.5)", {}, 4.0) and all_passed

	# String functions
	all_passed = _test_eval('len("hello")', {}, 5) and all_passed
	all_passed = _test_eval('upper("hello")', {}, "HELLO") and all_passed
	all_passed = _test_eval('lower("HELLO")', {}, "hello") and all_passed

	# Type checking
	all_passed = _test_eval("is_number(42)", {}, true) and all_passed
	all_passed = _test_eval('is_string("hello")', {}, true) and all_passed
	all_passed = _test_eval("is_bool(true)", {}, true) and all_passed

	# ==========================================================================
	# COMPLEX EXPRESSIONS
	# ==========================================================================
	print("\n--- Complex Expressions ---")

	# From success criteria
	all_passed = _test_eval('has_item("key") and gold > 100',
		{"items": {"key": 1}, "gold": 150}, true) and all_passed

	all_passed = _test_eval('has_item("key") and gold > 100',
		{"items": {"key": 1}, "gold": 50}, false) and all_passed

	all_passed = _test_eval('reputation >= 50 or has_flag("noble")',
		{"reputation": 30, "flags": {"noble": true}}, true) and all_passed

	all_passed = _test_eval('player.level >= 5 and (has_item("quest_item") or quest_complete("prologue"))',
		{"player": {"level": 7}, "items": {"quest_item": 1}, "quests": {}}, true) and all_passed

	# ==========================================================================
	# TYPE COERCION
	# ==========================================================================
	print("\n--- Type Coercion ---")

	# Number to bool
	all_passed = _test_eval("1 and true", {}, true) and all_passed
	all_passed = _test_eval("0 or false", {}, false) and all_passed

	# String to number in arithmetic
	all_passed = _test_eval('"5" + 3', {}, "53") and all_passed  # String concatenation wins

	# Comparison with different types
	all_passed = _test_eval("5 == 5.0", {}, true) and all_passed
	all_passed = _test_eval('5 == "5"', {}, true) and all_passed  # String coerced to number

	# ==========================================================================
	# ERROR HANDLING
	# ==========================================================================
	print("\n--- Error Handling ---")

	all_passed = _test_error("1 / 0", "Division by zero") and all_passed
	all_passed = _test_error("1 % 0", "Modulo by zero") and all_passed
	all_passed = _test_error("unknown_func()", "Unknown function") and all_passed

	# ==========================================================================
	# EXPRESSION CONTEXT
	# ==========================================================================
	print("\n--- ExpressionContext ---")

	var context = ExpressionContextScript.new()
	context.set_player_stats({"level": 10, "health": 100, "gold": 500, "reputation": 75})
	context.add_item("sword", 1)
	context.add_item("potion", 5)
	context.set_flag("met_king", true)
	context.set_quest_state("main", "active")

	all_passed = _test_context_eval(context, "player.level >= 10", true) and all_passed
	all_passed = _test_context_eval(context, 'has_item("sword")', true) and all_passed
	all_passed = _test_context_eval(context, 'count("potion")', 5) and all_passed
	all_passed = _test_context_eval(context, 'has_flag("met_king")', true) and all_passed
	all_passed = _test_context_eval(context, 'quest_state("main") == "active"', true) and all_passed
	all_passed = _test_context_eval(context, "reputation >= 50 and gold > 100", true) and all_passed

	# ==========================================================================
	# STATIC CONVENIENCE METHODS
	# ==========================================================================
	print("\n--- Static Methods ---")

	var result = ExpressionEvaluatorScript.eval("5 + 3", {})
	if result == 8.0:
		print("PASS: ExpressionEvaluator.eval()")
	else:
		print("FAIL: ExpressionEvaluator.eval() returned %s, expected 8" % str(result))
		all_passed = false

	var check_result = ExpressionEvaluatorScript.check("10 > 5", {})
	if check_result == true:
		print("PASS: ExpressionEvaluator.check()")
	else:
		print("FAIL: ExpressionEvaluator.check() returned %s, expected true" % str(check_result))
		all_passed = false

	# ==========================================================================
	# SUMMARY
	# ==========================================================================
	print("\n" + "=".repeat(60))
	if all_passed:
		print("ALL TESTS PASSED!")
	else:
		print("SOME TESTS FAILED!")
	print("=".repeat(60))


func _test_eval(expression: String, context: Dictionary, expected: Variant) -> bool:
	var evaluator = ExpressionEvaluatorScript.new()
	evaluator.set_context(context)

	var result = evaluator.evaluate_string(expression)

	if not result.success:
		print("FAIL: '%s' → Error: %s" % [expression, result.error])
		return false

	if not _values_equal(result.value, expected):
		print("FAIL: '%s' → Got %s (%s), expected %s (%s)" % [
			expression,
			str(result.value), typeof(result.value),
			str(expected), typeof(expected)
		])
		return false

	print("PASS: '%s' → %s" % [expression, str(result.value)])
	return true


func _test_error(expression: String, expected_error_contains: String) -> bool:
	var evaluator = ExpressionEvaluatorScript.new()
	var result = evaluator.evaluate_string(expression)

	if result.success:
		print("FAIL: Expected error for '%s' but got: %s" % [expression, str(result.value)])
		return false

	if expected_error_contains in result.error:
		print("PASS: '%s' → Error: %s" % [expression, result.error])
		return true
	else:
		print("FAIL: Wrong error for '%s'" % expression)
		print("  Expected containing: %s" % expected_error_contains)
		print("  Got: %s" % result.error)
		return false


func _test_context_eval(context: ExpressionContextScript, expression: String, expected: Variant) -> bool:
	var result = context.evaluate(expression)

	if not result.success:
		print("FAIL: Context '%s' → Error: %s" % [expression, result.error])
		return false

	if not _values_equal(result.value, expected):
		print("FAIL: Context '%s' → Got %s, expected %s" % [expression, str(result.value), str(expected)])
		return false

	print("PASS: Context '%s' → %s" % [expression, str(result.value)])
	return true


func _values_equal(a: Variant, b: Variant) -> bool:
	# Handle float comparison with some tolerance
	if (a is float or a is int) and (b is float or b is int):
		return abs(float(a) - float(b)) < 0.0001

	return a == b
