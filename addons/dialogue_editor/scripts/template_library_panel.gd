@tool
class_name TemplateLibraryPanel
extends VBoxContainer
## Template Library Panel for browsing, managing, and inserting dialogue templates.
## Displays templates organized by category with search, drag-and-drop, and management features.

signal template_selected(template: DialogueTemplateData)
signal template_drag_started(template: DialogueTemplateData)

# UI References
var _search_field: LineEdit
var _template_tree: Tree
var _preview_panel: PanelContainer
var _preview_label: RichTextLabel
var _button_container: HBoxContainer
var _import_btn: Button
var _export_btn: Button
var _delete_btn: Button
var _refresh_btn: Button

# Tree items
var _root_item: TreeItem
var _builtin_category: TreeItem
var _custom_category: TreeItem
var _category_items: Dictionary = {}  # category_name -> TreeItem

# Template data
var _templates_by_item: Dictionary = {}  # TreeItem -> DialogueTemplateData
var _current_filter: String = ""
var _selected_template: DialogueTemplateData = null

# Drag state
var _drag_template: DialogueTemplateData = null


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_refresh_templates()


func _setup_ui() -> void:
	# Main container styling
	custom_minimum_size = Vector2(200, 300)

	# Header label
	var header = Label.new()
	header.text = "Template Library"
	header.add_theme_font_size_override("font_size", 14)
	add_child(header)

	# Search field
	_search_field = LineEdit.new()
	_search_field.placeholder_text = "Search templates..."
	_search_field.clear_button_enabled = true
	add_child(_search_field)

	# Template tree
	_template_tree = Tree.new()
	_template_tree.hide_root = true
	_template_tree.select_mode = Tree.SELECT_SINGLE
	_template_tree.custom_minimum_size = Vector2(0, 150)
	_template_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_template_tree)

	# Preview panel
	_preview_panel = PanelContainer.new()
	_preview_panel.custom_minimum_size = Vector2(0, 80)
	_preview_panel.visible = false

	var preview_margin = MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 8)
	preview_margin.add_theme_constant_override("margin_right", 8)
	preview_margin.add_theme_constant_override("margin_top", 4)
	preview_margin.add_theme_constant_override("margin_bottom", 4)
	_preview_panel.add_child(preview_margin)

	_preview_label = RichTextLabel.new()
	_preview_label.bbcode_enabled = true
	_preview_label.fit_content = true
	_preview_label.scroll_active = false
	preview_margin.add_child(_preview_label)

	add_child(_preview_panel)

	# Button container
	_button_container = HBoxContainer.new()
	_button_container.alignment = BoxContainer.ALIGNMENT_CENTER

	_import_btn = Button.new()
	_import_btn.text = "Import"
	_import_btn.tooltip_text = "Import template from file"
	_button_container.add_child(_import_btn)

	_export_btn = Button.new()
	_export_btn.text = "Export"
	_export_btn.tooltip_text = "Export selected template"
	_export_btn.disabled = true
	_button_container.add_child(_export_btn)

	_delete_btn = Button.new()
	_delete_btn.text = "Delete"
	_delete_btn.tooltip_text = "Delete selected custom template"
	_delete_btn.disabled = true
	_button_container.add_child(_delete_btn)

	_refresh_btn = Button.new()
	_refresh_btn.text = "Refresh"
	_refresh_btn.tooltip_text = "Refresh template list"
	_button_container.add_child(_refresh_btn)

	add_child(_button_container)


func _connect_signals() -> void:
	_search_field.text_changed.connect(_on_search_text_changed)
	_template_tree.item_selected.connect(_on_tree_item_selected)
	_template_tree.nothing_selected.connect(_on_tree_nothing_selected)
	_template_tree.gui_input.connect(_on_tree_gui_input)
	_import_btn.pressed.connect(_on_import_pressed)
	_export_btn.pressed.connect(_on_export_pressed)
	_delete_btn.pressed.connect(_on_delete_pressed)
	_refresh_btn.pressed.connect(_on_refresh_pressed)


func _refresh_templates() -> void:
	_template_tree.clear()
	_templates_by_item.clear()
	_category_items.clear()

	# Create root
	_root_item = _template_tree.create_item()

	# Create main categories
	_builtin_category = _template_tree.create_item(_root_item)
	_builtin_category.set_text(0, "Built-in Templates")
	_builtin_category.set_selectable(0, false)
	_builtin_category.set_custom_color(0, Color(0.7, 0.7, 0.7))

	_custom_category = _template_tree.create_item(_root_item)
	_custom_category.set_text(0, "Custom Templates")
	_custom_category.set_selectable(0, false)
	_custom_category.set_custom_color(0, Color(0.7, 0.7, 0.7))

	# Load templates
	var manager = DialogueTemplateManager.get_instance()
	if manager:
		var all_templates = manager.get_all_templates()
		_populate_templates(all_templates)

	# Expand categories by default
	_builtin_category.collapsed = false
	_custom_category.collapsed = false


func _populate_templates(templates: Array) -> void:
	# Separate built-in and custom templates
	var builtin_templates: Array = []
	var custom_templates: Array = []

	for template in templates:
		if template is DialogueTemplateData:
			var path: String = template.get_meta("file_path", "") if template.has_meta("file_path") else ""
			if path.begins_with("res://addons/dialogue_editor/data/built_in_templates/"):
				builtin_templates.append(template)
			else:
				custom_templates.append(template)

	# Group by category within each section
	var builtin_by_category = _group_by_category(builtin_templates)
	var custom_by_category = _group_by_category(custom_templates)

	# Populate built-in section
	_populate_category_section(_builtin_category, builtin_by_category, true)

	# Populate custom section
	_populate_category_section(_custom_category, custom_by_category, false)

	# Apply current filter if any
	if _current_filter.length() > 0:
		_apply_filter(_current_filter)


func _group_by_category(templates: Array) -> Dictionary:
	var by_category: Dictionary = {}

	for template in templates:
		if template is DialogueTemplateData:
			var category = template.category if template.category.length() > 0 else "uncategorized"
			if not by_category.has(category):
				by_category[category] = []
			by_category[category].append(template)

	return by_category


func _populate_category_section(parent_item: TreeItem, by_category: Dictionary, is_builtin: bool) -> void:
	# Sort categories alphabetically
	var categories = by_category.keys()
	categories.sort()

	for category in categories:
		# Create category item
		var cat_item = _template_tree.create_item(parent_item)
		cat_item.set_text(0, category.capitalize())
		cat_item.set_selectable(0, false)
		cat_item.set_custom_color(0, Color(0.8, 0.8, 0.6))
		cat_item.collapsed = false

		# Add templates
		var templates = by_category[category]
		templates.sort_custom(func(a, b): return a.template_name < b.template_name)

		for template in templates:
			var item = _template_tree.create_item(cat_item)
			item.set_text(0, template.template_name)
			item.set_tooltip_text(0, template.description)

			# Mark built-in templates visually
			if is_builtin:
				item.set_custom_color(0, Color(0.6, 0.8, 1.0))

			_templates_by_item[item] = template


func _apply_filter(filter_text: String) -> void:
	_current_filter = filter_text.to_lower()

	# Recursively show/hide items based on filter
	_filter_tree_item(_builtin_category)
	_filter_tree_item(_custom_category)


func _filter_tree_item(item: TreeItem) -> bool:
	if item == null:
		return false

	var any_child_visible = false
	var child = item.get_first_child()

	while child != null:
		var child_visible = _filter_tree_item(child)
		any_child_visible = any_child_visible or child_visible
		child = child.get_next()

	# Check if this item matches (only for template items, not categories)
	var matches_filter = false
	if _templates_by_item.has(item):
		var template = _templates_by_item[item]
		if _current_filter.length() == 0:
			matches_filter = true
		else:
			# Check name, description, and tags
			matches_filter = template.template_name.to_lower().contains(_current_filter)
			matches_filter = matches_filter or template.description.to_lower().contains(_current_filter)
			for tag in template.tags:
				if tag.to_lower().contains(_current_filter):
					matches_filter = true
					break

	# Category items are visible if any child is visible
	var should_be_visible = matches_filter or any_child_visible
	item.visible = should_be_visible

	return should_be_visible


func _update_preview(template: DialogueTemplateData) -> void:
	if template == null:
		_preview_panel.visible = false
		return

	_preview_panel.visible = true

	var preview_text = "[b]%s[/b]\n" % template.template_name
	preview_text += "[color=gray]%s[/color]\n" % template.description
	preview_text += "[color=yellow]Nodes:[/color] %d" % template.get_node_count()

	if template.tags.size() > 0:
		preview_text += "\n[color=cyan]Tags:[/color] %s" % ", ".join(template.tags)

	if template.placeholders.size() > 0:
		preview_text += "\n[color=green]Placeholders:[/color] %d" % template.placeholders.size()

	_preview_label.text = preview_text


func _update_button_states() -> void:
	var has_selection = _selected_template != null
	var is_custom = false

	if has_selection and _selected_template.has_meta("file_path"):
		var path: String = _selected_template.get_meta("file_path")
		is_custom = not path.begins_with("res://addons/dialogue_editor/data/built_in_templates/")

	_export_btn.disabled = not has_selection
	_delete_btn.disabled = not (has_selection and is_custom)


func _create_drag_preview(template: DialogueTemplateData) -> Control:
	var preview = PanelContainer.new()

	var label = Label.new()
	label.text = template.template_name
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	preview.add_child(label)

	# Add a stylebox for visibility
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.4, 0.6, 0.9)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	preview.add_theme_stylebox_override("panel", style)

	return preview


# Signal handlers

func _on_search_text_changed(new_text: String) -> void:
	_apply_filter(new_text)


func _on_tree_item_selected() -> void:
	var selected = _template_tree.get_selected()
	if selected and _templates_by_item.has(selected):
		_selected_template = _templates_by_item[selected]
		_update_preview(_selected_template)
		_update_button_states()
		template_selected.emit(_selected_template)
	else:
		_selected_template = null
		_update_preview(null)
		_update_button_states()


func _on_tree_nothing_selected() -> void:
	_selected_template = null
	_update_preview(null)
	_update_button_states()


func _on_tree_gui_input(event: InputEvent) -> void:
	# Handle drag start
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var selected = _template_tree.get_selected()
		if selected and _templates_by_item.has(selected):
			var template = _templates_by_item[selected]
			var preview = _create_drag_preview(template)
			var drag_data = {
				"type": "dialogue_template",
				"template": template
			}
			_template_tree.force_drag(drag_data, preview)
			template_drag_started.emit(template)

	# Handle double-click to insert
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		var selected = _template_tree.get_selected()
		if selected and _templates_by_item.has(selected):
			template_selected.emit(_templates_by_item[selected])


func _on_import_pressed() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.filters = ["*.dttemplate ; Dialogue Template"]
	dialog.title = "Import Template"
	dialog.file_selected.connect(_on_import_file_selected.bind(dialog))
	dialog.canceled.connect(func(): dialog.queue_free())

	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


func _on_import_file_selected(path: String, dialog: FileDialog) -> void:
	dialog.queue_free()

	var manager = DialogueTemplateManager.get_instance()
	if manager:
		var template = manager.load_template(path)
		if template:
			# Mark as user template (not built-in) so it can be saved
			template.is_built_in = false
			# Save using the manager (saves to user templates directory)
			var err = manager.save_template(template)
			if err == OK:
				_refresh_templates()
				print("Template imported: ", template.template_name)
			else:
				push_error("Failed to import template: %d" % err)


func _on_export_pressed() -> void:
	if _selected_template == null:
		return

	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.dttemplate ; Dialogue Template"]
	dialog.title = "Export Template"
	dialog.current_file = _selected_template.template_name.to_snake_case() + ".dttemplate"
	dialog.file_selected.connect(_on_export_file_selected.bind(dialog))
	dialog.canceled.connect(func(): dialog.queue_free())

	add_child(dialog)
	dialog.popup_centered(Vector2(600, 400))


func _on_export_file_selected(path: String, dialog: FileDialog) -> void:
	dialog.queue_free()

	if _selected_template:
		var err = _selected_template.save_to_file(path)
		if err == OK:
			print("Template exported to: ", path)
		else:
			push_error("Failed to export template: %d" % err)


func _on_delete_pressed() -> void:
	if _selected_template == null:
		return

	if not _selected_template.has_meta("file_path"):
		return

	var path: String = _selected_template.get_meta("file_path")
	if path.begins_with("res://addons/dialogue_editor/data/built_in_templates/"):
		push_warning("Cannot delete built-in templates")
		return

	# Show confirmation dialog
	var confirm = ConfirmationDialog.new()
	confirm.title = "Delete Template"
	confirm.dialog_text = "Are you sure you want to delete '%s'?\nThis cannot be undone." % _selected_template.template_name
	confirm.confirmed.connect(_on_delete_confirmed.bind(path, confirm))
	confirm.canceled.connect(func(): confirm.queue_free())

	add_child(confirm)
	confirm.popup_centered()


func _on_delete_confirmed(path: String, dialog: ConfirmationDialog) -> void:
	dialog.queue_free()

	var dir = DirAccess.open(path.get_base_dir())
	if dir:
		var err = dir.remove(path.get_file())
		if err == OK:
			print("Template deleted: ", path)
			_selected_template = null
			_refresh_templates()
		else:
			push_error("Failed to delete template: ", error_string(err))


func _on_refresh_pressed() -> void:
	var manager = DialogueTemplateManager.get_instance()
	if manager:
		manager.refresh_templates()
	_refresh_templates()


# Public API

## Refresh the template list from disk.
func refresh() -> void:
	_refresh_templates()


## Get the currently selected template.
func get_selected_template() -> DialogueTemplateData:
	return _selected_template


## Set the search filter text.
func set_filter(text: String) -> void:
	_search_field.text = text
	_apply_filter(text)
