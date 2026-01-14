@tool
extends EditorScript
## Run this script from the Godot editor: Script → Run (Ctrl+Shift+X)
## Tests the template system functionality.


func _run() -> void:
	print("\n=== Template System Test ===\n")

	# Test 1: Get manager instance
	print("Test 1: Getting TemplateManager instance...")
	var manager = DialogueTemplateManager.get_instance()
	if manager:
		print("  ✓ Manager instance created")
	else:
		print("  ✗ Failed to create manager")
		return

	# Test 2: Check built-in templates loaded
	print("\nTest 2: Checking built-in templates...")
	var built_in = manager.get_built_in_templates()
	print("  Found %d built-in template(s)" % built_in.size())
	for template in built_in:
		print("    - %s (%d nodes)" % [template.template_name, template.node_count])

	# Test 3: Get specific template
	print("\nTest 3: Loading 'Basic Greeting' template...")
	var greeting = manager.get_template("Basic Greeting")
	if greeting:
		print("  ✓ Template loaded")
		print("    Name: %s" % greeting.template_name)
		print("    Description: %s" % greeting.description)
		print("    Category: %s" % greeting.category)
		print("    Nodes: %d" % greeting.nodes.size())
		print("    Connections: %d" % greeting.connections.size())
		print("    Placeholders: %s" % str(greeting.placeholders))
	else:
		print("  ✗ Template not found")

	# Test 4: Create a new template programmatically
	print("\nTest 4: Creating template programmatically...")
	var new_template = DialogueTemplateData.create_new("Test Template")
	new_template.description = "A test template created by script"
	new_template.category = "test"
	new_template.author = "Test Script"

	# Add some mock nodes
	new_template.nodes = [
		{"id": "Start_1", "type": "Start", "position_x": 0, "position_y": 0},
		{"id": "Speaker_1", "type": "Speaker", "position_x": 200, "position_y": 0, "speaker": "NPC", "text": "Hello!"},
		{"id": "End_1", "type": "End", "position_x": 400, "position_y": 0}
	]
	new_template.connections = [
		{"from_node": "Start_1", "from_port": 0, "to_node": "Speaker_1", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "End_1", "to_port": 0}
	]
	new_template.node_count = 3
	new_template._generate_preview_description()

	print("  ✓ Template created: %s" % new_template.template_name)
	print("    Preview: %s" % new_template.preview_description)

	# Test 5: Validate template
	print("\nTest 5: Validating template...")
	var validation = new_template.validate()
	if validation.valid:
		print("  ✓ Template is valid")
	else:
		print("  ✗ Template invalid: %s" % str(validation.errors))

	# Test 6: Save template (to user directory)
	print("\nTest 6: Saving template to user directory...")
	var save_err = manager.save_template(new_template)
	if save_err == OK:
		print("  ✓ Template saved successfully")
		print("    Path: %s" % manager.get_template_path("Test Template"))
	else:
		print("  ✗ Save failed with error: %d" % save_err)

	# Test 7: Verify it's now in user templates
	print("\nTest 7: Verifying user templates...")
	var user_templates = manager.get_user_templates()
	print("  Found %d user template(s)" % user_templates.size())
	for template in user_templates:
		print("    - %s" % template.template_name)

	# Test 8: Test search
	print("\nTest 8: Testing search...")
	var search_results = manager.search_templates("greeting")
	print("  Search 'greeting' found %d result(s)" % search_results.size())
	for result in search_results:
		print("    - %s" % result.template_name)

	# Test 9: Get categories
	print("\nTest 9: Getting categories...")
	var categories = manager.get_categories()
	print("  Categories: %s" % str(Array(categories)))

	# Test 10: Clean up - delete test template
	print("\nTest 10: Cleaning up (deleting test template)...")
	var delete_err = manager.delete_template("Test Template")
	if delete_err == OK:
		print("  ✓ Test template deleted")
	else:
		print("  ✗ Delete failed with error: %d" % delete_err)

	# Final summary
	print("\n=== Test Complete ===")
	print("All templates: %d" % manager.get_all_templates().size())
	print("Built-in: %d" % manager.get_built_in_templates().size())
	print("User: %d" % manager.get_user_templates().size())
