---
description: Set up a new Godot project with standard folder structure for scenes, scripts, assets, and resources. Creates organized directories following Godot best practices.
trigger: user
---

# Godot Project Setup Skill

You are helping set up a new Godot project with a professional, well-organized folder structure.

## How to Invoke This Skill

Users can trigger this skill by saying:
- "Set up Godot project structure"
- "Create Godot folders for a new project"
- "Use the godot-project-setup skill"
- "I need standard Godot folders"
- "Help me organize a new Godot project"

Or any similar phrase indicating they want to create a folder structure for a new Godot project.

## Objective

Create a complete folder structure for a Godot 4.x project following industry best practices, set up the main scene, and configure project settings with a default resolution of 1920x1080.

## Process

### Step 1: Determine Target Directory

Ask the user:
- "Would you like to set up the folder structure in the current directory, or specify a different path?"
- If they specify a path, verify it exists before proceeding

### Step 2: Create Core Directory Structure

Use a single `mkdir -p` command to create all directories at once for efficiency:

```bash
mkdir -p scenes/main scenes/player scenes/enemies scenes/UI scenes/levels scenes/weapons scenes/effects \
         scripts/autoload scripts/player scripts/enemies scripts/weapons scripts/systems scripts/resources scripts/utils \
         assets/sprites assets/textures assets/audio assets/fonts assets/shaders assets/animations \
         resources/themes resources/materials resources/data \
         addons \
         docs
```

### Core Directory Purposes

**scenes/** - All Godot scene files (.tscn)
- `main/` - Main game scene, entry points
- `player/` - Player character scenes and components
- `enemies/` - Enemy and NPC scenes
- `UI/` - User interface scenes (menus, HUD, dialogs)
- `levels/` - Level/arena/world scenes
- `weapons/` - Weapon and projectile scenes
- `effects/` - Visual effects, particle systems, screen effects

**scripts/** - All GDScript files (.gd)
- `autoload/` - Singleton scripts (game managers, event buses, etc.)
- `player/` - Player-related scripts
- `enemies/` - Enemy AI and behavior scripts
- `weapons/` - Weapon system scripts
- `systems/` - Core game systems (spawning, progression, wave management)
- `resources/` - Custom Resource class definitions
- `utils/` - Utility functions, helpers, extensions

**assets/** - All art and media files
- `sprites/` - 2D sprite images (PNG, SVG)
- `textures/` - Textures for materials
- `audio/` - Sound effects (SFX) and music
- `fonts/` - Font files (TTF, OTF)
- `shaders/` - Custom shader files (.gdshader)
- `animations/` - Animation data files

**resources/** - Godot resource files (.tres, .res)
- `themes/` - UI Theme resources
- `materials/` - Material resources
- `data/` - Game data resources (enemy stats, weapon configs, wave definitions)

**addons/** - Third-party plugins and editor tools

**docs/** - Project documentation, design docs, READMEs

### Step 3: Ask About Optional Directories

Ask the user: "Would you like to include optional directories for testing, exports, or custom tools?"

If yes, create:
```bash
mkdir -p tests/integration tests/unit \
         exports/windows exports/linux exports/mac exports/web \
         tools/editor_scripts
```

**tests/** - Test scenes and scripts
- `integration/` - Integration test scenes
- `unit/` - Unit test scripts

**exports/** - Build output directories (should be in .gitignore)
- Platform-specific folders for builds

**tools/** - Custom editor tools and scripts
- `editor_scripts/` - Editor plugin scripts and tools

### Step 4: Create Main Scene

Create a basic main scene file at `scenes/main/Main.tscn`:

```bash
cat > scenes/main/Main.tscn << 'EOF'
[gd_scene format=3]

[node name="Main" type="Node2D"]
EOF
```

This creates a minimal main scene with a Node2D root that can be extended as needed.

### Step 5: Configure Project Settings

If `project.godot` exists, update it to set the main scene and resolution. Otherwise, inform the user they need to create the project through Godot Editor first.

Check if project.godot exists and update it:

```bash
if [ -f project.godot ]; then
  # Set main scene if not already set
  if ! grep -q "run/main_scene=" project.godot; then
    sed -i.bak '/\[application\]/a\
run/main_scene="res://scenes/main/Main.tscn"' project.godot
  fi

  # Set resolution to 1920x1080
  if grep -q "\[display\]" project.godot; then
    # Display section exists, update or add resolution
    if ! grep -q "window/size/viewport_width=" project.godot; then
      sed -i.bak '/\[display\]/a\
window/size/viewport_width=1920\
window/size/viewport_height=1080' project.godot
    fi
  else
    # Add display section
    echo "" >> project.godot
    echo "[display]" >> project.godot
    echo "" >> project.godot
    echo "window/size/viewport_width=1920" >> project.godot
    echo "window/size/viewport_height=1080" >> project.godot
  fi

  rm -f project.godot.bak
fi
```

### Step 6: Provide Summary

After creating the structure, output:

1. **Success message** with count of directories created, confirmation that Main.tscn was created, and whether project settings were updated
2. **Tree view** of the structure (use `tree -L 2 -d` if available, or list manually)
3. **Configuration summary**:
   - Main scene: `scenes/main/Main.tscn`
   - Resolution: 1920x1080
   - Project settings updated (if project.godot existed)
4. **Next steps suggestions**:
   - Open the project in Godot Editor to verify settings
   - Consider creating a `.gitignore` file for Godot
   - Recommended .gitignore entries: `.godot/`, `*.import`, `exports/`, `.mono/`, `*.translation`
   - Set up version control with `git init` if not already initialized
   - If project.godot didn't exist, create the project through Godot Editor

5. **Quick reference** of where to put common files:
   ```
   Player scene → scenes/player/Player.tscn + scripts/player/player.gd
   Enemy data → resources/data/enemy_stats.tres
   Global manager → scripts/autoload/game_manager.gd
   UI theme → resources/themes/main_theme.tres
   Sound effects → assets/audio/sfx_*.wav
   ```

## Important Guidelines

- Use `mkdir -p` to create parent directories automatically
- Create multiple directories in parallel when possible (use single command with multiple paths)
- Verify target directory exists before proceeding
- Use relative paths from the project root
- Create the main scene file as a minimal Node2D scene
- Only modify project.godot if it exists - don't create it from scratch
- List all created directories and files at the end for user confirmation
- If the directory structure already exists, inform the user and ask if they want to:
  - Skip existing directories
  - Show what's missing and create only those
  - Cancel the operation

## Error Handling

- If target directory doesn't exist, ask user to confirm creation or provide valid path
- If some directories already exist, list them and only create missing ones
- If permission errors occur, inform user and suggest solutions

## Success Criteria

- All directories created without errors
- Main scene file created at `scenes/main/Main.tscn`
- Project settings configured with 1920x1080 resolution (if project.godot exists)
- Main scene set as the run scene in project.godot (if it exists)
- User receives clear summary of what was created and configured
- User understands the purpose of each directory
- User knows next steps for setting up their Godot project
