## LoyaltyPopup - Shows loyalty change notifications
## Part of: Blood & Gold Prototype
## Task 3.5: Border Dispute
class_name LoyaltyPopup
extends CanvasLayer

# ===== SIGNALS =====
signal popup_closed()

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.3
const DISPLAY_DURATION: float = 2.5
const NUMBER_RISE_DISTANCE: float = 30.0

# Colors
const COLOR_POSITIVE: Color = Color("#27ae60")  # Green
const COLOR_NEGATIVE: Color = Color("#e74c3c")  # Red
const COLOR_NEUTRAL: Color = Color("#f1c40f")   # Yellow

# ===== NODE REFERENCES =====
@onready var panel: PanelContainer = $Panel
@onready var portrait: TextureRect = $Panel/MarginContainer/HBoxContainer/Portrait
@onready var info_container: VBoxContainer = $Panel/MarginContainer/HBoxContainer/InfoContainer
@onready var name_label: Label = $Panel/MarginContainer/HBoxContainer/InfoContainer/NameLabel
@onready var status_label: Label = $Panel/MarginContainer/HBoxContainer/InfoContainer/StatusLabel
@onready var delta_label: Label = $Panel/MarginContainer/HBoxContainer/InfoContainer/DeltaLabel
@onready var quote_label: Label = $Panel/MarginContainer/HBoxContainer/InfoContainer/QuoteLabel

# ===== INTERNAL STATE =====
var _queue: Array[Dictionary] = []
var _is_showing: bool = false
var _auto_close_timer: float = 0.0

# ===== LIFECYCLE =====
func _ready() -> void:
	panel.visible = false
	panel.modulate.a = 0.0
	print("[LoyaltyPopup] Initialized")

func _process(delta: float) -> void:
	if _is_showing and _auto_close_timer > 0:
		_auto_close_timer -= delta
		if _auto_close_timer <= 0:
			_close_current()

# ===== PUBLIC API =====
func show_loyalty_change(companion_id: String, delta: int, quote: String = "") -> void:
	## Queue a loyalty change notification
	var data = {
		"companion_id": companion_id,
		"delta": delta,
		"quote": quote if quote else LoyaltyManager.get_reaction_quote(companion_id, delta),
	}
	_queue.append(data)

	if not _is_showing:
		_show_next()

func show_multiple_changes(changes: Dictionary) -> void:
	## Show multiple loyalty changes in sequence
	## changes format: {"companion_id": delta, ...}
	for companion_id in changes.keys():
		var delta = changes[companion_id]
		show_loyalty_change(companion_id, delta)

func is_showing() -> bool:
	return _is_showing

# ===== INTERNAL METHODS =====
func _show_next() -> void:
	if _queue.is_empty():
		_is_showing = false
		popup_closed.emit()
		return

	var data = _queue.pop_front()
	_display_change(data)

func _display_change(data: Dictionary) -> void:
	var companion_id = data.companion_id as String
	var delta = data.delta as int
	var quote = data.quote as String

	_is_showing = true
	_auto_close_timer = DISPLAY_DURATION

	# Update name
	var display_name = companion_id.capitalize()
	name_label.text = display_name

	# Update status
	var status = LoyaltyManager.get_loyalty_status(companion_id)
	var loyalty = LoyaltyManager.get_loyalty(companion_id)
	status_label.text = "%s (%d)" % [status, loyalty]
	status_label.add_theme_color_override("font_color", LoyaltyManager.get_loyalty_color(companion_id))

	# Update delta with animation
	var sign_str = "+" if delta > 0 else ""
	delta_label.text = "%s%d LOYALTY" % [sign_str, delta]

	if delta > 0:
		delta_label.add_theme_color_override("font_color", COLOR_POSITIVE)
	elif delta < 0:
		delta_label.add_theme_color_override("font_color", COLOR_NEGATIVE)
	else:
		delta_label.add_theme_color_override("font_color", COLOR_NEUTRAL)

	# Update quote
	quote_label.text = "\"%s\"" % quote

	# Show panel with fade
	panel.visible = true
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)

	# Animate delta number rising
	delta_label.position.y = NUMBER_RISE_DISTANCE
	delta_label.modulate.a = 0.0
	var delta_tween = create_tween()
	delta_tween.set_parallel(true)
	delta_tween.tween_property(delta_label, "position:y", 0.0, FADE_DURATION * 2).set_ease(Tween.EASE_OUT)
	delta_tween.tween_property(delta_label, "modulate:a", 1.0, FADE_DURATION)

	print("[LoyaltyPopup] Showing: %s %s%d" % [companion_id, sign_str, delta])

func _close_current() -> void:
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func():
		panel.visible = false
		_show_next()
	)

func _on_click_to_close(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_showing:
				_auto_close_timer = 0
				_close_current()
