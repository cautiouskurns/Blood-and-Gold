## ClearTheRuins - Contract 2: Full combat against bandit fortification
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.4-contract-clear-the-ruins.md
## Features: Hidden cache discovery, Bandit Leader with Rally Bandits ability
extends Node2D

# ===== SIGNALS =====
signal contract_started(contract_id: String)
signal contract_completed(contract_id: String, gold_earned: int)
signal contract_failed(contract_id: String, reason: String)
signal cache_discovered(bonus_gold: int)

# ===== CONSTANTS =====
const CONTRACT_ID: String = "clear_the_ruins"
const BASE_REWARD_GOLD: int = 500
const CACHE_BONUS_GOLD: int = 200

# ===== PRELOADS =====
const UnitScene = preload("res://scenes/combat/Unit.tscn")
const BattleResultPopupScene = preload("res://scenes/UI/BattleResultPopup.tscn")

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
var _battle_result_popup: BattleResultPopup = null
var _is_briefing_shown: bool = true
var _contract_active: bool = false
var _last_hovered_tile: Vector2i = Vector2i(-1, -1)

# Cache discovery state
var _cache_discovered: bool = false
var _cache_position: Vector2i = Vector2i(-1, -1)

# Leader AI state
var _bandit_leader: Unit = null
var _leader_ai: BanditLeaderAI = null

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_briefing()
	_setup_battle_result_popup()
	_setup_leader_ai()
	print("[ClearTheRuins] Contract scene loaded")

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

# ===== LEADER AI SETUP =====
func _setup_leader_ai() -> void:
	## Create the BanditLeaderAI tracker
	_leader_ai = BanditLeaderAI.new()
	add_child(_leader_ai)
	_leader_ai.rally_used.connect(_on_rally_used)
	print("[ClearTheRuins] BanditLeaderAI initialized")

func _on_rally_used(leader: Unit, affected_count: int) -> void:
	## Visual/audio feedback when Rally Bandits is used
	print("[ClearTheRuins] Rally Bandits! Leader buffed %d allies!" % affected_count)
	# TODO: Add visual effect (golden shout animation)
	# TODO: Add sound effect (war cry)

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
	# Hide entire briefing layer
	if briefing_layer:
		briefing_layer.visible = false
	_is_briefing_shown = false

	_start_combat()

# ===== COMBAT SETUP =====
func _start_combat() -> void:
	## Initialize and start combat
	_contract_active = true
	contract_started.emit(CONTRACT_ID)

	# Load the Ruined Fort map
	var map_data = RuinedFortMap.get_map_data()
	combat_grid.load_map(map_data)

	# Store cache position from map data
	_cache_position = map_data.get("cache_position", Vector2i(11, 8))

	# Spawn all units
	_spawn_units(map_data)

	# Update pathfinding
	combat_grid.update_occupied_tiles(_units)

	# Connect combat signals
	_connect_combat_signals()
	_connect_turn_signals()

	# Set combat grid reference
	CombatManager.set_combat_grid(combat_grid)

	# Start battle
	CombatManager.start_battle(_units)

	print("[ClearTheRuins] Combat started with %d units (cache at %s)" % [
		_units.size(), _cache_position
	])

func _spawn_units(map_data: Dictionary) -> void:
	## Spawn all units for the contract
	_units.clear()

	var party_spawns = map_data.get("party_spawns", [])
	var enemy_spawns = map_data.get("enemy_spawns", {})

	# Spawn party (4 members)
	var party_types = [
		{"type": Unit.UnitType.PLAYER, "name": "Player"},
		{"type": Unit.UnitType.THORNE, "name": "Thorne"},
		{"type": Unit.UnitType.LYRA, "name": "Lyra"},
		{"type": Unit.UnitType.MATTHIAS, "name": "Matthias"},
	]
	for i in range(min(party_types.size(), party_spawns.size())):
		var data = party_types[i]
		_spawn_unit(data["type"], party_spawns[i], data["name"])

	# Spawn soldiers (if party spawns has extra slots)
	for i in range(party_types.size(), party_spawns.size()):
		var unit = _spawn_unit(Unit.UnitType.INFANTRY, party_spawns[i], "Soldier %d" % (i - 3))
		unit.set_order(Unit.SoldierOrder.ADVANCE)

	# Spawn bandit archers (on tower)
	var archer_spawns = enemy_spawns.get("archers", [])
	for i in range(archer_spawns.size()):
		_spawn_unit(Unit.UnitType.BANDIT_ARCHER, archer_spawns[i], "Bandit Archer %d" % (i + 1))

	# Spawn bandit melee
	var melee_spawns = enemy_spawns.get("melee", [])
	for i in range(melee_spawns.size()):
		_spawn_unit(Unit.UnitType.ENEMY, melee_spawns[i], "Bandit %d" % (i + 1))

	# Spawn bandit leader
	var leader_spawns = enemy_spawns.get("leader", [])
	if leader_spawns.size() > 0:
		_bandit_leader = _spawn_unit(Unit.UnitType.BANDIT_LEADER, leader_spawns[0], "Bandit Leader")
		# Initialize the leader AI tracker
		if _leader_ai:
			_leader_ai.initialize(_bandit_leader)

	print("[ClearTheRuins] Spawned %d units" % _units.size())

func _spawn_unit(type: Unit.UnitType, grid_pos: Vector2i, unit_name: String) -> Unit:
	## Spawn a unit at the specified grid position
	var unit = UnitScene.instantiate() as Unit
	unit.unit_type = type
	unit.unit_name = unit_name
	unit.set_combat_grid(combat_grid)
	combat_grid.add_child(unit)
	unit.place_on_grid(grid_pos)
	unit.unit_died.connect(_on_unit_died)
	unit.movement_finished.connect(_on_unit_movement_finished.bind(unit))
	_units.append(unit)
	return unit

# ===== CACHE DISCOVERY =====
func _check_cache_discovery(unit: Unit) -> void:
	## Check if a unit has discovered the hidden cache
	if _cache_discovered:
		return  # Already found

	if unit.grid_position == _cache_position:
		_discover_cache(unit)

func _discover_cache(discovering_unit: Unit) -> void:
	## Trigger cache discovery
	_cache_discovered = true

	print("[ClearTheRuins] CACHE DISCOVERED by %s at %s! +%d gold!" % [
		discovering_unit.unit_name, _cache_position, CACHE_BONUS_GOLD
	])

	# Emit signal
	cache_discovered.emit(CACHE_BONUS_GOLD)

	# TODO: Show floating text notification "+200g Cache Found!"
	# TODO: Play discovery sound effect
	# TODO: Play cache open animation

# ===== COMBAT SIGNALS =====
func _connect_combat_signals() -> void:
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.movement_finished.connect(_on_combat_movement_finished)
	CombatManager.attack_executed.connect(_on_attack_executed)

func _connect_turn_signals() -> void:
	CombatManager.battle_started.connect(_on_battle_started)
	CombatManager.turn_started.connect(_on_turn_started)
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_won.connect(_on_battle_won)
	CombatManager.battle_lost.connect(_on_battle_lost)

func _on_unit_selected(unit: Unit) -> void:
	if unit and not unit.is_moving() and CombatManager.is_waiting_for_input():
		if unit.can_move():
			combat_grid.update_occupied_tiles(_units)
			combat_grid.show_movement_range(unit.grid_position, unit.movement_range, unit)

func _on_unit_deselected(_unit: Unit) -> void:
	combat_grid.clear_movement_overlay()
	_last_hovered_tile = Vector2i(-1, -1)

func _on_unit_movement_finished(unit: Unit) -> void:
	## Called when any unit finishes moving - check for cache discovery
	_check_cache_discovery(unit)

func _on_combat_movement_finished(unit: Unit) -> void:
	combat_grid.update_occupied_tiles(_units)
	_check_cache_discovery(unit)

func _on_attack_executed(_attacker: Unit, _target: Unit, _hit: bool, _damage: int) -> void:
	pass

func _on_battle_started(units: Array[Unit]) -> void:
	if turn_order_panel:
		turn_order_panel.initialize_turn_order(units)

func _on_turn_started(unit: Unit) -> void:
	## Handle leader's Rally ability at start of their turn
	if unit == _bandit_leader and is_instance_valid(_bandit_leader) and _bandit_leader.is_alive():
		if _leader_ai and _leader_ai.should_use_rally():
			# Execute Rally before normal AI behavior
			# This is handled by the turn manager calling EnemyAI.execute_turn
			# The BanditLeaderAI hooks into this via execute_leader_turn_with_rally
			pass

func _on_turn_ended(unit: Unit) -> void:
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

	# Track if leader died
	if unit == _bandit_leader:
		print("[ClearTheRuins] Bandit Leader defeated! Remaining bandits fight on...")
		_bandit_leader = null

# ===== BATTLE RESULTS =====
func _on_battle_won(_gold_earned: int) -> void:
	## Victory! All enemies defeated
	print("[ClearTheRuins] Victory!")

	# Calculate total reward
	var total_gold = BASE_REWARD_GOLD
	if _cache_discovered:
		total_gold += CACHE_BONUS_GOLD
		print("[ClearTheRuins] Cache bonus: +%d gold" % CACHE_BONUS_GOLD)

	# Complete the contract in GameState
	GameState.complete_current_contract(total_gold)

	contract_completed.emit(CONTRACT_ID, total_gold)

	if _battle_result_popup:
		_battle_result_popup.show_victory(total_gold, _cache_discovered, CACHE_BONUS_GOLD)

func _on_battle_lost() -> void:
	## Defeat - party wiped
	print("[ClearTheRuins] Defeat - party wiped")
	_show_defeat("Your company has fallen in the ruins.")
	contract_failed.emit(CONTRACT_ID, "party_wiped")

func _show_defeat(message: String) -> void:
	if _battle_result_popup:
		_battle_result_popup.show_defeat()

# ===== BATTLE RESULT POPUP =====
func _setup_battle_result_popup() -> void:
	_battle_result_popup = BattleResultPopupScene.instantiate() as BattleResultPopup
	add_child(_battle_result_popup)
	_battle_result_popup.continue_pressed.connect(_on_continue_pressed)
	_battle_result_popup.retry_pressed.connect(_on_retry_pressed)

func _on_continue_pressed() -> void:
	## Victory continue - transition to camp scene
	var contract = GameState.get_contract_by_id(CONTRACT_ID)
	if contract and contract.triggers_camp_scene:
		# Transition to camp scene
		print("[ClearTheRuins] Transitioning to camp scene: %s" % contract.camp_scene_id)
		# For now, return to hub - camp scene system will handle this
		# TODO: Implement camp scene transition
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")

func _on_retry_pressed() -> void:
	## Retry battle
	print("[ClearTheRuins] Retrying contract")
	_restart_battle()

func _restart_battle() -> void:
	## Restart the battle from scratch
	# Reset cache discovery
	_cache_discovered = false

	# Clear existing units
	for unit in _units.duplicate():
		if is_instance_valid(unit):
			unit.queue_free()
	_units.clear()
	_bandit_leader = null

	await get_tree().process_frame

	# Reload and restart
	combat_grid._setup_pathfinding()

	var map_data = RuinedFortMap.get_map_data()
	_spawn_units(map_data)
	combat_grid.update_occupied_tiles(_units)

	CombatManager.set_combat_grid(combat_grid)
	CombatManager.start_battle(_units)

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
