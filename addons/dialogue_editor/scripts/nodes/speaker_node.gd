@tool
class_name SpeakerNode
extends DialogueNode
## Speaker node - NPC dialogue line.
## Has one input slot, speaker dropdown, text field (500 char limit), and outputs.

const SpeakerColorsScript = preload("res://addons/dialogue_editor/scripts/speaker_colors.gd")

const MAX_TEXT_LENGTH := 500

# Speaker options - loaded from SpeakerColors for consistency
var _available_speakers: Array[String] = []

var speaker: String = "NPC"
var dialogue_text: String = ""
var portrait_path: String = ""

# UI References
var _speaker_dropdown: OptionButton
var _text_edit: TextEdit
var _char_count_label: Label
var _portrait_preview: TextureRect
var _portrait_btn: Button

# Placeholder texture for missing portraits
var _placeholder_texture: Texture2D = null


func _setup_node() -> void:
	node_type = "Speaker"
	title = "Speaker"
	custom_minimum_size = Vector2(280, 0)
	_available_speakers = SpeakerColorsScript.get_common_speakers()
	# Initial color will be set after speaker dropdown is created
	apply_color_theme(SpeakerColorsScript.get_speaker_color("NPC"))
	# Create placeholder texture for missing portraits
	_create_placeholder_texture()


func _setup_slots() -> void:
	# Speaker dropdown row
	var speaker_row = HBoxContainer.new()
	var speaker_label = Label.new()
	speaker_label.text = "Speaker:"
	speaker_label.custom_minimum_size = Vector2(60, 0)
	speaker_row.add_child(speaker_label)

	_speaker_dropdown = OptionButton.new()
	_speaker_dropdown.custom_minimum_size = Vector2(140, 0)
	for s in _available_speakers:
		_speaker_dropdown.add_item(s)
	_speaker_dropdown.item_selected.connect(_on_speaker_changed)
	speaker_row.add_child(_speaker_dropdown)
	add_child(speaker_row)

	# Portrait row
	var portrait_row = HBoxContainer.new()
	portrait_row.alignment = BoxContainer.ALIGNMENT_BEGIN

	_portrait_preview = TextureRect.new()
	_portrait_preview.custom_minimum_size = Vector2(48, 48)
	_portrait_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait_preview.texture = _placeholder_texture
	_portrait_preview.tooltip_text = "No portrait set"
	portrait_row.add_child(_portrait_preview)

	var portrait_vbox = VBoxContainer.new()
	portrait_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var portrait_label = Label.new()
	portrait_label.text = "Portrait:"
	portrait_label.add_theme_font_size_override("font_size", 11)
	portrait_vbox.add_child(portrait_label)

	_portrait_btn = Button.new()
	_portrait_btn.text = "Select..."
	_portrait_btn.custom_minimum_size = Vector2(80, 0)
	_portrait_btn.pressed.connect(_on_portrait_button_pressed)
	portrait_vbox.add_child(_portrait_btn)

	portrait_row.add_child(portrait_vbox)
	add_child(portrait_row)

	# Set initial speaker and color
	if _speaker_dropdown.item_count > 0:
		# Default to NPC if available, otherwise first item
		var npc_index = -1
		for i in _speaker_dropdown.item_count:
			if _speaker_dropdown.get_item_text(i) == "NPC":
				npc_index = i
				break
		if npc_index >= 0:
			_speaker_dropdown.select(npc_index)
			speaker = "NPC"
		else:
			_speaker_dropdown.select(0)
			speaker = _speaker_dropdown.get_item_text(0)
		_update_color_by_speaker()

	# Text edit for dialogue
	_text_edit = TextEdit.new()
	_text_edit.custom_minimum_size = Vector2(260, 80)
	_text_edit.placeholder_text = "Enter dialogue text..."
	_text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text_edit.text_changed.connect(_on_text_changed)
	add_child(_text_edit)

	# Character count
	_char_count_label = Label.new()
	_char_count_label.text = "0 / %d" % MAX_TEXT_LENGTH
	_char_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_char_count_label.add_theme_font_size_override("font_size", 10)
	_char_count_label.modulate = Color(1, 1, 1, 0.5)
	add_child(_char_count_label)

	# Input slot (slot 0 is speaker row), output slot - both use FLOW type
	set_slot(0, true, SlotType.FLOW, SLOT_COLOR_FLOW, true, SlotType.FLOW, SLOT_COLOR_FLOW)


func _on_speaker_changed(index: int) -> void:
	speaker = _speaker_dropdown.get_item_text(index)
	_update_color_by_speaker()
	_emit_data_changed()


func _on_text_changed() -> void:
	var text = _text_edit.text
	if text.length() > MAX_TEXT_LENGTH:
		# Truncate text
		_text_edit.text = text.substr(0, MAX_TEXT_LENGTH)
		_text_edit.set_caret_column(MAX_TEXT_LENGTH)

	dialogue_text = _text_edit.text
	_update_char_count()
	_emit_data_changed()


func _update_char_count() -> void:
	var count = _text_edit.text.length()
	_char_count_label.text = "%d / %d" % [count, MAX_TEXT_LENGTH]

	# Color warning when near limit
	if count >= MAX_TEXT_LENGTH:
		_char_count_label.modulate = Color.RED
	elif count >= MAX_TEXT_LENGTH * 0.9:
		_char_count_label.modulate = Color.ORANGE
	else:
		_char_count_label.modulate = Color(1, 1, 1, 0.5)


func _update_color_by_speaker() -> void:
	# Get color from centralized SpeakerColors manager
	var color = SpeakerColorsScript.get_speaker_color(speaker)
	apply_color_theme(color)


func _create_placeholder_texture() -> void:
	# Create a simple placeholder image programmatically
	var img = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.3, 0.3, 1.0))

	# Draw a simple "?" pattern
	var center_color = Color(0.5, 0.5, 0.5, 1.0)
	for x in range(16, 32):
		for y in range(10, 38):
			img.set_pixel(x, y, center_color)

	# Draw question mark shape approximation
	var q_color = Color(0.7, 0.7, 0.7, 1.0)
	# Top arc of ?
	for x in range(18, 30):
		img.set_pixel(x, 12, q_color)
		img.set_pixel(x, 13, q_color)
	for y in range(12, 20):
		img.set_pixel(28, y, q_color)
		img.set_pixel(29, y, q_color)
	for x in range(22, 30):
		img.set_pixel(x, 19, q_color)
		img.set_pixel(x, 20, q_color)
	# Stem of ?
	for y in range(20, 28):
		img.set_pixel(22, y, q_color)
		img.set_pixel(23, y, q_color)
	# Dot of ?
	for x in range(21, 25):
		for y in range(31, 35):
			img.set_pixel(x, y, q_color)

	_placeholder_texture = ImageTexture.create_from_image(img)


func _on_portrait_button_pressed() -> void:
	# Open file dialog to select portrait image
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg,*.jpeg ; JPEG Images", "*.webp ; WebP Images"])
	dialog.title = "Select Portrait Image"
	dialog.file_selected.connect(_on_portrait_selected)
	dialog.canceled.connect(func(): dialog.queue_free())

	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_portrait_selected(path: String) -> void:
	portrait_path = path
	_update_portrait_preview()
	_emit_data_changed()

	# Clean up dialog
	for child in get_children():
		if child is EditorFileDialog:
			child.queue_free()


func _update_portrait_preview() -> void:
	if not _portrait_preview:
		return

	if portrait_path.is_empty():
		_portrait_preview.texture = _placeholder_texture
		_portrait_preview.tooltip_text = "No portrait set"
		if _portrait_btn:
			_portrait_btn.text = "Select..."
		return

	# Try to load the portrait
	if not FileAccess.file_exists(portrait_path):
		# Portrait file missing - show placeholder with warning
		_portrait_preview.texture = _placeholder_texture
		_portrait_preview.modulate = Color(1.0, 0.6, 0.6, 1.0)  # Red tint
		_portrait_preview.tooltip_text = "Missing: %s" % portrait_path
		if _portrait_btn:
			_portrait_btn.text = "Missing!"
			_portrait_btn.modulate = Color(1.0, 0.6, 0.6, 1.0)
		push_warning("DialogueEditor: Portrait not found: %s" % portrait_path)
		return

	# Load the texture
	var texture = load(portrait_path)
	if texture and texture is Texture2D:
		_portrait_preview.texture = texture
		_portrait_preview.modulate = Color.WHITE
		_portrait_preview.tooltip_text = portrait_path.get_file()
		if _portrait_btn:
			_portrait_btn.text = portrait_path.get_file().substr(0, 10) + "..." if portrait_path.get_file().length() > 10 else portrait_path.get_file()
			_portrait_btn.modulate = Color.WHITE
	else:
		# Failed to load - show placeholder with warning
		_portrait_preview.texture = _placeholder_texture
		_portrait_preview.modulate = Color(1.0, 0.8, 0.5, 1.0)  # Orange tint
		_portrait_preview.tooltip_text = "Failed to load: %s" % portrait_path
		if _portrait_btn:
			_portrait_btn.text = "Error!"
			_portrait_btn.modulate = Color(1.0, 0.8, 0.5, 1.0)
		push_warning("DialogueEditor: Failed to load portrait: %s" % portrait_path)


func set_speaker(value: String) -> void:
	speaker = value
	if _speaker_dropdown:
		for i in _speaker_dropdown.item_count:
			if _speaker_dropdown.get_item_text(i) == value:
				_speaker_dropdown.select(i)
				break
	_update_color_by_speaker()


func set_dialogue_text(value: String) -> void:
	dialogue_text = value.substr(0, MAX_TEXT_LENGTH)
	if _text_edit:
		_text_edit.text = dialogue_text
		_update_char_count()


func set_portrait(value: String) -> void:
	portrait_path = value
	_update_portrait_preview()


func serialize() -> Dictionary:
	var data = super.serialize()
	data["speaker"] = speaker
	data["text"] = dialogue_text
	data["portrait"] = portrait_path
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	if data.has("speaker"):
		set_speaker(data.speaker)
	if data.has("text"):
		set_dialogue_text(data.text)
	if data.has("portrait"):
		portrait_path = data.portrait
		_update_portrait_preview()
