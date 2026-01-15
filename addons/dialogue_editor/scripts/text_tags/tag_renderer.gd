@tool
class_name DialogueTagRenderer
extends RefCounted
## Renders tagged dialogue text with variable values and evaluated conditionals.
## Supports variable substitution, conditional branches, and BBCode passthrough.
## Used by DialogueRunner to produce final display text.

const TagParserScript = preload("res://addons/dialogue_editor/scripts/text_tags/tag_parser.gd")
const ExpressionEvaluatorScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_evaluator.gd")

# =============================================================================
# RENDER OPTIONS
# =============================================================================

## Configuration for rendering behavior.
class RenderOptions:
	## How to handle missing variables.
	enum MissingVariableMode {
		SHOW_PLACEHOLDER,    # Show {variable_name} as-is
		SHOW_CUSTOM,         # Show custom placeholder text
		SHOW_EMPTY,          # Show empty string
		SHOW_ERROR,          # Show [ERROR: variable_name]
		THROW_ERROR          # Add to errors array
	}

	var missing_variable_mode: MissingVariableMode = MissingVariableMode.SHOW_PLACEHOLDER
	var custom_placeholder: String = "[???]"  # Used when mode is SHOW_CUSTOM
	var preserve_bbcode: bool = true          # Pass through BBCode tags unchanged
	var strip_whitespace: bool = false        # Strip leading/trailing whitespace from conditionals
	var debug_mode: bool = false              # Include debug info in output

	func _init() -> void:
		pass

	func duplicate() -> RenderOptions:
		var opts = RenderOptions.new()
		opts.missing_variable_mode = missing_variable_mode
		opts.custom_placeholder = custom_placeholder
		opts.preserve_bbcode = preserve_bbcode
		opts.strip_whitespace = strip_whitespace
		opts.debug_mode = debug_mode
		return opts


# =============================================================================
# RENDER RESULT
# =============================================================================

## Result of rendering tagged text.
class RenderResult:
	var success: bool = true
	var text: String = ""
	var errors: Array = []           # Array of error messages
	var variables_used: Array = []   # Variables that were substituted
	var conditions_evaluated: Array = []  # Conditions that were evaluated
	var missing_variables: Array = []     # Variables not found in context

	func _init() -> void:
		pass

	func add_error(message: String) -> void:
		errors.append(message)
		success = false

	func _to_string() -> String:
		if success:
			return "RenderResult(ok, %d chars)" % text.length()
		return "RenderResult(errors: %s)" % str(errors)


# =============================================================================
# CACHE
# =============================================================================

## Cache entry for repeated renders.
class CacheEntry:
	var source_text: String
	var context_hash: int
	var rendered_text: String
	var timestamp: int

	func _init(p_source: String, p_hash: int, p_rendered: String) -> void:
		source_text = p_source
		context_hash = p_hash
		rendered_text = p_rendered
		timestamp = Time.get_ticks_msec()


# =============================================================================
# STATE
# =============================================================================

var _parser: TagParserScript
var _evaluator: ExpressionEvaluatorScript
var _options: RenderOptions
var _cache: Dictionary = {}  # source_text -> CacheEntry
var _cache_enabled: bool = true
var _cache_max_size: int = 100
var _cache_ttl_ms: int = 60000  # 1 minute


# =============================================================================
# INITIALIZATION
# =============================================================================

func _init() -> void:
	_parser = TagParserScript.new()
	_evaluator = ExpressionEvaluatorScript.new()
	_options = RenderOptions.new()


## Set render options.
func set_options(options: RenderOptions) -> void:
	_options = options


## Get current render options.
func get_options() -> RenderOptions:
	return _options


## Enable or disable caching.
func set_cache_enabled(enabled: bool) -> void:
	_cache_enabled = enabled


## Clear the render cache.
func clear_cache() -> void:
	_cache.clear()


## Set maximum cache size.
func set_cache_max_size(size: int) -> void:
	_cache_max_size = size


# =============================================================================
# PUBLIC API
# =============================================================================

## Render tagged text with the given context.
## Context is a dictionary of variable names to values.
func render(text: String, context: Dictionary = {}) -> RenderResult:
	var result = RenderResult.new()

	# Check cache first
	if _cache_enabled:
		var cached = _get_cached(text, context)
		if cached != null:
			result.text = cached
			return result

	# Parse the text
	var parse_result = _parser.parse(text)
	if not parse_result.success:
		for error in parse_result.errors:
			result.add_error("Parse error: %s" % str(error))
		# Still try to render what we can
		result.text = text
		return result

	# Set up evaluator context
	_evaluator.set_context(context)

	# Render based on AST if we have conditionals, otherwise use flat tags
	if parse_result.has_conditionals and not parse_result.ast.is_empty():
		result.text = _render_ast(parse_result.ast, context, result)
	else:
		result.text = _render_tags(parse_result.tags, context, result)

	# Apply whitespace stripping if enabled
	if _options.strip_whitespace:
		result.text = result.text.strip_edges()

	# Store in cache
	if _cache_enabled:
		_store_cached(text, context, result.text)

	return result


## Render a single variable value.
func render_variable(name: String, context: Dictionary) -> String:
	return _resolve_variable(name, context, null)


## Quick render without full result object.
func render_text(text: String, context: Dictionary = {}) -> String:
	return render(text, context).text


## Check if text has any tags that need rendering.
func needs_rendering(text: String) -> bool:
	return _parser.has_tags(text)


# =============================================================================
# RENDERING - FLAT TAGS
# =============================================================================

func _render_tags(tags: Array, context: Dictionary, result: RenderResult) -> String:
	var output := ""

	for tag in tags:
		match tag.type:
			TagParserScript.TagType.TEXT:
				output += tag.content

			TagParserScript.TagType.VARIABLE:
				var value = _resolve_variable(tag.get_variable_path(), context, result)
				output += value
				if not tag.get_variable_path() in result.variables_used:
					result.variables_used.append(tag.get_variable_path())

			TagParserScript.TagType.CONDITIONAL_START, \
			TagParserScript.TagType.CONDITIONAL_ELIF, \
			TagParserScript.TagType.CONDITIONAL_ELSE, \
			TagParserScript.TagType.CONDITIONAL_END:
				# These should be handled by AST rendering
				# If we're here, something went wrong - skip them
				if _options.debug_mode:
					output += "[COND:%s]" % tag.content

			TagParserScript.TagType.ERROR:
				result.add_error("Tag error: %s" % tag.error_message)

	return output


# =============================================================================
# RENDERING - AST (Conditionals)
# =============================================================================

func _render_ast(ast: Array, context: Dictionary, result: RenderResult) -> String:
	var output := ""

	for item in ast:
		if item is TagParserScript.ConditionalBlock:
			output += _render_conditional_block(item, context, result)
		elif item is TagParserScript.Tag:
			output += _render_single_tag(item, context, result)
		else:
			# Shouldn't happen, but handle gracefully
			output += str(item)

	return output


func _render_conditional_block(block: TagParserScript.ConditionalBlock, context: Dictionary, result: RenderResult) -> String:
	# Track that we evaluated this condition
	if not block.condition.is_empty():
		result.conditions_evaluated.append(block.condition)

	# Evaluate the if condition
	if _evaluate_condition(block.condition, context, result):
		return _render_branch_content(block.if_content, context, result)

	# Try elif branches
	for elif_branch in block.elif_branches:
		var elif_condition = elif_branch.get("condition", "")
		result.conditions_evaluated.append(elif_condition)

		if _evaluate_condition(elif_condition, context, result):
			return _render_branch_content(elif_branch.get("content", []), context, result)

	# Fall back to else branch if exists
	if not block.else_content.is_empty():
		return _render_branch_content(block.else_content, context, result)

	# No branch matched, return empty
	return ""


func _render_branch_content(content: Array, context: Dictionary, result: RenderResult) -> String:
	var output := ""

	for item in content:
		if item is TagParserScript.ConditionalBlock:
			# Nested conditional
			output += _render_conditional_block(item, context, result)
		elif item is TagParserScript.Tag:
			output += _render_single_tag(item, context, result)
		else:
			output += str(item)

	return output


func _render_single_tag(tag: TagParserScript.Tag, context: Dictionary, result: RenderResult) -> String:
	match tag.type:
		TagParserScript.TagType.TEXT:
			return tag.content

		TagParserScript.TagType.VARIABLE:
			var value = _resolve_variable(tag.get_variable_path(), context, result)
			if not tag.get_variable_path() in result.variables_used:
				result.variables_used.append(tag.get_variable_path())
			return value

		TagParserScript.TagType.ERROR:
			result.add_error("Tag error: %s" % tag.error_message)
			return ""

		_:
			# Conditional tags shouldn't appear here in AST rendering
			return ""


# =============================================================================
# VARIABLE RESOLUTION
# =============================================================================

func _resolve_variable(var_path: String, context: Dictionary, result: RenderResult) -> String:
	# Split path into segments
	var segments = var_path.split(".")
	var value = _resolve_path(segments, context)

	if value == null:
		# Variable not found
		if result:
			result.missing_variables.append(var_path)

		# Handle missing variable based on options
		match _options.missing_variable_mode:
			RenderOptions.MissingVariableMode.SHOW_PLACEHOLDER:
				return "{%s}" % var_path
			RenderOptions.MissingVariableMode.SHOW_CUSTOM:
				return _options.custom_placeholder
			RenderOptions.MissingVariableMode.SHOW_EMPTY:
				return ""
			RenderOptions.MissingVariableMode.SHOW_ERROR:
				return "[ERROR: %s]" % var_path
			RenderOptions.MissingVariableMode.THROW_ERROR:
				if result:
					result.add_error("Missing variable: %s" % var_path)
				return "{%s}" % var_path

	# Convert value to string
	return _value_to_string(value)


func _resolve_path(segments: Array, context: Dictionary) -> Variant:
	if segments.is_empty():
		return null

	# Get first segment
	var first = str(segments[0])
	if not context.has(first):
		return null

	var current = context[first]

	# Navigate through remaining segments
	for i in range(1, segments.size()):
		if current == null:
			return null

		var key = str(segments[i])

		if current is Dictionary:
			if current.has(key):
				current = current[key]
			else:
				return null
		elif current is Object:
			if key in current:
				current = current.get(key)
			else:
				return null
		else:
			return null

	return current


func _value_to_string(value: Variant) -> String:
	if value == null:
		return ""
	if value is String:
		return value
	if value is bool:
		return "true" if value else "false"
	if value is float:
		# Format floats nicely (no trailing zeros)
		var s = str(value)
		if "." in s:
			s = s.rstrip("0").rstrip(".")
		return s
	return str(value)


# =============================================================================
# CONDITION EVALUATION
# =============================================================================

func _evaluate_condition(condition: String, context: Dictionary, result: RenderResult) -> bool:
	if condition.is_empty():
		return false

	# Use the expression evaluator
	_evaluator.set_context(context)
	var eval_result = _evaluator.evaluate_string(condition)

	if not eval_result.success:
		if result:
			result.add_error("Condition evaluation failed: %s - %s" % [condition, eval_result.error])
		return false

	# Convert result to boolean
	return _to_bool(eval_result.value)


func _to_bool(value: Variant) -> bool:
	if value is bool:
		return value
	if value is int or value is float:
		return value != 0
	if value is String:
		return not value.is_empty() and value.to_lower() != "false"
	if value is Array or value is Dictionary:
		return not value.is_empty()
	if value == null:
		return false
	return true


# =============================================================================
# CACHING
# =============================================================================

func _get_cached(text: String, context: Dictionary) -> Variant:
	if not _cache.has(text):
		return null

	var entry = _cache[text] as CacheEntry
	if entry == null:
		return null

	# Check TTL
	var now = Time.get_ticks_msec()
	if now - entry.timestamp > _cache_ttl_ms:
		_cache.erase(text)
		return null

	# Check context hash matches
	var context_hash = _hash_context(context)
	if entry.context_hash != context_hash:
		return null

	return entry.rendered_text


func _store_cached(text: String, context: Dictionary, rendered: String) -> void:
	# Enforce max cache size
	if _cache.size() >= _cache_max_size:
		_evict_oldest_cache_entry()

	var context_hash = _hash_context(context)
	_cache[text] = CacheEntry.new(text, context_hash, rendered)


func _evict_oldest_cache_entry() -> void:
	var oldest_key = ""
	var oldest_time = Time.get_ticks_msec()

	for key in _cache:
		var entry = _cache[key] as CacheEntry
		if entry and entry.timestamp < oldest_time:
			oldest_time = entry.timestamp
			oldest_key = key

	if not oldest_key.is_empty():
		_cache.erase(oldest_key)


func _hash_context(context: Dictionary) -> int:
	# Create a simple hash of the context for cache invalidation
	# This is not cryptographically secure, just for quick comparison
	var hash_value := 0
	for key in context:
		hash_value ^= hash(key)
		hash_value ^= hash(str(context[key]))
	return hash_value


# =============================================================================
# STATIC CONVENIENCE METHODS
# =============================================================================

## Quick render with default options.
static func quick_render(text: String, context: Dictionary = {}) -> String:
	var renderer = DialogueTagRenderer.new()
	return renderer.render_text(text, context)


## Render and return full result.
static func full_render(text: String, context: Dictionary = {}, options: RenderOptions = null) -> RenderResult:
	var renderer = DialogueTagRenderer.new()
	if options:
		renderer.set_options(options)
	return renderer.render(text, context)


## Create a renderer with specific options.
static func create_with_options(options: RenderOptions) -> DialogueTagRenderer:
	var renderer = DialogueTagRenderer.new()
	renderer.set_options(options)
	return renderer


# =============================================================================
# DEBUG / UTILITY
# =============================================================================

## Get debug info about a rendered text.
func get_render_info(text: String, context: Dictionary = {}) -> Dictionary:
	var parse_result = _parser.parse(text)
	var render_result = render(text, context)

	return {
		"source": text,
		"rendered": render_result.text,
		"success": render_result.success,
		"errors": render_result.errors,
		"has_variables": parse_result.has_variables,
		"has_conditionals": parse_result.has_conditionals,
		"variables_found": parse_result.get_variable_names(),
		"variables_used": render_result.variables_used,
		"missing_variables": render_result.missing_variables,
		"conditions_evaluated": render_result.conditions_evaluated,
		"tag_count": parse_result.tags.size(),
		"max_nesting": parse_result.max_nesting_depth
	}


## Preview render with debug markers.
func preview_with_markers(text: String, context: Dictionary = {}) -> String:
	var old_debug = _options.debug_mode
	_options.debug_mode = true
	var result = render_text(text, context)
	_options.debug_mode = old_debug
	return result
