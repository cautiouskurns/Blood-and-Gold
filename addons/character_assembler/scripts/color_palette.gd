@tool
extends Resource
class_name CharacterColorPalette
## A color palette resource for the Character Assembler.

@export var palette_name: String = "Custom"
@export var colors: Array[Color] = []

## Get all built-in palettes.
static func get_builtin_palettes() -> Array[CharacterColorPalette]:
	return [
		_create_ironmark(),
		_create_silvermere(),
		_create_thornwood(),
		_create_sunspire(),
		_create_bandits(),
		_create_basic(),
	]


static func _create_ironmark() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Ironmark"
	palette.colors.assign([
		Color("#4a5568"),  # Steel gray
		Color("#2d3748"),  # Dark steel
		Color("#718096"),  # Light steel
		Color("#1a202c"),  # Iron black
		Color("#c53030"),  # Military red
		Color("#9b2c2c"),  # Dark red
		Color("#e53e3e"),  # Bright red
		Color("#f7fafc"),  # White accent
		Color("#744210"),  # Leather brown
		Color("#d69e2e"),  # Gold trim
		Color("#2b6cb0"),  # Iron blue
		Color("#bee3f8"),  # Pale blue
	])
	return palette


static func _create_silvermere() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Silvermere"
	palette.colors.assign([
		Color("#6b46c1"),  # Royal purple
		Color("#553c9a"),  # Dark purple
		Color("#9f7aea"),  # Light purple
		Color("#44337a"),  # Deep purple
		Color("#d69e2e"),  # Gold
		Color("#b7791f"),  # Dark gold
		Color("#ecc94b"),  # Bright gold
		Color("#f7fafc"),  # White
		Color("#e2e8f0"),  # Silver
		Color("#a0aec0"),  # Gray silver
		Color("#2d3748"),  # Dark accent
		Color("#faf089"),  # Pale gold
	])
	return palette


static func _create_thornwood() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Thornwood"
	palette.colors.assign([
		Color("#276749"),  # Forest green
		Color("#22543d"),  # Dark green
		Color("#48bb78"),  # Light green
		Color("#1c4532"),  # Deep forest
		Color("#744210"),  # Earth brown
		Color("#5d3a1a"),  # Dark brown
		Color("#975a16"),  # Light brown
		Color("#dd6b20"),  # Autumn orange
		Color("#c05621"),  # Dark orange
		Color("#2d3748"),  # Shadow gray
		Color("#f7fafc"),  # White accent
		Color("#68d391"),  # Leaf green
	])
	return palette


static func _create_sunspire() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Sunspire"
	palette.colors.assign([
		Color("#d69e2e"),  # Desert gold
		Color("#b7791f"),  # Dark gold
		Color("#ecc94b"),  # Bright gold
		Color("#744210"),  # Sand brown
		Color("#6b46c1"),  # Arcane purple
		Color("#553c9a"),  # Dark purple
		Color("#9f7aea"),  # Light purple
		Color("#f7fafc"),  # White
		Color("#ed8936"),  # Orange
		Color("#dd6b20"),  # Dark orange
		Color("#2d3748"),  # Shadow
		Color("#faf5ff"),  # Pale purple
	])
	return palette


static func _create_bandits() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Bandits"
	palette.colors.assign([
		Color("#5d3a1a"),  # Worn leather
		Color("#744210"),  # Brown
		Color("#975a16"),  # Light brown
		Color("#2d3748"),  # Dark gray
		Color("#4a5568"),  # Gray
		Color("#718096"),  # Light gray
		Color("#1a202c"),  # Black
		Color("#c53030"),  # Blood red
		Color("#553c9a"),  # Bruise purple
		Color("#22543d"),  # Dirty green
		Color("#a0aec0"),  # Faded gray
		Color("#d69e2e"),  # Stolen gold
	])
	return palette


static func _create_basic() -> CharacterColorPalette:
	var palette = CharacterColorPalette.new()
	palette.palette_name = "Basic"
	palette.colors.assign([
		Color.WHITE,
		Color.BLACK,
		Color("#e53e3e"),  # Red
		Color("#dd6b20"),  # Orange
		Color("#d69e2e"),  # Yellow
		Color("#48bb78"),  # Green
		Color("#4299e1"),  # Blue
		Color("#9f7aea"),  # Purple
		Color("#ed64a6"),  # Pink
		Color("#718096"),  # Gray
		Color("#5d3a1a"),  # Brown
		Color("#2d3748"),  # Dark gray
	])
	return palette
