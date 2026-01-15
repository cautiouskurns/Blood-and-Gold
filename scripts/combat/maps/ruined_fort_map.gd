## RuinedFortMap - Combat map for "Clear the Ruins" contract
## Part of: Blood & Gold Prototype
## Spec: docs/features/3.4-contract-clear-the-ruins.md
## Layout: Tower (high ground), crumbling walls, rubble, hidden cache
class_name RuinedFortMap
extends RefCounted

# Tile type constants (must match CombatGrid)
const TILE_WALKABLE: int = 0
const TILE_OBSTACLE: int = 1
const TILE_COVER: int = 2
const TILE_HIGH_GROUND: int = 3
const TILE_COVER_HIGH_GROUND: int = 4
const TILE_DIFFICULT: int = 5
const TILE_WALL: int = 6  # Blocks movement AND line of sight

# Cache location - northeast corner (tile position)
const CACHE_POSITION := Vector2i(11, 8)

# ===== MAP DATA =====
# 14x14 Map Layout:
# - Tower (H) = 2x2 TILE_HIGH_GROUND in north center - archers positioned here
# - Walls (X) = TILE_WALL blocking movement and LOS - ruined fortifications
# - Rubble (R) = TILE_DIFFICULT slowing movement - crumbled stonework
# - Cover (C) = TILE_COVER for defensive positions
# - Party spawns at Y=13 (south), Enemy spawns in north/center

static func get_map_data() -> Dictionary:
	## Returns the complete Ruined Fort map data
	return {
		"name": "Ruined Fort",
		"width": 14,
		"height": 14,
		"tiles": _get_tile_data(),
		"party_spawns": _get_party_spawns(),
		"enemy_spawns": _get_enemy_spawns(),
		"cache_position": CACHE_POSITION,
	}

static func _get_tile_data() -> Array:
	## Returns the 14x14 grid of tile types
	## Row 0 is north (tower/enemy side), Row 13 is south (party side)
	var W = TILE_WALKABLE
	var X = TILE_WALL       # Wall - blocks movement and LOS
	var H = TILE_HIGH_GROUND  # Tower/elevated
	var R = TILE_DIFFICULT  # Rubble - slow terrain
	var C = TILE_COVER      # Cover positions

	return [
		# Row 0 (north - tower base)
		[W, W, X, X, X, H, H, H, H, X, X, X, W, W],
		# Row 1 (tower area)
		[W, W, X, W, W, H, H, H, H, W, W, X, W, W],
		# Row 2 (below tower)
		[X, W, W, W, W, W, W, W, W, W, W, W, W, X],
		# Row 3 (walls and rubble)
		[X, W, R, R, W, W, W, W, W, W, R, R, W, X],
		# Row 4 (melee spawn area - west)
		[W, W, R, W, W, W, W, W, W, W, W, R, W, W],
		# Row 5 (leader area)
		[W, C, W, W, W, W, C, C, W, W, W, W, C, W],
		# Row 6 (courtyard north)
		[W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		# Row 7 (courtyard center - open)
		[W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		# Row 8 (courtyard south - melee + cache area)
		[W, C, W, W, W, W, W, W, W, W, W, W, C, W],
		# Row 9 (rubble piles)
		[W, W, R, W, W, W, W, W, W, W, W, R, W, W],
		# Row 10 (approaching spawn)
		[X, W, W, W, W, W, W, W, W, W, W, W, W, X],
		# Row 11 (pre-spawn)
		[W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		# Row 12 (spawn approach)
		[W, W, W, W, W, W, W, W, W, W, W, W, W, W],
		# Row 13 (south - party spawn zone)
		[W, W, W, W, W, W, W, W, W, W, W, W, W, W],
	]

static func _get_party_spawns() -> Array[Vector2i]:
	## Returns spawn points for party units (south edge)
	## 4 party members + potential soldiers spread across south
	return [
		Vector2i(2, 13),   # Party member 1
		Vector2i(4, 13),   # Party member 2
		Vector2i(9, 13),   # Party member 3
		Vector2i(11, 13),  # Party member 4
		Vector2i(3, 12),   # Soldier 1
		Vector2i(10, 12),  # Soldier 2
	]

static func _get_enemy_spawns() -> Dictionary:
	## Returns spawn points for enemy units organized by type
	## Tower archers on high ground, melee in defensive positions, leader protected
	return {
		"archers": [
			Vector2i(5, 1),   # Tower archer 1
			Vector2i(6, 1),   # Tower archer 2
			Vector2i(7, 1),   # Tower archer 3
		],
		"melee": [
			Vector2i(2, 4),   # West melee 1
			Vector2i(3, 4),   # West melee 2
			Vector2i(10, 4),  # East melee 1
			Vector2i(11, 4),  # East melee 2
			Vector2i(4, 8),   # South melee 1
			Vector2i(9, 8),   # South melee 2
		],
		"leader": [
			Vector2i(6, 5),   # Leader - protected center position
		],
	}

# ===== MAP INFO =====
static func get_description() -> String:
	## Returns a description of this map for UI/tooltips
	return "Ancient watchtower ruins, now occupied by bandits. The tower provides height advantage for enemy archers. Crumbling walls create chokepoints."

static func get_tactical_notes() -> Array[String]:
	## Returns tactical hints for this map
	return [
		"Enemy archers hold the tower with high ground advantage (+2 attack).",
		"Use rubble piles as cover when advancing.",
		"The bandit leader stays protected - prioritize reaching him.",
		"Walls block line of sight - use them to approach the tower safely.",
		"Rumors suggest a hidden cache somewhere in the ruins..."
	]

static func get_cache_hint() -> String:
	## Returns a hint about the hidden cache location
	return "Look for a broken chest near the eastern wall."
