## GameState - Global game state management (gold, progression, saves)
## Part of: Blood & Gold Prototype
## Task 3.1: Main Hub Scene Structure
## Updated: Task 3.2 - Contract Board UI (contract tracking)
## Updated: Task 3.5 - Border Dispute (choice tracking)
extends Node

# ===== SIGNALS =====
signal gold_changed(new_amount: int)
signal screen_changed(screen_name: String)
signal active_contract_changed(contract: Contract)
signal contract_completed(contract: Contract)
signal contracts_updated()
signal choice_made(contract_id: String, choice_id: String)
signal upgrade_purchased(upgrade_id: String)
signal soldiers_changed()
signal equipment_changed(character_id: String, slot: String, equipment_id: String)

# ===== CONSTANTS =====
const STARTING_GOLD: int = 500

# Screen identifiers
enum Screen {
	HUB,
	CONTRACTS,
	BARRACKS,
	MERCHANT,
	CAMP,
	FORT,
	COMBAT
}

# ===== STATE =====
var gold: int = STARTING_GOLD
var current_screen: Screen = Screen.HUB

# Company state (for future tasks)
var company_name: String = "The Iron Company"
var completed_contracts: int = 0
var days_passed: int = 0

# ===== CONTRACT STATE =====
# Contract resource paths
const CONTRACT_PATHS: Array[String] = [
	"res://resources/contracts/merchants_escort.tres",
	"res://resources/contracts/clear_the_ruins.tres",
	"res://resources/contracts/border_dispute.tres",
]

# All loaded contracts
var all_contracts: Array[Contract] = []

# IDs of contracts available for selection
var available_contract_ids: Array[String] = []

# IDs of completed contracts (won't appear again)
var completed_contract_ids: Array[String] = []

# Currently active contract (player has accepted, not yet completed)
var active_contract: Contract = null

# ===== CHOICE TRACKING =====
# Tracks choices made in choice contracts for narrative continuity
# Format: {"contract_id": "choice_id", ...}
var contract_choices: Dictionary = {}

# ===== FORT UPGRADES =====
# Purchased fort upgrades (barracks, training_yard, tavern)
var fort_upgrades: Array[String] = []

# Upgrade effects - these affect other systems
var max_party_size: int = 4  # Default, +4 from Barracks
var xp_multiplier: float = 1.0  # Default, 1.5 with Training Yard
var recruitment_quality_bonus: bool = false  # True with Tavern

# ===== SOLDIER ROSTER =====
# Array of soldier type strings: ["infantry", "archer", "infantry"]
var soldiers: Array[String] = []

# ===== CHARACTER EQUIPMENT =====
# Equipment for party members: {character_id: {weapon: "equipment_id", armor: "equipment_id"}}
var character_equipment: Dictionary = {
	"player": {"weapon": "", "armor": ""},
	"thorne": {"weapon": "", "armor": ""},
	"lyra": {"weapon": "", "armor": ""},
	"matthias": {"weapon": "", "armor": ""},
}

# ===== LIFECYCLE =====
func _ready() -> void:
	_load_contracts()
	print("[GameState] Initialized with %d gold" % gold)

func _load_contracts() -> void:
	## Load all contract resources from disk
	all_contracts.clear()
	available_contract_ids.clear()

	for path in CONTRACT_PATHS:
		if ResourceLoader.exists(path):
			var contract = load(path) as Contract
			if contract:
				all_contracts.append(contract)
				available_contract_ids.append(contract.id)
				print("[GameState] Loaded contract: %s" % contract.display_name)
			else:
				push_warning("[GameState] Failed to load contract: %s" % path)
		else:
			push_warning("[GameState] Contract file not found: %s" % path)

	print("[GameState] Loaded %d contracts" % all_contracts.size())

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

# ===== CONTRACT MANAGEMENT =====
func get_available_contracts() -> Array[Contract]:
	## Returns contracts that are available for selection (not active, not completed)
	var available: Array[Contract] = []
	for contract in all_contracts:
		if contract.id in available_contract_ids and contract.id not in completed_contract_ids:
			if active_contract == null or active_contract.id != contract.id:
				available.append(contract)
	return available

func get_contract_by_id(id: String) -> Contract:
	## Find a contract by its ID
	for contract in all_contracts:
		if contract.id == id:
			return contract
	return null

func accept_contract(contract: Contract) -> bool:
	## Accept a contract and make it active
	if active_contract != null:
		push_warning("[GameState] Cannot accept contract: already have active contract")
		return false

	if contract.id in completed_contract_ids:
		push_warning("[GameState] Cannot accept contract: already completed")
		return false

	active_contract = contract

	# Remove from available list
	var idx = available_contract_ids.find(contract.id)
	if idx >= 0:
		available_contract_ids.remove_at(idx)

	active_contract_changed.emit(active_contract)
	contracts_updated.emit()
	print("[GameState] Contract accepted: %s" % contract.display_name)
	return true

func complete_current_contract(gold_reward: int) -> void:
	## Mark the current active contract as completed
	if active_contract == null:
		push_warning("[GameState] No active contract to complete")
		return

	var contract = active_contract
	completed_contract_ids.append(contract.id)
	completed_contracts += 1

	# Add gold reward
	add_gold(gold_reward)

	# Clear active contract
	active_contract = null

	contract_completed.emit(contract)
	active_contract_changed.emit(null)
	contracts_updated.emit()
	print("[GameState] Contract completed: %s (+%dg)" % [contract.display_name, gold_reward])

func has_active_contract() -> bool:
	## Check if there is an active contract
	return active_contract != null

func get_active_contract() -> Contract:
	## Get the currently active contract
	return active_contract

func cancel_active_contract() -> void:
	## Cancel the active contract (return it to available)
	if active_contract == null:
		return

	# Return to available
	if active_contract.id not in available_contract_ids:
		available_contract_ids.append(active_contract.id)

	active_contract = null
	active_contract_changed.emit(null)
	contracts_updated.emit()
	print("[GameState] Active contract cancelled")

func are_all_contracts_completed() -> bool:
	## Check if all contracts have been completed
	return completed_contract_ids.size() >= all_contracts.size()

# ===== CHOICE TRACKING =====
func record_choice(contract_id: String, choice_id: String) -> void:
	## Record a choice made during a choice contract
	contract_choices[contract_id] = choice_id
	choice_made.emit(contract_id, choice_id)
	print("[GameState] Choice recorded: %s -> %s" % [contract_id, choice_id])

func get_choice(contract_id: String) -> String:
	## Get the choice made for a specific contract
	return contract_choices.get(contract_id, "")

func has_made_choice(contract_id: String) -> bool:
	## Check if a choice was made for a contract
	return contract_id in contract_choices

func get_all_choices() -> Dictionary:
	## Get all recorded choices
	return contract_choices.duplicate()

# ===== FORT UPGRADE MANAGEMENT =====
func has_upgrade(upgrade_id: String) -> bool:
	## Check if a fort upgrade has been purchased
	return upgrade_id in fort_upgrades

func add_upgrade(upgrade_id: String) -> void:
	## Add a fort upgrade and apply its effect
	if has_upgrade(upgrade_id):
		push_warning("[GameState] Upgrade already owned: %s" % upgrade_id)
		return

	fort_upgrades.append(upgrade_id)
	_apply_upgrade_effect(upgrade_id)
	upgrade_purchased.emit(upgrade_id)
	print("[GameState] Upgrade purchased: %s" % upgrade_id)

func _apply_upgrade_effect(upgrade_id: String) -> void:
	## Apply the effect of a purchased upgrade
	match upgrade_id:
		"barracks":
			max_party_size += 4
			print("[GameState] Barracks effect: max_party_size = %d" % max_party_size)
		"training_yard":
			xp_multiplier = 1.5
			print("[GameState] Training Yard effect: xp_multiplier = %.1f" % xp_multiplier)
		"tavern":
			recruitment_quality_bonus = true
			print("[GameState] Tavern effect: recruitment_quality_bonus = true")
		_:
			push_warning("[GameState] Unknown upgrade: %s" % upgrade_id)

func get_all_upgrades() -> Array[String]:
	## Get list of all purchased upgrades
	return fort_upgrades.duplicate()

# ===== SOLDIER ROSTER MANAGEMENT =====
func add_soldier(soldier_type: String) -> void:
	## Add a soldier to the roster
	soldiers.append(soldier_type)
	soldiers_changed.emit()
	print("[GameState] Soldier added: %s (Total: %d)" % [soldier_type, soldiers.size()])

func remove_soldier(soldier_type: String) -> bool:
	## Remove first matching soldier from roster (for deaths)
	var idx := soldiers.find(soldier_type)
	if idx >= 0:
		soldiers.remove_at(idx)
		soldiers_changed.emit()
		print("[GameState] Soldier removed: %s (Total: %d)" % [soldier_type, soldiers.size()])
		return true
	return false

func get_soldiers() -> Array[String]:
	## Get copy of current soldier roster
	return soldiers.duplicate()

func get_soldier_count() -> int:
	## Get total soldiers owned
	return soldiers.size()

func get_soldier_count_by_type(soldier_type: String) -> int:
	## Get count of specific soldier type
	return soldiers.count(soldier_type)

func clear_soldiers() -> void:
	## Remove all soldiers (for game reset)
	soldiers.clear()
	soldiers_changed.emit()

# ===== CHARACTER EQUIPMENT MANAGEMENT =====
func equip_item(character_id: String, slot: String, equipment_id: String) -> void:
	## Equip an item to a party member
	if character_id not in character_equipment:
		push_warning("[GameState] Unknown character: %s" % character_id)
		return

	if slot not in ["weapon", "armor"]:
		push_warning("[GameState] Invalid slot: %s" % slot)
		return

	character_equipment[character_id][slot] = equipment_id
	equipment_changed.emit(character_id, slot, equipment_id)
	print("[GameState] %s equipped %s: %s" % [character_id, slot, equipment_id])

func get_equipped(character_id: String, slot: String) -> String:
	## Get the equipment ID for a character's slot
	if character_id not in character_equipment:
		return ""
	return character_equipment[character_id].get(slot, "")

func has_equipment(character_id: String, equipment_id: String) -> bool:
	## Check if a character has a specific equipment item
	if character_id not in character_equipment:
		return false
	return character_equipment[character_id]["weapon"] == equipment_id or \
		   character_equipment[character_id]["armor"] == equipment_id

func get_character_equipment(character_id: String) -> Dictionary:
	## Get all equipment for a character
	if character_id not in character_equipment:
		return {"weapon": "", "armor": ""}
	return character_equipment[character_id].duplicate()

# ===== SAVE/LOAD (placeholder for future) =====
func get_save_data() -> Dictionary:
	## Get save data dictionary
	return {
		"gold": gold,
		"company_name": company_name,
		"completed_contracts": completed_contracts,
		"days_passed": days_passed,
		"available_contract_ids": available_contract_ids.duplicate(),
		"completed_contract_ids": completed_contract_ids.duplicate(),
		"active_contract_id": active_contract.id if active_contract else "",
		"contract_choices": contract_choices.duplicate(),
		"fort_upgrades": fort_upgrades.duplicate(),
		"soldiers": soldiers.duplicate(),
		"character_equipment": character_equipment.duplicate(true),
	}

func load_save_data(data: Dictionary) -> void:
	## Load from save data dictionary
	gold = data.get("gold", STARTING_GOLD)
	company_name = data.get("company_name", "The Iron Company")
	completed_contracts = data.get("completed_contracts", 0)
	days_passed = data.get("days_passed", 0)

	# Load contract state
	available_contract_ids.clear()
	for id in data.get("available_contract_ids", []):
		available_contract_ids.append(id)

	completed_contract_ids.clear()
	for id in data.get("completed_contract_ids", []):
		completed_contract_ids.append(id)

	var active_id = data.get("active_contract_id", "")
	if active_id != "":
		active_contract = get_contract_by_id(active_id)
	else:
		active_contract = null

	# Load contract choices
	contract_choices.clear()
	for key in data.get("contract_choices", {}).keys():
		contract_choices[key] = data.contract_choices[key]

	# Load fort upgrades and re-apply effects
	fort_upgrades.clear()
	max_party_size = 4  # Reset to default
	xp_multiplier = 1.0  # Reset to default
	recruitment_quality_bonus = false  # Reset to default
	for upgrade_id in data.get("fort_upgrades", []):
		fort_upgrades.append(upgrade_id)
		_apply_upgrade_effect(upgrade_id)

	# Load soldier roster
	soldiers.clear()
	for soldier_type in data.get("soldiers", []):
		soldiers.append(soldier_type)

	# Load character equipment
	var saved_equipment = data.get("character_equipment", {})
	for char_id in character_equipment.keys():
		if char_id in saved_equipment:
			character_equipment[char_id] = saved_equipment[char_id].duplicate()
		else:
			character_equipment[char_id] = {"weapon": "", "armor": ""}

	gold_changed.emit(gold)
	contracts_updated.emit()
	soldiers_changed.emit()
	print("[GameState] Save data loaded")

func reset_to_new_game() -> void:
	## Reset all state for a new game
	gold = STARTING_GOLD
	company_name = "The Iron Company"
	completed_contracts = 0
	days_passed = 0
	current_screen = Screen.HUB

	# Reset contract state
	active_contract = null
	completed_contract_ids.clear()
	available_contract_ids.clear()
	for contract in all_contracts:
		available_contract_ids.append(contract.id)

	# Reset choice tracking
	contract_choices.clear()

	# Reset fort upgrades
	fort_upgrades.clear()
	max_party_size = 4
	xp_multiplier = 1.0
	recruitment_quality_bonus = false

	# Reset soldier roster
	soldiers.clear()

	# Reset character equipment
	for char_id in character_equipment.keys():
		character_equipment[char_id] = {"weapon": "", "armor": ""}

	gold_changed.emit(gold)
	contracts_updated.emit()
	soldiers_changed.emit()
	print("[GameState] Reset to new game")
