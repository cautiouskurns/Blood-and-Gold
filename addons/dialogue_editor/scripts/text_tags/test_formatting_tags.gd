@tool
extends EditorScript
## Test script for DialogueFormattingTags.
## Run with: Ctrl+Shift+X (or Cmd+Shift+X on Mac) in Godot editor.

func _run() -> void:
	print("\n" + "=".repeat(60))
	print("DIALOGUE FORMATTING TAGS TESTS")
	print("=".repeat(60))

	var tests_passed := 0
	var tests_failed := 0

	var formatter = DialogueFormattingTags.new()

	# ==========================================================================
	# TAG REGISTRATION TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("TAG REGISTRATION TESTS")
	print("=".repeat(60))

	# Test 1: Standard BBCode tags registered
	print("\n--- Test 1: Standard BBCode tags ---")
	var standard_tags = ["b", "i", "u", "s", "color", "font_size", "code", "center", "right"]
	var all_found = true
	for tag_name in standard_tags:
		if not formatter.is_known_tag(tag_name):
			print("MISSING: %s" % tag_name)
			all_found = false
	if all_found:
		print("PASS: All standard BBCode tags registered")
		tests_passed += 1
	else:
		print("FAIL: Some standard tags missing")
		tests_failed += 1

	# Test 2: Game effect tags registered
	print("\n--- Test 2: Game effect tags ---")
	var game_tags = ["shake", "wave", "rainbow", "fade"]
	all_found = true
	for tag_name in game_tags:
		if not formatter.is_known_tag(tag_name):
			print("MISSING: %s" % tag_name)
			all_found = false
	if all_found:
		print("PASS: All game effect tags registered")
		tests_passed += 1
	else:
		print("FAIL: Some game tags missing")
		tests_failed += 1

	# Test 3: Timing tags registered
	print("\n--- Test 3: Timing tags ---")
	var timing_tags = ["pause", "speed", "wait", "clear"]
	all_found = true
	for tag_name in timing_tags:
		if not formatter.is_known_tag(tag_name):
			print("MISSING: %s" % tag_name)
			all_found = false
	if all_found:
		print("PASS: All timing tags registered")
		tests_passed += 1
	else:
		print("FAIL: Some timing tags missing")
		tests_failed += 1

	# Test 4: Tag definitions have correct properties
	print("\n--- Test 4: Tag properties ---")
	var pause_tag = formatter.get_tag("pause")
	var color_tag = formatter.get_tag("color")
	if pause_tag and color_tag:
		var checks_passed = true
		if not pause_tag.self_closing:
			print("FAIL: pause should be self-closing")
			checks_passed = false
		if not color_tag.has_value or not color_tag.required_value:
			print("FAIL: color should require a value")
			checks_passed = false
		if checks_passed:
			print("PASS: Tag properties correct")
			tests_passed += 1
		else:
			tests_failed += 1
	else:
		print("FAIL: Could not get tag definitions")
		tests_failed += 1

	# ==========================================================================
	# PARSING TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("PARSING TESTS")
	print("=".repeat(60))

	# Test 5: Simple tag parsing
	print("\n--- Test 5: Simple tag parsing ---")
	var parse1 = formatter.parse("[b]bold[/b]")
	print("Input: '[b]bold[/b]'")
	print("Tags found: %d" % parse1.tags.size())
	for tag in parse1.tags:
		print("  - %s" % tag)
	if parse1.tags.size() == 2:
		var open_tag = parse1.tags[0]
		var close_tag = parse1.tags[1]
		if open_tag.name == "b" and not open_tag.is_closing and close_tag.name == "b" and close_tag.is_closing:
			print("PASS: Simple tags parsed correctly")
			tests_passed += 1
		else:
			print("FAIL: Tag content incorrect")
			tests_failed += 1
	else:
		print("FAIL: Expected 2 tags")
		tests_failed += 1

	# Test 6: Tag with value
	print("\n--- Test 6: Tag with value ---")
	var parse2 = formatter.parse("[color=red]text[/color]")
	print("Input: '[color=red]text[/color]'")
	if parse2.tags.size() >= 1:
		var tag = parse2.tags[0]
		print("Tag name: %s, value: %s" % [tag.name, tag.value])
		if tag.name == "color" and tag.value == "red":
			print("PASS: Tag value parsed correctly")
			tests_passed += 1
		else:
			print("FAIL: Tag value incorrect")
			tests_failed += 1
	else:
		print("FAIL: No tags found")
		tests_failed += 1

	# Test 7: Self-closing tag
	print("\n--- Test 7: Self-closing tag ---")
	var parse3 = formatter.parse("Before[pause=1.5]After")
	print("Input: 'Before[pause=1.5]After'")
	if parse3.tags.size() == 1:
		var tag = parse3.tags[0]
		print("Tag: %s, self-closing: %s, value: %s" % [tag.name, tag.is_self_closing, tag.value])
		if tag.name == "pause" and tag.is_self_closing and tag.value == "1.5":
			print("PASS: Self-closing tag parsed correctly")
			tests_passed += 1
		else:
			print("FAIL: Self-closing tag incorrect")
			tests_failed += 1
	else:
		print("FAIL: Expected 1 tag, found %d" % parse3.tags.size())
		tests_failed += 1

	# Test 8: Multiple nested tags
	print("\n--- Test 8: Multiple nested tags ---")
	var parse4 = formatter.parse("[b][i]bold italic[/i][/b]")
	print("Input: '[b][i]bold italic[/i][/b]'")
	print("Tags found: %d" % parse4.tags.size())
	if parse4.tags.size() == 4:
		print("PASS: Multiple tags parsed")
		tests_passed += 1
	else:
		print("FAIL: Expected 4 tags")
		tests_failed += 1

	# ==========================================================================
	# VALIDATION TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("VALIDATION TESTS")
	print("=".repeat(60))

	# Test 9: Valid nesting
	print("\n--- Test 9: Valid nesting ---")
	var valid1 = formatter.validate("[b]bold[/b]")
	print("Input: '[b]bold[/b]'")
	print("Valid: %s" % valid1.valid)
	if valid1.valid:
		print("PASS: Valid nesting accepted")
		tests_passed += 1
	else:
		print("FAIL: Should be valid")
		tests_failed += 1

	# Test 10: Valid nested tags
	print("\n--- Test 10: Valid nested tags ---")
	var valid2 = formatter.validate("[b][i]text[/i][/b]")
	print("Input: '[b][i]text[/i][/b]'")
	print("Valid: %s" % valid2.valid)
	if valid2.valid:
		print("PASS: Nested tags valid")
		tests_passed += 1
	else:
		print("FAIL: Should be valid")
		tests_failed += 1

	# Test 11: Missing closing tag
	print("\n--- Test 11: Missing closing tag ---")
	var valid3 = formatter.validate("[b]unclosed")
	print("Input: '[b]unclosed'")
	print("Valid: %s" % valid3.valid)
	print("Errors: %d" % valid3.errors.size())
	for error in valid3.errors:
		print("  - %s" % error)
	if not valid3.valid and valid3.errors.size() > 0:
		print("PASS: Missing closing tag detected")
		tests_passed += 1
	else:
		print("FAIL: Should have detected error")
		tests_failed += 1

	# Test 12: Mismatched tags
	print("\n--- Test 12: Mismatched tags ---")
	var valid4 = formatter.validate("[b][i]text[/b][/i]")
	print("Input: '[b][i]text[/b][/i]'")
	print("Valid: %s" % valid4.valid)
	print("Errors: %d" % valid4.errors.size())
	for error in valid4.errors:
		print("  - %s" % error)
	if not valid4.valid:
		print("PASS: Mismatched tags detected")
		tests_passed += 1
	else:
		print("FAIL: Should have detected mismatch")
		tests_failed += 1

	# Test 13: Extra closing tag
	print("\n--- Test 13: Extra closing tag ---")
	var valid5 = formatter.validate("text[/b]")
	print("Input: 'text[/b]'")
	print("Valid: %s" % valid5.valid)
	if not valid5.valid:
		print("PASS: Extra closing tag detected")
		tests_passed += 1
	else:
		print("FAIL: Should have detected error")
		tests_failed += 1

	# Test 14: Required value missing
	print("\n--- Test 14: Required value missing ---")
	var valid6 = formatter.validate("[color]text[/color]")
	print("Input: '[color]text[/color]'")
	print("Valid: %s" % valid6.valid)
	if not valid6.valid:
		print("PASS: Missing required value detected")
		tests_passed += 1
	else:
		print("FAIL: Should have detected missing value")
		tests_failed += 1

	# Test 15: Self-closing tags don't need closing
	print("\n--- Test 15: Self-closing tags ---")
	var valid7 = formatter.validate("Text[pause=1]more text")
	print("Input: 'Text[pause=1]more text'")
	print("Valid: %s" % valid7.valid)
	if valid7.valid:
		print("PASS: Self-closing tag accepted")
		tests_passed += 1
	else:
		print("FAIL: Self-closing tags should be valid")
		tests_failed += 1

	# Test 16: Unknown tags warn but don't error
	print("\n--- Test 16: Unknown tags ---")
	var valid8 = formatter.validate("[custom]text[/custom]")
	print("Input: '[custom]text[/custom]'")
	print("Valid: %s" % valid8.valid)
	print("Warnings: %d" % valid8.warnings.size())
	for warning in valid8.warnings:
		print("  - %s" % warning)
	if valid8.valid and valid8.warnings.size() > 0:
		print("PASS: Unknown tags generate warnings")
		tests_passed += 1
	else:
		print("FAIL: Unknown tags should warn but be valid")
		tests_failed += 1

	# ==========================================================================
	# PREVIEW GENERATION TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("PREVIEW GENERATION TESTS")
	print("=".repeat(60))

	# Test 17: Standard BBCode preserved
	print("\n--- Test 17: BBCode preserved ---")
	var preview1 = formatter.generate_preview("[b]bold[/b] and [i]italic[/i]")
	print("Input: '[b]bold[/b] and [i]italic[/i]'")
	print("Preview: '%s'" % preview1)
	if "[b]" in preview1 and "[i]" in preview1:
		print("PASS: BBCode preserved in preview")
		tests_passed += 1
	else:
		print("FAIL: BBCode should be preserved")
		tests_failed += 1

	# Test 18: Game tags converted to colors
	print("\n--- Test 18: Game tags to colors ---")
	var preview2 = formatter.generate_preview("[shake]scary[/shake]")
	print("Input: '[shake]scary[/shake]'")
	print("Preview: '%s'" % preview2)
	if "[color=" in preview2 and "scary" in preview2:
		print("PASS: Game tags converted to color preview")
		tests_passed += 1
	else:
		print("FAIL: Game tags should convert to colors")
		tests_failed += 1

	# Test 19: Pause tag shows marker
	print("\n--- Test 19: Pause tag marker ---")
	var preview3 = formatter.generate_preview("Hello[pause=2]world")
	print("Input: 'Hello[pause=2]world'")
	print("Preview: '%s'" % preview3)
	if "2" in preview3 and "[color=" in preview3:
		print("PASS: Pause shows duration marker")
		tests_passed += 1
	else:
		print("FAIL: Pause should show marker")
		tests_failed += 1

	# Test 20: Strip tags
	print("\n--- Test 20: Strip tags ---")
	var stripped = formatter.strip_tags("[b]bold[/b] and [color=red]colored[/color]")
	print("Input: '[b]bold[/b] and [color=red]colored[/color]'")
	print("Stripped: '%s'" % stripped)
	if stripped == "bold and colored":
		print("PASS: Tags stripped correctly")
		tests_passed += 1
	else:
		print("FAIL: Expected 'bold and colored'")
		tests_failed += 1

	# ==========================================================================
	# UTILITY TESTS
	# ==========================================================================

	print("\n" + "=".repeat(60))
	print("UTILITY TESTS")
	print("=".repeat(60))

	# Test 21: Get visible length
	print("\n--- Test 21: Visible length ---")
	var vis_len = formatter.get_visible_length("[b]hello[/b] [color=red]world[/color]")
	print("Input: '[b]hello[/b] [color=red]world[/color]'")
	print("Visible length: %d" % vis_len)
	if vis_len == 11:  # "hello world" = 11 chars
		print("PASS: Visible length correct")
		tests_passed += 1
	else:
		print("FAIL: Expected 11 characters")
		tests_failed += 1

	# Test 22: Has game tags
	print("\n--- Test 22: Has game tags ---")
	var has_game1 = formatter.has_game_tags("[shake]text[/shake]")
	var has_game2 = formatter.has_game_tags("[b]text[/b]")
	print("'[shake]text[/shake]' has game tags: %s" % has_game1)
	print("'[b]text[/b]' has game tags: %s" % has_game2)
	if has_game1 and not has_game2:
		print("PASS: Game tag detection works")
		tests_passed += 1
	else:
		print("FAIL: Game tag detection incorrect")
		tests_failed += 1

	# Test 23: Has timing tags
	print("\n--- Test 23: Has timing tags ---")
	var has_timing1 = formatter.has_timing_tags("Hello[pause=1]world")
	var has_timing2 = formatter.has_timing_tags("[b]bold[/b]")
	print("'Hello[pause=1]world' has timing tags: %s" % has_timing1)
	print("'[b]bold[/b]' has timing tags: %s" % has_timing2)
	if has_timing1 and not has_timing2:
		print("PASS: Timing tag detection works")
		tests_passed += 1
	else:
		print("FAIL: Timing tag detection incorrect")
		tests_failed += 1

	# Test 24: Autocomplete suggestions
	print("\n--- Test 24: Autocomplete ---")
	var suggestions = formatter.get_autocomplete_suggestions("c")
	print("Suggestions for 'c': %d found" % suggestions.size())
	var found_color = false
	var found_center = false
	for s in suggestions:
		if s.name == "color":
			found_color = true
		if s.name == "center":
			found_center = true
	if found_color and found_center:
		print("PASS: Autocomplete returns relevant suggestions")
		tests_passed += 1
	else:
		print("FAIL: Missing expected suggestions")
		tests_failed += 1

	# Test 25: Export preparation
	print("\n--- Test 25: Export preparation ---")
	var export_result = formatter.prepare_for_export("[b]text[/b] [shake]effect[/shake]")
	print("Valid: %s" % export_result.valid)
	print("Tags used: %s" % str(export_result.tags_used))
	if export_result.valid and "b" in export_result.tags_used and "shake" in export_result.tags_used:
		print("PASS: Export preparation correct")
		tests_passed += 1
	else:
		print("FAIL: Export preparation incorrect")
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
