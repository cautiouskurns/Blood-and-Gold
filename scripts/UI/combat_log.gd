## CombatLogPanel - Scrolling log of combat events
## Part of: Blood & Gold Prototype
## Spec: docs/features/4.3-combat-ui-polish.md
class_name CombatLogPanel
extends PanelContainer

# ===== CONSTANTS =====
const MAX_ENTRIES: int = 100
const VISIBLE_LINES: int = 8
const FADE_DURATION: float = 0.2

# Event colors
const COLOR_DAMAGE_DEALT: Color = Color("#e74c3c")   # Red
const COLOR_DAMAGE_TAKEN: Color = Color("#e67e22")   # Orange
const COLOR_HEALING: Color = Color("#27ae60")        # Green
const COLOR_ABILITY: Color = Color("#3498db")        # Blue
const COLOR_MOVEMENT: Color = Color("#95a5a6")       # Gray
const COLOR_TURN: Color = Color("#f1c40f")           # Gold
const COLOR_STATUS: Color = Color("#9b59b6")         # Purple
const COLOR_DEATH: Color = Color("#c0392b")          # Dark red
const COLOR_MISS: Color = Color("#7f8c8d")           # Gray
const COLOR_DEFAULT: Color = Color("#ffffff")        # White

# Panel colors
const COLOR_BG: Color = Color("#1a1a2e")
const COLOR_BORDER: Color = Color("#34495e")
const COLOR_HEADER: Color = Color("#f1c40f")

# ===== NODE REFERENCES =====
@onready var header_label: Label = $VBoxContainer/HeaderLabel
@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer
@onready var log_container: VBoxContainer = $VBoxContainer/ScrollContainer/LogContainer

# ===== STATE =====
var _auto_scroll: bool = true

# ===== LIFECYCLE =====
func _ready() -> void:
	_setup_panel_style()
	_connect_signals()
	_add_entry("Combat log initialized", COLOR_DEFAULT)
	print("[CombatLog] Initialized")

func _setup_panel_style() -> void:
	## Configure panel visual style
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.bg_color.a = 0.9
	style.border_color = COLOR_BORDER
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	add_theme_stylebox_override("panel", style)

	# Style header
	header_label.add_theme_color_override("font_color", COLOR_HEADER)

func _connect_signals() -> void:
	## Connect to game signals
	CombatManager.ability_executed.connect(_on_ability_executed)
	CombatManager.turn_started.connect(_on_turn_started)
	CombatManager.turn_ended.connect(_on_turn_ended)
	CombatManager.battle_started.connect(_on_battle_started)
	CombatManager.battle_won.connect(_on_battle_won)
	CombatManager.battle_lost.connect(_on_battle_lost)
	CombatManager.movement_finished.connect(_on_movement_finished)
	CombatManager.attack_executed.connect(_on_attack_executed)
	CombatManager.unit_teleported.connect(_on_unit_teleported)

	# Connect scroll detection for auto-scroll behavior
	scroll_container.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)

# ===== PUBLIC API =====
func add_entry(message: String, color: Color = COLOR_DEFAULT) -> void:
	## Add a new log entry (public wrapper)
	_add_entry(message, color)

func clear_log() -> void:
	## Clear all log entries
	for child in log_container.get_children():
		child.queue_free()
	_add_entry("Log cleared", COLOR_DEFAULT)

# ===== INTERNAL METHODS =====
func _add_entry(message: String, color: Color) -> void:
	## Add a new log entry
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 10)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 230  # Ensure wrapping

	log_container.add_child(label)

	# Remove oldest entries if over limit
	while log_container.get_child_count() > MAX_ENTRIES:
		var oldest = log_container.get_child(0)
		oldest.queue_free()

	# Auto-scroll to bottom
	if _auto_scroll:
		_scroll_to_bottom()

func _scroll_to_bottom() -> void:
	## Scroll to show latest entries
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _get_ability_display_name(ability_id: String) -> String:
	## Get display name for an ability
	# Try to load ability resource
	var path = "res://resources/abilities/%s.tres" % ability_id
	if ResourceLoader.exists(path):
		var ability = load(path)
		if ability:
			return ability.display_name
	# Fallback: format the ID nicely
	return ability_id.replace("_", " ").capitalize()

# ===== SIGNAL HANDLERS =====
func _on_ability_executed(user: Unit, ability_id: String, result: Dictionary) -> void:
	## Log ability execution
	var ability_name = _get_ability_display_name(ability_id)

	# Log the ability use
	_add_entry("%s uses %s!" % [user.unit_name, ability_name], COLOR_ABILITY)

	# Log result details
	if result.get("hit", false):
		var target_name = result.get("target_name", "target")
		var damage = result.get("damage", 0)
		if damage > 0:
			var crit_text = " (CRITICAL!)" if result.get("is_critical", false) else ""
			var backstab_text = " (BACKSTAB!)" if result.get("is_backstab", false) else ""
			_add_entry("  Hit %s for %d damage%s%s" % [target_name, damage, crit_text, backstab_text], COLOR_DAMAGE_DEALT)

	elif result.get("missed", false):
		var target_name = result.get("target_name", "target")
		_add_entry("  Missed %s!" % target_name, COLOR_MISS)

	elif result.get("healed", false):
		var target_name = result.get("target_name", "target")
		var heal_amount = result.get("heal_amount", 0)
		_add_entry("  Healed %s for %d HP" % [target_name, heal_amount], COLOR_HEALING)

	elif result.get("buff_applied", false):
		var buff_name = result.get("buff_name", "buff")
		var targets = result.get("targets_affected", 1)
		if targets > 1:
			_add_entry("  Applied %s to %d allies" % [buff_name, targets], COLOR_STATUS)
		else:
			_add_entry("  Applied %s" % buff_name, COLOR_STATUS)

	elif result.get("teleported", false):
		var destination = result.get("destination", Vector2i.ZERO)
		_add_entry("  Teleported to (%d, %d)" % [destination.x, destination.y], COLOR_MOVEMENT)

func _on_turn_started(unit: Unit) -> void:
	## Log turn start
	if unit.is_enemy:
		_add_entry(">> %s's TURN <<" % unit.unit_name.to_upper(), COLOR_TURN)
	else:
		_add_entry(">> YOUR TURN: %s <<" % unit.unit_name.to_upper(), COLOR_TURN)

func _on_turn_ended(unit: Unit) -> void:
	## Log turn end (optional, might be too verbose)
	pass

func _on_battle_started(_units: Array[Unit]) -> void:
	## Log battle start
	clear_log()
	_add_entry("===== BATTLE START =====", COLOR_TURN)

func _on_battle_won(gold_earned: int) -> void:
	## Log victory
	_add_entry("===== VICTORY! =====", COLOR_TURN)
	_add_entry("Gold earned: %d" % gold_earned, COLOR_HEALING)

func _on_battle_lost() -> void:
	## Log defeat
	_add_entry("===== DEFEAT =====", COLOR_DEATH)

func _on_movement_finished(unit: Unit) -> void:
	## Log movement (optional)
	_add_entry("%s moved to (%d, %d)" % [unit.unit_name, unit.grid_position.x, unit.grid_position.y], COLOR_MOVEMENT)

func _on_attack_executed(attacker: Unit, target: Unit, hit: bool, _damage: int) -> void:
	## Log basic attacks (when not using abilities)
	# Note: This may duplicate with ability_executed, use sparingly
	pass

func _on_unit_teleported(unit: Unit, from: Vector2i, to: Vector2i) -> void:
	## Log teleport movement
	_add_entry("%s teleported from (%d,%d) to (%d,%d)" % [
		unit.unit_name, from.x, from.y, to.x, to.y
	], COLOR_MOVEMENT)

func _on_scroll_changed(_value: float) -> void:
	## Track manual scrolling to disable auto-scroll
	var scrollbar = scroll_container.get_v_scroll_bar()
	# If user scrolled away from bottom, disable auto-scroll
	_auto_scroll = scrollbar.value >= scrollbar.max_value - scroll_container.size.y - 10
