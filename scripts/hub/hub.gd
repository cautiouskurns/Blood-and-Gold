## Hub - Main hub scene controller
## Part of: Blood & Gold Prototype
## Task 3.1: Main Hub Scene Structure
extends Control

# ===== SIGNALS =====
signal navigation_requested(screen_name: String)

# ===== CONSTANTS =====
const BUTTON_COLORS = {
	"contracts": Color("#c0392b"),   # Red - danger/combat
	"barracks": Color("#2980b9"),    # Blue - soldiers
	"merchant": Color("#f39c12"),    # Gold - commerce
	"camp": Color("#27ae60")         # Green - rest/healing
}

# ===== NODE REFERENCES =====
@onready var gold_label: Label = $TopBar/GoldDisplay/GoldAmount
@onready var company_label: Label = $TopBar/CompanyName
@onready var contracts_btn: Button = $NavigationPanel/VBoxContainer/ContractsButton
@onready var barracks_btn: Button = $NavigationPanel/VBoxContainer/BarracksButton
@onready var merchant_btn: Button = $NavigationPanel/VBoxContainer/MerchantButton
@onready var camp_btn: Button = $NavigationPanel/VBoxContainer/CampButton
@onready var combat_btn: Button = $NavigationPanel/VBoxContainer/CombatButton
@onready var sub_screen_container: Control = $SubScreenContainer
@onready var main_hub_view: Control = $MainHubView

# Preload sub-screens
const ContractsScreenScene = preload("res://scenes/hub/screens/ContractsScreen.tscn")
const BarracksScreenScene = preload("res://scenes/hub/screens/BarracksScreen.tscn")
const MerchantScreenScene = preload("res://scenes/hub/screens/MerchantScreen.tscn")
const CampScreenScene = preload("res://scenes/hub/screens/CampScreen.tscn")

# ===== STATE =====
var _current_sub_screen: Control = null

# ===== LIFECYCLE =====
func _ready() -> void:
	_connect_signals()
	_update_gold_display()
	_update_company_name()
	GameState.change_screen(GameState.Screen.HUB)
	print("[Hub] Initialized")

func _connect_signals() -> void:
	# Connect button signals
	contracts_btn.pressed.connect(_on_contracts_pressed)
	barracks_btn.pressed.connect(_on_barracks_pressed)
	merchant_btn.pressed.connect(_on_merchant_pressed)
	camp_btn.pressed.connect(_on_camp_pressed)
	combat_btn.pressed.connect(_on_combat_pressed)

	# Connect to GameState for gold updates
	GameState.gold_changed.connect(_on_gold_changed)

# ===== UI UPDATES =====
func _update_gold_display() -> void:
	## Update the gold display label
	gold_label.text = "%d" % GameState.get_gold()

func _update_company_name() -> void:
	## Update the company name label
	company_label.text = GameState.company_name

func _on_gold_changed(new_amount: int) -> void:
	## Handle gold amount changes
	gold_label.text = "%d" % new_amount

# ===== NAVIGATION =====
func _on_contracts_pressed() -> void:
	_show_sub_screen("contracts", ContractsScreenScene)
	GameState.change_screen(GameState.Screen.CONTRACTS)

func _on_barracks_pressed() -> void:
	_show_sub_screen("barracks", BarracksScreenScene)
	GameState.change_screen(GameState.Screen.BARRACKS)

func _on_merchant_pressed() -> void:
	_show_sub_screen("merchant", MerchantScreenScene)
	GameState.change_screen(GameState.Screen.MERCHANT)

func _on_camp_pressed() -> void:
	_show_sub_screen("camp", CampScreenScene)
	GameState.change_screen(GameState.Screen.CAMP)

func _on_combat_pressed() -> void:
	## Go to combat scene
	print("[Hub] Navigating to Combat")
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _show_sub_screen(screen_name: String, scene: PackedScene) -> void:
	## Display a sub-screen in the container
	print("[Hub] Showing sub-screen: %s" % screen_name)

	# Clear existing sub-screen
	_clear_sub_screen()

	# Hide main hub view, show sub-screen container
	main_hub_view.visible = false
	sub_screen_container.visible = true

	# Instance and add the sub-screen
	_current_sub_screen = scene.instantiate()
	sub_screen_container.add_child(_current_sub_screen)

	# Connect back button if it exists
	if _current_sub_screen.has_signal("back_pressed"):
		_current_sub_screen.back_pressed.connect(_on_sub_screen_back)

func _clear_sub_screen() -> void:
	## Clear the current sub-screen
	if _current_sub_screen:
		_current_sub_screen.queue_free()
		_current_sub_screen = null

func _on_sub_screen_back() -> void:
	## Handle back button from sub-screen
	print("[Hub] Returning to main hub")
	_clear_sub_screen()
	main_hub_view.visible = true
	sub_screen_container.visible = false
	GameState.change_screen(GameState.Screen.HUB)

func return_to_hub() -> void:
	## Public method to return to main hub view
	_on_sub_screen_back()

# ===== INPUT =====
func _unhandled_input(event: InputEvent) -> void:
	# ESC to go back from sub-screen
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if _current_sub_screen:
				_on_sub_screen_back()
				get_viewport().set_input_as_handled()
