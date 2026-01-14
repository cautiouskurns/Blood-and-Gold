@tool
extends EditorScript
## Built-in Templates Generator
## Run this script from the editor (Script → Run) to regenerate the built-in template files.
## This is useful for updating templates or adding new ones.

const OUTPUT_DIR := "res://addons/dialogue_editor/data/built_in_templates/"


func _run() -> void:
	print("\n=== Generating Built-in Templates ===\n")

	# Ensure output directory exists
	if not DirAccess.dir_exists_absolute(OUTPUT_DIR):
		DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
		print("Created directory: %s" % OUTPUT_DIR)

	# Generate all templates
	_generate_basic_greeting()
	_generate_shop_interaction()
	_generate_quest_offer()
	_generate_skill_check_gate()
	_generate_information_loop()

	print("\n=== Template Generation Complete ===")
	print("Generated 5 built-in templates in: %s" % OUTPUT_DIR)


func _generate_basic_greeting() -> void:
	var template = DialogueTemplateData.create_new("Basic Greeting")
	template.description = "A simple NPC greeting with three player response options leading to different outcomes."
	template.author = "Blood & Gold Team"
	template.tags = PackedStringArray(["greeting", "conversation", "basic"])
	template.category = "conversation"
	template.is_built_in = true

	template.nodes = [
		{"id": "Start_1", "type": "Start", "position_x": -300, "position_y": 0},
		{"id": "Speaker_1", "type": "Speaker", "position_x": -100, "position_y": 0,
			"speaker": "{{SPEAKER}}", "text": "Greetings, traveler. What brings you to these parts?"},
		{"id": "Choice_1", "type": "Choice", "position_x": 150, "position_y": -100, "text": "I'm just passing through."},
		{"id": "Choice_2", "type": "Choice", "position_x": 150, "position_y": 0, "text": "I'm looking for work."},
		{"id": "Choice_3", "type": "Choice", "position_x": 150, "position_y": 100, "text": "None of your business."},
		{"id": "Speaker_2", "type": "Speaker", "position_x": 400, "position_y": -100,
			"speaker": "{{SPEAKER}}", "text": "Safe travels then. The roads can be dangerous."},
		{"id": "Speaker_3", "type": "Speaker", "position_x": 400, "position_y": 0,
			"speaker": "{{SPEAKER}}", "text": "Work, you say? There might be something..."},
		{"id": "Speaker_4", "type": "Speaker", "position_x": 400, "position_y": 100,
			"speaker": "{{SPEAKER}}", "text": "Hmph. Suit yourself, stranger."},
		{"id": "End_1", "type": "End", "position_x": 650, "position_y": -100, "end_type": "normal"},
		{"id": "End_2", "type": "End", "position_x": 650, "position_y": 0, "end_type": "normal"},
		{"id": "End_3", "type": "End", "position_x": 650, "position_y": 100, "end_type": "normal"}
	]

	template.connections = [
		{"from_node": "Start_1", "from_port": 0, "to_node": "Speaker_1", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_1", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_2", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_3", "to_port": 0},
		{"from_node": "Choice_1", "from_port": 0, "to_node": "Speaker_2", "to_port": 0},
		{"from_node": "Choice_2", "from_port": 0, "to_node": "Speaker_3", "to_port": 0},
		{"from_node": "Choice_3", "from_port": 0, "to_node": "Speaker_4", "to_port": 0},
		{"from_node": "Speaker_2", "from_port": 0, "to_node": "End_1", "to_port": 0},
		{"from_node": "Speaker_3", "from_port": 0, "to_node": "End_2", "to_port": 0},
		{"from_node": "Speaker_4", "from_port": 0, "to_node": "End_3", "to_port": 0}
	]

	template.placeholders = [
		{"name": "SPEAKER", "description": "The NPC speaker name", "default": "Villager"}
	]

	template.node_count = template.nodes.size()
	template._generate_preview_description()

	var path = OUTPUT_DIR + "basic_greeting.dttemplate"
	var err = template.save_to_file(path)
	if err == OK:
		print("  ✓ Generated: basic_greeting.dttemplate")
	else:
		print("  ✗ Failed to generate: basic_greeting.dttemplate (error: %d)" % err)


func _generate_shop_interaction() -> void:
	var template = DialogueTemplateData.create_new("Shop Interaction")
	template.description = "Standard shop dialogue with buy, sell, browse, and leave options. Perfect for merchants and vendors."
	template.author = "Blood & Gold Team"
	template.tags = PackedStringArray(["shop", "merchant", "trade", "conversation"])
	template.category = "shop"
	template.is_built_in = true

	template.nodes = [
		{"id": "Speaker_1", "type": "Speaker", "position_x": -200, "position_y": 0,
			"speaker": "{{MERCHANT}}", "text": "Welcome to my shop! Take a look around. What can I help you with today?"},
		{"id": "Choice_Buy", "type": "Choice", "position_x": 50, "position_y": -150, "text": "I'd like to buy something."},
		{"id": "Choice_Sell", "type": "Choice", "position_x": 50, "position_y": -50, "text": "I have items to sell."},
		{"id": "Choice_Browse", "type": "Choice", "position_x": 50, "position_y": 50, "text": "Just browsing for now."},
		{"id": "Choice_Leave", "type": "Choice", "position_x": 50, "position_y": 150, "text": "Never mind, I'll be going."},
		{"id": "Speaker_Buy", "type": "Speaker", "position_x": 300, "position_y": -150,
			"speaker": "{{MERCHANT}}", "text": "Excellent! Here's what I have in stock..."},
		{"id": "Speaker_Sell", "type": "Speaker", "position_x": 300, "position_y": -50,
			"speaker": "{{MERCHANT}}", "text": "Let me see what you've got. I pay fair prices."},
		{"id": "Speaker_Browse", "type": "Speaker", "position_x": 300, "position_y": 50,
			"speaker": "{{MERCHANT}}", "text": "Of course, take your time. Let me know if anything catches your eye."},
		{"id": "Speaker_Leave", "type": "Speaker", "position_x": 300, "position_y": 150,
			"speaker": "{{MERCHANT}}", "text": "Come back anytime! Safe travels."},
		{"id": "End_Buy", "type": "End", "position_x": 550, "position_y": -150, "end_type": "open_shop_buy"},
		{"id": "End_Sell", "type": "End", "position_x": 550, "position_y": -50, "end_type": "open_shop_sell"},
		{"id": "End_Browse", "type": "End", "position_x": 550, "position_y": 50, "end_type": "open_shop_browse"},
		{"id": "End_Leave", "type": "End", "position_x": 550, "position_y": 150, "end_type": "normal"}
	]

	template.connections = [
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_Buy", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_Sell", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_Browse", "to_port": 0},
		{"from_node": "Speaker_1", "from_port": 0, "to_node": "Choice_Leave", "to_port": 0},
		{"from_node": "Choice_Buy", "from_port": 0, "to_node": "Speaker_Buy", "to_port": 0},
		{"from_node": "Choice_Sell", "from_port": 0, "to_node": "Speaker_Sell", "to_port": 0},
		{"from_node": "Choice_Browse", "from_port": 0, "to_node": "Speaker_Browse", "to_port": 0},
		{"from_node": "Choice_Leave", "from_port": 0, "to_node": "Speaker_Leave", "to_port": 0},
		{"from_node": "Speaker_Buy", "from_port": 0, "to_node": "End_Buy", "to_port": 0},
		{"from_node": "Speaker_Sell", "from_port": 0, "to_node": "End_Sell", "to_port": 0},
		{"from_node": "Speaker_Browse", "from_port": 0, "to_node": "End_Browse", "to_port": 0},
		{"from_node": "Speaker_Leave", "from_port": 0, "to_node": "End_Leave", "to_port": 0}
	]

	template.placeholders = [
		{"name": "MERCHANT", "description": "The merchant/vendor name", "default": "Merchant"}
	]

	template.node_count = template.nodes.size()
	template._generate_preview_description()

	var path = OUTPUT_DIR + "shop_interaction.dttemplate"
	var err = template.save_to_file(path)
	if err == OK:
		print("  ✓ Generated: shop_interaction.dttemplate")
	else:
		print("  ✗ Failed to generate: shop_interaction.dttemplate (error: %d)" % err)


func _generate_quest_offer() -> void:
	var template = DialogueTemplateData.create_new("Quest Offer")
	template.description = "NPC offers a quest with accept/decline options. Includes quest start/update nodes for tracking."
	template.author = "Blood & Gold Team"
	template.tags = PackedStringArray(["quest", "mission", "job", "conversation"])
	template.category = "quest"
	template.is_built_in = true

	template.nodes = [
		{"id": "Speaker_Intro", "type": "Speaker", "position_x": -250, "position_y": 0,
			"speaker": "{{QUEST_GIVER}}", "text": "I have a task that requires someone capable. Are you interested in earning some coin?"},
		{"id": "Choice_Interested", "type": "Choice", "position_x": 0, "position_y": -50, "text": "I'm listening. What do you need?"},
		{"id": "Choice_NotNow", "type": "Choice", "position_x": 0, "position_y": 50, "text": "Not right now, sorry."},
		{"id": "Speaker_Details", "type": "Speaker", "position_x": 250, "position_y": -50,
			"speaker": "{{QUEST_GIVER}}", "text": "{{QUEST_DESCRIPTION}} The pay is good. What do you say?"},
		{"id": "Speaker_Decline1", "type": "Speaker", "position_x": 250, "position_y": 50,
			"speaker": "{{QUEST_GIVER}}", "text": "I understand. Come back if you change your mind."},
		{"id": "Choice_Accept", "type": "Choice", "position_x": 500, "position_y": -100, "text": "Count me in. I'll take the job."},
		{"id": "Choice_Decline2", "type": "Choice", "position_x": 500, "position_y": 0, "text": "I'll have to pass on this one."},
		{"id": "Quest_Start", "type": "Quest", "position_x": 750, "position_y": -100, "quest_id": "{{QUEST_ID}}", "action": "start"},
		{"id": "Speaker_Accept", "type": "Speaker", "position_x": 1000, "position_y": -100,
			"speaker": "{{QUEST_GIVER}}", "text": "Excellent! I knew I could count on you. Here are the details..."},
		{"id": "Speaker_Decline2", "type": "Speaker", "position_x": 750, "position_y": 0,
			"speaker": "{{QUEST_GIVER}}", "text": "A shame, but I understand. Perhaps another time."},
		{"id": "End_Accept", "type": "End", "position_x": 1250, "position_y": -100, "end_type": "quest_started"},
		{"id": "End_Decline", "type": "End", "position_x": 1000, "position_y": 0, "end_type": "normal"},
		{"id": "End_NotNow", "type": "End", "position_x": 500, "position_y": 50, "end_type": "normal"}
	]

	template.connections = [
		{"from_node": "Speaker_Intro", "from_port": 0, "to_node": "Choice_Interested", "to_port": 0},
		{"from_node": "Speaker_Intro", "from_port": 0, "to_node": "Choice_NotNow", "to_port": 0},
		{"from_node": "Choice_Interested", "from_port": 0, "to_node": "Speaker_Details", "to_port": 0},
		{"from_node": "Choice_NotNow", "from_port": 0, "to_node": "Speaker_Decline1", "to_port": 0},
		{"from_node": "Speaker_Details", "from_port": 0, "to_node": "Choice_Accept", "to_port": 0},
		{"from_node": "Speaker_Details", "from_port": 0, "to_node": "Choice_Decline2", "to_port": 0},
		{"from_node": "Speaker_Decline1", "from_port": 0, "to_node": "End_NotNow", "to_port": 0},
		{"from_node": "Choice_Accept", "from_port": 0, "to_node": "Quest_Start", "to_port": 0},
		{"from_node": "Quest_Start", "from_port": 0, "to_node": "Speaker_Accept", "to_port": 0},
		{"from_node": "Choice_Decline2", "from_port": 0, "to_node": "Speaker_Decline2", "to_port": 0},
		{"from_node": "Speaker_Accept", "from_port": 0, "to_node": "End_Accept", "to_port": 0},
		{"from_node": "Speaker_Decline2", "from_port": 0, "to_node": "End_Decline", "to_port": 0}
	]

	template.placeholders = [
		{"name": "QUEST_GIVER", "description": "The NPC offering the quest", "default": "Quest Giver"},
		{"name": "QUEST_ID", "description": "Unique identifier for the quest", "default": "quest_example"},
		{"name": "QUEST_DESCRIPTION", "description": "Brief description of the quest objective",
			"default": "I need you to retrieve an important item from the nearby ruins."}
	]

	template.node_count = template.nodes.size()
	template._generate_preview_description()

	var path = OUTPUT_DIR + "quest_offer.dttemplate"
	var err = template.save_to_file(path)
	if err == OK:
		print("  ✓ Generated: quest_offer.dttemplate")
	else:
		print("  ✗ Failed to generate: quest_offer.dttemplate (error: %d)" % err)


func _generate_skill_check_gate() -> void:
	var template = DialogueTemplateData.create_new("Skill Check Gate")
	template.description = "A dialogue gate that requires passing a skill check to proceed. Includes success and failure branches."
	template.author = "Blood & Gold Team"
	template.tags = PackedStringArray(["skill", "check", "gate", "branch", "combat"])
	template.category = "combat"
	template.is_built_in = true

	template.nodes = [
		{"id": "Speaker_Challenge", "type": "Speaker", "position_x": -250, "position_y": 0,
			"speaker": "{{NPC}}", "text": "{{CHALLENGE_TEXT}}"},
		{"id": "Choice_Attempt", "type": "Choice", "position_x": 0, "position_y": -50,
			"text": "[{{SKILL_NAME}}] {{ATTEMPT_TEXT}}"},
		{"id": "Choice_Decline", "type": "Choice", "position_x": 0, "position_y": 50,
			"text": "I'd rather not risk it."},
		{"id": "SkillCheck_1", "type": "SkillCheck", "position_x": 250, "position_y": -50,
			"skill": "{{SKILL_NAME}}", "difficulty": 12},
		{"id": "Speaker_Success", "type": "Speaker", "position_x": 500, "position_y": -100,
			"speaker": "{{NPC}}", "text": "{{SUCCESS_TEXT}}"},
		{"id": "Speaker_Failure", "type": "Speaker", "position_x": 500, "position_y": 0,
			"speaker": "{{NPC}}", "text": "{{FAILURE_TEXT}}"},
		{"id": "Speaker_Decline", "type": "Speaker", "position_x": 250, "position_y": 50,
			"speaker": "{{NPC}}", "text": "Very well. Perhaps another approach then."},
		{"id": "End_Success", "type": "End", "position_x": 750, "position_y": -100, "end_type": "skill_success"},
		{"id": "End_Failure", "type": "End", "position_x": 750, "position_y": 0, "end_type": "skill_failure"},
		{"id": "End_Decline", "type": "End", "position_x": 500, "position_y": 50, "end_type": "normal"}
	]

	template.connections = [
		{"from_node": "Speaker_Challenge", "from_port": 0, "to_node": "Choice_Attempt", "to_port": 0},
		{"from_node": "Speaker_Challenge", "from_port": 0, "to_node": "Choice_Decline", "to_port": 0},
		{"from_node": "Choice_Attempt", "from_port": 0, "to_node": "SkillCheck_1", "to_port": 0},
		{"from_node": "SkillCheck_1", "from_port": 0, "to_node": "Speaker_Success", "to_port": 0},
		{"from_node": "SkillCheck_1", "from_port": 1, "to_node": "Speaker_Failure", "to_port": 0},
		{"from_node": "Choice_Decline", "from_port": 0, "to_node": "Speaker_Decline", "to_port": 0},
		{"from_node": "Speaker_Success", "from_port": 0, "to_node": "End_Success", "to_port": 0},
		{"from_node": "Speaker_Failure", "from_port": 0, "to_node": "End_Failure", "to_port": 0},
		{"from_node": "Speaker_Decline", "from_port": 0, "to_node": "End_Decline", "to_port": 0}
	]

	template.placeholders = [
		{"name": "NPC", "description": "The NPC presenting the challenge", "default": "Guard"},
		{"name": "SKILL_NAME", "description": "The skill being tested (e.g., Persuasion, Intimidation, Stealth)",
			"default": "Persuasion"},
		{"name": "CHALLENGE_TEXT", "description": "The NPC's challenge or obstacle",
			"default": "This area is restricted. You'll need to convince me you belong here."},
		{"name": "ATTEMPT_TEXT", "description": "The player's attempt text", "default": "Try to convince them."},
		{"name": "SUCCESS_TEXT", "description": "What the NPC says on success",
			"default": "Hmm, I suppose you're right. Go ahead."},
		{"name": "FAILURE_TEXT", "description": "What the NPC says on failure",
			"default": "Nice try, but I'm not buying it. Move along."}
	]

	template.node_count = template.nodes.size()
	template._generate_preview_description()

	var path = OUTPUT_DIR + "skill_check_gate.dttemplate"
	var err = template.save_to_file(path)
	if err == OK:
		print("  ✓ Generated: skill_check_gate.dttemplate")
	else:
		print("  ✗ Failed to generate: skill_check_gate.dttemplate (error: %d)" % err)


func _generate_information_loop() -> void:
	var template = DialogueTemplateData.create_new("Information Loop")
	template.description = "A dialogue menu where the player can ask multiple questions before leaving. Questions loop back to the menu."
	template.author = "Blood & Gold Team"
	template.tags = PackedStringArray(["information", "questions", "loop", "menu", "conversation"])
	template.category = "conversation"
	template.is_built_in = true

	template.nodes = [
		{"id": "Speaker_Menu", "type": "Speaker", "position_x": 0, "position_y": 0,
			"speaker": "{{NPC}}", "text": "What would you like to know?"},
		{"id": "Choice_Q1", "type": "Choice", "position_x": 250, "position_y": -150, "text": "{{QUESTION_1}}"},
		{"id": "Choice_Q2", "type": "Choice", "position_x": 250, "position_y": -50, "text": "{{QUESTION_2}}"},
		{"id": "Choice_Q3", "type": "Choice", "position_x": 250, "position_y": 50, "text": "{{QUESTION_3}}"},
		{"id": "Choice_Exit", "type": "Choice", "position_x": 250, "position_y": 150, "text": "That's all I needed to know."},
		{"id": "Speaker_A1", "type": "Speaker", "position_x": 500, "position_y": -150,
			"speaker": "{{NPC}}", "text": "{{ANSWER_1}}"},
		{"id": "Speaker_A2", "type": "Speaker", "position_x": 500, "position_y": -50,
			"speaker": "{{NPC}}", "text": "{{ANSWER_2}}"},
		{"id": "Speaker_A3", "type": "Speaker", "position_x": 500, "position_y": 50,
			"speaker": "{{NPC}}", "text": "{{ANSWER_3}}"},
		{"id": "Speaker_Exit", "type": "Speaker", "position_x": 500, "position_y": 150,
			"speaker": "{{NPC}}", "text": "Safe travels, then. Come back if you have more questions."},
		{"id": "Speaker_Followup", "type": "Speaker", "position_x": 750, "position_y": -50,
			"speaker": "{{NPC}}", "text": "Anything else you'd like to know?"},
		{"id": "End_Exit", "type": "End", "position_x": 750, "position_y": 150, "end_type": "normal"}
	]

	template.connections = [
		{"from_node": "Speaker_Menu", "from_port": 0, "to_node": "Choice_Q1", "to_port": 0},
		{"from_node": "Speaker_Menu", "from_port": 0, "to_node": "Choice_Q2", "to_port": 0},
		{"from_node": "Speaker_Menu", "from_port": 0, "to_node": "Choice_Q3", "to_port": 0},
		{"from_node": "Speaker_Menu", "from_port": 0, "to_node": "Choice_Exit", "to_port": 0},
		{"from_node": "Choice_Q1", "from_port": 0, "to_node": "Speaker_A1", "to_port": 0},
		{"from_node": "Choice_Q2", "from_port": 0, "to_node": "Speaker_A2", "to_port": 0},
		{"from_node": "Choice_Q3", "from_port": 0, "to_node": "Speaker_A3", "to_port": 0},
		{"from_node": "Choice_Exit", "from_port": 0, "to_node": "Speaker_Exit", "to_port": 0},
		{"from_node": "Speaker_A1", "from_port": 0, "to_node": "Speaker_Followup", "to_port": 0},
		{"from_node": "Speaker_A2", "from_port": 0, "to_node": "Speaker_Followup", "to_port": 0},
		{"from_node": "Speaker_A3", "from_port": 0, "to_node": "Speaker_Followup", "to_port": 0},
		{"from_node": "Speaker_Followup", "from_port": 0, "to_node": "Choice_Q1", "to_port": 0},
		{"from_node": "Speaker_Followup", "from_port": 0, "to_node": "Choice_Q2", "to_port": 0},
		{"from_node": "Speaker_Followup", "from_port": 0, "to_node": "Choice_Q3", "to_port": 0},
		{"from_node": "Speaker_Followup", "from_port": 0, "to_node": "Choice_Exit", "to_port": 0},
		{"from_node": "Speaker_Exit", "from_port": 0, "to_node": "End_Exit", "to_port": 0}
	]

	template.placeholders = [
		{"name": "NPC", "description": "The informant NPC name", "default": "Informant"},
		{"name": "QUESTION_1", "description": "First question option", "default": "Tell me about this place."},
		{"name": "ANSWER_1", "description": "Answer to the first question",
			"default": "This is an ancient settlement. Many stories are told of the things that happened here."},
		{"name": "QUESTION_2", "description": "Second question option", "default": "Who's in charge around here?"},
		{"name": "ANSWER_2", "description": "Answer to the second question",
			"default": "The local lord oversees these lands. You'll find the keep on the hill to the north."},
		{"name": "QUESTION_3", "description": "Third question option", "default": "Any dangers I should know about?"},
		{"name": "ANSWER_3", "description": "Answer to the third question",
			"default": "Bandits have been spotted on the eastern roads. Best travel in groups if you're heading that way."}
	]

	template.node_count = template.nodes.size()
	template._generate_preview_description()

	var path = OUTPUT_DIR + "information_loop.dttemplate"
	var err = template.save_to_file(path)
	if err == OK:
		print("  ✓ Generated: information_loop.dttemplate")
	else:
		print("  ✗ Failed to generate: information_loop.dttemplate (error: %d)" % err)
