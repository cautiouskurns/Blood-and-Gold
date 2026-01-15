## MerchantScreen - Equipment shop for purchasing weapons and armor
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.8-merchant-screen.md
extends BaseHubScreen

# ===== SIGNALS =====
signal equipment_purchased(character_id: String, equipment_id: String)

# ===== CONSTANTS =====
enum EquipmentType { WEAPON, ARMOR }

const WEAPONS := [
	{"id": "iron_sword", "name": "Iron Sword", "cost": 100, "damage_die": 8, "damage_bonus": 0, "type": EquipmentType.WEAPON},
	{"id": "steel_sword", "name": "Steel Sword", "cost": 300, "damage_die": 8, "damage_bonus": 1, "type": EquipmentType.WEAPON},
]

const ARMOR := [
	{"id": "leather_armor", "name": "Leather Armor", "cost": 50, "armor_bonus": 2, "movement": 6, "type": EquipmentType.ARMOR},
	{"id": "chain_shirt", "name": "Chain Shirt", "cost": 150, "armor_bonus": 4, "movement": 5, "type": EquipmentType.ARMOR},
	{"id": "scale_mail", "name": "Scale Mail", "cost": 300, "armor_bonus": 5, "movement": 5, "type": EquipmentType.ARMOR},
]

const PARTY_MEMBERS := ["player", "thorne", "lyra", "matthias"]
const PARTY_DISPLAY_NAMES := {
	"player": "COMMANDER",
	"thorne": "THORNE",
	"lyra": "LYRA",
	"matthias": "MATTHIAS"
}

# Visual constants
const CARD_MIN_SIZE := Vector2(280, 120)
const COLOR_AVAILABLE := Color("#ffffff")
const COLOR_UNAFFORDABLE := Color("#666666")
const COLOR_EQUIPPED := Color("#27ae60")
const COLOR_COST_NORMAL := Color("#f1c40f")
const COLOR_COST_RED := Color("#e74c3c")
const COLOR_STAT_UP := Color("#27ae60")
const COLOR_STAT_DOWN := Color("#e74c3c")
const COLOR_STAT_SAME := Color("#888888")

# ===== NODE REFERENCES =====
@onready var gold_amount: Label = $TopBar/GoldDisplay/GoldAmount
@onready var party_container: HBoxContainer = $ContentPanel/VBoxContainer/PartySelector
@onready var category_container: HBoxContainer = $ContentPanel/VBoxContainer/CategoryTabs
@onready var items_container: GridContainer = $ContentPanel/VBoxContainer/ItemsContainer
@onready var comparison_panel: PanelContainer = $ContentPanel/VBoxContainer/ComparisonPanel
@onready var current_name: Label = $ContentPanel/VBoxContainer/ComparisonPanel/HBoxContainer/CurrentEquipment/CurrentName
@onready var current_stats: VBoxContainer = $ContentPanel/VBoxContainer/ComparisonPanel/HBoxContainer/CurrentEquipment/CurrentStats
@onready var new_name: Label = $ContentPanel/VBoxContainer/ComparisonPanel/HBoxContainer/NewEquipment/NewName
@onready var new_stats: VBoxContainer = $ContentPanel/VBoxContainer/ComparisonPanel/HBoxContainer/NewEquipment/NewStats
@onready var purchase_button: Button = $ContentPanel/VBoxContainer/ComparisonPanel/HBoxContainer/NewEquipment/PurchaseButton

# ===== STATE =====
var _selected_member: String = "player"
var _selected_category: EquipmentType = EquipmentType.WEAPON
var _selected_item: Dictionary = {}
var _party_buttons: Dictionary = {}
var _category_buttons: Dictionary = {}
var _item_cards: Dictionary = {}

# ===== LIFECYCLE =====
func _setup_screen() -> void:
	set_title("MERCHANT")
	_update_gold_display()
	_create_party_buttons()
	_create_category_tabs()
	_refresh_items()
	_clear_comparison()

	# Connect to gold changes
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.equipment_changed.connect(_on_equipment_changed)

	print("[MerchantScreen] Initialized")

func _update_gold_display() -> void:
	if gold_amount:
		gold_amount.text = "%d" % GameState.get_gold()

func _on_gold_changed(new_amount: int) -> void:
	gold_amount.text = "%d" % new_amount
	_refresh_item_states()
	_update_comparison()

func _on_equipment_changed(_char_id: String, _slot: String, _equip_id: String) -> void:
	_refresh_item_states()
	_update_comparison()

# ===== PARTY SELECTION =====
func _create_party_buttons() -> void:
	# Clear existing buttons
	for child in party_container.get_children():
		child.queue_free()
	_party_buttons.clear()

	for member_id in PARTY_MEMBERS:
		var btn := Button.new()
		btn.text = PARTY_DISPLAY_NAMES[member_id]
		btn.custom_minimum_size = Vector2(120, 40)
		btn.pressed.connect(_on_party_member_selected.bind(member_id))
		party_container.add_child(btn)
		_party_buttons[member_id] = btn

	_update_party_selection()

func _update_party_selection() -> void:
	for member_id in _party_buttons.keys():
		var btn: Button = _party_buttons[member_id]
		if member_id == _selected_member:
			btn.modulate = Color(1.2, 1.2, 0.8)
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)

func _on_party_member_selected(member_id: String) -> void:
	_selected_member = member_id
	_update_party_selection()
	_refresh_item_states()
	_update_comparison()
	print("[MerchantScreen] Selected party member: %s" % member_id)

# ===== CATEGORY TABS =====
func _create_category_tabs() -> void:
	# Clear existing tabs
	for child in category_container.get_children():
		child.queue_free()
	_category_buttons.clear()

	var weapons_btn := Button.new()
	weapons_btn.text = "WEAPONS"
	weapons_btn.custom_minimum_size = Vector2(150, 40)
	weapons_btn.pressed.connect(_on_category_selected.bind(EquipmentType.WEAPON))
	category_container.add_child(weapons_btn)
	_category_buttons[EquipmentType.WEAPON] = weapons_btn

	var armor_btn := Button.new()
	armor_btn.text = "ARMOR"
	armor_btn.custom_minimum_size = Vector2(150, 40)
	armor_btn.pressed.connect(_on_category_selected.bind(EquipmentType.ARMOR))
	category_container.add_child(armor_btn)
	_category_buttons[EquipmentType.ARMOR] = armor_btn

	_update_category_selection()

func _update_category_selection() -> void:
	for cat_type in _category_buttons.keys():
		var btn: Button = _category_buttons[cat_type]
		if cat_type == _selected_category:
			btn.modulate = Color(1.2, 1.2, 0.8)
		else:
			btn.modulate = Color(0.7, 0.7, 0.7)

func _on_category_selected(category: EquipmentType) -> void:
	_selected_category = category
	_selected_item = {}
	_update_category_selection()
	_refresh_items()
	_clear_comparison()
	print("[MerchantScreen] Selected category: %s" % ("WEAPONS" if category == EquipmentType.WEAPON else "ARMOR"))

# ===== ITEM CARDS =====
func _refresh_items() -> void:
	# Clear existing items
	for child in items_container.get_children():
		child.queue_free()
	_item_cards.clear()

	var items: Array = WEAPONS if _selected_category == EquipmentType.WEAPON else ARMOR

	for item in items:
		var card := _create_item_card(item)
		items_container.add_child(card)
		_item_cards[item.id] = card

	_refresh_item_states()

func _create_item_card(item: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_MIN_SIZE

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Item name
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.text = item.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Stats
	var stats_label := Label.new()
	stats_label.name = "StatsLabel"
	if item.type == EquipmentType.WEAPON:
		var bonus_str := "" if item.damage_bonus == 0 else "+%d" % item.damage_bonus
		stats_label.text = "Damage: 1d%d%s" % [item.damage_die, bonus_str]
	else:
		stats_label.text = "Defense: +%d | Move: %d" % [item.armor_bonus, item.movement]
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(stats_label)

	# Cost
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "%d GOLD" % item.cost
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_color_override("font_color", COLOR_COST_NORMAL)
	vbox.add_child(cost_label)

	# Equipped badge (hidden by default)
	var equipped_label := Label.new()
	equipped_label.name = "EquippedLabel"
	equipped_label.text = "EQUIPPED"
	equipped_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipped_label.add_theme_color_override("font_color", COLOR_EQUIPPED)
	equipped_label.visible = false
	vbox.add_child(equipped_label)

	# Make card clickable
	card.gui_input.connect(_on_card_input.bind(item))
	card.mouse_entered.connect(_on_card_hover.bind(item, true))
	card.mouse_exited.connect(_on_card_hover.bind(item, false))

	return card

func _refresh_item_states() -> void:
	var items: Array = WEAPONS if _selected_category == EquipmentType.WEAPON else ARMOR
	var slot := "weapon" if _selected_category == EquipmentType.WEAPON else "armor"
	var equipped_id := GameState.get_equipped(_selected_member, slot)

	for item in items:
		if item.id not in _item_cards:
			continue

		var card: PanelContainer = _item_cards[item.id]
		var vbox := card.get_child(0)
		var name_label: Label = vbox.get_node("NameLabel")
		var cost_label: Label = vbox.get_node("CostLabel")
		var equipped_label: Label = vbox.get_node("EquippedLabel")

		var is_equipped := equipped_id == item.id
		var can_afford := GameState.can_afford(item.cost)

		# Update visual state
		if is_equipped:
			card.modulate = COLOR_EQUIPPED
			cost_label.visible = false
			equipped_label.visible = true
		elif not can_afford:
			card.modulate = COLOR_UNAFFORDABLE
			cost_label.add_theme_color_override("font_color", COLOR_COST_RED)
			cost_label.visible = true
			equipped_label.visible = false
		else:
			card.modulate = COLOR_AVAILABLE
			cost_label.add_theme_color_override("font_color", COLOR_COST_NORMAL)
			cost_label.visible = true
			equipped_label.visible = false

		# Highlight selected item
		if _selected_item and _selected_item.id == item.id:
			card.modulate = card.modulate * Color(1.3, 1.3, 1.0)

func _on_card_input(event: InputEvent, item: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_item(item)

func _on_card_hover(item: Dictionary, hovering: bool) -> void:
	if item.id not in _item_cards:
		return
	var card: PanelContainer = _item_cards[item.id]

	# Don't change hover state for selected item
	if _selected_item and _selected_item.id == item.id:
		return

	if hovering:
		card.modulate = card.modulate * Color(1.1, 1.1, 1.0)
	else:
		_refresh_item_states()

func _select_item(item: Dictionary) -> void:
	_selected_item = item
	_refresh_item_states()
	_update_comparison()
	print("[MerchantScreen] Selected item: %s" % item.name)

# ===== COMPARISON PANEL =====
func _clear_comparison() -> void:
	comparison_panel.visible = false
	_selected_item = {}

func _update_comparison() -> void:
	if _selected_item.is_empty():
		comparison_panel.visible = false
		return

	comparison_panel.visible = true

	var slot := "weapon" if _selected_item.type == EquipmentType.WEAPON else "armor"
	var current_id := GameState.get_equipped(_selected_member, slot)
	var current_item := _get_item_by_id(current_id)

	# Current equipment
	if current_item.is_empty():
		current_name.text = "(None)"
		_clear_stats_container(current_stats)
	else:
		current_name.text = current_item.name
		_populate_stats(current_stats, current_item, null)

	# New equipment
	new_name.text = _selected_item.name
	_populate_stats(new_stats, _selected_item, current_item)

	# Purchase button
	var is_equipped := current_id == _selected_item.id
	var can_afford := GameState.can_afford(_selected_item.cost)

	if is_equipped:
		purchase_button.text = "EQUIPPED"
		purchase_button.disabled = true
	elif not can_afford:
		purchase_button.text = "CANNOT AFFORD"
		purchase_button.disabled = true
	else:
		purchase_button.text = "PURCHASE - %dg" % _selected_item.cost
		purchase_button.disabled = false
		if not purchase_button.pressed.is_connected(_on_purchase_pressed):
			purchase_button.pressed.connect(_on_purchase_pressed)

func _clear_stats_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func _populate_stats(container: VBoxContainer, item: Dictionary, compare_to: Dictionary) -> void:
	_clear_stats_container(container)

	if item.type == EquipmentType.WEAPON:
		# Damage die
		var die_label := Label.new()
		var bonus_str := "" if item.damage_bonus == 0 else "+%d" % item.damage_bonus
		die_label.text = "Damage: 1d%d%s" % [item.damage_die, bonus_str]

		if compare_to and not compare_to.is_empty():
			var old_total := compare_to.damage_die + compare_to.damage_bonus
			var new_total := item.damage_die + item.damage_bonus
			if new_total > old_total:
				die_label.add_theme_color_override("font_color", COLOR_STAT_UP)
				die_label.text += " ^"
			elif new_total < old_total:
				die_label.add_theme_color_override("font_color", COLOR_STAT_DOWN)
				die_label.text += " v"
			else:
				die_label.add_theme_color_override("font_color", COLOR_STAT_SAME)

		container.add_child(die_label)
	else:
		# Defense
		var def_label := Label.new()
		def_label.text = "Defense: +%d" % item.armor_bonus

		if compare_to and not compare_to.is_empty():
			if item.armor_bonus > compare_to.armor_bonus:
				def_label.add_theme_color_override("font_color", COLOR_STAT_UP)
				def_label.text += " ^"
			elif item.armor_bonus < compare_to.armor_bonus:
				def_label.add_theme_color_override("font_color", COLOR_STAT_DOWN)
				def_label.text += " v"
			else:
				def_label.add_theme_color_override("font_color", COLOR_STAT_SAME)

		container.add_child(def_label)

		# Movement
		var move_label := Label.new()
		move_label.text = "Movement: %d" % item.movement

		if compare_to and not compare_to.is_empty():
			if item.movement > compare_to.movement:
				move_label.add_theme_color_override("font_color", COLOR_STAT_UP)
				move_label.text += " ^"
			elif item.movement < compare_to.movement:
				move_label.add_theme_color_override("font_color", COLOR_STAT_DOWN)
				move_label.text += " v"
			else:
				move_label.add_theme_color_override("font_color", COLOR_STAT_SAME)

		container.add_child(move_label)

func _get_item_by_id(item_id: String) -> Dictionary:
	if item_id.is_empty():
		return {}

	for item in WEAPONS:
		if item.id == item_id:
			return item
	for item in ARMOR:
		if item.id == item_id:
			return item

	return {}

# ===== PURCHASE =====
func _on_purchase_pressed() -> void:
	if _selected_item.is_empty():
		return

	var cost: int = _selected_item.cost
	if not GameState.can_afford(cost):
		_shake_button()
		return

	# Spend gold and equip
	if GameState.spend_gold(cost):
		var slot := "weapon" if _selected_item.type == EquipmentType.WEAPON else "armor"
		GameState.equip_item(_selected_member, slot, _selected_item.id)
		equipment_purchased.emit(_selected_member, _selected_item.id)

		# Visual feedback
		_flash_purchase_success()
		print("[MerchantScreen] Purchased %s for %s" % [_selected_item.name, _selected_member])

func _shake_button() -> void:
	var original_pos := purchase_button.position
	var tween := create_tween()
	tween.tween_property(purchase_button, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(purchase_button, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(purchase_button, "position:x", original_pos.x + 5, 0.05)
	tween.tween_property(purchase_button, "position:x", original_pos.x, 0.05)

func _flash_purchase_success() -> void:
	if _selected_item.id in _item_cards:
		var card: PanelContainer = _item_cards[_selected_item.id]
		var tween := create_tween()
		tween.tween_property(card, "modulate", Color(2.0, 2.0, 2.0), 0.1)
		tween.tween_property(card, "modulate", COLOR_EQUIPPED, 0.2)
