## DamageNumber - Floating damage text that animates and fades
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.7-basic-melee-attack.md
class_name DamageNumber
extends Node2D

# ===== CONSTANTS =====
const FLOAT_DISTANCE: float = 50.0
const FLOAT_DURATION: float = 1.0
const FADE_START: float = 0.7

const COLOR_DAMAGE: Color = Color("#e74c3c")   # Red
const COLOR_MISS: Color = Color("#bdc3c7")     # Gray
const COLOR_CRITICAL: Color = Color("#f1c40f") # Gold
const COLOR_HEAL: Color = Color("#27ae60")     # Green - Task 2.6
const COLOR_HOLY: Color = Color("#f4d03f")     # Light gold - Task 2.6 (Smite)

const FONT_SIZE_NORMAL: int = 24
const FONT_SIZE_CRITICAL: int = 32

# ===== NODE REFERENCES =====
@onready var label: Label = $Label

# ===== LIFECYCLE =====
func _ready() -> void:
	# Ensure label exists
	if not label:
		push_error("[DamageNumber] Label node not found!")

# ===== PUBLIC API =====
func show_damage(amount: int, is_critical: bool = false) -> void:
	## Display damage number and animate
	if not label:
		return

	label.text = str(amount)

	if is_critical:
		label.add_theme_color_override("font_color", COLOR_CRITICAL)
		label.add_theme_font_size_override("font_size", FONT_SIZE_CRITICAL)
	else:
		label.add_theme_color_override("font_color", COLOR_DAMAGE)
		label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)

	_animate()

func show_miss() -> void:
	## Display miss text and animate
	if not label:
		return

	label.text = "MISS"
	label.add_theme_color_override("font_color", COLOR_MISS)
	label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)
	_animate()

func show_damage_colored(amount: int, is_critical: bool, color: Color) -> void:
	## Display damage number with custom color (Task 2.5: Backstab)
	if not label:
		return

	label.text = str(amount)
	label.add_theme_color_override("font_color", color)

	if is_critical:
		label.add_theme_font_size_override("font_size", FONT_SIZE_CRITICAL)
	else:
		label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)

	_animate()

func show_heal(amount: int) -> void:
	## Display healing number in green (Task 2.6: Matthias Heal)
	if not label:
		return

	label.text = "+" + str(amount)
	label.add_theme_color_override("font_color", COLOR_HEAL)
	label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)
	_animate()

func show_holy_damage(amount: int) -> void:
	## Display holy damage number in light gold (Task 2.6: Smite)
	if not label:
		return

	label.text = str(amount)
	label.add_theme_color_override("font_color", COLOR_HOLY)
	label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)
	_animate()

func show_text(text: String, color: Color) -> void:
	## Display custom text with custom color (Task 2.6: Full HP, etc.)
	if not label:
		return

	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", FONT_SIZE_NORMAL)
	_animate()

# ===== INTERNAL =====
func _animate() -> void:
	## Float up and fade out
	var tween = create_tween()
	tween.set_parallel(true)

	# Float up
	tween.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, FLOAT_DURATION)

	# Fade out (start fading at FADE_START)
	tween.tween_property(self, "modulate:a", 0.0, FLOAT_DURATION - FADE_START).set_delay(FADE_START)

	# Remove when done
	tween.chain().tween_callback(queue_free)
