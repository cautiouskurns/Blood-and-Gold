@tool
extends EditorScript
## Test script for ExpressionLexer
## Run with: Script → Run (Ctrl+Shift+X) in Godot editor

const ExpressionLexerScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_lexer.gd")


func _run() -> void:
	print("\n" + "=".repeat(60))
	print("EXPRESSION LEXER TESTS")
	print("=".repeat(60))

	var lexer = ExpressionLexerScript.new()
	var all_passed = true

	# Test 1: Simple comparison
	all_passed = _test_expression(lexer, "reputation >= 50", [
		["IDENTIFIER", "reputation"],
		["OPERATOR", ">="],
		["NUMBER", 50],
		["EOF", null]
	]) and all_passed

	# Test 2: Complex expression with function call
	all_passed = _test_expression(lexer, 'has_item("key") and player_level > 10', [
		["IDENTIFIER", "has_item"],
		["LPAREN", "("],
		["STRING", "key"],
		["RPAREN", ")"],
		["KEYWORD", "and"],
		["IDENTIFIER", "player_level"],
		["OPERATOR", ">"],
		["NUMBER", 10],
		["EOF", null]
	]) and all_passed

	# Test 3: Boolean literals
	all_passed = _test_expression(lexer, "true and false or not true", [
		["BOOLEAN", true],
		["KEYWORD", "and"],
		["BOOLEAN", false],
		["KEYWORD", "or"],
		["KEYWORD", "not"],
		["BOOLEAN", true],
		["EOF", null]
	]) and all_passed

	# Test 4: Arithmetic
	all_passed = _test_expression(lexer, "damage * 1.5 + bonus - 10", [
		["IDENTIFIER", "damage"],
		["OPERATOR", "*"],
		["NUMBER", 1.5],
		["OPERATOR", "+"],
		["IDENTIFIER", "bonus"],
		["OPERATOR", "-"],
		["NUMBER", 10],
		["EOF", null]
	]) and all_passed

	# Test 5: Nested parentheses
	all_passed = _test_expression(lexer, "(a + b) * (c - d)", [
		["LPAREN", "("],
		["IDENTIFIER", "a"],
		["OPERATOR", "+"],
		["IDENTIFIER", "b"],
		["RPAREN", ")"],
		["OPERATOR", "*"],
		["LPAREN", "("],
		["IDENTIFIER", "c"],
		["OPERATOR", "-"],
		["IDENTIFIER", "d"],
		["RPAREN", ")"],
		["EOF", null]
	]) and all_passed

	# Test 6: Dot notation
	all_passed = _test_expression(lexer, "player.stats.strength > enemy.health", [
		["IDENTIFIER", "player"],
		["DOT", "."],
		["IDENTIFIER", "stats"],
		["DOT", "."],
		["IDENTIFIER", "strength"],
		["OPERATOR", ">"],
		["IDENTIFIER", "enemy"],
		["DOT", "."],
		["IDENTIFIER", "health"],
		["EOF", null]
	]) and all_passed

	# Test 7: String with escapes
	all_passed = _test_expression(lexer, '"hello\\nworld\\t!"', [
		["STRING", "hello\nworld\t!"],
		["EOF", null]
	]) and all_passed

	# Test 8: Multiple operators
	all_passed = _test_expression(lexer, "a == b and c != d or e <= f", [
		["IDENTIFIER", "a"],
		["OPERATOR", "=="],
		["IDENTIFIER", "b"],
		["KEYWORD", "and"],
		["IDENTIFIER", "c"],
		["OPERATOR", "!="],
		["IDENTIFIER", "d"],
		["KEYWORD", "or"],
		["IDENTIFIER", "e"],
		["OPERATOR", "<="],
		["IDENTIFIER", "f"],
		["EOF", null]
	]) and all_passed

	# Test 9: Function with multiple arguments
	all_passed = _test_expression(lexer, 'count_items("sword", 5)', [
		["IDENTIFIER", "count_items"],
		["LPAREN", "("],
		["STRING", "sword"],
		["COMMA", ","],
		["NUMBER", 5],
		["RPAREN", ")"],
		["EOF", null]
	]) and all_passed

	# Test 10: Negative numbers
	all_passed = _test_expression(lexer, "health > -10 and damage <= -5.5", [
		["IDENTIFIER", "health"],
		["OPERATOR", ">"],
		["NUMBER", -10],
		["KEYWORD", "and"],
		["IDENTIFIER", "damage"],
		["OPERATOR", "<="],
		["NUMBER", -5.5],
		["EOF", null]
	]) and all_passed

	# Test 11: Comments
	all_passed = _test_expression(lexer, "a + b # this is a comment", [
		["IDENTIFIER", "a"],
		["OPERATOR", "+"],
		["IDENTIFIER", "b"],
		["EOF", null]
	]) and all_passed

	# Test 12: C-style line comment
	all_passed = _test_expression(lexer, "x > 5 // check threshold", [
		["IDENTIFIER", "x"],
		["OPERATOR", ">"],
		["NUMBER", 5],
		["EOF", null]
	]) and all_passed

	# Test 13: Single quotes
	all_passed = _test_expression(lexer, "name == 'Alice'", [
		["IDENTIFIER", "name"],
		["OPERATOR", "=="],
		["STRING", "Alice"],
		["EOF", null]
	]) and all_passed

	# Test 14: Array access (bracket notation)
	all_passed = _test_expression(lexer, "inventory[0]", [
		["IDENTIFIER", "inventory"],
		["LBRACKET", "["],
		["NUMBER", 0],
		["RBRACKET", "]"],
		["EOF", null]
	]) and all_passed

	# Test 15: Float starting with dot
	all_passed = _test_expression(lexer, ".5 + .25", [
		["NUMBER", 0.5],
		["OPERATOR", "+"],
		["NUMBER", 0.25],
		["EOF", null]
	]) and all_passed

	# Test 16: Scientific notation
	all_passed = _test_expression(lexer, "1e10 + 2.5E-3", [
		["NUMBER", 1e10],
		["OPERATOR", "+"],
		["NUMBER", 2.5e-3],
		["EOF", null]
	]) and all_passed

	# Test error case: unterminated string
	print("\n--- Testing Error Cases ---")
	var result = lexer.tokenize('"unterminated string')
	if result.has_errors():
		print("PASS: Detected unterminated string error")
		print("  Error: %s" % result.errors[0])
	else:
		print("FAIL: Should have detected unterminated string")
		all_passed = false

	# Test error case: invalid character
	result = lexer.tokenize("a @ b")
	if result.has_errors():
		print("PASS: Detected invalid character '@'")
		print("  Error: %s" % result.errors[0])
	else:
		print("FAIL: Should have detected invalid character")
		all_passed = false

	print("\n" + "=".repeat(60))
	if all_passed:
		print("ALL TESTS PASSED!")
	else:
		print("SOME TESTS FAILED!")
	print("=".repeat(60))


func _test_expression(lexer: ExpressionLexerScript, expression: String, expected: Array) -> bool:
	print("\n--- Testing: \"%s\" ---" % expression)

	var result = lexer.tokenize(expression)

	if result.has_errors():
		print("FAIL: Lexer returned errors")
		for error in result.errors:
			print("  Error: %s" % error)
		return false

	var tokens = result.tokens

	if tokens.size() != expected.size():
		print("FAIL: Token count mismatch (got %d, expected %d)" % [tokens.size(), expected.size()])
		_print_tokens(tokens)
		return false

	for i in range(expected.size()):
		var token = tokens[i]
		var exp_type = expected[i][0]
		var exp_value = expected[i][1]

		if token.get_type_name() != exp_type:
			print("FAIL: Token %d type mismatch (got %s, expected %s)" % [i, token.get_type_name(), exp_type])
			_print_tokens(tokens)
			return false

		if token.value != exp_value:
			print("FAIL: Token %d value mismatch (got %s, expected %s)" % [i, str(token.value), str(exp_value)])
			_print_tokens(tokens)
			return false

	print("PASS")
	return true


func _print_tokens(tokens: Array) -> void:
	print("  Tokens:")
	for i in range(tokens.size()):
		var token = tokens[i]
		print("    [%d] %s = %s (lexeme: '%s')" % [i, token.get_type_name(), str(token.value), token.lexeme])
