@tool
class_name DialogueTemplateManager
extends RefCounted
## Singleton manager for dialogue templates.
## Handles loading, saving, and organizing templates from both built-in and user directories.

signal templates_changed()
signal template_loaded(template: DialogueTemplateData)
signal template_saved(template: DialogueTemplateData, path: String)
signal template_deleted(template_name: String)

## Directories for template storage
const BUILT_IN_TEMPLATES_DIR := "res://addons/dialogue_editor/data/built_in_templates/"
const USER_TEMPLATES_DIR := "user://dialogue_templates/"

## Cached templates (keyed by template_name)
var _built_in_templates: Dictionary = {}  # {name: DialogueTemplateData}
var _user_templates: Dictionary = {}  # {name: DialogueTemplateData}

## Template file paths (keyed by template_name)
var _template_paths: Dictionary = {}  # {name: file_path}

## Singleton instance
static var _instance: DialogueTemplateManager = null


## Get the singleton instance.
static func get_instance() -> DialogueTemplateManager:
	if _instance == null:
		_instance = DialogueTemplateManager.new()
		_instance._initialize()
	return _instance


## Initialize the manager and load all templates.
func _initialize() -> void:
	_ensure_user_directory()
	refresh_templates()


## Ensure the user templates directory exists.
func _ensure_user_directory() -> void:
	if not DirAccess.dir_exists_absolute(USER_TEMPLATES_DIR):
		var err = DirAccess.make_dir_recursive_absolute(USER_TEMPLATES_DIR)
		if err == OK:
			print("DialogueTemplateManager: Created user templates directory: %s" % USER_TEMPLATES_DIR)
		else:
			push_warning("DialogueTemplateManager: Could not create user templates directory: %s (error: %d)" % [USER_TEMPLATES_DIR, err])


## Refresh all templates from disk.
func refresh_templates() -> void:
	_built_in_templates.clear()
	_user_templates.clear()
	_template_paths.clear()

	# Load built-in templates
	_load_templates_from_directory(BUILT_IN_TEMPLATES_DIR, true)

	# Load user templates
	_load_templates_from_directory(USER_TEMPLATES_DIR, false)

	templates_changed.emit()
	print("DialogueTemplateManager: Loaded %d built-in and %d user templates" % [_built_in_templates.size(), _user_templates.size()])


## Load templates from a directory.
func _load_templates_from_directory(directory: String, is_built_in: bool) -> void:
	if not DirAccess.dir_exists_absolute(directory):
		return

	var dir = DirAccess.open(directory)
	if dir == null:
		push_warning("DialogueTemplateManager: Could not open directory: %s" % directory)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".%s" % DialogueTemplateData.FILE_EXTENSION):
			var full_path = directory + file_name
			var template = DialogueTemplateData.load_from_file(full_path)

			if template != null:
				template.is_built_in = is_built_in
				var template_name = template.template_name

				if template_name.is_empty():
					template_name = file_name.get_basename()
					template.template_name = template_name

				_template_paths[template_name] = full_path

				if is_built_in:
					_built_in_templates[template_name] = template
				else:
					_user_templates[template_name] = template

				template_loaded.emit(template)

		file_name = dir.get_next()

	dir.list_dir_end()


## Get all templates (built-in + user).
func get_all_templates() -> Array[DialogueTemplateData]:
	var all_templates: Array[DialogueTemplateData] = []

	for template in _built_in_templates.values():
		all_templates.append(template)

	for template in _user_templates.values():
		all_templates.append(template)

	return all_templates


## Get all built-in templates.
func get_built_in_templates() -> Array[DialogueTemplateData]:
	var templates: Array[DialogueTemplateData] = []
	for template in _built_in_templates.values():
		templates.append(template)
	return templates


## Get all user templates.
func get_user_templates() -> Array[DialogueTemplateData]:
	var templates: Array[DialogueTemplateData] = []
	for template in _user_templates.values():
		templates.append(template)
	return templates


## Get templates by category.
func get_templates_by_category(category: String) -> Array[DialogueTemplateData]:
	var templates: Array[DialogueTemplateData] = []

	for template in get_all_templates():
		if template.category == category:
			templates.append(template)

	return templates


## Get all unique categories.
func get_categories() -> PackedStringArray:
	var categories := {}

	for template in get_all_templates():
		if not template.category.is_empty():
			categories[template.category] = true

	var result := PackedStringArray()
	for cat in categories:
		result.append(cat)
	result.sort()

	return result


## Get a template by name.
func get_template(template_name: String) -> DialogueTemplateData:
	if _user_templates.has(template_name):
		return _user_templates[template_name]
	if _built_in_templates.has(template_name):
		return _built_in_templates[template_name]
	return null


## Check if a template exists.
func has_template(template_name: String) -> bool:
	return _user_templates.has(template_name) or _built_in_templates.has(template_name)


## Check if a template name is available for a new template.
func is_name_available(template_name: String) -> bool:
	return not has_template(template_name)


## Save a template to the user templates directory.
func save_template(template: DialogueTemplateData) -> Error:
	if template.is_built_in:
		push_error("DialogueTemplateManager: Cannot save built-in template")
		return ERR_UNAUTHORIZED

	var validation = template.validate()
	if not validation.valid:
		push_error("DialogueTemplateManager: Template validation failed: %s" % str(validation.errors))
		return ERR_INVALID_DATA

	_ensure_user_directory()

	var file_name = template.get_template_id() + "." + DialogueTemplateData.FILE_EXTENSION
	var file_path = USER_TEMPLATES_DIR + file_name

	var err = template.save_to_file(file_path)
	if err == OK:
		_user_templates[template.template_name] = template
		_template_paths[template.template_name] = file_path
		template_saved.emit(template, file_path)
		templates_changed.emit()

	return err


## Delete a user template.
func delete_template(template_name: String) -> Error:
	if not _user_templates.has(template_name):
		if _built_in_templates.has(template_name):
			push_error("DialogueTemplateManager: Cannot delete built-in template: %s" % template_name)
			return ERR_UNAUTHORIZED
		push_error("DialogueTemplateManager: Template not found: %s" % template_name)
		return ERR_DOES_NOT_EXIST

	var file_path = _template_paths.get(template_name, "")
	if not file_path.is_empty() and FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		if err != OK:
			push_error("DialogueTemplateManager: Failed to delete template file: %s (error: %d)" % [file_path, err])
			return err

	_user_templates.erase(template_name)
	_template_paths.erase(template_name)
	template_deleted.emit(template_name)
	templates_changed.emit()

	print("DialogueTemplateManager: Deleted template: %s" % template_name)
	return OK


## Rename a user template.
func rename_template(old_name: String, new_name: String) -> Error:
	if not _user_templates.has(old_name):
		push_error("DialogueTemplateManager: Template not found: %s" % old_name)
		return ERR_DOES_NOT_EXIST

	if has_template(new_name):
		push_error("DialogueTemplateManager: Template name already exists: %s" % new_name)
		return ERR_ALREADY_EXISTS

	var template = _user_templates[old_name]
	var old_path = _template_paths.get(old_name, "")

	# Update template name
	template.template_name = new_name

	# Save with new name
	var err = save_template(template)
	if err != OK:
		# Revert on failure
		template.template_name = old_name
		return err

	# Delete old file
	if not old_path.is_empty() and FileAccess.file_exists(old_path):
		DirAccess.remove_absolute(old_path)

	# Update internal tracking
	_user_templates.erase(old_name)
	_template_paths.erase(old_name)

	print("DialogueTemplateManager: Renamed template '%s' to '%s'" % [old_name, new_name])
	return OK


## Duplicate a template (creates a user copy).
func duplicate_template(template_name: String, new_name: String) -> DialogueTemplateData:
	var source = get_template(template_name)
	if source == null:
		push_error("DialogueTemplateManager: Source template not found: %s" % template_name)
		return null

	if has_template(new_name):
		push_error("DialogueTemplateManager: Template name already exists: %s" % new_name)
		return null

	# Create a new template as a copy
	var copy = DialogueTemplateData.new()
	copy.template_name = new_name
	copy.description = source.description
	copy.author = source.author
	copy.tags = source.tags.duplicate()
	copy.category = source.category
	copy.created_date = Time.get_datetime_string_from_system()
	copy.modified_date = copy.created_date
	copy.is_built_in = false

	# Deep copy nodes and connections
	for node in source.nodes:
		copy.nodes.append(node.duplicate(true))
	for conn in source.connections:
		copy.connections.append(conn.duplicate())
	for placeholder in source.placeholders:
		copy.placeholders.append(placeholder.duplicate())

	copy.node_count = source.node_count
	copy.preview_description = source.preview_description

	# Save the copy
	var err = save_template(copy)
	if err != OK:
		push_error("DialogueTemplateManager: Failed to save duplicated template")
		return null

	return copy


## Import a template from an external file path.
func import_template(file_path: String) -> Error:
	var template = DialogueTemplateData.load_from_file(file_path)
	if template == null:
		return ERR_FILE_CANT_READ

	# Check for name collision
	var original_name = template.template_name
	var new_name = original_name
	var counter = 1

	while has_template(new_name):
		new_name = "%s_%d" % [original_name, counter]
		counter += 1

	if new_name != original_name:
		template.template_name = new_name
		push_warning("DialogueTemplateManager: Imported template renamed to '%s' (name collision)" % new_name)

	# Mark as user template
	template.is_built_in = false

	return save_template(template)


## Export a template to an external file path.
func export_template(template_name: String, output_path: String) -> Error:
	var template = get_template(template_name)
	if template == null:
		push_error("DialogueTemplateManager: Template not found: %s" % template_name)
		return ERR_DOES_NOT_EXIST

	# Create a copy to export (to avoid modifying the original)
	var export_template = DialogueTemplateData.new()
	export_template.template_name = template.template_name
	export_template.description = template.description
	export_template.author = template.author
	export_template.tags = template.tags.duplicate()
	export_template.category = template.category
	export_template.created_date = template.created_date
	export_template.modified_date = Time.get_datetime_string_from_system()
	export_template.is_built_in = false  # Exported templates are never built-in

	for node in template.nodes:
		export_template.nodes.append(node.duplicate(true))
	for conn in template.connections:
		export_template.connections.append(conn.duplicate())
	for placeholder in template.placeholders:
		export_template.placeholders.append(placeholder.duplicate())

	export_template.node_count = template.node_count
	export_template.preview_description = template.preview_description

	return export_template.save_to_file(output_path)


## Search templates by name or description.
func search_templates(query: String) -> Array[DialogueTemplateData]:
	if query.is_empty():
		return get_all_templates()

	var results: Array[DialogueTemplateData] = []
	var query_lower = query.to_lower()

	for template in get_all_templates():
		if template.template_name.to_lower().contains(query_lower):
			results.append(template)
		elif template.description.to_lower().contains(query_lower):
			results.append(template)
		elif template.category.to_lower().contains(query_lower):
			results.append(template)
		else:
			# Check tags
			for tag in template.tags:
				if tag.to_lower().contains(query_lower):
					results.append(template)
					break

	return results


## Get templates sorted by name.
func get_templates_sorted_by_name() -> Array[DialogueTemplateData]:
	var templates = get_all_templates()
	templates.sort_custom(func(a, b): return a.template_name.naturalcasecmp_to(b.template_name) < 0)
	return templates


## Get templates sorted by category then name.
func get_templates_sorted_by_category() -> Array[DialogueTemplateData]:
	var templates = get_all_templates()
	templates.sort_custom(func(a, b):
		if a.category != b.category:
			return a.category.naturalcasecmp_to(b.category) < 0
		return a.template_name.naturalcasecmp_to(b.template_name) < 0
	)
	return templates


## Get the file path for a template.
func get_template_path(template_name: String) -> String:
	return _template_paths.get(template_name, "")


## Generate a unique template name based on a base name.
func generate_unique_name(base_name: String) -> String:
	if is_name_available(base_name):
		return base_name

	var counter = 1
	var new_name = "%s_%d" % [base_name, counter]

	while not is_name_available(new_name):
		counter += 1
		new_name = "%s_%d" % [base_name, counter]

	return new_name
