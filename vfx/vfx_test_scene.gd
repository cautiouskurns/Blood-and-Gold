## VFX Test Scene
## Allows testing all VFX in the vfx/ folder
## Click to spawn effects, dropdown to select
extends Node2D

# ===== CONSTANTS =====
const VFX_ROOT_PATH: String = "res://vfx/"
const SPAWN_OFFSET: Vector2 = Vector2(400, 300)  # Center-ish spawn for impacts

# ===== NODE REFERENCES =====
@onready var vfx_dropdown: OptionButton = %VFXDropdown
@onready var camera: Camera2D = $Camera2D

# ===== STATE =====
var _vfx_scenes: Array[String] = []
var _selected_scene: String = ""

# ===== LIFECYCLE =====
func _ready() -> void:
	_scan_vfx_folder()
	_populate_dropdown()
	vfx_dropdown.item_selected.connect(_on_vfx_selected)

	# Select first item if available
	if _vfx_scenes.size() > 0:
		vfx_dropdown.select(0)
		_on_vfx_selected(0)

	print("[VFXTestScene] Ready - Found %d VFX scenes" % _vfx_scenes.size())

func _input(event: InputEvent) -> void:
	# Left click - spawn at mouse position
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_spawn_vfx_at(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_spawn_projectile_toward(get_global_mouse_position())

	# R key - refresh VFX list
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_refresh_list()

# ===== VFX SCANNING =====
func _scan_vfx_folder() -> void:
	_vfx_scenes.clear()
	_scan_directory(VFX_ROOT_PATH)
	_vfx_scenes.sort()

func _scan_directory(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		print("[VFXTestScene] Could not open directory: %s" % path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path + file_name

		if dir.current_is_dir() and not file_name.begins_with("."):
			# Recurse into subdirectory
			_scan_directory(full_path + "/")
		elif file_name.ends_with(".tscn"):
			# Skip this test scene itself
			if file_name != "vfx_test_scene.tscn":
				_vfx_scenes.append(full_path)

		file_name = dir.get_next()

	dir.list_dir_end()

func _populate_dropdown() -> void:
	vfx_dropdown.clear()

	for scene_path in _vfx_scenes:
		# Create readable name from path
		# res://vfx/projectiles/fireball.tscn -> projectiles/fireball
		var display_name = scene_path.replace(VFX_ROOT_PATH, "").replace(".tscn", "")
		vfx_dropdown.add_item(display_name)

func _refresh_list() -> void:
	_scan_vfx_folder()
	_populate_dropdown()

	if _vfx_scenes.size() > 0:
		vfx_dropdown.select(0)
		_on_vfx_selected(0)

	print("[VFXTestScene] Refreshed - Found %d VFX scenes" % _vfx_scenes.size())

# ===== CALLBACKS =====
func _on_vfx_selected(index: int) -> void:
	if index >= 0 and index < _vfx_scenes.size():
		_selected_scene = _vfx_scenes[index]
		print("[VFXTestScene] Selected: %s" % _selected_scene)

# ===== VFX SPAWNING =====
func _spawn_vfx_at(pos: Vector2) -> void:
	if _selected_scene.is_empty():
		print("[VFXTestScene] No VFX selected")
		return

	var scene = load(_selected_scene)
	if not scene:
		print("[VFXTestScene] Failed to load: %s" % _selected_scene)
		return

	var instance = scene.instantiate()
	add_child(instance)
	instance.global_position = pos

	print("[VFXTestScene] Spawned %s at %s" % [_selected_scene.get_file(), pos])

func _spawn_projectile_toward(target_pos: Vector2) -> void:
	if _selected_scene.is_empty():
		print("[VFXTestScene] No VFX selected")
		return

	var scene = load(_selected_scene)
	if not scene:
		print("[VFXTestScene] Failed to load: %s" % _selected_scene)
		return

	var instance = scene.instantiate()
	add_child(instance)

	# Spawn from center of screen
	var spawn_pos = camera.global_position
	instance.global_position = spawn_pos

	# If it's a projectile, set target
	if instance.has_method("set_target"):
		instance.set_target(target_pos)
		print("[VFXTestScene] Spawned projectile toward %s" % target_pos)
	else:
		print("[VFXTestScene] Spawned %s (no set_target method)" % _selected_scene.get_file())
