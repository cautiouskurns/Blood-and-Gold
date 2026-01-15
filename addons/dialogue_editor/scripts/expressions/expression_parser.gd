@tool
class_name ExpressionParser
extends RefCounted
## Recursive descent parser for expression strings.
## Parses a token stream into an Abstract Syntax Tree (AST).
## Supports arithmetic, comparison, logical operators, function calls, and dot notation.

# =============================================================================
# AST NODE CLASSES
# =============================================================================

## Base class for all AST nodes.
class ASTNode:
	var position: int  # Position in source for error reporting
	var line: int
	var column: int

	func _init(p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		position = p_position
		line = p_line
		column = p_column

	func accept(visitor: ASTVisitor) -> Variant:
		push_error("ASTNode.accept() must be overridden")
		return null

	func _to_string() -> String:
		return "ASTNode"


## Literal value (number, string, boolean).
class LiteralNode extends ASTNode:
	var value: Variant

	func _init(p_value: Variant, p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		value = p_value

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_literal(self)

	func _to_string() -> String:
		if value is String:
			return "Literal(\"%s\")" % value
		return "Literal(%s)" % str(value)


## Variable reference (possibly with dot notation).
class VariableNode extends ASTNode:
	var name: String
	var path: Array[String]  # For dot notation: player.stats.health -> ["player", "stats", "health"]

	func _init(p_name: String, p_path: Array[String] = [], p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		name = p_name
		path = p_path if not p_path.is_empty() else [p_name]

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_variable(self)

	func get_full_path() -> String:
		return ".".join(path)

	func _to_string() -> String:
		return "Variable(%s)" % get_full_path()


## Binary operation (left op right).
class BinaryOpNode extends ASTNode:
	var left: ASTNode
	var operator: String
	var right: ASTNode

	func _init(p_left: ASTNode, p_operator: String, p_right: ASTNode, p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		left = p_left
		operator = p_operator
		right = p_right

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_binary_op(self)

	func _to_string() -> String:
		return "BinaryOp(%s %s %s)" % [str(left), operator, str(right)]


## Unary operation (op operand).
class UnaryOpNode extends ASTNode:
	var operator: String
	var operand: ASTNode

	func _init(p_operator: String, p_operand: ASTNode, p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		operator = p_operator
		operand = p_operand

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_unary_op(self)

	func _to_string() -> String:
		return "UnaryOp(%s %s)" % [operator, str(operand)]


## Function call with arguments.
class FunctionCallNode extends ASTNode:
	var name: String
	var arguments: Array[ASTNode]

	func _init(p_name: String, p_arguments: Array[ASTNode] = [], p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		name = p_name
		arguments = p_arguments

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_function_call(self)

	func _to_string() -> String:
		var args_str = ", ".join(arguments.map(func(a): return str(a)))
		return "FunctionCall(%s(%s))" % [name, args_str]


## Array/bracket access (obj[index]).
class IndexAccessNode extends ASTNode:
	var object: ASTNode
	var index: ASTNode

	func _init(p_object: ASTNode, p_index: ASTNode, p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		object = p_object
		index = p_index

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_index_access(self)

	func _to_string() -> String:
		return "IndexAccess(%s[%s])" % [str(object), str(index)]


## Member access via dot notation (obj.member).
class MemberAccessNode extends ASTNode:
	var object: ASTNode
	var member: String

	func _init(p_object: ASTNode, p_member: String, p_position: int = 0, p_line: int = 1, p_column: int = 1) -> void:
		super(p_position, p_line, p_column)
		object = p_object
		member = p_member

	func accept(visitor: ASTVisitor) -> Variant:
		return visitor.visit_member_access(self)

	func _to_string() -> String:
		return "MemberAccess(%s.%s)" % [str(object), member]


# =============================================================================
# AST VISITOR (for evaluation/compilation)
# =============================================================================

class ASTVisitor:
	func visit_literal(_node: LiteralNode) -> Variant:
		return null

	func visit_variable(_node: VariableNode) -> Variant:
		return null

	func visit_binary_op(_node: BinaryOpNode) -> Variant:
		return null

	func visit_unary_op(_node: UnaryOpNode) -> Variant:
		return null

	func visit_function_call(_node: FunctionCallNode) -> Variant:
		return null

	func visit_index_access(_node: IndexAccessNode) -> Variant:
		return null

	func visit_member_access(_node: MemberAccessNode) -> Variant:
		return null


# =============================================================================
# PARSE ERROR CLASS
# =============================================================================

class ParseError:
	var message: String
	var position: int
	var line: int
	var column: int
	var token_info: String

	func _init(p_message: String, p_position: int = 0, p_line: int = 1, p_column: int = 1, p_token_info: String = "") -> void:
		message = p_message
		position = p_position
		line = p_line
		column = p_column
		token_info = p_token_info

	func _to_string() -> String:
		var location = "line %d, column %d" % [line, column]
		if token_info.is_empty():
			return "ParseError at %s: %s" % [location, message]
		return "ParseError at %s near '%s': %s" % [location, token_info, message]


# =============================================================================
# PARSE RESULT CLASS
# =============================================================================

class ParseResult:
	var success: bool
	var ast: ASTNode
	var errors: Array[ParseError]

	func _init() -> void:
		success = true
		ast = null
		errors = []

	func set_ast(node: ASTNode) -> void:
		ast = node

	func add_error(error: ParseError) -> void:
		errors.append(error)
		success = false

	func has_errors() -> bool:
		return not errors.is_empty()


# =============================================================================
# PARSER STATE
# =============================================================================

const ExpressionLexerScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_lexer.gd")

var _tokens: Array  # Array of ExpressionLexer.Token
var _current: int = 0
var _source: String = ""


# =============================================================================
# PUBLIC API
# =============================================================================

## Parse an expression string into an AST.
## Returns a ParseResult containing the AST and any errors.
func parse(expression: String) -> ParseResult:
	_source = expression
	_current = 0

	var result = ParseResult.new()

	# Tokenize the expression first
	var lexer = ExpressionLexerScript.new()
	var lexer_result = lexer.tokenize(expression)

	if lexer_result.has_errors():
		for error in lexer_result.errors:
			result.add_error(ParseError.new(
				error.message,
				error.position,
				error.line,
				error.column,
				error.context
			))
		return result

	_tokens = []
	for token in lexer_result.tokens:
		_tokens.append(token)

	if _tokens.is_empty():
		result.add_error(ParseError.new("Empty expression", 0, 1, 1))
		return result

	# Parse the expression
	var ast = _parse_expression(result)

	if ast != null and not result.has_errors():
		# Check for trailing tokens (except EOF)
		if not _check_type(ExpressionLexerScript.TokenType.EOF):
			var token = _peek()
			result.add_error(ParseError.new(
				"Unexpected token after expression",
				token.position,
				token.line,
				token.column,
				token.lexeme
			))
		else:
			result.set_ast(ast)

	return result


## Convenience method to parse and return AST or null on error.
func parse_or_null(expression: String) -> ASTNode:
	var result = parse(expression)
	if result.has_errors():
		return null
	return result.ast


## Validate an expression without fully parsing it.
## Returns a ParseResult with errors if invalid.
func validate(expression: String) -> ParseResult:
	return parse(expression)


# =============================================================================
# RECURSIVE DESCENT PARSER
# =============================================================================

## Top-level expression parsing.
func _parse_expression(result: ParseResult) -> ASTNode:
	return _parse_or(result)


## Parse OR expressions (lowest precedence for logical ops).
func _parse_or(result: ParseResult) -> ASTNode:
	var left = _parse_and(result)
	if left == null:
		return null

	while _match_keyword("or") or _match_operator("||"):
		var op = _previous()
		var operator = "or" if op.value == "or" else "||"
		var right = _parse_and(result)
		if right == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % operator,
				op.position,
				op.line,
				op.column,
				operator
			))
			return null
		left = BinaryOpNode.new(left, operator, right, op.position, op.line, op.column)

	return left


## Parse AND expressions.
func _parse_and(result: ParseResult) -> ASTNode:
	var left = _parse_comparison(result)
	if left == null:
		return null

	while _match_keyword("and") or _match_operator("&&"):
		var op = _previous()
		var operator = "and" if op.value == "and" else "&&"
		var right = _parse_comparison(result)
		if right == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % operator,
				op.position,
				op.line,
				op.column,
				operator
			))
			return null
		left = BinaryOpNode.new(left, operator, right, op.position, op.line, op.column)

	return left


## Parse comparison expressions (==, !=, <, >, <=, >=).
func _parse_comparison(result: ParseResult) -> ASTNode:
	var left = _parse_term(result)
	if left == null:
		return null

	while _match_operator("==") or _match_operator("!=") or \
		  _match_operator("<") or _match_operator(">") or \
		  _match_operator("<=") or _match_operator(">="):
		var op = _previous()
		var right = _parse_term(result)
		if right == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % op.value,
				op.position,
				op.line,
				op.column,
				str(op.value)
			))
			return null
		left = BinaryOpNode.new(left, str(op.value), right, op.position, op.line, op.column)

	return left


## Parse additive expressions (+, -).
func _parse_term(result: ParseResult) -> ASTNode:
	var left = _parse_factor(result)
	if left == null:
		return null

	while _match_operator("+") or _match_operator("-"):
		var op = _previous()
		var right = _parse_factor(result)
		if right == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % op.value,
				op.position,
				op.line,
				op.column,
				str(op.value)
			))
			return null
		left = BinaryOpNode.new(left, str(op.value), right, op.position, op.line, op.column)

	return left


## Parse multiplicative expressions (*, /, %).
func _parse_factor(result: ParseResult) -> ASTNode:
	var left = _parse_unary(result)
	if left == null:
		return null

	while _match_operator("*") or _match_operator("/") or _match_operator("%"):
		var op = _previous()
		var right = _parse_unary(result)
		if right == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % op.value,
				op.position,
				op.line,
				op.column,
				str(op.value)
			))
			return null
		left = BinaryOpNode.new(left, str(op.value), right, op.position, op.line, op.column)

	return left


## Parse unary expressions (not, -).
func _parse_unary(result: ParseResult) -> ASTNode:
	if _match_keyword("not") or _match_operator("-"):
		var op = _previous()
		var operator = "not" if op.value == "not" else "-"
		var operand = _parse_unary(result)  # Right-associative
		if operand == null:
			result.add_error(ParseError.new(
				"Expected expression after '%s'" % operator,
				op.position,
				op.line,
				op.column,
				operator
			))
			return null
		return UnaryOpNode.new(operator, operand, op.position, op.line, op.column)

	return _parse_postfix(result)


## Parse postfix expressions (function calls, member access, index access).
func _parse_postfix(result: ParseResult) -> ASTNode:
	var expr = _parse_primary(result)
	if expr == null:
		return null

	while true:
		if _match_type(ExpressionLexerScript.TokenType.LPAREN):
			# Function call
			expr = _parse_function_call(expr, result)
			if expr == null:
				return null
		elif _match_type(ExpressionLexerScript.TokenType.DOT):
			# Member access
			var dot = _previous()
			if not _check_type(ExpressionLexerScript.TokenType.IDENTIFIER):
				result.add_error(ParseError.new(
					"Expected identifier after '.'",
					dot.position,
					dot.line,
					dot.column,
					"."
				))
				return null
			var member_token = _advance()
			expr = MemberAccessNode.new(expr, member_token.value, dot.position, dot.line, dot.column)
		elif _match_type(ExpressionLexerScript.TokenType.LBRACKET):
			# Index access
			var bracket = _previous()
			var index = _parse_expression(result)
			if index == null:
				result.add_error(ParseError.new(
					"Expected index expression",
					bracket.position,
					bracket.line,
					bracket.column,
					"["
				))
				return null
			if not _match_type(ExpressionLexerScript.TokenType.RBRACKET):
				var token = _peek()
				result.add_error(ParseError.new(
					"Expected ']' after index",
					token.position,
					token.line,
					token.column,
					token.lexeme
				))
				return null
			expr = IndexAccessNode.new(expr, index, bracket.position, bracket.line, bracket.column)
		else:
			break

	return expr


## Parse function call arguments.
func _parse_function_call(callee: ASTNode, result: ParseResult) -> ASTNode:
	var lparen = _previous()
	var args: Array[ASTNode] = []

	# Get function name from callee
	var func_name = ""
	if callee is VariableNode:
		func_name = callee.get_full_path()
	elif callee is MemberAccessNode:
		# Handle method calls like obj.method()
		func_name = str(callee)
	else:
		result.add_error(ParseError.new(
			"Invalid function call target",
			lparen.position,
			lparen.line,
			lparen.column,
			"("
		))
		return null

	# Parse arguments
	if not _check_type(ExpressionLexerScript.TokenType.RPAREN):
		var first_arg = _parse_expression(result)
		if first_arg == null:
			return null
		args.append(first_arg)

		while _match_type(ExpressionLexerScript.TokenType.COMMA):
			var arg = _parse_expression(result)
			if arg == null:
				var token = _peek()
				result.add_error(ParseError.new(
					"Expected argument after ','",
					token.position,
					token.line,
					token.column,
					token.lexeme
				))
				return null
			args.append(arg)

	if not _match_type(ExpressionLexerScript.TokenType.RPAREN):
		var token = _peek()
		result.add_error(ParseError.new(
			"Expected ')' after function arguments",
			token.position,
			token.line,
			token.column,
			token.lexeme
		))
		return null

	# If callee was a simple variable, use its name; otherwise keep the full expression
	if callee is VariableNode:
		return FunctionCallNode.new(callee.name, args, lparen.position, lparen.line, lparen.column)
	else:
		# For method calls, we'll need to handle this differently
		# For now, store the full path
		return FunctionCallNode.new(func_name, args, lparen.position, lparen.line, lparen.column)


## Parse primary expressions (literals, variables, parenthesized).
func _parse_primary(result: ParseResult) -> ASTNode:
	var token = _peek()

	# Number literal
	if _match_type(ExpressionLexerScript.TokenType.NUMBER):
		var prev = _previous()
		return LiteralNode.new(prev.value, prev.position, prev.line, prev.column)

	# String literal
	if _match_type(ExpressionLexerScript.TokenType.STRING):
		var prev = _previous()
		return LiteralNode.new(prev.value, prev.position, prev.line, prev.column)

	# Boolean literal
	if _match_type(ExpressionLexerScript.TokenType.BOOLEAN):
		var prev = _previous()
		return LiteralNode.new(prev.value, prev.position, prev.line, prev.column)

	# Parenthesized expression
	if _match_type(ExpressionLexerScript.TokenType.LPAREN):
		var lparen = _previous()
		var expr = _parse_expression(result)
		if expr == null:
			return null
		if not _match_type(ExpressionLexerScript.TokenType.RPAREN):
			var next_token = _peek()
			result.add_error(ParseError.new(
				"Expected ')' after expression",
				next_token.position,
				next_token.line,
				next_token.column,
				next_token.lexeme
			))
			return null
		return expr

	# Identifier (variable or function name)
	if _match_type(ExpressionLexerScript.TokenType.IDENTIFIER):
		var prev = _previous()
		return VariableNode.new(prev.value, [prev.value], prev.position, prev.line, prev.column)

	# Error: unexpected token
	if _check_type(ExpressionLexerScript.TokenType.EOF):
		result.add_error(ParseError.new(
			"Unexpected end of expression",
			token.position,
			token.line,
			token.column,
			""
		))
	else:
		result.add_error(ParseError.new(
			"Unexpected token '%s'" % token.lexeme,
			token.position,
			token.line,
			token.column,
			token.lexeme
		))

	return null


# =============================================================================
# HELPER METHODS
# =============================================================================

func _is_at_end() -> bool:
	return _current >= _tokens.size() or _check_type(ExpressionLexerScript.TokenType.EOF)


func _peek() -> ExpressionLexerScript.Token:
	if _current >= _tokens.size():
		# Return a dummy EOF token
		return ExpressionLexerScript.Token.new(
			ExpressionLexerScript.TokenType.EOF,
			null,
			"",
			_source.length(),
			1,
			_source.length() + 1
		)
	return _tokens[_current]


func _previous() -> ExpressionLexerScript.Token:
	if _current == 0:
		return _tokens[0]
	return _tokens[_current - 1]


func _advance() -> ExpressionLexerScript.Token:
	if not _is_at_end():
		_current += 1
	return _previous()


func _check_type(type: ExpressionLexerScript.TokenType) -> bool:
	if _is_at_end() and type != ExpressionLexerScript.TokenType.EOF:
		return false
	return _peek().type == type


func _match_type(type: ExpressionLexerScript.TokenType) -> bool:
	if _check_type(type):
		_advance()
		return true
	return false


func _match_keyword(keyword: String) -> bool:
	if _check_type(ExpressionLexerScript.TokenType.KEYWORD) and _peek().value == keyword:
		_advance()
		return true
	return false


func _match_operator(op: String) -> bool:
	if _check_type(ExpressionLexerScript.TokenType.OPERATOR) and _peek().value == op:
		_advance()
		return true
	return false


# =============================================================================
# AST PRETTY PRINTER (for debugging)
# =============================================================================

class ASTPrinter extends ASTVisitor:
	var _indent: int = 0

	func print_ast(node: ASTNode) -> String:
		if node == null:
			return "null"
		return node.accept(self)

	func visit_literal(node: LiteralNode) -> Variant:
		if node.value is String:
			return "\"%s\"" % node.value
		return str(node.value)

	func visit_variable(node: VariableNode) -> Variant:
		return node.get_full_path()

	func visit_binary_op(node: BinaryOpNode) -> Variant:
		var left = node.left.accept(self)
		var right = node.right.accept(self)
		return "(%s %s %s)" % [left, node.operator, right]

	func visit_unary_op(node: UnaryOpNode) -> Variant:
		var operand = node.operand.accept(self)
		return "(%s %s)" % [node.operator, operand]

	func visit_function_call(node: FunctionCallNode) -> Variant:
		var args = []
		for arg in node.arguments:
			args.append(arg.accept(self))
		return "%s(%s)" % [node.name, ", ".join(args)]

	func visit_index_access(node: IndexAccessNode) -> Variant:
		var obj = node.object.accept(self)
		var idx = node.index.accept(self)
		return "%s[%s]" % [obj, idx]

	func visit_member_access(node: MemberAccessNode) -> Variant:
		var obj = node.object.accept(self)
		return "%s.%s" % [obj, node.member]


## Create a string representation of an AST.
static func ast_to_string(node: ASTNode) -> String:
	var printer = ASTPrinter.new()
	return printer.print_ast(node)


# =============================================================================
# STATIC HELPERS
# =============================================================================

## Parse an expression string and return the AST or null.
static func parse_expression(expression: String) -> ASTNode:
	var parser = ExpressionParser.new()
	return parser.parse_or_null(expression)


## Validate an expression and return true if valid.
static func is_valid(expression: String) -> bool:
	var parser = ExpressionParser.new()
	var result = parser.validate(expression)
	return not result.has_errors()
