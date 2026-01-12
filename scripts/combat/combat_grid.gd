## Combat Grid - 12x12 tactical battlefield display
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.1-combat-grid-display.md
class_name CombatGrid
extends Node2D

# ===== SIGNALS =====
signal tile_clicked(coords: Vector2i)
signal tile_hovered(coords: Vector2i)

# ===== CONSTANTS =====
const GRID_WIDTH: int = 12
const GRID_HEIGHT: int = 12
const TILE_SIZE: int = 64

# Tile type identifiers
const TILE_WALKABLE: int = 0
const TILE_OBSTACLE: int = 1

# Colors from spec
const COLOR_WALKABLE: Color = Color("#4a6741")
const COLOR_WALKABLE_BORDER: Color = Color("#3d5636")
const COLOR_OBSTACLE: Color = Color("#2d3436")
const COLOR_OBSTACLE_BORDER: Color = Color("#1a1a2e")
const COLOR_BACKGROUND: Color = Color("#0d1117")

# Movement overlay colors (Task 1.5)
const COLOR_VALID_MOVE: Color = Color("#27ae60", 0.4)  # 40% opacity green
const COLOR_PATH_LINE: Color = Color("#3498db")  # Blue

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

# ===== LIFECYCLE =====
func _ready() -> void:
	_initialize_grid_data()
	_create_tileset()
	_generate_default_grid()
	_setup_movement_overlay()
	_setup_path_preview()
	_setup_pathfinding()
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

	# Add tiles to source (walkable at 0,0 and obstacle at 1,0)
	source.create_tile(Vector2i(0, 0))  # Walkable
	source.create_tile(Vector2i(1, 0))  # Obstacle

	# Add source to tileset
	_tile_set.add_source(source, 0)

	# Apply tileset to TileMapLayer
	tile_map.tile_set = _tile_set

func _create_tile_atlas_texture() -> ImageTexture:
	## Create an atlas texture containing both tile types
	var atlas_width = TILE_SIZE * 2  # 2 tiles wide
	var atlas_height = TILE_SIZE

	var image = Image.create(atlas_width, atlas_height, false, Image.FORMAT_RGBA8)

	# Draw walkable tile (left side, 0-63)
	_draw_tile_to_image(image, 0, COLOR_WALKABLE, COLOR_WALKABLE_BORDER)

	# Draw obstacle tile (right side, 64-127)
	_draw_tile_to_image(image, TILE_SIZE, COLOR_OBSTACLE, COLOR_OBSTACLE_BORDER)

	var texture = ImageTexture.create_from_image(image)
	return texture

func _draw_tile_to_image(image: Image, x_offset: int, fill_color: Color, border_color: Color) -> void:
	## Draw a single tile with fill and 1px border
	for x in range(TILE_SIZE):
		for y in range(TILE_SIZE):
			var is_border = (x == 0 or x == TILE_SIZE - 1 or y == 0 or y == TILE_SIZE - 1)
			var color = border_color if is_border else fill_color
			image.set_pixel(x_offset + x, y, color)

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
	## Check if a tile is walkable
	return get_tile_type(coords) == TILE_WALKABLE

func is_obstacle(coords: Vector2i) -> bool:
	## Check if a tile is an obstacle
	return get_tile_type(coords) == TILE_OBSTACLE

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

func clear_grid() -> void:
	## Clear all tiles to walkable
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			_set_tile(Vector2i(x, y), TILE_WALKABLE)

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
