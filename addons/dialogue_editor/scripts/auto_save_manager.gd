@tool
class_name DialogueAutoSaveManager
extends RefCounted
## Manages auto-saving of dialogue trees to prevent data loss.
## Saves to temporary files and supports crash recovery.

signal auto_saved(temp_path: String)
signal auto_save_failed(error: String)
signal recovery_available(temp_path: String, original_path: String)

const DialogueTreeDataScript = preload("res://addons/dialogue_editor/scripts/dialogue_tree_data.gd")

# Auto-save directory within user data
const AUTO_SAVE_DIR := "user://dialogue_editor_autosave/"
const AUTO_SAVE_EXTENSION := ".autosave.dtree"
const RECOVERY_MANIFEST := "user://dialogue_editor_autosave/recovery_manifest.json"

# Configuration
var auto_save_enabled: bool = true
var auto_save_interval: float = 60.0  # seconds
var max_auto_saves: int = 5  # Keep last N auto-saves per file

# State
var _timer: Timer = null
var _canvas: GraphEdit = null
var _current_file_path: String = ""
var _dialogue_id: String = ""
var _is_dirty: bool = false
var _last_auto_save_time: float = 0.0
var _last_auto_save_path: String = ""

# For tracking in editor
var _parent_node: Node = null


## Initialize the auto-save manager.
func setup(parent: Node, canvas: GraphEdit) -> void:
	_parent_node = parent
	_canvas = canvas

	# Create auto-save directory if needed
	_ensure_auto_save_directory()

	# Create and configure timer
	_timer = Timer.new()
	_timer.name = "AutoSaveTimer"
	_timer.wait_time = auto_save_interval
	_timer.one_shot = false
	_timer.timeout.connect(_on_auto_save_timer)
	parent.add_child(_timer)

	if auto_save_enabled:
		_timer.start()

	print("DialogueAutoSave: Initialized (interval: %ds, enabled: %s)" % [int(auto_save_interval), auto_save_enabled])


## Clean up resources.
func cleanup() -> void:
	if _timer:
		_timer.stop()
		_timer.queue_free()
		_timer = null


## Set the current file being edited.
func set_current_file(file_path: String, dialogue_id: String) -> void:
	_current_file_path = file_path
	_dialogue_id = dialogue_id
	_is_dirty = false
	_last_auto_save_path = ""


## Mark the document as dirty (has unsaved changes).
func mark_dirty() -> void:
	_is_dirty = true


## Mark the document as clean (saved).
func mark_clean() -> void:
	_is_dirty = false


## Enable or disable auto-save.
func set_enabled(enabled: bool) -> void:
	auto_save_enabled = enabled
	if _timer:
		if enabled:
			_timer.start()
		else:
			_timer.stop()
	print("DialogueAutoSave: %s" % ("Enabled" if enabled else "Disabled"))


## Set the auto-save interval in seconds.
func set_interval(seconds: float) -> void:
	auto_save_interval = max(10.0, seconds)  # Minimum 10 seconds
	if _timer:
		_timer.wait_time = auto_save_interval
	print("DialogueAutoSave: Interval set to %ds" % int(auto_save_interval))


## Get the time since last auto-save in seconds.
func get_time_since_last_save() -> float:
	if _last_auto_save_time <= 0:
		return -1.0
	return Time.get_unix_time_from_system() - _last_auto_save_time


## Get formatted string of last auto-save time.
func get_last_save_time_string() -> String:
	if _last_auto_save_time <= 0:
		return "Never"

	var elapsed = get_time_since_last_save()
	if elapsed < 60:
		return "%ds ago" % int(elapsed)
	elif elapsed < 3600:
		return "%dm ago" % int(elapsed / 60)
	else:
		return "%dh ago" % int(elapsed / 3600)


## Get the path to the last auto-save file.
func get_last_auto_save_path() -> String:
	return _last_auto_save_path


## Check if auto-save is enabled.
func is_enabled() -> bool:
	return auto_save_enabled


## Force an immediate auto-save.
func force_auto_save() -> bool:
	return _perform_auto_save()


## Check for recoverable auto-saves on startup.
func check_for_recovery() -> Dictionary:
	var recovery_data := {
		"has_recovery": false,
		"recoveries": []  # Array of {temp_path, original_path, dialogue_id, timestamp}
	}

	if not FileAccess.file_exists(RECOVERY_MANIFEST):
		return recovery_data

	var file = FileAccess.open(RECOVERY_MANIFEST, FileAccess.READ)
	if not file:
		return recovery_data

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		return recovery_data

	var manifest = json.data
	if not manifest is Dictionary or not manifest.has("pending_recoveries"):
		return recovery_data

	# Check which recoveries are still valid (temp file exists)
	for recovery in manifest.pending_recoveries:
		if recovery is Dictionary and recovery.has("temp_path"):
			if FileAccess.file_exists(recovery.temp_path):
				recovery_data.recoveries.append(recovery)

	recovery_data.has_recovery = not recovery_data.recoveries.is_empty()
	return recovery_data


## Load from an auto-save file for recovery.
func load_recovery(temp_path: String) -> Dictionary:
	if not FileAccess.file_exists(temp_path):
		return {}

	var result = DialogueTreeDataScript.load_from_file(temp_path)
	if result.success:
		# Clear this recovery from manifest
		_remove_from_recovery_manifest(temp_path)

	return result


## Clear a recovery entry (user chose to discard).
func discard_recovery(temp_path: String) -> void:
	_remove_from_recovery_manifest(temp_path)

	# Delete the temp file
	if FileAccess.file_exists(temp_path):
		DirAccess.remove_absolute(temp_path)


## Clear all recovery entries.
func clear_all_recoveries() -> void:
	if FileAccess.file_exists(RECOVERY_MANIFEST):
		DirAccess.remove_absolute(RECOVERY_MANIFEST)

	# Clean up old auto-save files
	_cleanup_old_auto_saves()


# =============================================================================
# PRIVATE METHODS
# =============================================================================

func _ensure_auto_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(AUTO_SAVE_DIR):
		var err = DirAccess.make_dir_recursive_absolute(AUTO_SAVE_DIR)
		if err != OK:
			push_error("DialogueAutoSave: Could not create auto-save directory")


func _on_auto_save_timer() -> void:
	if not auto_save_enabled:
		return

	if not _is_dirty:
		return  # No changes to save

	if not _canvas:
		return

	_perform_auto_save()


func _perform_auto_save() -> bool:
	if not _canvas or not _canvas.has_method("serialize"):
		auto_save_failed.emit("Canvas not available")
		return false

	# Generate auto-save filename
	var temp_path = _generate_auto_save_path()

	# Get canvas data
	var canvas_data = _canvas.serialize()

	# Build full dialogue tree data
	var data := {
		"version": 1,
		"metadata": {
			"dialogue_id": _dialogue_id if not _dialogue_id.is_empty() else "autosave",
			"display_name": "Auto-save",
			"description": "Auto-saved dialogue tree",
			"author": "",
			"created_date": Time.get_datetime_string_from_system(),
			"modified_date": Time.get_datetime_string_from_system(),
			"is_auto_save": true,
			"original_path": _current_file_path
		},
		"canvas": {
			"scroll_offset_x": canvas_data.get("scroll_offset", {}).get("x", 0),
			"scroll_offset_y": canvas_data.get("scroll_offset", {}).get("y", 0),
			"zoom": canvas_data.get("zoom", 1.0)
		},
		"nodes": canvas_data.get("nodes", []),
		"connections": canvas_data.get("connections", [])
	}

	# Save to temp file - create a DialogueTreeData instance and populate it
	var tree_data = DialogueTreeData.new()
	tree_data.dialogue_id = data.metadata.dialogue_id
	tree_data.display_name = data.metadata.display_name
	tree_data.description = data.metadata.description
	tree_data.author = data.metadata.author
	tree_data.created_date = data.metadata.created_date
	tree_data.modified_date = data.metadata.modified_date
	tree_data.scroll_offset_x = data.canvas.scroll_offset_x
	tree_data.scroll_offset_y = data.canvas.scroll_offset_y
	tree_data.zoom = data.canvas.zoom
	tree_data.nodes = data.nodes
	tree_data.connections = data.connections

	var result = tree_data.save_to_file(temp_path)

	if result == OK:
		_last_auto_save_time = Time.get_unix_time_from_system()
		_last_auto_save_path = temp_path

		# Update recovery manifest
		_update_recovery_manifest(temp_path)

		# Cleanup old auto-saves
		_cleanup_old_auto_saves()

		auto_saved.emit(temp_path)
		print("DialogueAutoSave: Saved to %s" % temp_path)
		return true
	else:
		auto_save_failed.emit("Error code: %d" % result)
		push_error("DialogueAutoSave: Failed to save - Error code: %d" % result)
		return false


func _generate_auto_save_path() -> String:
	var timestamp = Time.get_unix_time_from_system()
	var id = _dialogue_id if not _dialogue_id.is_empty() else "untitled"
	# Sanitize id for filename
	id = id.replace("/", "_").replace("\\", "_").replace(":", "_")
	return AUTO_SAVE_DIR + "%s_%d%s" % [id, int(timestamp), AUTO_SAVE_EXTENSION]


func _update_recovery_manifest(temp_path: String) -> void:
	var manifest := {
		"pending_recoveries": []
	}

	# Load existing manifest
	if FileAccess.file_exists(RECOVERY_MANIFEST):
		var file = FileAccess.open(RECOVERY_MANIFEST, FileAccess.READ)
		if file:
			var json = JSON.new()
			if json.parse(file.get_as_text()) == OK and json.data is Dictionary:
				manifest = json.data
			file.close()

	if not manifest.has("pending_recoveries"):
		manifest.pending_recoveries = []

	# Add or update this recovery entry
	var found = false
	for i in manifest.pending_recoveries.size():
		var entry = manifest.pending_recoveries[i]
		if entry.get("dialogue_id") == _dialogue_id:
			manifest.pending_recoveries[i] = {
				"temp_path": temp_path,
				"original_path": _current_file_path,
				"dialogue_id": _dialogue_id,
				"timestamp": Time.get_unix_time_from_system()
			}
			found = true
			break

	if not found:
		manifest.pending_recoveries.append({
			"temp_path": temp_path,
			"original_path": _current_file_path,
			"dialogue_id": _dialogue_id,
			"timestamp": Time.get_unix_time_from_system()
		})

	# Save manifest
	var file = FileAccess.open(RECOVERY_MANIFEST, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "\t"))
		file.close()


func _remove_from_recovery_manifest(temp_path: String) -> void:
	if not FileAccess.file_exists(RECOVERY_MANIFEST):
		return

	var file = FileAccess.open(RECOVERY_MANIFEST, FileAccess.READ)
	if not file:
		return

	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return

	file.close()

	var manifest = json.data
	if not manifest is Dictionary or not manifest.has("pending_recoveries"):
		return

	# Remove entry with matching temp_path
	var new_recoveries = []
	for entry in manifest.pending_recoveries:
		if entry.get("temp_path") != temp_path:
			new_recoveries.append(entry)

	manifest.pending_recoveries = new_recoveries

	# Save updated manifest
	file = FileAccess.open(RECOVERY_MANIFEST, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "\t"))
		file.close()


func _cleanup_old_auto_saves() -> void:
	# Group auto-saves by dialogue_id
	var auto_saves_by_id: Dictionary = {}

	var dir = DirAccess.open(AUTO_SAVE_DIR)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(AUTO_SAVE_EXTENSION):
			# Extract dialogue_id from filename (format: id_timestamp.autosave.dtree)
			var parts = file_name.replace(AUTO_SAVE_EXTENSION, "").rsplit("_", true, 1)
			if parts.size() >= 2:
				var id = parts[0]
				var timestamp = int(parts[1]) if parts[1].is_valid_int() else 0

				if not auto_saves_by_id.has(id):
					auto_saves_by_id[id] = []
				auto_saves_by_id[id].append({
					"path": AUTO_SAVE_DIR + file_name,
					"timestamp": timestamp
				})
		file_name = dir.get_next()
	dir.list_dir_end()

	# For each dialogue_id, keep only the newest max_auto_saves files
	for id in auto_saves_by_id:
		var saves = auto_saves_by_id[id]
		if saves.size() <= max_auto_saves:
			continue

		# Sort by timestamp descending
		saves.sort_custom(func(a, b): return a.timestamp > b.timestamp)

		# Delete old saves (keep first max_auto_saves)
		for i in range(max_auto_saves, saves.size()):
			var old_path = saves[i].path
			if old_path != _last_auto_save_path:  # Don't delete current auto-save
				DirAccess.remove_absolute(old_path)
				print("DialogueAutoSave: Cleaned up old auto-save: %s" % old_path)


## Called when the editor is about to close - mark recovery as complete if saved.
func on_clean_exit() -> void:
	# If the document was saved (not dirty), remove from recovery manifest
	if not _is_dirty and not _last_auto_save_path.is_empty():
		_remove_from_recovery_manifest(_last_auto_save_path)

		# Delete the auto-save file since we have a proper save
		if FileAccess.file_exists(_last_auto_save_path):
			DirAccess.remove_absolute(_last_auto_save_path)
