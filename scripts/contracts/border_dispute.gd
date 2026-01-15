## BorderDispute - Choice contract with moral decision and branching outcomes
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.5-border-dispute-choice-contract.md
extends Node2D

# ===== SIGNALS =====
signal contract_started(contract_id: String)
signal contract_completed(contract_id: String, gold_earned: int)
signal contract_failed(contract_id: String, reason: String)
signal choice_made(choice_id: String)
signal loyalty_changed(companion_id: String, delta: int)

# ===== CONSTANTS =====
const CONTRACT_ID: String = "border_dispute"

# Choice configuration from spec
const CHOICES: Dictionary = {
	"A": {
		"label": "We'll handle it.",
		"description": "Drive off the refugees by force.",
		"gold_reward": 600,
		"has_combat": true,
		"loyalty_changes": {
			"matthias": -20,
			"thorne": 5
		}
	},
	"B": {
		"label": "We're mercenaries, not butchers.",
		"description": "Refuse the contract and let refugees pass.",
		"gold_reward": 300,
		"has_combat": false,
		"loyalty_changes": {
			"matthias": 10,
			"thorne": 5
		}
	},
	"C": {
		"label": "Perhaps there's another way...",
		"description": "Attempt to negotiate a peaceful solution.",
		"requires_check": "CHA",
		"check_dc": 15,
		"gold_reward": 500,  # On success
		"has_combat": false,
		"loyalty_changes": {
			"matthias": 5,
			"thorne": 5,
			"lyra": 5
		}
	}
}

# Combat setup (Option A)
const REFUGEE_MELEE_SPAWN := [Vector2i(8, 4), Vector2i(8, 6)]
const REFUGEE_RANGED_SPAWN := [Vector2i(9, 5), Vector2i(9, 7)]
const PARTY_SPAWN := [Vector2i(2, 4), Vector2i(2, 5), Vector2i(2, 6), Vector2i(2, 7)]
const SOLDIER_SPAWN := [Vector2i(3, 5), Vector2i(3, 6)]

# Dialogue sequence
const DIALOGUE_SEQUENCE: Array[Dictionary] = [
	{"speaker": "Commander Harwick", "text": "Ah, the mercenaries. Good. I have a task that requires... discretion."},
	{"speaker": "Commander Harwick", "text": "Refugees from the east. Hundreds of them. Trying to cross into Ironmark territory."},
	{"speaker": "Narrator", "text": "You see families huddled together. Children clutching parents. The elderly supported by the young."},
	{"speaker": "Matthias", "text": "Commander, these are civilians. Women and children..."},
	{"speaker": "Commander Harwick", "text": "They are unauthorized trespassers. Ironmark cannot absorb every vagrant from the borderlands."},
	{"speaker": "Thorne", "text": "We took a contract. Gold changes hands, we do the job. That's how it works."},
	{"speaker": "Commander Harwick", "text": "Precisely. Remove them. I don't care how. Six hundred gold for your trouble."},
]

# ===== PRELOADS =====
const UnitScene = preload("res://scenes/combat/Unit.tscn")
const BattleResultPopupScene = preload("res://scenes/UI/BattleResultPopup.tscn")
const ChoicePanelScene = preload("res://scenes/ui/ChoicePanel.tscn")
const LoyaltyPopupScene = preload("res://scenes/ui/LoyaltyPopup.tscn")

# ===== NODE REFERENCES =====
@onready var dialogue_layer: CanvasLayer = $DialogueLayer
@onready var dialogue_panel: PanelContainer = $DialogueLayer/DialoguePanel
@onready var speaker_label: Label = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_text: RichTextLabel = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var continue_button: Button = $DialogueLayer/DialoguePanel/MarginContainer/VBoxContainer/ContinueButton
@onready var ui_layer: CanvasLayer = $UILayer
@onready var combat_grid: CombatGrid = $CombatGrid

# ===== INTERNAL STATE =====
enum ContractState {
	DIALOGUE,
	CHOICE,
	CHA_CHECK,
	CHA_FAILED_CHOICE,
	COMBAT,
	RESULTS,
	COMPLETE
}

var _state: ContractState = ContractState.DIALOGUE
var _dialogue_index: int = 0
var _selected_choice: String = ""
var _final_gold_reward: int = 0
var _units: Array[Unit] = []
var _choice_panel: ChoicePanel = null
var _loyalty_popup: LoyaltyPopup = null
var _battle_result_popup: BattleResultPopup = null
var _cha_check_result: Dictionary = {}

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_dialogue()
	_setup_choice_panel()
	_setup_loyalty_popup()
	_setup_battle_result_popup()
	_start_contract()
	print("[BorderDispute] Contract scene loaded")

func _unhandled_input(event: InputEvent) -> void:
	match _state:
		ContractState.DIALOGUE:
			if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
				_advance_dialogue()
		ContractState.COMBAT:
			_handle_combat_input(event)

# ===== CONTRACT FLOW =====
func _start_contract() -> void:
	_state = ContractState.DIALOGUE
	contract_started.emit(CONTRACT_ID)
	_show_dialogue_panel()
	_show_current_dialogue()
	print("[BorderDispute] Contract started")

func _setup_dialogue() -> void:
	if continue_button:
		continue_button.pressed.connect(_advance_dialogue)

func _show_dialogue_panel() -> void:
	if dialogue_layer:
		dialogue_layer.visible = true
	if dialogue_panel:
		dialogue_panel.visible = true

func _hide_dialogue_panel() -> void:
	if dialogue_layer:
		dialogue_layer.visible = false

func _show_current_dialogue() -> void:
	if _dialogue_index >= DIALOGUE_SEQUENCE.size():
		_transition_to_choice()
		return

	var line = DIALOGUE_SEQUENCE[_dialogue_index]
	if speaker_label:
		speaker_label.text = line.speaker
		# Color code speakers
		match line.speaker:
			"Commander Harwick":
				speaker_label.add_theme_color_override("font_color", Color("#c0392b"))
			"Matthias":
				speaker_label.add_theme_color_override("font_color", Color("#3498db"))
			"Thorne":
				speaker_label.add_theme_color_override("font_color", Color("#2ecc71"))
			"Narrator":
				speaker_label.add_theme_color_override("font_color", Color("#95a5a6"))
			_:
				speaker_label.add_theme_color_override("font_color", Color.WHITE)

	if dialogue_text:
		dialogue_text.text = line.text

func _advance_dialogue() -> void:
	if _state != ContractState.DIALOGUE:
		return

	_dialogue_index += 1
	_show_current_dialogue()

# ===== CHOICE PHASE =====
func _setup_choice_panel() -> void:
	_choice_panel = ChoicePanelScene.instantiate() as ChoicePanel
	add_child(_choice_panel)
	_choice_panel.choice_selected.connect(_on_choice_selected)

func _transition_to_choice() -> void:
	_state = ContractState.CHOICE
	_hide_dialogue_panel()

	var opinions = {
		"thorne": "Honor demands we fulfill the contract.",
		"matthias": "These are civilians, not bandits..."
	}

	_choice_panel.show_choices(
		"THE BORDER DISPUTE",
		"What will you do about the refugees?",
		CHOICES,
		opinions
	)
	print("[BorderDispute] Showing choices")

func _on_choice_selected(choice_id: String) -> void:
	print("[BorderDispute] Choice selected: %s" % choice_id)
	_selected_choice = choice_id
	choice_made.emit(choice_id)

	# Store choice in GameState
	if GameState:
		GameState.record_choice(CONTRACT_ID, choice_id)

	_choice_panel.hide_choices()

	match choice_id:
		"A":
			_execute_option_a()
		"B":
			_execute_option_b()
		"C":
			_execute_option_c()

# ===== OPTION A: COMPLY (Combat) =====
func _execute_option_a() -> void:
	print("[BorderDispute] Option A: Combat with refugees")
	_final_gold_reward = CHOICES["A"].gold_reward
	_state = ContractState.COMBAT

	# Setup combat
	await get_tree().process_frame
	_start_combat()

func _start_combat() -> void:
	# Load a simple map or use existing combat grid
	var map_data = _get_border_map_data()
	combat_grid.load_map(map_data)

	# Spawn units
	_spawn_combat_units()

	# Update pathfinding
	combat_grid.update_occupied_tiles(_units)

	# Connect combat signals
	_connect_combat_signals()

	# Set combat grid reference
	CombatManager.set_combat_grid(combat_grid)

	# Start battle
	CombatManager.start_battle(_units)

	print("[BorderDispute] Combat started with %d units" % _units.size())

func _spawn_combat_units() -> void:
	_units.clear()

	# Spawn party
	var party_types = [
		{"type": Unit.UnitType.PLAYER, "name": "Player"},
		{"type": Unit.UnitType.THORNE, "name": "Thorne"},
		{"type": Unit.UnitType.LYRA, "name": "Lyra"},
		{"type": Unit.UnitType.MATTHIAS, "name": "Matthias"},
	]
	for i in range(min(party_types.size(), PARTY_SPAWN.size())):
		var data = party_types[i]
		_spawn_unit(data["type"], PARTY_SPAWN[i], data["name"])

	# Spawn soldiers
	for i in range(SOLDIER_SPAWN.size()):
		var unit = _spawn_unit(Unit.UnitType.INFANTRY, SOLDIER_SPAWN[i], "Soldier %d" % (i + 1))
		unit.set_order(Unit.SoldierOrder.ADVANCE if i == 0 else Unit.SoldierOrder.HOLD)

	# Spawn refugee defenders (use ENEMY type with different name)
	for i in range(REFUGEE_MELEE_SPAWN.size()):
		var unit = _spawn_unit(Unit.UnitType.ENEMY, REFUGEE_MELEE_SPAWN[i], "Refugee Defender %d" % (i + 1))
		unit.is_enemy = true

	for i in range(REFUGEE_RANGED_SPAWN.size()):
		var unit = _spawn_unit(Unit.UnitType.BANDIT_ARCHER, REFUGEE_RANGED_SPAWN[i], "Refugee Guard %d" % (i + 1))
		unit.is_enemy = true

	print("[BorderDispute] Spawned %d units for combat" % _units.size())

func _spawn_unit(type: Unit.UnitType, grid_pos: Vector2i, unit_name: String) -> Unit:
	var unit = UnitScene.instantiate() as Unit
	unit.unit_type = type
	unit.unit_name = unit_name
	unit.set_combat_grid(combat_grid)
	combat_grid.add_child(unit)
	unit.place_on_grid(grid_pos)
	unit.unit_died.connect(_on_unit_died)
	_units.append(unit)
	return unit

func _get_border_map_data() -> Dictionary:
	# Simple map data for border checkpoint - using Forest Clearing structure
	return {
		"grid_size": Vector2i(12, 12),
		"terrain": {},
		"obstacles": [
			Vector2i(5, 0), Vector2i(6, 0), Vector2i(5, 11), Vector2i(6, 11),
			Vector2i(0, 5), Vector2i(0, 6), Vector2i(11, 5), Vector2i(11, 6),
		]
	}

func _connect_combat_signals() -> void:
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.movement_finished.connect(_on_unit_movement_finished)
	CombatManager.battle_won.connect(_on_battle_won)
	CombatManager.battle_lost.connect(_on_battle_lost)

func _handle_combat_input(event: InputEvent) -> void:
	if CombatManager.is_unit_moving():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_grid_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_attack_click()

func _handle_grid_click() -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	if not _is_valid_grid_pos(grid_pos):
		CombatManager.deselect_unit()
		return

	var selected = CombatManager.get_selected_unit()
	if selected and selected.can_move() and combat_grid.is_valid_move_tile(grid_pos):
		var path = combat_grid.pathfinding.get_path(selected.grid_position, grid_pos, selected)
		if path.size() >= 2:
			CombatManager.start_unit_movement(selected, path)
			return

	var unit = _get_unit_at_grid_pos(grid_pos)
	if unit == null:
		CombatManager.deselect_unit()

func _handle_attack_click() -> void:
	var selected = CombatManager.get_selected_unit()
	if selected == null or selected.is_moving() or not CombatManager.is_waiting_for_input():
		return

	if not selected.can_perform_attacks():
		return

	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)
	var target = _get_unit_at_grid_pos(grid_pos)

	if target and CombatManager.attempt_attack(selected, target):
		combat_grid.update_occupied_tiles(_units.filter(func(u): return u.is_alive()))
		combat_grid.clear_movement_overlay()

func _on_unit_selected(unit: Unit) -> void:
	if unit and not unit.is_moving() and CombatManager.is_waiting_for_input():
		if unit.can_move():
			combat_grid.update_occupied_tiles(_units)
			combat_grid.show_movement_range(unit.grid_position, unit.movement_range, unit)

func _on_unit_deselected(_unit: Unit) -> void:
	combat_grid.clear_movement_overlay()

func _on_unit_movement_finished(_unit: Unit) -> void:
	combat_grid.update_occupied_tiles(_units)

func _on_unit_died(unit: Unit) -> void:
	var turn_manager = CombatManager.get_turn_manager()
	if turn_manager:
		turn_manager.remove_unit(unit)

	var index = _units.find(unit)
	if index != -1:
		_units.remove_at(index)

func _get_unit_at_grid_pos(pos: Vector2i) -> Unit:
	for unit in _units:
		if unit.grid_position == pos:
			return unit
	return null

func _is_valid_grid_pos(pos: Vector2i) -> bool:
	var grid_size = combat_grid.get_grid_size()
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

# ===== OPTION B: REFUSE (No Combat) =====
func _execute_option_b() -> void:
	print("[BorderDispute] Option B: Refuse contract")
	_final_gold_reward = CHOICES["B"].gold_reward
	_apply_loyalty_changes("B")
	_complete_contract()

# ===== OPTION C: NEGOTIATE (CHA Check) =====
func _execute_option_c() -> void:
	print("[BorderDispute] Option C: CHA check")
	_state = ContractState.CHA_CHECK

	# Perform the check
	_cha_check_result = SkillCheckManager.perform_check("CHA", CHOICES["C"].check_dc)

	# Show result with brief delay for dramatic effect
	await get_tree().create_timer(0.5).timeout

	if _cha_check_result.success:
		_on_cha_success()
	else:
		_on_cha_failure()

func _on_cha_success() -> void:
	print("[BorderDispute] CHA check passed!")
	_final_gold_reward = CHOICES["C"].gold_reward
	_apply_loyalty_changes("C")
	_complete_contract()

func _on_cha_failure() -> void:
	print("[BorderDispute] CHA check failed - showing reduced choices")
	_state = ContractState.CHA_FAILED_CHOICE

	# Show only A and B options
	var reduced_choices = {
		"A": CHOICES["A"],
		"B": CHOICES["B"],
	}

	var opinions = {
		"thorne": "The negotiation failed. We must choose.",
		"matthias": "There's still a choice to make..."
	}

	_choice_panel.show_choices(
		"NEGOTIATION FAILED",
		"Your words did not convince Commander Harwick. Choose another path.",
		reduced_choices,
		opinions
	)

# ===== BATTLE RESULTS =====
func _on_battle_won(_gold_earned: int) -> void:
	print("[BorderDispute] Combat won")
	CombatManager.end_battle()
	_apply_loyalty_changes("A")
	_complete_contract()

func _on_battle_lost() -> void:
	print("[BorderDispute] Combat lost - party wiped")
	CombatManager.end_battle()
	_show_defeat()
	contract_failed.emit(CONTRACT_ID, "party_wiped")

# ===== LOYALTY CHANGES =====
func _apply_loyalty_changes(choice_id: String) -> void:
	var choice_data = CHOICES.get(choice_id, {})
	var changes = choice_data.get("loyalty_changes", {})

	for companion_id in changes.keys():
		var delta = changes[companion_id]
		LoyaltyManager.modify_loyalty(companion_id, delta)
		loyalty_changed.emit(companion_id, delta)

	# Show loyalty popup
	if not changes.is_empty() and _loyalty_popup:
		await get_tree().create_timer(0.3).timeout
		_loyalty_popup.show_multiple_changes(changes)
		# Wait for popup to finish
		await _loyalty_popup.popup_closed

# ===== CONTRACT COMPLETION =====
func _complete_contract() -> void:
	_state = ContractState.RESULTS
	print("[BorderDispute] Contract complete! Gold: %d" % _final_gold_reward)

	# Complete in GameState
	GameState.complete_current_contract(_final_gold_reward)
	contract_completed.emit(CONTRACT_ID, _final_gold_reward)

	# Show result popup
	if _battle_result_popup:
		_battle_result_popup.show_victory(_final_gold_reward)

func _setup_battle_result_popup() -> void:
	_battle_result_popup = BattleResultPopupScene.instantiate() as BattleResultPopup
	add_child(_battle_result_popup)
	_battle_result_popup.continue_pressed.connect(_on_continue_pressed)
	_battle_result_popup.retry_pressed.connect(_on_retry_pressed)

func _setup_loyalty_popup() -> void:
	_loyalty_popup = LoyaltyPopupScene.instantiate() as LoyaltyPopup
	add_child(_loyalty_popup)

func _show_defeat() -> void:
	if _battle_result_popup:
		_battle_result_popup.show_defeat()

func _on_continue_pressed() -> void:
	# Check for camp scene
	var contract = GameState.get_contract_by_id(CONTRACT_ID)
	if contract and contract.triggers_camp_scene:
		print("[BorderDispute] Transitioning to camp scene: %s" % contract.camp_scene_id)
		# For now, return to hub - camp scene will be implemented in future task
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")

func _on_retry_pressed() -> void:
	# Retry from choice moment
	print("[BorderDispute] Retrying contract")
	get_tree().reload_current_scene()
