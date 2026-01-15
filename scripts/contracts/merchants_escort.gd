## MerchantsEscort - Tutorial contract controller
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.3-merchants-escort-tutorial-contract.md
extends Node2D

# ===== SIGNALS =====
signal contract_started(contract_id: String)
signal contract_completed(contract_id: String, gold_earned: int)
signal contract_failed(contract_id: String, reason: String)
signal wagon_health_changed(current: int, max_val: int)

# ===== CONSTANTS =====
const CONTRACT_ID: String = "merchants_escort"
const REWARD_GOLD: int = 300

# Unit spawn positions (spec-defined)
const WAGON_POSITION := Vector2i(6, 5)  # Center of 12x12 grid
const PARTY_SPAWN := [Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10), Vector2i(4, 10)]
const SOLDIER_SPAWN := [Vector2i(2, 11), Vector2i(3, 11)]
const BANDIT_MELEE_SPAWN := [Vector2i(10, 3), Vector2i(10, 4), Vector2i(10, 7), Vector2i(10, 8)]
const BANDIT_ARCHER_SPAWN := [Vector2i(11, 5), Vector2i(11, 6)]

# ===== PRELOADS =====
const UnitScene = preload("res://scenes/combat/Unit.tscn")
const BattleResultPopupScene = preload("res://scenes/UI/BattleResultPopup.tscn")
const TutorialPopupScene = preload("res://scenes/tutorial/TutorialPopup.tscn")

# ===== NODE REFERENCES =====
@onready var combat_grid: CombatGrid = $CombatGrid
@onready var ui_layer: CanvasLayer = $UILayer
@onready var turn_order_panel = $UILayer/TurnOrderPanel
@onready var ability_bar = $UILayer/AbilityBar
@onready var selection_panel = $UILayer/SelectionPanel
@onready var combat_log = $UILayer/CombatLog
@onready var order_panel = $UILayer/OrderPanel
@onready var briefing_layer: CanvasLayer = $BriefingLayer
@onready var briefing_panel: PanelContainer = $BriefingLayer/BriefingPanel

# ===== INTERNAL STATE =====
var _units: Array[Unit] = []
var _wagon: Unit = null
var _battle_result_popup: BattleResultPopup = null
var _tutorial_manager: TutorialManager = null
var _tutorial_popup: TutorialPopup = null
var _is_briefing_shown: bool = true
var _contract_active: bool = false
var _last_hovered_tile: Vector2i = Vector2i(-1, -1)

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_briefing()
	_setup_battle_result_popup()
	_setup_tutorial_system()
	print("[MerchantsEscort] Contract scene loaded")

func _process(_delta: float) -> void:
	if _contract_active and not _is_briefing_shown:
		_update_path_preview_on_hover()

func _unhandled_input(event: InputEvent) -> void:
	if not _contract_active or _is_briefing_shown:
		return

	# Handle grid clicks
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_grid_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_attack_click()

# ===== BRIEFING =====
func _setup_briefing() -> void:
	## Show contract briefing before combat
	if briefing_panel:
		briefing_panel.visible = true
		_is_briefing_shown = true

		# Connect accept button
		var accept_btn = briefing_panel.get_node_or_null("MarginContainer/VBoxContainer/AcceptButton")
		if accept_btn:
			accept_btn.pressed.connect(_on_accept_contract)

func _on_accept_contract() -> void:
	## Player accepted the contract - start combat
	# Hide entire briefing layer (includes dim background)
	if briefing_layer:
		briefing_layer.visible = false
	_is_briefing_shown = false

	_start_combat()

# ===== COMBAT SETUP =====
func _start_combat() -> void:
	## Initialize and start combat
	_contract_active = true
	contract_started.emit(CONTRACT_ID)

	# Load the Forest Clearing map
	var map_data = ForestClearingMap.get_map_data()
	combat_grid.load_map(map_data)

	# Spawn all units
	_spawn_units()

	# Update pathfinding
	combat_grid.update_occupied_tiles(_units)

	# Connect combat signals
	_connect_combat_signals()
	_connect_turn_signals()

	# Set combat grid reference
	CombatManager.set_combat_grid(combat_grid)

	# Start battle
	CombatManager.start_battle(_units)

	# Start tutorial
	if _tutorial_manager:
		_tutorial_manager.start_tutorial()
		_tutorial_manager.on_combat_start()

	print("[MerchantsEscort] Combat started with %d units" % _units.size())

func _spawn_units() -> void:
	## Spawn all units for the contract
	_units.clear()

	# Spawn wagon (objective)
	_wagon = _spawn_unit(Unit.UnitType.WAGON, WAGON_POSITION, "Merchant Wagon")
	_wagon.wagon_damaged.connect(_on_wagon_damaged)
	_wagon.wagon_destroyed.connect(_on_wagon_destroyed)

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

	# Spawn bandit melee
	for i in range(BANDIT_MELEE_SPAWN.size()):
		_spawn_unit(Unit.UnitType.ENEMY, BANDIT_MELEE_SPAWN[i], "Bandit %d" % (i + 1))

	# Spawn bandit archers
	for i in range(BANDIT_ARCHER_SPAWN.size()):
		_spawn_unit(Unit.UnitType.BANDIT_ARCHER, BANDIT_ARCHER_SPAWN[i], "Bandit Archer %d" % (i + 1))

	print("[MerchantsEscort] Spawned %d units (including wagon)" % _units.size())

func _spawn_unit(type: Unit.UnitType, grid_pos: Vector2i, unit_name: String) -> Unit:
	## Spawn a unit at the specified grid position
	var unit = UnitScene.instantiate() as Unit
	unit.unit_type = type
	unit.unit_name = unit_name
	unit.set_combat_grid(combat_grid)
	combat_grid.add_child(unit)
	unit.place_on_grid(grid_pos)
	unit.unit_died.connect(_on_unit_died)
	_units.append(unit)
	return unit

# ===== COMBAT SIGNALS =====
func _connect_combat_signals() -> void:
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.movement_finished.connect(_on_unit_movement_finished)
	CombatManager.attack_executed.connect(_on_attack_executed)

func _connect_turn_signals() -> void:
	CombatManager.battle_started.connect(_on_battle_started)
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_won.connect(_on_battle_won)
	CombatManager.battle_lost.connect(_on_battle_lost)

func _on_unit_selected(unit: Unit) -> void:
	if unit and not unit.is_moving() and CombatManager.is_waiting_for_input():
		if unit.can_move():
			combat_grid.update_occupied_tiles(_units)
			combat_grid.show_movement_range(unit.grid_position, unit.movement_range, unit)

		# Tutorial trigger
		if _tutorial_manager:
			_tutorial_manager.on_unit_selected(unit)

func _on_unit_deselected(_unit: Unit) -> void:
	combat_grid.clear_movement_overlay()
	_last_hovered_tile = Vector2i(-1, -1)

func _on_unit_movement_finished(unit: Unit) -> void:
	combat_grid.update_occupied_tiles(_units)

	# Tutorial trigger
	if _tutorial_manager:
		_tutorial_manager.on_unit_moved(unit)

func _on_attack_executed(attacker: Unit, target: Unit, _hit: bool, _damage: int) -> void:
	## Called when any attack is executed
	if _tutorial_manager:
		_tutorial_manager.on_attack_performed(attacker, target)

func _on_battle_started(units: Array[Unit]) -> void:
	if turn_order_panel:
		turn_order_panel.initialize_turn_order(units)

func _on_turn_ended(_unit: Unit) -> void:
	if turn_order_panel:
		turn_order_panel.advance_turn()
		if turn_order_panel.get_turn_order().is_empty():
			var turn_order = CombatManager.get_turn_order()
			if not turn_order.is_empty():
				turn_order_panel.initialize_turn_order(turn_order)

func _on_unit_died(unit: Unit) -> void:
	var turn_manager = CombatManager.get_turn_manager()
	if turn_manager:
		turn_manager.remove_unit(unit)

	var index = _units.find(unit)
	if index != -1:
		_units.remove_at(index)

# ===== WAGON EVENTS =====
func _on_wagon_damaged(current_hp: int, max_hp: int) -> void:
	wagon_health_changed.emit(current_hp, max_hp)
	print("[MerchantsEscort] Wagon damaged: %d/%d HP" % [current_hp, max_hp])

func _on_wagon_destroyed() -> void:
	## Mission failed - wagon was destroyed
	print("[MerchantsEscort] WAGON DESTROYED - Mission Failed!")
	CombatManager.end_battle()
	_show_defeat("The merchant wagon was destroyed!")
	contract_failed.emit(CONTRACT_ID, "wagon_destroyed")

# ===== BATTLE RESULTS =====
func _on_battle_won(gold_earned: int) -> void:
	## Victory! All enemies defeated, wagon survived
	print("[MerchantsEscort] Victory! Wagon survived.")

	# Use contract reward, not default
	var actual_gold = REWARD_GOLD

	# Complete the contract in GameState
	GameState.complete_current_contract(actual_gold)

	contract_completed.emit(CONTRACT_ID, actual_gold)

	if _battle_result_popup:
		_battle_result_popup.show_victory(actual_gold)

func _on_battle_lost() -> void:
	## Defeat - party wiped (wagon may still be intact)
	print("[MerchantsEscort] Defeat - party wiped")
	_show_defeat("Your company has fallen.")
	contract_failed.emit(CONTRACT_ID, "party_wiped")

func _show_defeat(message: String) -> void:
	if _battle_result_popup:
		# Customize defeat message
		_battle_result_popup.show_defeat()

# ===== BATTLE RESULT POPUP =====
func _setup_battle_result_popup() -> void:
	_battle_result_popup = BattleResultPopupScene.instantiate() as BattleResultPopup
	add_child(_battle_result_popup)
	_battle_result_popup.continue_pressed.connect(_on_continue_pressed)
	_battle_result_popup.retry_pressed.connect(_on_retry_pressed)

func _on_continue_pressed() -> void:
	## Victory continue - check for camp scene
	var contract = GameState.get_contract_by_id(CONTRACT_ID)
	if contract and contract.triggers_camp_scene:
		# Transition to camp scene
		print("[MerchantsEscort] Transitioning to camp scene: %s" % contract.camp_scene_id)
		# For now, return to hub - camp scene will be implemented in future task
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")

func _on_retry_pressed() -> void:
	## Retry battle
	print("[MerchantsEscort] Retrying contract")
	_restart_battle()

func _restart_battle() -> void:
	## Restart the battle from scratch
	# Clear existing units
	for unit in _units.duplicate():
		if is_instance_valid(unit):
			unit.queue_free()
	_units.clear()
	_wagon = null

	await get_tree().process_frame

	# Reload and restart
	combat_grid._setup_pathfinding()
	_spawn_units()
	combat_grid.update_occupied_tiles(_units)

	CombatManager.set_combat_grid(combat_grid)
	CombatManager.start_battle(_units)

	if _tutorial_manager:
		_tutorial_manager.start_tutorial()
		_tutorial_manager.on_combat_start()

# ===== TUTORIAL SYSTEM =====
func _setup_tutorial_system() -> void:
	# Create tutorial manager
	_tutorial_manager = TutorialManager.new()
	add_child(_tutorial_manager)

	# Create tutorial popup
	_tutorial_popup = TutorialPopupScene.instantiate() as TutorialPopup
	add_child(_tutorial_popup)

	# Connect them
	_tutorial_manager.set_popup(_tutorial_popup)

	print("[MerchantsEscort] Tutorial system initialized")

# ===== INPUT HANDLING =====
func _update_path_preview_on_hover() -> void:
	var selected = CombatManager.get_selected_unit()
	if selected == null or selected.is_moving() or not CombatManager.is_waiting_for_input():
		return

	if not selected.can_move():
		return

	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	if grid_pos == _last_hovered_tile:
		return
	_last_hovered_tile = grid_pos

	if combat_grid.is_valid_move_tile(grid_pos):
		combat_grid.show_path_preview(selected.grid_position, grid_pos, selected)
	else:
		combat_grid.hide_path_preview()

func _handle_grid_click() -> void:
	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	if CombatManager.is_unit_moving():
		return

	if CombatManager.is_targeting_ability():
		var unit = _get_unit_at_grid_pos(grid_pos)
		if unit == null:
			CombatManager.cancel_ability_targeting()
		return

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
	if selected == null:
		return

	if selected.is_moving() or not CombatManager.is_waiting_for_input():
		return

	if not selected.can_perform_attacks():
		return

	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	var target = _get_unit_at_grid_pos(grid_pos)
	if target == null:
		return

	if CombatManager.attempt_attack(selected, target):
		combat_grid.update_occupied_tiles(_units.filter(func(u): return u.is_alive()))
		combat_grid.clear_movement_overlay()

func _get_unit_at_grid_pos(pos: Vector2i) -> Unit:
	for unit in _units:
		if unit.grid_position == pos:
			return unit
	return null

func _is_valid_grid_pos(pos: Vector2i) -> bool:
	var grid_size = combat_grid.get_grid_size()
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y
