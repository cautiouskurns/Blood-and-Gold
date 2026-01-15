## TutorialManager - Controls tutorial popup display and trigger logic
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.3-merchants-escort-tutorial-contract.md
class_name TutorialManager
extends Node

# ===== SIGNALS =====
signal tutorial_step_completed(step_id: String)
signal all_tutorials_complete()

# ===== TUTORIAL STEPS =====
enum TutorialStep {
	SELECT_UNIT,
	MOVEMENT,
	ATTACK,
	SOLDIER_ORDERS,
	COMPLETE
}

# Step configuration
const TUTORIAL_STEPS: Dictionary = {
	TutorialStep.SELECT_UNIT: {
		"id": "select_unit",
		"text": "Welcome to combat! Click a unit to select them.",
		"trigger": "combat_start",
		"highlight": "party_units"
	},
	TutorialStep.MOVEMENT: {
		"id": "movement",
		"text": "Blue tiles show where you can move. Click to move.",
		"trigger": "unit_selected",
		"highlight": "valid_tiles"
	},
	TutorialStep.ATTACK: {
		"id": "attack",
		"text": "Right-click an enemy to attack when adjacent.",
		"trigger": "unit_moved",
		"highlight": "enemy_units"
	},
	TutorialStep.SOLDIER_ORDERS: {
		"id": "orders",
		"text": "Your soldiers follow orders. Try the Order Panel on the right.",
		"trigger": "first_attack",
		"highlight": "order_panel"
	}
}

# ===== CONSTANTS =====
const AUTO_DISMISS_DELAY: float = 10.0  # Seconds before auto-dismiss

# ===== NODE REFERENCES =====
var _popup: TutorialPopup = null

# ===== INTERNAL STATE =====
var _current_step: TutorialStep = TutorialStep.SELECT_UNIT
var _completed_steps: Dictionary = {}  # step_id -> bool
var _is_active: bool = false
var _auto_dismiss_timer: Timer = null

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_auto_dismiss_timer()
	print("[TutorialManager] Initialized")

func _setup_auto_dismiss_timer() -> void:
	_auto_dismiss_timer = Timer.new()
	_auto_dismiss_timer.one_shot = true
	_auto_dismiss_timer.timeout.connect(_on_auto_dismiss_timeout)
	add_child(_auto_dismiss_timer)

# ===== PUBLIC API =====
func set_popup(popup: TutorialPopup) -> void:
	## Set the tutorial popup reference
	_popup = popup
	if _popup:
		_popup.popup_dismissed.connect(_on_popup_dismissed)
		print("[TutorialManager] Popup connected")

func start_tutorial() -> void:
	## Begin the tutorial sequence
	_is_active = true
	_current_step = TutorialStep.SELECT_UNIT
	_completed_steps.clear()
	print("[TutorialManager] Tutorial started")

func stop_tutorial() -> void:
	## End the tutorial (e.g., player skipped)
	_is_active = false
	_hide_popup()
	print("[TutorialManager] Tutorial stopped")

func is_active() -> bool:
	return _is_active

func has_completed_step(step_id: String) -> bool:
	## Check if a specific tutorial step has been completed
	return _completed_steps.get(step_id, false)

func has_completed_all() -> bool:
	## Check if all tutorial steps are complete
	return _current_step == TutorialStep.COMPLETE

# ===== TRIGGER HANDLERS =====
func on_combat_start() -> void:
	## Called when combat begins
	if not _is_active:
		return
	if _current_step == TutorialStep.SELECT_UNIT:
		_show_step(TutorialStep.SELECT_UNIT)

func on_unit_selected(_unit: Unit) -> void:
	## Called when a unit is selected
	if not _is_active:
		return

	# Complete select step if showing
	if _current_step == TutorialStep.SELECT_UNIT:
		_complete_step(TutorialStep.SELECT_UNIT)
		_advance_to_step(TutorialStep.MOVEMENT)
		_show_step(TutorialStep.MOVEMENT)

func on_unit_moved(_unit: Unit) -> void:
	## Called when a unit moves
	if not _is_active:
		return

	# Complete movement step if showing
	if _current_step == TutorialStep.MOVEMENT:
		_complete_step(TutorialStep.MOVEMENT)
		_advance_to_step(TutorialStep.ATTACK)
		_show_step(TutorialStep.ATTACK)

func on_attack_performed(_attacker: Unit, _target: Unit) -> void:
	## Called when an attack is performed
	if not _is_active:
		return

	# Complete attack step if showing
	if _current_step == TutorialStep.ATTACK:
		_complete_step(TutorialStep.ATTACK)
		_advance_to_step(TutorialStep.SOLDIER_ORDERS)
		_show_step(TutorialStep.SOLDIER_ORDERS)

func on_order_assigned(_unit: Unit, _order: int) -> void:
	## Called when a soldier order is assigned
	if not _is_active:
		return

	# Complete orders step if showing
	if _current_step == TutorialStep.SOLDIER_ORDERS:
		_complete_step(TutorialStep.SOLDIER_ORDERS)
		_advance_to_step(TutorialStep.COMPLETE)
		all_tutorials_complete.emit()
		print("[TutorialManager] All tutorial steps complete!")

# ===== INTERNAL METHODS =====
func _show_step(step: TutorialStep) -> void:
	## Display the popup for a tutorial step
	if not _popup:
		push_warning("[TutorialManager] No popup connected")
		return

	if step == TutorialStep.COMPLETE:
		return

	var step_data = TUTORIAL_STEPS.get(step, {})
	if step_data.is_empty():
		return

	_popup.show_tutorial(step_data["text"], step_data["highlight"])

	# Start auto-dismiss timer
	_auto_dismiss_timer.start(AUTO_DISMISS_DELAY)

	print("[TutorialManager] Showing step: %s" % step_data["id"])

func _hide_popup() -> void:
	## Hide the tutorial popup
	if _popup:
		_popup.hide_tutorial()
	_auto_dismiss_timer.stop()

func _complete_step(step: TutorialStep) -> void:
	## Mark a step as completed
	var step_data = TUTORIAL_STEPS.get(step, {})
	if step_data.is_empty():
		return

	_completed_steps[step_data["id"]] = true
	tutorial_step_completed.emit(step_data["id"])
	_hide_popup()
	print("[TutorialManager] Completed step: %s" % step_data["id"])

func _advance_to_step(step: TutorialStep) -> void:
	## Move to the next tutorial step
	_current_step = step

func _on_popup_dismissed() -> void:
	## Handle manual popup dismissal
	_auto_dismiss_timer.stop()

func _on_auto_dismiss_timeout() -> void:
	## Handle auto-dismiss timer expiry
	if _popup and _popup.is_showing():
		_popup.hide_tutorial()
		print("[TutorialManager] Auto-dismissed current step")
