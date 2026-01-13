## Main - Game entry point and test setup
## Part of: Blood & Gold Prototype
extends Node2D

# ===== NODE REFERENCES =====
@onready var combat_grid: CombatGrid = $CombatGrid
@onready var turn_order_panel = $UILayer/TurnOrderPanel

# Preload scenes
const UnitScene = preload("res://scenes/combat/Unit.tscn")
const BattleResultPopupScene = preload("res://scenes/UI/BattleResultPopup.tscn")

# ===== DEBUG CONSTANTS =====
const DEBUG_DAMAGE_AMOUNT: int = 10
const DEBUG_HEAL_AMOUNT: int = 10

# ===== INTERNAL STATE =====
var _units: Array[Unit] = []
var _last_hovered_tile: Vector2i = Vector2i(-1, -1)
var _battle_result_popup: BattleResultPopup = null

# Initial spawn data for retry (Task 1.9)
var _initial_spawn_data: Array[Dictionary] = []

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_battle_result_popup()
	_spawn_test_units()
	_connect_combat_signals()
	_connect_turn_signals()
	_start_battle()
	print("[Main] Controls: Right-click adjacent enemy to attack. Debug: D = damage, H = heal, E = end turn")

func _process(_delta: float) -> void:
	## Handle hover updates for path preview (Task 1.5)
	_update_path_preview_on_hover()

func _unhandled_input(event: InputEvent) -> void:
	## Handle debug input for HP bar testing (Task 1.3) and turn testing (Task 1.8)
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D:
				_debug_damage_hovered_unit()
			KEY_H:
				_debug_heal_hovered_unit()
			KEY_E:
				_debug_end_turn()

	## Handle grid clicks for movement and deselection (Task 1.4 & 1.5)
	## This only triggers if Unit's Area2D didn't consume the click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_grid_click()
		## Handle right-click for attack (Task 1.7)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_handle_attack_click()

func _spawn_test_units() -> void:
	## Spawn test units to verify Task 1.2 implementation
	print("[Main] Spawning test units...")

	# Save spawn data for retry (Task 1.9)
	_initial_spawn_data = [
		{"type": Unit.UnitType.PLAYER, "pos": Vector2i(1, 5), "name": "Player"},
		{"type": Unit.UnitType.THORNE, "pos": Vector2i(1, 3), "name": "Thorne"},
		{"type": Unit.UnitType.LYRA, "pos": Vector2i(1, 7), "name": "Lyra"},
		{"type": Unit.UnitType.MATTHIAS, "pos": Vector2i(2, 5), "name": "Matthias"},
		# Task 2.8: Test infantry soldiers
		{"type": Unit.UnitType.INFANTRY, "pos": Vector2i(2, 3), "name": "Soldier 1", "order": Unit.SoldierOrder.ADVANCE},
		{"type": Unit.UnitType.INFANTRY, "pos": Vector2i(2, 7), "name": "Soldier 2", "order": Unit.SoldierOrder.HOLD},
		{"type": Unit.UnitType.ENEMY, "pos": Vector2i(10, 4), "name": "Bandit 1"},
		{"type": Unit.UnitType.ENEMY, "pos": Vector2i(10, 6), "name": "Bandit 2"},
		{"type": Unit.UnitType.ENEMY, "pos": Vector2i(9, 5), "name": "Bandit 3"},
	]

	# Spawn all units from data
	for data in _initial_spawn_data:
		var unit = _spawn_unit(data["type"], data["pos"], data["name"])
		# Task 2.8: Set soldier order if specified
		if data.has("order") and unit.is_soldier:
			unit.set_order(data["order"])

	print("[Main] Test units spawned: %d total" % _units.size())

	# Update pathfinding with unit positions
	combat_grid.update_occupied_tiles(_units)

func _spawn_unit(type: Unit.UnitType, grid_pos: Vector2i, unit_name: String) -> Unit:
	## Spawn a unit at the specified grid position
	var unit = UnitScene.instantiate() as Unit
	unit.unit_type = type
	unit.unit_name = unit_name

	# Note: Stats (HP, STR, DEX, etc.) are auto-configured in Unit._ready()
	# based on unit_type via _configure_stats_for_type() (Task 2.1)

	# Set grid reference first
	unit.set_combat_grid(combat_grid)

	# Add as child of CombatGrid so units move when grid is centered
	combat_grid.add_child(unit)

	# Then place on grid (uses local coordinates relative to grid)
	unit.place_on_grid(grid_pos)

	# Connect death signal for turn order removal (Task 1.9)
	unit.unit_died.connect(_on_unit_died)

	_units.append(unit)

	print("[Main] Spawned %s (%s) at grid position %s" % [
		unit_name,
		Unit.get_unit_display_name(type),
		grid_pos
	])

	return unit

# ===== TURN SYSTEM (Task 1.8) =====
func _start_battle() -> void:
	## Start the combat battle
	if not turn_order_panel:
		push_error("[Main] TurnOrderPanel not found!")
		return

	# Set combat grid reference on CombatManager (Task 2.7)
	CombatManager.set_combat_grid(combat_grid)

	# Start battle through CombatManager (creates TurnManager internally)
	CombatManager.start_battle(_units)
	print("[Main] Battle started")

func _connect_turn_signals() -> void:
	## Connect turn manager signals to UI
	CombatManager.battle_started.connect(_on_battle_started)
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_won.connect(_on_battle_won)    # Task 1.9
	CombatManager.battle_lost.connect(_on_battle_lost)  # Task 1.9

func _on_battle_started(units: Array[Unit]) -> void:
	## Handle battle start - initialize turn order panel
	turn_order_panel.initialize_turn_order(units)

func _on_turn_ended(_unit: Unit) -> void:
	## Handle turn end - advance turn order panel
	turn_order_panel.advance_turn()

	# Check if we need to re-initialize for new round
	# This happens when the panel is empty (all units acted)
	if turn_order_panel.get_turn_order().is_empty():
		# Get fresh turn order from TurnManager for the new round
		var turn_order = CombatManager.get_turn_order()
		if not turn_order.is_empty():
			turn_order_panel.initialize_turn_order(turn_order)

# ===== COMBAT SIGNAL HANDLING (Task 1.5) =====
func _connect_combat_signals() -> void:
	## Connect to CombatManager signals for movement handling
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.movement_finished.connect(_on_unit_movement_finished)

func _on_unit_selected(unit: Unit) -> void:
	## Show movement range when a unit is selected
	if unit and not unit.is_moving() and CombatManager.is_waiting_for_input():
		combat_grid.update_occupied_tiles(_units)
		combat_grid.show_movement_range(unit.grid_position, unit.movement_range, unit)

func _on_unit_deselected(_unit: Unit) -> void:
	## Clear movement overlay when unit is deselected
	combat_grid.clear_movement_overlay()
	_last_hovered_tile = Vector2i(-1, -1)

func _on_unit_movement_finished(unit: Unit) -> void:
	## Update occupied tiles after movement completes
	combat_grid.update_occupied_tiles(_units)
	# Movement range is not re-shown (can only move once per turn)
	# Unit remains selected for potential attack action

func _update_path_preview_on_hover() -> void:
	## Update path preview based on mouse position
	var selected = CombatManager.get_selected_unit()
	if selected == null or selected.is_moving() or not CombatManager.is_waiting_for_input():
		return

	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	# Only update if hovered tile changed
	if grid_pos == _last_hovered_tile:
		return

	_last_hovered_tile = grid_pos

	# Check if this is a valid move tile
	if combat_grid.is_valid_move_tile(grid_pos):
		combat_grid.show_path_preview(selected.grid_position, grid_pos, selected)
	else:
		combat_grid.hide_path_preview()

# ===== PUBLIC API =====
func get_all_units() -> Array[Unit]:
	## Get all units in the scene
	return _units

func get_party_units() -> Array[Unit]:
	## Get all friendly (party) units
	return _units.filter(func(u): return u.is_friendly())

func get_enemy_units() -> Array[Unit]:
	## Get all enemy units
	return _units.filter(func(u): return u.is_enemy)

func get_unit_at_grid_pos(pos: Vector2i) -> Unit:
	## Get unit at specified grid position, or null
	for unit in _units:
		if unit.grid_position == pos:
			return unit
	return null

# ===== GRID CLICK HANDLING (Task 1.4 & 1.5) =====
func _handle_grid_click() -> void:
	## Handle clicks on tiles for movement and deselection
	## This is called when click wasn't consumed by a Unit's Area2D
	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	# Don't process clicks during movement
	if CombatManager.is_unit_moving():
		return

	# Don't process grid clicks when in ability targeting mode (Task 2.3)
	# Unit Area2D handles targeting clicks
	if CombatManager.is_targeting_ability():
		var unit = get_unit_at_grid_pos(grid_pos)
		if unit == null:
			# Clicking empty tile during targeting cancels it
			CombatManager.cancel_ability_targeting()
		# If clicking on a unit, their Area2D will handle it
		return

	# Check if click is outside grid bounds
	if not _is_valid_grid_pos(grid_pos):
		CombatManager.deselect_unit()
		return

	var selected = CombatManager.get_selected_unit()

	# Task 1.5: Handle movement clicks
	if selected and combat_grid.is_valid_move_tile(grid_pos):
		# Get path and start movement
		var path = combat_grid.pathfinding.get_path(selected.grid_position, grid_pos, selected)
		if path.size() >= 2:
			CombatManager.start_unit_movement(selected, path)
			return

	# Check if there's a unit at this position
	var unit = get_unit_at_grid_pos(grid_pos)
	if unit == null:
		# Clicked empty tile (not valid move) - deselect
		CombatManager.deselect_unit()
	# Note: If unit exists, their Area2D should have handled the click
	# This is a fallback in case the click missed the Area2D

# ===== ATTACK HANDLING (Task 1.7) =====
func _handle_attack_click() -> void:
	## Handle right-click to attack adjacent enemy
	var selected = CombatManager.get_selected_unit()
	if selected == null:
		return

	# Don't attack during movement or if not waiting for input
	if selected.is_moving() or not CombatManager.is_waiting_for_input():
		return

	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	# Find unit at clicked position
	var target = get_unit_at_grid_pos(grid_pos)
	if target == null:
		return

	# Attempt attack (CombatManager validates adjacency, turn, etc.)
	if CombatManager.attempt_attack(selected, target):
		# Attack succeeded - update occupied tiles in case of death
		combat_grid.update_occupied_tiles(_units.filter(func(u): return u.is_alive()))
		# Clear movement overlay since turn ended
		combat_grid.clear_movement_overlay()

# ===== BATTLE RESULT POPUP (Task 1.9) =====
func _setup_battle_result_popup() -> void:
	## Create and configure the battle result popup
	_battle_result_popup = BattleResultPopupScene.instantiate() as BattleResultPopup
	add_child(_battle_result_popup)

	# Connect popup signals
	_battle_result_popup.continue_pressed.connect(_on_continue_pressed)
	_battle_result_popup.retry_pressed.connect(_on_retry_pressed)

	print("[Main] Battle result popup initialized")

func _on_unit_died(unit: Unit) -> void:
	## Handle unit death - remove from turn order
	var turn_manager = CombatManager.get_turn_manager()
	if turn_manager:
		turn_manager.remove_unit(unit)

	# Remove from our units list
	var index = _units.find(unit)
	if index != -1:
		_units.remove_at(index)

	print("[Main] Unit died: %s" % unit.unit_name)

func _on_battle_won(gold_earned: int) -> void:
	## Handle victory - show popup
	print("[Main] Victory! Gold earned: %d" % gold_earned)
	if _battle_result_popup:
		_battle_result_popup.show_victory(gold_earned)

func _on_battle_lost() -> void:
	## Handle defeat - show popup
	print("[Main] Defeat!")
	if _battle_result_popup:
		_battle_result_popup.show_defeat()

func _on_continue_pressed() -> void:
	## Handle continue button (victory)
	print("[Main] Continue pressed - battle complete")
	# For now, just log. In Phase 3, this would return to hub/contract selection

func _on_retry_pressed() -> void:
	## Handle retry button (defeat) - restart battle
	print("[Main] Retry pressed - restarting battle")
	_restart_battle()

func _restart_battle() -> void:
	## Restart the battle from scratch
	print("[Main] Restarting battle...")

	# Clear existing units
	for unit in _units.duplicate():
		if is_instance_valid(unit):
			unit.queue_free()
	_units.clear()

	# Wait a frame for cleanup
	await get_tree().process_frame

	# Respawn units from initial data
	for data in _initial_spawn_data:
		var unit = _spawn_unit(data["type"], data["pos"], data["name"])
		# Task 2.8: Set soldier order if specified
		if data.has("order") and unit.is_soldier:
			unit.set_order(data["order"])

	# Update pathfinding
	combat_grid.update_occupied_tiles(_units)

	# Start new battle
	CombatManager.start_battle(_units)
	print("[Main] Battle restarted with %d units" % _units.size())

# ===== DEBUG FUNCTIONS (Task 1.3) =====
func _get_unit_under_mouse() -> Unit:
	## Get the unit currently under the mouse cursor
	var mouse_pos = get_global_mouse_position()
	var grid_pos = combat_grid.world_to_grid(mouse_pos)

	# Check if the grid position is valid
	if not _is_valid_grid_pos(grid_pos):
		return null

	return get_unit_at_grid_pos(grid_pos)

func _is_valid_grid_pos(pos: Vector2i) -> bool:
	## Check if a grid position is within bounds
	var grid_size = combat_grid.get_grid_size()
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func _debug_damage_hovered_unit() -> void:
	## Deal debug damage to the unit under the mouse cursor
	var unit = _get_unit_under_mouse()
	if unit and unit.is_alive():
		unit.take_damage(DEBUG_DAMAGE_AMOUNT)
		print("[Debug] Dealt %d damage to %s (HP: %d/%d, %.0f%%)" % [
			DEBUG_DAMAGE_AMOUNT,
			unit.unit_name,
			unit.current_hp,
			unit.max_hp,
			unit.get_hp_percentage() * 100
		])
	else:
		print("[Debug] No unit under cursor to damage")

func _debug_heal_hovered_unit() -> void:
	## Heal the unit under the mouse cursor
	var unit = _get_unit_under_mouse()
	if unit and unit.is_alive():
		unit.heal(DEBUG_HEAL_AMOUNT)
		print("[Debug] Healed %d HP to %s (HP: %d/%d, %.0f%%)" % [
			DEBUG_HEAL_AMOUNT,
			unit.unit_name,
			unit.current_hp,
			unit.max_hp,
			unit.get_hp_percentage() * 100
		])
	else:
		print("[Debug] No unit under cursor to heal")

func _debug_end_turn() -> void:
	## End the current turn (debug shortcut)
	if CombatManager.is_battle_active():
		var current_unit = CombatManager.get_current_turn_unit()
		if current_unit and current_unit.is_friendly():
			print("[Debug] Manually ending turn for %s" % current_unit.unit_name)
			CombatManager.end_current_turn()
		else:
			print("[Debug] Cannot end turn - not a friendly unit's turn")
