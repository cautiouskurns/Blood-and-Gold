## Main - Game entry point and test setup
## Part of: Blood & Gold Prototype
extends Node2D

# ===== NODE REFERENCES =====
@onready var combat_grid: CombatGrid = $CombatGrid

# Preload Unit scene
const UnitScene = preload("res://scenes/combat/Unit.tscn")

# ===== DEBUG CONSTANTS =====
const DEBUG_DAMAGE_AMOUNT: int = 10
const DEBUG_HEAL_AMOUNT: int = 10

# ===== INTERNAL STATE =====
var _units: Array[Unit] = []
var _last_hovered_tile: Vector2i = Vector2i(-1, -1)

# ===== LIFECYCLE =====
func _ready() -> void:
	_spawn_test_units()
	_connect_combat_signals()
	print("[Main] Debug controls enabled: D = damage, H = heal (hover over unit)")

func _process(_delta: float) -> void:
	## Handle hover updates for path preview (Task 1.5)
	_update_path_preview_on_hover()

func _unhandled_input(event: InputEvent) -> void:
	## Handle debug input for HP bar testing (Task 1.3)
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D:
				_debug_damage_hovered_unit()
			KEY_H:
				_debug_heal_hovered_unit()

	## Handle grid clicks for movement and deselection (Task 1.4 & 1.5)
	## This only triggers if Unit's Area2D didn't consume the click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_grid_click()

func _spawn_test_units() -> void:
	## Spawn test units to verify Task 1.2 implementation
	print("[Main] Spawning test units...")

	# Spawn party members (left side of grid)
	_spawn_unit(Unit.UnitType.PLAYER, Vector2i(1, 5), "Player")
	_spawn_unit(Unit.UnitType.THORNE, Vector2i(1, 3), "Thorne")
	_spawn_unit(Unit.UnitType.LYRA, Vector2i(1, 7), "Lyra")
	_spawn_unit(Unit.UnitType.MATTHIAS, Vector2i(2, 5), "Matthias")

	# Spawn enemies (right side of grid)
	_spawn_unit(Unit.UnitType.ENEMY, Vector2i(10, 4), "Bandit 1")
	_spawn_unit(Unit.UnitType.ENEMY, Vector2i(10, 6), "Bandit 2")
	_spawn_unit(Unit.UnitType.ENEMY, Vector2i(9, 5), "Bandit 3")

	print("[Main] Test units spawned: %d total" % _units.size())

	# Update pathfinding with unit positions
	combat_grid.update_occupied_tiles(_units)

func _spawn_unit(type: Unit.UnitType, grid_pos: Vector2i, unit_name: String) -> Unit:
	## Spawn a unit at the specified grid position
	var unit = UnitScene.instantiate() as Unit
	unit.unit_type = type
	unit.unit_name = unit_name

	# Set enemy flag based on type
	unit.is_enemy = (type == Unit.UnitType.ENEMY)

	# Set HP based on unit type (from GDD)
	match type:
		Unit.UnitType.PLAYER:
			unit.max_hp = 35
		Unit.UnitType.THORNE:
			unit.max_hp = 40
		Unit.UnitType.LYRA:
			unit.max_hp = 25
		Unit.UnitType.MATTHIAS:
			unit.max_hp = 30
		Unit.UnitType.ENEMY:
			unit.max_hp = 15

	# Add to scene tree first (so _ready runs)
	add_child(unit)

	# Then set grid reference and position
	unit.set_combat_grid(combat_grid)
	unit.place_on_grid(grid_pos)

	_units.append(unit)

	print("[Main] Spawned %s (%s) at grid position %s" % [
		unit_name,
		Unit.get_unit_display_name(type),
		grid_pos
	])

	return unit

# ===== COMBAT SIGNAL HANDLING (Task 1.5) =====
func _connect_combat_signals() -> void:
	## Connect to CombatManager signals for movement handling
	CombatManager.unit_selected.connect(_on_unit_selected)
	CombatManager.unit_deselected.connect(_on_unit_deselected)
	CombatManager.movement_finished.connect(_on_unit_movement_finished)

func _on_unit_selected(unit: Unit) -> void:
	## Show movement range when a unit is selected
	if unit and not unit.is_moving():
		combat_grid.update_occupied_tiles(_units)
		combat_grid.show_movement_range(unit.grid_position, unit.movement_range, unit)

func _on_unit_deselected(_unit: Unit) -> void:
	## Clear movement overlay when unit is deselected
	combat_grid.clear_movement_overlay()
	_last_hovered_tile = Vector2i(-1, -1)

func _on_unit_movement_finished(unit: Unit) -> void:
	## Update occupied tiles after movement completes
	combat_grid.update_occupied_tiles(_units)

func _update_path_preview_on_hover() -> void:
	## Update path preview based on mouse position
	var selected = CombatManager.get_selected_unit()
	if selected == null or selected.is_moving():
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
