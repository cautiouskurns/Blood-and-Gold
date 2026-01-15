## ContractCard - Individual contract card component for Contract Board
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.2-contract-board-ui.md
class_name ContractCard
extends PanelContainer

# ===== SIGNALS =====
signal card_clicked(contract: Contract)
signal card_hovered(contract: Contract)
signal card_unhovered(contract: Contract)

# ===== CONSTANTS =====
const CARD_WIDTH: int = 300
const CARD_HEIGHT: int = 150

# Colors
const COLOR_BACKGROUND: Color = Color("#2a2a3a")
const COLOR_BORDER_DEFAULT: Color = Color("#4a4a5a")
const COLOR_BORDER_HOVER: Color = Color("#7a7a8a")
const COLOR_BORDER_SELECTED: Color = Color("#f1c40f")
const COLOR_GOLD: Color = Color("#f1c40f")

# ===== EXPORTED PROPERTIES =====
@export var contract: Contract = null

# ===== INTERNAL STATE =====
var _is_hovered: bool = false
var _is_selected: bool = false
var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat

# ===== NODE REFERENCES =====
@onready var contract_name_label: Label = $MarginContainer/VBoxContainer/ContractName
@onready var brief_description_label: Label = $MarginContainer/VBoxContainer/BriefDescription
@onready var gold_amount_label: Label = $MarginContainer/VBoxContainer/FooterRow/RewardDisplay/GoldAmount
@onready var difficulty_stars_label: Label = $MarginContainer/VBoxContainer/FooterRow/DifficultyStars

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_styles()
	_connect_signals()
	if contract:
		display_contract(contract)

func _setup_styles() -> void:
	## Create and configure style boxes for different states
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = COLOR_BACKGROUND
	_style_normal.border_color = COLOR_BORDER_DEFAULT
	_style_normal.set_border_width_all(2)
	_style_normal.set_corner_radius_all(8)

	_style_hover = StyleBoxFlat.new()
	_style_hover.bg_color = COLOR_BACKGROUND.lightened(0.05)
	_style_hover.border_color = COLOR_BORDER_HOVER
	_style_hover.set_border_width_all(3)
	_style_hover.set_corner_radius_all(8)

	add_theme_stylebox_override("panel", _style_normal)

	# Set minimum size
	custom_minimum_size = Vector2(CARD_WIDTH, CARD_HEIGHT)

func _connect_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

# ===== PUBLIC API =====
func display_contract(contract_data: Contract) -> void:
	## Update the card display with contract data
	contract = contract_data

	if not is_inside_tree():
		await ready

	if contract_name_label:
		contract_name_label.text = contract.display_name.to_upper()

	if brief_description_label:
		brief_description_label.text = contract.brief_description

	if gold_amount_label:
		gold_amount_label.text = contract.get_reward_display()
		gold_amount_label.add_theme_color_override("font_color", COLOR_GOLD)

	if difficulty_stars_label:
		difficulty_stars_label.text = contract.get_difficulty_stars()
		difficulty_stars_label.add_theme_color_override("font_color", contract.get_difficulty_color())

func set_selected(selected: bool) -> void:
	## Set whether this card is selected (detail view open)
	_is_selected = selected
	_update_visual_state()

func get_contract() -> Contract:
	## Return the contract data
	return contract

# ===== INPUT HANDLING =====
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_card_clicked()

func _on_card_clicked() -> void:
	print("[ContractCard] Card clicked: %s" % contract.display_name if contract else "No contract")
	if contract:
		card_clicked.emit(contract)

# ===== HOVER HANDLING =====
func _on_mouse_entered() -> void:
	_is_hovered = true
	_update_visual_state()
	if contract:
		card_hovered.emit(contract)

func _on_mouse_exited() -> void:
	_is_hovered = false
	_update_visual_state()
	if contract:
		card_unhovered.emit(contract)

func _update_visual_state() -> void:
	## Update visual appearance based on hover/selected state
	if _is_selected:
		var selected_style = StyleBoxFlat.new()
		selected_style.bg_color = COLOR_BACKGROUND.lightened(0.08)
		selected_style.border_color = COLOR_BORDER_SELECTED
		selected_style.set_border_width_all(3)
		selected_style.set_corner_radius_all(8)
		add_theme_stylebox_override("panel", selected_style)
	elif _is_hovered:
		add_theme_stylebox_override("panel", _style_hover)
		# Subtle scale effect
		scale = Vector2(1.02, 1.02)
		pivot_offset = size / 2
	else:
		add_theme_stylebox_override("panel", _style_normal)
		scale = Vector2(1.0, 1.0)
