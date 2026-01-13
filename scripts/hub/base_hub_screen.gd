## BaseHubScreen - Base class for hub sub-screens
## Part of: Blood & Gold Prototype
## Task 3.1: Main Hub Scene Structure
class_name BaseHubScreen
extends Control

# ===== SIGNALS =====
signal back_pressed

# ===== NODE REFERENCES =====
@onready var back_button: Button = $TopBar/BackButton
@onready var title_label: Label = $TopBar/TitleLabel
@onready var content_panel: Panel = $ContentPanel

# ===== LIFECYCLE =====
func _ready() -> void:
	_connect_signals()
	_setup_screen()

func _connect_signals() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _setup_screen() -> void:
	## Override in child classes to set up screen-specific content
	pass

func _on_back_pressed() -> void:
	back_pressed.emit()

# ===== PUBLIC API =====
func set_title(title: String) -> void:
	if title_label:
		title_label.text = title
