## ChoicePanel - Displays branching choices for choice contracts
## Part of: Blood & Gold Prototype
## Task 3.5: Border Dispute
class_name ChoicePanel
extends CanvasLayer

# ===== SIGNALS =====
signal choice_selected(choice_id: String)
signal choice_hovered(choice_id: String)
signal choice_unhovered(choice_id: String)

# ===== CONSTANTS =====
const FADE_DURATION: float = 0.3
const HOVER_SCALE: float = 1.03

# Choice colors
const COLOR_OPTION_A: Color = Color("#c0392b")  # Red - combat/aggressive
const COLOR_OPTION_B: Color = Color("#2980b9")  # Blue - peaceful
const COLOR_OPTION_C: Color = Color("#f39c12")  # Gold - diplomatic

# ===== NODE REFERENCES =====
@onready var dim_background: ColorRect = $DimBackground
@onready var panel: PanelContainer = $Panel
@onready var header_label: Label = $Panel/MarginContainer/VBoxContainer/HeaderLabel
@onready var subheader_label: Label = $Panel/MarginContainer/VBoxContainer/SubheaderLabel
@onready var choices_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var option_a: Button = $Panel/MarginContainer/VBoxContainer/ChoicesContainer/OptionA
@onready var option_b: Button = $Panel/MarginContainer/VBoxContainer/ChoicesContainer/OptionB
@onready var option_c: Button = $Panel/MarginContainer/VBoxContainer/ChoicesContainer/OptionC
@onready var companion_opinions: VBoxContainer = $Panel/MarginContainer/VBoxContainer/CompanionOpinions
@onready var thorne_opinion: Label = $Panel/MarginContainer/VBoxContainer/CompanionOpinions/ThorneOpinion
@onready var matthias_opinion: Label = $Panel/MarginContainer/VBoxContainer/CompanionOpinions/MatthiasOpinion

# ===== INTERNAL STATE =====
var _is_showing: bool = false
var _choices_data: Dictionary = {}
var _selected_choice: String = ""

# ===== LIFECYCLE =====
func _ready() -> void:
	_hide_immediate()
	_connect_button_signals()
	print("[ChoicePanel] Initialized")

func _connect_button_signals() -> void:
	if option_a:
		option_a.pressed.connect(func(): _on_choice_pressed("A"))
		option_a.mouse_entered.connect(func(): _on_choice_hovered("A"))
		option_a.mouse_exited.connect(func(): _on_choice_unhovered("A"))

	if option_b:
		option_b.pressed.connect(func(): _on_choice_pressed("B"))
		option_b.mouse_entered.connect(func(): _on_choice_hovered("B"))
		option_b.mouse_exited.connect(func(): _on_choice_unhovered("B"))

	if option_c:
		option_c.pressed.connect(func(): _on_choice_pressed("C"))
		option_c.mouse_entered.connect(func(): _on_choice_hovered("C"))
		option_c.mouse_exited.connect(func(): _on_choice_unhovered("C"))

# ===== PUBLIC API =====
func show_choices(header: String, subheader: String, choices: Dictionary, opinions: Dictionary = {}) -> void:
	## Display the choice panel
	## choices format: {"A": {label, description, gold, has_combat, ...}, ...}
	## opinions format: {"thorne": "quote", "matthias": "quote"}

	_choices_data = choices
	_selected_choice = ""

	# Update header
	if header_label:
		header_label.text = header

	if subheader_label:
		subheader_label.text = subheader

	# Update choice buttons
	_update_choice_button(option_a, choices.get("A", {}), COLOR_OPTION_A)
	_update_choice_button(option_b, choices.get("B", {}), COLOR_OPTION_B)
	_update_choice_button(option_c, choices.get("C", {}), COLOR_OPTION_C)

	# Update companion opinions
	if thorne_opinion:
		var thorne_text = opinions.get("thorne", "")
		thorne_opinion.text = "Thorne: \"%s\"" % thorne_text if thorne_text else ""
		thorne_opinion.visible = not thorne_text.is_empty()

	if matthias_opinion:
		var matthias_text = opinions.get("matthias", "")
		matthias_opinion.text = "Matthias: \"%s\"" % matthias_text if matthias_text else ""
		matthias_opinion.visible = not matthias_text.is_empty()

	# Show with fade
	_show_animated()

func hide_choices() -> void:
	## Hide the choice panel
	_hide_animated()

func is_showing() -> bool:
	return _is_showing

func get_selected_choice() -> String:
	return _selected_choice

func show_reduced_choices(excluded_choice: String) -> void:
	## Show only A and B (used after CHA check failure)
	match excluded_choice:
		"A":
			if option_a:
				option_a.visible = false
		"B":
			if option_b:
				option_b.visible = false
		"C":
			if option_c:
				option_c.visible = false

# ===== INTERNAL METHODS =====
func _update_choice_button(button: Button, data: Dictionary, color: Color) -> void:
	if not button:
		return

	if data.is_empty():
		button.visible = false
		return

	button.visible = true

	var label = data.get("label", "Unknown")
	var gold = data.get("gold_reward", 0)
	var has_combat = data.get("has_combat", false)
	var requires_check = data.get("requires_check", "")
	var check_dc = data.get("check_dc", 0)

	# Build button text
	var text_lines = [label]
	text_lines.append("")  # Spacer
	text_lines.append("%d gold" % gold)

	if has_combat:
		text_lines.append("Combat: Yes")
	else:
		text_lines.append("Combat: No")

	if requires_check:
		text_lines.append("%s DC %d" % [requires_check, check_dc])

	button.text = "\n".join(text_lines)

	# Apply color tint to button
	button.modulate = Color.WHITE.lerp(color, 0.3)

	# Store tooltip
	var description = data.get("description", "")
	button.tooltip_text = description

func _on_choice_pressed(choice_id: String) -> void:
	_selected_choice = choice_id
	print("[ChoicePanel] Choice selected: %s" % choice_id)
	choice_selected.emit(choice_id)

func _on_choice_hovered(choice_id: String) -> void:
	var button = _get_button_for_choice(choice_id)
	if button:
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.1)
	choice_hovered.emit(choice_id)

func _on_choice_unhovered(choice_id: String) -> void:
	var button = _get_button_for_choice(choice_id)
	if button:
		var tween = create_tween()
		tween.tween_property(button, "scale", Vector2.ONE, 0.1)
	choice_unhovered.emit(choice_id)

func _get_button_for_choice(choice_id: String) -> Button:
	match choice_id:
		"A": return option_a
		"B": return option_b
		"C": return option_c
	return null

func _show_animated() -> void:
	_is_showing = true
	dim_background.visible = true
	panel.visible = true

	dim_background.modulate.a = 0.0
	panel.modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dim_background, "modulate:a", 1.0, FADE_DURATION)
	tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)

func _hide_animated() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dim_background, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_DURATION)
	tween.chain().tween_callback(func():
		_is_showing = false
		dim_background.visible = false
		panel.visible = false
	)

func _hide_immediate() -> void:
	_is_showing = false
	dim_background.visible = false
	panel.visible = false
