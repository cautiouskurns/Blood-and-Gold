@tool
class_name ExpressionEvaluator
extends RefCounted
## Evaluates parsed expression ASTs against a context of variable values.
## Supports arithmetic, comparison, logical operators, function calls, and member access.

const ExpressionParserScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")

# =============================================================================
# EVALUATION RESULT
# =============================================================================

class EvaluationResult:
	var success: bool
	var value: Variant
	var error: String
	var error_position: int

	func _init(p_value: Variant = null, p_error: String = "", p_position: int = -1) -> void:
		if p_error.is_empty():
			success = true
			value = p_value
			error = ""
			error_position = -1
		else:
			success = false
			value = null
			error = p_error
			error_position = p_position

	static func ok(val: Variant) -> EvaluationResult:
		return EvaluationResult.new(val)

	static func err(message: String, position: int = -1) -> EvaluationResult:
		return EvaluationResult.new(null, message, position)

	func _to_string() -> String:
		if success:
			return "EvaluationResult(ok: %s)" % str(value)
		return "EvaluationResult(error: %s)" % error


# =============================================================================
# EVALUATION CONTEXT
# =============================================================================

## The context holds variable values and provides built-in functions.
## Can be extended for game-specific functionality.
var _context: Dictionary = {}
var _functions: Dictionary = {}
var _missing_variable_handler: Callable
var _strict_mode: bool = false  # If true, missing variables cause errors


# =============================================================================
# PUBLIC API
# =============================================================================

func _init() -> void:
	_register_builtin_functions()


## Set the evaluation context (variable values).
func set_context(context: Dictionary) -> void:
	_context = context


## Get the current context.
func get_context() -> Dictionary:
	return _context


## Set a single variable in the context.
func set_variable(name: String, value: Variant) -> void:
	_context[name] = value


## Get a variable from the context.
func get_variable(name: String, default: Variant = null) -> Variant:
	return _context.get(name, default)


## Enable strict mode (missing variables cause errors instead of returning null).
func set_strict_mode(enabled: bool) -> void:
	_strict_mode = enabled


## Set a custom handler for missing variables.
## Handler signature: func(name: String) -> Variant
func set_missing_variable_handler(handler: Callable) -> void:
	_missing_variable_handler = handler


## Register a custom function.
## Handler signature: func(args: Array) -> Variant
func register_function(name: String, handler: Callable) -> void:
	_functions[name] = handler


## Evaluate an AST node and return the result.
func evaluate(node: ExpressionParserScript.ASTNode) -> EvaluationResult:
	if node == null:
		return EvaluationResult.err("Cannot evaluate null node")

	return _evaluate_node(node)


## Evaluate an expression string directly.
func evaluate_string(expression: String) -> EvaluationResult:
	var parser = ExpressionParserScript.new()
	var parse_result = parser.parse(expression)

	if parse_result.has_errors():
		var first_error = parse_result.errors[0]
		return EvaluationResult.err(
			"Parse error: %s" % first_error.message,
			first_error.position
		)

	return evaluate(parse_result.ast)


## Convenience method: evaluate and return value or default on error.
func evaluate_or_default(node: ExpressionParserScript.ASTNode, default: Variant) -> Variant:
	var result = evaluate(node)
	if result.success:
		return result.value
	return default


## Convenience method: evaluate string and return value or default on error.
func evaluate_string_or_default(expression: String, default: Variant) -> Variant:
	var result = evaluate_string(expression)
	if result.success:
		return result.value
	return default


# =============================================================================
# NODE EVALUATION
# =============================================================================

func _evaluate_node(node: ExpressionParserScript.ASTNode) -> EvaluationResult:
	if node is ExpressionParserScript.LiteralNode:
		return _evaluate_literal(node)
	elif node is ExpressionParserScript.VariableNode:
		return _evaluate_variable(node)
	elif node is ExpressionParserScript.BinaryOpNode:
		return _evaluate_binary_op(node)
	elif node is ExpressionParserScript.UnaryOpNode:
		return _evaluate_unary_op(node)
	elif node is ExpressionParserScript.FunctionCallNode:
		return _evaluate_function_call(node)
	elif node is ExpressionParserScript.MemberAccessNode:
		return _evaluate_member_access(node)
	elif node is ExpressionParserScript.IndexAccessNode:
		return _evaluate_index_access(node)
	else:
		return EvaluationResult.err("Unknown node type: %s" % node.get_class(), node.position)


func _evaluate_literal(node: ExpressionParserScript.LiteralNode) -> EvaluationResult:
	return EvaluationResult.ok(node.value)


func _evaluate_variable(node: ExpressionParserScript.VariableNode) -> EvaluationResult:
	var path = node.path
	var value = _resolve_path(path)

	if value == null and not _context_has_path(path):
		if _strict_mode:
			return EvaluationResult.err(
				"Undefined variable: %s" % node.get_full_path(),
				node.position
			)
		elif _missing_variable_handler.is_valid():
			value = _missing_variable_handler.call(node.get_full_path())

	return EvaluationResult.ok(value)


func _evaluate_binary_op(node: ExpressionParserScript.BinaryOpNode) -> EvaluationResult:
	# Short-circuit evaluation for logical operators
	if node.operator in ["and", "&&"]:
		var left_result = _evaluate_node(node.left)
		if not left_result.success:
			return left_result
		if not _to_bool(left_result.value):
			return EvaluationResult.ok(false)
		var right_result = _evaluate_node(node.right)
		if not right_result.success:
			return right_result
		return EvaluationResult.ok(_to_bool(right_result.value))

	if node.operator in ["or", "||"]:
		var left_result = _evaluate_node(node.left)
		if not left_result.success:
			return left_result
		if _to_bool(left_result.value):
			return EvaluationResult.ok(true)
		var right_result = _evaluate_node(node.right)
		if not right_result.success:
			return right_result
		return EvaluationResult.ok(_to_bool(right_result.value))

	# Evaluate both operands for other operators
	var left_result = _evaluate_node(node.left)
	if not left_result.success:
		return left_result

	var right_result = _evaluate_node(node.right)
	if not right_result.success:
		return right_result

	var left = left_result.value
	var right = right_result.value

	match node.operator:
		# Comparison operators
		"==":
			return EvaluationResult.ok(_equals(left, right))
		"!=":
			return EvaluationResult.ok(not _equals(left, right))
		"<":
			return _compare(left, right, func(a, b): return a < b, node.position)
		">":
			return _compare(left, right, func(a, b): return a > b, node.position)
		"<=":
			return _compare(left, right, func(a, b): return a <= b, node.position)
		">=":
			return _compare(left, right, func(a, b): return a >= b, node.position)

		# Arithmetic operators
		"+":
			return _arithmetic(left, right, func(a, b): return a + b, node.position, "+")
		"-":
			return _arithmetic(left, right, func(a, b): return a - b, node.position, "-")
		"*":
			return _arithmetic(left, right, func(a, b): return a * b, node.position, "*")
		"/":
			if _to_number(right) == 0:
				return EvaluationResult.err("Division by zero", node.position)
			return _arithmetic(left, right, func(a, b): return a / b, node.position, "/")
		"%":
			if _to_number(right) == 0:
				return EvaluationResult.err("Modulo by zero", node.position)
			return _arithmetic(left, right, func(a, b): return fmod(a, b), node.position, "%")

		_:
			return EvaluationResult.err("Unknown operator: %s" % node.operator, node.position)


func _evaluate_unary_op(node: ExpressionParserScript.UnaryOpNode) -> EvaluationResult:
	var operand_result = _evaluate_node(node.operand)
	if not operand_result.success:
		return operand_result

	var operand = operand_result.value

	match node.operator:
		"not":
			return EvaluationResult.ok(not _to_bool(operand))
		"-":
			return EvaluationResult.ok(-_to_number(operand))
		_:
			return EvaluationResult.err("Unknown unary operator: %s" % node.operator, node.position)


func _evaluate_function_call(node: ExpressionParserScript.FunctionCallNode) -> EvaluationResult:
	# Evaluate all arguments first
	var args: Array = []
	for arg_node in node.arguments:
		var arg_result = _evaluate_node(arg_node)
		if not arg_result.success:
			return arg_result
		args.append(arg_result.value)

	# Look up the function
	if not _functions.has(node.name):
		return EvaluationResult.err("Unknown function: %s" % node.name, node.position)

	var func_handler = _functions[node.name]

	# Call the function
	var result = func_handler.call(args)

	# Handle function returning EvaluationResult directly
	if result is EvaluationResult:
		return result

	return EvaluationResult.ok(result)


func _evaluate_member_access(node: ExpressionParserScript.MemberAccessNode) -> EvaluationResult:
	var object_result = _evaluate_node(node.object)
	if not object_result.success:
		return object_result

	var obj = object_result.value

	if obj is Dictionary:
		if obj.has(node.member):
			return EvaluationResult.ok(obj[node.member])
		elif _strict_mode:
			return EvaluationResult.err(
				"Dictionary has no key: %s" % node.member,
				node.position
			)
		return EvaluationResult.ok(null)

	elif obj is Object:
		if node.member in obj:
			return EvaluationResult.ok(obj.get(node.member))
		elif _strict_mode:
			return EvaluationResult.err(
				"Object has no property: %s" % node.member,
				node.position
			)
		return EvaluationResult.ok(null)

	elif _strict_mode:
		return EvaluationResult.err(
			"Cannot access member '%s' on %s" % [node.member, typeof(obj)],
			node.position
		)

	return EvaluationResult.ok(null)


func _evaluate_index_access(node: ExpressionParserScript.IndexAccessNode) -> EvaluationResult:
	var object_result = _evaluate_node(node.object)
	if not object_result.success:
		return object_result

	var index_result = _evaluate_node(node.index)
	if not index_result.success:
		return index_result

	var obj = object_result.value
	var index = index_result.value

	if obj is Array:
		var idx = int(index)
		if idx < 0 or idx >= obj.size():
			if _strict_mode:
				return EvaluationResult.err(
					"Array index out of bounds: %d" % idx,
					node.position
				)
			return EvaluationResult.ok(null)
		return EvaluationResult.ok(obj[idx])

	elif obj is Dictionary:
		if obj.has(index):
			return EvaluationResult.ok(obj[index])
		elif _strict_mode:
			return EvaluationResult.err(
				"Dictionary has no key: %s" % str(index),
				node.position
			)
		return EvaluationResult.ok(null)

	elif obj is String:
		var idx = int(index)
		if idx < 0 or idx >= obj.length():
			if _strict_mode:
				return EvaluationResult.err(
					"String index out of bounds: %d" % idx,
					node.position
				)
			return EvaluationResult.ok("")
		return EvaluationResult.ok(obj[idx])

	elif _strict_mode:
		return EvaluationResult.err(
			"Cannot index into %s" % typeof(obj),
			node.position
		)

	return EvaluationResult.ok(null)


# =============================================================================
# HELPER METHODS
# =============================================================================

## Resolve a dotted path in the context.
func _resolve_path(path: Array[String]) -> Variant:
	if path.is_empty():
		return null

	var current = _context.get(path[0])

	for i in range(1, path.size()):
		if current == null:
			return null

		var key = path[i]

		if current is Dictionary:
			current = current.get(key)
		elif current is Object:
			if key in current:
				current = current.get(key)
			else:
				return null
		else:
			return null

	return current


## Check if a path exists in the context.
func _context_has_path(path: Array[String]) -> bool:
	if path.is_empty():
		return false

	if not _context.has(path[0]):
		return false

	var current = _context.get(path[0])

	for i in range(1, path.size()):
		if current == null:
			return false

		var key = path[i]

		if current is Dictionary:
			if not current.has(key):
				return false
			current = current.get(key)
		elif current is Object:
			if not (key in current):
				return false
			current = current.get(key)
		else:
			return false

	return true


## Type coercion: convert to boolean.
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


## Type coercion: convert to number.
func _to_number(value: Variant) -> float:
	if value is int or value is float:
		return float(value)
	if value is bool:
		return 1.0 if value else 0.0
	if value is String:
		if value.is_valid_float():
			return value.to_float()
		if value.is_valid_int():
			return float(value.to_int())
		return 0.0
	return 0.0


## Type coercion: convert to string.
func _to_string_value(value: Variant) -> String:
	if value is String:
		return value
	return str(value)


## Equality comparison with type coercion.
func _equals(left: Variant, right: Variant) -> bool:
	# Same type: direct comparison
	if typeof(left) == typeof(right):
		return left == right

	# Null comparisons
	if left == null or right == null:
		return left == right

	# Number comparisons (int/float)
	if (left is int or left is float) and (right is int or right is float):
		return float(left) == float(right)

	# Boolean comparisons
	if left is bool or right is bool:
		return _to_bool(left) == _to_bool(right)

	# String comparisons
	if left is String or right is String:
		return _to_string_value(left) == _to_string_value(right)

	return left == right


## Comparison with type coercion.
func _compare(left: Variant, right: Variant, op: Callable, position: int) -> EvaluationResult:
	# Try numeric comparison first
	if (left is int or left is float or left is String) and (right is int or right is float or right is String):
		var left_num = _to_number(left)
		var right_num = _to_number(right)
		return EvaluationResult.ok(op.call(left_num, right_num))

	# String comparison
	if left is String and right is String:
		return EvaluationResult.ok(op.call(left, right))

	# Fallback: try direct comparison
	return EvaluationResult.ok(op.call(left, right))


## Arithmetic with type coercion.
func _arithmetic(left: Variant, right: Variant, op: Callable, position: int, op_name: String) -> EvaluationResult:
	# String concatenation for +
	if op_name == "+" and (left is String or right is String):
		return EvaluationResult.ok(_to_string_value(left) + _to_string_value(right))

	# Numeric operation
	var left_num = _to_number(left)
	var right_num = _to_number(right)
	return EvaluationResult.ok(op.call(left_num, right_num))


# =============================================================================
# BUILT-IN FUNCTIONS
# =============================================================================

func _register_builtin_functions() -> void:
	# Inventory functions
	register_function("has_item", _builtin_has_item)
	register_function("count", _builtin_count)
	register_function("count_items", _builtin_count)  # Alias

	# Flag/state functions
	register_function("has_flag", _builtin_has_flag)
	register_function("get_flag", _builtin_get_flag)
	register_function("quest_state", _builtin_quest_state)
	register_function("quest_complete", _builtin_quest_complete)

	# Utility functions
	register_function("random", _builtin_random)
	register_function("random_int", _builtin_random_int)
	register_function("min", _builtin_min)
	register_function("max", _builtin_max)
	register_function("abs", _builtin_abs)
	register_function("clamp", _builtin_clamp)
	register_function("floor", _builtin_floor)
	register_function("ceil", _builtin_ceil)
	register_function("round", _builtin_round)

	# String functions
	register_function("len", _builtin_len)
	register_function("upper", _builtin_upper)
	register_function("lower", _builtin_lower)

	# Type checking
	register_function("is_number", _builtin_is_number)
	register_function("is_string", _builtin_is_string)
	register_function("is_bool", _builtin_is_bool)


## has_item(item_id) - Check if player has item in inventory.
func _builtin_has_item(args: Array) -> Variant:
	if args.is_empty():
		return false
	var item_id = str(args[0])

	# Check inventory in context
	var inventory = _context.get("inventory", [])
	if inventory is Array:
		for item in inventory:
			if item is Dictionary and item.get("id") == item_id:
				return true
			elif item is String and item == item_id:
				return true
	elif inventory is Dictionary:
		return inventory.has(item_id) and inventory[item_id] > 0

	# Also check items dict directly
	var items = _context.get("items", {})
	if items is Dictionary:
		return items.has(item_id) and items[item_id] > 0

	return false


## count(item_id) - Get quantity of item in inventory.
func _builtin_count(args: Array) -> Variant:
	if args.is_empty():
		return 0
	var item_id = str(args[0])

	# Check inventory in context
	var inventory = _context.get("inventory", [])
	if inventory is Array:
		var count = 0
		for item in inventory:
			if item is Dictionary:
				if item.get("id") == item_id:
					count += item.get("quantity", 1)
			elif item is String and item == item_id:
				count += 1
		return count
	elif inventory is Dictionary:
		return inventory.get(item_id, 0)

	# Also check items dict directly
	var items = _context.get("items", {})
	if items is Dictionary:
		return items.get(item_id, 0)

	return 0


## has_flag(flag_name) - Check if a flag is set and truthy.
func _builtin_has_flag(args: Array) -> Variant:
	if args.is_empty():
		return false
	var flag_name = str(args[0])

	# Check flags dict in context
	var flags = _context.get("flags", {})
	if flags is Dictionary:
		return flags.get(flag_name, false) == true

	# Also check top-level context
	return _context.get(flag_name, false) == true


## get_flag(flag_name, default) - Get flag value with optional default.
func _builtin_get_flag(args: Array) -> Variant:
	if args.is_empty():
		return null
	var flag_name = str(args[0])
	var default_value = args[1] if args.size() > 1 else null

	var flags = _context.get("flags", {})
	if flags is Dictionary:
		return flags.get(flag_name, default_value)

	return _context.get(flag_name, default_value)


## quest_state(quest_id) - Get quest state (not_started, active, complete, failed).
func _builtin_quest_state(args: Array) -> Variant:
	if args.is_empty():
		return "not_started"
	var quest_id = str(args[0])

	var quests = _context.get("quests", {})
	if quests is Dictionary:
		var quest = quests.get(quest_id, {})
		if quest is Dictionary:
			return quest.get("state", "not_started")
		return quest if quest is String else "not_started"

	return "not_started"


## quest_complete(quest_id) - Check if quest is complete.
func _builtin_quest_complete(args: Array) -> Variant:
	if args.is_empty():
		return false
	var state = _builtin_quest_state(args)
	return state == "complete" or state == "completed"


## random() - Random float between 0 and 1.
## random(max) - Random float between 0 and max.
## random(min, max) - Random float between min and max.
func _builtin_random(args: Array) -> Variant:
	if args.is_empty():
		return randf()
	elif args.size() == 1:
		return randf() * float(args[0])
	else:
		var min_val = float(args[0])
		var max_val = float(args[1])
		return min_val + randf() * (max_val - min_val)


## random_int(max) - Random integer from 0 to max-1.
## random_int(min, max) - Random integer from min to max (inclusive).
func _builtin_random_int(args: Array) -> Variant:
	if args.is_empty():
		return randi() % 100
	elif args.size() == 1:
		return randi() % int(args[0])
	else:
		var min_val = int(args[0])
		var max_val = int(args[1])
		return min_val + randi() % (max_val - min_val + 1)


## min(a, b) - Return smaller value.
func _builtin_min(args: Array) -> Variant:
	if args.size() < 2:
		return args[0] if not args.is_empty() else 0
	return min(float(args[0]), float(args[1]))


## max(a, b) - Return larger value.
func _builtin_max(args: Array) -> Variant:
	if args.size() < 2:
		return args[0] if not args.is_empty() else 0
	return max(float(args[0]), float(args[1]))


## abs(x) - Absolute value.
func _builtin_abs(args: Array) -> Variant:
	if args.is_empty():
		return 0
	return abs(float(args[0]))


## clamp(value, min, max) - Clamp value to range.
func _builtin_clamp(args: Array) -> Variant:
	if args.size() < 3:
		return args[0] if not args.is_empty() else 0
	return clamp(float(args[0]), float(args[1]), float(args[2]))


## floor(x) - Round down.
func _builtin_floor(args: Array) -> Variant:
	if args.is_empty():
		return 0
	return floor(float(args[0]))


## ceil(x) - Round up.
func _builtin_ceil(args: Array) -> Variant:
	if args.is_empty():
		return 0
	return ceil(float(args[0]))


## round(x) - Round to nearest.
func _builtin_round(args: Array) -> Variant:
	if args.is_empty():
		return 0
	return round(float(args[0]))


## len(x) - Get length of string or array.
func _builtin_len(args: Array) -> Variant:
	if args.is_empty():
		return 0
	var val = args[0]
	if val is String:
		return val.length()
	if val is Array:
		return val.size()
	if val is Dictionary:
		return val.size()
	return 0


## upper(str) - Convert string to uppercase.
func _builtin_upper(args: Array) -> Variant:
	if args.is_empty():
		return ""
	return str(args[0]).to_upper()


## lower(str) - Convert string to lowercase.
func _builtin_lower(args: Array) -> Variant:
	if args.is_empty():
		return ""
	return str(args[0]).to_lower()


## is_number(x) - Check if value is a number.
func _builtin_is_number(args: Array) -> Variant:
	if args.is_empty():
		return false
	return args[0] is int or args[0] is float


## is_string(x) - Check if value is a string.
func _builtin_is_string(args: Array) -> Variant:
	if args.is_empty():
		return false
	return args[0] is String


## is_bool(x) - Check if value is a boolean.
func _builtin_is_bool(args: Array) -> Variant:
	if args.is_empty():
		return false
	return args[0] is bool


# =============================================================================
# STATIC CONVENIENCE METHODS
# =============================================================================

## Evaluate an expression string with a context.
static func eval(expression: String, context: Dictionary = {}) -> Variant:
	var evaluator = ExpressionEvaluator.new()
	evaluator.set_context(context)
	var result = evaluator.evaluate_string(expression)
	if result.success:
		return result.value
	push_error("Expression evaluation failed: %s" % result.error)
	return null


## Check if an expression evaluates to true.
static func check(expression: String, context: Dictionary = {}) -> bool:
	var evaluator = ExpressionEvaluator.new()
	evaluator.set_context(context)
	var result = evaluator.evaluate_string(expression)
	if result.success:
		return evaluator._to_bool(result.value)
	return false
