@tool
class_name VariableBrowserPanel
extends VBoxContainer
## Panel showing all variables used across the dialogue tree.
## Displays variables in categorized lists with test value editing.

# Lazy-loaded to avoid blocking compilation if lexer has issues
var _expression_lexer_script: GDScript = null

signal variable_selected(variable_name: String, node_names: Array)
signal test_value_changed(variable_name: String, value: Variant)

# =============================================================================
# UI COMPONENTS
# =============================================================================

var _header_bar: HBoxContainer
var _collapse_button: Button
var _title_label: Label
var _refresh_button: Button

var _content_container: VBoxContainer
var _variable_tree: Tree
var _tree_root: TreeItem

# Category items
var _flags_category: TreeItem
var _items_category: TreeItem
var _quests_category: TreeItem
var _player_category: TreeItem
var _custom_category: TreeItem

# =============================================================================
# STATE
# =============================================================================

var _is_collapsed: bool = false
var _variables: Dictionary = {}  # variable_name -> {category, nodes, test_value}
var _graph_edit: GraphEdit  # Reference to main canvas

# Known variable patterns for categorization
const BUILTIN_CATEGORIES = {
	"has_flag": "flags",
	"has_item": "items",
	"count": "items",
	"quest_state": "quests",
	"quest_complete": "quests",
	"player": "player",
	"reputation": "player",
	"gold": "player",
	"level": "player"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

func _ready() -> void:
	_setup_ui()
	custom_minimum_size = Vector2(0, 350)
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func _setup_ui() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Header bar with collapse toggle
	_header_bar = HBoxContainer.new()
	_header_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_header_bar)

	_collapse_button = Button.new()
	_collapse_button.text = "▼"
	_collapse_button.flat = true
	_collapse_button.custom_minimum_size = Vector2(24, 24)
	_collapse_button.tooltip_text = "Collapse/Expand variable browser"
	_collapse_button.pressed.connect(_on_collapse_pressed)
	_header_bar.add_child(_collapse_button)

	_title_label = Label.new()
	_title_label.text = "Variables"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header_bar.add_child(_title_label)

	_refresh_button = Button.new()
	_refresh_button.text = "⟳"
	_refresh_button.flat = true
	_refresh_button.custom_minimum_size = Vector2(24, 24)
	_refresh_button.tooltip_text = "Refresh variable list"
	_refresh_button.pressed.connect(_on_refresh_pressed)
	_header_bar.add_child(_refresh_button)

	# Separator
	var separator = HSeparator.new()
	add_child(separator)

	# Content container (collapsible)
	_content_container = VBoxContainer.new()
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_content_container)

	# Variable tree
	_variable_tree = Tree.new()
	_variable_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_variable_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_variable_tree.hide_root = true
	_variable_tree.columns = 3
	_variable_tree.set_column_title(0, "Variable")
	_variable_tree.set_column_title(1, "Used In")
	_variable_tree.set_column_title(2, "Test Value")
	_variable_tree.set_column_titles_visible(true)
	_variable_tree.set_column_expand(0, true)
	_variable_tree.set_column_expand(1, true)
	_variable_tree.set_column_expand(2, false)
	_variable_tree.set_column_custom_minimum_width(2, 100)
	_variable_tree.item_selected.connect(_on_item_selected)
	_variable_tree.item_edited.connect(_on_item_edited)
	_content_container.add_child(_variable_tree)

	_setup_tree_categories()


func _setup_tree_categories() -> void:
	_tree_root = _variable_tree.create_item()

	_flags_category = _variable_tree.create_item(_tree_root)
	_flags_category.set_text(0, "🚩 Flags")
	_flags_category.set_selectable(0, false)
	_flags_category.set_selectable(1, false)
	_flags_category.set_selectable(2, false)

	_items_category = _variable_tree.create_item(_tree_root)
	_items_category.set_text(0, "📦 Items")
	_items_category.set_selectable(0, false)
	_items_category.set_selectable(1, false)
	_items_category.set_selectable(2, false)

	_quests_category = _variable_tree.create_item(_tree_root)
	_quests_category.set_text(0, "📜 Quests")
	_quests_category.set_selectable(0, false)
	_quests_category.set_selectable(1, false)
	_quests_category.set_selectable(2, false)

	_player_category = _variable_tree.create_item(_tree_root)
	_player_category.set_text(0, "👤 Player")
	_player_category.set_selectable(0, false)
	_player_category.set_selectable(1, false)
	_player_category.set_selectable(2, false)

	_custom_category = _variable_tree.create_item(_tree_root)
	_custom_category.set_text(0, "📝 Custom")
	_custom_category.set_selectable(0, false)
	_custom_category.set_selectable(1, false)
	_custom_category.set_selectable(2, false)


# =============================================================================
# PUBLIC API
# =============================================================================

## Set the GraphEdit reference for scanning nodes.
func set_graph_edit(graph: GraphEdit) -> void:
	_graph_edit = graph


## Scan all nodes and update the variable list.
func scan_variables() -> void:
	_variables.clear()

	if not _graph_edit:
		_rebuild_tree()
		return

	# Scan all GraphNode children
	for child in _graph_edit.get_children():
		if child is GraphNode:
			_scan_node(child)

	_rebuild_tree()
	_update_title()


## Get all test values as a dictionary.
func get_test_values() -> Dictionary:
	var values = {}
	for var_name in _variables:
		var var_data = _variables[var_name]
		if var_data.has("test_value"):
			values[var_name] = var_data.test_value
	return values


## Set test values from a dictionary.
func set_test_values(values: Dictionary) -> void:
	for var_name in values:
		if _variables.has(var_name):
			_variables[var_name].test_value = values[var_name]
	_rebuild_tree()


## Toggle collapsed state.
func set_collapsed(collapsed: bool) -> void:
	_is_collapsed = collapsed
	_content_container.visible = not _is_collapsed
	_collapse_button.text = "▶" if _is_collapsed else "▼"

	if _is_collapsed:
		custom_minimum_size = Vector2(0, 30)
	else:
		custom_minimum_size = Vector2(0, 350)


## Get collapsed state.
func is_collapsed() -> bool:
	return _is_collapsed


# =============================================================================
# NODE SCANNING
# =============================================================================

func _scan_node(node: GraphNode) -> void:
	var node_name = node.name

	# Check if node has serialization method
	if node.has_method("serialize"):
		var data = node.serialize()
		_scan_data_for_variables(data, node_name)


func _scan_data_for_variables(data: Dictionary, node_name: String) -> void:
	# Scan expression field
	if data.has("expression"):
		_extract_variables_from_expression(data.expression, node_name)

	# Scan simple conditions (Branch node)
	if data.has("conditions"):
		for cond in data.conditions:
			if cond.has("variable"):
				_add_variable(cond.variable, node_name, _guess_category(cond.variable))

	# Scan choices (Choice node)
	if data.has("choices"):
		for choice in data.choices:
			if choice.has("condition") and choice.condition is String and not choice.condition.is_empty():
				_extract_variables_from_expression(choice.condition, node_name)

	# Scan set operations
	if data.has("operations"):
		for op in data.operations:
			if op.has("variable"):
				_add_variable(op.variable, node_name, _guess_category(op.variable))


func _extract_variables_from_expression(expression: String, node_name: String) -> void:
	if expression.is_empty():
		return

	# Lazy load lexer to avoid blocking compilation
	if _expression_lexer_script == null:
		_expression_lexer_script = load("res://addons/dialogue_editor/scripts/expressions/expression_lexer.gd")

	if _expression_lexer_script == null:
		# Lexer unavailable, skip expression parsing
		return

	# Use lexer to tokenize
	var lexer = _expression_lexer_script.new()
	var tokens_result = lexer.tokenize(expression)
	if tokens_result == null or not tokens_result.success:
		return
	var tokens = tokens_result.tokens

	var i = 0
	while i < tokens.size():
		var token = tokens[i]
		var token_type_name = token.get_type_name() if token.has_method("get_type_name") else ""

		# Check for function calls like has_flag("name")
		if token_type_name == "IDENTIFIER" and i + 1 < tokens.size():
			var func_name = token.value
			var next_token = tokens[i + 1]
			var next_type_name = next_token.get_type_name() if next_token.has_method("get_type_name") else ""

			if next_type_name == "LPAREN":
				# This is a function call - find the argument
				if i + 2 < tokens.size():
					var arg_token = tokens[i + 2]
					var arg_type_name = arg_token.get_type_name() if arg_token.has_method("get_type_name") else ""
					if arg_type_name == "STRING":
						var category = BUILTIN_CATEGORIES.get(func_name, "custom")
						var var_name = func_name + "(\"" + str(arg_token.value) + "\")"
						_add_variable(var_name, node_name, category)
			else:
				# Regular variable
				var category = _guess_category(func_name)
				_add_variable(func_name, node_name, category)
		elif token_type_name == "IDENTIFIER":
			# Standalone variable
			var category = _guess_category(str(token.value))
			_add_variable(str(token.value), node_name, category)

		i += 1


func _add_variable(var_name: String, node_name: String, category: String) -> void:
	if not _variables.has(var_name):
		_variables[var_name] = {
			"category": category,
			"nodes": [],
			"test_value": _get_default_value(category)
		}

	if not node_name in _variables[var_name].nodes:
		_variables[var_name].nodes.append(node_name)


func _guess_category(var_name: String) -> String:
	# Check known patterns
	if var_name in BUILTIN_CATEGORIES:
		return BUILTIN_CATEGORIES[var_name]

	# Check prefixes
	if var_name.begins_with("flag_") or var_name.ends_with("_flag"):
		return "flags"
	if var_name.begins_with("item_") or var_name.ends_with("_item"):
		return "items"
	if var_name.begins_with("quest_") or var_name.ends_with("_quest"):
		return "quests"
	if var_name.begins_with("player."):
		return "player"
	if var_name in ["reputation", "gold", "level", "health", "mana"]:
		return "player"

	return "custom"


func _get_default_value(category: String) -> Variant:
	match category:
		"flags":
			return false
		"items":
			return 0
		"quests":
			return "not_started"
		"player":
			return 0
		_:
			return ""


# =============================================================================
# TREE BUILDING
# =============================================================================

func _rebuild_tree() -> void:
	# Clear existing items (keep categories)
	_clear_category_children(_flags_category)
	_clear_category_children(_items_category)
	_clear_category_children(_quests_category)
	_clear_category_children(_player_category)
	_clear_category_children(_custom_category)

	# Add variables to appropriate categories
	for var_name in _variables:
		var var_data = _variables[var_name]
		var category_item = _get_category_item(var_data.category)

		if category_item:
			_add_variable_item(category_item, var_name, var_data)

	# Collapse empty categories
	_flags_category.collapsed = _flags_category.get_child_count() == 0
	_items_category.collapsed = _items_category.get_child_count() == 0
	_quests_category.collapsed = _quests_category.get_child_count() == 0
	_player_category.collapsed = _player_category.get_child_count() == 0
	_custom_category.collapsed = _custom_category.get_child_count() == 0


func _clear_category_children(category: TreeItem) -> void:
	var child = category.get_first_child()
	while child:
		var next = child.get_next()
		category.remove_child(child)
		child.free()
		child = next


func _get_category_item(category: String) -> TreeItem:
	match category:
		"flags":
			return _flags_category
		"items":
			return _items_category
		"quests":
			return _quests_category
		"player":
			return _player_category
		_:
			return _custom_category


func _add_variable_item(parent: TreeItem, var_name: String, var_data: Dictionary) -> void:
	var item = _variable_tree.create_item(parent)

	# Column 0: Variable name
	item.set_text(0, var_name)
	item.set_tooltip_text(0, var_name)
	item.set_metadata(0, var_name)

	# Column 1: Used in (node count)
	var node_count = var_data.nodes.size()
	var used_text = "%d node%s" % [node_count, "s" if node_count != 1 else ""]
	item.set_text(1, used_text)
	item.set_tooltip_text(1, ", ".join(var_data.nodes))
	item.set_metadata(1, var_data.nodes)

	# Column 2: Test value (editable)
	var test_value = var_data.get("test_value", "")
	item.set_text(2, str(test_value))
	item.set_editable(2, true)
	item.set_metadata(2, test_value)


func _update_title() -> void:
	var count = _variables.size()
	_title_label.text = "Variables (%d)" % count


# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_collapse_pressed() -> void:
	set_collapsed(not _is_collapsed)


func _on_refresh_pressed() -> void:
	scan_variables()


func _on_item_selected() -> void:
	var selected = _variable_tree.get_selected()
	if selected:
		var var_name = selected.get_metadata(0)
		var nodes = selected.get_metadata(1)
		if var_name and nodes:
			variable_selected.emit(var_name, nodes)


func _on_item_edited() -> void:
	var selected = _variable_tree.get_selected()
	if selected:
		var var_name = selected.get_metadata(0)
		var new_value_str = selected.get_text(2)

		# Parse value based on category
		var var_data = _variables.get(var_name, {})
		var category = var_data.get("category", "custom")
		var new_value = _parse_value(new_value_str, category)

		# Update stored value
		if _variables.has(var_name):
			_variables[var_name].test_value = new_value

		selected.set_metadata(2, new_value)
		test_value_changed.emit(var_name, new_value)


func _parse_value(value_str: String, category: String) -> Variant:
	match category:
		"flags":
			return value_str.to_lower() in ["true", "1", "yes", "on"]
		"items", "player":
			if value_str.is_valid_int():
				return value_str.to_int()
			if value_str.is_valid_float():
				return value_str.to_float()
			return 0
		_:
			return value_str
