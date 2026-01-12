# Blood & Gold - Development Rules

This file defines project-wide conventions and rules for Claude Code to follow when working on this Godot 4.x tactical CRPG prototype.

---

## Scene vs Programmatic Creation

- **Prefer scenes (.tscn)** for all game objects that exist at design time
- Only create objects programmatically when they MUST spawn at runtime:
  - Projectiles
  - Spawned enemies during combat
  - Particle effects
  - Dynamically generated UI elements
- If something CAN be a scene, it SHOULD be a scene
- Scenes are easier to edit, preview, and iterate on in the Godot editor

---

## Project Structure

Follow the established folder structure:
- `scenes/` - All .tscn scene files, organized by category
- `scripts/` - All .gd script files, mirroring scene organization
- `resources/` - .tres resource files (tilesets, themes, data)
- `assets/` - Art, audio, fonts, shaders
- `docs/` - Documentation, specs, reports

---

## GDScript Conventions

- Use `class_name` for scripts that will be referenced by other scripts
- Use type hints on all function parameters and return values
- Use `@onready` for node references
- Use `@export` for inspector-configurable properties
- Prefix private methods and variables with underscore: `_private_method()`
- Use SCREAMING_SNAKE_CASE for constants
- Use snake_case for functions and variables
- Use PascalCase for class names

---

## Signal Patterns

- Define signals at the top of the class, after class_name
- Use typed signal parameters: `signal damage_taken(amount: int, source: Node)`
- Connect signals using callable syntax: `node.signal_name.connect(_on_signal_name)`
- Name signal handlers with `_on_` prefix: `_on_enemy_died()`

---

## Documentation

- Add doc comments (`##`) to public methods
- Reference the feature spec in script headers when implementing a spec
- Keep implementation reports in `docs/implementation-reports/`

---

## Testing

- Test features by running the game (F5) after implementation
- Verify acceptance criteria from feature specs
- Check for errors in the Output panel
