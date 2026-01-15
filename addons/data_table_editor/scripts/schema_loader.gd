@tool
extends RefCounted
class_name SchemaLoader
## Schema Loader for the Data Table Editor.
## Loads, caches, and provides access to table schema definitions.
## Spec: docs/tools/data-table-editor-roadmap.md - Feature 1.3

# ===== CONSTANTS =====
const SCHEMA_PATH: String = "res://data/_schemas/"
const SCHEMA_EXTENSION: String = ".schema.json"

# Supported column types
const COLUMN_TYPES: Array[String] = [
	"string",
	"integer",
	"float",
	"boolean",
	"enum",
	"array",
	"json",
	"resource_path",  # For referencing .tres files
	"table_ref",      # For referencing other table rows
	"dice",           # For dice notation like "2d6+3"
]

# ===== SINGLETON =====
static var _instance: SchemaLoader = null
static var _schema_cache: Dictionary = {}  # schema_name -> Dictionary


## Get the singleton instance of SchemaLoader.
static func get_instance() -> SchemaLoader:
	if _instance == null:
		_instance = SchemaLoader.new()
	return _instance


# ===== PUBLIC API =====

## Load a schema by name. Returns cached version if available.
## @param schema_name: The name of the schema (without path or extension)
## @return: Schema dictionary or empty dictionary if not found
static func load_schema(schema_name: String) -> Dictionary:
	if schema_name.is_empty():
		return {}

	# Check cache first
	if _schema_cache.has(schema_name):
		return _schema_cache[schema_name]

	# Try to load from file
	var schema_path = SCHEMA_PATH + schema_name + SCHEMA_EXTENSION
	var schema = _load_schema_file(schema_path)

	if not schema.is_empty():
		_schema_cache[schema_name] = schema
		print("[SchemaLoader] Loaded schema: %s" % schema_name)
	else:
		print("[SchemaLoader] Schema not found: %s" % schema_name)

	return schema


## Infer a schema from table data when no schema file exists.
## @param data: Array of row dictionaries
## @param table_name: Name to use for the inferred schema
## @return: Inferred schema dictionary
static func infer_schema_from_data(data: Array, table_name: String = "inferred") -> Dictionary:
	var schema: Dictionary = {
		"name": table_name,
		"display_name": table_name.capitalize(),
		"columns": [],
		"inferred": true  # Mark as auto-generated
	}

	if data.is_empty():
		return schema

	# Infer columns from first row
	var first_row = data[0]
	if not first_row is Dictionary:
		return schema

	for key in first_row.keys():
		var value = first_row[key]
		var col_type = _infer_type(value)
		schema.columns.append({
			"name": key,
			"type": col_type,
			"inferred": true
		})

	return schema


## Get all available schemas from the schemas folder.
## @return: Array of schema names (without extension)
static func get_available_schemas() -> Array[String]:
	var schemas: Array[String] = []

	if not DirAccess.dir_exists_absolute(SCHEMA_PATH):
		return schemas

	var dir = DirAccess.open(SCHEMA_PATH)
	if not dir:
		return schemas

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(SCHEMA_EXTENSION):
			var schema_name = file_name.replace(SCHEMA_EXTENSION, "")
			schemas.append(schema_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	schemas.sort()

	return schemas


## Clear the schema cache. Call after modifying schema files.
static func clear_cache() -> void:
	_schema_cache.clear()
	print("[SchemaLoader] Cache cleared")


## Reload a specific schema from disk.
## @param schema_name: The schema to reload
## @return: The reloaded schema
static func reload_schema(schema_name: String) -> Dictionary:
	_schema_cache.erase(schema_name)
	return load_schema(schema_name)


## Check if a schema exists (either cached or on disk).
## @param schema_name: The schema name to check
## @return: True if schema exists
static func schema_exists(schema_name: String) -> bool:
	if _schema_cache.has(schema_name):
		return true

	var schema_path = SCHEMA_PATH + schema_name + SCHEMA_EXTENSION
	return FileAccess.file_exists(schema_path)


# ===== SCHEMA HELPERS =====

## Get column definition from a schema.
## @param schema: The schema dictionary
## @param column_name: Name of the column
## @return: Column definition dictionary or empty if not found
static func get_column(schema: Dictionary, column_name: String) -> Dictionary:
	var columns = schema.get("columns", [])
	for col in columns:
		if col.get("name", "") == column_name:
			return col
	return {}


## Get the display columns for a schema (subset shown in grid).
## @param schema: The schema dictionary
## @return: Array of column names to display
static func get_display_columns(schema: Dictionary) -> Array:
	var display = schema.get("display", {})
	var grid_columns = display.get("grid_columns", [])

	if not grid_columns.is_empty():
		return grid_columns

	# Fall back to all columns
	var columns = schema.get("columns", [])
	var names: Array = []
	for col in columns:
		names.append(col.get("name", ""))
	return names


## Get the default sort column for a schema.
## @param schema: The schema dictionary
## @return: Column name to sort by, or empty string
static func get_default_sort(schema: Dictionary) -> String:
	var display = schema.get("display", {})
	return display.get("sort_default", "")


## Get default value for a column based on its type.
## @param column: Column definition dictionary
## @return: Default value appropriate for the column type
static func get_column_default(column: Dictionary) -> Variant:
	# Check for explicit default in column definition
	if column.has("default"):
		return column.default

	# Fall back to type-based defaults
	var col_type = column.get("type", "string")
	return get_default_for_type(col_type)


## Get default value for a column type.
## @param col_type: The column type string
## @return: Default value for that type
static func get_default_for_type(col_type: String) -> Variant:
	match col_type:
		"boolean":
			return false
		"integer":
			return 0
		"float":
			return 0.0
		"array":
			return []
		"json":
			return {}
		"enum":
			return ""  # Will be set to first option if available
		_:
			return ""


## Validate a value against a column definition.
## @param value: The value to validate
## @param column: Column definition dictionary
## @return: Dictionary with "valid" bool and optional "error" message
static func validate_value(value: Variant, column: Dictionary) -> Dictionary:
	var col_name = column.get("name", "unknown")
	var col_type = column.get("type", "string")
	var required = column.get("required", false)

	# Check required
	if required and (value == null or (value is String and value.is_empty())):
		return {"valid": false, "error": "Field '%s' is required" % col_name}

	# Allow null/empty for non-required fields
	if value == null or (value is String and value.is_empty()):
		return {"valid": true}

	# Type-specific validation
	match col_type:
		"integer":
			if not (value is int or value is float):
				return {"valid": false, "error": "Field '%s' must be an integer" % col_name}
			var int_val = int(value)
			if column.has("min") and int_val < column.min:
				return {"valid": false, "error": "Field '%s' must be >= %d" % [col_name, column.min]}
			if column.has("max") and int_val > column.max:
				return {"valid": false, "error": "Field '%s' must be <= %d" % [col_name, column.max]}

		"float":
			if not (value is int or value is float):
				return {"valid": false, "error": "Field '%s' must be a number" % col_name}
			var float_val = float(value)
			if column.has("min") and float_val < column.min:
				return {"valid": false, "error": "Field '%s' must be >= %s" % [col_name, column.min]}
			if column.has("max") and float_val > column.max:
				return {"valid": false, "error": "Field '%s' must be <= %s" % [col_name, column.max]}

		"boolean":
			if not value is bool:
				return {"valid": false, "error": "Field '%s' must be true or false" % col_name}

		"enum":
			var options = column.get("options", [])
			if not options.is_empty() and not value in options:
				return {"valid": false, "error": "Field '%s' must be one of: %s" % [col_name, ", ".join(options)]}

		"dice":
			if value is String and not _is_valid_dice(value):
				return {"valid": false, "error": "Field '%s' must be valid dice notation (e.g., 2d6+3)" % col_name}

		"resource_path":
			if value is String and not value.is_empty():
				if not value.begins_with("res://"):
					return {"valid": false, "error": "Field '%s' must be a valid resource path" % col_name}

	return {"valid": true}


## Validate an entire row against a schema.
## @param row: Row data dictionary
## @param schema: Schema dictionary
## @return: Dictionary with "valid" bool and "errors" array
static func validate_row(row: Dictionary, schema: Dictionary) -> Dictionary:
	var errors: Array = []
	var columns = schema.get("columns", [])

	for col in columns:
		var col_name = col.get("name", "")
		var value = row.get(col_name)
		var result = validate_value(value, col)

		if not result.valid:
			errors.append(result.error)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}


# ===== INTERNAL METHODS =====

static func _load_schema_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_warning("[SchemaLoader] Failed to parse schema %s: %s" % [path, json.get_error_message()])
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		push_warning("[SchemaLoader] Schema %s is not a dictionary" % path)
		return {}

	return data


static func _infer_type(value: Variant) -> String:
	if value is bool:
		return "boolean"
	elif value is int:
		return "integer"
	elif value is float:
		return "float"
	elif value is Array:
		return "array"
	elif value is Dictionary:
		return "json"
	elif value is String:
		# Try to detect special string types
		if value.begins_with("res://"):
			return "resource_path"
		if _is_valid_dice(value):
			return "dice"
	return "string"


static func _is_valid_dice(text: String) -> bool:
	# Use DiceParser for validation
	return DiceParser.is_valid(text)
