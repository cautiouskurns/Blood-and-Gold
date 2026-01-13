## GameState - Global game state management (gold, progression, saves)
## Part of: Blood & Gold Prototype
## Task 3.1: Main Hub Scene Structure
extends Node

# ===== SIGNALS =====
signal gold_changed(new_amount: int)
signal screen_changed(screen_name: String)

# ===== CONSTANTS =====
const STARTING_GOLD: int = 500

# Screen identifiers
enum Screen {
	HUB,
	CONTRACTS,
	BARRACKS,
	MERCHANT,
	CAMP,
	COMBAT
}

# ===== STATE =====
var gold: int = STARTING_GOLD
var current_screen: Screen = Screen.HUB

# Company state (for future tasks)
var company_name: String = "The Iron Company"
var completed_contracts: int = 0
var days_passed: int = 0

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[GameState] Initialized with %d gold" % gold)

# ===== GOLD MANAGEMENT =====
func add_gold(amount: int) -> void:
	## Add gold to the company treasury
	gold += amount
	gold_changed.emit(gold)
	print("[GameState] Gold +%d (Total: %d)" % [amount, gold])

func spend_gold(amount: int) -> bool:
	## Spend gold, returns false if insufficient funds
	if gold < amount:
		print("[GameState] Insufficient gold! Have %d, need %d" % [gold, amount])
		return false
	gold -= amount
	gold_changed.emit(gold)
	print("[GameState] Gold -%d (Total: %d)" % [amount, gold])
	return true

func can_afford(amount: int) -> bool:
	## Check if company can afford an amount
	return gold >= amount

func get_gold() -> int:
	return gold

func set_gold(amount: int) -> void:
	## Set gold directly (for loading saves)
	gold = amount
	gold_changed.emit(gold)

# ===== SCREEN NAVIGATION =====
func change_screen(screen: Screen) -> void:
	## Change to a different screen
	current_screen = screen
	var screen_name = Screen.keys()[screen]
	screen_changed.emit(screen_name)
	print("[GameState] Screen changed to: %s" % screen_name)

func get_current_screen() -> Screen:
	return current_screen

func get_screen_name() -> String:
	return Screen.keys()[current_screen]

# ===== PROGRESSION =====
func complete_contract(gold_reward: int) -> void:
	## Called when a contract is completed
	completed_contracts += 1
	add_gold(gold_reward)
	print("[GameState] Contract completed! Total: %d" % completed_contracts)

func advance_day() -> void:
	## Advance to the next day
	days_passed += 1
	print("[GameState] Day %d" % days_passed)

# ===== SAVE/LOAD (placeholder for future) =====
func get_save_data() -> Dictionary:
	## Get save data dictionary
	return {
		"gold": gold,
		"company_name": company_name,
		"completed_contracts": completed_contracts,
		"days_passed": days_passed
	}

func load_save_data(data: Dictionary) -> void:
	## Load from save data dictionary
	gold = data.get("gold", STARTING_GOLD)
	company_name = data.get("company_name", "The Iron Company")
	completed_contracts = data.get("completed_contracts", 0)
	days_passed = data.get("days_passed", 0)
	gold_changed.emit(gold)
	print("[GameState] Save data loaded")

func reset_to_new_game() -> void:
	## Reset all state for a new game
	gold = STARTING_GOLD
	company_name = "The Iron Company"
	completed_contracts = 0
	days_passed = 0
	current_screen = Screen.HUB
	gold_changed.emit(gold)
	print("[GameState] Reset to new game")
