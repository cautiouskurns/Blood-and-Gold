## Combat Grid - 12x12 tactical battlefield display
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.1-combat-grid-display.md
class_name CombatGrid
extends Node2D

# ===== SIGNALS =====
signal tile_clicked(coords: Vector2i)
signal tile_hovered(coords: Vector2i)

# ===== CONSTANTS =====
const GRID_WIDTH: int = 14  # Task 2.17: Increased from 12 to support Ruined Fort map
const GRID_HEIGHT: int = 14  # Task 2.17: Increased from 12 to support Ruined Fort map
const TILE_SIZE: int = 64

# Tile type identifiers
const TILE_WALKABLE: int = 0
const TILE_OBSTACLE: int = 1
const TILE_COVER: int = 2           # Task 2.12: Cover tiles (+2 Defense)
const TILE_HIGH_GROUND: int = 3     # Task 2.12: High ground tiles (+2 ranged attack)
const TILE_COVER_HIGH_GROUND: int = 4  # Task 2.12: Combined (both bonuses)
const TILE_DIFFICULT: int = 5       # Task 2.16: Difficult terrain (stream, mud - double movement cost)
const TILE_WALL: int = 6            # Task 2.17: Wall (blocks movement AND line of sight)

# Terrain bonus constants (Task 2.12)
const COVER_DEFENSE_BONUS: int = 2
const HIGH_GROUND_ATTACK_BONUS: int = 2

# Difficult terrain constants (Task 2.16)
const DIFFICULT_TERRAIN_COST: int = 2  # Movement cost multiplier

# Colors from spec
const COLOR_WALKABLE: Color = Color("#4a6741")
const COLOR_WALKABLE_BORDER: Color = Color("#3d5636")
const COLOR_OBSTACLE: Color = Color("#2d3436")
const COLOR_OBSTACLE_BORDER: Color = Color("#1a1a2e")
const COLOR_BACKGROUND: Color = Color("#0d1117")

# Cover and High Ground colors (Task 2.12)
const COLOR_COVER: Color = Color("#3d5636")           # Darker forest green
const COLOR_COVER_BORDER: Color = Color("#2d4226")
const COLOR_HIGH_GROUND: Color = Color("#8b7355")     # Tan/brown
const COLOR_HIGH_GROUND_BORDER: Color = Color("#6b5345")
const COLOR_COVER_HIGH_GROUND: Color = Color("#5d6355")  # Mixed green-brown
const COLOR_COVER_HIGH_GROUND_BORDER: Color = Color("#4d5345")

# Difficult terrain colors (Task 2.16: stream/water)
const COLOR_DIFFICULT: Color = Color("#3498db")       # Blue for water
const COLOR_DIFFICULT_BORDER: Color = Color("#2980b9") # Darker blue border

# Wall colors (Task 2.17: blocks movement and LoS)
const COLOR_WALL: Color = Color("#4a4a4a")            # Dark gray stone
const COLOR_WALL_BORDER: Color = Color("#333333")     # Very dark gray border

# Movement overlay colors (Task 1.5)
const COLOR_VALID_MOVE: Color = Color("#27ae60", 0.4)  # 40% opacity green
const COLOR_PATH_LINE: Color = Color("#3498db")  # Blue

# Attack range overlay colors (Task 2.7)
const COLOR_ATTACK_RANGE: Color = Color("#4a90d9", 0.3)  # Blue tint at 30% opacity
const COLOR_ATTACK_RANGE_BLOCKED: Color = Color("#888888", 0.2)  # Gray for blocked LoS

# ===== NODE REFERENCES =====
@onready var tile_map: TileMapLayer = $TileMapLayer

# ===== INTERNAL STATE =====
var _tile_set: TileSet
var _grid_data: Array[Array] = []  # Stores tile types for quick lookup

# Movement overlay state (Task 1.5)
var _movement_overlay: Node2D
var _path_preview: Line2D
var _valid_move_tiles: Array[Vector2i] = []
var pathfinding: Pathfinding

# Attack range overlay state (Task 2.7)
var _attack_range_overlay: Node2D
var _attack_range_tiles: Array[Vector2i] = []

# ===== LIFECYCLE =====
func _ready() -> void:
	_initialize_grid_data()
	_create_tileset()
	_generate_default_grid()
	_setup_movement_overlay()
	_setup_path_preview()
	_setup_pathfinding()
	_setup_attack_range_overlay()  # Task 2.7
	# Defer centering to ensure viewport size is correct
	call_deferred("_center_grid")

func _initialize_grid_data() -> void:
	## Initialize the grid data array
	_grid_data.clear()
	for x in range(GRID_WIDTH):
		var column: Array[int] = []
		column.resize(GRID_HEIGHT)
		column.fill(TILE_WALKABLE)
		_grid_data.append(column)

func _create_tileset() -> void:
	## Create TileSet with programmatic tiles
	_tile_set = TileSet.new()
	_tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Create tile source with our custom tiles
	var source = TileSetAtlasSource.new()
	source.texture = _create_tile_atlas_texture()
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Add tiles to source (Task 2.17: expanded to 7 tile types)
	source.create_tile(Vector2i(0, 0))  # Walkable
	source.create_tile(Vector2i(1, 0))  # Obstacle
	source.create_tile(Vector2i(2, 0))  # Cover
	source.create_tile(Vector2i(3, 0))  # High Ground
	source.create_tile(Vector2i(4, 0))  # Cover + High Ground
	source.create_tile(Vector2i(5, 0))  # Difficult terrain (stream)
	source.create_tile(Vector2i(6, 0))  # Wall (blocks movement and LoS)

	# Add source to tileset
	_tile_set.add_source(source, 0)

	# Apply tileset to TileMapLayer
	tile_map.tile_set = _tile_set

func _create_tile_atlas_texture() -> ImageTexture:
	## Create an atlas texture containing all tile types (Task 2.17: expanded to 7)
	var atlas_width = TILE_SIZE * 7  # 7 tiles wide
	var atlas_height = TILE_SIZE

	var image = Image.create(atlas_width, atlas_height, false, Image.FORMAT_RGBA8)

	# Draw walkable tile (0)
	_draw_tile_to_image(image, 0, COLOR_WALKABLE, COLOR_WALKABLE_BORDER)

	# Draw obstacle tile (1)
	_draw_tile_to_image(image, TILE_SIZE, COLOR_OBSTACLE, COLOR_OBSTACLE_BORDER)

	# Draw cover tile (2) - Task 2.12
	_draw_tile_with_icon(image, TILE_SIZE * 2, COLOR_COVER, COLOR_COVER_BORDER, "cover")

	# Draw high ground tile (3) - Task 2.12
	_draw_tile_with_icon(image, TILE_SIZE * 3, COLOR_HIGH_GROUND, COLOR_HIGH_GROUND_BORDER, "high_ground")

	# Draw cover + high ground tile (4) - Task 2.12
	_draw_tile_with_icon(image, TILE_SIZE * 4, COLOR_COVER_HIGH_GROUND, COLOR_COVER_HIGH_GROUND_BORDER, "both")

	# Draw difficult terrain tile (5) - Task 2.16: stream/water
	_draw_tile_with_icon(image, TILE_SIZE * 5, COLOR_DIFFICULT, COLOR_DIFFICULT_BORDER, "water")

	# Draw wall tile (6) - Task 2.17: blocks movement and LoS
	_draw_tile_with_icon(image, TILE_SIZE * 6, COLOR_WALL, COLOR_WALL_BORDER, "wall")

	var texture = ImageTexture.create_from_image(image)
	return texture

func _draw_tile_to_image(image: Image, x_offset: int, fill_color: Color, border_color: Color) -> void:
	## Draw a single tile with fill and 1px border
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			var is_border = (x == 0 or x == TILE_SIZE - 1 or y == 0 or y == TILE_SIZE - 1)
			var color = border_color if is_border else fill_color
			image.set_pixel(x_offset + x, y, color)

func _draw_tile_with_icon(image: Image, x_offset: int, fill_color: Color, border_color: Color, icon_type: String) -> void:
	## Draw a tile with a terrain indicator icon (Task 2.12)
	# First draw the base tile
	_draw_tile_to_image(image, x_offset, fill_color, border_color)

	# Icon parameters
	var icon_color = Color(1, 1, 1, 0.6)  # White at 60% opacity
	var center_x = TILE_SIZE / 2
	var center_y = TILE_SIZE / 2

	match icon_type:
		"cover":
			# Draw shield-like icon (filled rounded rectangle)
			_draw_shield_icon(image, x_offset, center_x, center_y, icon_color)
		"high_ground":
			# Draw up arrow icon
			_draw_arrow_icon(image, x_offset, center_x, center_y, icon_color)
		"both":
			# Draw both icons (shield smaller, arrow smaller)
			_draw_shield_icon(image, x_offset, center_x - 10, center_y, icon_color, 0.7)
			_draw_arrow_icon(image, x_offset, center_x + 10, center_y, icon_color, 0.7)
		"water":
			# Draw wave icon for difficult terrain (Task 2.16)
			_draw_wave_icon(image, x_offset, center_x, center_y, icon_color)
		"wall":
			# Draw brick pattern icon for walls (Task 2.17)
			_draw_brick_icon(image, x_offset, center_x, center_y, icon_color)

func _draw_shield_icon(image: Image, x_offset: int, cx: int, cy: int, color: Color, scale: float = 1.0) -> void:
	## Draw a simple shield icon (rounded top, pointed bottom)
	var size = int(12 * scale)
	var half = size / 2

	for x in range(-half, half + 1):
		for y in range(-half - 2, half + 4):
			var px = x_offset + cx + x
			var py = cy + y

			if px < x_offset or px >= x_offset + TILE_SIZE:
				continue
			if py < 0 or py >= TILE_SIZE:
				continue

			# Shield shape: rectangle top, triangle bottom
			var in_shield = false
			if y >= -half - 2 and y <= 2:
				# Top rectangle part
				if abs(x) <= half:
					in_shield = true
			elif y > 2 and y <= half + 4:
				# Bottom triangle part
				var max_x = half - (y - 2) * half / (half + 2)
				if abs(x) <= max_x:
					in_shield = true

			if in_shield:
				image.set_pixel(px, py, color)

func _draw_arrow_icon(image: Image, x_offset: int, cx: int, cy: int, color: Color, scale: float = 1.0) -> void:
	## Draw an up arrow icon
	var size = int(10 * scale)
	var half = size / 2

	for x in range(-half - 2, half + 3):
		for y in range(-half - 4, half + 2):
			var px = x_offset + cx + x
			var py = cy + y

			if px < x_offset or px >= x_offset + TILE_SIZE:
				continue
			if py < 0 or py >= TILE_SIZE:
				continue

			var in_arrow = false

			# Arrow head (triangle pointing up)
			if y >= -half - 4 and y <= 0:
				var max_x = (half + 2) - abs(y + half + 4) * (half + 2) / (half + 4)
				if abs(x) <= max_x:
					in_arrow = true

			# Arrow shaft (vertical line)
			if y > 0 and y <= half + 2:
				if abs(x) <= 2:
					in_arrow = true

			if in_arrow:
				image.set_pixel(px, py, color)

func _draw_wave_icon(image: Image, x_offset: int, cx: int, cy: int, color: Color) -> void:
	## Draw a wave/water icon (Task 2.16: difficult terrain indicator)
	# Draw three wave lines
	for wave in range(3):
		var wave_y = cy - 8 + wave * 8
		for x in range(-16, 17):
			var px = x_offset + cx + x
			if px < x_offset or px >= x_offset + TILE_SIZE:
				continue

			# Create sine wave pattern
			var wave_offset = sin((x + wave * 10) * 0.4) * 3
			var py = int(wave_y + wave_offset)

			if py >= 0 and py < TILE_SIZE:
				image.set_pixel(px, py, color)
				# Make lines thicker
				if py + 1 < TILE_SIZE:
					image.set_pixel(px, py + 1, color)

func _draw_brick_icon(image: Image, x_offset: int, cx: int, cy: int, color: Color) -> void:
	## Draw a brick pattern icon (Task 2.17: wall indicator)
	# Draw 3 rows of bricks
	var brick_width = 12
	var brick_height = 6
	var mortar_width = 2

	for row in range(3):
		var row_y = cy - 10 + row * (brick_height + mortar_width)
		# Offset alternate rows
		var row_offset = 0 if row % 2 == 0 else brick_width / 2 + mortar_width / 2

		for brick in range(3):
			var brick_x = cx - brick_width - mortar_width + brick * (brick_width + mortar_width) + row_offset

			# Draw brick rectangle
			for bx in range(brick_width):
				for by in range(brick_height):
					var px = x_offset + brick_x + bx
					var py = row_y + by

					if px >= x_offset and px < x_offset + TILE_SIZE:
						if py >= 0 and py < TILE_SIZE:
							# Draw outline
							var is_outline = (bx == 0 or bx == brick_width - 1 or by == 0 or by == brick_height - 1)
							if is_outline:
								image.set_pixel(px, py, color)

func _center_grid() -> void:
	## Center the grid in the viewport
	# Use design resolution (matches project.godot window/size settings)
	var viewport_size = Vector2(1920, 1080)
	var viewport_rect = get_viewport_rect()
	if viewport_rect.size.x > 0 and viewport_rect.size.y > 0:
		viewport_size = viewport_rect.size
	var grid_pixel_size = Vector2(GRID_WIDTH * TILE_SIZE, GRID_HEIGHT * TILE_SIZE)
	position = (viewport_size - grid_pixel_size) / 2
	print("[CombatGrid] Centered at %s (viewport: %s, grid: %s)" % [position, viewport_size, grid_pixel_size])

func _generate_default_grid() -> void:
	## Fill grid with walkable tiles and add test obstacles
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			_set_tile(Vector2i(x, y), TILE_WALKABLE)

	# Add test obstacles (small cluster in center)
	_set_obstacle(Vector2i(5, 5))
	_set_obstacle(Vector2i(5, 6))
	_set_obstacle(Vector2i(6, 5))

	# Add some edge obstacles for visual variety
	_set_obstacle(Vector2i(2, 2))
	_set_obstacle(Vector2i(9, 3))
	_set_obstacle(Vector2i(3, 8))
	_set_obstacle(Vector2i(8, 9))

	# Task 2.12: Add cover tiles (trees/rocks for defense bonus)
	set_tile_cover(Vector2i(1, 4))
	set_tile_cover(Vector2i(1, 5))
	set_tile_cover(Vector2i(2, 6))
	set_tile_cover(Vector2i(10, 4))
	set_tile_cover(Vector2i(10, 5))
	set_tile_cover(Vector2i(9, 6))

	# Task 2.12: Add high ground tiles (elevated positions for ranged bonus)
	set_tile_high_ground(Vector2i(6, 1))
	set_tile_high_ground(Vector2i(7, 1))
	set_tile_high_ground(Vector2i(6, 10))
	set_tile_high_ground(Vector2i(7, 10))

	# Task 2.12: Add combined cover + high ground tile (defensive tower)
	set_tile_cover_high_ground(Vector2i(11, 1))
	set_tile_cover_high_ground(Vector2i(0, 10))

	print("[CombatGrid] Added terrain: 6 cover tiles, 4 high ground tiles, 2 combined tiles")

func _set_tile(coords: Vector2i, tile_type: int) -> void:
	## Set a tile at the given coordinates
	if not _is_valid_coords(coords):
		return

	_grid_data[coords.x][coords.y] = tile_type
	var atlas_coords = Vector2i(tile_type, 0)  # 0 = walkable, 1 = obstacle
	tile_map.set_cell(coords, 0, atlas_coords)

func _set_obstacle(coords: Vector2i) -> void:
	## Set a tile as an obstacle
	_set_tile(coords, TILE_OBSTACLE)

func _is_valid_coords(coords: Vector2i) -> bool:
	## Check if coordinates are within grid bounds
	return coords.x >= 0 and coords.x < GRID_WIDTH and coords.y >= 0 and coords.y < GRID_HEIGHT

# ===== PUBLIC API =====
func get_tile_type(coords: Vector2i) -> int:
	## Get the tile type at the given coordinates
	## Returns -1 for invalid coordinates
	if not _is_valid_coords(coords):
		return -1
	return _grid_data[coords.x][coords.y]

func is_walkable(coords: Vector2i) -> bool:
	## Check if a tile is walkable (includes cover, high ground, and difficult terrain)
	var tile_type = get_tile_type(coords)
	return tile_type == TILE_WALKABLE or tile_type == TILE_COVER or tile_type == TILE_HIGH_GROUND or tile_type == TILE_COVER_HIGH_GROUND or tile_type == TILE_DIFFICULT

func is_obstacle(coords: Vector2i) -> bool:
	## Check if a tile is an obstacle
	return get_tile_type(coords) == TILE_OBSTACLE

func is_wall(coords: Vector2i) -> bool:
	## Check if a tile is a wall (blocks movement AND line of sight) - Task 2.17
	return get_tile_type(coords) == TILE_WALL

func blocks_los(coords: Vector2i) -> bool:
	## Check if a tile blocks line of sight (obstacles and walls) - Task 2.17
	var tile_type = get_tile_type(coords)
	return tile_type == TILE_OBSTACLE or tile_type == TILE_WALL

# ===== TERRAIN BONUS METHODS (Task 2.12) =====
func is_cover(coords: Vector2i) -> bool:
	## Check if a tile provides cover (+2 Defense)
	var tile_type = get_tile_type(coords)
	return tile_type == TILE_COVER or tile_type == TILE_COVER_HIGH_GROUND

func is_high_ground(coords: Vector2i) -> bool:
	## Check if a tile is high ground (+2 ranged attack)
	var tile_type = get_tile_type(coords)
	return tile_type == TILE_HIGH_GROUND or tile_type == TILE_COVER_HIGH_GROUND

func get_cover_bonus(coords: Vector2i) -> int:
	## Get the cover defense bonus for a tile position
	## Returns COVER_DEFENSE_BONUS (+2) if tile provides cover, 0 otherwise
	if is_cover(coords):
		return COVER_DEFENSE_BONUS
	return 0

func get_high_ground_bonus(coords: Vector2i) -> int:
	## Get the high ground attack bonus for a tile position
	## Returns HIGH_GROUND_ATTACK_BONUS (+2) if tile is high ground, 0 otherwise
	if is_high_ground(coords):
		return HIGH_GROUND_ATTACK_BONUS
	return 0

func get_terrain_info(coords: Vector2i) -> Dictionary:
	## Get all terrain info for a tile (for tooltips)
	return {
		"has_cover": is_cover(coords),
		"has_high_ground": is_high_ground(coords),
		"has_difficult_terrain": is_difficult_terrain(coords),
		"has_wall": is_wall(coords),  # Task 2.17
		"cover_bonus": get_cover_bonus(coords),
		"high_ground_bonus": get_high_ground_bonus(coords),
		"movement_cost": get_movement_cost(coords),
		"blocks_los": blocks_los(coords)  # Task 2.17
	}

# ===== DIFFICULT TERRAIN METHODS (Task 2.16) =====
func is_difficult_terrain(coords: Vector2i) -> bool:
	## Check if a tile is difficult terrain (stream, mud - costs double movement)
	var tile_type = get_tile_type(coords)
	return tile_type == TILE_DIFFICULT

func get_movement_cost(coords: Vector2i) -> int:
	## Get the movement cost for entering a tile
	## Returns DIFFICULT_TERRAIN_COST (2) for difficult terrain, 1 otherwise
	if is_difficult_terrain(coords):
		return DIFFICULT_TERRAIN_COST
	return 1

func is_valid_position(coords: Vector2i) -> bool:
	## Check if coordinates are within grid bounds (Task 2.5: Shadowstep)
	return _is_valid_coords(coords)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	## Convert world position to grid coordinates
	var local_pos = world_pos - position
	return Vector2i(int(local_pos.x / TILE_SIZE), int(local_pos.y / TILE_SIZE))

func grid_to_world(grid_coords: Vector2i) -> Vector2:
	## Convert grid coordinates to world position (tile center)
	## Returns position relative to grid (for children of CombatGrid)
	return Vector2(
		grid_coords.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_coords.y * TILE_SIZE + TILE_SIZE / 2.0
	)

func grid_to_world_global(grid_coords: Vector2i) -> Vector2:
	## Convert grid coordinates to global world position
	## Use this for nodes that are NOT children of CombatGrid
	return position + grid_to_world(grid_coords)

func get_grid_size() -> Vector2i:
	## Get the grid dimensions
	return Vector2i(GRID_WIDTH, GRID_HEIGHT)

func get_tile_size() -> int:
	## Get the tile size in pixels
	return TILE_SIZE

func get_grid_pixel_size() -> Vector2:
	## Get the total grid size in pixels
	return Vector2(GRID_WIDTH * TILE_SIZE, GRID_HEIGHT * TILE_SIZE)

func set_tile_walkable(coords: Vector2i) -> void:
	## Set a tile as walkable
	_set_tile(coords, TILE_WALKABLE)

func set_tile_obstacle(coords: Vector2i) -> void:
	## Set a tile as an obstacle
	_set_tile(coords, TILE_OBSTACLE)

func set_tile_cover(coords: Vector2i) -> void:
	## Set a tile as cover (+2 Defense) - Task 2.12
	_set_tile(coords, TILE_COVER)

func set_tile_high_ground(coords: Vector2i) -> void:
	## Set a tile as high ground (+2 ranged attack) - Task 2.12
	_set_tile(coords, TILE_HIGH_GROUND)

func set_tile_cover_high_ground(coords: Vector2i) -> void:
	## Set a tile as both cover and high ground - Task 2.12
	_set_tile(coords, TILE_COVER_HIGH_GROUND)

func set_tile_difficult(coords: Vector2i) -> void:
	## Set a tile as difficult terrain (stream, mud) - Task 2.16
	_set_tile(coords, TILE_DIFFICULT)

func set_tile_wall(coords: Vector2i) -> void:
	## Set a tile as a wall (blocks movement and LoS) - Task 2.17
	_set_tile(coords, TILE_WALL)

func clear_grid() -> void:
	## Clear all tiles to walkable
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			_set_tile(Vector2i(x, y), TILE_WALKABLE)

# ===== MAP LOADING (Task 2.16) =====
func load_map(map_data: Dictionary) -> void:
	## Load terrain from a map data dictionary
	## Expected format: { "name": String, "width": int, "height": int, "tiles": Array[Array[int]] }
	clear_grid()

	var map_name = map_data.get("name", "Unknown Map")
	var tiles = map_data.get("tiles", [])

	# Load tiles from map data (y = row index, x = column index)
	for y in range(tiles.size()):
		var row = tiles[y]
		for x in range(row.size()):
			if x < GRID_WIDTH and y < GRID_HEIGHT:
				var tile_type = row[x]
				_set_tile(Vector2i(x, y), tile_type)

	# Update pathfinding with new terrain
	if pathfinding:
		for x in range(GRID_WIDTH):
			for y in range(GRID_HEIGHT):
				var coords = Vector2i(x, y)
				pathfinding.set_tile_walkable(coords, is_walkable(coords))

	print("[CombatGrid] Loaded map: %s" % map_name)

func get_spawn_points_party(map_data: Dictionary) -> Array[Vector2i]:
	## Get party spawn points from map data
	var spawns: Array[Vector2i] = []
	var raw_spawns = map_data.get("party_spawns", [])
	for spawn in raw_spawns:
		if spawn is Vector2i:
			spawns.append(spawn)
	return spawns

func get_spawn_points_enemy(map_data: Dictionary) -> Array[Vector2i]:
	## Get enemy spawn points from map data
	var spawns: Array[Vector2i] = []
	var raw_spawns = map_data.get("enemy_spawns", [])
	for spawn in raw_spawns:
		if spawn is Vector2i:
			spawns.append(spawn)
	return spawns

# ===== MOVEMENT OVERLAY (Task 1.5) =====
func _setup_movement_overlay() -> void:
	## Create container for movement highlight tiles
	_movement_overlay = Node2D.new()
	_movement_overlay.name = "MovementOverlay"
	_movement_overlay.z_index = 5  # Above tiles, below units
	add_child(_movement_overlay)

func _setup_path_preview() -> void:
	## Create Line2D for path preview
	_path_preview = Line2D.new()
	_path_preview.name = "PathPreview"
	_path_preview.width = 2.0
	_path_preview.default_color = COLOR_PATH_LINE
	_path_preview.z_index = 6
	add_child(_path_preview)

func _setup_pathfinding() -> void:
	## Initialize pathfinding with grid data
	pathfinding = Pathfinding.new()
	pathfinding.initialize(GRID_WIDTH, GRID_HEIGHT)

	# Task 2.16: Set combat grid reference for terrain cost queries
	pathfinding.set_combat_grid(self)

	# Mark obstacles as non-walkable
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var coords = Vector2i(x, y)
			pathfinding.set_tile_walkable(coords, is_walkable(coords))
	print("[CombatGrid] Pathfinding initialized")

func show_movement_range(from: Vector2i, movement_range: float, exclude_unit: Unit = null) -> void:
	## Display valid movement tiles for a unit
	clear_movement_overlay()
	_valid_move_tiles = pathfinding.get_reachable_tiles(from, movement_range, exclude_unit)

	for coords in _valid_move_tiles:
		var overlay = ColorRect.new()
		overlay.color = COLOR_VALID_MOVE
		overlay.size = Vector2(TILE_SIZE, TILE_SIZE)
		overlay.position = Vector2(coords.x * TILE_SIZE, coords.y * TILE_SIZE)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block clicks
		_movement_overlay.add_child(overlay)

func clear_movement_overlay() -> void:
	## Remove all movement highlights
	for child in _movement_overlay.get_children():
		child.queue_free()
	_valid_move_tiles.clear()
	hide_path_preview()

func show_path_preview(from: Vector2i, to: Vector2i, exclude_unit: Unit = null) -> void:
	## Draw path line from unit to target tile
	_path_preview.clear_points()

	if not _valid_move_tiles.has(to):
		return  # Not a valid destination

	var path = pathfinding.get_path(from, to, exclude_unit)
	for coords in path:
		var world_pos = grid_to_world(coords)  # Local coords (relative to grid)
		_path_preview.add_point(world_pos)

func hide_path_preview() -> void:
	## Clear the path preview line
	_path_preview.clear_points()

func is_valid_move_tile(coords: Vector2i) -> bool:
	## Check if a tile is in the current valid move set
	return _valid_move_tiles.has(coords)

func get_valid_move_tiles() -> Array[Vector2i]:
	## Get the current set of valid move tiles
	return _valid_move_tiles

func update_occupied_tiles(units: Array[Unit]) -> void:
	## Update pathfinding with current unit positions
	pathfinding.clear_occupied_tiles()

	# Mark current unit positions
	for unit in units:
		pathfinding.set_tile_occupied(unit.grid_position, unit)

# ===== ATTACK RANGE OVERLAY (Task 2.7) =====
func _setup_attack_range_overlay() -> void:
	## Create container for attack range highlight tiles
	_attack_range_overlay = Node2D.new()
	_attack_range_overlay.name = "AttackRangeOverlay"
	_attack_range_overlay.z_index = 4  # Below movement overlay
	add_child(_attack_range_overlay)

func show_attack_range(unit: Unit) -> void:
	## Display attack range indicator for unit's weapon
	clear_attack_range_overlay()

	if not unit:
		return

	var origin = unit.grid_position
	var weapon_range = unit.weapon_range

	# Calculate all tiles in range
	for dx in range(-weapon_range, weapon_range + 1):
		for dy in range(-weapon_range, weapon_range + 1):
			var tile = Vector2i(origin.x + dx, origin.y + dy)

			# Skip own tile
			if tile == origin:
				continue

			# Check if within range (Chebyshev distance)
			var distance = AttackResolver.get_distance(origin, tile)
			if distance > weapon_range:
				continue

			# Check if tile is within grid bounds
			if not _is_valid_coords(tile):
				continue

			# For ranged weapons, check line of sight
			var has_los = true
			if unit.is_ranged_weapon and distance > 1:
				has_los = AttackResolver.has_line_of_sight(origin, tile)

			# Create overlay for this tile
			var overlay = ColorRect.new()
			if has_los:
				overlay.color = COLOR_ATTACK_RANGE
				_attack_range_tiles.append(tile)
			else:
				overlay.color = COLOR_ATTACK_RANGE_BLOCKED

			overlay.size = Vector2(TILE_SIZE, TILE_SIZE)
			overlay.position = Vector2(tile.x * TILE_SIZE, tile.y * TILE_SIZE)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_attack_range_overlay.add_child(overlay)

	print("[CombatGrid] Showing attack range for %s: %d valid tiles (range %d)" % [
		unit.unit_name, _attack_range_tiles.size(), weapon_range
	])

func hide_attack_range() -> void:
	## Alias for clear_attack_range_overlay
	clear_attack_range_overlay()

func clear_attack_range_overlay() -> void:
	## Remove all attack range highlights
	if _attack_range_overlay:
		for child in _attack_range_overlay.get_children():
			child.queue_free()
	_attack_range_tiles.clear()

func is_in_attack_range(coords: Vector2i) -> bool:
	## Check if a tile is in the current attack range with LoS
	return _attack_range_tiles.has(coords)

func get_attack_range_tiles() -> Array[Vector2i]:
	## Get the current set of valid attack range tiles
	return _attack_range_tiles

# ===== MAP DATA (Task 2.17) =====
# Ruined Fort map - 14x14, walls block movement and LoS, rubble is difficult terrain
# Tile types: 0=walkable, 2=cover, 3=high_ground, 5=difficult, 6=wall
const RUINED_FORT_DATA: Dictionary = {
	"name": "Ruined Fort",
	"width": 14,
	"height": 14,
	"tiles": [
		# Row 0 (north - outside fort, enemy spawn area)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 1 (north wall with gaps)
		[0, 0, 0, 6, 6, 6, 0, 0, 6, 6, 6, 0, 0, 0],
		# Row 2 (rubble in gaps)
		[0, 0, 6, 0, 0, 0, 5, 5, 0, 0, 0, 6, 0, 0],
		# Row 3
		[0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0],
		# Row 4 (tower row 1 - high ground, and cover)
		[0, 6, 0, 0, 3, 3, 0, 0, 0, 2, 2, 0, 6, 0],
		# Row 5 (tower row 2)
		[0, 6, 0, 0, 3, 3, 0, 0, 0, 2, 0, 0, 6, 0],
		# Row 6
		[0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0],
		# Row 7
		[0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0],
		# Row 8 (interior cover and rubble)
		[0, 6, 0, 0, 2, 0, 0, 0, 0, 5, 0, 0, 6, 0],
		# Row 9
		[0, 6, 0, 0, 2, 2, 0, 0, 5, 5, 0, 0, 6, 0],
		# Row 10 (rubble in south gap)
		[0, 0, 6, 0, 0, 0, 5, 5, 0, 0, 0, 6, 0, 0],
		# Row 11 (south wall with gaps)
		[0, 0, 0, 6, 6, 6, 0, 0, 6, 6, 6, 0, 0, 0],
		# Row 12 (south - outside fort)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 13 (party spawn area)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	"party_spawns": [
		Vector2i(0, 13), Vector2i(1, 13), Vector2i(2, 13),
		Vector2i(11, 13), Vector2i(12, 13), Vector2i(13, 13)
	],
	"enemy_spawns": [
		Vector2i(0, 0), Vector2i(1, 0),    # Outside north-west
		Vector2i(12, 0), Vector2i(13, 0),  # Outside north-east
		Vector2i(4, 4), Vector2i(5, 5),    # On tower (high ground)
	]
}

func get_ruined_fort_data() -> Dictionary:
	## Get the Ruined Fort map data for loading
	return RUINED_FORT_DATA

# Open Field map - 12x12, minimal cover, wide open for flanking (Task 2.18)
# Tile types: 0=walkable, 2=cover
# Design intent: Sparse terrain IS the design - forces mobility-focused tactics
const OPEN_FIELD_DATA: Dictionary = {
	"name": "Open Field",
	"width": 12,
	"height": 12,
	"tiles": [
		# Row 0 (north - enemy spawn area)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 1
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 2
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 3 (rock at 2,3)
		[0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 4
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 5 (rock at 9,5)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0],
		# Row 6
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 7 (rock at 1,7)
		[0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 8
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 9 (rock at 8,9)
		[0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0],
		# Row 10
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		# Row 11 (south - party spawn area)
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	],
	"party_spawns": [
		Vector2i(0, 11), Vector2i(1, 11), Vector2i(2, 11),
		Vector2i(8, 11), Vector2i(9, 11), Vector2i(10, 11)
	],
	"enemy_spawns": [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0)
	]
}

func get_open_field_data() -> Dictionary:
	## Get the Open Field map data for loading
	return OPEN_FIELD_DATA
