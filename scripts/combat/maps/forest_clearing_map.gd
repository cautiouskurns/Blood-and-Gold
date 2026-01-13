## Forest Clearing Combat Map - First "real" tactical map
## Part of: Blood & Gold Prototype
## Spec: docs/features/2.16-combat-map-forest-clearing.md
class_name ForestClearingMap
extends RefCounted

# Tile type constants (must match CombatGrid)
const TILE_WALKABLE: int = 0
const TILE_OBSTACLE: int = 1
const TILE_COVER: int = 2
const TILE_HIGH_GROUND: int = 3
const TILE_COVER_HIGH_GROUND: int = 4
const TILE_DIFFICULT: int = 5

# ===== MAP DATA =====
# Map layout based on spec (12x12):
# - Trees (T) = TILE_COVER on flanks for infantry cover
# - Stream (~) = TILE_DIFFICULT running north-south (costs double movement)
# - High Ground (H) = TILE_HIGH_GROUND overlooking clearing
# - Party spawns at Y=11 (south), Enemy spawns at Y=0 (north)

static func get_map_data() -> Dictionary:
	## Returns the complete Forest Clearing map data
	return {
		"name": "Forest Clearing",
		"width": 12,
		"height": 12,
		"tiles": _get_tile_data(),
		"party_spawns": _get_party_spawns(),
		"enemy_spawns": _get_enemy_spawns()
	}

static func _get_tile_data() -> Array:
	## Returns the 12x12 grid of tile types
	## Row 0 is north (enemy side), Row 11 is south (party side)
	var W = TILE_WALKABLE
	var T = TILE_COVER
	var H = TILE_HIGH_GROUND
	var S = TILE_DIFFICULT  # Stream

	return [
		# Row 0 (north - enemy spawn zone)
		[W, W, W, W, H, H, W, W, W, W, W, W],
		# Row 1
		[T, W, W, W, W, W, W, W, W, W, W, T],
		# Row 2
		[W, T, W, W, W, W, W, W, W, W, T, W],
		# Row 3 - Stream starts (runs east-west across center-ish)
		[W, W, W, S, S, S, S, S, S, W, W, W],
		# Row 4 - Stream continues with trees on sides
		[W, T, W, S, W, W, W, W, S, W, T, W],
		# Row 5 - Stream continues
		[W, W, W, S, W, W, W, W, S, W, W, W],
		# Row 6 - Stream continues
		[W, W, W, S, W, W, W, W, S, W, W, W],
		# Row 7 - Stream ends, trees on sides
		[W, T, W, W, W, W, W, W, W, W, T, W],
		# Row 8
		[W, W, W, W, W, W, W, W, W, W, W, W],
		# Row 9
		[T, W, W, W, W, W, W, W, W, W, W, T],
		# Row 10
		[W, T, W, W, W, W, W, W, W, W, T, W],
		# Row 11 (south - party spawn zone)
		[W, W, W, W, W, W, W, W, W, W, W, W],
	]

static func _get_party_spawns() -> Array[Vector2i]:
	## Returns spawn points for party units (south edge)
	return [
		Vector2i(0, 11),
		Vector2i(1, 11),
		Vector2i(2, 11),
		Vector2i(8, 11),
		Vector2i(9, 11),
		Vector2i(10, 11)
	]

static func _get_enemy_spawns() -> Array[Vector2i]:
	## Returns spawn points for enemy units (north edge)
	return [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(8, 0),
		Vector2i(9, 0),
		Vector2i(10, 0)
	]

# ===== MAP INFO =====
static func get_description() -> String:
	## Returns a description of this map for UI/tooltips
	return "A woodland clearing crossed by a stream. Trees on the flanks provide cover for advancing infantry. High ground in the north overlooks the battlefield."

static func get_tactical_notes() -> Array[String]:
	## Returns tactical hints for this map
	return [
		"The stream divides the battlefield - crossing costs double movement.",
		"Use trees on the flanks for cover when advancing.",
		"High ground in the north provides +2 ranged attack bonus.",
		"Go around the stream or push through - choose your approach."
	]
