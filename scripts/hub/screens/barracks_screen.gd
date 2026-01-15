## BarracksScreen - Soldier recruitment and roster management
## Part of: Blood & Gold Prototype
## Task 3.7: Soldier Recruitment Screen
## Spec: docs/features/3.7-soldier-recruitment-screen.md
extends BaseHubScreen

# ===== SIGNALS =====
signal soldier_hired(soldier_type: String)

# ===== CONSTANTS =====
const SOLDIER_DATA := {
	"infantry": {
		"name": "Infantry",
		"cost": 50,
		"hp": 20,
		"atk": "1d6+1",
		"defense": 13,
		"movement": 4,
		"description": "Reliable melee fighters",
		"color": Color("#2ecc71"),
	},
	"archer": {
		"name": "Archer",
		"cost": 100,
		"hp": 15,
		"atk": "1d6",
		"defense": 11,
		"movement": 5,
		"range": 8,
		"description": "Deadly at range, fragile up close",
		"color": Color("#9b59b6"),
	}
}

const BASE_CAPACITY := 4
const BARRACKS_BONUS := 4

# ===== NODE REFERENCES =====
@onready var gold_amount: Label = $TopBar/GoldDisplay/GoldAmount
@onready var capacity_bar: ProgressBar = $ContentPanel/MainContent/RosterStatus/CapacityBar
@onready var capacity_text: Label = $ContentPanel/MainContent/RosterStatus/CapacityText
@onready var barracks_hint: Label = $ContentPanel/MainContent/RosterStatus/BarracksHint
@onready var soldiers_container: HBoxContainer = $ContentPanel/MainContent/SoldiersContainer
@onready var infantry_card: PanelContainer = $ContentPanel/MainContent/SoldiersContainer/InfantryCard
@onready var archer_card: PanelContainer = $ContentPanel/MainContent/SoldiersContainer/ArcherCard
@onready var infantry_hire_btn: Button = $ContentPanel/MainContent/SoldiersContainer/InfantryCard/VBoxContainer/HireButton
@onready var archer_hire_btn: Button = $ContentPanel/MainContent/SoldiersContainer/ArcherCard/VBoxContainer/HireButton
@onready var owned_icons: HBoxContainer = $ContentPanel/MainContent/OwnedRosterDisplay/SoldierIcons
@onready var no_soldiers_label: Label = $ContentPanel/MainContent/OwnedRosterDisplay/NoSoldiersLabel

# ===== LIFECYCLE =====
func _setup_screen() -> void:
	set_title("SOLDIER RECRUITMENT")
	_connect_recruitment_signals()
	_populate_soldier_cards()
	_refresh_display()
	print("[BarracksScreen] Initialized - Recruitment Ready")

func _connect_recruitment_signals() -> void:
	infantry_hire_btn.pressed.connect(_on_hire_infantry)
	archer_hire_btn.pressed.connect(_on_hire_archer)
	GameState.gold_changed.connect(_on_gold_changed)
	GameState.soldiers_changed.connect(_on_soldiers_changed)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)

# ===== PUBLIC API =====
func get_max_capacity() -> int:
	## Returns max soldier capacity based on upgrades
	var capacity := BASE_CAPACITY
	if GameState.has_upgrade("barracks"):
		capacity += BARRACKS_BONUS
	return capacity

func get_current_roster_size() -> int:
	## Returns number of soldiers currently owned
	return GameState.get_soldier_count()

func can_hire() -> bool:
	## Returns true if there's room for more soldiers
	return get_current_roster_size() < get_max_capacity()

# ===== INTERNAL METHODS =====
func _populate_soldier_cards() -> void:
	## Populate the soldier cards with data from SOLDIER_DATA
	_populate_card(infantry_card, "infantry")
	_populate_card(archer_card, "archer")

func _populate_card(card: PanelContainer, soldier_type: String) -> void:
	var data = SOLDIER_DATA[soldier_type]
	var vbox := card.get_node("VBoxContainer")

	# Set name
	var name_label := vbox.get_node("NameLabel") as Label
	name_label.text = data.name.to_upper()

	# Set stats
	var stats := vbox.get_node("StatsContainer")
	(stats.get_node("HPValue") as Label).text = str(data.hp)
	(stats.get_node("ATKValue") as Label).text = data.atk
	(stats.get_node("DEFValue") as Label).text = str(data.defense)
	(stats.get_node("MOVEValue") as Label).text = str(data.movement)

	# Set range if archer
	var range_container := stats.get_node_or_null("RangeContainer")
	if range_container:
		if data.has("range"):
			range_container.visible = true
			(stats.get_node("RangeValue") as Label).text = str(data.range)
		else:
			range_container.visible = false

	# Set description
	var desc_label := vbox.get_node("DescriptionLabel") as Label
	desc_label.text = "\"%s\"" % data.description

func _refresh_display() -> void:
	_update_gold_display()
	_update_capacity_display()
	_update_soldier_cards()
	_update_owned_roster_display()

func _update_gold_display() -> void:
	gold_amount.text = str(GameState.gold)

func _update_capacity_display() -> void:
	var current := get_current_roster_size()
	var max_cap := get_max_capacity()
	capacity_bar.max_value = max_cap
	capacity_bar.value = current
	capacity_text.text = "%d/%d SOLDIERS" % [current, max_cap]

	# Show/hide barracks hint
	if GameState.has_upgrade("barracks"):
		barracks_hint.text = "Barracks upgrade active (+4 capacity)"
		barracks_hint.modulate = Color("#27ae60")
	else:
		barracks_hint.text = "Upgrade Barracks at Fort for more capacity"
		barracks_hint.modulate = Color("#f39c12")

func _update_soldier_cards() -> void:
	_update_card_button(infantry_hire_btn, "infantry")
	_update_card_button(archer_hire_btn, "archer")

func _update_card_button(button: Button, soldier_type: String) -> void:
	var data = SOLDIER_DATA[soldier_type]
	var cost: int = data.cost
	var can_afford := GameState.can_afford(cost)
	var has_room := can_hire()

	if not has_room:
		button.text = "ROSTER FULL"
		button.disabled = true
		button.modulate = Color(0.6, 0.6, 0.6)
	elif not can_afford:
		button.text = "HIRE - %d GOLD" % cost
		button.disabled = true
		button.modulate = Color(0.8, 0.4, 0.4)
	else:
		button.text = "HIRE - %d GOLD" % cost
		button.disabled = false
		button.modulate = Color.WHITE

func _update_owned_roster_display() -> void:
	# Clear existing icons
	for child in owned_icons.get_children():
		child.queue_free()

	var soldiers := GameState.get_soldiers()
	var max_cap := get_max_capacity()

	# Show/hide "no soldiers" message
	if no_soldiers_label:
		no_soldiers_label.visible = soldiers.is_empty()

	# Add icons for each slot
	for i in range(max_cap):
		var slot := _create_roster_slot(i, soldiers)
		owned_icons.add_child(slot)

func _create_roster_slot(index: int, soldiers: Array[String]) -> Control:
	## Create a roster slot showing either a soldier or empty slot
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(50, 50)

	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if index < soldiers.size():
		var soldier_type := soldiers[index]
		var data = SOLDIER_DATA[soldier_type]
		label.text = data.name.left(3).to_upper()  # "INF" or "ARC"
		slot.modulate = data.color
	else:
		label.text = "---"
		slot.modulate = Color(0.3, 0.3, 0.3, 0.5)

	slot.add_child(label)
	return slot

func _hire_soldier(soldier_type: String) -> void:
	var data = SOLDIER_DATA[soldier_type]
	var cost: int = data.cost

	if not GameState.can_afford(cost):
		_play_denied_feedback(soldier_type)
		return

	if not can_hire():
		_play_denied_feedback(soldier_type)
		return

	# Execute purchase
	if GameState.spend_gold(cost):
		GameState.add_soldier(soldier_type)
		_play_success_feedback(soldier_type)
		soldier_hired.emit(soldier_type)
		_refresh_display()

func _play_success_feedback(soldier_type: String) -> void:
	var card := infantry_card if soldier_type == "infantry" else archer_card
	var tween := create_tween()
	tween.tween_property(card, "modulate", Color(0.5, 1.0, 0.5), 0.15)
	tween.tween_property(card, "modulate", Color.WHITE, 0.15)
	print("[BarracksScreen] Hired %s" % soldier_type)

func _play_denied_feedback(soldier_type: String) -> void:
	var card := infantry_card if soldier_type == "infantry" else archer_card
	var original_pos := card.position
	var tween := create_tween()
	tween.tween_property(card, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(card, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(card, "position:x", original_pos.x, 0.05)
	print("[BarracksScreen] Cannot hire %s - insufficient gold or capacity" % soldier_type)

# ===== SIGNAL HANDLERS =====
func _on_hire_infantry() -> void:
	_hire_soldier("infantry")

func _on_hire_archer() -> void:
	_hire_soldier("archer")

func _on_gold_changed(_new_amount: int) -> void:
	_refresh_display()

func _on_soldiers_changed() -> void:
	_refresh_display()

func _on_upgrade_purchased(upgrade_id: String) -> void:
	if upgrade_id == "barracks":
		_refresh_display()
		print("[BarracksScreen] Barracks upgrade detected - capacity increased")
