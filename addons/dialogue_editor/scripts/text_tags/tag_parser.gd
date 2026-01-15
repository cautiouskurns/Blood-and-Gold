@tool
class_name DialogueTagParser
extends RefCounted
## Parses {variable_name} tags in dialogue text.
## Supports variable interpolation, dot notation, and conditional blocks.
## Used by DialogueRunner to process text before display.

# =============================================================================
# TAG TYPES
# =============================================================================

enum TagType {
	TEXT,               # Plain text segment
	VARIABLE,           # {variable_name} or {player.stats.health}
	CONDITIONAL_START,  # {if condition}  (Phase 4C.2)
	CONDITIONAL_ELSE,   # {else}          (Phase 4C.2)
	CONDITIONAL_END,    # {/if}           (Phase 4C.2)
	ERROR               # Parse error marker
}


# =============================================================================
# TAG CLASS
# =============================================================================

class Tag:
	var type: TagType
	var content: String          # Text content or variable name
	var path: Array              # For dot notation: ["player", "stats", "health"]
	var position: int            # Start position in source text
	var length: int              # Length in source text
	var error_message: String    # Error description if type is ERROR

	func _init(p_type: TagType, p_content: String, p_position: int, p_length: int = 0) -> void:
		type = p_type
		content = p_content
		position = p_position
		length = p_length if p_length > 0 else p_content.length()
		path = []
		error_message = ""

	func _to_string() -> String:
		match type:
			TagType.TEXT:
				return "TEXT(\"%s\")" % content.substr(0, 20)
			TagType.VARIABLE:
				if path.size() > 1:
					return "VAR(%s)" % ".".join(path)
				return "VAR(%s)" % content
			TagType.CONDITIONAL_START:
				return "IF(%s)" % content
			TagType.CONDITIONAL_ELSE:
				return "ELSE"
			TagType.CONDITIONAL_END:
				return "ENDIF"
			TagType.ERROR:
				return "ERROR(%s)" % error_message
			_:
				return "UNKNOWN"

	## Check if this is an error tag.
	func is_error() -> bool:
		return type == TagType.ERROR

	## Get the full variable path as a string.
	func get_variable_path() -> String:
		if path.is_empty():
			return content
		return ".".join(path)


# =============================================================================
# PARSE ERROR CLASS
# =============================================================================

class ParseError:
	var message: String
	var position: int
	var context: String  # Surrounding text for context

	func _init(p_message: String, p_position: int, p_context: String = "") -> void:
		message = p_message
		position = p_position
		context = p_context

	func _to_string() -> String:
		if context.is_empty():
			return "ParseError at position %d: %s" % [position, message]
		return "ParseError at position %d: %s (near: \"%s\")" % [position, message, context]


# =============================================================================
# PARSE RESULT CLASS
# =============================================================================

class ParseResult:
	var success: bool
	var tags: Array  # Array of Tag
	var errors: Array  # Array of ParseError
	var has_variables: bool  # Quick check if any variables exist

	func _init() -> void:
		success = true
		tags = []
		errors = []
		has_variables = false

	func add_tag(tag: Tag) -> void:
		tags.append(tag)
		if tag.type == TagType.VARIABLE:
			has_variables = true
		if tag.type == TagType.ERROR:
			success = false

	func add_error(error: ParseError) -> void:
		errors.append(error)
		success = false

	func has_errors() -> bool:
		return not errors.is_empty()

	## Get all variable names found in the text.
	func get_variable_names() -> Array:
		var names: Array = []
		for tag in tags:
			if tag.type == TagType.VARIABLE:
				names.append(tag.get_variable_path())
		return names


# =============================================================================
# CONSTANTS
# =============================================================================

const TAG_OPEN := "{"
const TAG_CLOSE := "}"
const ESCAPE_CHAR := "\\"
const DOT_CHAR := "."

# Valid characters for variable names (start)
const VAR_START_CHARS := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

# Valid characters for variable names (continuation)
const VAR_CHARS := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"

# Reserved keywords for conditional tags (Phase 4C.2)
const CONDITIONAL_KEYWORDS := ["if", "else", "elif", "/if", "endif"]


# =============================================================================
# PARSER STATE
# =============================================================================

var _source: String = ""
var _position: int = 0
var _length: int = 0


# =============================================================================
# PUBLIC API
# =============================================================================

## Parse a text string and extract all tags.
## Returns a ParseResult containing tags and any errors.
func parse(text: String) -> ParseResult:
	_source = text
	_position = 0
	_length = text.length()

	var result = ParseResult.new()
	var text_start := 0

	while _position < _length:
		var c = _source[_position]

		# Check for escape sequence
		if c == ESCAPE_CHAR and _peek_next() == TAG_OPEN:
			# Flush any pending text
			if _position > text_start:
				var text_content = _source.substr(text_start, _position - text_start)
				result.add_tag(Tag.new(TagType.TEXT, text_content, text_start))

			# Skip escape char, add literal brace as text
			_position += 1  # Skip backslash
			text_start = _position  # Start new text segment from the brace
			_position += 1  # Skip the brace
			continue

		# Check for tag open
		if c == TAG_OPEN:
			# Flush any pending text
			if _position > text_start:
				var text_content = _source.substr(text_start, _position - text_start)
				result.add_tag(Tag.new(TagType.TEXT, text_content, text_start))

			# Parse the tag
			var tag = _parse_tag(result)
			if tag:
				result.add_tag(tag)

			text_start = _position
			continue

		_position += 1

	# Flush any remaining text
	if _position > text_start:
		var text_content = _source.substr(text_start, _position - text_start)
		result.add_tag(Tag.new(TagType.TEXT, text_content, text_start))

	return result


## Convenience method to check if text contains any tags.
func has_tags(text: String) -> bool:
	# Quick check without full parsing
	var i := 0
	while i < text.length():
		if text[i] == TAG_OPEN:
			# Check if it's escaped
			if i > 0 and text[i - 1] == ESCAPE_CHAR:
				i += 1
				continue
			return true
		i += 1
	return false


## Get all variable names from text without full parsing.
func get_variables(text: String) -> Array:
	var result = parse(text)
	return result.get_variable_names()


# =============================================================================
# TAG PARSING
# =============================================================================

func _parse_tag(result: ParseResult) -> Tag:
	var tag_start := _position
	_position += 1  # Skip opening brace

	# Skip whitespace after opening brace
	_skip_whitespace()

	if _position >= _length:
		result.add_error(ParseError.new(
			"Unclosed tag at end of text",
			tag_start,
			_get_context(tag_start)
		))
		return _make_error_tag("Unclosed tag", tag_start)

	# Check for conditional keywords (Phase 4C.2 - stub for now)
	var keyword = _peek_keyword()
	if keyword in CONDITIONAL_KEYWORDS:
		return _parse_conditional_tag(tag_start, keyword, result)

	# Parse as variable tag
	return _parse_variable_tag(tag_start, result)


func _parse_variable_tag(tag_start: int, result: ParseResult) -> Tag:
	var var_name = ""
	var path: Array = []
	var current_segment := ""

	while _position < _length:
		var c = _source[_position]

		if c == TAG_CLOSE:
			# End of tag
			if not current_segment.is_empty():
				path.append(current_segment)
				if var_name.is_empty():
					var_name = current_segment

			_position += 1  # Skip closing brace

			# Validate we got a variable name
			if var_name.is_empty():
				result.add_error(ParseError.new(
					"Empty variable tag",
					tag_start,
					_get_context(tag_start)
				))
				return _make_error_tag("Empty variable tag", tag_start)

			# Create variable tag
			var tag = Tag.new(TagType.VARIABLE, var_name, tag_start, _position - tag_start)
			tag.path = path
			return tag

		if c == DOT_CHAR:
			# Dot notation separator
			if current_segment.is_empty():
				result.add_error(ParseError.new(
					"Invalid dot notation: missing segment before '.'",
					_position,
					_get_context(_position)
				))
				return _make_error_tag("Invalid dot notation", tag_start)

			path.append(current_segment)
			if var_name.is_empty():
				var_name = current_segment
			current_segment = ""
			_position += 1
			continue

		# Validate variable name characters
		if current_segment.is_empty():
			# First character must be a valid start char
			if c not in VAR_START_CHARS:
				result.add_error(ParseError.new(
					"Invalid variable name: must start with letter or underscore, got '%s'" % c,
					_position,
					_get_context(_position)
				))
				return _make_error_tag("Invalid variable name start", tag_start)
		else:
			# Subsequent characters
			if c not in VAR_CHARS:
				result.add_error(ParseError.new(
					"Invalid character in variable name: '%s'" % c,
					_position,
					_get_context(_position)
				))
				return _make_error_tag("Invalid variable character", tag_start)

		current_segment += c
		_position += 1

	# Reached end without closing brace
	result.add_error(ParseError.new(
		"Unclosed variable tag starting at position %d" % tag_start,
		tag_start,
		_get_context(tag_start)
	))
	return _make_error_tag("Unclosed tag", tag_start)


func _parse_conditional_tag(tag_start: int, keyword: String, result: ParseResult) -> Tag:
	# Phase 4C.2 stub - for now just skip to closing brace and create placeholder
	_position += keyword.length()
	_skip_whitespace()

	var condition := ""

	# Read until closing brace
	while _position < _length and _source[_position] != TAG_CLOSE:
		condition += _source[_position]
		_position += 1

	if _position >= _length:
		result.add_error(ParseError.new(
			"Unclosed conditional tag",
			tag_start,
			_get_context(tag_start)
		))
		return _make_error_tag("Unclosed conditional tag", tag_start)

	_position += 1  # Skip closing brace

	var tag_type: TagType
	match keyword:
		"if":
			tag_type = TagType.CONDITIONAL_START
		"else", "elif":
			tag_type = TagType.CONDITIONAL_ELSE
		"/if", "endif":
			tag_type = TagType.CONDITIONAL_END
		_:
			tag_type = TagType.ERROR

	var tag = Tag.new(tag_type, condition.strip_edges(), tag_start, _position - tag_start)
	return tag


# =============================================================================
# HELPER METHODS
# =============================================================================

func _peek_next() -> String:
	if _position + 1 >= _length:
		return ""
	return _source[_position + 1]


func _skip_whitespace() -> void:
	while _position < _length and _source[_position] in " \t":
		_position += 1


func _peek_keyword() -> String:
	# Check if the current position starts with a conditional keyword
	var remaining = _source.substr(_position)
	for keyword in CONDITIONAL_KEYWORDS:
		if remaining.begins_with(keyword):
			# Verify it's followed by whitespace or closing brace
			var next_pos = keyword.length()
			if next_pos >= remaining.length():
				return keyword
			var next_char = remaining[next_pos]
			if next_char in " \t}" or next_char == TAG_CLOSE:
				return keyword
	return ""


func _get_context(pos: int, context_size: int = 20) -> String:
	var start = maxi(0, pos - context_size / 2)
	var end = mini(_length, pos + context_size / 2)
	return _source.substr(start, end - start)


func _make_error_tag(message: String, position: int) -> Tag:
	var tag = Tag.new(TagType.ERROR, "", position)
	tag.error_message = message
	return tag


# =============================================================================
# STATIC UTILITY METHODS
# =============================================================================

## Check if a string is a valid variable name.
static func is_valid_variable_name(name: String) -> bool:
	if name.is_empty():
		return false

	# Check first character
	if name[0] not in VAR_START_CHARS:
		return false

	# Check remaining characters (including dots for paths)
	for i in range(1, name.length()):
		var c = name[i]
		if c != DOT_CHAR and c not in VAR_CHARS:
			return false

	# Check for consecutive dots or trailing dot
	if ".." in name or name.ends_with("."):
		return false

	return true


## Split a variable path into segments.
static func split_variable_path(path: String) -> Array:
	return path.split(".")


## Join variable path segments.
static func join_variable_path(segments: Array) -> String:
	return ".".join(segments)
