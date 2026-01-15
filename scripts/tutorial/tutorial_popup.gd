## TutorialPopup - UI component for displaying tutorial messages
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.3-merchants-escort-tutorial-contract.md
class_name TutorialPopup
extends CanvasLayer

# ===== SIGNALS =====
signal popup_dismissed()

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.3
const ARROW_BOUNCE_AMPLITUDE: float = 5.0
const ARROW_BOUNCE_SPEED: float = 3.0

# ===== COLORS =====
const COLOR_HIGHLIGHT: Color = Color("#3498db", 0.5)  # Soft blue glow

# ===== NODE REFERENCES =====
@onready var panel: PanelContainer = $Panel
@onready var message_label: Label = $Panel/MarginContainer/VBoxContainer/MessageLabel
@onready var dismiss_button: Button = $Panel/MarginContainer/VBoxContainer/DismissButton
@onready var arrow_indicator: Sprite2D = $ArrowIndicator

# ===== INTERNAL STATE =====
var _is_showing: bool = false
var _arrow_tween: Tween = null
var _current_highlight: String = ""

# ===== LIFECYCLE =====
func _ready() -> void:
	# Hide by default
	panel.visible = false
	panel.modulate.a = 0.0
	arrow_indicator.visible = false

	# Connect button
	if dismiss_button:
		dismiss_button.pressed.connect(_on_dismiss_pressed)

	print("[TutorialPopup] Initialized")

func _process(delta: float) -> void:
	# Update arrow animation if showing
	if arrow_indicator.visible:
		_animate_arrow(delta)

# ===== PUBLIC API =====
func show_tutorial(message: String, highlight_target: String = "") -> void:
	## Display the tutorial popup with message and optional highlight
	if message_label:
		message_label.text = message

	_current_highlight = highlight_target
	_position_for_highlight(highlight_target)

	# Show with fade animation
	panel.visible = true
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)

	_is_showing = true
	print("[TutorialPopup] Showing: %s" % message)

func hide_tutorial() -> void:
	## Hide the tutorial popup
	if not _is_showing:
		return

	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func(): panel.visible = false)

	arrow_indicator.visible = false
	_is_showing = false
	popup_dismissed.emit()

func is_showing() -> bool:
	return _is_showing

# ===== POSITIONING =====
func _position_for_highlight(highlight: String) -> void:
	## Position the popup based on what's being highlighted
	var viewport_size = get_viewport().get_visible_rect().size

	# Default position: center-bottom area
	var target_pos = Vector2(viewport_size.x / 2 - 200, viewport_size.y - 200)

	match highlight:
		"party_units":
			# Point to left side where party spawns
			target_pos = Vector2(250, viewport_size.y / 2 - 100)
			_show_arrow(Vector2(150, viewport_size.y / 2), Vector2(-1, 0))

		"valid_tiles":
			# Point to center grid area
			target_pos = Vector2(viewport_size.x / 2 - 200, viewport_size.y - 200)
			_hide_arrow()

		"enemy_units":
			# Point to right side where enemies spawn
			target_pos = Vector2(viewport_size.x - 500, viewport_size.y / 2 - 100)
			_show_arrow(Vector2(viewport_size.x - 200, viewport_size.y / 2), Vector2(1, 0))

		"order_panel":
			# Point to order panel (bottom-right)
			target_pos = Vector2(viewport_size.x - 500, viewport_size.y - 300)
			_show_arrow(Vector2(viewport_size.x - 150, viewport_size.y - 200), Vector2(1, 0))

		_:
			# Default center position
			target_pos = Vector2(viewport_size.x / 2 - 200, viewport_size.y / 2 - 50)
			_hide_arrow()

	panel.position = target_pos

func _show_arrow(arrow_pos: Vector2, direction: Vector2) -> void:
	## Show directional arrow pointing to highlight
	arrow_indicator.visible = true
	arrow_indicator.position = arrow_pos
	arrow_indicator.rotation = direction.angle()

func _hide_arrow() -> void:
	arrow_indicator.visible = false

func _animate_arrow(_delta: float) -> void:
	## Animate arrow with gentle bounce
	var time = Time.get_ticks_msec() / 1000.0
	var offset = sin(time * ARROW_BOUNCE_SPEED) * ARROW_BOUNCE_AMPLITUDE

	# Apply offset in arrow's facing direction
	var dir = Vector2.from_angle(arrow_indicator.rotation)
	arrow_indicator.position += dir * offset * 0.1

# ===== BUTTON HANDLERS =====
func _on_dismiss_pressed() -> void:
	hide_tutorial()
