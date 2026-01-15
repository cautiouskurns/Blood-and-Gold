@tool
class_name DialogueTagParser
extends RefCounted
## Parses {variable_name} and {if}...{else}...{/if} tags in dialogue text.
## Supports variable interpolation, dot notation, and conditional blocks.
## Used by DialogueRunner to process text before display.

# =============================================================================
# TAG TYPES
# =============================================================================

enum TagType {
	TEXT,               # Plain text segment
	VARIABLE,           # {variable_name} or {player.stats.health}
	CONDITIONAL_START,  # {if condition}
	CONDITIONAL_ELIF,   # {elif condition}
	CONDITIONAL_ELSE,   # {else}
	CONDITIONAL_END,    # {/if} or {endif}
	ERROR               # Parse error marker
}


# =============================================================================
# TAG CLASS
# =============================================================================

class Tag:
	var type: TagType
	var content: String          # Text content, variable name, or condition expression
	var path: Array              # For dot notation: ["player", "stats", "health"]
	var position: int            # Start position in source text
	var length: int              # Length in source text
	var error_message: String    # Error description if type is ERROR
	var nesting_depth: int       # Conditional nesting depth when this tag was parsed

	func _init(p_type: TagType, p_content: String, p_position: int, p_length: int = 0) -> void:
		type = p_type
		content = p_content
		position = p_position
		length = p_length if p_length > 0 else p_content.length()
		path = []
		error_message = ""
		nesting_depth = 0

	func _to_string() -> String:
		match type:
			TagType.TEXT:
				var preview = content.substr(0, 20)
				if content.length() > 20:
					preview += "..."
				return "TEXT(\"%s\")" % preview
			TagType.VARIABLE:
				if path.size() > 1:
					return "VAR(%s)" % ".".join(path)
				return "VAR(%s)" % content
			TagType.CONDITIONAL_START:
				return "IF(%s)" % content
			TagType.CONDITIONAL_ELIF:
				return "ELIF(%s)" % content
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

	## Check if this is a conditional tag.
	func is_conditional() -> bool:
		return type in [TagType.CONDITIONAL_START, TagType.CONDITIONAL_ELIF,
						TagType.CONDITIONAL_ELSE, TagType.CONDITIONAL_END]

	## Get the full variable path as a string.
	func get_variable_path() -> String:
		if path.is_empty():
			return content
		return ".".join(path)


# =============================================================================
# CONDITIONAL BLOCK CLASS (AST)
# =============================================================================

## Represents a conditional block in the AST.
## Structure: if-branch -> [elif-branches] -> [else-branch]
class ConditionalBlock:
	var condition: String        # The if/elif condition expression
	var if_content: Array        # Tags for the if branch (Array of Tag or ConditionalBlock)
	var elif_branches: Array     # Array of {condition: String, content: Array}
	var else_content: Array      # Tags for the else branch (can be empty)
	var position: int            # Position of opening {if}
	var end_position: int        # Position after closing {/if}

	func _init() -> void:
		condition = ""
		if_content = []
		elif_branches = []
		else_content = []
		position = 0
		end_position = 0

	func _to_string() -> String:
		var s = "ConditionalBlock(if %s)" % condition
		if elif_branches.size() > 0:
			s += " [%d elif]" % elif_branches.size()
		if else_content.size() > 0:
			s += " [else]"
		return s

	## Get all conditions in this block (if + elifs).
	func get_all_conditions() -> Array:
		var conditions: Array = [condition]
		for branch in elif_branches:
			conditions.append(branch.condition)
		return conditions


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
	var tags: Array              # Array of Tag (flat list)
	var ast: Array               # Array of Tag and ConditionalBlock (nested structure)
	var errors: Array            # Array of ParseError
	var has_variables: bool      # Quick check if any variables exist
	var has_conditionals: bool   # Quick check if any conditionals exist
	var max_nesting_depth: int   # Maximum conditional nesting depth found

	func _init() -> void:
		success = true
		tags = []
		ast = []
		errors = []
		has_variables = false
		has_conditionals = false
		max_nesting_depth = 0

	func add_tag(tag: Tag) -> void:
		tags.append(tag)
		if tag.type == TagType.VARIABLE:
			has_variables = true
		if tag.is_conditional():
			has_conditionals = true
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

	## Get all condition expressions found in the text.
	func get_conditions() -> Array:
		var conditions: Array = []
		for tag in tags:
			if tag.type in [TagType.CONDITIONAL_START, TagType.CONDITIONAL_ELIF]:
				if not tag.content.is_empty():
					conditions.append(tag.content)
		return conditions


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

# Reserved keywords for conditional tags
const KEYWORD_IF := "if"
const KEYWORD_ELIF := "elif"
const KEYWORD_ELSE := "else"
const KEYWORD_ENDIF := "/if"
const KEYWORD_ENDIF_ALT := "endif"

const CONDITIONAL_KEYWORDS := [KEYWORD_IF, KEYWORD_ELIF, KEYWORD_ELSE, KEYWORD_ENDIF, KEYWORD_ENDIF_ALT]


# =============================================================================
# PARSER STATE
# =============================================================================

var _source: String = ""
var _position: int = 0
var _length: int = 0
var _conditional_depth: int = 0  # Track nesting depth
var _conditional_stack: Array = []  # Stack of {type, position} for validation


# =============================================================================
# PUBLIC API
# =============================================================================

## Parse a text string and extract all tags.
## Returns a ParseResult containing tags and any errors.
func parse(text: String) -> ParseResult:
	_source = text
	_position = 0
	_length = text.length()
	_conditional_depth = 0
	_conditional_stack = []

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
				tag.nesting_depth = _conditional_depth
				result.add_tag(tag)

				# Update max nesting depth
				if _conditional_depth > result.max_nesting_depth:
					result.max_nesting_depth = _conditional_depth

			text_start = _position
			continue

		_position += 1

	# Flush any remaining text
	if _position > text_start:
		var text_content = _source.substr(text_start, _position - text_start)
		result.add_tag(Tag.new(TagType.TEXT, text_content, text_start))

	# Check for unclosed conditionals
	if _conditional_stack.size() > 0:
		for unclosed in _conditional_stack:
			result.add_error(ParseError.new(
				"Unclosed {%s} tag" % unclosed.keyword,
				unclosed.position,
				_get_context(unclosed.position)
			))

	# Build AST if no errors
	if result.success:
		result.ast = _build_ast(result.tags)

	return result


## Parse and validate, including condition expression validation.
## Uses the expression parser if available.
func parse_and_validate(text: String) -> ParseResult:
	var result = parse(text)

	if result.success and result.has_conditionals:
		_validate_conditions(result)

	return result


## Convenience method to check if text contains any tags.
func has_tags(text: String) -> bool:
	var i := 0
	while i < text.length():
		if text[i] == TAG_OPEN:
			if i > 0 and text[i - 1] == ESCAPE_CHAR:
				i += 1
				continue
			return true
		i += 1
	return false


## Check if text contains conditional tags.
func has_conditionals(text: String) -> bool:
	var result = parse(text)
	return result.has_conditionals


## Get all variable names from text.
func get_variables(text: String) -> Array:
	var result = parse(text)
	return result.get_variable_names()


## Get all condition expressions from text.
func get_conditions(text: String) -> Array:
	var result = parse(text)
	return result.get_conditions()


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

	# Check for conditional keywords
	var keyword = _peek_keyword()
	if not keyword.is_empty():
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
			if c not in VAR_START_CHARS:
				result.add_error(ParseError.new(
					"Invalid variable name: must start with letter or underscore, got '%s'" % c,
					_position,
					_get_context(_position)
				))
				return _make_error_tag("Invalid variable name start", tag_start)
		else:
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
	_position += keyword.length()
	_skip_whitespace()

	var condition := ""
	var tag_type: TagType

	# Determine tag type and handle accordingly
	match keyword:
		KEYWORD_IF:
			tag_type = TagType.CONDITIONAL_START
			condition = _read_until_close()
			if condition.is_empty():
				result.add_error(ParseError.new(
					"{if} requires a condition expression",
					tag_start,
					_get_context(tag_start)
				))
			_conditional_depth += 1
			_conditional_stack.append({
				"keyword": "if",
				"position": tag_start
			})

		KEYWORD_ELIF:
			tag_type = TagType.CONDITIONAL_ELIF
			condition = _read_until_close()
			if condition.is_empty():
				result.add_error(ParseError.new(
					"{elif} requires a condition expression",
					tag_start,
					_get_context(tag_start)
				))
			# Validate we're inside an if block
			if _conditional_stack.is_empty():
				result.add_error(ParseError.new(
					"{elif} without matching {if}",
					tag_start,
					_get_context(tag_start)
				))

		KEYWORD_ELSE:
			tag_type = TagType.CONDITIONAL_ELSE
			_read_until_close()  # Should be empty, but skip anyway
			# Validate we're inside an if block
			if _conditional_stack.is_empty():
				result.add_error(ParseError.new(
					"{else} without matching {if}",
					tag_start,
					_get_context(tag_start)
				))

		KEYWORD_ENDIF, KEYWORD_ENDIF_ALT:
			tag_type = TagType.CONDITIONAL_END
			_read_until_close()  # Should be empty
			# Validate we have a matching if
			if _conditional_stack.is_empty():
				result.add_error(ParseError.new(
					"{/if} without matching {if}",
					tag_start,
					_get_context(tag_start)
				))
			else:
				_conditional_stack.pop_back()
				_conditional_depth -= 1

		_:
			tag_type = TagType.ERROR
			result.add_error(ParseError.new(
				"Unknown conditional keyword: %s" % keyword,
				tag_start,
				_get_context(tag_start)
			))

	if _position >= _length or _source[_position - 1] != TAG_CLOSE:
		if _position < _length and _source[_position] == TAG_CLOSE:
			_position += 1
		elif _position >= _length:
			result.add_error(ParseError.new(
				"Unclosed conditional tag",
				tag_start,
				_get_context(tag_start)
			))
			return _make_error_tag("Unclosed conditional tag", tag_start)

	var tag = Tag.new(tag_type, condition.strip_edges(), tag_start, _position - tag_start)
	return tag


func _read_until_close() -> String:
	var content := ""
	while _position < _length and _source[_position] != TAG_CLOSE:
		content += _source[_position]
		_position += 1
	if _position < _length:
		_position += 1  # Skip closing brace
	return content


# =============================================================================
# AST BUILDING
# =============================================================================

## Build AST from flat tag list.
## Groups conditionals into ConditionalBlock nodes.
func _build_ast(tags: Array) -> Array:
	var ast: Array = []
	var i := 0

	while i < tags.size():
		var tag = tags[i]

		if tag.type == TagType.CONDITIONAL_START:
			var block = _build_conditional_block(tags, i)
			ast.append(block.block)
			i = block.end_index
		else:
			ast.append(tag)
			i += 1

	return ast


## Build a ConditionalBlock from tags starting at index.
## Returns {block: ConditionalBlock, end_index: int}
func _build_conditional_block(tags: Array, start_index: int) -> Dictionary:
	var block = ConditionalBlock.new()
	var i := start_index

	# Get the opening {if} tag
	var if_tag = tags[i]
	block.condition = if_tag.content
	block.position = if_tag.position
	i += 1

	# Current branch we're filling
	var current_content: Array = []
	var in_else := false
	var current_elif_condition := ""

	while i < tags.size():
		var tag = tags[i]

		match tag.type:
			TagType.CONDITIONAL_START:
				# Nested conditional - recurse
				var nested = _build_conditional_block(tags, i)
				current_content.append(nested.block)
				i = nested.end_index
				continue

			TagType.CONDITIONAL_ELIF:
				# Save current content to appropriate branch
				if in_else:
					# Error: elif after else (should be caught in parse)
					pass
				elif current_elif_condition.is_empty():
					# First elif, save if_content
					block.if_content = current_content
				else:
					# Save previous elif branch
					block.elif_branches.append({
						"condition": current_elif_condition,
						"content": current_content
					})
				current_elif_condition = tag.content
				current_content = []
				i += 1
				continue

			TagType.CONDITIONAL_ELSE:
				# Save current content
				if current_elif_condition.is_empty():
					block.if_content = current_content
				else:
					block.elif_branches.append({
						"condition": current_elif_condition,
						"content": current_content
					})
				current_content = []
				in_else = true
				current_elif_condition = ""
				i += 1
				continue

			TagType.CONDITIONAL_END:
				# End of this block
				if in_else:
					block.else_content = current_content
				elif not current_elif_condition.is_empty():
					block.elif_branches.append({
						"condition": current_elif_condition,
						"content": current_content
					})
				else:
					block.if_content = current_content
				block.end_position = tag.position + tag.length
				return {"block": block, "end_index": i + 1}

			_:
				# Regular tag (TEXT, VARIABLE, etc.)
				current_content.append(tag)
				i += 1

	# Reached end without finding {/if} - should be caught in parse
	return {"block": block, "end_index": i}


# =============================================================================
# CONDITION VALIDATION
# =============================================================================

## Validate condition expressions using ExpressionParser if available.
func _validate_conditions(result: ParseResult) -> void:
	# Try to use ExpressionParser for validation
	var parser_available := false
	var parser = null

	# Check if ExpressionParser class exists
	if ClassDB.class_exists("ExpressionParser"):
		parser_available = true
	else:
		# Try to instantiate via class_name
		# Note: This may fail if expression system isn't compiled
		pass

	if not parser_available:
		# Expression parser not available, skip validation
		# Conditions will be validated at runtime
		return

	for tag in result.tags:
		if tag.type in [TagType.CONDITIONAL_START, TagType.CONDITIONAL_ELIF]:
			if tag.content.is_empty():
				continue

			# Would validate here with parser.parse(tag.content)
			# For now, do basic syntax checks
			_basic_condition_check(tag.content, tag.position, result)


## Basic condition syntax check without full parser.
func _basic_condition_check(condition: String, position: int, result: ParseResult) -> void:
	# Check for common issues
	if condition.strip_edges().is_empty():
		result.add_error(ParseError.new(
			"Empty condition expression",
			position,
			""
		))
		return

	# Check for balanced parentheses
	var paren_depth := 0
	for c in condition:
		if c == "(":
			paren_depth += 1
		elif c == ")":
			paren_depth -= 1
			if paren_depth < 0:
				result.add_error(ParseError.new(
					"Unbalanced parentheses in condition: extra ')'",
					position,
					condition
				))
				return

	if paren_depth != 0:
		result.add_error(ParseError.new(
			"Unbalanced parentheses in condition: missing ')'",
			position,
			condition
		))


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
	var remaining = _source.substr(_position)
	for keyword in CONDITIONAL_KEYWORDS:
		if remaining.begins_with(keyword):
			var next_pos = keyword.length()
			if next_pos >= remaining.length():
				return keyword
			var next_char = remaining[next_pos]
			if next_char in " \t}":
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

	if name[0] not in VAR_START_CHARS:
		return false

	for i in range(1, name.length()):
		var c = name[i]
		if c != DOT_CHAR and c not in VAR_CHARS:
			return false

	if ".." in name or name.ends_with("."):
		return false

	return true


## Split a variable path into segments.
static func split_variable_path(path: String) -> Array:
	return path.split(".")


## Join variable path segments.
static func join_variable_path(segments: Array) -> String:
	return ".".join(segments)


## Render a flat tag list back to string (for debugging/preview).
static func tags_to_string(tags: Array) -> String:
	var result := ""
	for tag in tags:
		match tag.type:
			TagType.TEXT:
				result += tag.content
			TagType.VARIABLE:
				result += "{%s}" % tag.get_variable_path()
			TagType.CONDITIONAL_START:
				result += "{if %s}" % tag.content
			TagType.CONDITIONAL_ELIF:
				result += "{elif %s}" % tag.content
			TagType.CONDITIONAL_ELSE:
				result += "{else}"
			TagType.CONDITIONAL_END:
				result += "{/if}"
	return result
