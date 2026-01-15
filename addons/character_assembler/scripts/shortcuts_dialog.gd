@tool
extends AcceptDialog
class_name ShortcutsDialog
## Dialog showing all available keyboard shortcuts for the Character Assembler.

const SHORTCUTS_TEXT := """
# File Operations
Ctrl+N          New project
Ctrl+O          Open project
Ctrl+S          Save project
Ctrl+Shift+S    Save project as...

# Edit Operations
Ctrl+Z          Undo
Ctrl+Shift+Z    Redo
Ctrl+Y          Redo (alternative)
Delete          Delete selected shape(s)
Backspace       Delete selected shape(s)

# Tool Selection
V               Select tool
R               Rectangle tool
C               Circle tool
E               Ellipse tool
T               Triangle tool

# Canvas Navigation
Mouse Wheel     Zoom in/out
Middle-click    Pan canvas (drag)
Shift+drag      Constrain to axis

# Selection
Click           Select shape
Ctrl+click      Multi-select (add/remove)
Shift+click     Range select in layer list
Drag            Move selected shape(s)

# Shape Editing
Drag corners    Resize shape
Drag edges      Resize shape (one direction)
Shift+resize    Maintain aspect ratio

# Body Part Tagging
Click pivot btn Set pivot point (click canvas)

# Animation
Space           Play/pause animation preview
"""


func _init() -> void:
	title = "Keyboard Shortcuts"
	dialog_hide_on_ok = true
	min_size = Vector2(400, 500)


func _ready() -> void:
	_setup_content()


func _setup_content() -> void:
	# Create a scroll container for the shortcuts
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(380, 450)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	# Create a RichTextLabel for formatted content
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text = _format_shortcuts()

	scroll.add_child(label)
	add_child(scroll)


func _format_shortcuts() -> String:
	## Format the shortcuts text with BBCode for nicer display.
	var formatted := ""
	var lines := SHORTCUTS_TEXT.strip_edges().split("\n")

	for line in lines:
		if line.is_empty():
			formatted += "\n"
		elif line.begins_with("# "):
			# Section header
			formatted += "\n[b][color=#88ccff]%s[/color][/b]\n" % line.substr(2)
		else:
			# Shortcut line - split at multiple spaces
			var parts := line.split("  ", false)
			if parts.size() >= 2:
				var shortcut := parts[0].strip_edges()
				var description := parts[1].strip_edges()
				formatted += "[code]%s[/code]  %s\n" % [shortcut, description]
			else:
				formatted += line + "\n"

	return formatted


## Show the shortcuts dialog centered on the screen.
func show_shortcuts() -> void:
	popup_centered()
