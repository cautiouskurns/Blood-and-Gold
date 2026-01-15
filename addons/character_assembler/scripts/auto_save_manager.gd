@tool
extends RefCounted
class_name AutoSaveManager
## Manages automatic saving and crash recovery for the Character Assembler.
## Saves projects periodically and detects unsaved work from previous sessions.

signal auto_save_triggered(path: String)
signal recovery_file_found(path: String)

## Auto-save interval in seconds (default: 5 minutes).
const AUTO_SAVE_INTERVAL_SECONDS: float = 300.0

## Directory for auto-save files.
const AUTO_SAVE_DIR := "user://character_assembler/autosave/"

## Maximum number of auto-save files to keep.
const MAX_AUTO_SAVE_FILES := 5

## Prefix for auto-save files.
const AUTO_SAVE_PREFIX := "autosave_"

## Timer for auto-save.
var _timer: Timer
var _current_project_path: String = ""
var _parent_node: Node


func _init() -> void:
	_ensure_auto_save_directory()


## Initialize with a parent node for the timer.
func initialize(parent: Node) -> void:
	_parent_node = parent
	_setup_timer()


## Start auto-saving for a project.
func start(project_path: String = "") -> void:
	_current_project_path = project_path
	if _timer:
		_timer.start()
	print("CharacterAssembler: Auto-save started (interval: %.0f seconds)" % AUTO_SAVE_INTERVAL_SECONDS)


## Stop auto-saving.
func stop() -> void:
	if _timer:
		_timer.stop()


## Pause auto-saving temporarily.
func pause() -> void:
	if _timer:
		_timer.paused = true


## Resume auto-saving.
func resume() -> void:
	if _timer:
		_timer.paused = false


## Set the current project path for auto-save naming.
func set_project_path(path: String) -> void:
	_current_project_path = path


## Check for recovery files from a previous session.
func check_for_recovery_files() -> Array[Dictionary]:
	var recovery_files: Array[Dictionary] = []

	var dir := DirAccess.open(AUTO_SAVE_DIR)
	if not dir:
		return recovery_files

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.begins_with(AUTO_SAVE_PREFIX) and file_name.ends_with(".charproj"):
			var full_path := AUTO_SAVE_DIR + file_name
			var modified_time := FileAccess.get_modified_time(full_path)

			recovery_files.append({
				"path": full_path,
				"file_name": file_name,
				"modified_time": modified_time,
				"modified_date": Time.get_datetime_string_from_unix_time(modified_time)
			})

		file_name = dir.get_next()

	dir.list_dir_end()

	# Sort by modified time, newest first
	recovery_files.sort_custom(func(a, b): return a.modified_time > b.modified_time)

	return recovery_files


## Get the most recent recovery file.
func get_latest_recovery_file() -> String:
	var recovery_files := check_for_recovery_files()
	if recovery_files.is_empty():
		return ""
	return recovery_files[0].path


## Perform an auto-save of the current project data.
func perform_auto_save(project_data: Dictionary) -> Error:
	if project_data.is_empty():
		return ERR_INVALID_DATA

	var auto_save_path := _get_auto_save_path()
	var json_string := JSON.stringify(project_data, "\t")

	var file := FileAccess.open(auto_save_path, FileAccess.WRITE)
	if file == null:
		var err := FileAccess.get_open_error()
		push_error("AutoSaveManager: Failed to open file for auto-save: %s (error: %d)" % [auto_save_path, err])
		return err

	file.store_string(json_string)
	file.close()

	auto_save_triggered.emit(auto_save_path)
	print("CharacterAssembler: Auto-saved to %s" % auto_save_path)

	# Clean up old auto-save files
	_cleanup_old_auto_saves()

	return OK


## Delete a recovery file after successful recovery or dismissal.
func delete_recovery_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("CharacterAssembler: Deleted recovery file: %s" % path)


## Clear all auto-save files (e.g., after successful save).
func clear_auto_saves() -> void:
	var dir := DirAccess.open(AUTO_SAVE_DIR)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name.begins_with(AUTO_SAVE_PREFIX):
			dir.remove(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	print("CharacterAssembler: Cleared all auto-save files")


## Load project data from a recovery file.
func load_recovery_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("AutoSaveManager: Recovery file not found: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("AutoSaveManager: Could not open recovery file: %s" % path)
		return {}

	var json_string := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_string)
	if data == null:
		push_error("AutoSaveManager: Invalid JSON in recovery file: %s" % path)
		return {}

	return data


func _setup_timer() -> void:
	if not _parent_node:
		return

	_timer = Timer.new()
	_timer.name = "AutoSaveTimer"
	_timer.wait_time = AUTO_SAVE_INTERVAL_SECONDS
	_timer.one_shot = false
	_timer.timeout.connect(_on_timer_timeout)
	_parent_node.add_child(_timer)


func _on_timer_timeout() -> void:
	# This will be connected by main_panel to trigger the actual save
	# The signal is emitted with an empty path to indicate the timer triggered
	auto_save_triggered.emit("")


func _ensure_auto_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(AUTO_SAVE_DIR):
		var err := DirAccess.make_dir_recursive_absolute(AUTO_SAVE_DIR)
		if err == OK:
			print("AutoSaveManager: Created auto-save directory: %s" % AUTO_SAVE_DIR)
		else:
			push_error("AutoSaveManager: Failed to create auto-save directory: %s (error: %d)" % [AUTO_SAVE_DIR, err])


func _get_auto_save_path() -> String:
	var timestamp := Time.get_unix_time_from_system()
	var project_name := "untitled"

	if not _current_project_path.is_empty():
		project_name = _current_project_path.get_file().get_basename()

	return AUTO_SAVE_DIR + AUTO_SAVE_PREFIX + project_name + "_" + str(int(timestamp)) + ".charproj"


func _cleanup_old_auto_saves() -> void:
	var auto_saves := check_for_recovery_files()

	# Remove files beyond the maximum limit
	if auto_saves.size() > MAX_AUTO_SAVE_FILES:
		for i in range(MAX_AUTO_SAVE_FILES, auto_saves.size()):
			var path: String = auto_saves[i].path
			DirAccess.remove_absolute(path)
			print("CharacterAssembler: Removed old auto-save: %s" % path)
