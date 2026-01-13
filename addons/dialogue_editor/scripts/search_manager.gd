@tool
class_name DialogueSearchManager
extends RefCounted
## Manages search and filter functionality for the dialogue canvas.
## Finds nodes by ID, speaker, text content, or type.

signal search_completed(results: Array[String], total: int)
signal result_selected(node_id: String, index: int, total: int)
signal filter_changed()

# Search modes
enum SearchField {
	ALL,        # Search all fields
	NODE_ID,    # Search by node ID
	SPEAKER,    # Search by speaker name
	TEXT,       # Search by dialogue text
	TYPE        # Search by node type
}

# Reference to canvas
var _canvas: GraphEdit = null

# Current search state
var _search_results: Array[String] = []
var _current_result_index: int = -1
var _last_search_query: String = ""
var _last_search_field: SearchField = SearchField.ALL

# Filter state
var _type_filter: String = ""  # Empty = show all
var _hidden_nodes: Array[String] = []  # Node IDs that are hidden by filter

# Highlighted nodes for search results
var _highlighted_nodes: Dictionary = {}  # node_id -> original_style


## Setup with canvas reference.
func setup(canvas: GraphEdit) -> void:
	_canvas = canvas


## Perform a search with the given query.
func search(query: String, field: SearchField = SearchField.ALL) -> void:
	if not _canvas:
		return

	_last_search_query = query
	_last_search_field = field
	_search_results.clear()
	_current_result_index = -1

	# Clear previous highlights
	_clear_all_highlights()

	if query.is_empty():
		search_completed.emit(_search_results, 0)
		return

	# Normalize query for case-insensitive search
	var normalized_query = query.to_lower()

	# Search through all nodes
	for child in _canvas.get_children():
		if child is GraphNode and child.has_method("serialize"):
			var node_data = child.serialize()
			var matches = _node_matches_query(child, node_data, normalized_query, field)
			if matches:
				_search_results.append(child.name)

	# Highlight all matching nodes
	for node_id in _search_results:
		_highlight_node(node_id, Color.YELLOW)

	search_completed.emit(_search_results, _search_results.size())

	# Auto-select first result if any
	if not _search_results.is_empty():
		go_to_result(0)


## Check if a node matches the search query.
func _node_matches_query(node: GraphNode, node_data: Dictionary, query: String, field: SearchField) -> bool:
	match field:
		SearchField.ALL:
			return _matches_any_field(node, node_data, query)
		SearchField.NODE_ID:
			return node.name.to_lower().contains(query)
		SearchField.SPEAKER:
			return node_data.get("speaker", "").to_lower().contains(query)
		SearchField.TEXT:
			return _matches_text_field(node_data, query)
		SearchField.TYPE:
			return node_data.get("type", "").to_lower().contains(query)

	return false


func _matches_any_field(node: GraphNode, node_data: Dictionary, query: String) -> bool:
	# Check node ID
	if node.name.to_lower().contains(query):
		return true

	# Check type
	if node_data.get("type", "").to_lower().contains(query):
		return true

	# Check speaker (for Speaker nodes)
	if node_data.get("speaker", "").to_lower().contains(query):
		return true

	# Check text content
	if _matches_text_field(node_data, query):
		return true

	return false


func _matches_text_field(node_data: Dictionary, query: String) -> bool:
	# Check dialogue text (Speaker nodes)
	if node_data.get("text", "").to_lower().contains(query):
		return true

	# Check choice text (Choice nodes)
	if node_data.get("choice_text", "").to_lower().contains(query):
		return true

	# Check condition key/value (Branch nodes)
	if node_data.get("condition_key", "").to_lower().contains(query):
		return true
	if node_data.get("condition_value", "").to_lower().contains(query):
		return true

	# Check flag name/value (Flag nodes)
	if node_data.get("flag_name", "").to_lower().contains(query):
		return true
	if node_data.get("flag_value", "").to_lower().contains(query):
		return true

	# Check quest ID (Quest nodes)
	if node_data.get("quest_id", "").to_lower().contains(query):
		return true

	# Check item ID (Item nodes)
	if node_data.get("item_id", "").to_lower().contains(query):
		return true

	# Check faction (Reputation nodes)
	if node_data.get("faction", "").to_lower().contains(query):
		return true
	if node_data.get("custom_faction", "").to_lower().contains(query):
		return true

	# Check skill (SkillCheck nodes)
	if node_data.get("skill", "").to_lower().contains(query):
		return true
	if node_data.get("custom_skill", "").to_lower().contains(query):
		return true

	return false


## Go to a specific result by index.
func go_to_result(index: int) -> void:
	if _search_results.is_empty():
		return

	# Wrap around
	if index < 0:
		index = _search_results.size() - 1
	elif index >= _search_results.size():
		index = 0

	_current_result_index = index
	var node_id = _search_results[index]

	# Highlight current result more prominently
	_update_current_highlight()

	# Select and center on the node
	_select_and_center_node(node_id)

	result_selected.emit(node_id, index, _search_results.size())


## Go to next search result.
func find_next() -> void:
	if _search_results.is_empty():
		# Re-run last search if we have a query
		if not _last_search_query.is_empty():
			search(_last_search_query, _last_search_field)
		return

	go_to_result(_current_result_index + 1)


## Go to previous search result.
func find_previous() -> void:
	if _search_results.is_empty():
		# Re-run last search if we have a query
		if not _last_search_query.is_empty():
			search(_last_search_query, _last_search_field)
		return

	go_to_result(_current_result_index - 1)


## Clear all search results and highlights.
func clear_search() -> void:
	_clear_all_highlights()
	_search_results.clear()
	_current_result_index = -1
	_last_search_query = ""
	search_completed.emit(_search_results, 0)


## Get current result count.
func get_result_count() -> int:
	return _search_results.size()


## Get current result index (0-based).
func get_current_index() -> int:
	return _current_result_index


## Check if there are any results.
func has_results() -> bool:
	return not _search_results.is_empty()


# =============================================================================
# FILTERING
# =============================================================================

## Apply a type filter to show only nodes of a specific type.
## Pass empty string to show all nodes.
func set_type_filter(type_filter: String) -> void:
	_type_filter = type_filter
	_apply_filter()
	filter_changed.emit()


## Get the current type filter.
func get_type_filter() -> String:
	return _type_filter


## Clear the type filter to show all nodes.
func clear_filter() -> void:
	set_type_filter("")


func _apply_filter() -> void:
	if not _canvas:
		return

	# Restore all previously hidden nodes
	for node_id in _hidden_nodes:
		var node = _canvas.get_node_or_null(NodePath(node_id))
		if node and node is GraphNode:
			node.visible = true

	_hidden_nodes.clear()

	# If no filter, we're done
	if _type_filter.is_empty():
		return

	# Hide nodes that don't match the filter
	for child in _canvas.get_children():
		if child is GraphNode and child.has_method("serialize"):
			var node_data = child.serialize()
			var node_type = node_data.get("type", "")

			if node_type.to_lower() != _type_filter.to_lower():
				child.visible = false
				_hidden_nodes.append(child.name)


## Get list of all unique node types in the canvas.
func get_available_types() -> Array[String]:
	var types: Array[String] = []

	if not _canvas:
		return types

	for child in _canvas.get_children():
		if child is GraphNode and child.has_method("serialize"):
			var node_data = child.serialize()
			var node_type = node_data.get("type", "")
			if not node_type.is_empty() and node_type not in types:
				types.append(node_type)

	types.sort()
	return types


# =============================================================================
# HIGHLIGHTING
# =============================================================================

func _highlight_node(node_id: String, color: Color) -> void:
	var node = _canvas.get_node_or_null(NodePath(node_id))
	if not node or not node is GraphNode:
		return

	# Store original style if not already stored
	if node_id not in _highlighted_nodes:
		_highlighted_nodes[node_id] = node.get_theme_stylebox("panel")

	# Create highlight style
	var highlight_style = StyleBoxFlat.new()
	highlight_style.bg_color = color.darkened(0.6)
	highlight_style.bg_color.a = 0.8
	highlight_style.border_color = color
	highlight_style.set_border_width_all(3)
	highlight_style.set_corner_radius_all(4)

	node.add_theme_stylebox_override("panel", highlight_style)
	node.add_theme_stylebox_override("panel_selected", highlight_style)


func _clear_highlight(node_id: String) -> void:
	if node_id not in _highlighted_nodes:
		return

	var node = _canvas.get_node_or_null(NodePath(node_id))
	if node and node is GraphNode:
		var original = _highlighted_nodes[node_id]
		if original:
			node.add_theme_stylebox_override("panel", original)
		else:
			node.remove_theme_stylebox_override("panel")
		node.remove_theme_stylebox_override("panel_selected")

	_highlighted_nodes.erase(node_id)


func _clear_all_highlights() -> void:
	var node_ids = _highlighted_nodes.keys()
	for node_id in node_ids:
		_clear_highlight(node_id)
	_highlighted_nodes.clear()


func _update_current_highlight() -> void:
	# Re-highlight all results with base color
	for i in _search_results.size():
		var node_id = _search_results[i]
		if i == _current_result_index:
			# Current result gets more prominent highlight
			_highlight_node(node_id, Color.ORANGE)
		else:
			# Other results get subtle highlight
			_highlight_node(node_id, Color.YELLOW)


func _select_and_center_node(node_id: String) -> void:
	var node = _canvas.get_node_or_null(NodePath(node_id))
	if not node or not node is GraphNode:
		return

	# Deselect all nodes first
	for child in _canvas.get_children():
		if child is GraphNode:
			child.selected = false

	# Select the target node
	node.selected = true

	# Center the view on the node
	var node_center = node.position_offset + node.size / 2
	var viewport_size = _canvas.size
	var target_scroll = node_center * _canvas.zoom - viewport_size / 2

	_canvas.scroll_offset = target_scroll
