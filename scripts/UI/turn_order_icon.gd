## TurnOrderIcon - Individual unit icon in turn order panel
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.6-turn-order-ui-panel.md
extends Control

# ===== CONSTANTS =====
const BORDER_WIDTH: int = 3
const ICON_CORNER_RADIUS: int = 4
const COLOR_CURRENT_TURN: Color = Color("#f1c40f")

# ===== NODE REFERENCES =====
@onready var background: Panel = $Background
@onready var letter_label: Label = $LetterLabel
@onready var current_border: Panel = $CurrentBorder

# ===== STATE =====
var _unit: Unit = null
var _is_current_turn: bool = false

# ===== LIFECYCLE =====
func _ready() -> void:
	# Initial setup handled by setup() call
	pass

# ===== PUBLIC API =====
func setup(unit: Unit) -> void:
	## Initialize icon for a specific unit
	_unit = unit

	# Wait for nodes to be ready if called before _ready
	if not is_node_ready():
		await ready

	_update_appearance()
	_setup_current_border()

func get_unit() -> Unit:
	## Return the unit this icon represents
	return _unit

func set_current_turn(is_current: bool) -> void:
	## Set whether this icon represents the current turn unit
	_is_current_turn = is_current
	if current_border:
		current_border.visible = is_current

# ===== INTERNAL METHODS =====
func _update_appearance() -> void:
	## Update visual appearance based on unit type
	if not _unit:
		return

	# Set letter from unit's type
	if letter_label:
		letter_label.text = Unit.UNIT_LETTERS.get(_unit.unit_type, "?")

	# Set background color from unit's type
	if background:
		var bg_style = StyleBoxFlat.new()
		bg_style.bg_color = Unit.UNIT_COLORS.get(_unit.unit_type, Color.GRAY)
		bg_style.corner_radius_top_left = ICON_CORNER_RADIUS
		bg_style.corner_radius_top_right = ICON_CORNER_RADIUS
		bg_style.corner_radius_bottom_left = ICON_CORNER_RADIUS
		bg_style.corner_radius_bottom_right = ICON_CORNER_RADIUS
		background.add_theme_stylebox_override("panel", bg_style)

func _setup_current_border() -> void:
	## Setup the gold border for current turn indication
	if not current_border:
		return

	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color.TRANSPARENT
	border_style.border_color = COLOR_CURRENT_TURN
	border_style.border_width_left = BORDER_WIDTH
	border_style.border_width_right = BORDER_WIDTH
	border_style.border_width_top = BORDER_WIDTH
	border_style.border_width_bottom = BORDER_WIDTH
	border_style.corner_radius_top_left = ICON_CORNER_RADIUS
	border_style.corner_radius_top_right = ICON_CORNER_RADIUS
	border_style.corner_radius_bottom_left = ICON_CORNER_RADIUS
	border_style.corner_radius_bottom_right = ICON_CORNER_RADIUS
	current_border.add_theme_stylebox_override("panel", border_style)
	current_border.visible = false  # Hidden by default
