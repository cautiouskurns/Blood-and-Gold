@tool
extends EditorScript
## Test script for ExpressionParser
## Run with: Script → Run (Ctrl+Shift+X) in Godot editor

const ExpressionParserScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")


func _run() -> void:
	print("\n" + "=".repeat(60))
	print("EXPRESSION PARSER TESTS")
	print("=".repeat(60))

	var parser = ExpressionParserScript.new()
	var all_passed = true

	# Test 1: Simple comparison
	all_passed = _test_parse(parser, "x > 5", "(x > 5)") and all_passed

	# Test 2: Variable equality
	all_passed = _test_parse(parser, "reputation >= 50", "(reputation >= 50)") and all_passed

	# Test 3: Boolean literal
	all_passed = _test_parse(parser, "true", "true") and all_passed

	# Test 4: String literal
	all_passed = _test_parse(parser, '"hello"', '"hello"') and all_passed

	# Test 5: Number literal
	all_passed = _test_parse(parser, "42", "42") and all_passed

	# Test 6: Float literal
	all_passed = _test_parse(parser, "3.14", "3.14") and all_passed

	# Test 7: Compound AND expression
	all_passed = _test_parse(parser, "a and b", "(a and b)") and all_passed

	# Test 8: Compound OR expression
	all_passed = _test_parse(parser, "a or b", "(a or b)") and all_passed

	# Test 9: AND/OR precedence (and binds tighter than or)
	all_passed = _test_parse(parser, "a or b and c", "(a or (b and c))") and all_passed

	# Test 10: Parenthesized expression
	all_passed = _test_parse(parser, "(a or b) and c", "((a or b) and c)") and all_passed

	# Test 11: NOT operator
	all_passed = _test_parse(parser, "not x", "(not x)") and all_passed

	# Test 12: Negation operator
	all_passed = _test_parse(parser, "-5", "(- 5)") and all_passed

	# Test 13: Arithmetic addition
	all_passed = _test_parse(parser, "a + b", "(a + b)") and all_passed

	# Test 14: Arithmetic multiplication
	all_passed = _test_parse(parser, "a * b", "(a * b)") and all_passed

	# Test 15: Arithmetic precedence (* binds tighter than +)
	all_passed = _test_parse(parser, "a + b * c", "(a + (b * c))") and all_passed

	# Test 16: Parenthesized arithmetic
	all_passed = _test_parse(parser, "(a + b) * c", "((a + b) * c)") and all_passed

	# Test 17: Function call no args
	all_passed = _test_parse(parser, "foo()", "foo()") and all_passed

	# Test 18: Function call one arg
	all_passed = _test_parse(parser, 'has_item("sword")', 'has_item("sword")') and all_passed

	# Test 19: Function call multiple args
	all_passed = _test_parse(parser, 'count_items("sword", 5)', 'count_items("sword", 5)') and all_passed

	# Test 20: Dot notation
	all_passed = _test_parse(parser, "player.health", "player.health") and all_passed

	# Test 21: Deep dot notation
	all_passed = _test_parse(parser, "player.stats.strength", "player.stats.strength") and all_passed

	# Test 22: Dot notation in comparison
	all_passed = _test_parse(parser, "player.health > 50", "(player.health > 50)") and all_passed

	# Test 23: Array/bracket access
	all_passed = _test_parse(parser, "inventory[0]", "inventory[0]") and all_passed

	# Test 24: Array access with expression index
	all_passed = _test_parse(parser, "items[i + 1]", "items[(i + 1)]") and all_passed

	# Test 25: Complex expression
	all_passed = _test_parse(parser,
		'has_item("key") and player_level > 10',
		'(has_item("key") and (player_level > 10))') and all_passed

	# Test 26: Very complex expression
	all_passed = _test_parse(parser,
		'(reputation >= 50 or has_flag("noble")) and not is_enemy',
		'(((reputation >= 50) or has_flag("noble")) and (not is_enemy))') and all_passed

	# Test 27: Chained comparisons need explicit grouping
	all_passed = _test_parse(parser, "a == b == c", "((a == b) == c)") and all_passed

	# Test 28: Multiple OR
	all_passed = _test_parse(parser, "a or b or c", "((a or b) or c)") and all_passed

	# Test 29: Multiple AND
	all_passed = _test_parse(parser, "a and b and c", "((a and b) and c)") and all_passed

	# Test 30: C-style operators
	all_passed = _test_parse(parser, "a && b || c", "((a && b) || c)") and all_passed

	print("\n--- Testing Error Cases ---")

	# Error Test 1: Missing operand
	all_passed = _test_error(parser, "a +", "Expected expression after '+'") and all_passed

	# Error Test 2: Missing closing paren
	all_passed = _test_error(parser, "(a + b", "Expected ')' after expression") and all_passed

	# Error Test 3: Unexpected token
	all_passed = _test_error(parser, "a b", "Unexpected token after expression") and all_passed

	# Error Test 4: Empty expression
	all_passed = _test_error(parser, "", "Empty expression") and all_passed

	# Error Test 5: Missing function argument after comma
	all_passed = _test_error(parser, "foo(a,)", "Expected argument after ','") and all_passed

	# Error Test 6: Missing closing bracket
	all_passed = _test_error(parser, "arr[0", "Expected ']' after index") and all_passed

	# Error Test 7: Missing member after dot
	all_passed = _test_error(parser, "obj.", "Expected identifier after '.'") and all_passed

	print("\n--- Testing AST Node Types ---")

	# Verify AST node types
	all_passed = _test_node_type(parser, "42", "LiteralNode") and all_passed
	all_passed = _test_node_type(parser, "x", "VariableNode") and all_passed
	all_passed = _test_node_type(parser, "a + b", "BinaryOpNode") and all_passed
	all_passed = _test_node_type(parser, "not x", "UnaryOpNode") and all_passed
	all_passed = _test_node_type(parser, "foo()", "FunctionCallNode") and all_passed
	all_passed = _test_node_type(parser, "a.b", "MemberAccessNode") and all_passed
	all_passed = _test_node_type(parser, "a[0]", "IndexAccessNode") and all_passed

	print("\n" + "=".repeat(60))
	if all_passed:
		print("ALL TESTS PASSED!")
	else:
		print("SOME TESTS FAILED!")
	print("=".repeat(60))


func _test_parse(parser: ExpressionParserScript, expression: String, expected_output: String) -> bool:
	print("\n--- Parsing: \"%s\" ---" % expression)

	var result = parser.parse(expression)

	if result.has_errors():
		print("FAIL: Parser returned errors")
		for error in result.errors:
			print("  Error: %s" % str(error))
		return false

	var output = ExpressionParserScript.ast_to_string(result.ast)

	if output != expected_output:
		print("FAIL: Output mismatch")
		print("  Expected: %s" % expected_output)
		print("  Got:      %s" % output)
		return false

	print("PASS: %s" % output)
	return true


func _test_error(parser: ExpressionParserScript, expression: String, expected_error_contains: String) -> bool:
	var result = parser.parse(expression)

	if not result.has_errors():
		print("FAIL: Expected error for '%s' but parsing succeeded" % expression)
		return false

	var found_expected = false
	for error in result.errors:
		if expected_error_contains in str(error):
			found_expected = true
			break

	if found_expected:
		print("PASS: Error detected for '%s': %s" % [expression, result.errors[0].message])
		return true
	else:
		print("FAIL: Wrong error message")
		print("  Expected message containing: %s" % expected_error_contains)
		print("  Got: %s" % str(result.errors[0]))
		return false


func _test_node_type(parser: ExpressionParserScript, expression: String, expected_type: String) -> bool:
	var result = parser.parse(expression)

	if result.has_errors():
		print("FAIL: Parser error for '%s'" % expression)
		return false

	var node_class = result.ast.get_class()
	# get_class() returns the base GDScript class, so we check the script class name
	var actual_type = _get_ast_node_type_name(result.ast)

	if actual_type == expected_type:
		print("PASS: '%s' → %s" % [expression, actual_type])
		return true
	else:
		print("FAIL: Node type mismatch for '%s'" % expression)
		print("  Expected: %s" % expected_type)
		print("  Got: %s" % actual_type)
		return false


func _get_ast_node_type_name(node) -> String:
	if node is ExpressionParserScript.LiteralNode:
		return "LiteralNode"
	elif node is ExpressionParserScript.VariableNode:
		return "VariableNode"
	elif node is ExpressionParserScript.BinaryOpNode:
		return "BinaryOpNode"
	elif node is ExpressionParserScript.UnaryOpNode:
		return "UnaryOpNode"
	elif node is ExpressionParserScript.FunctionCallNode:
		return "FunctionCallNode"
	elif node is ExpressionParserScript.MemberAccessNode:
		return "MemberAccessNode"
	elif node is ExpressionParserScript.IndexAccessNode:
		return "IndexAccessNode"
	return "Unknown"
