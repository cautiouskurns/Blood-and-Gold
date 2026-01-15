@tool
class_name ExpressionField
extends HBoxContainer
## Compact expression input field with validation indicator.
## Suitable for embedding in node UIs where space is limited.

const ExpressionLexerScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_lexer.gd")
const ExpressionParserScript = preload("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")

signal expression_changed(expression: String)
signal validation_changed(is_valid: bool, error: String)

# =============================================================================
# UI COMPONENTS
# =============================================================================

var _line_edit: LineEdit
var _status_button: Button
var _validation_timer: Timer

var _is_valid: bool = true
var _parse_error: String = ""
var _last_expression: String = ""

# =============================================================================
# CONFIGURATION
# =============================================================================

@export var placeholder_text: String = "expression..."
@export var validation_delay_ms: int = 200

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	_setup_ui()
	_setup_validation_timer()


func _setup_ui() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Line edit for expression
	_line_edit = LineEdit.new()
	_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_line_edit.placeholder_text = placeholder_text
	_line_edit.text_changed.connect(_on_text_changed)
	add_child(_line_edit)

	# Status button (shows valid/invalid, click for details)
	_status_button = Button.new()
	_status_button.custom_minimum_size = Vector2(24, 24)
	_status_button.flat = true
	_status_button.tooltip_text = "Expression valid"
	_status_button.pressed.connect(_on_status_pressed)
	add_child(_status_button)

	_update_status()


func _setup_validation_timer() -> void:
	_validation_timer = Timer.new()
	_validation_timer.one_shot = true
	_validation_timer.wait_time = validation_delay_ms / 1000.0
	_validation_timer.timeout.connect(_validate_expression)
	add_child(_validation_timer)


# =============================================================================
# PUBLIC API
# =============================================================================

## Get the current expression.
func get_expression() -> String:
	return _line_edit.text


## Set the expression.
func set_expression(expression: String) -> void:
	_line_edit.text = expression
	_validate_expression()


## Check if current expression is valid.
func is_valid() -> bool:
	return _is_valid


## Get the parse error (empty if valid).
func get_error() -> String:
	return _parse_error


## Focus the input.
func focus() -> void:
	_line_edit.grab_focus()


# =============================================================================
# VALIDATION
# =============================================================================

func _on_text_changed(new_text: String) -> void:
	_validation_timer.stop()
	_validation_timer.start()

	if new_text != _last_expression:
		_last_expression = new_text
		expression_changed.emit(new_text)


func _validate_expression() -> void:
	var expression = _line_edit.text.strip_edges()

	# Empty is valid
	if expression.is_empty():
		_set_valid(true, "")
		return

	# Parse
	var parser = ExpressionParserScript.new()
	var result = parser.parse(expression)

	if result.has_errors():
		_set_valid(false, result.errors[0].message)
	else:
		_set_valid(true, "")


func _set_valid(valid: bool, error: String) -> void:
	_is_valid = valid
	_parse_error = error
	_update_status()
	validation_changed.emit(valid, error)


func _update_status() -> void:
	if _is_valid:
		_status_button.text = "✓"
		_status_button.tooltip_text = "Expression valid"
		_status_button.add_theme_color_override("font_color", Color("#a6e22e"))
		_line_edit.remove_theme_color_override("font_color")
	else:
		_status_button.text = "✗"
		_status_button.tooltip_text = "Error: " + _parse_error
		_status_button.add_theme_color_override("font_color", Color("#f92672"))
		_line_edit.add_theme_color_override("font_color", Color("#f92672"))


func _on_status_pressed() -> void:
	if not _is_valid:
		# Show error in a tooltip-like popup
		print("Expression error: %s" % _parse_error)
