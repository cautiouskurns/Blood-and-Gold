@tool
extends EditorScript
## Test script for DialogueTagParser.
## Run with: Ctrl+Shift+X (or Cmd+Shift+X on Mac) in Godot editor.

func _run() -> void:
	print("\n" + "=".repeat(60))
	print("DIALOGUE TAG PARSER TESTS")
	print("=".repeat(60))

	var parser = DialogueTagParser.new()
	var tests_passed := 0
	var tests_failed := 0

	# Test 1: Simple variable
	print("\n--- Test 1: Simple variable ---")
	var result1 = parser.parse("Hello, {player_name}!")
	print("Input: 'Hello, {player_name}!'")
	print("Tags: %d" % result1.tags.size())
	for tag in result1.tags:
		print("  - %s" % tag)
	if result1.success and result1.tags.size() == 3:
		var var_tag = result1.tags[1]
		if var_tag.type == DialogueTagParser.TagType.VARIABLE and var_tag.content == "player_name":
			print("PASS: Correctly parsed simple variable")
			tests_passed += 1
		else:
			print("FAIL: Variable tag not correct")
			tests_failed += 1
	else:
		print("FAIL: Unexpected result")
		tests_failed += 1

	# Test 2: Dot notation
	print("\n--- Test 2: Dot notation ---")
	var result2 = parser.parse("Gold: {player.gold}")
	print("Input: 'Gold: {player.gold}'")
	print("Tags: %d" % result2.tags.size())
	for tag in result2.tags:
		print("  - %s" % tag)
	if result2.success and result2.tags.size() == 2:
		var var_tag = result2.tags[1]
		if var_tag.type == DialogueTagParser.TagType.VARIABLE and var_tag.path == ["player", "gold"]:
			print("PASS: Correctly parsed dot notation")
			tests_passed += 1
		else:
			print("FAIL: Dot notation not parsed correctly (path: %s)" % str(var_tag.path))
			tests_failed += 1
	else:
		print("FAIL: Unexpected result")
		tests_failed += 1

	# Test 3: Deep dot notation
	print("\n--- Test 3: Deep dot notation ---")
	var result3 = parser.parse("{player.stats.strength}")
	print("Input: '{player.stats.strength}'")
	print("Tags: %d" % result3.tags.size())
	for tag in result3.tags:
		print("  - %s" % tag)
	if result3.success and result3.tags.size() == 1:
		var var_tag = result3.tags[0]
		if var_tag.path == ["player", "stats", "strength"]:
			print("PASS: Correctly parsed deep dot notation")
			tests_passed += 1
		else:
			print("FAIL: Deep dot notation not parsed correctly (path: %s)" % str(var_tag.path))
			tests_failed += 1
	else:
		print("FAIL: Unexpected result")
		tests_failed += 1

	# Test 4: Escaped braces
	print("\n--- Test 4: Escaped braces ---")
	var result4 = parser.parse("Use \\{curly\\} for variables")
	print("Input: 'Use \\{curly\\} for variables'")
	print("Tags: %d" % result4.tags.size())
	for tag in result4.tags:
		print("  - %s" % tag)
	# Should have text segments with literal braces
	if result4.success:
		var full_text := ""
		for tag in result4.tags:
			if tag.type == DialogueTagParser.TagType.TEXT:
				full_text += tag.content
		if "{" in full_text:
			print("PASS: Escaped braces preserved as text")
			tests_passed += 1
		else:
			print("FAIL: Escaped braces not preserved")
			tests_failed += 1
	else:
		print("FAIL: Parse failed")
		tests_failed += 1

	# Test 5: Unclosed tag error
	print("\n--- Test 5: Unclosed tag error ---")
	var result5 = parser.parse("Hello {name")
	print("Input: 'Hello {name'")
	print("Success: %s" % result5.success)
	print("Errors: %d" % result5.errors.size())
	for error in result5.errors:
		print("  - %s" % error)
	if not result5.success and result5.errors.size() > 0:
		print("PASS: Correctly reported unclosed tag error")
		tests_passed += 1
	else:
		print("FAIL: Should have reported error")
		tests_failed += 1

	# Test 6: Invalid variable name
	print("\n--- Test 6: Invalid variable name ---")
	var result6 = parser.parse("Hello {123invalid}")
	print("Input: 'Hello {123invalid}'")
	print("Success: %s" % result6.success)
	print("Errors: %d" % result6.errors.size())
	for error in result6.errors:
		print("  - %s" % error)
	if not result6.success:
		print("PASS: Correctly rejected invalid variable name")
		tests_passed += 1
	else:
		print("FAIL: Should have rejected invalid name")
		tests_failed += 1

	# Test 7: Multiple variables
	print("\n--- Test 7: Multiple variables ---")
	var result7 = parser.parse("{greeting}, {player_name}! You have {gold} gold.")
	print("Input: '{greeting}, {player_name}! You have {gold} gold.'")
	print("Tags: %d" % result7.tags.size())
	var var_names = result7.get_variable_names()
	print("Variables found: %s" % str(var_names))
	if result7.success and var_names.size() == 3:
		if "greeting" in var_names and "player_name" in var_names and "gold" in var_names:
			print("PASS: Found all variables")
			tests_passed += 1
		else:
			print("FAIL: Missing variables")
			tests_failed += 1
	else:
		print("FAIL: Unexpected result")
		tests_failed += 1

	# Test 8: Empty tag error
	print("\n--- Test 8: Empty tag error ---")
	var result8 = parser.parse("Hello {}!")
	print("Input: 'Hello {}!'")
	print("Success: %s" % result8.success)
	if not result8.success:
		print("PASS: Correctly rejected empty tag")
		tests_passed += 1
	else:
		print("FAIL: Should have rejected empty tag")
		tests_failed += 1

	# Test 9: has_tags utility
	print("\n--- Test 9: has_tags utility ---")
	var has1 = parser.has_tags("Hello {name}!")
	var has2 = parser.has_tags("Hello world!")
	var has3 = parser.has_tags("Use \\{escaped\\}")
	print("'Hello {name}!' has tags: %s" % has1)
	print("'Hello world!' has tags: %s" % has2)
	print("'Use \\{escaped\\}' has tags: %s" % has3)
	if has1 and not has2:
		print("PASS: has_tags works correctly")
		tests_passed += 1
	else:
		print("FAIL: has_tags not working")
		tests_failed += 1

	# Test 10: Valid variable name checker
	print("\n--- Test 10: Static validators ---")
	var valid1 = DialogueTagParser.is_valid_variable_name("player_name")
	var valid2 = DialogueTagParser.is_valid_variable_name("player.stats.health")
	var valid3 = DialogueTagParser.is_valid_variable_name("123invalid")
	var valid4 = DialogueTagParser.is_valid_variable_name("")
	print("'player_name' valid: %s" % valid1)
	print("'player.stats.health' valid: %s" % valid2)
	print("'123invalid' valid: %s" % valid3)
	print("'' (empty) valid: %s" % valid4)
	if valid1 and valid2 and not valid3 and not valid4:
		print("PASS: Variable name validation works")
		tests_passed += 1
	else:
		print("FAIL: Variable name validation incorrect")
		tests_failed += 1

	# Summary
	print("\n" + "=".repeat(60))
	print("RESULTS: %d passed, %d failed" % [tests_passed, tests_failed])
	print("=".repeat(60))

	if tests_failed == 0:
		print("\nAll tests passed!")
	else:
		print("\nSome tests failed. Please review the output above.")
