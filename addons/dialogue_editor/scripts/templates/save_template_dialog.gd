@tool
class_name SaveTemplateDialog
extends ConfirmationDialog
## Dialog for saving selected nodes as a reusable template.
## Allows entering template name, description, tags, and category.

signal template_saved(template: DialogueTemplateData)

# UI Elements
var _name_edit: LineEdit
var _description_edit: TextEdit
var _tags_edit: LineEdit
var _category_dropdown: OptionButton
var _preview_label: Label
var _error_label: Label

# Data
var _selected_nodes: Array = []
var _selected_connections: Array = []

# Categories for templates
const CATEGORIES := ["conversation", "quest", "shop", "combat", "custom"]


func _init() -> void:
	title = "Save as Template"
	ok_button_text = "Save Template"
	min_size = Vector2(450, 400)


func _ready() -> void:
	_setup_ui()
	confirmed.connect(_on_confirmed)
	canceled.connect(_on_canceled)


func _setup_ui() -> void:
	# Create main container
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(430, 350)

	# Template Name (required)
	var name_label = Label.new()
	name_label.text = "Template Name *"
	vbox.add_child(name_label)

	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Enter template name..."
	_name_edit.text_changed.connect(_on_name_changed)
	vbox.add_child(_name_edit)

	_add_spacer(vbox, 10)

	# Description (optional)
	var desc_label = Label.new()
	desc_label.text = "Description"
	vbox.add_child(desc_label)

	_description_edit = TextEdit.new()
	_description_edit.placeholder_text = "Enter a description for this template..."
	_description_edit.custom_minimum_size = Vector2(0, 80)
	_description_edit.scroll_fit_content_height = true
	vbox.add_child(_description_edit)

	_add_spacer(vbox, 10)

	# Category
	var category_hbox = HBoxContainer.new()

	var cat_label = Label.new()
	cat_label.text = "Category"
	cat_label.custom_minimum_size = Vector2(100, 0)
	category_hbox.add_child(cat_label)

	_category_dropdown = OptionButton.new()
	for cat in CATEGORIES:
		_category_dropdown.add_item(cat.capitalize())
	_category_dropdown.selected = 0
	_category_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_hbox.add_child(_category_dropdown)

	vbox.add_child(category_hbox)

	_add_spacer(vbox, 10)

	# Tags (optional)
	var tags_label = Label.new()
	tags_label.text = "Tags (comma-separated)"
	vbox.add_child(tags_label)

	_tags_edit = LineEdit.new()
	_tags_edit.placeholder_text = "e.g., greeting, npc, merchant"
	vbox.add_child(_tags_edit)

	_add_spacer(vbox, 10)

	# Preview
	var preview_header = Label.new()
	preview_header.text = "Preview"
	preview_header.add_theme_font_size_override("font_size", 14)
	vbox.add_child(preview_header)

	var preview_panel = PanelContainer.new()
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	preview_style.set_corner_radius_all(4)
	preview_style.content_margin_left = 8
	preview_style.content_margin_right = 8
	preview_style.content_margin_top = 8
	preview_style.content_margin_bottom = 8
	preview_panel.add_theme_stylebox_override("panel", preview_style)

	_preview_label = Label.new()
	_preview_label.text = "No nodes selected"
	_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_panel.add_child(_preview_label)
	vbox.add_child(preview_panel)

	_add_spacer(vbox, 10)

	# Error label
	_error_label = Label.new()
	_error_label.text = ""
	_error_label.add_theme_color_override("font_color", Color.RED)
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.visible = false
	vbox.add_child(_error_label)

	add_child(vbox)


func _add_spacer(parent: Control, height: float) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	parent.add_child(spacer)


## Show the dialog with selected nodes data.
func show_for_selection(nodes: Array, connections: Array) -> void:
	_selected_nodes = nodes
	_selected_connections = connections

	# Reset form
	_name_edit.text = ""
	_description_edit.text = ""
	_tags_edit.text = ""
	_category_dropdown.selected = 0
	_error_label.visible = false

	# Update preview
	_update_preview()

	# Validate selection
	var validation = _validate_selection()
	if not validation.valid:
		_show_error(validation.error)
		get_ok_button().disabled = true
	else:
		get_ok_button().disabled = true  # Disabled until name is entered

	popup_centered()
	_name_edit.grab_focus()


## Update the preview label with selection info.
func _update_preview() -> void:
	if _selected_nodes.is_empty():
		_preview_label.text = "No nodes selected"
		return

	# Count node types
	var type_counts := {}
	for node in _selected_nodes:
		var node_type = node.get("type", "Unknown")
		type_counts[node_type] = type_counts.get(node_type, 0) + 1

	# Build preview text
	var parts := []
	for node_type in type_counts:
		var count = type_counts[node_type]
		if count == 1:
			parts.append("1 %s" % node_type)
		else:
			parts.append("%d %ss" % [count, node_type])

	var preview_text = "Selected: %d nodes (%s)\nConnections: %d internal" % [
		_selected_nodes.size(),
		", ".join(parts),
		_selected_connections.size()
	]

	_preview_label.text = preview_text


## Validate the selection is suitable for a template.
func _validate_selection() -> Dictionary:
	if _selected_nodes.is_empty():
		return {"valid": false, "error": "No nodes selected. Select at least 2 nodes."}

	if _selected_nodes.size() < 2:
		return {"valid": false, "error": "Select at least 2 nodes to create a template."}

	# Check for at least one connection if multiple nodes
	if _selected_nodes.size() > 1 and _selected_connections.is_empty():
		return {"valid": false, "error": "Selected nodes should be connected to each other."}

	return {"valid": true, "error": ""}


## Validate the template name.
func _validate_name(template_name: String) -> Dictionary:
	if template_name.strip_edges().is_empty():
		return {"valid": false, "error": "Template name is required."}

	if template_name.length() < 2:
		return {"valid": false, "error": "Template name must be at least 2 characters."}

	if template_name.length() > 100:
		return {"valid": false, "error": "Template name must be 100 characters or less."}

	# Check for invalid characters
	var invalid_chars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|']
	for char in invalid_chars:
		if char in template_name:
			return {"valid": false, "error": "Template name contains invalid character: %s" % char}

	# Check if name already exists
	var manager = DialogueTemplateManager.get_instance()
	if manager.has_template(template_name):
		return {"valid": false, "error": "A template with this name already exists."}

	return {"valid": true, "error": ""}


func _on_name_changed(new_text: String) -> void:
	var validation = _validate_name(new_text)
	if not validation.valid:
		_show_error(validation.error)
		get_ok_button().disabled = true
	else:
		_hide_error()
		get_ok_button().disabled = false


func _show_error(message: String) -> void:
	_error_label.text = message
	_error_label.visible = true


func _hide_error() -> void:
	_error_label.visible = false


func _on_confirmed() -> void:
	var template_name = _name_edit.text.strip_edges()

	# Final validation
	var name_validation = _validate_name(template_name)
	if not name_validation.valid:
		_show_error(name_validation.error)
		return

	var selection_validation = _validate_selection()
	if not selection_validation.valid:
		_show_error(selection_validation.error)
		return

	# Create the template
	var template = DialogueTemplateData.create_from_selection(
		template_name,
		_selected_nodes,
		_selected_connections,
		_description_edit.text.strip_edges()
	)

	# Set additional metadata
	template.category = CATEGORIES[_category_dropdown.selected]
	template.author = "User"

	# Parse tags
	var tags_text = _tags_edit.text.strip_edges()
	if not tags_text.is_empty():
		var tags = tags_text.split(",")
		for tag in tags:
			var trimmed_tag = tag.strip_edges()
			if not trimmed_tag.is_empty():
				template.tags.append(trimmed_tag)

	# Save the template
	var manager = DialogueTemplateManager.get_instance()
	var err = manager.save_template(template)

	if err == OK:
		template_saved.emit(template)
		print("SaveTemplateDialog: Template '%s' saved successfully" % template_name)
	else:
		_show_error("Failed to save template (error: %d)" % err)


func _on_canceled() -> void:
	_selected_nodes.clear()
	_selected_connections.clear()
