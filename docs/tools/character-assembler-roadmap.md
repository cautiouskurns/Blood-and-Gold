# Tool Roadmap: Procedural Character Assembler

**Spec:** `docs/tools/character-assembler-spec.md`
**Created:** January 2026
**Implementer:** Use `tool-feature-implementer` skill to build features

---

## Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  Phase 1: MVP              Phase 2: Animation      Phase 3: Polish  │
│  ─────────────             ─────────────────       ───────────────  │
│                                                                     │
│  ┌─────────────┐          ┌─────────────┐        ┌─────────────┐   │
│  │ 1.1 Plugin  │          │ 2.1 Anim    │        │ 3.1 Undo/   │   │
│  │     Setup   │          │   Templates │        │     Redo    │   │
│  └──────┬──────┘          └──────┬──────┘        └─────────────┘   │
│         │                        │                                  │
│  ┌──────▼──────┐          ┌──────▼──────┐        ┌─────────────┐   │
│  │ 1.2 Canvas  │          │ 2.2 Multi-  │        │ 3.2 Shape   │   │
│  │   + Shapes  │          │   Direction │        │   Library   │   │
│  └──────┬──────┘          └──────┬──────┘        └─────────────┘   │
│         │                        │                                  │
│  ┌──────▼──────┐          ┌──────▼──────┐        ┌─────────────┐   │
│  │ 1.3 Body    │          │ 2.3 Export  │        │ 3.3 Error   │   │
│  │   Part Tags │          │   System    │        │   Handling  │   │
│  └──────┬──────┘          └─────────────┘        └─────────────┘   │
│         │                                                           │
│  ┌──────▼──────┐                                 ┌─────────────┐   │
│  │ 1.4 Pose    │                                │ 3.4 Docs &  │   │
│  │   System    │                                │   Presets   │   │
│  └─────────────┘                                └─────────────┘   │
│                                                                     │
│  Exit: Can rig    Exit: Full character         Exit: Production    │
│  a character      with animations              ready tool          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**Goal:** Reduce character creation from 8-12 hours to 30-40 minutes by assembling shapes instead of drawing pixels.

---

## Phase 1: MVP (Core Rigging System)

**Goal:** Assemble a character from shapes and create an animatable rig with poses.

**Exit Criteria:** Can create a character with tagged body parts, define poses, and see live rotation preview.

---

### Feature 1.1: Plugin Setup & Project Structure ✅ COMPLETE

**Description:** Create the Godot editor plugin structure and main panel that will host the character assembler.

**Implementation Tasks:**
- [x] Create `addons/character_assembler/` directory structure
- [x] Create `plugin.cfg` with metadata (name, description, author, version)
- [x] Create `plugin.gd` EditorPlugin that registers main screen
- [x] Create `main_panel.tscn` as MainScreenPlugin root
- [x] Add plugin icon (using built-in Skeleton2D icon)
- [x] Create `CharacterProject` resource class for save/load

**Files Created:**
```
addons/character_assembler/
├── plugin.cfg              ✅
├── plugin.gd               ✅
├── icons/
│   └── .gitkeep            (using built-in editor icon)
├── scenes/
│   └── main_panel.tscn     ✅
├── scripts/
│   ├── main_panel.gd       ✅
│   └── character_project.gd ✅
└── resources/
    └── .gitkeep            (placeholder for future resources)
```

**Success Criteria:**
- [x] Plugin appears in Project Settings → Plugins
- [x] Plugin can be enabled/disabled without errors
- [x] Main panel appears as editor main screen tab
- [x] CharacterProject resource can be instantiated

---

### Feature 1.2: Character Canvas & Shape Tools ✅ COMPLETE

**Description:** Workspace for assembling characters from primitive shapes with reference image support.

**Dependencies:** Feature 1.1 (Plugin Setup)

**Implementation Tasks:**
- [x] Create canvas viewport (default 64x64, scalable display)
- [x] Implement reference image loading with file dialog
- [x] Add reference image opacity slider (0-100%)
- [x] Create shape drawing tool: Rectangle
- [x] Create shape drawing tool: Circle
- [x] Create shape drawing tool: Ellipse
- [x] Create shape drawing tool: Triangle
- [x] Implement shape selection (click, Shift+click for multi)
- [x] Implement shape movement (drag selected)
- [x] Implement shape resize (corner handles)
- [x] Implement shape rotation (rotation handle - via properties panel)
- [x] Create color picker with preset palettes
- [x] Implement layer system (z-order)
- [x] Add layer up/down buttons
- [x] Implement grid snap toggle (8px default)
- [x] Add zoom controls (fit, 1x, 2x, 4x, 8x)

**Files Created/Modified:**
```
addons/character_assembler/
├── scenes/
│   └── main_panel.tscn              ✅ (modified - complete UI layout)
├── scripts/
│   ├── main_panel.gd                ✅ (modified - integrates all components)
│   ├── canvas_viewport.gd           ✅ (CharacterCanvas class - ~600 lines)
│   ├── shape_tools_panel.gd         ✅ (tool buttons + keyboard shortcuts)
│   ├── layer_panel.gd               ✅ (layer list + ordering)
│   ├── shape_properties_panel.gd    ✅ (position/size/rotation/color editing)
│   └── color_palette.gd             ✅ (6 built-in kingdom palettes)
```

**Implementation Notes:**
- CharacterCanvas handles all shape rendering via `_draw()` method
- Shapes stored as dictionaries matching CharacterProject format
- Kingdom palettes: Ironmark, Silvermere, Thornwood, Sunspire, Bandits, Basic
- Tool enum: SELECT, RECTANGLE, CIRCLE, ELLIPSE, TRIANGLE
- Keyboard shortcuts: V (Select), R (Rectangle), C (Circle), E (Ellipse), T (Triangle)
- 8 resize handles around selection bounds
- Signal-based communication between components

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ [File ▼] [Edit ▼]  Reference: [Load...] Opacity: [====50%===]  │
├───────────────────────────────────────────┬─────────────────────┤
│                                           │ TOOLS               │
│                                           │ ─────               │
│  ┌─────────────────────────────────────┐  │ [■] Rectangle      │
│  │                                     │  │ [●] Circle         │
│  │         CANVAS (64x64)              │  │ [⬭] Ellipse        │
│  │                                     │  │ [▲] Triangle       │
│  │    [Reference image with           │  │                     │
│  │     shapes overlaid]               │  │ COLORS              │
│  │                                     │  │ ─────               │
│  │                                     │  │ [████] [████]      │
│  │                                     │  │ [████] [████]      │
│  └─────────────────────────────────────┘  │                     │
│                                           │ Palette: [▼]        │
│  Zoom: [Fit] [1x] [2x] [4x]  Grid: [✓]   │                     │
├───────────────────────────────────────────┼─────────────────────┤
│ LAYERS                                    │ SHAPE PROPERTIES    │
│ ─────                                     │ ─────────────────   │
│ [12] ████ Head Circle                    │ X: [32] Y: [8]      │
│ [11] ████ Head Circle 2                  │ W: [16] H: [16]     │
│ [10] ████ Torso Rect                     │ Rot: [0°]           │
│ [↑ Up] [↓ Down] [🗑 Delete]              │ Color: [████]       │
└───────────────────────────────────────────┴─────────────────────┘
```

**Success Criteria:**
- [x] Can load reference image and adjust opacity
- [x] Can draw all 4 shape types on canvas
- [x] Can select, move, resize, and rotate shapes
- [x] Can change shape colors from palette
- [x] Can reorder layers (z-order)
- [x] Grid snap works correctly
- [x] Zoom works at all levels

---

### Feature 1.3: Body Part Tagging System ✅ COMPLETE

**Description:** Tag shapes with body part names and define hierarchical parent-child relationships with pivot points.

**Dependencies:** Feature 1.2 (Canvas & Shapes)

**Implementation Tasks:**
- [x] Create body part enum/list (14 standard parts)
- [x] Create BodyPart class (name, shapes[], pivot, parent)
- [x] Implement multi-select shapes for tagging
- [x] Create body part dropdown selector
- [x] Implement click-to-set pivot point on canvas
- [x] Create parent body part dropdown
- [x] Build hierarchical tree view of current rig
- [x] Add validation: untagged shapes warning
- [x] Add validation: missing pivot warning
- [x] Add validation: circular parent reference prevention
- [x] Implement "tag all selected as X" batch operation
- [x] Add visual indicator for pivot points on canvas
- [x] Create progress indicator (X/14 body parts tagged)

**Body Part Hierarchy (14 parts):**
```
Character (root)
├─ Head (pivot: neck)
├─ Torso (pivot: waist) ← ROOT PARENT
├─ Left Arm
│  ├─ L Upper Arm (pivot: shoulder, parent: Torso)
│  ├─ L Lower Arm (pivot: elbow, parent: L Upper Arm)
│  └─ L Hand (pivot: wrist, parent: L Lower Arm)
├─ Right Arm
│  ├─ R Upper Arm (pivot: shoulder, parent: Torso)
│  ├─ R Lower Arm (pivot: elbow, parent: R Upper Arm)
│  └─ R Hand (pivot: wrist, parent: R Lower Arm)
├─ Left Leg
│  ├─ L Upper Leg (pivot: hip, parent: Torso)
│  ├─ L Lower Leg (pivot: knee, parent: L Upper Leg)
│  └─ L Foot (pivot: ankle, parent: L Lower Leg)
└─ Right Leg
   ├─ R Upper Leg (pivot: hip, parent: Torso)
   ├─ R Lower Leg (pivot: knee, parent: R Upper Leg)
   └─ R Foot (pivot: ankle, parent: R Lower Leg)
```

**Files Created/Modified:**
```
addons/character_assembler/
├── scenes/
│   └── main_panel.tscn              ✅ (modified - added BodyPartTagger)
├── scripts/
│   ├── body_part.gd                 ✅ (BodyPart class with 14 parts)
│   ├── body_part_tagger.gd          ✅ (main tagger panel UI)
│   ├── rig_tree_view.gd             ✅ (hierarchical tree display)
│   ├── rig_validator.gd             ✅ (validation logic)
│   ├── canvas_viewport.gd           ✅ (modified - pivot visualization)
│   ├── main_panel.gd                ✅ (modified - tagger integration)
│   └── character_project.gd         ✅ (modified - body parts storage)
```

**Implementation Notes:**
- BodyPart class stores part_name, shape_indices[], pivot Vector2, pivot_set bool, parent_name
- RigTreeView extends Tree with hierarchical body part display
- RigValidator provides static methods: validate(), get_configured_count(), is_animation_ready()
- Canvas displays pivot points as crosshair + circle with part name label
- Pivot mode allows clicking canvas to set pivot point
- Highlighting shows shapes belonging to selected body part
- Signal-based communication: body_parts_changed, pivot_mode_changed, body_part_selected

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ BODY PART TAGGER                                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Selected Shapes: [6 shapes selected]                           │
│                                                                 │
│ Assign to Body Part: [Torso ▼]                                 │
│                                                                 │
│ Pivot Point: X [32] Y [28]  [⊕ Click on Canvas to Set]        │
│                                                                 │
│ Parent Body Part: [None (Root) ▼]                              │
│                                                                 │
│ [Apply Tags to Selected]                                        │
│                                                                 │
│ ────────────────────────────────────────────────────────────── │
│ CURRENT RIG:                           VALIDATION:              │
│ └─ Torso (6 shapes) ✓                 ✓ All shapes tagged      │
│    ├─ Head (8 shapes) ✓               ✓ All pivots set         │
│    ├─ L Upper Arm (4 shapes) ✓        ⚠ L Hand missing pivot  │
│    │  └─ L Lower Arm (4 shapes) ✓     ❌ R Leg unassigned      │
│    │     └─ L Hand (3 shapes) ⚠                                │
│    ├─ R Upper Arm (4 shapes) ✓                                 │
│    │  └─ R Lower Arm (4 shapes) ✓                              │
│    └─ L Upper Leg (unassigned) ❌                               │
│                                                                 │
│ Progress: [=========70%=========] 10/14 body parts             │
└─────────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [x] Can select shapes and assign to body part
- [x] Can set pivot point by clicking on canvas
- [x] Can set parent body part from dropdown
- [x] Tree view shows current rig hierarchy
- [x] Validation warnings appear for issues
- [x] Progress indicator shows completion status
- [x] Pivot points display on canvas when body part selected

---

### Feature 1.4: Pose System

**Description:** Define key poses by rotating body parts, with live preview on canvas.

**Dependencies:** Feature 1.3 (Body Part Tagging)

**Implementation Tasks:**
- [ ] Create Pose class (name, rotations dictionary)
- [ ] Create pose list panel (saved poses)
- [ ] Implement "New Pose" with name input
- [ ] Create rotation slider for each body part (-180° to +180°)
- [ ] Implement hierarchical rotation (parent pulls children)
- [ ] Create live preview renderer on canvas
- [ ] Implement "Reset" button (all rotations to 0°)
- [ ] Implement "Reset Part" button (single part to 0°)
- [ ] Implement "Duplicate Pose" feature
- [ ] Implement "Mirror Pose" (swap L/R rotations)
- [ ] Implement "Delete Pose" with confirmation
- [ ] Add pose quick-select buttons at bottom
- [ ] Create default poses: Idle, Walk_L, Walk_R, Attack_Windup, Attack_Swing, Hurt, Death

**Rotation Algorithm:**
```gdscript
func apply_pose_to_canvas(pose: Pose):
    # Start from root (Torso)
    var processed = {}
    _apply_rotation_recursive("Torso", 0.0, processed, pose)

func _apply_rotation_recursive(part_name: String, parent_rotation: float, processed: Dictionary, pose: Pose):
    if part_name in processed:
        return
    processed[part_name] = true

    var body_part = body_parts[part_name]
    var local_rotation = pose.rotations.get(part_name, 0.0)
    var world_rotation = parent_rotation + local_rotation

    # Rotate all shapes in this body part around pivot
    for shape_idx in body_part.shapes:
        var shape = shapes[shape_idx]
        rotate_shape_around_pivot(shape, body_part.pivot, world_rotation)

    # Recurse to children
    for child_name in get_children_of(part_name):
        _apply_rotation_recursive(child_name, world_rotation, processed, pose)
```

**Files to Create/Modify:**
```
addons/character_assembler/
├── scenes/
│   ├── main_panel.tscn (modify - add pose panel)
│   └── pose_editor.tscn
├── scripts/
│   ├── pose_editor.gd
│   ├── pose.gd (Pose class)
│   ├── pose_renderer.gd
│   └── rotation_slider.gd
└── resources/
    └── default_poses/
        ├── idle.tres
        ├── walk_left.tres
        ├── walk_right.tres
        ├── attack_windup.tres
        ├── attack_swing.tres
        ├── hurt.tres
        └── death.tres
```

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ POSE EDITOR                                                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Current Pose: [Walk_Left ▼]  [+ New] [📋 Duplicate] [🗑 Delete]│
│                                                                 │
│ ROTATIONS:                      PREVIEW:                        │
│                                 ┌─────────────────┐             │
│ Head:        [========0°=====] │                 │             │
│ Torso:       [========0°=====] │   [Character    │             │
│ L Upper Arm: [=====-15°======] │    in current   │             │
│ L Lower Arm: [======+5°======] │    pose]        │             │
│ L Hand:      [========0°=====] │                 │             │
│ R Upper Arm: [=====+15°======] │                 │             │
│ R Lower Arm: [======-5°======] └─────────────────┘             │
│ R Hand:      [========0°=====]                                  │
│ L Upper Leg: [=====+30°======] ← Adjusted                      │
│ L Lower Leg: [=====-20°======] ← Adjusted                      │
│ L Foot:      [=====+10°======]                                  │
│ R Upper Leg: [=====-20°======]                                  │
│ R Lower Leg: [=====-10°======]                                  │
│ R Foot:      [========0°=====]                                  │
│                                                                 │
│ [Reset All] [Mirror L↔R]                                       │
│                                                                 │
│ SAVED POSES:                                                    │
│ [Idle] [Walk_L] [Walk_R] [Atk_Wind] [Atk_Swing] [Hurt] [Death] │
└─────────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [ ] Can create new pose with custom name
- [ ] Rotation sliders work for all body parts
- [ ] Preview updates live as sliders move
- [ ] Hierarchical rotation works (rotate torso moves arms)
- [ ] Can duplicate existing pose
- [ ] Mirror pose swaps left/right correctly
- [ ] Can switch between saved poses instantly
- [ ] Default poses load correctly

---

### Phase 1 Complete Checklist

- [ ] Plugin installs and enables without errors
- [ ] Can load reference image with opacity control
- [ ] Can draw and manipulate all 4 shape types
- [ ] Can tag shapes to 14 body parts
- [ ] Can set pivot points for all body parts
- [ ] Can create and edit poses with rotation sliders
- [ ] Live preview shows posed character
- [ ] Can save/load CharacterProject

**Phase 1 Exit Test:**
Create a simple stick figure character (20 shapes), tag all body parts, create Idle and Walk_Left poses, see character animate between them in preview.

---

## Phase 2: Animation & Export

**Goal:** Generate animations from poses and export game-ready assets.

**Prerequisites:** Phase 1 complete (can create rigged character with poses)

---

### Feature 2.1: Animation Templates

**Description:** Pre-built animation logic that interpolates between poses to generate frame sequences.

**Dependencies:** Feature 1.4 (Pose System)

**Implementation Tasks:**
- [ ] Create Animation class (name, template, frames, fps, loop, pose_assignments)
- [ ] Create AnimationTemplate class (name, required_poses[], frame_sequence[])
- [ ] Implement linear interpolation between poses
- [ ] Create 8 built-in templates:
  - Walk Cycle (8 frames): Idle → Walk_L → Walk_R → Idle
  - Run Cycle (8 frames): Same but faster transitions
  - Idle Breathing (4 frames): Subtle torso movement
  - Attack (6 frames): Idle → Windup → Swing → Idle
  - Hurt Recoil (3 frames): Idle → Hurt → Idle
  - Death (6 frames): Idle → Death (no loop)
  - Victory (4 frames): Subtle celebration
  - Jump (6 frames): Crouch → Up → Down → Land
- [ ] Create template selector UI
- [ ] Create pose assignment UI (map user poses to template slots)
- [ ] Implement frame count adjustment
- [ ] Implement FPS adjustment (8, 12, 15, 24)
- [ ] Create animation preview player (play/pause/scrub)
- [ ] Add timeline with frame indicators
- [ ] Implement "Generate Animation" button
- [ ] Store generated frame data for export

**Interpolation Algorithm:**
```gdscript
func generate_animation_frames(animation: Animation) -> Array[Dictionary]:
    var template = get_template(animation.template)
    var frames = []

    for frame_def in template.frame_sequence:
        var blended_rotations = {}

        # Blend between poses based on weights
        for pose_slot in frame_def.pose_weights:
            var user_pose = animation.pose_assignments[pose_slot]
            var weight = frame_def.pose_weights[pose_slot]

            for body_part in user_pose.rotations:
                if body_part not in blended_rotations:
                    blended_rotations[body_part] = 0.0
                blended_rotations[body_part] += user_pose.rotations[body_part] * weight

        frames.append(blended_rotations)

    return frames
```

**Walk Cycle Template Definition:**
```gdscript
var walk_cycle_template = {
    "name": "Walk Cycle",
    "required_poses": ["idle", "walk_left", "walk_right"],
    "frame_count": 8,
    "loop": true,
    "frame_sequence": [
        {"pose_weights": {"idle": 1.0}},                           # Frame 1
        {"pose_weights": {"idle": 0.5, "walk_left": 0.5}},         # Frame 2
        {"pose_weights": {"walk_left": 1.0}},                      # Frame 3
        {"pose_weights": {"walk_left": 0.5, "walk_right": 0.5}},   # Frame 4
        {"pose_weights": {"walk_right": 1.0}},                     # Frame 5
        {"pose_weights": {"walk_right": 0.5, "idle": 0.5}},        # Frame 6
        {"pose_weights": {"idle": 0.75, "walk_left": 0.25}},       # Frame 7
        {"pose_weights": {"idle": 1.0}},                           # Frame 8
    ]
}
```

**Files to Create/Modify:**
```
addons/character_assembler/
├── scenes/
│   ├── main_panel.tscn (modify - add animation panel)
│   └── animation_generator.tscn
├── scripts/
│   ├── animation_generator.gd
│   ├── animation.gd (Animation class)
│   ├── animation_template.gd (AnimationTemplate class)
│   ├── pose_interpolator.gd
│   └── animation_preview.gd
└── resources/
    └── animation_templates/
        ├── walk_cycle.tres
        ├── run_cycle.tres
        ├── idle_breathing.tres
        ├── attack.tres
        ├── hurt_recoil.tres
        ├── death.tres
        ├── victory.tres
        └── jump.tres
```

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ ANIMATION GENERATOR                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Template: [Walk Cycle ▼]                                       │
│                                                                 │
│ REQUIRED POSES:                    PREVIEW:                     │
│ • Idle:       [Idle ▼]     ✓      ┌─────────────────┐          │
│ • Walk_Left:  [Walk_L ▼]   ✓      │                 │          │
│ • Walk_Right: [Walk_R ▼]   ✓      │  [Animating     │          │
│                                    │   character]    │          │
│ SETTINGS:                          │                 │          │
│ Frames: [8]  FPS: [12]  Loop: [✓] └─────────────────┘          │
│                                                                 │
│ [Generate Animation]               [▶ Play] [⏸ Pause]          │
│                                    Frame: [3/8]                 │
│ TIMELINE:                                                       │
│ [1][2][●][4][5][6][7][8]                                       │
│                                                                 │
│ ────────────────────────────────────────────────────────────── │
│ GENERATED ANIMATIONS:                                           │
│ ✓ walk_cycle (8 frames, 12 FPS)                                │
│ ✓ idle_breathing (4 frames, 6 FPS)                             │
│ ○ attack (not generated)                                        │
│ ○ hurt (not generated)                                          │
│ ○ death (not generated)                                         │
│                                                                 │
│ [Generate All]  [Export Animations]                             │
└─────────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [ ] Can select animation template
- [ ] Can assign user poses to template slots
- [ ] Can adjust frame count and FPS
- [ ] Animation preview plays smoothly
- [ ] Can scrub through timeline
- [ ] Generated animations store correctly
- [ ] All 8 templates work correctly

---

### Feature 2.2: Multi-Direction Support

**Description:** Generate 4 directional variants (South, North, East, West) from base character.

**Dependencies:** Feature 2.1 (Animation Templates)

**Implementation Tasks:**
- [ ] Create DirectionView class (direction, shapes[], overrides)
- [ ] Implement view switcher tabs (South, North, East, West)
- [ ] Implement "Copy from South" for body part tags and pivots
- [ ] Implement auto-flip horizontal (East → West)
- [ ] Implement auto-flip vertical (South → North) with adjustments
- [ ] Create semi-manual mode (copy tags, adjust shapes)
- [ ] Create full-manual mode (design each view separately)
- [ ] Add "Generate All Directions" batch button
- [ ] Implement direction-specific pose overrides (optional)
- [ ] Create 4-up preview showing all directions
- [ ] Implement per-direction animation generation

**Generation Methods:**
| Method | Quality | Workflow |
|--------|---------|----------|
| Auto-flip | Low | Click "Generate All" - instant |
| Semi-manual | Medium | Design South & East, auto-generate North & West |
| Full-manual | High | Design all 4 views separately |

**Files to Create/Modify:**
```
addons/character_assembler/
├── scenes/
│   ├── main_panel.tscn (modify - add direction tabs)
│   └── direction_manager.tscn
├── scripts/
│   ├── direction_manager.gd
│   ├── direction_view.gd (DirectionView class)
│   ├── auto_flip.gd
│   └── four_up_preview.gd
```

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ DIRECTION VARIANTS                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Views: [South ●] [North ○] [East ○] [West ○]                   │
│                                                                 │
│ Current: South (Front View) - PRIMARY                           │
│                                                                 │
│ 4-UP PREVIEW:                                                   │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                │
│ │  SOUTH  │ │  NORTH  │ │  EAST   │ │  WEST   │                │
│ │   ✓     │ │   ○     │ │   ○     │ │   ○     │                │
│ │ [front] │ │ [back]  │ │ [side]  │ │ [side]  │                │
│ │ [img]   │ │ [img]   │ │ [img]   │ │ [img]   │                │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘                │
│                                                                 │
│ GENERATION MODE:                                                │
│ ○ Auto-flip all (fast, lower quality)                          │
│ ● Semi-manual (recommended)                                     │
│ ○ Full manual (highest quality)                                │
│                                                                 │
│ COPY FROM SOUTH:                                                │
│ [✓] Body part tags & pivots                                    │
│ [✓] Poses                                                      │
│ [ ] Shape positions (manual per view)                          │
│                                                                 │
│ [Switch to East View]  [Generate All Directions]               │
└─────────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [ ] Can switch between 4 direction views
- [ ] Body part tags copy to other views
- [ ] Auto-flip generates reasonable results
- [ ] Can manually adjust shapes per view
- [ ] 4-up preview shows all directions
- [ ] Animations generate for all directions

---

### Feature 2.3: Export System

**Description:** Output game-ready assets in multiple formats (sprite sheets, PNGs, Godot scenes).

**Dependencies:** Feature 2.1 (Animation Templates), Feature 2.2 (Multi-Direction)

**Implementation Tasks:**
- [ ] Create export settings panel
- [ ] Implement sprite sheet generator (grid layout PNG)
- [ ] Implement individual frame exporter (named PNGs)
- [ ] Implement Godot AnimatedSprite2D scene generator (.tscn)
- [ ] Implement JSON project save/load
- [ ] Add background options (transparent, solid color)
- [ ] Add scale options (1x, 2x, 4x)
- [ ] Add naming convention settings
- [ ] Create export progress dialog
- [ ] Implement batch export (all directions, all animations)
- [ ] Add export to project assets folder option

**Export Formats:**

**A. Sprite Sheet (PNG):**
```
┌────┬────┬────┬────┐
│Idl1│Idl2│Idl3│Idl4│  ← Idle animation
├────┼────┼────┼────┼────┬────┬────┬────┐
│Wlk1│Wlk2│Wlk3│Wlk4│Wlk5│Wlk6│Wlk7│Wlk8│  ← Walk animation
├────┼────┼────┼────┼────┼────┼────┼────┘
│Atk1│Atk2│Atk3│Atk4│Atk5│Atk6│
└────┴────┴────┴────┴────┴────┘
```

**B. Individual Frames:**
```
thorne_south_idle_001.png
thorne_south_idle_002.png
thorne_south_walk_001.png
...
thorne_east_attack_003.png
```

**C. Godot AnimatedSprite2D Scene:**
```gdscript
# Generated thorne.tscn
[gd_scene load_steps=5 format=3]

[ext_resource path="res://assets/sprites/characters/thorne_sheet.png" type="Texture2D" id="1"]

[sub_resource type="SpriteFrames" id="1"]
animations = [{
    "frames": [/* frame data */],
    "loop": true,
    "name": "idle_south",
    "speed": 6.0
}, {
    "frames": [/* frame data */],
    "loop": true,
    "name": "walk_south",
    "speed": 12.0
}, /* ... */]

[node name="Thorne" type="AnimatedSprite2D"]
sprite_frames = SubResource("1")
animation = "idle_south"
```

**D. JSON Project File:**
```json
{
    "character_id": "thorne",
    "version": "1.0",
    "canvas_size": 64,
    "shapes": [...],
    "body_parts": {...},
    "poses": {...},
    "animations": {...},
    "directions": ["south", "north", "east", "west"]
}
```

**Files to Create/Modify:**
```
addons/character_assembler/
├── scenes/
│   ├── main_panel.tscn (modify - add export panel)
│   └── export_dialog.tscn
├── scripts/
│   ├── export_manager.gd
│   ├── sprite_sheet_generator.gd
│   ├── frame_exporter.gd
│   ├── godot_scene_generator.gd
│   └── project_serializer.gd
```

**UI Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ EXPORT                                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Character Name: [thorne____________]                            │
│                                                                 │
│ OUTPUT FORMATS:                                                 │
│ [✓] Sprite Sheet (.png)                                        │
│ [✓] Individual Frames (.png)                                   │
│ [✓] Godot Scene (.tscn)                                        │
│ [✓] Project File (.json)                                       │
│                                                                 │
│ SETTINGS:                                                       │
│ Background: [Transparent ▼]                                    │
│ Scale: [1x ▼]  (64×64 → 64×64)                                 │
│ Naming: [character_direction_anim_frame ▼]                     │
│                                                                 │
│ DIRECTIONS TO EXPORT:                                           │
│ [✓] South  [✓] North  [✓] East  [✓] West                      │
│                                                                 │
│ ANIMATIONS TO EXPORT:                                           │
│ [✓] idle (4 frames)                                            │
│ [✓] walk (8 frames)                                            │
│ [✓] attack (6 frames)                                          │
│ [✓] hurt (3 frames)                                            │
│ [✓] death (6 frames)                                           │
│                                                                 │
│ OUTPUT PATH: [res://assets/sprites/characters/thorne/]         │
│                                                    [Browse...]  │
│                                                                 │
│ PREVIEW:                                                        │
│ Will generate:                                                  │
│ • 1 sprite sheet (512×256 px)                                  │
│ • 108 individual frames                                         │
│ • 1 AnimatedSprite2D scene                                      │
│ • 1 project file                                                │
│                                                                 │
│ [Export All]                                                    │
└─────────────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- [ ] Can export sprite sheet PNG
- [ ] Can export individual frame PNGs
- [ ] Can export Godot AnimatedSprite2D scene
- [ ] Can save/load project JSON
- [ ] Scale options work correctly
- [ ] Batch export for all directions works
- [ ] Exported assets work in Godot without modification

---

### Phase 2 Complete Checklist

- [ ] Animation templates generate correct frame sequences
- [ ] Animation preview plays smoothly at correct FPS
- [ ] All 4 directions can be created/generated
- [ ] Export produces usable sprite sheets
- [ ] Godot scene imports and works correctly
- [ ] Project can be saved and reloaded

**Phase 2 Exit Test:**
Create character with 6 animations, 4 directions. Export to Godot scene. Import into Blood & Gold project. Character animates correctly in all directions.

---

## Phase 3: Polish & Production Ready

**Goal:** Handle edge cases, add convenience features, documentation.

**Prerequisites:** Phase 2 complete, tool used to create 5+ real characters

---

### Feature 3.1: Undo/Redo System

**Description:** Full undo/redo support for all editing operations.

**Implementation Tasks:**
- [ ] Create command pattern for all operations
- [ ] Implement undo stack (20 levels)
- [ ] Implement redo stack
- [ ] Add keyboard shortcuts (Ctrl+Z, Ctrl+Shift+Z)
- [ ] Add undo/redo buttons to toolbar
- [ ] Handle compound operations (multiple shapes at once)

**Files to Create/Modify:**
```
addons/character_assembler/scripts/
├── command_manager.gd
├── commands/
│   ├── add_shape_command.gd
│   ├── move_shape_command.gd
│   ├── delete_shape_command.gd
│   ├── tag_body_part_command.gd
│   ├── set_rotation_command.gd
│   └── compound_command.gd
```

**Success Criteria:**
- [ ] Can undo any operation
- [ ] Can redo undone operations
- [ ] 20 levels of undo work
- [ ] Keyboard shortcuts work

---

### Feature 3.2: Shape Library

**Description:** Save and load reusable shape groups (armor sets, weapons, etc.)

**Implementation Tasks:**
- [ ] Create ShapeGroup resource type
- [ ] Implement "Save Selection as Group"
- [ ] Implement group library browser
- [ ] Add built-in groups (humanoid base, weapons, armor pieces)
- [ ] Implement drag-drop from library to canvas
- [ ] Add group categories (body, armor, weapons, accessories)

**Files to Create/Modify:**
```
addons/character_assembler/
├── scenes/
│   └── shape_library.tscn
├── scripts/
│   ├── shape_library.gd
│   └── shape_group.gd
└── resources/
    └── shape_library/
        ├── humanoid_base.tres
        ├── plate_armor.tres
        ├── leather_armor.tres
        ├── sword.tres
        ├── shield.tres
        └── bow.tres
```

**Success Criteria:**
- [ ] Can save selection as reusable group
- [ ] Can browse and insert groups from library
- [ ] Built-in groups provide useful starting points

---

### Feature 3.3: Error Handling & Validation

**Description:** Graceful handling of edge cases and user errors.

**Implementation Tasks:**
- [ ] Add validation before export (all parts tagged, all pivots set)
- [ ] Handle missing reference images gracefully
- [ ] Handle corrupted project files
- [ ] Add confirmation dialogs for destructive operations
- [ ] Implement auto-save (every 5 minutes)
- [ ] Add recovery from auto-save on crash
- [ ] Add helpful error messages with suggested fixes

**Success Criteria:**
- [ ] Export fails gracefully with clear message if rig incomplete
- [ ] Can recover from auto-save after crash
- [ ] All error messages are actionable

---

### Feature 3.4: Documentation & Presets

**Description:** User guide, tooltips, and preset characters for learning.

**Implementation Tasks:**
- [ ] Write usage guide (`docs/tools/character-assembler-guide.md`)
- [ ] Add tooltips to all UI elements
- [ ] Create 3 example characters (fighter, rogue, mage)
- [ ] Add "Load Example" menu option
- [ ] Add keyboard shortcut reference panel
- [ ] Create video tutorial outline

**Files to Create/Modify:**
```
docs/tools/
├── character-assembler-guide.md
└── character-assembler-shortcuts.md

addons/character_assembler/resources/
└── examples/
    ├── fighter_example.json
    ├── rogue_example.json
    └── mage_example.json
```

**Success Criteria:**
- [ ] New user can create character using guide alone
- [ ] Example characters demonstrate all features
- [ ] Tooltips explain all UI elements

---

### Phase 3 Complete Checklist

- [ ] Undo/redo works for all operations
- [ ] Shape library saves time on common elements
- [ ] Errors handled gracefully with clear messages
- [ ] Documentation enables self-service learning
- [ ] Tool is stable enough for daily use

**Phase 3 Exit Test:**
Hand tool to someone unfamiliar with it. They should be able to create a complete character (4 directions, 6 animations) using only the documentation and examples, without asking questions.

---

## Future Ideas (Backlog)

Post-MVP ideas that may be valuable:

- **Animation Curves:** Non-linear interpolation (ease in/out, bounce)
- **Batch Processing:** Apply changes to multiple characters at once
- **Style Transfer:** Copy body proportions from one character to another
- **Weapon Attachment Points:** Define where weapons attach for swapping
- **Custom Animation Templates:** User-defined templates
- **Import Existing Sprites:** Re-rig existing sprite sheets
- **Onion Skinning:** Show previous/next frames for reference
- **Live Game Preview:** Preview character in actual game scene
- **Collaboration:** Multiple users editing same character

---

## Dependencies

| Dependency | Required By | Notes |
|------------|-------------|-------|
| Godot 4.x | All features | Editor plugin API |
| FileAccess | Export System | PNG/JSON writing |
| Image class | Export System | Sprite sheet composition |
| JSON class | Project Save | Serialization |

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Rotation math complexity | Delays Phase 1 | Prototype rotation algorithm early |
| Performance with many shapes | Slow editing | Batch rendering, limit to 100 shapes |
| Export quality issues | Unusable output | Test exports in real game early |
| Scope creep | Never finishes | Strict MVP focus, backlog for ideas |

---

## Implementation Order Summary

```
Week 1-2:   Feature 1.1 (Plugin Setup)
            Feature 1.2 (Canvas + Shapes) ← HIGHEST RISK

Week 3-4:   Feature 1.3 (Body Part Tagging)
            Feature 1.4 (Pose System)

Week 5-6:   Feature 2.1 (Animation Templates)
            Feature 2.2 (Multi-Direction)

Week 7:     Feature 2.3 (Export System)

Week 8:     Feature 3.1-3.4 (Polish)

            TOTAL: ~8 weeks / 110 hours
```

---

**Next Step:** Use `tool-feature-implementer` skill to implement Feature 1.1 (Plugin Setup).
