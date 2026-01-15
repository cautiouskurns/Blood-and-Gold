@tool
extends EditorScript
## Test script for DialogueTagRenderer.
## Run with: Ctrl+Shift+X (or Cmd+Shift+X on Mac) in Godot editor.

func _run() -> void:
	print("\n" + "=".repeat(60))
	print("DIALOGUE TAG RENDERER TESTS")
	print("=".repeat(60))

	var tests_passed := 0
	var tests_failed := 0

	# ==========================================================================
	# BASIC VARIABLE SUBSTITUTION TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("VARIABLE SUBSTITUTION TESTS")
	print("=".repeat(60))

	# Test 1: Simple variable substitution
	print("\n--- Test 1: Simple variable ---")
	var context1 = {"name": "Alice"}
	var result1 = DialogueTagRenderer.quick_render("Hello, {name}!", context1)
	print("Input: 'Hello, {name}!' with {name: 'Alice'}")
	print("Output: '%s'" % result1)
	if result1 == "Hello, Alice!":
		print("PASS: Simple variable substitution works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Hello, Alice!' got '%s'" % result1)
		tests_failed += 1

	# Test 2: Multiple variables
	print("\n--- Test 2: Multiple variables ---")
	var context2 = {"greeting": "Welcome", "name": "Bob", "gold": 100}
	var result2 = DialogueTagRenderer.quick_render("{greeting}, {name}! You have {gold} gold.", context2)
	print("Input: '{greeting}, {name}! You have {gold} gold.'")
	print("Output: '%s'" % result2)
	if result2 == "Welcome, Bob! You have 100 gold.":
		print("PASS: Multiple variables work")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Welcome, Bob! You have 100 gold.'")
		tests_failed += 1

	# Test 3: Dot notation
	print("\n--- Test 3: Dot notation ---")
	var context3 = {"player": {"name": "Hero", "stats": {"strength": 15}}}
	var result3 = DialogueTagRenderer.quick_render("{player.name} has {player.stats.strength} strength.", context3)
	print("Input: '{player.name} has {player.stats.strength} strength.'")
	print("Output: '%s'" % result3)
	if result3 == "Hero has 15 strength.":
		print("PASS: Dot notation works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Hero has 15 strength.'")
		tests_failed += 1

	# Test 4: Missing variable - default placeholder
	print("\n--- Test 4: Missing variable (placeholder) ---")
	var result4 = DialogueTagRenderer.quick_render("Hello, {unknown}!", {})
	print("Input: 'Hello, {unknown}!' with empty context")
	print("Output: '%s'" % result4)
	if result4 == "Hello, {unknown}!":
		print("PASS: Missing variable shows placeholder")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Hello, {unknown}!'")
		tests_failed += 1

	# Test 5: Missing variable - custom placeholder
	print("\n--- Test 5: Missing variable (custom) ---")
	var renderer5 = DialogueTagRenderer.new()
	var opts5 = DialogueTagRenderer.RenderOptions.new()
	opts5.missing_variable_mode = DialogueTagRenderer.RenderOptions.MissingVariableMode.SHOW_CUSTOM
	opts5.custom_placeholder = "[MISSING]"
	renderer5.set_options(opts5)
	var result5 = renderer5.render_text("Hello, {unknown}!", {})
	print("Input: 'Hello, {unknown}!' with SHOW_CUSTOM mode")
	print("Output: '%s'" % result5)
	if result5 == "Hello, [MISSING]!":
		print("PASS: Custom placeholder works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Hello, [MISSING]!'")
		tests_failed += 1

	# Test 6: Missing variable - empty
	print("\n--- Test 6: Missing variable (empty) ---")
	var renderer6 = DialogueTagRenderer.new()
	var opts6 = DialogueTagRenderer.RenderOptions.new()
	opts6.missing_variable_mode = DialogueTagRenderer.RenderOptions.MissingVariableMode.SHOW_EMPTY
	renderer6.set_options(opts6)
	var result6 = renderer6.render_text("Hello, {unknown}!", {})
	print("Input: 'Hello, {unknown}!' with SHOW_EMPTY mode")
	print("Output: '%s'" % result6)
	if result6 == "Hello, !":
		print("PASS: Empty placeholder works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Hello, !'")
		tests_failed += 1

	# ==========================================================================
	# CONDITIONAL RENDERING TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("CONDITIONAL RENDERING TESTS")
	print("=".repeat(60))

	# Test 7: Simple if/else - true branch
	print("\n--- Test 7: Simple if/else (true) ---")
	var context7 = {"noble": true}
	var result7 = DialogueTagRenderer.quick_render("{if noble}Lord{else}Friend{/if}", context7)
	print("Input: '{if noble}Lord{else}Friend{/if}' with {noble: true}")
	print("Output: '%s'" % result7)
	if result7 == "Lord":
		print("PASS: Conditional true branch works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Lord'")
		tests_failed += 1

	# Test 8: Simple if/else - false branch
	print("\n--- Test 8: Simple if/else (false) ---")
	var context8 = {"noble": false}
	var result8 = DialogueTagRenderer.quick_render("{if noble}Lord{else}Friend{/if}", context8)
	print("Input: '{if noble}Lord{else}Friend{/if}' with {noble: false}")
	print("Output: '%s'" % result8)
	if result8 == "Friend":
		print("PASS: Conditional false branch works")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Friend'")
		tests_failed += 1

	# Test 9: if/elif/else
	print("\n--- Test 9: if/elif/else ---")
	var context9a = {"rank": 10}
	var text9 = "{if rank > 7}General{elif rank > 3}Officer{else}Soldier{/if}"
	var result9a = DialogueTagRenderer.quick_render(text9, context9a)
	print("Input: '%s' with {rank: 10}" % text9)
	print("Output: '%s'" % result9a)
	if result9a == "General":
		print("PASS: First branch matched")
		tests_passed += 1
	else:
		print("FAIL: Expected 'General'")
		tests_failed += 1

	# Test 9b: elif branch
	print("\n--- Test 9b: elif branch ---")
	var context9b = {"rank": 5}
	var result9b = DialogueTagRenderer.quick_render(text9, context9b)
	print("Input: '%s' with {rank: 5}" % text9)
	print("Output: '%s'" % result9b)
	if result9b == "Officer":
		print("PASS: Elif branch matched")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Officer'")
		tests_failed += 1

	# Test 9c: else branch
	print("\n--- Test 9c: else branch ---")
	var context9c = {"rank": 2}
	var result9c = DialogueTagRenderer.quick_render(text9, context9c)
	print("Input: '%s' with {rank: 2}" % text9)
	print("Output: '%s'" % result9c)
	if result9c == "Soldier":
		print("PASS: Else branch matched")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Soldier'")
		tests_failed += 1

	# Test 10: Nested conditionals
	print("\n--- Test 10: Nested conditionals ---")
	var context10 = {"a": true, "b": true}
	var text10 = "{if a}A{if b}B{/if}C{/if}"
	var result10 = DialogueTagRenderer.quick_render(text10, context10)
	print("Input: '%s' with {a: true, b: true}" % text10)
	print("Output: '%s'" % result10)
	if result10 == "ABC":
		print("PASS: Nested conditionals work")
		tests_passed += 1
	else:
		print("FAIL: Expected 'ABC' got '%s'" % result10)
		tests_failed += 1

	# Test 11: Variables inside conditionals
	print("\n--- Test 11: Variables inside conditionals ---")
	var context11 = {"noble": true, "title": "Lord", "name": "Blackwood"}
	var text11 = "{if noble}Greetings, {title} {name}{else}Hello, {name}{/if}"
	var result11 = DialogueTagRenderer.quick_render(text11, context11)
	print("Input: '%s'" % text11)
	print("Output: '%s'" % result11)
	if result11 == "Greetings, Lord Blackwood":
		print("PASS: Variables inside conditionals work")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Greetings, Lord Blackwood'")
		tests_failed += 1

	# Test 12: Complex condition expression
	print("\n--- Test 12: Complex expression ---")
	var context12 = {"reputation": 75, "gold": 200}
	var text12 = "{if reputation >= 50 and gold > 100}You are worthy{else}Prove yourself{/if}"
	var result12 = DialogueTagRenderer.quick_render(text12, context12)
	print("Input: '%s'" % text12)
	print("Context: {reputation: 75, gold: 200}")
	print("Output: '%s'" % result12)
	if result12 == "You are worthy":
		print("PASS: Complex expression evaluates correctly")
		tests_passed += 1
	else:
		print("FAIL: Expected 'You are worthy'")
		tests_failed += 1

	# ==========================================================================
	# EDGE CASES AND SPECIAL FEATURES
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("EDGE CASES AND SPECIAL FEATURES")
	print("=".repeat(60))

	# Test 13: Plain text (no tags)
	print("\n--- Test 13: Plain text ---")
	var result13 = DialogueTagRenderer.quick_render("Just plain text.", {})
	print("Input: 'Just plain text.'")
	print("Output: '%s'" % result13)
	if result13 == "Just plain text.":
		print("PASS: Plain text passes through unchanged")
		tests_passed += 1
	else:
		print("FAIL: Text was modified")
		tests_failed += 1

	# Test 14: Escaped braces
	print("\n--- Test 14: Escaped braces ---")
	var result14 = DialogueTagRenderer.quick_render("Use \\{curly\\} for variables", {})
	print("Input: 'Use \\{curly\\} for variables'")
	print("Output: '%s'" % result14)
	if "{curly}" in result14 or "{" in result14:
		print("PASS: Escaped braces preserved")
		tests_passed += 1
	else:
		print("FAIL: Escaped braces not preserved")
		tests_failed += 1

	# Test 15: Boolean values
	print("\n--- Test 15: Boolean values ---")
	var context15 = {"active": true, "disabled": false}
	var result15 = DialogueTagRenderer.quick_render("Active: {active}, Disabled: {disabled}", context15)
	print("Input: 'Active: {active}, Disabled: {disabled}'")
	print("Output: '%s'" % result15)
	if result15 == "Active: true, Disabled: false":
		print("PASS: Boolean values render correctly")
		tests_passed += 1
	else:
		print("FAIL: Expected 'Active: true, Disabled: false'")
		tests_failed += 1

	# Test 16: Float values (clean formatting)
	print("\n--- Test 16: Float values ---")
	var context16 = {"price": 19.50, "whole": 20.0}
	var result16 = DialogueTagRenderer.quick_render("Price: {price}, Whole: {whole}", context16)
	print("Input: 'Price: {price}, Whole: {whole}'")
	print("Output: '%s'" % result16)
	if "19.5" in result16 and "20" in result16:
		print("PASS: Float values format cleanly")
		tests_passed += 1
	else:
		print("FAIL: Float formatting issue")
		tests_failed += 1

	# Test 17: Render result with info
	print("\n--- Test 17: Full render result ---")
	var renderer17 = DialogueTagRenderer.new()
	var context17 = {"name": "Alice", "gold": 100}
	var full_result = renderer17.render("{if gold > 50}Rich {name}{else}Poor {name}{/if}", context17)
	print("Success: %s" % full_result.success)
	print("Text: '%s'" % full_result.text)
	print("Variables used: %s" % str(full_result.variables_used))
	print("Conditions evaluated: %s" % str(full_result.conditions_evaluated))
	if full_result.success and full_result.text == "Rich Alice":
		if "name" in full_result.variables_used and "gold > 50" in full_result.conditions_evaluated:
			print("PASS: Full render result contains all info")
			tests_passed += 1
		else:
			print("FAIL: Missing tracking info")
			tests_failed += 1
	else:
		print("FAIL: Render failed or wrong output")
		tests_failed += 1

	# Test 18: Needs rendering check
	print("\n--- Test 18: needs_rendering utility ---")
	var renderer18 = DialogueTagRenderer.new()
	var needs1 = renderer18.needs_rendering("Hello {name}!")
	var needs2 = renderer18.needs_rendering("Plain text")
	var needs3 = renderer18.needs_rendering("{if x}conditional{/if}")
	print("'Hello {name}!' needs rendering: %s" % needs1)
	print("'Plain text' needs rendering: %s" % needs2)
	print("'{if x}conditional{/if}' needs rendering: %s" % needs3)
	if needs1 and not needs2 and needs3:
		print("PASS: needs_rendering works correctly")
		tests_passed += 1
	else:
		print("FAIL: needs_rendering not working")
		tests_failed += 1

	# Test 19: Missing variables tracking
	print("\n--- Test 19: Missing variables tracking ---")
	var renderer19 = DialogueTagRenderer.new()
	var result19 = renderer19.render("Hello, {name} from {city}!", {"name": "Bob"})
	print("Input: 'Hello, {name} from {city}!' with {name: 'Bob'}")
	print("Missing: %s" % str(result19.missing_variables))
	if "city" in result19.missing_variables and "name" not in result19.missing_variables:
		print("PASS: Missing variables tracked correctly")
		tests_passed += 1
	else:
		print("FAIL: Missing variables not tracked")
		tests_failed += 1

	# Test 20: Caching
	print("\n--- Test 20: Caching ---")
	var renderer20 = DialogueTagRenderer.new()
	renderer20.set_cache_enabled(true)
	var context20 = {"x": "value"}
	var text20 = "Text with {x}"
	var r20a = renderer20.render_text(text20, context20)
	var r20b = renderer20.render_text(text20, context20)  # Should hit cache
	print("First render: '%s'" % r20a)
	print("Second render: '%s'" % r20b)
	if r20a == r20b and r20a == "Text with value":
		print("PASS: Caching works (same result)")
		tests_passed += 1
	else:
		print("FAIL: Cache may have caused issues")
		tests_failed += 1

	# ==========================================================================
	# SUMMARY
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("RESULTS: %d passed, %d failed" % [tests_passed, tests_failed])
	print("=".repeat(60))

	if tests_failed == 0:
		print("\nAll tests passed!")
	else:
		print("\nSome tests failed. Please review the output above.")
