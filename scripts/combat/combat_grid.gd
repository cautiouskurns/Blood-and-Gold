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

# ===== NODE REFERENCES =====
@onready var tile_map: TileMapLayer = $TileMapLayer

# ===== INTERNAL STATE =====
var _tile_set: TileSet
var _grid_data: Array[Array] = []  # Stores tile types for quick lookup

# ===== LIFECYCLE =====
func _ready() -> void:
	_initialize_grid_data()
	_create_tileset()
	_center_grid()
	_generate_default_grid()

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
	var viewport_size = get_viewport_rect().size
	var grid_pixel_size = Vector2(GRID_WIDTH * TILE_SIZE, GRID_HEIGHT * TILE_SIZE)
	position = (viewport_size - grid_pixel_size) / 2

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
	return position + Vector2(
		grid_coords.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_coords.y * TILE_SIZE + TILE_SIZE / 2.0
	)

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
