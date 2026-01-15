## FortManagement - Fort upgrade purchase screen
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.6-fort-management-screen.md
extends BaseHubScreen

# ===== SIGNALS =====
signal upgrade_purchased(upgrade_id: String)

# ===== CONSTANTS =====
const UPGRADES := {
	"barracks": {
		"name": "BARRACKS",
		"description": "+4 Soldier Capacity",
		"cost": 500,
	},
	"training_yard": {
		"name": "TRAINING YARD",
		"description": "+50% XP Gain",
		"cost": 600,
	},
	"tavern": {
		"name": "TAVERN",
		"description": "Better Quality Recruits",
		"cost": 300,
	}
}

# Visual states
const COLOR_AVAILABLE := Color("#ffffff")
const COLOR_UNAFFORDABLE := Color("#666666")
const COLOR_PURCHASED := Color("#27ae60")
const COLOR_COST_NORMAL := Color("#f39c12")
const COLOR_COST_UNAFFORDABLE := Color("#c0392b")

# ===== NODE REFERENCES =====
@onready var gold_display: Label = $TopBar/GoldDisplay/GoldAmount
@onready var upgrades_container: VBoxContainer = $ContentPanel/ScrollContainer/UpgradesContainer
@onready var confirmation_dialog: Panel = $ConfirmationDialog
@onready var confirm_message: Label = $ConfirmationDialog/VBoxContainer/MessageLabel
@onready var confirm_button: Button = $ConfirmationDialog/VBoxContainer/ButtonContainer/ConfirmButton
@onready var cancel_button: Button = $ConfirmationDialog/VBoxContainer/ButtonContainer/CancelButton

# Upgrade card references (created dynamically)
var _upgrade_cards: Dictionary = {}

# ===== STATE =====
var _pending_upgrade: String = ""

# ===== LIFECYCLE =====
func _setup_screen() -> void:
	set_title("FORT MANAGEMENT")
	_create_upgrade_cards()
	_update_gold_display()
	_refresh_all_cards()
	_hide_confirmation()

	# Connect to GameState gold changes
	if not GameState.gold_changed.is_connected(_on_gold_changed):
		GameState.gold_changed.connect(_on_gold_changed)

	# Connect confirmation dialog buttons
	confirm_button.pressed.connect(_on_confirm_purchase)
	cancel_button.pressed.connect(_hide_confirmation)

	print("[FortManagement] Initialized")

func _create_upgrade_cards() -> void:
	## Create upgrade cards from UPGRADES data
	for upgrade_id in UPGRADES:
		var upgrade_data = UPGRADES[upgrade_id]
		var card = _create_card(upgrade_id, upgrade_data)
		upgrades_container.add_child(card)
		_upgrade_cards[upgrade_id] = card

func _create_card(upgrade_id: String, data: Dictionary) -> PanelContainer:
	## Create a single upgrade card
	var card := PanelContainer.new()
	card.name = upgrade_id.capitalize().replace("_", "") + "Card"
	card.custom_minimum_size = Vector2(0, 120)

	# Card margin
	var margin := MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	card.add_child(margin)

	# Main horizontal layout
	var hbox := HBoxContainer.new()
	hbox.name = "HBoxContainer"
	margin.add_child(hbox)

	# Left side - Info
	var info_vbox := VBoxContainer.new()
	info_vbox.name = "InfoContainer"
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# Name label
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = data.name
	name_label.add_theme_font_size_override("font_size", 24)
	info_vbox.add_child(name_label)

	# Description label
	var desc_label := Label.new()
	desc_label.name = "DescriptionLabel"
	desc_label.text = data.description
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.modulate = Color(0.8, 0.8, 0.8, 1.0)
	info_vbox.add_child(desc_label)

	# Right side - Cost and status
	var right_vbox := VBoxContainer.new()
	right_vbox.name = "CostContainer"
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	right_vbox.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(right_vbox)

	# Cost label
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "%d GOLD" % data.cost
	cost_label.add_theme_font_size_override("font_size", 20)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", COLOR_COST_NORMAL)
	right_vbox.add_child(cost_label)

	# Status label (for PURCHASED badge)
	var status_label := Label.new()
	status_label.name = "StatusLabel"
	status_label.text = ""
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", COLOR_PURCHASED)
	status_label.visible = false
	right_vbox.add_child(status_label)

	# Make card clickable
	card.gui_input.connect(_on_card_input.bind(upgrade_id))
	card.mouse_entered.connect(_on_card_hover_enter.bind(upgrade_id))
	card.mouse_exited.connect(_on_card_hover_exit.bind(upgrade_id))

	return card

# ===== UI UPDATES =====
func _update_gold_display() -> void:
	gold_display.text = "%d" % GameState.get_gold()

func _refresh_all_cards() -> void:
	## Update all upgrade cards based on current state
	for upgrade_id in _upgrade_cards:
		_update_card_state(upgrade_id)

func _update_card_state(upgrade_id: String) -> void:
	## Update a single card's visual state
	var card: PanelContainer = _upgrade_cards[upgrade_id]
	var data: Dictionary = UPGRADES[upgrade_id]
	var is_owned := GameState.has_upgrade(upgrade_id)
	var can_afford := GameState.can_afford(data.cost)

	# Get labels
	var name_label: Label = card.get_node("MarginContainer/HBoxContainer/InfoContainer/NameLabel")
	var cost_label: Label = card.get_node("MarginContainer/HBoxContainer/CostContainer/CostLabel")
	var status_label: Label = card.get_node("MarginContainer/HBoxContainer/CostContainer/StatusLabel")

	if is_owned:
		# Purchased state
		name_label.modulate = COLOR_PURCHASED
		cost_label.visible = false
		status_label.text = "PURCHASED"
		status_label.visible = true
		card.modulate = Color(0.8, 0.8, 0.8, 1.0)
	elif can_afford:
		# Available state
		name_label.modulate = COLOR_AVAILABLE
		cost_label.visible = true
		cost_label.add_theme_color_override("font_color", COLOR_COST_NORMAL)
		status_label.visible = false
		card.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		# Unaffordable state
		name_label.modulate = COLOR_UNAFFORDABLE
		cost_label.visible = true
		cost_label.add_theme_color_override("font_color", COLOR_COST_UNAFFORDABLE)
		status_label.visible = false
		card.modulate = Color(0.6, 0.6, 0.6, 1.0)

func _on_gold_changed(_new_amount: int) -> void:
	_update_gold_display()
	_refresh_all_cards()

# ===== CARD INTERACTION =====
func _on_card_input(event: InputEvent, upgrade_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_card_clicked(upgrade_id)

func _on_card_clicked(upgrade_id: String) -> void:
	## Handle click on an upgrade card
	var data: Dictionary = UPGRADES[upgrade_id]

	# Check if already owned
	if GameState.has_upgrade(upgrade_id):
		print("[FortManagement] %s already purchased" % upgrade_id)
		return

	# Check if can afford
	if not GameState.can_afford(data.cost):
		print("[FortManagement] Cannot afford %s (need %d, have %d)" % [upgrade_id, data.cost, GameState.get_gold()])
		_shake_card(upgrade_id)
		return

	# Show confirmation dialog
	_pending_upgrade = upgrade_id
	_show_confirmation(upgrade_id, data.cost)

func _on_card_hover_enter(upgrade_id: String) -> void:
	var card: PanelContainer = _upgrade_cards[upgrade_id]
	var is_owned := GameState.has_upgrade(upgrade_id)
	var can_afford := GameState.can_afford(UPGRADES[upgrade_id].cost)

	if not is_owned and can_afford:
		# Highlight available cards on hover
		var tween = create_tween()
		tween.tween_property(card, "modulate", Color(1.2, 1.2, 1.0, 1.0), 0.1)

func _on_card_hover_exit(upgrade_id: String) -> void:
	_update_card_state(upgrade_id)

func _shake_card(upgrade_id: String) -> void:
	## Shake animation for denied purchase
	var card: PanelContainer = _upgrade_cards[upgrade_id]
	var original_pos = card.position
	var tween = create_tween()
	tween.tween_property(card, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(card, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(card, "position:x", original_pos.x + 5, 0.05)
	tween.tween_property(card, "position:x", original_pos.x, 0.05)

# ===== CONFIRMATION DIALOG =====
func _show_confirmation(upgrade_id: String, cost: int) -> void:
	var upgrade_name = UPGRADES[upgrade_id].name
	confirm_message.text = "Purchase %s for %d gold?" % [upgrade_name, cost]
	confirmation_dialog.visible = true

func _hide_confirmation() -> void:
	confirmation_dialog.visible = false
	_pending_upgrade = ""

func _on_confirm_purchase() -> void:
	if _pending_upgrade.is_empty():
		_hide_confirmation()
		return

	var data: Dictionary = UPGRADES[_pending_upgrade]

	# Double-check affordability
	if not GameState.can_afford(data.cost):
		push_warning("[FortManagement] Cannot afford upgrade during confirmation")
		_hide_confirmation()
		return

	# Process purchase
	if GameState.spend_gold(data.cost):
		GameState.add_upgrade(_pending_upgrade)
		upgrade_purchased.emit(_pending_upgrade)
		print("[FortManagement] Purchased: %s" % _pending_upgrade)

		# Flash purchased card green
		var card: PanelContainer = _upgrade_cards[_pending_upgrade]
		var tween = create_tween()
		tween.tween_property(card, "modulate", Color(0.5, 1.0, 0.5, 1.0), 0.1)
		tween.tween_callback(_refresh_all_cards)

	_hide_confirmation()
