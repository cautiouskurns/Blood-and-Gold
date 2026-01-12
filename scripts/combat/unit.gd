## Unit - Base class for all combat units (party, soldiers, enemies)
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.2-unit-placeholder-sprites.md
class_name Unit
extends Node2D

# ===== SIGNALS =====
signal unit_clicked(unit: Unit)
signal unit_moved(unit: Unit, from: Vector2i, to: Vector2i)
signal unit_damaged(unit: Unit, amount: int)
signal unit_died(unit: Unit)
signal movement_started(unit: Unit)
signal movement_finished(unit: Unit)

# ===== ENUMS =====
enum UnitType { PLAYER, THORNE, LYRA, MATTHIAS, ENEMY, INFANTRY, ARCHER }

# ===== CONSTANTS =====
const SPRITE_SIZE: int = 56
const MOVE_DURATION_PER_TILE: float = 0.15  # Seconds per tile (Task 1.5)

# HP Bar colors from spec (Task 1.3)
const COLOR_HP_HEALTHY: Color = Color("#27ae60")    # Green - HP > 25%
const COLOR_HP_CRITICAL: Color = Color("#c0392b")   # Red - HP <= 25%
const COLOR_HP_BACKGROUND: Color = Color("#7f1d1d") # Dark red background

# Selection colors from spec (Task 1.4)
const COLOR_SELECTION: Color = Color("#f1c40f")     # Yellow selection outline
const SELECTION_OUTLINE_WIDTH: int = 3
const CLICK_RADIUS: int = 28  # Half of sprite size

# HP Bar dimensions from spec
const HP_BAR_WIDTH: int = 48
const HP_BAR_HEIGHT: int = 6
const HP_BAR_OFFSET_Y: int = -40
const LOW_HP_THRESHOLD: float = 0.25  # 25%

# Unit colors from spec
const UNIT_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#3498db"),    # Blue
	UnitType.THORNE: Color("#2980b9"),    # Dark Blue
	UnitType.LYRA: Color("#9b59b6"),      # Purple
	UnitType.MATTHIAS: Color("#f39c12"),  # Orange
	UnitType.ENEMY: Color("#e74c3c"),     # Red
	UnitType.INFANTRY: Color("#1abc9c"),  # Teal (soldier)
	UnitType.ARCHER: Color("#16a085"),    # Dark Teal (soldier)
}

const UNIT_BORDER_COLORS: Dictionary = {
	UnitType.PLAYER: Color("#2980b9"),
	UnitType.THORNE: Color("#1f618d"),
	UnitType.LYRA: Color("#7d3c98"),
	UnitType.MATTHIAS: Color("#d68910"),
	UnitType.ENEMY: Color("#c0392b"),
	UnitType.INFANTRY: Color("#17a589"),
	UnitType.ARCHER: Color("#138d75"),
}

const UNIT_LETTERS: Dictionary = {
	UnitType.PLAYER: "P",
	UnitType.THORNE: "T",
	UnitType.LYRA: "L",
	UnitType.MATTHIAS: "M",
	UnitType.ENEMY: "E",
	UnitType.INFANTRY: "I",
	UnitType.ARCHER: "A",
}

# ===== EXPORTED PROPERTIES =====
@export var unit_type: UnitType = UnitType.PLAYER
@export var unit_name: String = "Unit"
@export var is_enemy: bool = false
@export var max_hp: int = 30
@export var movement_range: int = 5  # Tiles per turn (Task 1.5)

# ===== NODE REFERENCES =====
@onready var sprite: Sprite2D = $Sprite2D
@onready var letter_label: Label = $LetterLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var selection_indicator: Sprite2D = $SelectionIndicator
@onready var click_area: Area2D = $ClickArea

# ===== INTERNAL STATE =====
var grid_position: Vector2i = Vector2i.ZERO
var current_hp: int = 30
var combat_grid: CombatGrid = null
var is_selected: bool = false
var _is_moving: bool = false
var _movement_tween: Tween

# ===== LIFECYCLE =====
func _ready() -> void:
	current_hp = max_hp
	_update_visual()
	_setup_hp_bar()
	_update_hp_bar()
	_setup_selection_indicator()
	_setup_click_detection()
	add_to_group("units")

	# Set enemy flag based on unit type
	is_enemy = (unit_type == UnitType.ENEMY)

func _update_visual() -> void:
	## Update sprite and label based on unit type
	_generate_sprite_texture()
	_update_letter_label()

func _generate_sprite_texture() -> void:
	## Generate a colored square texture for the unit
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)

	var fill_color = UNIT_COLORS.get(unit_type, Color.WHITE)
	var border_color = UNIT_BORDER_COLORS.get(unit_type, Color.GRAY)

	# Draw filled rectangle with 2px border
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var is_border = (x < 2 or x >= SPRITE_SIZE - 2 or y < 2 or y >= SPRITE_SIZE - 2)
			var color = border_color if is_border else fill_color
			image.set_pixel(x, y, color)

	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.centered = true

func _update_letter_label() -> void:
	## Update the letter label with unit's identifier
	var letter = UNIT_LETTERS.get(unit_type, "?")
	letter_label.text = letter
	letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# ===== HP BAR MANAGEMENT =====
func _setup_hp_bar() -> void:
	## Configure HP bar styling with custom StyleBoxFlat for colors
	if not hp_bar:
		return

	# Set HP bar size and position (centered above unit)
	hp_bar.custom_minimum_size = Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT)
	hp_bar.size = Vector2(HP_BAR_WIDTH, HP_BAR_HEIGHT)
	hp_bar.position = Vector2(-HP_BAR_WIDTH / 2, HP_BAR_OFFSET_Y)

	# Configure ProgressBar properties
	hp_bar.min_value = 0
	hp_bar.max_value = 100
	hp_bar.show_percentage = false

	# Apply background style (dark red - represents missing health)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = COLOR_HP_BACKGROUND
	bg_style.corner_radius_top_left = 1
	bg_style.corner_radius_top_right = 1
	bg_style.corner_radius_bottom_left = 1
	bg_style.corner_radius_bottom_right = 1
	hp_bar.add_theme_stylebox_override("background", bg_style)

func _update_hp_bar() -> void:
	## Update HP bar value and color based on current HP
	if not hp_bar:
		return

	# Calculate percentage and update bar value
	var hp_percent = get_hp_percentage()
	hp_bar.value = hp_percent * 100

	# Update fill color based on HP threshold
	_update_hp_bar_color(hp_percent)

func _update_hp_bar_color(hp_percent: float) -> void:
	## Update the HP bar fill color based on current HP percentage
	var fill_style = StyleBoxFlat.new()

	# Use critical (red) color when HP is at or below 25%
	if hp_percent <= LOW_HP_THRESHOLD:
		fill_style.bg_color = COLOR_HP_CRITICAL
	else:
		fill_style.bg_color = COLOR_HP_HEALTHY

	fill_style.corner_radius_top_left = 1
	fill_style.corner_radius_top_right = 1
	fill_style.corner_radius_bottom_left = 1
	fill_style.corner_radius_bottom_right = 1
	hp_bar.add_theme_stylebox_override("fill", fill_style)

# ===== SELECTION MANAGEMENT (Task 1.4) =====
func _setup_selection_indicator() -> void:
	## Create yellow outline texture for selection indicator
	if not selection_indicator:
		return

	var indicator_size = SPRITE_SIZE + (SELECTION_OUTLINE_WIDTH * 2)
	var image = Image.create(indicator_size, indicator_size, false, Image.FORMAT_RGBA8)

	# Draw hollow rectangle (outline only)
	for x in range(indicator_size):
		for y in range(indicator_size):
			var is_outline = (
				x < SELECTION_OUTLINE_WIDTH or
				x >= indicator_size - SELECTION_OUTLINE_WIDTH or
				y < SELECTION_OUTLINE_WIDTH or
				y >= indicator_size - SELECTION_OUTLINE_WIDTH
			)
			if is_outline:
				image.set_pixel(x, y, COLOR_SELECTION)
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)

	var texture = ImageTexture.create_from_image(image)
	selection_indicator.texture = texture
	selection_indicator.centered = true
	selection_indicator.visible = false  # Hidden by default

func _setup_click_detection() -> void:
	## Configure Area2D for click detection
	if not click_area:
		push_error("[Unit] ClickArea not found for %s" % unit_name)
		return
	click_area.input_event.connect(_on_click_area_input_event)
	print("[Unit] Click detection setup for %s" % unit_name)

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	## Handle click input on unit
	if event is InputEventMouseButton:
		print("[Unit] Mouse event on %s: button=%d pressed=%s" % [unit_name, event.button_index, event.pressed])
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_click()

func _handle_click() -> void:
	## Process click on this unit
	unit_clicked.emit(self)

	# Let CombatManager handle selection logic
	if not is_enemy and is_alive():
		CombatManager.select_unit(self)
	else:
		# Clicking enemy or dead unit deselects
		CombatManager.deselect_unit()

func select() -> void:
	## Mark this unit as selected and show indicator
	is_selected = true
	if selection_indicator:
		selection_indicator.visible = true

func deselect() -> void:
	## Mark this unit as not selected and hide indicator
	is_selected = false
	if selection_indicator:
		selection_indicator.visible = false

# ===== PUBLIC API =====
func place_on_grid(coords: Vector2i) -> void:
	## Place unit on grid at specified coordinates
	var old_position = grid_position
	grid_position = coords

	if combat_grid:
		position = combat_grid.grid_to_world(coords)

	if old_position != coords:
		unit_moved.emit(self, old_position, coords)

func get_grid_position() -> Vector2i:
	## Get current grid position
	return grid_position

func set_combat_grid(grid: CombatGrid) -> void:
	## Set reference to the combat grid
	combat_grid = grid

func snap_to_grid() -> void:
	## Snap unit to its current grid position
	if combat_grid:
		position = combat_grid.grid_to_world(grid_position)

func set_unit_type(type: UnitType) -> void:
	## Change unit type and update visuals
	unit_type = type
	is_enemy = (type == UnitType.ENEMY)
	_update_visual()

func take_damage(amount: int) -> void:
	## Apply damage to unit and update HP bar
	current_hp = max(0, current_hp - amount)
	_update_hp_bar()
	unit_damaged.emit(self, amount)

	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	## Heal unit and update HP bar
	current_hp = min(max_hp, current_hp + amount)
	_update_hp_bar()

func _die() -> void:
	## Handle unit death
	unit_died.emit(self)
	# Don't queue_free yet - let combat manager handle removal

func get_hp_percentage() -> float:
	## Get HP as percentage (0.0 to 1.0)
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)

func is_alive() -> bool:
	## Check if unit is still alive
	return current_hp > 0

func is_friendly() -> bool:
	## Check if unit is friendly (not enemy)
	return not is_enemy

# ===== MOVEMENT (Task 1.5) =====
func is_moving() -> bool:
	## Check if unit is currently animating movement
	return _is_moving

func move_along_path(path: Array[Vector2i]) -> void:
	## Animate unit movement along a path
	if path.size() < 2:
		return  # Need at least start and end

	_is_moving = true
	movement_started.emit(self)

	# Cancel any existing tween
	if _movement_tween and _movement_tween.is_running():
		_movement_tween.kill()

	_movement_tween = create_tween()
	_movement_tween.set_ease(Tween.EASE_IN_OUT)
	_movement_tween.set_trans(Tween.TRANS_LINEAR)

	# Animate through each tile in path (skip first - we're already there)
	for i in range(1, path.size()):
		var target_coords = path[i]
		var target_pos = combat_grid.grid_to_world(target_coords)
		_movement_tween.tween_property(self, "position", target_pos, MOVE_DURATION_PER_TILE)

	# Update grid position to final destination
	var final_coords = path[path.size() - 1]
	_movement_tween.tween_callback(_on_movement_complete.bind(final_coords))

func _on_movement_complete(final_coords: Vector2i) -> void:
	## Called when movement animation finishes
	var old_pos = grid_position
	grid_position = final_coords
	_is_moving = false
	movement_finished.emit(self)
	unit_moved.emit(self, old_pos, final_coords)

# ===== STATIC HELPERS =====
static func get_unit_display_name(type: UnitType) -> String:
	## Get display name for unit type
	match type:
		UnitType.PLAYER: return "Player"
		UnitType.THORNE: return "Thorne"
		UnitType.LYRA: return "Lyra"
		UnitType.MATTHIAS: return "Matthias"
		UnitType.ENEMY: return "Enemy"
		UnitType.INFANTRY: return "Infantry"
		UnitType.ARCHER: return "Archer"
		_: return "Unknown"
