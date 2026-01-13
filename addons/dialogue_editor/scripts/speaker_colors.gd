@tool
class_name SpeakerColors
extends RefCounted
## Manages speaker-to-color mapping for visual clarity in dialogue nodes.
## Provides default colors and allows custom color configuration.

# Default speaker color palette
# These colors are designed for readability against dark node backgrounds
const DEFAULT_COLORS: Dictionary = {
	# Core speakers
	"Player": Color(0.12, 0.56, 1.0),      # Dodger Blue - player responses
	"Narrator": Color(0.5, 0.5, 0.5),      # Gray - narration/system text
	"NPC": Color(0.0, 0.8, 0.8),           # Cyan - generic NPC

	# Common character archetypes
	"Guard": Color(0.7, 0.2, 0.2),         # Dark Red - authority/military
	"Merchant": Color(1.0, 0.84, 0.0),     # Gold - commerce
	"Villager": Color(0.6, 0.8, 0.4),      # Olive - common folk
	"Noble": Color(0.6, 0.2, 0.8),         # Purple - aristocracy
	"Priest": Color(1.0, 1.0, 0.8),        # Ivory - religious
	"Thief": Color(0.4, 0.4, 0.4),         # Dark Gray - underworld
	"Mage": Color(0.4, 0.2, 0.8),          # Indigo - magic users
	"Warrior": Color(0.8, 0.4, 0.2),       # Rust - fighters

	# Factions (if game has them)
	"Enemy": Color(0.9, 0.1, 0.1),         # Bright Red - hostile
	"Ally": Color(0.2, 0.8, 0.2),          # Green - friendly
	"Neutral": Color(0.7, 0.7, 0.5),       # Tan - neutral parties

	# Special
	"Unknown": Color(0.3, 0.3, 0.3),       # Dark Gray - unidentified
	"Custom": Color(0.5, 0.5, 0.7),        # Slate - custom speakers
}

# Player color is special - always used for Choice nodes
const PLAYER_COLOR := Color(0.12, 0.56, 1.0)  # Dodger Blue

# Custom colors that override defaults (persisted to editor settings if needed)
static var _custom_colors: Dictionary = {}

# Signal emitted when colors change
signal colors_changed()


## Get the color for a speaker name.
## Returns custom color if set, otherwise default, otherwise fallback.
static func get_speaker_color(speaker: String) -> Color:
	# Check custom colors first
	if _custom_colors.has(speaker):
		return _custom_colors[speaker]

	# Check default colors
	if DEFAULT_COLORS.has(speaker):
		return DEFAULT_COLORS[speaker]

	# Fallback: generate a consistent color from the speaker name
	return _generate_color_from_name(speaker)


## Get the player color (used for Choice nodes).
static func get_player_color() -> Color:
	if _custom_colors.has("Player"):
		return _custom_colors["Player"]
	return PLAYER_COLOR


## Set a custom color for a speaker.
static func set_speaker_color(speaker: String, color: Color) -> void:
	_custom_colors[speaker] = color


## Remove custom color for a speaker (revert to default).
static func clear_speaker_color(speaker: String) -> void:
	_custom_colors.erase(speaker)


## Get all available speakers (defaults + any custom).
static func get_all_speakers() -> Array[String]:
	var speakers: Array[String] = []

	for speaker in DEFAULT_COLORS:
		speakers.append(speaker)

	for speaker in _custom_colors:
		if speaker not in speakers:
			speakers.append(speaker)

	speakers.sort()
	return speakers


## Get commonly used speakers for the dropdown.
static func get_common_speakers() -> Array[String]:
	return ["Narrator", "Player", "NPC", "Guard", "Merchant", "Villager"]


## Check if a speaker has a custom color set.
static func has_custom_color(speaker: String) -> bool:
	return _custom_colors.has(speaker)


## Get all colors as a dictionary for display/legend.
static func get_color_legend() -> Dictionary:
	var legend: Dictionary = {}

	# Add defaults
	for speaker in DEFAULT_COLORS:
		legend[speaker] = DEFAULT_COLORS[speaker]

	# Override with custom colors
	for speaker in _custom_colors:
		legend[speaker] = _custom_colors[speaker]

	return legend


## Get a simplified legend with just the most common speakers.
static func get_simple_legend() -> Dictionary:
	var common = get_common_speakers()
	var legend: Dictionary = {}

	for speaker in common:
		legend[speaker] = get_speaker_color(speaker)

	return legend


## Generate a deterministic color from a speaker name.
## Used for unknown speakers to ensure consistency.
static func _generate_color_from_name(speaker_name: String) -> Color:
	# Use a hash to generate consistent hue
	var hash_val = speaker_name.hash()

	# Generate HSV color with good saturation and value
	var hue = fmod(abs(hash_val) / 1000000.0, 1.0)
	var saturation = 0.5 + fmod(abs(hash_val) / 500000.0, 0.3)  # 0.5-0.8
	var value = 0.6 + fmod(abs(hash_val) / 300000.0, 0.2)       # 0.6-0.8

	return Color.from_hsv(hue, saturation, value)


## Save custom colors to a config file.
static func save_custom_colors(path: String = "user://dialogue_editor_colors.cfg") -> Error:
	var config = ConfigFile.new()

	for speaker in _custom_colors:
		config.set_value("colors", speaker, _custom_colors[speaker].to_html())

	return config.save(path)


## Load custom colors from a config file.
static func load_custom_colors(path: String = "user://dialogue_editor_colors.cfg") -> Error:
	var config = ConfigFile.new()
	var err = config.load(path)

	if err != OK:
		return err

	_custom_colors.clear()

	for speaker in config.get_section_keys("colors"):
		var color_html = config.get_value("colors", speaker, "")
		if not color_html.is_empty():
			_custom_colors[speaker] = Color.html(color_html)

	return OK


## Reset all custom colors to defaults.
static func reset_to_defaults() -> void:
	_custom_colors.clear()
