## Contract - Resource class defining contract/mission properties
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.2-contract-board-ui.md
class_name Contract
extends Resource

# ===== ENUMS =====
enum Difficulty {
	EASY,    # 1 star - Tutorial/introductory
	MEDIUM,  # 2 stars - Standard challenge
	HARD,    # 3 stars - Tough fight
}

enum ContractType {
	TUTORIAL,   # Merchant's Escort - guided experience
	COMBAT,     # Clear the Ruins - straightforward battle
	CHOICE,     # Border Dispute - moral/strategic decision
}

# ===== EXPORTED PROPERTIES =====
@export var id: String = ""
@export var display_name: String = ""
@export var brief_description: String = ""  # Short description for card (1-2 lines)
@export_multiline var full_briefing: String = ""  # Full mission briefing

@export var difficulty: Difficulty = Difficulty.MEDIUM
@export var contract_type: ContractType = ContractType.COMBAT

# Objectives
@export var primary_objective: String = ""
@export var secondary_objective: String = ""

# Rewards
@export var gold_reward: int = 0
@export var gold_reward_max: int = 0  # For variable rewards (Border Dispute), 0 = use gold_reward
@export var bonus_reward_description: String = ""  # e.g., "Steel Sword if cache found"

# Combat setup
@export var map_scene: String = ""  # Path to combat map scene, e.g., "res://scenes/combat/maps/ForestClearing.tscn"
@export var enemy_description: String = ""  # e.g., "Bandits (estimated 6)"
@export var enemy_count: int = 0

# Pre-combat scene (for choice contracts)
@export var has_pre_combat_dialogue: bool = false
@export var pre_combat_scene: String = ""  # Path to dialogue/choice scene

# Post-combat camp scene
@export var triggers_camp_scene: bool = false
@export var camp_scene_id: String = ""  # ID for which camp scene to trigger

# ===== COMPUTED PROPERTIES =====
func get_difficulty_stars() -> String:
	## Returns difficulty as star string (★☆☆, ★★☆, ★★★)
	match difficulty:
		Difficulty.EASY:
			return "★☆☆"
		Difficulty.MEDIUM:
			return "★★☆"
		Difficulty.HARD:
			return "★★★"
		_:
			return "★☆☆"

func get_difficulty_color() -> Color:
	## Returns color for difficulty indicator
	match difficulty:
		Difficulty.EASY:
			return Color("#27ae60")  # Green
		Difficulty.MEDIUM:
			return Color("#f39c12")  # Yellow/Orange
		Difficulty.HARD:
			return Color("#e74c3c")  # Red
		_:
			return Color("#27ae60")

func get_reward_display() -> String:
	## Returns formatted reward string
	if gold_reward_max > 0 and gold_reward_max != gold_reward:
		return "%d-%dg" % [gold_reward, gold_reward_max]
	return "%dg" % gold_reward

func get_difficulty_name() -> String:
	## Returns difficulty as readable string
	match difficulty:
		Difficulty.EASY:
			return "Easy"
		Difficulty.MEDIUM:
			return "Medium"
		Difficulty.HARD:
			return "Hard"
		_:
			return "Unknown"

# ===== METHODS =====
func get_objectives_text() -> String:
	## Returns formatted objectives text
	var text = ""
	if primary_objective:
		text += "PRIMARY: %s" % primary_objective
	if secondary_objective:
		text += "\nSECONDARY: %s" % secondary_objective
	return text

func get_map_scene_name() -> String:
	## Extract map name from scene path
	if map_scene.is_empty():
		return "Unknown"
	var filename = map_scene.get_file().get_basename()
	# Convert PascalCase to readable format
	return filename.capitalize().replace("_", " ")
