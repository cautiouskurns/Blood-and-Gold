@tool
class_name ExpressionEditor
extends VBoxContainer
## Rich text editor for dialogue expressions with syntax highlighting,
## real-time validation, autocomplete, and testing capabilities.

# Lazy-loaded to avoid @tool compilation issues with inner class types
var _lexer_script: GDScript = null
var _parser_script: GDScript = null
var _evaluator_script: GDScript = null
var _context_script: GDScript = null

func _get_lexer_script() -> GDScript:
	if _lexer_script == null:
		_lexer_script = load("res://addons/dialogue_editor/scripts/expressions/expression_lexer.gd")
	return _lexer_script

func _get_parser_script() -> GDScript:
	if _parser_script == null:
		_parser_script = load("res://addons/dialogue_editor/scripts/expressions/expression_parser.gd")
	return _parser_script

func _get_evaluator_script() -> GDScript:
	if _evaluator_script == null:
		_evaluator_script = load("res://addons/dialogue_editor/scripts/expressions/expression_evaluator.gd")
	return _evaluator_script

func _get_context_script() -> GDScript:
	if _context_script == null:
		_context_script = load("res://addons/dialogue_editor/scripts/expressions/expression_context.gd")
	return _context_script

# Token type constant (mirrors ExpressionLexer.TokenType.IDENTIFIER)
const TT_IDENTIFIER = 3

signal expression_changed(expression: String)
signal validation_changed(is_valid: bool, error: String)

# =============================================================================
# CONFIGURATION
# =============================================================================

## Delay before validating after typing stops (ms).
@export var validation_delay_ms: int = 300

## Show line numbers.
@export var show_line_numbers: bool = false

## Show the test panel.
@export var show_test_panel: bool = true

## Placeholder text when empty.
@export var placeholder_text: String = "Enter expression..."

## Known variables for autocomplete.
var known_variables: Array[String] = []

## Test context for evaluation.
var test_context: ExpressionContext

# =============================================================================
# UI COMPONENTS
# =============================================================================

var _code_edit: CodeEdit
var _status_container: HBoxContainer
var _status_icon: TextureRect
var _status_label: Label
var _error_tooltip: String = ""

var _autocomplete_popup: PopupMenu
var _autocomplete_items: Array[Dictionary] = []

var _test_panel: VBoxContainer
var _test_result_label: Label
var _test_variables_container: VBoxContainer

var _validation_timer: Timer
var _last_expression: String = ""
var _is_valid: bool = true
var _parse_error: String = ""

# =============================================================================
# BUILT-IN FUNCTION SIGNATURES
# =============================================================================

const BUILTIN_FUNCTIONS: Array[Dictionary] = [
	{"name": "has_item", "signature": "has_item(item_id)", "description": "Check if player has item"},
	{"name": "count", "signature": "count(item_id)", "description": "Get item quantity"},
	{"name": "has_flag", "signature": "has_flag(flag_name)", "description": "Check if flag is set"},
	{"name": "get_flag", "signature": "get_flag(flag_name, default)", "description": "Get flag value"},
	{"name": "quest_state", "signature": "quest_state(quest_id)", "description": "Get quest state"},
	{"name": "quest_complete", "signature": "quest_complete(quest_id)", "description": "Check if quest complete"},
	{"name": "random", "signature": "random() / random(max) / random(min, max)", "description": "Random float"},
	{"name": "random_int", "signature": "random_int(max) / random_int(min, max)", "description": "Random integer"},
	{"name": "min", "signature": "min(a, b)", "description": "Minimum of two values"},
	{"name": "max", "signature": "max(a, b)", "description": "Maximum of two values"},
	{"name": "abs", "signature": "abs(x)", "description": "Absolute value"},
	{"name": "clamp", "signature": "clamp(value, min, max)", "description": "Clamp to range"},
	{"name": "floor", "signature": "floor(x)", "description": "Round down"},
	{"name": "ceil", "signature": "ceil(x)", "description": "Round up"},
	{"name": "round", "signature": "round(x)", "description": "Round to nearest"},
	{"name": "len", "signature": "len(x)", "description": "Length of string/array"},
	{"name": "upper", "signature": "upper(str)", "description": "Convert to uppercase"},
	{"name": "lower", "signature": "lower(str)", "description": "Convert to lowercase"},
]

const KEYWORDS: Array[String] = ["and", "or", "not", "true", "false"]

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	_setup_ui()
	_setup_syntax_highlighting()
	_setup_validation_timer()
	_setup_autocomplete()

	if show_test_panel:
		_setup_test_panel()

	# Initialize test context
	var ContextScript = _get_context_script()
	if ContextScript:
		test_context = ContextScript.create_default()


func _setup_ui() -> void:
	# Main code editor
	_code_edit = CodeEdit.new()
	_code_edit.custom_minimum_size = Vector2(200, 60)
	_code_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_code_edit.gutters_draw_line_numbers = show_line_numbers
	_code_edit.scroll_fit_content_height = true
	_code_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_code_edit.placeholder_text = placeholder_text
	_code_edit.caret_blink = true
	_code_edit.highlight_current_line = true
	_code_edit.draw_tabs = false
	_code_edit.draw_spaces = false
	_code_edit.minimap_draw = false
	_code_edit.code_completion_enabled = true
	_code_edit.auto_brace_completion_enabled = true

	_code_edit.text_changed.connect(_on_text_changed)
	_code_edit.code_completion_requested.connect(_on_code_completion_requested)
	_code_edit.gui_input.connect(_on_code_edit_gui_input)

	add_child(_code_edit)

	# Status bar
	_status_container = HBoxContainer.new()
	_status_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_status_icon = TextureRect.new()
	_status_icon.custom_minimum_size = Vector2(16, 16)
	_status_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_status_container.add_child(_status_icon)

	_status_label = Label.new()
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.add_theme_font_size_override("font_size", 12)
	_status_container.add_child(_status_label)

	add_child(_status_container)

	_update_status_display()


func _setup_syntax_highlighting() -> void:
	var highlighter = CodeHighlighter.new()

	# Colors
	var keyword_color = Color("#ff7085")      # Pink for keywords
	var function_color = Color("#66d9ef")     # Cyan for functions
	var string_color = Color("#a6e22e")       # Green for strings
	var number_color = Color("#ae81ff")       # Purple for numbers
	var operator_color = Color("#f8f8f2")     # White for operators
	var comment_color = Color("#75715e")      # Gray for comments
	var symbol_color = Color("#f8f8f2")       # White for symbols

	highlighter.number_color = number_color
	highlighter.symbol_color = symbol_color
	highlighter.function_color = function_color
	highlighter.member_variable_color = Color("#fd971f")  # Orange for variables

	# Keywords
	for keyword in KEYWORDS:
		highlighter.add_keyword_color(keyword, keyword_color)

	# Built-in functions
	for func_info in BUILTIN_FUNCTIONS:
		highlighter.add_keyword_color(func_info.name, function_color)

	# String regions
	highlighter.add_color_region('"', '"', string_color)
	highlighter.add_color_region("'", "'", string_color)

	# Comments
	highlighter.add_color_region("#", "", comment_color, true)  # Line comment
	highlighter.add_color_region("//", "", comment_color, true)  # C-style line comment

	_code_edit.syntax_highlighter = highlighter


func _setup_validation_timer() -> void:
	_validation_timer = Timer.new()
	_validation_timer.one_shot = true
	_validation_timer.wait_time = validation_delay_ms / 1000.0
	_validation_timer.timeout.connect(_validate_expression)
	add_child(_validation_timer)


func _setup_autocomplete() -> void:
	_autocomplete_popup = PopupMenu.new()
	_autocomplete_popup.id_pressed.connect(_on_autocomplete_selected)
	add_child(_autocomplete_popup)


func _setup_test_panel() -> void:
	# Separator
	var separator = HSeparator.new()
	add_child(separator)

	_test_panel = VBoxContainer.new()

	# Header with test button
	var header = HBoxContainer.new()

	var test_label = Label.new()
	test_label.text = "Test Expression"
	test_label.add_theme_font_size_override("font_size", 12)
	test_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(test_label)

	var test_button = Button.new()
	test_button.text = "Evaluate"
	test_button.pressed.connect(_on_test_button_pressed)
	header.add_child(test_button)

	_test_panel.add_child(header)

	# Variables container (scrollable)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 60)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_test_variables_container = VBoxContainer.new()
	_test_variables_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_test_variables_container)

	_test_panel.add_child(scroll)

	# Result display
	var result_container = HBoxContainer.new()

	var result_prefix = Label.new()
	result_prefix.text = "Result: "
	result_prefix.add_theme_font_size_override("font_size", 12)
	result_container.add_child(result_prefix)

	_test_result_label = Label.new()
	_test_result_label.text = "-"
	_test_result_label.add_theme_font_size_override("font_size", 12)
	_test_result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_container.add_child(_test_result_label)

	_test_panel.add_child(result_container)

	add_child(_test_panel)
	_test_panel.visible = show_test_panel


# =============================================================================
# PUBLIC API
# =============================================================================

## Get the current expression text.
func get_expression() -> String:
	return _code_edit.text


## Set the expression text.
func set_expression(expression: String) -> void:
	_code_edit.text = expression
	_validate_expression()


## Check if the current expression is valid.
func is_valid() -> bool:
	return _is_valid


## Get the current parse error (empty if valid).
func get_error() -> String:
	return _parse_error


## Set known variables for autocomplete.
func set_known_variables(variables: Array[String]) -> void:
	known_variables = variables


## Add a known variable for autocomplete.
func add_known_variable(variable: String) -> void:
	if variable not in known_variables:
		known_variables.append(variable)


## Set the test context.
func set_test_context(context: ExpressionContext) -> void:
	test_context = context
	_update_test_variables_ui()


## Focus the editor.
func focus() -> void:
	_code_edit.grab_focus()


## Set whether test panel is visible.
func set_test_panel_visible(visible: bool) -> void:
	show_test_panel = visible
	if _test_panel:
		_test_panel.visible = visible


# =============================================================================
# VALIDATION
# =============================================================================

func _on_text_changed() -> void:
	var expression = _code_edit.text

	# Reset timer on each change
	_validation_timer.stop()
	_validation_timer.start()

	# Emit change signal
	if expression != _last_expression:
		_last_expression = expression
		expression_changed.emit(expression)


func _validate_expression() -> void:
	var expression = _code_edit.text.strip_edges()

	# Empty is valid (no condition)
	if expression.is_empty():
		_set_valid(true, "")
		return

	# Parse the expression
	var ParserScript = _get_parser_script()
	if ParserScript == null:
		_set_valid(false, "Parser not available")
		return
	var parser = ParserScript.new()
	var result = parser.parse(expression)

	if result.has_errors():
		var error = result.errors[0]
		_set_valid(false, error.message)
		_highlight_error(error.position, error.column)
	else:
		_set_valid(true, "")
		_clear_error_highlights()


func _set_valid(valid: bool, error: String) -> void:
	_is_valid = valid
	_parse_error = error
	_update_status_display()
	validation_changed.emit(valid, error)


func _update_status_display() -> void:
	if _is_valid:
		_status_label.text = "Valid"
		_status_label.add_theme_color_override("font_color", Color("#a6e22e"))
		_error_tooltip = ""
	else:
		_status_label.text = "Error: " + _parse_error
		_status_label.add_theme_color_override("font_color", Color("#f92672"))
		_error_tooltip = _parse_error

	# Update icon (using built-in editor icons if available)
	if Engine.is_editor_hint():
		var icon_name = "StatusSuccess" if _is_valid else "StatusError"
		if EditorInterface.get_editor_theme():
			_status_icon.texture = EditorInterface.get_editor_theme().get_icon(icon_name, "EditorIcons")


func _highlight_error(position: int, column: int) -> void:
	# CodeEdit doesn't have built-in error underlining like some IDEs,
	# but we can use the executing lines or breakpoint markers as visual indicators
	# For now, we rely on the status bar to show the error
	pass


func _clear_error_highlights() -> void:
	pass


# =============================================================================
# AUTOCOMPLETE
# =============================================================================

func _on_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Ctrl+Space to trigger autocomplete
		if event.ctrl_pressed and event.keycode == KEY_SPACE:
			_trigger_autocomplete()
			get_viewport().set_input_as_handled()


func _on_code_completion_requested() -> void:
	_trigger_autocomplete()


func _trigger_autocomplete() -> void:
	var caret_column = _code_edit.get_caret_column()
	var line = _code_edit.get_line(_code_edit.get_caret_line())

	# Get the word being typed
	var word_start = caret_column
	while word_start > 0 and _is_identifier_char(line[word_start - 1]):
		word_start -= 1

	var prefix = line.substr(word_start, caret_column - word_start)

	# Build completion items
	_autocomplete_items.clear()

	# Add keywords
	for keyword in KEYWORDS:
		if prefix.is_empty() or keyword.begins_with(prefix.to_lower()):
			_code_edit.add_code_completion_option(
				CodeEdit.KIND_PLAIN_TEXT,
				keyword,
				keyword,
				Color("#ff7085"),
				null,
				"keyword"
			)

	# Add built-in functions
	for func_info in BUILTIN_FUNCTIONS:
		if prefix.is_empty() or func_info.name.begins_with(prefix.to_lower()):
			_code_edit.add_code_completion_option(
				CodeEdit.KIND_FUNCTION,
				func_info.name + "()",
				func_info.name + "(",
				Color("#66d9ef"),
				null,
				func_info.description
			)

	# Add known variables
	for variable in known_variables:
		if prefix.is_empty() or variable.to_lower().begins_with(prefix.to_lower()):
			_code_edit.add_code_completion_option(
				CodeEdit.KIND_VARIABLE,
				variable,
				variable,
				Color("#fd971f"),
				null,
				"variable"
			)

	# Add common variable suggestions
	var common_vars = ["reputation", "gold", "player.level", "player.health"]
	for v in common_vars:
		if v not in known_variables and (prefix.is_empty() or v.to_lower().begins_with(prefix.to_lower())):
			_code_edit.add_code_completion_option(
				CodeEdit.KIND_VARIABLE,
				v,
				v,
				Color("#fd971f").darkened(0.2),
				null,
				"common variable"
			)

	_code_edit.update_code_completion_options(true)


func _on_autocomplete_selected(id: int) -> void:
	if id >= 0 and id < _autocomplete_items.size():
		var item = _autocomplete_items[id]
		_insert_completion(item.insert_text)


func _insert_completion(text: String) -> void:
	var caret_column = _code_edit.get_caret_column()
	var line = _code_edit.get_line(_code_edit.get_caret_line())

	# Find word start
	var word_start = caret_column
	while word_start > 0 and _is_identifier_char(line[word_start - 1]):
		word_start -= 1

	# Replace the word with completion
	_code_edit.select(
		_code_edit.get_caret_line(), word_start,
		_code_edit.get_caret_line(), caret_column
	)
	_code_edit.insert_text_at_caret(text)


func _is_identifier_char(c: String) -> bool:
	return c.is_valid_identifier() or c == "_" or c == "."


# =============================================================================
# TEST PANEL
# =============================================================================

func _on_test_button_pressed() -> void:
	_evaluate_test_expression()


func _evaluate_test_expression() -> void:
	var expression = _code_edit.text.strip_edges()

	if expression.is_empty():
		_test_result_label.text = "(empty)"
		_test_result_label.add_theme_color_override("font_color", Color.GRAY)
		return

	if not _is_valid:
		_test_result_label.text = "Invalid expression"
		_test_result_label.add_theme_color_override("font_color", Color("#f92672"))
		return

	# Collect test values from UI
	_collect_test_values()

	# Evaluate
	var result = test_context.evaluate(expression)

	if result.success:
		_test_result_label.text = str(result.value)
		if result.value is bool:
			var color = Color("#a6e22e") if result.value else Color("#f92672")
			_test_result_label.add_theme_color_override("font_color", color)
		else:
			_test_result_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		_test_result_label.text = "Error: " + result.error
		_test_result_label.add_theme_color_override("font_color", Color("#f92672"))


func _update_test_variables_ui() -> void:
	if not _test_variables_container:
		return

	# Clear existing
	for child in _test_variables_container.get_children():
		child.queue_free()

	# Extract variables from expression
	var variables = _extract_variables_from_expression()

	# Add UI for each variable
	for variable in variables:
		var row = _create_variable_row(variable)
		_test_variables_container.add_child(row)


func _extract_variables_from_expression() -> Array[String]:
	var expression = _code_edit.text
	var variables: Array[String] = []

	# Use lexer to find identifiers
	var LexerScript = _get_lexer_script()
	if LexerScript == null:
		return variables
	var lexer = LexerScript.new()
	var result = lexer.tokenize(expression)

	if result.has_errors():
		return variables

	for token in result.tokens:
		if token.type == TT_IDENTIFIER:
			var name = str(token.value)
			# Skip function names (followed by parenthesis)
			var is_function = false
			for func_info in BUILTIN_FUNCTIONS:
				if func_info.name == name:
					is_function = true
					break

			if not is_function and name not in variables:
				variables.append(name)

	return variables


func _create_variable_row(variable: String) -> HBoxContainer:
	var row = HBoxContainer.new()

	var label = Label.new()
	label.text = variable + ":"
	label.custom_minimum_size = Vector2(100, 0)
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)

	var input = LineEdit.new()
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.placeholder_text = "value"
	input.name = "var_" + variable

	# Set initial value from context
	var current_value = test_context.get_variable(variable)
	if current_value != null:
		input.text = str(current_value)

	input.text_changed.connect(_on_test_variable_changed.bind(variable))
	row.add_child(input)

	return row


func _on_test_variable_changed(new_text: String, variable: String) -> void:
	# Try to parse as number, bool, or string
	var value: Variant

	if new_text.to_lower() == "true":
		value = true
	elif new_text.to_lower() == "false":
		value = false
	elif new_text.is_valid_int():
		value = new_text.to_int()
	elif new_text.is_valid_float():
		value = new_text.to_float()
	else:
		value = new_text

	test_context.set_variable(variable, value)


func _collect_test_values() -> void:
	# Update test context from UI inputs
	for child in _test_variables_container.get_children():
		if child is HBoxContainer:
			for subchild in child.get_children():
				if subchild is LineEdit and subchild.name.begins_with("var_"):
					var variable = subchild.name.substr(4)  # Remove "var_" prefix
					_on_test_variable_changed(subchild.text, variable)


# =============================================================================
# UTILITY
# =============================================================================

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_status_display()
