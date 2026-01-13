## Pathfinding - AStar2D wrapper for grid-based movement
## Part of: Blood & Gold Prototype
## Spec: docs/features/1.5-click-to-move-path-preview.md
class_name Pathfinding
extends RefCounted

# ===== CONSTANTS =====
const CARDINAL_COST: float = 1.0
const DIAGONAL_COST: float = 1.5

# ===== STATE =====
var _astar: AStar2D
var _grid_width: int
var _grid_height: int
var _walkable_tiles: Dictionary = {}  # Vector2i -> bool
var _occupied_tiles: Dictionary = {}  # Vector2i -> Unit
var _combat_grid: CombatGrid = null  # Task 2.16: Reference for terrain costs

# ===== INITIALIZATION =====
func initialize(grid_width: int, grid_height: int) -> void:
	## Set up AStar2D for the grid
	_grid_width = grid_width
	_grid_height = grid_height
	_astar = AStar2D.new()
	_build_graph()
	print("[Pathfinding] Initialized %dx%d grid" % [grid_width, grid_height])

func set_combat_grid(combat_grid: CombatGrid) -> void:
	## Set the combat grid reference for terrain cost queries (Task 2.16)
	_combat_grid = combat_grid

func _build_graph() -> void:
	## Build the pathfinding graph from walkable tiles
	_astar.clear()

	# Add all points
	for x in range(_grid_width):
		for y in range(_grid_height):
			var coords = Vector2i(x, y)
			var id = _coords_to_id(coords)
			_astar.add_point(id, Vector2(x, y))

	# Connect adjacent points
	for x in range(_grid_width):
		for y in range(_grid_height):
			var coords = Vector2i(x, y)
			_connect_neighbors(coords)

func _connect_neighbors(coords: Vector2i) -> void:
	## Connect a point to its walkable neighbors
	var id = _coords_to_id(coords)
	var neighbors = _get_neighbor_coords(coords)

	for neighbor in neighbors:
		if not _is_valid_coords(neighbor):
			continue

		var neighbor_id = _coords_to_id(neighbor)
		if _astar.are_points_connected(id, neighbor_id):
			continue

		_astar.connect_points(id, neighbor_id)

func _get_neighbor_coords(coords: Vector2i) -> Array[Vector2i]:
	## Get all 8 neighboring coordinates
	var neighbors: Array[Vector2i] = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			neighbors.append(Vector2i(coords.x + dx, coords.y + dy))
	return neighbors

# ===== PUBLIC API =====
func set_tile_walkable(coords: Vector2i, walkable: bool) -> void:
	## Mark a tile as walkable or blocked
	_walkable_tiles[coords] = walkable
	if _is_valid_coords(coords):
		_astar.set_point_disabled(_coords_to_id(coords), not walkable)

func set_tile_occupied(coords: Vector2i, unit: Unit) -> void:
	## Mark a tile as occupied by a unit
	if unit:
		_occupied_tiles[coords] = unit
	else:
		_occupied_tiles.erase(coords)

func clear_occupied_tiles() -> void:
	## Clear all occupied tile markers
	_occupied_tiles.clear()

func is_tile_blocked(coords: Vector2i, exclude_unit: Unit = null) -> bool:
	## Check if tile is blocked (obstacle or occupied)
	## exclude_unit: Optionally exclude a specific unit from blocking check
	if not _is_valid_coords(coords):
		return true
	if not _walkable_tiles.get(coords, true):
		return true
	if _occupied_tiles.has(coords):
		var occupant = _occupied_tiles[coords]
		if exclude_unit != null and occupant == exclude_unit:
			return false  # Don't count the excluded unit as blocking
		return true
	return false

func get_path(from: Vector2i, to: Vector2i, exclude_unit: Unit = null) -> Array[Vector2i]:
	## Get path from one tile to another
	if is_tile_blocked(to, exclude_unit):
		return []

	# Temporarily enable the from tile if the excluded unit is there
	var from_id = _coords_to_id(from)
	var to_id = _coords_to_id(to)

	# Temporarily disable occupied tiles for pathfinding
	var disabled_points: Array[int] = []
	for occupied_coords in _occupied_tiles.keys():
		if exclude_unit != null and _occupied_tiles[occupied_coords] == exclude_unit:
			continue  # Don't disable the moving unit's position
		var point_id = _coords_to_id(occupied_coords)
		if not _astar.is_point_disabled(point_id):
			_astar.set_point_disabled(point_id, true)
			disabled_points.append(point_id)

	var path_points = _astar.get_point_path(from_id, to_id)
	var path: Array[Vector2i] = []

	for point in path_points:
		path.append(Vector2i(int(point.x), int(point.y)))

	# Re-enable temporarily disabled points
	for point_id in disabled_points:
		_astar.set_point_disabled(point_id, false)

	return path

func get_path_cost(path: Array[Vector2i]) -> float:
	## Calculate total movement cost for a path
	## Task 2.16: Accounts for difficult terrain (double cost)
	if path.size() < 2:
		return 0.0

	var total_cost: float = 0.0
	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]
		var is_diagonal = (prev.x != curr.x and prev.y != curr.y)
		var base_cost = DIAGONAL_COST if is_diagonal else CARDINAL_COST

		# Task 2.16: Apply terrain movement cost multiplier
		var terrain_cost = _get_terrain_cost(curr)
		total_cost += base_cost * terrain_cost

	return total_cost

func _get_terrain_cost(coords: Vector2i) -> float:
	## Get terrain movement cost for a tile (Task 2.16)
	## Returns 2.0 for difficult terrain, 1.0 otherwise
	if _combat_grid:
		return float(_combat_grid.get_movement_cost(coords))
	return 1.0

func get_reachable_tiles(from: Vector2i, movement_range: float, exclude_unit: Unit = null) -> Array[Vector2i]:
	## Get all tiles reachable within movement range using BFS with movement costs
	## Task 2.16: Accounts for difficult terrain (double cost)
	var reachable: Array[Vector2i] = []
	var cost_to_reach: Dictionary = {}  # Vector2i -> float
	var queue: Array = [[from, 0.0]]  # [coords, cost_so_far]

	cost_to_reach[from] = 0.0

	while queue.size() > 0:
		var current = queue.pop_front()
		var coords: Vector2i = current[0]
		var cost: float = current[1]

		# Check neighbors
		for neighbor in _get_neighbor_coords(coords):
			if not _is_valid_coords(neighbor):
				continue
			if is_tile_blocked(neighbor, exclude_unit):
				continue

			var is_diagonal = (neighbor.x != coords.x and neighbor.y != coords.y)
			var base_cost = DIAGONAL_COST if is_diagonal else CARDINAL_COST

			# Task 2.16: Apply terrain movement cost multiplier
			var terrain_cost = _get_terrain_cost(neighbor)
			var move_cost = base_cost * terrain_cost
			var new_cost = cost + move_cost

			# Only process if within range and better than previous path
			if new_cost <= movement_range:
				var prev_cost = cost_to_reach.get(neighbor, INF)
				if new_cost < prev_cost:
					cost_to_reach[neighbor] = new_cost
					queue.append([neighbor, new_cost])
					if neighbor != from and not reachable.has(neighbor):
						reachable.append(neighbor)

	return reachable

# ===== INTERNAL HELPERS =====
func _coords_to_id(coords: Vector2i) -> int:
	## Convert 2D coords to unique ID
	return coords.y * _grid_width + coords.x

func _id_to_coords(id: int) -> Vector2i:
	## Convert ID back to 2D coords
	return Vector2i(id % _grid_width, id / _grid_width)

func _is_valid_coords(coords: Vector2i) -> bool:
	## Check if coords are within grid bounds
	return coords.x >= 0 and coords.x < _grid_width and coords.y >= 0 and coords.y < _grid_height
