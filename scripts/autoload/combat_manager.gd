## CombatManager - Global combat state management
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.4-click-to-select-unit.md
## Handles: Unit selection, movement (Task 1.5), turn management (future), combat flow (future)
extends Node

# ===== SIGNALS =====
signal unit_selected(unit: Unit)
signal unit_deselected(unit: Unit)
signal selection_changed(old_unit: Unit, new_unit: Unit)
signal movement_started(unit: Unit)
signal movement_finished(unit: Unit)

# ===== STATE =====
var selected_unit: Unit = null
var _moving_unit: Unit = null

# ===== LIFECYCLE =====
func _ready() -> void:
	print("[CombatManager] Initialized")

# ===== SELECTION API =====
func select_unit(unit: Unit) -> void:
	## Select a unit, deselecting any previously selected unit
	if unit == null:
		deselect_unit()
		return

	# Can only select friendly, living units
	if unit.is_enemy or not unit.is_alive():
		deselect_unit()
		return

	# Don't re-select already selected unit (but don't deselect either)
	if unit == selected_unit:
		return

	var old_unit = selected_unit

	# Deselect previous unit
	if selected_unit != null:
		selected_unit.deselect()
		unit_deselected.emit(selected_unit)

	# Select new unit
	selected_unit = unit
	selected_unit.select()
	unit_selected.emit(selected_unit)
	selection_changed.emit(old_unit, selected_unit)

	print("[CombatManager] Selected: %s" % unit.unit_name)

func deselect_unit() -> void:
	## Deselect the currently selected unit
	if selected_unit == null:
		return

	var old_unit = selected_unit
	selected_unit.deselect()
	selected_unit = null

	unit_deselected.emit(old_unit)
	selection_changed.emit(old_unit, null)

	print("[CombatManager] Deselected")

func get_selected_unit() -> Unit:
	## Get the currently selected unit (or null)
	return selected_unit

func has_selection() -> bool:
	## Check if any unit is selected
	return selected_unit != null

func is_unit_selected(unit: Unit) -> bool:
	## Check if a specific unit is selected
	return selected_unit == unit

# ===== MOVEMENT API (Task 1.5) =====
func start_unit_movement(unit: Unit, path: Array[Vector2i]) -> void:
	## Initiate unit movement along a path
	if unit == null or path.size() < 2:
		return

	# Don't allow movement if another unit is moving
	if is_unit_moving():
		print("[CombatManager] Cannot move - another unit is already moving")
		return

	_moving_unit = unit
	movement_started.emit(unit)

	# Connect to unit's movement finished signal
	unit.movement_finished.connect(_on_unit_movement_finished, CONNECT_ONE_SHOT)

	# Start the movement animation
	unit.move_along_path(path)

	print("[CombatManager] %s starting movement to %s" % [unit.unit_name, path[path.size() - 1]])

func _on_unit_movement_finished(unit: Unit) -> void:
	## Called when a unit completes its movement
	_moving_unit = null
	movement_finished.emit(unit)

	# Deselect after movement
	deselect_unit()

	print("[CombatManager] %s finished movement at %s" % [unit.unit_name, unit.grid_position])

func is_unit_moving() -> bool:
	## Check if any unit is currently moving
	return _moving_unit != null

func get_moving_unit() -> Unit:
	## Get the currently moving unit (or null)
	return _moving_unit
