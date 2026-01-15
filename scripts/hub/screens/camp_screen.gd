## CampScreen - Companion management and loyalty display
## Part of: Blood & Gold Prototype
## Task 3.9: Loyalty System Implementation
## Task 3.10: Camp Scene System
## Spec: docs/features/3.9-loyalty-system-implementation.md
## Spec: docs/features/3.10-camp-scene-system.md
extends BaseHubScreen

# ===== CONSTANTS =====
const COMPANION_PORTRAITS: Dictionary = {
	"thorne": Color("#2c3e50"),   # Dark blue-gray (warrior)
	"lyra": Color("#f1c40f"),     # Gold (priest)
	"matthias": Color("#c0392b"), # Red (rogue)
}

# Camp dialogue scene paths
const CAMP_DIALOGUE_PATHS: Dictionary = {
	"thorne": "res://data/camp_scenes/camp_scene_1_thorne.json",
	"lyra": "res://data/camp_scenes/camp_scene_2_lyra.json",
	"matthias": "res://data/camp_scenes/camp_scene_3_matthias.json",
}

# Preload CampDialogue scene
const CampDialogueScene = preload("res://scenes/camp/CampDialogue.tscn")

# ===== NODE REFERENCES =====
@onready var companions_container: HBoxContainer = $ContentPanel/MainContent/CompanionsContainer
@onready var party_status_label: Label = $ContentPanel/MainContent/PartyStatus/StatusLabel

# ===== INTERNAL STATE =====
var _camp_dialogue_instance: Control = null

# ===== LIFECYCLE =====
func _setup_screen() -> void:
	set_title("CAMP - COMPANIONS")
	_connect_loyalty_signals()
	_refresh_display()
	print("[CampScreen] Initialized with loyalty display")

func _connect_loyalty_signals() -> void:
	LoyaltyManager.loyalty_changed.connect(_on_loyalty_changed)
	LoyaltyManager.companion_left.connect(_on_companion_left)

# ===== PUBLIC API =====
func refresh() -> void:
	## Refresh the entire display
	_refresh_display()

# ===== INTERNAL METHODS =====
func _refresh_display() -> void:
	_update_party_status()
	_update_companion_cards()

func _update_party_status() -> void:
	var active = LoyaltyManager.get_active_companions()
	var departed = LoyaltyManager.get_departed_companions()

	if departed.is_empty():
		party_status_label.text = "%d companions in your company" % active.size()
		party_status_label.modulate = Color.WHITE
	else:
		party_status_label.text = "%d companions active, %d departed" % [active.size(), departed.size()]
		party_status_label.modulate = Color("#e74c3c")

func _update_companion_cards() -> void:
	# Clear existing cards
	for child in companions_container.get_children():
		child.queue_free()

	# Create card for each companion
	var all_companions = LoyaltyManager.get_all_companions()
	for companion_id in all_companions:
		var card = _create_companion_card(companion_id)
		companions_container.add_child(card)

func _create_companion_card(companion_id: String) -> PanelContainer:
	## Create a companion card showing loyalty information
	var has_left = LoyaltyManager.has_companion_left(companion_id)
	var loyalty = LoyaltyManager.get_loyalty(companion_id)
	var tier = LoyaltyManager.get_loyalty_tier(companion_id)
	var tier_color = LoyaltyManager.get_loyalty_color(companion_id)
	var stat_modifier = LoyaltyManager.get_stat_modifier_percent(companion_id)
	var progress = LoyaltyManager.get_progress_to_next_tier(companion_id)
	var tier_desc = LoyaltyManager.get_tier_description(tier)

	# Main card container
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(220, 380)
	if has_left:
		card.modulate = Color(0.5, 0.5, 0.5, 0.7)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card.add_child(vbox)

	# Portrait placeholder
	var portrait = ColorRect.new()
	portrait.custom_minimum_size = Vector2(80, 80)
	portrait.color = COMPANION_PORTRAITS.get(companion_id, Color.GRAY)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(portrait)

	var portrait_label = Label.new()
	portrait_label.text = companion_id.left(3).to_upper()
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.add_child(portrait_label)

	# Name label
	var name_label = Label.new()
	name_label.text = companion_id.capitalize()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if has_left:
		name_label.text += " (DEPARTED)"
		name_label.modulate = Color("#e74c3c")
	vbox.add_child(name_label)

	# Loyalty tier
	var tier_label = Label.new()
	tier_label.text = tier.capitalize()
	tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tier_label.add_theme_color_override("font_color", tier_color)
	vbox.add_child(tier_label)

	# Loyalty value
	var loyalty_label = Label.new()
	loyalty_label.text = "Loyalty: %d/100" % loyalty
	loyalty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(loyalty_label)

	# Progress bar to next tier
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(0, 20)
	progress_bar.max_value = 1.0
	progress_bar.value = progress
	progress_bar.show_percentage = false
	vbox.add_child(progress_bar)

	# Stat modifier
	var modifier_label = Label.new()
	if stat_modifier == 0:
		modifier_label.text = "Combat: Normal"
		modifier_label.add_theme_color_override("font_color", Color.WHITE)
	elif stat_modifier > 0:
		modifier_label.text = "Combat: +%d%%" % stat_modifier
		modifier_label.add_theme_color_override("font_color", Color("#27ae60"))
	else:
		modifier_label.text = "Combat: %d%%" % stat_modifier
		modifier_label.add_theme_color_override("font_color", Color("#e74c3c"))
	modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(modifier_label)

	# Tier description
	var desc_label = Label.new()
	desc_label.text = tier_desc
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(180, 0)
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(desc_label)

	# Talk button (camp dialogue)
	if not has_left and CAMP_DIALOGUE_PATHS.has(companion_id):
		var talk_button = Button.new()
		talk_button.text = "TALK"
		talk_button.custom_minimum_size = Vector2(0, 35)
		talk_button.pressed.connect(_on_talk_pressed.bind(companion_id))
		vbox.add_child(talk_button)

	return card

# ===== SIGNAL HANDLERS =====
func _on_loyalty_changed(_companion_id: String, _new_value: int, _delta: int) -> void:
	_refresh_display()

func _on_companion_left(companion_id: String, _loyalty: int) -> void:
	_refresh_display()
	print("[CampScreen] %s has left the company!" % companion_id.capitalize())

func _on_talk_pressed(companion_id: String) -> void:
	## Start camp dialogue with a companion
	print("[CampScreen] Starting dialogue with %s" % companion_id)
	_start_camp_dialogue(companion_id)

func _on_dialogue_ended(_scene_id: String) -> void:
	## Handle dialogue ending, return to camp screen
	_cleanup_dialogue()
	_refresh_display()

# ===== CAMP DIALOGUE =====
func _start_camp_dialogue(companion_id: String) -> void:
	## Launch a camp dialogue scene for a companion
	var json_path = CAMP_DIALOGUE_PATHS.get(companion_id, "")
	if json_path.is_empty():
		push_error("[CampScreen] No dialogue path for companion: %s" % companion_id)
		return

	# Create dialogue instance
	_camp_dialogue_instance = CampDialogueScene.instantiate()
	add_child(_camp_dialogue_instance)

	# Connect to scene_ended signal
	_camp_dialogue_instance.scene_ended.connect(_on_dialogue_ended)

	# Load and start dialogue
	if _camp_dialogue_instance.load_scene(json_path):
		_camp_dialogue_instance.start_dialogue()
	else:
		push_error("[CampScreen] Failed to load dialogue: %s" % json_path)
		_cleanup_dialogue()

func _cleanup_dialogue() -> void:
	## Clean up dialogue instance
	if _camp_dialogue_instance:
		_camp_dialogue_instance.queue_free()
		_camp_dialogue_instance = null
