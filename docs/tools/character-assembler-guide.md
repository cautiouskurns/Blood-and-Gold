# Character Assembler User Guide

A complete guide to creating animated pixel art characters using the Procedural Character Assembler editor plugin.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Interface Overview](#interface-overview)
3. [Creating Your First Character](#creating-your-first-character)
4. [Shape Tools](#shape-tools)
5. [Body Part Tagging](#body-part-tagging)
6. [Pose Creation](#pose-creation)
7. [Animation Generation](#animation-generation)
8. [Direction Variants](#direction-variants)
9. [Exporting](#exporting)
10. [Shape Library](#shape-library)
11. [Tips & Best Practices](#tips--best-practices)
12. [Troubleshooting](#troubleshooting)
13. [Keyboard Shortcuts](#keyboard-shortcuts)

---

## Getting Started

### What is the Character Assembler?

The Character Assembler is a Godot editor plugin that lets you create animated pixel art characters by assembling geometric shapes. Instead of drawing every pixel, you place rectangles, circles, ellipses, and triangles to build a character, then tag them as body parts to enable animation.

**Key Benefits:**
- Create a complete 4-direction character with animations in 30-40 minutes
- Perfect frame-to-frame consistency (no pixel wobble)
- No drawing skills required
- Reusable shape groups for armor, weapons, accessories

### Opening the Character Assembler

1. Open your Godot project
2. Enable the plugin in Project > Project Settings > Plugins
3. Click on "Character Assembler" in the main screen tabs (next to 2D, 3D, Script, etc.)

---

## Interface Overview

```
┌────────────────────────────────────────────────────────────────────────────┐
│ [New] [Open] [Save] [Save As] | [Undo] [Redo] | Reference: [Load] [Clear] │
├──────────────────┬─────────────────────────────────┬───────────────────────┤
│                  │                                 │                       │
│  SHAPE TOOLS     │         CANVAS                  │    RIGHT PANEL        │
│  ────────────    │                                 │    ───────────        │
│  • Rectangle     │    ┌─────────────────────┐      │    • Layers           │
│  • Circle        │    │                     │      │    • Shape Properties │
│  • Ellipse       │    │   Your character    │      │    • Directions       │
│  • Triangle      │    │   appears here      │      │    • Body Part Tagger │
│                  │    │                     │      │    • Pose Editor      │
│  SHAPE LIBRARY   │    └─────────────────────┘      │    • Animation Gen    │
│  ────────────    │                                 │    • Export           │
│  • Built-in      │    [Fit] [1x] [2x] [4x] [8x]   │                       │
│  • My Groups     │    [Grid] [Snap]                │                       │
│                  │                                 │                       │
└──────────────────┴─────────────────────────────────┴───────────────────────┤
│ Project: character_name* | Canvas: 64x64 | Shapes: 42 | Body Parts: 12/14 │
└────────────────────────────────────────────────────────────────────────────┘
```

### Panel Descriptions

| Panel | Purpose |
|-------|---------|
| **Toolbar** | File operations, undo/redo, reference image controls |
| **Shape Tools** | Select shape type and color for drawing |
| **Shape Library** | Save and load reusable shape groups |
| **Canvas** | Main workspace where you build your character |
| **Layers** | Manage shape z-order (front/back) |
| **Shape Properties** | Edit selected shape's position, size, rotation, color |
| **Directions** | Manage 8 directional views of your character |
| **Body Part Tagger** | Assign shapes to body parts with pivots |
| **Pose Editor** | Create and edit poses |
| **Animation Generator** | Generate animations from poses |
| **Export** | Export sprite sheets and Godot scenes |

---

## Creating Your First Character

### Step 1: Project Setup (2-3 minutes)

1. **New Project**: Click "New" to start fresh (or open an existing `.charproj` file)

2. **Load a Reference Image** (optional but recommended):
   - Click "Load..." next to Reference
   - Select a PNG/JPG image of your character concept
   - Adjust the "Opacity" slider to see through the reference while drawing

3. **Set Canvas Size**:
   - Default is 64x64 pixels
   - Use the "Canvas" spinbox to adjust (16-128px)
   - Smaller = more stylized, larger = more detailed

### Step 2: Draw Shapes (10-15 minutes)

1. **Select a Shape Tool**:
   - Click Rectangle (R), Circle (C), Ellipse (E), or Triangle (T)
   - Or use keyboard shortcuts

2. **Pick a Color**:
   - Use the color picker in the Shape Tools panel
   - Select from kingdom palettes for consistency

3. **Draw on Canvas**:
   - Click and drag to create a shape
   - Shapes snap to 8px grid by default (toggle with "Snap" checkbox)

4. **Select & Modify Shapes**:
   - Press V for Select tool
   - Click a shape to select it
   - Shift+click to select multiple shapes
   - Drag to move selected shapes
   - Drag corner handles to resize

5. **Layer Ordering**:
   - Use the Layer panel to see all shapes
   - Click "Up" or "Down" to change z-order
   - Back parts should be behind front parts

**Tip**: Build your character from back to front: legs first, then torso, then arms, then head.

### Step 3: Tag Body Parts (5-8 minutes)

This is the crucial step that makes your character animatable.

1. **Select Shapes** for a body part (e.g., all shapes that make up the torso)

2. **Open Body Part Tagger** panel on the right

3. **Choose Body Part** from the dropdown (e.g., "Torso")

4. **Click "Set Pivot"** and click on the canvas where the rotation point should be:
   - Torso: center of body
   - Upper Arm: shoulder joint
   - Lower Arm: elbow joint
   - Hand: wrist
   - Upper Leg: hip joint
   - Lower Leg: knee
   - Foot: ankle
   - Head: base of neck

5. **Click "Assign"** to link the shapes to that body part

6. **Repeat** for all 14 body parts:
   ```
   Character
   ├─ Head (pivot: neck)
   ├─ Torso (pivot: center) ← ROOT
   ├─ Left Arm
   │  ├─ L Upper Arm (pivot: shoulder)
   │  ├─ L Lower Arm (pivot: elbow)
   │  └─ L Hand (pivot: wrist)
   ├─ Right Arm (same structure)
   ├─ Left Leg
   │  ├─ L Upper Leg (pivot: hip)
   │  ├─ L Lower Leg (pivot: knee)
   │  └─ L Foot (pivot: ankle)
   └─ Right Leg (same structure)
   ```

### Step 4: Create Poses (5-10 minutes)

Poses define key positions of your character. Animations interpolate between poses.

1. **Open Pose Editor** panel

2. **Create Poses** by clicking "+ New Pose":
   - **Idle**: All rotations at 0° (neutral stance)
   - **Walk_Left**: Left leg forward (+30°), right leg back (-20°), opposite arms
   - **Walk_Right**: Mirror of Walk_Left
   - **Attack_Windup**: Weapon arm raised (+90°), slight torso rotation (-10°)
   - **Attack_Swing**: Weapon arm swung down (-120°), torso follows (+20°)
   - **Hurt**: Torso tilted back (-15°), arms slightly raised
   - **Death**: Torso collapsed (+45°), limbs splayed

3. **Adjust Rotations** using the sliders for each body part

4. **Preview** appears live on the canvas as you adjust

### Step 5: Generate Animations (2-3 minutes)

1. **Open Animation Generator** panel

2. **Select a Template** (e.g., "Walk Cycle")

3. **Assign Your Poses** to the template's required slots:
   - Walk Cycle needs: Idle, Walk_Left, Walk_Right

4. **Configure Settings**:
   - Frame count (default varies by template)
   - FPS (8, 12, or 24)
   - Loop (on/off)

5. **Click "Generate"** to create the animation

6. **Preview** the animation using Play/Pause controls

7. **Repeat** for other animations (idle, attack, hurt, death)

### Step 6: Export (1-2 minutes)

1. **Open Export** panel

2. **Set Character Name** (used in file names)

3. **Choose Output Directory**

4. **Select Export Formats**:
   - Sprite Sheet (PNG): All frames in a grid
   - Individual Frames (PNG): Separate file per frame
   - Godot Scene (.tscn): Ready-to-use AnimatedSprite2D
   - Metadata (JSON): Frame data for custom use

5. **Click "Export"**

---

## Shape Tools

### Available Shapes

| Shape | Shortcut | Best Used For |
|-------|----------|---------------|
| Rectangle | R | Torso, limbs, weapons, shields |
| Circle | C | Heads, joints, buttons, eyes |
| Ellipse | E | Torso, heads (longer/shorter), shields |
| Triangle | T | Feet, weapon tips, decorations |

### Color Palettes

The Character Assembler includes 6 kingdom-themed color palettes:

- **Ironmark**: Grays, steel blues (industrial/military)
- **Silvermere**: Silvers, whites, light blues (noble/magical)
- **Thornwood**: Browns, greens, earth tones (forest/ranger)
- **Sunspire**: Golds, reds, warm tones (royal/zealot)
- **Bandits**: Dark reds, blacks, muted colors (outlaws)
- **Basic**: Standard primary colors

### Shape Properties

When a shape is selected, you can edit:

| Property | Description |
|----------|-------------|
| Position X/Y | Location on canvas (in pixels) |
| Width/Height | Size of the shape |
| Rotation | Angle in degrees (-180 to +180) |
| Color | RGBA color picker |

---

## Body Part Tagging

### The 14 Body Parts

```
                    ┌───────┐
                    │ Head  │
                    └───┬───┘
    ┌─────────┐         │         ┌─────────┐
    │L U.Arm  ├─────────┼─────────┤ R U.Arm │
    └────┬────┘    ┌────┴────┐    └────┬────┘
         │         │  Torso  │         │
    ┌────┴────┐    └────┬────┘    ┌────┴────┐
    │L L.Arm  │         │         │ R L.Arm │
    └────┬────┘    ┌────┴────┐    └────┬────┘
    ┌────┴────┐    │ L U.Leg │    ┌────┴────┐
    │ L Hand  │    └────┬────┘    │ R Hand  │
    └─────────┘    ┌────┴────┐    └─────────┘
                   │ L L.Leg │
              ┌────┴────┐    └────┬────┐
              │ L Foot  │    │ R U.Leg │ (etc.)
              └─────────┘    └─────────┘
```

### Parent-Child Relationships

Body parts inherit rotation from their parents:
- Rotating the **Torso** rotates the entire character
- Rotating an **Upper Arm** also rotates the Lower Arm and Hand
- Rotating a **Lower Leg** also rotates the Foot

### Pivot Points

The pivot point determines where a body part rotates from:

| Body Part | Pivot Location |
|-----------|----------------|
| Torso | Center of body |
| Head | Base of neck |
| Upper Arms | Shoulder joint |
| Lower Arms | Elbow joint |
| Hands | Wrist |
| Upper Legs | Hip joint |
| Lower Legs | Knee |
| Feet | Ankle |

**Tip**: Zoom in (4x or 8x) when setting pivot points for precision.

### Validation

The Body Part Tagger shows validation status:
- ✓ Green checkmark: Body part fully configured
- ⚠ Warning: Missing pivot point or shapes
- ❌ Error: Configuration problem (e.g., circular parent reference)

---

## Pose Creation

### Standard Poses

Every character should have these basic poses:

| Pose | Description | Key Rotations |
|------|-------------|---------------|
| Idle | Neutral stance | All at 0° |
| Walk_Left | Left foot forward | L Leg +30°, R Leg -20°, arms opposite |
| Walk_Right | Right foot forward | Mirror of Walk_Left |
| Attack_Windup | Preparing to strike | Weapon arm +90°, torso -10° |
| Attack_Swing | Executing attack | Weapon arm -120°, torso +20° |
| Hurt | Taking damage | Torso -15°, head -5°, arms +20° |
| Death | Fallen | Torso +45°, limbs splayed |

### Pose Operations

- **Duplicate**: Copy a pose to create a variant
- **Mirror L↔R**: Swap left and right rotations
- **Reset All**: Return all rotations to 0°
- **Delete**: Remove the pose

---

## Animation Generation

### Built-in Templates

| Template | Required Poses | Output Frames | Loop |
|----------|----------------|---------------|------|
| Walk Cycle | Idle, Walk_Left, Walk_Right | 8 | Yes |
| Run Cycle | Idle, Walk_Left, Walk_Right | 8 | Yes |
| Idle Breathing | Idle | 4 | Yes |
| Attack | Idle, Attack_Windup, Attack_Swing | 6 | No |
| Hurt Recoil | Idle, Hurt | 3 | No |
| Death | Idle, Death | 6 | No |
| Victory | Idle | 4 | No |
| Jump | Idle | 6 | No |

### How Animation Works

Animations interpolate between poses:

```
Walk Animation (8 frames):
Frame 1: 100% Idle
Frame 2: 75% Idle + 25% Walk_Left
Frame 3: 50% Idle + 50% Walk_Left
Frame 4: 25% Idle + 75% Walk_Left
Frame 5: 100% Walk_Left
Frame 6: 50% Walk_Left + 50% Walk_Right
Frame 7: 100% Walk_Right
Frame 8: 50% Walk_Right + 50% Idle
→ Loop back to Frame 1
```

### Animation Preview

- **Play/Pause**: Toggle animation playback
- **Frame Slider**: Scrub through frames manually
- **FPS**: Adjust playback speed

---

## Direction Variants

### The 8 Directions

```
        N (North - back)
    NW      |      NE
       \    |    /
        \   |   /
W ──────── ● ──────── E
        /   |   \
       /    |    \
    SW      |      SE
        S (South - front)
```

### Generation Methods

| Method | Quality | Time | Use When |
|--------|---------|------|----------|
| Auto-flip | Basic | Instant | Quick placeholder, symmetric characters |
| Copy & Edit | Good | +5 min | Most characters (recommended) |
| Full Manual | Best | +15 min | Hero characters, asymmetric designs |

### Recommended Workflow

1. **South (Front)**: Design fully (this is your primary view)
2. **North (Back)**: Copy from South, adjust back details
3. **East (Side)**: Design side profile (important for readability)
4. **West**: Flip from East
5. **Diagonals** (optional): Generate from adjacent views

---

## Exporting

### Export Formats

| Format | File Type | Use Case |
|--------|-----------|----------|
| Sprite Sheet | PNG | Game engines, most versatile |
| Individual Frames | PNG | Custom animation systems |
| Godot Scene | .tscn + .tres | Drop into Godot project |
| Metadata | JSON | Custom tools, data analysis |

### Sprite Sheet Layout

Frames are arranged in a grid:
```
[idle_1][idle_2][idle_3][idle_4]
[walk_1][walk_2][walk_3][walk_4][walk_5][walk_6][walk_7][walk_8]
[attack_1][attack_2][attack_3][attack_4][attack_5][attack_6]
```

### Export Settings

| Setting | Options | Description |
|---------|---------|-------------|
| Scale | 1x, 2x, 4x, 8x | Output resolution multiplier |
| Background | Transparent, Solid | Transparency or solid color |
| All Directions | On/Off | Export all 8 directions or just current |

---

## Shape Library

### Using the Shape Library

The Shape Library lets you save and reuse groups of shapes.

**Built-in Groups**:
- Humanoid Base: Basic body structure
- Knight Armor: Chest plate, shoulder pads, etc.
- Sword: Simple blade shape
- Shield: Rounded shield
- Staff: Wizard's staff

**Saving Your Own**:
1. Select shapes on the canvas
2. Click "Save Selection as Group" in the Shape Library
3. Name your group and choose a category
4. Group is saved for future use

**Using Groups**:
1. Find a group in the library browser
2. Click to select it
3. Click "Insert" to add to canvas
4. Shapes are automatically scaled to your canvas size

### Categories

- **Body**: Base character shapes
- **Armor**: Protective gear
- **Weapons**: Swords, staffs, bows
- **Accessories**: Cloaks, jewelry, pouches
- **Custom**: Your saved groups

---

## Tips & Best Practices

### Design Tips

1. **Start Simple**: Begin with basic shapes, add detail later
2. **Use Reference**: Load a concept sketch as reference
3. **Build Back-to-Front**: Create legs, then torso, then arms, then head
4. **Keep It Chunky**: Pixel art works best with bold, simple shapes
5. **Consistent Style**: Use the same palette and shape sizes across characters

### Rigging Tips

1. **Pivot Precision**: Zoom in when setting pivots
2. **Test Early**: Try a simple pose before tagging all parts
3. **Check Hierarchy**: Make sure parent-child relationships make sense
4. **Torso First**: Always tag the Torso first (it's the root)

### Animation Tips

1. **Start with Walk**: If walk looks good, everything else will too
2. **Subtle is Better**: Small rotations look more natural
3. **Test All Poses**: Preview each pose before generating animations
4. **Watch Joints**: Pivot points should be at natural joint locations

### Performance Tips

1. **Fewer Shapes**: 40-60 shapes is ideal; 100+ may slow preview
2. **Save Often**: Use Ctrl+S regularly
3. **Auto-Save**: The plugin auto-saves every 5 minutes to prevent loss

---

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Shapes not visible | Check layer order; shape may be behind others |
| Animation looks wrong | Verify pivot points are at joints |
| Can't select shape | Switch to Select tool (V) |
| Export button disabled | Ensure character name and output path are set |
| Reference image too dark | Increase reference opacity slider |
| Shapes not snapping | Enable "Snap" checkbox |

### Error Messages

| Message | Meaning | Fix |
|---------|---------|-----|
| "No animations to export" | No animations have been generated | Generate at least one animation first |
| "Pivot point not set" | Body part missing pivot | Click "Set Pivot" and click on canvas |
| "No shapes assigned" | Body part has no shapes | Select shapes and assign to part |
| "Character name required" | Export needs a name | Enter a name in Export panel |

### Recovery

If the editor crashes:
1. Reopen the Character Assembler
2. A recovery dialog will appear if auto-save data exists
3. Click "Recover" to restore your work
4. Save immediately with Ctrl+S

---

## Keyboard Shortcuts

See the full list in [character-assembler-shortcuts.md](./character-assembler-shortcuts.md).

### Essential Shortcuts

| Shortcut | Action |
|----------|--------|
| Ctrl+N | New project |
| Ctrl+O | Open project |
| Ctrl+S | Save project |
| Ctrl+Shift+S | Save As |
| Ctrl+Z | Undo |
| Ctrl+Y / Ctrl+Shift+Z | Redo |
| V | Select tool |
| R | Rectangle tool |
| C | Circle tool |
| E | Ellipse tool |
| T | Triangle tool |
| Delete | Delete selected shapes |
| Shift+Click | Multi-select shapes |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                 CHARACTER ASSEMBLER                          │
│                   Quick Reference                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  WORKFLOW:                                                   │
│  1. Load reference → Set canvas size                        │
│  2. Draw shapes → Arrange layers                            │
│  3. Tag body parts → Set pivots                             │
│  4. Create poses → Test rotations                           │
│  5. Generate animations → Preview                           │
│  6. Export → Sprite sheets & Godot scene                    │
│                                                              │
│  TIME ESTIMATE: 30-40 minutes per character                 │
│                                                              │
│  TOOLS: V=Select  R=Rect  C=Circle  E=Ellipse  T=Triangle  │
│                                                              │
│  BODY PARTS (14):                                            │
│  Head, Torso, L/R Upper Arm, L/R Lower Arm, L/R Hand,       │
│  L/R Upper Leg, L/R Lower Leg, L/R Foot                     │
│                                                              │
│  STANDARD POSES (7):                                         │
│  Idle, Walk_Left, Walk_Right, Attack_Windup,                │
│  Attack_Swing, Hurt, Death                                  │
│                                                              │
│  ANIMATION TEMPLATES (8):                                    │
│  Walk, Run, Idle, Attack, Hurt, Death, Victory, Jump        │
│                                                              │
│  EXPORT: PNG sprite sheet, Individual frames, Godot .tscn   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Getting Help

- **Tooltips**: Hover over any UI element for helpful tips
- **Example Characters**: File > Load Example to see completed characters
- **GitHub Issues**: Report bugs at the project repository
- **Documentation**: This guide and the shortcuts reference

---

*Document Version: 1.0 | Last Updated: January 2026*
