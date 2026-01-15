@tool
class_name DialogueFormattingTags
extends RefCounted
## Handles BBCode-style formatting tags in dialogue text.
## Supports standard BBCode (bold, italic, color) and game-specific tags (shake, wave, pause, speed).
## Validates tag nesting and provides preview text for editor display.

# =============================================================================
# TAG DEFINITIONS
# =============================================================================

## Tag types categorized by behavior.
enum TagCategory {
	STANDARD_BBCODE,   # Supported by RichTextLabel directly
	GAME_EFFECT,       # Custom effects handled by game runtime
	TIMING,            # Timing/pacing hints for typewriter
	PASSTHROUGH        # Unknown tags passed through unchanged
}

## Definition of a supported tag.
class TagDefinition:
	var name: String              # Tag name (e.g., "b", "color")
	var category: TagCategory     # How this tag is handled
	var has_value: bool           # Whether tag accepts a value (e.g., color=red)
	var required_value: bool      # Whether value is required
	var self_closing: bool        # Whether tag is self-closing (e.g., [pause=1])
	var preview_supported: bool   # Whether RichTextLabel can preview it
	var description: String       # Human-readable description
	var example: String           # Example usage

	func _init(p_name: String, p_category: TagCategory) -> void:
		name = p_name
		category = p_category
		has_value = false
		required_value = false
		self_closing = false
		preview_supported = p_category == TagCategory.STANDARD_BBCODE
		description = ""
		example = ""

	func with_value(required: bool = false) -> TagDefinition:
		has_value = true
		required_value = required
		return self

	func as_self_closing() -> TagDefinition:
		self_closing = true
		return self

	func with_description(desc: String) -> TagDefinition:
		description = desc
		return self

	func with_example(ex: String) -> TagDefinition:
		example = ex
		return self


## Registered tag definitions.
var _tags: Dictionary = {}  # name -> TagDefinition

## Tag stack for validation.
var _tag_stack: Array = []


# =============================================================================
# INITIALIZATION
# =============================================================================

func _init() -> void:
	_register_standard_tags()
	_register_game_tags()


func _register_standard_tags() -> void:
	# Bold
	_register_tag(TagDefinition.new("b", TagCategory.STANDARD_BBCODE)
		.with_description("Bold text")
		.with_example("[b]bold text[/b]"))

	# Italic
	_register_tag(TagDefinition.new("i", TagCategory.STANDARD_BBCODE)
		.with_description("Italic text")
		.with_example("[i]italic text[/i]"))

	# Underline
	_register_tag(TagDefinition.new("u", TagCategory.STANDARD_BBCODE)
		.with_description("Underlined text")
		.with_example("[u]underlined text[/u]"))

	# Strikethrough
	_register_tag(TagDefinition.new("s", TagCategory.STANDARD_BBCODE)
		.with_description("Strikethrough text")
		.with_example("[s]strikethrough[/s]"))

	# Color
	_register_tag(TagDefinition.new("color", TagCategory.STANDARD_BBCODE)
		.with_value(true)
		.with_description("Colored text")
		.with_example("[color=red]red text[/color]"))

	# Font size
	_register_tag(TagDefinition.new("font_size", TagCategory.STANDARD_BBCODE)
		.with_value(true)
		.with_description("Font size in pixels")
		.with_example("[font_size=24]large text[/font_size]"))

	# Code (monospace)
	_register_tag(TagDefinition.new("code", TagCategory.STANDARD_BBCODE)
		.with_description("Monospace text")
		.with_example("[code]code text[/code]"))

	# Center align
	_register_tag(TagDefinition.new("center", TagCategory.STANDARD_BBCODE)
		.with_description("Center aligned text")
		.with_example("[center]centered[/center]"))

	# Right align
	_register_tag(TagDefinition.new("right", TagCategory.STANDARD_BBCODE)
		.with_description("Right aligned text")
		.with_example("[right]right aligned[/right]"))


func _register_game_tags() -> void:
	# Shake effect
	_register_tag(TagDefinition.new("shake", TagCategory.GAME_EFFECT)
		.with_value()  # Optional intensity value
		.with_description("Shaking text effect")
		.with_example("[shake]scary text[/shake]"))

	# Wave effect
	_register_tag(TagDefinition.new("wave", TagCategory.GAME_EFFECT)
		.with_value()  # Optional amplitude value
		.with_description("Wavy text effect")
		.with_example("[wave]wobbly text[/wave]"))

	# Rainbow effect
	_register_tag(TagDefinition.new("rainbow", TagCategory.GAME_EFFECT)
		.with_value()  # Optional speed value
		.with_description("Rainbow color cycling")
		.with_example("[rainbow]colorful[/rainbow]"))

	# Fade effect
	_register_tag(TagDefinition.new("fade", TagCategory.GAME_EFFECT)
		.with_value()  # Optional duration
		.with_description("Fade in text")
		.with_example("[fade]appearing text[/fade]"))

	# Pause - self-closing timing tag
	_register_tag(TagDefinition.new("pause", TagCategory.TIMING)
		.with_value(true)
		.as_self_closing()
		.with_description("Pause for N seconds")
		.with_example("[pause=1.5]"))

	# Speed - changes typewriter speed
	_register_tag(TagDefinition.new("speed", TagCategory.TIMING)
		.with_value(true)
		.with_description("Typewriter speed multiplier")
		.with_example("[speed=0.5]slow text[/speed]"))

	# Wait for input
	_register_tag(TagDefinition.new("wait", TagCategory.TIMING)
		.as_self_closing()
		.with_description("Wait for player input")
		.with_example("[wait]"))

	# Clear screen
	_register_tag(TagDefinition.new("clear", TagCategory.TIMING)
		.as_self_closing()
		.with_description("Clear dialogue box")
		.with_example("[clear]"))


func _register_tag(tag: TagDefinition) -> void:
	_tags[tag.name] = tag


# =============================================================================
# TAG LOOKUP
# =============================================================================

## Check if a tag name is registered.
func is_known_tag(name: String) -> bool:
	return _tags.has(name.to_lower())


## Get tag definition by name.
func get_tag(name: String) -> TagDefinition:
	return _tags.get(name.to_lower())


## Get all registered tags.
func get_all_tags() -> Dictionary:
	return _tags.duplicate()


## Get tags by category.
func get_tags_by_category(category: TagCategory) -> Array[TagDefinition]:
	var result: Array[TagDefinition] = []
	for tag in _tags.values():
		if tag.category == category:
			result.append(tag)
	return result


## Get all standard BBCode tags.
func get_standard_tags() -> Array[TagDefinition]:
	return get_tags_by_category(TagCategory.STANDARD_BBCODE)


## Get all game effect tags.
func get_game_effect_tags() -> Array[TagDefinition]:
	return get_tags_by_category(TagCategory.GAME_EFFECT)


## Get all timing tags.
func get_timing_tags() -> Array[TagDefinition]:
	return get_tags_by_category(TagCategory.TIMING)


# =============================================================================
# PARSING
# =============================================================================

## Parsed tag from text.
class ParsedTag:
	var name: String              # Tag name
	var value: String             # Tag value (if any)
	var is_closing: bool          # Is this a closing tag?
	var is_self_closing: bool     # Is this a self-closing tag?
	var position: int             # Position in source text
	var length: int               # Length in source text
	var raw: String               # Raw tag text including brackets

	func _init() -> void:
		name = ""
		value = ""
		is_closing = false
		is_self_closing = false
		position = 0
		length = 0
		raw = ""

	func _to_string() -> String:
		if is_closing:
			return "CloseTag(/%s)" % name
		elif value.is_empty():
			return "OpenTag(%s)" % name
		else:
			return "OpenTag(%s=%s)" % [name, value]


## Parse result containing all tags found.
class ParseResult:
	var success: bool = true
	var tags: Array = []          # Array of ParsedTag
	var errors: Array = []        # Array of error messages
	var warnings: Array = []      # Array of warning messages

	func add_error(message: String) -> void:
		errors.append(message)
		success = false

	func add_warning(message: String) -> void:
		warnings.append(message)

	func has_errors() -> bool:
		return not errors.is_empty()


## Parse all BBCode tags from text.
func parse(text: String) -> ParseResult:
	var result = ParseResult.new()
	var pos := 0
	var length := text.length()

	while pos < length:
		# Find next tag opening
		var tag_start = text.find("[", pos)
		if tag_start == -1:
			break

		# Find tag closing
		var tag_end = text.find("]", tag_start)
		if tag_end == -1:
			result.add_error("Unclosed tag bracket at position %d" % tag_start)
			break

		# Extract tag content
		var tag_content = text.substr(tag_start + 1, tag_end - tag_start - 1)
		var parsed = _parse_single_tag(tag_content, tag_start, tag_end - tag_start + 1)

		if parsed:
			parsed.raw = text.substr(tag_start, tag_end - tag_start + 1)
			result.tags.append(parsed)

		pos = tag_end + 1

	return result


func _parse_single_tag(content: String, position: int, length: int) -> ParsedTag:
	if content.is_empty():
		return null

	var tag = ParsedTag.new()
	tag.position = position
	tag.length = length

	# Check for closing tag
	if content.begins_with("/"):
		tag.is_closing = true
		content = content.substr(1)

	# Check for value
	var eq_pos = content.find("=")
	if eq_pos > 0:
		tag.name = content.substr(0, eq_pos).strip_edges().to_lower()
		tag.value = content.substr(eq_pos + 1).strip_edges()
	else:
		tag.name = content.strip_edges().to_lower()

	# Check if self-closing
	var tag_def = get_tag(tag.name)
	if tag_def and tag_def.self_closing:
		tag.is_self_closing = true

	return tag


# =============================================================================
# VALIDATION
# =============================================================================

## Validation result for tag nesting.
class ValidationResult:
	var valid: bool = true
	var errors: Array = []        # Array of ValidationError
	var warnings: Array = []      # Array of strings

	func add_error(error) -> void:
		errors.append(error)
		valid = false

	func add_warning(message: String) -> void:
		warnings.append(message)


## Validation error details.
class ValidationError:
	var message: String
	var position: int
	var tag_name: String

	func _init(p_message: String, p_position: int = -1, p_tag: String = "") -> void:
		message = p_message
		position = p_position
		tag_name = p_tag

	func _to_string() -> String:
		if position >= 0:
			return "%s at position %d" % [message, position]
		return message


## Validate BBCode tag nesting in text.
func validate(text: String) -> ValidationResult:
	var result = ValidationResult.new()
	_tag_stack.clear()

	var parse_result = parse(text)

	# Check parse errors first
	for error in parse_result.errors:
		result.add_error(ValidationError.new(error))

	# Validate tag nesting
	for tag in parse_result.tags:
		if tag.is_self_closing:
			# Self-closing tags don't need validation
			continue

		if tag.is_closing:
			# Closing tag - check if it matches the top of stack
			if _tag_stack.is_empty():
				result.add_error(ValidationError.new(
					"Unexpected closing tag [/%s] with no matching opening tag" % tag.name,
					tag.position,
					tag.name
				))
			elif _tag_stack.back().name != tag.name:
				var expected = _tag_stack.back().name
				result.add_error(ValidationError.new(
					"Mismatched tag: expected [/%s] but found [/%s]" % [expected, tag.name],
					tag.position,
					tag.name
				))
				# Try to recover by popping until we find a match or empty
				_recover_stack(tag.name)
			else:
				# Correct closing tag
				_tag_stack.pop_back()
		else:
			# Opening tag - push to stack
			var tag_def = get_tag(tag.name)

			if tag_def:
				# Known tag - validate value if required
				if tag_def.required_value and tag.value.is_empty():
					result.add_error(ValidationError.new(
						"Tag [%s] requires a value" % tag.name,
						tag.position,
						tag.name
					))
			else:
				# Unknown tag - warn but don't error (passthrough)
				result.add_warning("Unknown tag [%s] will be passed through unchanged" % tag.name)

			_tag_stack.append(tag)

	# Check for unclosed tags
	for unclosed in _tag_stack:
		result.add_error(ValidationError.new(
			"Unclosed tag [%s]" % unclosed.name,
			unclosed.position,
			unclosed.name
		))

	_tag_stack.clear()
	return result


func _recover_stack(closing_tag: String) -> void:
	# Try to find matching opening tag in stack
	for i in range(_tag_stack.size() - 1, -1, -1):
		if _tag_stack[i].name == closing_tag:
			# Found it - pop everything up to and including
			while _tag_stack.size() > i:
				_tag_stack.pop_back()
			return
	# No match found - clear stack
	_tag_stack.clear()


## Quick validation check.
func is_valid(text: String) -> bool:
	return validate(text).valid


# =============================================================================
# PREVIEW GENERATION
# =============================================================================

## Generate preview text suitable for RichTextLabel.
## Converts game-specific tags to visual representations.
func generate_preview(text: String) -> String:
	var result := text

	# Replace game effect tags with visual approximations
	result = _replace_game_tags_for_preview(result)

	# Replace timing tags with visual markers
	result = _replace_timing_tags_for_preview(result)

	return result


func _replace_game_tags_for_preview(text: String) -> String:
	var result := text

	# Shake - show in orange to indicate effect
	result = _replace_tag_pair(result, "shake", "[color=orange]", "[/color]")

	# Wave - show in cyan
	result = _replace_tag_pair(result, "wave", "[color=cyan]", "[/color]")

	# Rainbow - show with multiple colors
	result = _replace_tag_pair(result, "rainbow", "[color=magenta]", "[/color]")

	# Fade - show in gray (faded look)
	result = _replace_tag_pair(result, "fade", "[color=gray]", "[/color]")

	return result


func _replace_timing_tags_for_preview(text: String) -> String:
	var result := text

	# Pause - show as marker
	var pause_regex = RegEx.new()
	pause_regex.compile("\\[pause(?:=([\\d.]+))?\\]")
	var matches = pause_regex.search_all(result)
	for m in matches:
		var duration = m.get_string(1) if m.get_string(1) else "?"
		result = result.replace(m.get_string(), "[color=yellow][...%ss...][/color]" % duration)

	# Speed - show in blue to indicate different speed
	result = _replace_tag_pair(result, "speed", "[color=blue]", "[/color]")

	# Wait - show as marker
	result = result.replace("[wait]", "[color=yellow][WAIT][/color]")

	# Clear - show as marker
	result = result.replace("[clear]", "[color=red][CLEAR][/color]")

	return result


func _replace_tag_pair(text: String, tag_name: String, open_replacement: String, close_replacement: String) -> String:
	var result := text

	# Handle tags with values [tag=value]
	var tag_regex = RegEx.new()
	tag_regex.compile("\\[" + tag_name + "(?:=[^\\]]*)?\\]")
	result = tag_regex.sub(result, open_replacement, true)

	# Handle closing tags
	result = result.replace("[/" + tag_name + "]", close_replacement)

	return result


## Strip all formatting tags from text (get plain text).
func strip_tags(text: String) -> String:
	var result := text
	var tag_regex = RegEx.new()
	tag_regex.compile("\\[[^\\]]+\\]")
	result = tag_regex.sub(result, "", true)
	return result


## Get the visible character count (excluding tags).
func get_visible_length(text: String) -> int:
	return strip_tags(text).length()


# =============================================================================
# EXPORT SUPPORT
# =============================================================================

## Prepare text for export - validate and optionally strip unknown tags.
func prepare_for_export(text: String, strip_unknown: bool = false) -> Dictionary:
	var result = {
		"text": text,
		"valid": true,
		"errors": [],
		"tags_used": []
	}

	var validation = validate(text)
	result["valid"] = validation.valid

	for error in validation.errors:
		result["errors"].append(str(error))

	# Collect tags used
	var parse_result = parse(text)
	var tags_seen = {}
	for tag in parse_result.tags:
		if not tag.is_closing:
			tags_seen[tag.name] = true
	result["tags_used"] = tags_seen.keys()

	# Strip unknown tags if requested
	if strip_unknown:
		var export_text = text
		for tag in parse_result.tags:
			if not is_known_tag(tag.name):
				export_text = export_text.replace(tag.raw, "")
		result["text"] = export_text

	return result


## Check if text contains any game-specific tags.
func has_game_tags(text: String) -> bool:
	var parse_result = parse(text)
	for tag in parse_result.tags:
		var tag_def = get_tag(tag.name)
		if tag_def and tag_def.category in [TagCategory.GAME_EFFECT, TagCategory.TIMING]:
			return true
	return false


## Check if text contains any timing tags.
func has_timing_tags(text: String) -> bool:
	var parse_result = parse(text)
	for tag in parse_result.tags:
		var tag_def = get_tag(tag.name)
		if tag_def and tag_def.category == TagCategory.TIMING:
			return true
	return false


# =============================================================================
# TAG AUTOCOMPLETION
# =============================================================================

## Get autocomplete suggestions for a partial tag name.
func get_autocomplete_suggestions(partial: String) -> Array[Dictionary]:
	var suggestions: Array[Dictionary] = []
	var search = partial.to_lower()

	for tag in _tags.values():
		if tag.name.begins_with(search) or search.is_empty():
			var suggestion = {
				"name": tag.name,
				"category": TagCategory.keys()[tag.category],
				"description": tag.description,
				"example": tag.example,
				"has_value": tag.has_value,
				"required_value": tag.required_value,
				"self_closing": tag.self_closing
			}
			suggestions.append(suggestion)

	# Sort by name
	suggestions.sort_custom(func(a, b): return a.name < b.name)
	return suggestions


## Get tag help text for display.
func get_tag_help(tag_name: String) -> String:
	var tag_def = get_tag(tag_name)
	if not tag_def:
		return "Unknown tag: [%s]" % tag_name

	var help := "[%s]\n" % tag_def.name
	help += "Category: %s\n" % TagCategory.keys()[tag_def.category]
	help += "Description: %s\n" % tag_def.description
	if tag_def.has_value:
		help += "Value: %s\n" % ("Required" if tag_def.required_value else "Optional")
	if tag_def.self_closing:
		help += "Self-closing: Yes\n"
	help += "Example: %s" % tag_def.example
	return help


# =============================================================================
# STATIC HELPERS
# =============================================================================

## Quick validation check.
static func quick_validate(text: String) -> bool:
	var validator = DialogueFormattingTags.new()
	return validator.is_valid(text)


## Quick preview generation.
static func quick_preview(text: String) -> String:
	var formatter = DialogueFormattingTags.new()
	return formatter.generate_preview(text)


## Quick strip tags.
static func quick_strip(text: String) -> String:
	var formatter = DialogueFormattingTags.new()
	return formatter.strip_tags(text)
