# Tool Spec: Procedural Character Assembler

**Version:** 0.1
**Type:** Standalone Tool (Godot Integration)
**Priority:** High
**Created:** January 2026
**Estimated Dev Time:** 110 hours

---

## Problem Statement

**Pain Point:**
Traditional pixel art requires drawing every pixel for every frame, taking 8-12 hours per character with 4-direction animations. For a game with 57 characters, this means 450+ hours of art creation alone.

**Current Workaround:**
- Use PixelLab AI generation (good but limited control over style consistency)
- Hand-draw each frame (time-prohibitive)
- Use pre-made asset packs (doesn't match game's unique aesthetic)

**Impact:**
Reduce character creation time from 8-12 hours to 25-30 minutes per character. Enable rapid iteration on character designs. Maintain perfect frame-to-frame consistency. Allow non-artists to create game-ready sprites.

**Core Insight:**
Instead of drawing pixels, assemble shapes. The target art style is already geometric ("engineering schematics that learned to walk"), making procedural generation a feature, not a limitation.

---

## Target Users

| User | Use Case |
|------|----------|
| Solo Developer | Create all 57 game characters without hiring artist |
| Designer | Rapidly prototype character concepts with placeholder art |
| Programmer | Generate consistent sprites that integrate cleanly with animation systems |

---

## Design Philosophy

1. **"Show, Don't Configure"** - User sees results, adjusts visually. No dropdown menus for interpolation modes.
2. **"Make It Work, Then Make It Perfect"** - Functional > beautiful. Ship games > perfect tools.
3. **"Intelligence in Templates, Simplicity in UI"** - Complexity lives in animation templates, not user-facing concepts.
4. **"Reuse Over Perfection"** - Good enough for 3-5 second combat views beats perfect but never shipped.

---

## Core Functionality (6 Features)

### Feature 1: Character Canvas (MVP)
**Dev Time:** 20 hours

Workspace for assembling characters from primitive shapes.

**Must Have:**
- Adjustable canvas size (default 64x64, supports 32-128px)
- Reference image underlay with opacity slider (0-100%)
- Shape palette: Rectangle, Circle, Ellipse, Triangle
- Color palette with per-kingdom theme presets
- Layer system with z-ordering (front/back)
- Grid snap for clean alignment
- Undo/redo (20 levels)

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ Reference: [image.png ▼] Opacity: [====50%====]        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────┐  TOOLS:           │
│  │                                 │  [■] Rectangle    │
│  │     CANVAS (64x64)              │  [●] Circle       │
│  │                                 │  [⬭] Ellipse      │
│  │  [Reference image faded        │  [▲] Triangle     │
│  │   with shapes overlaid]        │                    │
│  │                                 │  COLORS:          │
│  │                                 │  [████] [████]    │
│  │                                 │  [████] [████]    │
│  └─────────────────────────────────┘                    │
│                                                         │
│  Layer: [5/12] [↑ Up] [↓ Down] [🗑 Delete]              │
└─────────────────────────────────────────────────────────┘
```

---

### Feature 2: Body Part Tagging System (MVP)
**Dev Time:** 30 hours

The KEY innovation. Converts loose shapes into an animatable character rig.

**Must Have:**
- Select multiple shapes and assign to body part
- 14 standard body parts with hierarchy:
  ```
  Character
  ├─ Head (pivot: neck)
  ├─ Torso (pivot: waist) ← ROOT
  ├─ Left Arm
  │  ├─ Upper Arm (pivot: shoulder, parent: Torso)
  │  ├─ Lower Arm (pivot: elbow, parent: Upper Arm)
  │  └─ Hand (pivot: wrist, parent: Lower Arm)
  ├─ Right Arm (mirrors Left)
  ├─ Left Leg
  │  ├─ Upper Leg (pivot: hip, parent: Torso)
  │  ├─ Lower Leg (pivot: knee, parent: Upper Leg)
  │  └─ Foot (pivot: ankle, parent: Lower Leg)
  └─ Right Leg (mirrors Left)
  ```
- Click-to-set pivot points (rotation origin)
- Parent-child hierarchy (rotating torso rotates all children)
- Visual hierarchy display (tree view)
- Validation warnings (untagged shapes, missing pivots)

**Interaction:**
1. Select shapes (click + drag box, or Shift+click)
2. Choose body part from dropdown
3. Click to set pivot point on canvas
4. Select parent body part
5. Repeat for all 14 body parts

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ BODY PART TAGGER                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Selected: [6 shapes]                                    │
│                                                         │
│ Assign to: [Torso ▼]                                   │
│                                                         │
│ Pivot Point: X [32] Y [28]  [⊕ Click on Canvas]       │
│                                                         │
│ Parent Part: [None (Root) ▼]                           │
│                                                         │
│ [Apply Tags]                                            │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ CURRENT RIG:                                            │
│ └─ Torso (6 shapes) ✓                                  │
│    ├─ Head (8 shapes) ✓                                │
│    ├─ L Upper Arm (4 shapes) ✓                         │
│    │  └─ L Lower Arm (4 shapes) ✓                      │
│    │     └─ L Hand (3 shapes) ⚠ Missing pivot          │
│    ├─ R Upper Arm (4 shapes) ✓                         │
│    └─ L Upper Leg (unassigned) ❌                       │
│                                                         │
│ Progress: [=========70%=========] 10/14 parts          │
└─────────────────────────────────────────────────────────┘
```

---

### Feature 3: Pose System (MVP)
**Dev Time:** 25 hours

Define key poses by rotating body parts. Animations interpolate between poses.

**Must Have:**
- Create/save/delete poses
- Rotate any body part (-180° to +180°)
- Live preview of pose on canvas
- Reset individual parts or entire pose
- Duplicate pose (for variants)
- Mirror pose (left ↔ right swap)

**Standard Poses to Create:**
| Pose Name | Purpose | Key Rotations |
|-----------|---------|---------------|
| Idle | Neutral stance | All 0° |
| Walk_Left | Left foot forward | L Leg +30°, R Leg -20°, Arms opposite |
| Walk_Right | Right foot forward | Mirror of Walk_Left |
| Attack_Windup | Wind up swing | R Arm +90°, Torso -10° |
| Attack_Swing | Execute attack | R Arm -120°, Torso +20° |
| Hurt | Taking damage | Torso -15°, Head -5°, Arms +20° |
| Death | Collapsed | Torso +45°, limbs splayed |

**Interaction:**
1. Create new pose (name it)
2. Drag rotation sliders for each body part
3. See live preview on canvas
4. Save pose
5. Create 5-7 poses total (15 minutes)

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ POSE EDITOR                                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Current Pose: [Walk_Left ▼]  [+ New] [🗑 Delete]       │
│                                                         │
│ ROTATIONS:                    PREVIEW:                  │
│                               ┌─────────────┐           │
│ Head:        [====0°====]    │             │           │
│ Torso:       [====0°====]    │  [Animated  │           │
│ L Upper Arm: [==-15°====]    │   preview   │           │
│ L Lower Arm: [===+5°====]    │   of pose]  │           │
│ L Hand:      [====0°====]    │             │           │
│ R Upper Arm: [===+15°===]    └─────────────┘           │
│ R Lower Arm: [===-5°====]                               │
│ L Upper Leg: [===+30°===] ← Adjusted                   │
│ L Lower Leg: [===-20°===] ← Adjusted                   │
│ L Foot:      [===+10°===]                               │
│ R Upper Leg: [===-20°===]                               │
│ R Lower Leg: [===-10°===]                               │
│                                                         │
│ [Reset All] [Mirror L↔R] [Duplicate Pose]              │
│                                                         │
│ SAVED POSES: Idle | Walk_Left | Walk_Right | Attack... │
└─────────────────────────────────────────────────────────┘
```

---

### Feature 4: Animation Templates (MVP)
**Dev Time:** 15 hours

Pre-built animation logic that interpolates between poses.

**Must Have:**
- 8 built-in templates:
  | Template | Input Poses | Output Frames |
  |----------|-------------|---------------|
  | Walk Cycle | Idle, Walk_L, Walk_R | 8 frames |
  | Run Cycle | Idle, Walk_L, Walk_R | 8 frames (faster) |
  | Idle Breathing | Idle | 4 frames (subtle torso) |
  | Attack | Idle, Windup, Swing | 6 frames |
  | Hurt Recoil | Idle, Hurt | 3 frames |
  | Death | Idle, Death | 6 frames |
  | Victory | Idle | 4 frames |
  | Jump | Idle | 6 frames |

- Pose assignment UI (map your poses to template slots)
- Adjustable frame count (default or custom)
- Adjustable FPS (8, 12, 15, 24)
- Live animation preview with play/pause
- Interpolation between poses (linear default)

**How Interpolation Works:**
```
Walk Animation (8 frames):
Frame 1: Idle (100%)
Frame 2: Idle (75%) + Walk_L (25%)
Frame 3: Idle (50%) + Walk_L (50%)
Frame 4: Idle (25%) + Walk_L (75%)
Frame 5: Walk_L (100%)
Frame 6: Walk_L (50%) + Walk_R (50%)
Frame 7: Walk_R (100%)
Frame 8: Walk_R (50%) + Idle (50%)
→ Loop
```

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ ANIMATION GENERATOR                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Template: [Walk Cycle ▼]                               │
│                                                         │
│ REQUIRED POSES:                                         │
│ • Idle:       [Idle ▼]        ✓ Assigned               │
│ • Walk_Left:  [Walk_Left ▼]   ✓ Assigned               │
│ • Walk_Right: [Walk_Right ▼]  ✓ Assigned               │
│                                                         │
│ SETTINGS:                                               │
│ Frames: [8]    FPS: [12]    Loop: [✓]                  │
│                                                         │
│ [Generate Animation]                                    │
│                                                         │
│ PREVIEW:          ┌─────────────────┐                  │
│ [▶ Play] [⏸]     │                 │                  │
│                   │  [Character     │                  │
│ Frame: [3/8]      │   animating]    │                  │
│                   │                 │                  │
│ Timeline:         └─────────────────┘                  │
│ [1][2][●][4][5][6][7][8]                               │
│                                                         │
│ GENERATED ANIMATIONS:                                   │
│ ✓ walk_cycle (8 frames)                                │
│ ✓ idle_breathing (4 frames)                            │
│ ○ attack (not yet generated)                           │
│                                                         │
│ [Export All Animations]                                 │
└─────────────────────────────────────────────────────────┘
```

---

### Feature 5: Multi-Direction Support (MVP)
**Dev Time:** 10 hours

Generate 4 directional variants from base character.

**Must Have:**
- 4 direction views: South (front), North (back), East (side), West (flipped)
- Three generation methods:
  | Method | Quality | Time | Use When |
  |--------|---------|------|----------|
  | Auto-flip | Low | 5 sec | Placeholder, symmetric characters |
  | Semi-manual | Medium | +8 min | Most characters (recommended) |
  | Full manual | High | +20 min | Hero characters, asymmetric designs |

- Copy body part tags between views (tags persist, shapes differ)
- Copy poses between views (or create view-specific)
- Batch generate all directions at once

**Recommended Workflow (Semi-Manual):**
1. South: Fully design (front view) - 15 min
2. East: Manually adjust shapes (side profile important) - 5 min
3. North: Auto-generate from South, tweak back details - 3 min
4. West: Auto-flip East - instant

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ DIRECTION VARIANTS                                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ Views: [South ●] [North ○] [East ○] [West ○]           │
│                                                         │
│ Current: South (Front View) - PRIMARY                   │
│                                                         │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│ │  SOUTH  │ │  NORTH  │ │  EAST   │ │  WEST   │        │
│ │   ✓     │ │   ○     │ │   ○     │ │   ○     │        │
│ │ [front] │ │ [back]  │ │ [side]  │ │ [side]  │        │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘        │
│                                                         │
│ GENERATION OPTIONS:                                     │
│ ○ Auto-flip all (fast, lower quality)                  │
│ ● Semi-manual (recommended)                            │
│ ○ Full manual (highest quality)                        │
│                                                         │
│ COPY FROM SOUTH:                                        │
│ [✓] Body part tags & pivots                            │
│ [✓] Poses                                              │
│ [ ] Shape positions (manual per view)                  │
│                                                         │
│ [Switch to East View] [Generate All Directions]        │
└─────────────────────────────────────────────────────────┘
```

---

### Feature 6: Export System (MVP)
**Dev Time:** 10 hours

Output game-ready assets in multiple formats.

**Must Have:**
- **Sprite Sheet:** All frames in grid layout (PNG)
  ```
  [Idle1][Idle2][Idle3][Idle4]
  [Walk1][Walk2][Walk3][Walk4][Walk5][Walk6][Walk7][Walk8]
  [Atk1][Atk2][Atk3][Atk4][Atk5][Atk6]
  ```
- **Individual Frames:** Named PNGs
  ```
  thorne_south_idle_001.png
  thorne_south_walk_001.png
  thorne_east_attack_003.png
  ```
- **Godot AnimatedSprite2D Scene:** Drop-in .tscn file
  ```
  AnimatedSprite2D
  ├─ Animation: idle_south (4 frames, 6 FPS, loop)
  ├─ Animation: walk_south (8 frames, 12 FPS, loop)
  ├─ Animation: attack_south (6 frames, 12 FPS, no loop)
  └─ ... (all directions × all animations)
  ```
- **JSON Project File:** Re-editable character data
  ```json
  {
    "character_id": "thorne",
    "canvas_size": 64,
    "body_parts": {...},
    "poses": {...},
    "animations": {...}
  }
  ```

**Export Settings:**
- Background: Transparent / Solid color
- Scale: 1x, 2x, 4x (for different resolutions)
- Naming convention: customizable pattern

---

## Complete User Workflow

```
STAGE 1: Setup (3 min)
├─ Import reference image
├─ Set canvas size (64x64)
├─ Adjust reference opacity (50%)
└─ Choose color palette

STAGE 2: Shape Assembly (15 min)
├─ Paint shapes over reference
├─ 40-60 shapes total
├─ Layer ordering (back→front)
└─ Result: Complete character silhouette

STAGE 3: Body Part Tagging (8 min)
├─ Select shapes → Assign to body parts
├─ Set pivot points (click on joints)
├─ Define parent-child hierarchy
└─ Result: 14 tagged body parts

STAGE 4: Pose Creation (10 min)
├─ Create 5-7 key poses
├─ Rotate body parts per pose
├─ Preview each pose
└─ Result: Idle, Walk×2, Attack×2, Hurt, Death

STAGE 5: Animation Generation (2 min)
├─ Select templates
├─ Assign poses to template slots
├─ Generate animations
├─ Preview and adjust
└─ Result: 6 animations, ~48 frames

STAGE 6: Multi-Direction Export (2 min)
├─ Generate/tweak other directions
├─ Export sprite sheets
├─ Export Godot scene
└─ Result: Complete character ready for game

TOTAL TIME: 30-40 minutes per character
```

---

## Technical Notes

### Data Structure

```gdscript
class_name CharacterProject

var character_id: String
var canvas_size: int = 64
var reference_image: Texture2D
var reference_opacity: float = 0.5

var shapes: Array[Shape] = []  # All shapes on canvas
var body_parts: Dictionary = {}  # body_part_name → BodyPart
var poses: Dictionary = {}  # pose_name → Pose
var animations: Dictionary = {}  # anim_name → Animation
var directions: Array[String] = ["south", "north", "east", "west"]

class Shape:
    var type: String  # "rectangle", "circle", "ellipse", "triangle"
    var position: Vector2
    var size: Vector2
    var color: Color
    var rotation: float
    var layer: int

class BodyPart:
    var name: String
    var shapes: Array[int]  # Indices into shapes array
    var pivot: Vector2
    var parent: String  # Parent body part name, or "" for root

class Pose:
    var name: String
    var rotations: Dictionary  # body_part_name → rotation_degrees

class Animation:
    var name: String
    var template: String
    var frames: int
    var fps: int
    var loop: bool
    var pose_assignments: Dictionary  # slot_name → pose_name
```

### Integration Points

| System | Integration |
|--------|-------------|
| Godot Editor | Optional dock plugin for preview |
| File System | Save .json projects, export .png/.tscn |
| Blood & Gold | Export to `assets/sprites/characters/` |

### Performance Targets

- Shape rendering: 60 FPS with 100+ shapes
- Animation preview: 60 FPS
- Export generation: <5 seconds for full character
- Project save/load: <1 second

---

## Success Criteria

**MVP Complete When:**
- [ ] Can import reference image and adjust opacity
- [ ] Can place/resize/color all 4 shape types
- [ ] Can tag shapes to 14 body parts with pivots
- [ ] Can create poses with rotation sliders
- [ ] Can generate 8-frame walk cycle from 3 poses
- [ ] Can export sprite sheet PNG
- [ ] Can export Godot AnimatedSprite2D scene
- [ ] Can save/load project JSON

**Tool is Successful When:**
- Create one character (4 directions, 6 animations) in under 40 minutes
- Non-artist can produce acceptable game-ready sprites
- All 57 Blood & Gold characters created in <35 hours total
- Frame-to-frame consistency is perfect (no wobble)

---

## Development Phases

| Phase | Features | Hours | Milestone |
|-------|----------|-------|-----------|
| 1 | Canvas + Shapes | 20h | Can assemble character visually |
| 2 | Body Part Tagging | 30h | Can create animatable rig |
| 3 | Pose System | 25h | Can define key poses |
| 4 | Animation Templates | 15h | Can generate animations |
| 5 | Multi-Direction | 10h | Can export 4 directions |
| 6 | Export System | 10h | Can output game-ready assets |
| **Total** | **All MVP** | **110h** | **Complete tool** |

---

## Open Questions

- [ ] Build as standalone app or Godot editor plugin?
- [ ] Support custom animation templates (user-defined)?
- [ ] Add shape "mirroring" for symmetric characters?
- [ ] Include built-in color palette presets per faction?
- [ ] Support importing existing sprite sheets for re-rigging?

---

## References

- Blood & Gold GDD: `docs/blood-and-gold-prototype-gdd.md`
- Existing mech editor code (reusable for canvas/shapes)
- Spine 2D / DragonBones (industry standard 2D rigging)
- Aseprite (pixel art workflow reference)
- PixelLab MCP (current character generation approach)

---

## Future Enhancements (Post-MVP)

- **Shape Library:** Save/load reusable shape groups (armor sets, weapons)
- **Animation Curves:** Non-linear interpolation (ease in/out)
- **Batch Processing:** Apply template changes to multiple characters
- **Style Transfer:** Copy body proportions from one character to another
- **Weapon Attachment Points:** Define where weapons attach for swapping
