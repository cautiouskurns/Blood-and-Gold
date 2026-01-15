## ContractsScreen - Contract board UI for selecting missions
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.2-contract-board-ui.md
extends BaseHubScreen

# ===== SIGNALS =====
signal contract_selected(contract: Contract)
signal contract_accepted(contract: Contract)

# ===== CONSTANTS =====
const CONTRACT_CARD_SCENE: PackedScene = preload("res://scenes/hub/ContractCard.tscn")
const MAX_DISPLAYED_CONTRACTS: int = 3

# ===== NODE REFERENCES =====
@onready var contract_board: VBoxContainer = $ContentPanel/ContractBoard
@onready var cards_container: HBoxContainer = $ContentPanel/ContractBoard/CardsContainer
@onready var no_contracts_message: Label = $ContentPanel/NoContractsMessage
@onready var detail_panel: PanelContainer = $ContractDetailPanel
@onready var dim_background: ColorRect = $DimBackground

# Detail panel elements
@onready var close_button: Button = $ContractDetailPanel/MarginContainer/VBoxContainer/DetailHeader/CloseButton
@onready var detail_contract_name: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/ContractName
@onready var detail_difficulty_stars: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/DifficultyRow/DifficultyStars
@onready var detail_briefing_text: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/BriefingSection/BriefingText
@onready var detail_objectives_text: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/ObjectivesSection/ObjectivesText
@onready var detail_reward_amount: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/InfoRow/RewardSection/RewardAmount
@onready var detail_enemy_info: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/InfoRow/EnemySection/EnemyInfo
@onready var detail_map_name: Label = $ContractDetailPanel/MarginContainer/VBoxContainer/MapSection/MapName
@onready var accept_button: Button = $ContractDetailPanel/MarginContainer/VBoxContainer/ButtonContainer/AcceptButton

# ===== INTERNAL STATE =====
var _card_instances: Array[ContractCard] = []
var _selected_contract: Contract = null
var _detail_panel_open: bool = false

# ===== LIFECYCLE =====
func _setup_screen() -> void:
	set_title("CONTRACTS")
	_connect_detail_signals()
	_populate_contract_cards()
	print("[ContractsScreen] Initialized")

func _connect_detail_signals() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	if accept_button:
		accept_button.pressed.connect(_on_accept_button_pressed)
	if dim_background:
		dim_background.gui_input.connect(_on_dim_background_input)

	# Listen for contract updates from GameState
	if GameState:
		GameState.contracts_updated.connect(_on_contracts_updated)

func _input(event: InputEvent) -> void:
	# Handle ESC key to close detail panel
	if event.is_action_pressed("ui_cancel"):
		if _detail_panel_open:
			_close_detail_panel()
			get_viewport().set_input_as_handled()

# ===== CONTRACT CARD MANAGEMENT =====
func _populate_contract_cards() -> void:
	## Load available contracts and create card instances
	_clear_cards()

	var available_contracts = GameState.get_available_contracts()

	if available_contracts.is_empty():
		_show_no_contracts_message()
		return

	_hide_no_contracts_message()

	# Create cards for available contracts (up to max)
	var count = mini(available_contracts.size(), MAX_DISPLAYED_CONTRACTS)
	for i in range(count):
		var contract = available_contracts[i]
		_create_contract_card(contract)

	print("[ContractsScreen] Populated %d contract cards" % count)

func _create_contract_card(contract: Contract) -> ContractCard:
	## Create and add a contract card to the board
	var card_instance = CONTRACT_CARD_SCENE.instantiate() as ContractCard
	cards_container.add_child(card_instance)
	card_instance.display_contract(contract)

	# Connect signals
	card_instance.card_clicked.connect(_on_card_clicked)
	card_instance.card_hovered.connect(_on_card_hovered)
	card_instance.card_unhovered.connect(_on_card_unhovered)

	_card_instances.append(card_instance)
	return card_instance

func _clear_cards() -> void:
	## Remove all contract cards from the board
	for card in _card_instances:
		if is_instance_valid(card):
			card.queue_free()
	_card_instances.clear()

func _show_no_contracts_message() -> void:
	if contract_board:
		contract_board.visible = false
	if no_contracts_message:
		no_contracts_message.visible = true

func _hide_no_contracts_message() -> void:
	if contract_board:
		contract_board.visible = true
	if no_contracts_message:
		no_contracts_message.visible = false

# ===== CARD INTERACTION =====
func _on_card_clicked(contract: Contract) -> void:
	print("[ContractsScreen] Card clicked: %s" % contract.display_name)
	_selected_contract = contract
	contract_selected.emit(contract)
	_open_detail_panel(contract)

func _on_card_hovered(contract: Contract) -> void:
	# Could add preview behavior here if needed
	pass

func _on_card_unhovered(contract: Contract) -> void:
	pass

# ===== DETAIL PANEL =====
func _open_detail_panel(contract: Contract) -> void:
	## Show the contract detail panel with contract info
	if not contract:
		return

	_selected_contract = contract
	_detail_panel_open = true

	# Update detail panel content
	if detail_contract_name:
		detail_contract_name.text = contract.display_name.to_upper()

	if detail_difficulty_stars:
		detail_difficulty_stars.text = contract.get_difficulty_stars()
		detail_difficulty_stars.add_theme_color_override("font_color", contract.get_difficulty_color())

	if detail_briefing_text:
		detail_briefing_text.text = contract.full_briefing

	if detail_objectives_text:
		detail_objectives_text.text = contract.get_objectives_text()

	if detail_reward_amount:
		var reward_text = "%d gold" % contract.gold_reward
		if contract.gold_reward_max > 0 and contract.gold_reward_max != contract.gold_reward:
			reward_text = "%d-%d gold" % [contract.gold_reward, contract.gold_reward_max]
		detail_reward_amount.text = reward_text

	if detail_enemy_info:
		detail_enemy_info.text = contract.enemy_description if contract.enemy_description else "Unknown"

	if detail_map_name:
		detail_map_name.text = contract.get_map_scene_name()

	# Update accept button state
	_update_accept_button()

	# Mark the selected card
	for card in _card_instances:
		if card.contract == contract:
			card.set_selected(true)
		else:
			card.set_selected(false)

	# Show panel with animation
	if dim_background:
		dim_background.visible = true
	if detail_panel:
		detail_panel.visible = true
		# Optional: animate fade in
		detail_panel.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(detail_panel, "modulate:a", 1.0, 0.2)

	print("[ContractsScreen] Detail panel opened for: %s" % contract.display_name)

func _close_detail_panel() -> void:
	## Hide the contract detail panel
	_detail_panel_open = false
	_selected_contract = null

	# Deselect all cards
	for card in _card_instances:
		card.set_selected(false)

	# Hide panel
	if dim_background:
		dim_background.visible = false
	if detail_panel:
		detail_panel.visible = false

	print("[ContractsScreen] Detail panel closed")

func _update_accept_button() -> void:
	## Update accept button state based on whether we can accept
	if not accept_button:
		return

	var can_accept = not GameState.has_active_contract()
	accept_button.disabled = not can_accept

	if can_accept:
		accept_button.text = "ACCEPT CONTRACT"
		accept_button.tooltip_text = ""
	else:
		accept_button.text = "ACCEPT CONTRACT"
		accept_button.tooltip_text = "You already have an active contract. Complete it first."

# ===== BUTTON HANDLERS =====
func _on_close_button_pressed() -> void:
	_close_detail_panel()

func _on_accept_button_pressed() -> void:
	if not _selected_contract:
		return

	if GameState.has_active_contract():
		push_warning("[ContractsScreen] Cannot accept: already have active contract")
		return

	# Store contract reference before closing panel (which clears _selected_contract)
	var contract = _selected_contract

	# Accept the contract
	var success = GameState.accept_contract(contract)
	if success:
		print("[ContractsScreen] Contract accepted: %s" % contract.display_name)
		contract_accepted.emit(contract)

		# Close detail panel (this clears _selected_contract)
		_close_detail_panel()

		# Transition to contract scene
		_start_contract(contract)

func _on_dim_background_input(event: InputEvent) -> void:
	## Close detail panel when clicking on dimmed background
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_close_detail_panel()

# ===== CONTRACT START =====
func _start_contract(contract: Contract) -> void:
	## Start the accepted contract (transition to appropriate scene)
	print("[ContractsScreen] Starting contract: %s" % contract.display_name)

	# Determine which scene to load
	var target_scene: String = ""

	if contract.has_pre_combat_dialogue and contract.pre_combat_scene:
		# Choice contracts go to dialogue first
		target_scene = contract.pre_combat_scene
	elif contract.map_scene:
		# Contract scene (e.g., MerchantsEscort.tscn)
		target_scene = contract.map_scene
	else:
		# Fallback to main combat scene
		target_scene = "res://scenes/main/Main.tscn"

	print("[ContractsScreen] Transitioning to: %s" % target_scene)

	# Verify scene exists before transitioning
	if ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)
	else:
		push_warning("[ContractsScreen] Scene not found: %s - falling back to Main" % target_scene)
		get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

# ===== GAME STATE UPDATES =====
func _on_contracts_updated() -> void:
	## Called when contracts change (accepted, completed, etc.)
	_populate_contract_cards()
