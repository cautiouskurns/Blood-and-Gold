## BattleResultPopup - Displays victory/defeat outcome
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.9-victory-defeat-detection.md
class_name BattleResultPopup
extends CanvasLayer

# ===== SIGNALS =====
signal continue_pressed()
signal retry_pressed()

# ===== CONSTANTS =====
const FADE_IN_DURATION: float = 0.3
const FADE_OUT_DURATION: float = 0.2

# Victory colors
const COLOR_VICTORY_TITLE: Color = Color("#f1c40f")
const COLOR_VICTORY_PANEL: Color = Color("#1a1a2e")
const COLOR_VICTORY_BORDER: Color = Color("#f1c40f")
const COLOR_VICTORY_BUTTON: Color = Color("#27ae60")

# Defeat colors
const COLOR_DEFEAT_TITLE: Color = Color("#c0392b")
const COLOR_DEFEAT_PANEL: Color = Color("#2e1a1a")
const COLOR_DEFEAT_BORDER: Color = Color("#c0392b")
const COLOR_DEFEAT_BUTTON: Color = Color("#e74c3c")

# ===== NODE REFERENCES =====
@onready var overlay: ColorRect = $Overlay
@onready var center_container: CenterContainer = $CenterContainer
@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var title_label: Label = $CenterContainer/Panel/VBoxContainer/TitleLabel
@onready var message_label: Label = $CenterContainer/Panel/VBoxContainer/MessageLabel
@onready var gold_container: HBoxContainer = $CenterContainer/Panel/VBoxContainer/GoldContainer
@onready var gold_label: Label = $CenterContainer/Panel/VBoxContainer/GoldContainer/GoldLabel
@onready var action_button: Button = $CenterContainer/Panel/VBoxContainer/ActionButton

# ===== INTERNAL STATE =====
var _is_victory: bool = false

# ===== LIFECYCLE =====
func _ready() -> void:
	visible = false
	action_button.pressed.connect(_on_action_button_pressed)

# ===== PUBLIC API =====
func show_victory(gold_earned: int) -> void:
	## Display victory result with gold reward
	_is_victory = true
	_setup_victory_visuals()
	title_label.text = "VICTORY!"
	message_label.text = "Battle Won!"
	gold_container.visible = true
	gold_label.text = "%dg" % gold_earned
	action_button.text = "Continue"
	_show_popup()
	print("[BattleResultPopup] Showing victory - %dg earned" % gold_earned)

func show_defeat() -> void:
	## Display defeat result with retry option
	_is_victory = false
	_setup_defeat_visuals()
	title_label.text = "DEFEAT"
	message_label.text = "Party Defeated"
	gold_container.visible = false
	action_button.text = "Retry"
	_show_popup()
	print("[BattleResultPopup] Showing defeat")

func hide_popup() -> void:
	## Hide the popup with animation (fade child controls since CanvasLayer has no modulate)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.tween_property(center_container, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.set_parallel(false)
	tween.tween_callback(func(): visible = false)

# ===== INTERNAL METHODS =====
func _show_popup() -> void:
	## Animate popup appearing (fade child controls since CanvasLayer has no modulate)
	overlay.modulate.a = 0.0
	center_container.modulate.a = 0.0
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, FADE_IN_DURATION)
	tween.tween_property(center_container, "modulate:a", 1.0, FADE_IN_DURATION)

func _setup_victory_visuals() -> void:
	## Configure colors for victory
	title_label.add_theme_color_override("font_color", COLOR_VICTORY_TITLE)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	_set_panel_style(COLOR_VICTORY_PANEL, COLOR_VICTORY_BORDER)
	_set_button_style(COLOR_VICTORY_BUTTON)

func _setup_defeat_visuals() -> void:
	## Configure colors for defeat
	title_label.add_theme_color_override("font_color", COLOR_DEFEAT_TITLE)
	message_label.add_theme_color_override("font_color", Color("#cccccc"))
	_set_panel_style(COLOR_DEFEAT_PANEL, COLOR_DEFEAT_BORDER)
	_set_button_style(COLOR_DEFEAT_BUTTON)

func _set_panel_style(bg_color: Color, border_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 40
	style.content_margin_right = 40
	style.content_margin_top = 30
	style.content_margin_bottom = 30
	panel.add_theme_stylebox_override("panel", style)

func _set_button_style(color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	action_button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.1)
	action_button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.1)
	action_button.add_theme_stylebox_override("pressed", pressed_style)

# ===== SIGNAL HANDLERS =====
func _on_action_button_pressed() -> void:
	## Handle action button click
	if _is_victory:
		continue_pressed.emit()
	else:
		retry_pressed.emit()
	hide_popup()

func _unhandled_input(event: InputEvent) -> void:
	## Allow ESC to dismiss popup
	if visible and event.is_action_pressed("ui_cancel"):
		_on_action_button_pressed()
		get_viewport().set_input_as_handled()
