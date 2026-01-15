@tool
class_name ExpressionLexer
extends RefCounted
## Lexer for tokenizing expression strings into typed tokens.
## Supports numbers, strings, booleans, identifiers, operators, keywords, and punctuation.
## Used by the Expression Parser to build an AST.

# =============================================================================
# TOKEN TYPES
# =============================================================================

enum TokenType {
	# Literals
	NUMBER,         # Integer or float: 42, 3.14, -5
	STRING,         # Quoted string: "hello", 'world'
	BOOLEAN,        # true, false

	# Identifiers & Keywords
	IDENTIFIER,     # Variable names: player_level, reputation
	KEYWORD,        # and, or, not

	# Operators
	OPERATOR,       # ==, !=, >, <, >=, <=, +, -, *, /, %

	# Punctuation
	LPAREN,         # (
	RPAREN,         # )
	COMMA,          # ,
	DOT,            # .
	LBRACKET,       # [
	RBRACKET,       # ]

	# Special
	EOF,            # End of input
	ERROR           # Lexer error
}


# =============================================================================
# TOKEN CLASS
# =============================================================================

class Token:
	var type: int  # TokenType enum value (avoid @tool inner class type issues)
	var value: Variant          # The actual value (number, string, etc.)
	var lexeme: String          # The raw text that was tokenized
	var position: int           # Character position in source
	var line: int               # Line number (for multi-line expressions)
	var column: int             # Column number

	func _init(p_type: int, p_value: Variant, p_lexeme: String, p_position: int, p_line: int = 1, p_column: int = 0) -> void:
		type = p_type
		value = p_value
		lexeme = p_lexeme
		position = p_position
		line = p_line
		column = p_column

	func _to_string() -> String:
		return "Token(%s, %s, pos=%d)" % [TokenType.keys()[type], str(value), position]

	func is_type(t: int) -> bool:
		return type == t

	## Get a human-readable type name.
	func get_type_name() -> String:
		return TokenType.keys()[type]


# =============================================================================
# LEXER ERROR CLASS
# =============================================================================

class LexerError:
	var message: String
	var position: int
	var line: int
	var column: int
	var context: String  # The surrounding text for context

	func _init(p_message: String, p_position: int, p_line: int, p_column: int, p_context: String = "") -> void:
		message = p_message
		position = p_position
		line = p_line
		column = p_column
		context = p_context

	func _to_string() -> String:
		if context.is_empty():
			return "LexerError at line %d, column %d: %s" % [line, column, message]
		return "LexerError at line %d, column %d: %s\n  Context: \"%s\"" % [line, column, message, context]


# =============================================================================
# LEXER RESULT CLASS
# =============================================================================

class LexerResult:
	var success: bool
	var tokens: Array  # Array of Token (untyped to avoid @tool compilation issues)
	var errors: Array  # Array of LexerError

	func _init() -> void:
		success = true
		tokens = []
		errors = []

	func add_token(token) -> void:
		tokens.append(token)

	func add_error(error) -> void:
		errors.append(error)
		success = false

	func has_errors() -> bool:
		return not errors.is_empty()


# =============================================================================
# CONSTANTS
# =============================================================================

# Keywords that are recognized as special tokens
const KEYWORDS: Dictionary = {
	"and": TokenType.KEYWORD,
	"or": TokenType.KEYWORD,
	"not": TokenType.KEYWORD,
	"true": TokenType.BOOLEAN,
	"false": TokenType.BOOLEAN,
}

# Multi-character operators (order matters - longer first)
const MULTI_CHAR_OPERATORS: Array[String] = [
	"==", "!=", ">=", "<=", "&&", "||"
]

# Single-character operators
const SINGLE_CHAR_OPERATORS: String = "+-*/%<>="

# Valid identifier start characters
const IDENTIFIER_START: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

# Valid identifier continuation characters
const IDENTIFIER_CONTINUE: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789"

# Whitespace characters
const WHITESPACE: String = " \t\r\n"


# =============================================================================
# LEXER STATE
# =============================================================================

var _source: String = ""
var _position: int = 0
var _line: int = 1
var _column: int = 1
var _start_position: int = 0
var _start_line: int = 1
var _start_column: int = 1


# =============================================================================
# PUBLIC API
# =============================================================================

## Tokenize an expression string into an array of tokens.
## Returns a LexerResult containing tokens and any errors.
func tokenize(expression: String) -> LexerResult:
	_source = expression
	_position = 0
	_line = 1
	_column = 1

	var result = LexerResult.new()

	while not _is_at_end():
		_start_position = _position
		_start_line = _line
		_start_column = _column

		var token = _scan_token()
		if token != null:
			if token.type == TokenType.ERROR:
				result.add_error(LexerError.new(
					str(token.value),
					token.position,
					token.line,
					token.column,
					_get_context(token.position)
				))
			else:
				result.add_token(token)

	# Add EOF token
	result.add_token(Token.new(TokenType.EOF, null, "", _position, _line, _column))

	return result


## Convenience method that returns just the tokens array.
## Throws an error if lexing fails.
func tokenize_or_fail(expression: String) -> Array:
	var result = tokenize(expression)
	if result.has_errors():
		push_error("Lexer errors: " + str(result.errors))
		return []
	return result.tokens


# =============================================================================
# SCANNING METHODS
# =============================================================================

func _scan_token() -> Token:
	var c = _advance()

	# Skip whitespace
	if c in WHITESPACE:
		_skip_whitespace()
		return null

	# Skip comments
	if c == "#":
		_skip_line_comment()
		return null

	# Check for multi-line comment
	if c == "/" and _peek() == "*":
		_skip_block_comment()
		return null

	# Single-line comment with //
	if c == "/" and _peek() == "/":
		_skip_line_comment()
		return null

	# Punctuation
	match c:
		"(":
			return _make_token(TokenType.LPAREN, c)
		")":
			return _make_token(TokenType.RPAREN, c)
		",":
			return _make_token(TokenType.COMMA, c)
		".":
			# Check if it's a number starting with .
			if _peek().is_valid_int():
				return _scan_number_from_dot()
			return _make_token(TokenType.DOT, c)
		"[":
			return _make_token(TokenType.LBRACKET, c)
		"]":
			return _make_token(TokenType.RBRACKET, c)

	# String literals
	if c == '"' or c == "'":
		return _scan_string(c)

	# Numbers
	if c.is_valid_int() or (c == "-" and _peek().is_valid_int()):
		return _scan_number(c)

	# Operators
	if c in SINGLE_CHAR_OPERATORS or c == "!" or c == "&" or c == "|":
		return _scan_operator(c)

	# Identifiers and keywords
	if c in IDENTIFIER_START:
		return _scan_identifier(c)

	# Unknown character
	return _make_error_token("Unexpected character: '%s'" % c)


func _scan_number(first_char: String) -> Token:
	var lexeme = first_char
	var is_float = false

	# Handle negative sign
	if first_char == "-":
		if _is_at_end() or not (_peek().is_valid_int() or _peek() == "."):
			return _make_token(TokenType.OPERATOR, first_char)

	# Scan integer part
	while not _is_at_end() and _peek().is_valid_int():
		lexeme += _advance()

	# Check for decimal point
	if not _is_at_end() and _peek() == ".":
		var next = _peek_next()
		if next.is_valid_int():
			is_float = true
			lexeme += _advance()  # consume '.'
			while not _is_at_end() and _peek().is_valid_int():
				lexeme += _advance()

	# Check for scientific notation
	if not _is_at_end() and (_peek() == "e" or _peek() == "E"):
		var next = _peek_next()
		if next.is_valid_int() or next == "+" or next == "-":
			is_float = true
			lexeme += _advance()  # consume 'e' or 'E'
			if _peek() == "+" or _peek() == "-":
				lexeme += _advance()
			while not _is_at_end() and _peek().is_valid_int():
				lexeme += _advance()

	var value: Variant
	if is_float:
		value = lexeme.to_float()
	else:
		value = lexeme.to_int()

	return _make_token(TokenType.NUMBER, value, lexeme)


func _scan_number_from_dot() -> Token:
	var lexeme = "."

	while not _is_at_end() and _peek().is_valid_int():
		lexeme += _advance()

	return _make_token(TokenType.NUMBER, lexeme.to_float(), lexeme)


func _scan_string(quote_char: String) -> Token:
	var value = ""
	var lexeme = quote_char

	while not _is_at_end() and _peek() != quote_char:
		var c = _advance()
		lexeme += c

		if c == "\\":
			# Handle escape sequences
			if _is_at_end():
				return _make_error_token("Unterminated string escape sequence")

			var escape = _advance()
			lexeme += escape

			match escape:
				"n":
					value += "\n"
				"t":
					value += "\t"
				"r":
					value += "\r"
				"\\":
					value += "\\"
				"\"":
					value += "\""
				"'":
					value += "'"
				"0":
					value += "\0"
				_:
					# Unknown escape, keep as-is
					value += escape
		elif c == "\n":
			_line += 1
			_column = 1
			value += c
		else:
			value += c

	if _is_at_end():
		return _make_error_token("Unterminated string literal")

	# Consume closing quote
	lexeme += _advance()

	return _make_token(TokenType.STRING, value, lexeme)


func _scan_operator(first_char: String) -> Token:
	# Check for multi-character operators
	for op in MULTI_CHAR_OPERATORS:
		if first_char == op[0] and _peek() == op[1]:
			_advance()  # consume second character
			return _make_token(TokenType.OPERATOR, op, op)

	# Single character operators
	return _make_token(TokenType.OPERATOR, first_char)


func _scan_identifier(first_char: String) -> Token:
	var lexeme = first_char

	while not _is_at_end() and _peek() in IDENTIFIER_CONTINUE:
		lexeme += _advance()

	# Check if it's a keyword
	var lower_lexeme = lexeme.to_lower()
	if KEYWORDS.has(lower_lexeme):
		var keyword_type = KEYWORDS[lower_lexeme]
		if keyword_type == TokenType.BOOLEAN:
			return _make_token(TokenType.BOOLEAN, lower_lexeme == "true", lexeme)
		return _make_token(keyword_type, lower_lexeme, lexeme)

	return _make_token(TokenType.IDENTIFIER, lexeme, lexeme)


# =============================================================================
# COMMENT HANDLING
# =============================================================================

func _skip_whitespace() -> void:
	# We already consumed the first whitespace character
	while not _is_at_end() and _peek() in WHITESPACE:
		var c = _advance()
		if c == "\n":
			_line += 1
			_column = 1


func _skip_line_comment() -> void:
	# Skip until end of line
	while not _is_at_end() and _peek() != "\n":
		_advance()


func _skip_block_comment() -> void:
	# Consume the '*' after '/'
	_advance()

	while not _is_at_end():
		var c = _advance()
		if c == "\n":
			_line += 1
			_column = 1
		elif c == "*" and _peek() == "/":
			_advance()  # consume '/'
			return

	# Unterminated block comment - we don't error, just end


# =============================================================================
# HELPER METHODS
# =============================================================================

func _is_at_end() -> bool:
	return _position >= _source.length()


func _advance() -> String:
	if _is_at_end():
		return ""
	var c = _source[_position]
	_position += 1
	_column += 1
	return c


func _peek() -> String:
	if _is_at_end():
		return ""
	return _source[_position]


func _peek_next() -> String:
	if _position + 1 >= _source.length():
		return ""
	return _source[_position + 1]


func _make_token(type: int, value: Variant, lexeme: String = "") -> Token:
	if lexeme.is_empty():
		lexeme = str(value)
	return Token.new(type, value, lexeme, _start_position, _start_line, _start_column)


func _make_error_token(message: String) -> Token:
	return Token.new(TokenType.ERROR, message, "", _start_position, _start_line, _start_column)


func _get_context(pos: int, context_size: int = 20) -> String:
	var start = maxi(0, pos - context_size / 2)
	var end = mini(_source.length(), pos + context_size / 2)
	return _source.substr(start, end - start)


# =============================================================================
# STATIC HELPER METHODS
# =============================================================================

## Get a human-readable name for a token type.
static func get_type_name(type: int) -> String:
	return TokenType.keys()[type]


## Check if a token type is a literal (NUMBER, STRING, BOOLEAN).
static func is_literal_type(type: int) -> bool:
	return type in [TokenType.NUMBER, TokenType.STRING, TokenType.BOOLEAN]


## Check if a token type is an operator.
static func is_operator_type(type: int) -> bool:
	return type == TokenType.OPERATOR


## Get operator precedence (higher = binds tighter).
static func get_operator_precedence(op: String) -> int:
	match op:
		"or", "||":
			return 1
		"and", "&&":
			return 2
		"==", "!=":
			return 3
		"<", ">", "<=", ">=":
			return 4
		"+", "-":
			return 5
		"*", "/", "%":
			return 6
		_:
			return 0


## Check if an operator is right-associative.
static func is_right_associative(op: String) -> bool:
	# Currently only 'not' is right-associative, but it's unary
	return false
