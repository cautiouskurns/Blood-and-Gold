
The Solution: Procedural Character Assembly
The Core Insight:
Instead of drawing pixels, assemble shapes.
Traditional pixel art asks: "Where should each pixel go?"
This tool asks: "What shapes form this character?"
Traditional Approach:
Reference Image → Draw 64×64 pixels → Animate frame-by-frame
Time: 8-12 hours per character

New Approach:
Reference Image → Trace with shapes → Tag body parts → Generate animations
Time: 25-30 minutes per character
Why This Works:
1. Primitive Art Aesthetic:
Your target art style is already shape-based:

"Engineering schematics that learned to walk"
Geometric, architectural characters
Not trying to look hand-painted
Procedural feel is a FEATURE, not a limitation

2. Separation of Structure and Motion:
Traditional pixel art mixes these:

Every frame is hand-painted
Move arm = redraw entire character
Consistency is hard (arm looks different each frame)

This tool separates them:

Structure: What shapes form the character? (done once)
Motion: How do shapes move? (templates handle this)
Result: Perfect frame-to-frame consistency

3. Reusable Intelligence:
Once you teach the tool "this is how humans walk," every character gets that knowledge:

Walk cycle template works for all characters
Attack animation template works for all characters
Add new animation = all characters get it automatically


Core Workflow: From Reference to Animation
The User Journey (30 Minutes)
STAGE 1: Setup (3 minutes)
User Action:
1. Find reference image of character
   (concept art, photo, sketch - anything)
2. Import to tool
3. Adjust opacity (50% = see reference + canvas)
4. Set canvas size (64×64 default, adjustable)

Tool State:
- Reference visible as underlay
- Empty canvas overlaid
- Shape palette ready
- Grid snap enabled
Why this matters:

Reference image guides accuracy (no guessing anatomy)
Adjustable opacity lets you trace without obscuring
Grid snap ensures clean, aligned shapes
Canvas size standardized = consistent character scale


STAGE 2: Shape Assembly (15 minutes)
User Action:
User paints character using shapes:

Head:
- Paint 2 circles (head base)
- Paint 4 rectangles (helmet/hair details)
- Paint 2 small circles (eyes)

Torso:
- Paint 6 rectangles (chest armor plates)
- Paint 2 ellipses (shoulder pauldrons)
- Paint 1 large rectangle (main body)

Arms (Left):
- Paint 4 rectangles (upper arm armor)
- Paint 4 rectangles (lower arm/bracer)
- Paint 3 small shapes (hand/gauntlet)

Arms (Right):
- Mirror left arm (or paint manually)

Legs (Left):
- Paint 5 rectangles (upper leg armor)
- Paint 4 rectangles (lower leg/greaves)
- Paint 2 shapes (boot)

Legs (Right):
- Mirror left leg

Weapon:
- Paint 1 rectangle (sword blade)
- Paint 2 rectangles (hilt)

Layer ordering:
- Back arm
- Back leg
- Torso
- Front arm
- Front leg
- Head (always on top)

Total shapes: 40-60 (depending on detail)
Time: 15 minutes
Why this matters:

Simple shapes = fast to place
Reference underlay = accurate proportions
Reusable shapes = consistent style
Layer system = proper depth (front/back)

What user sees:
Progress from empty → full character:

Minute 0:  □ (empty)
Minute 3:  ⚪ (head circles placed)
Minute 6:  👤 (torso added)
Minute 10: 🧍 (limbs added)
Minute 15: 🤺 (weapon, details complete)

Reference image visible throughout for accuracy

STAGE 3: Body Part Tagging (8 minutes)
User Action:
Now tag which shapes belong to which body parts:

1. Select shapes 1-8 → Assign to "Head"
   - Tool asks: Where does head rotate? (neck joint)
   - User clicks neck position → Pivot set

2. Select shapes 9-17 → Assign to "Torso"
   - Tool asks: Where does torso rotate? (waist)
   - User clicks waist → Pivot set

3. Select shapes 18-25 → Assign to "Left Upper Arm"
   - Tool asks: Where does this rotate? (shoulder)
   - User clicks shoulder → Pivot set
   - Tool asks: Parent body part? (Torso)

4. Select shapes 26-33 → Assign to "Left Lower Arm"
   - Pivot: Elbow (user clicks)
   - Parent: Left Upper Arm

5. Repeat for:
   - Left Hand (parent: Left Lower Arm)
   - Right Upper Arm (parent: Torso)
   - Right Lower Arm (parent: Right Upper Arm)
   - Right Hand (parent: Right Lower Arm)
   - Left Upper Leg (parent: Torso)
   - Left Lower Leg (parent: Left Upper Leg)
   - Left Foot (parent: Left Lower Leg)
   - Right Upper Leg, Lower Leg, Foot

6. Weapon → Assign to "Right Hand"

Total body parts: 14
Time: 8 minutes
Why this matters:
This is THE critical step that enables animation:
Without tagging:

Shapes are just rectangles
No relationship between parts
Can't animate (would have to move each shape individually)

With tagging:

Shapes grouped into logical limbs
Hierarchical parent-child relationships
Rotate shoulder → entire arm moves
Rotate torso → arms, head, weapon all move together
Foundation for procedural animation

Analogy:
Like rigging a 3D character, but 2D and much faster:

3D character rig: 2-4 hours
This tool: 8 minutes


STAGE 4: Pose Creation (10 minutes)
User Action:
Define key poses by rotating body parts:

Pose 1: "Idle"
- All rotations: 0°
- Neutral stance
- Save pose

Pose 2: "Walk_Left_Foot_Forward"
- Left Upper Leg: +30° (leg swings forward)
- Left Lower Leg: -15° (knee bends)
- Left Foot: +5° (foot angles)
- Right Upper Leg: -20° (leg back)
- Right Lower Leg: -10° (slight bend)
- Left Arm: -10° (opposite of leg = natural)
- Right Arm: +10° (opposite of leg)
- Save pose

Pose 3: "Walk_Right_Foot_Forward"
- Mirror of Pose 2
- Tool offers: Auto-generate by mirroring?
- User accepts
- Save pose

Pose 4: "Attack_Windup"
- Right Upper Arm: +90° (arm pulls back)
- Right Lower Arm: -30° (elbow bends)
- Torso: -10° (lean back for power)
- Left Arm: +20° (guard position)
- Save pose

Pose 5: "Attack_Swing"
- Right Upper Arm: -120° (arm swings forward)
- Right Lower Arm: +10° (arm extends)
- Torso: +20° (lean forward for follow-through)
- Left Arm: -10° (balance)
- Weapon follows hand automatically (parented)
- Save pose

Pose 6: "Hurt"
- Torso: -15° (recoil back)
- Head: -5° (head snaps back)
- Both arms: +20° (defensive raise)
- Save pose

Pose 7: "Death"
- All parts: various rotations (collapsed)
- Torso: +45° (fallen)
- Limbs: splayed
- Save pose

Total poses: 5-7
Time: 10 minutes (2 min per pose)
Why this matters:
Key insight:
Most animations are just blending between 2-3 key poses:

Walk = blend between Idle, Left, Right poses
Attack = blend between Idle, Windup, Swing poses
Hurt = snap from Idle to Hurt, back to Idle
Death = smooth transition from Idle/Hurt to Death

Efficiency:

Create 7 poses (10 minutes)
Generate 6 full animations (automatic)
48 animation frames total (6 animations × 8 average frames)

vs.

Draw 48 frames manually (8-12 hours)


STAGE 5: Animation Generation (2 minutes)
User Action:
Apply animation templates:

1. Select template: "Walk Cycle"
   - Tool asks: Assign poses
   - Idle → idle pose
   - Walk_Left → walk left pose
   - Walk_Right → walk right pose
   - Confirm

2. Tool generates:
   - Frame 1: Idle (100%)
   - Frame 2: Idle (75%) + Walk_Left (25%)
   - Frame 3: Idle (50%) + Walk_Left (50%)
   - Frame 4: Idle (25%) + Walk_Left (75%)
   - Frame 5: Walk_Left (100%)
   - Frame 6: Walk_Left (50%) + Walk_Right (50%)
   - Frame 7: Walk_Right (100%)
   - Frame 8: Walk_Right (50%) + Idle (50%)
   - Loop back to Frame 1
   
   8-frame walk cycle created automatically!

3. Preview animation:
   [▶ Play button]
   - Character walks in place
   - User sees smooth walking motion
   - Adjusts if needed (tweak pose rotations)

4. Repeat for other animations:
   - Attack (6 frames, uses Idle/Windup/Swing)
   - Idle Breathing (4 frames, subtle torso movement)
   - Hurt (3 frames, quick recoil)
   - Death (6 frames, collapse animation)

5. All 6 animations generated in 2 minutes

Total animations: 6 (Walk, Attack, Idle, Hurt, Death, Victory)
Time: 2 minutes
Why this matters:
The magic moment:
This is where the tool pays off. User spent 15 minutes placing shapes and 10 minutes creating poses.
Now in 2 minutes they get:

6 complete animations
48 total frames (8 frames × 6 animations)
Smooth interpolation between poses
Professional-looking character movement

Without this tool:
Would need to hand-draw all 48 frames = 6-8 hours
With this tool:
Procedural generation = 2 minutes
User feels like a wizard.

STAGE 6: Multi-Direction Export (2 minutes)
User Action:
Generate all 4 directions:

Current: Character designed in South (front-facing) view

Option 1: Quick (Auto-flip)
- North: Flip South vertically (back view)
- East: Rotate 90° (side view)
- West: Flip East horizontally
- Click "Generate All Directions"
- Done in 5 seconds

Option 2: Manual (Higher Quality)
User switches to "North View" mode:
- Adjusts shapes (back of helmet, different armor plates visible)
- Same body part tags apply (already set)
- Creates 1-2 unique poses (back-view specific)
- Animations auto-generate using same templates
- Time: +5 minutes for North view
- Repeat for East view: +5 minutes
- West auto-flips from East

Total time: 10-15 minutes for all directions

Option 3: Hybrid (Recommended)
- South: Fully designed (front view)
- East: Manually adjusted (side profile important)
- North: Auto-flip South with minor tweaks
- West: Auto-flip East
- Time: +8 minutes

Final output:
- 6 animations × 4 directions = 24 animation sets
- ~48 frames × 4 directions = 192 sprite frames
- For ONE character
- In 30 minutes total

Export:
- Sprite sheet (all frames in grid)
- Individual PNGs (thorne_south_walk_001.png, etc.)
- Godot .tscn scene (drop-in ready AnimatedSprite2D)
- JSON file (re-edit later)
Why this matters:
Isometric/4-direction requirements:
CRPGs need characters facing all directions. Traditional pixel art requires redrawing character 4 times.
This tool:

Design once (South view)
Generate other directions automatically OR
Tweak manually only where needed
Massive time savings

Result:
Complete character ready for game in 30 minutes.

Feature Ecosystem: How Everything Connects
The tool is designed as an integrated system where each feature builds on previous ones:
The Dependency Chain:
1. CANVAS & SHAPES (Foundation)
   ↓
   Creates: Character geometry
   ↓
2. BODY PART TAGGING (Structure)
   ↓
   Creates: Hierarchical rig (parent-child relationships)
   ↓
3. POSE SYSTEM (Key Frames)
   ↓
   Creates: Rotation data per body part
   ↓
4. ANIMATION TEMPLATES (Motion)
   ↓
   Uses: Poses to generate in-between frames
   ↓
5. MULTI-DIRECTION (Variants)
   ↓
   Uses: Tagged body parts + animations
   ↓
6. EXPORT SYSTEM (Delivery)
   ↓
   Outputs: Game-ready sprites
Each layer depends on the previous layer:

Can't tag body parts without shapes
Can't create poses without body part tags
Can't generate animations without poses
Can't export animations without animation data

But also enables rapid iteration:
User creates character → Exports → Sees in game → "Arms too short"

Traditional pixel art:
- Redraw all frames (4-6 hours)

This tool:
- Adjust arm shapes in canvas (2 minutes)
- Body part tags still valid
- All animations auto-regenerate
- Re-export (30 seconds)
- Total iteration: 3 minutes

Feature Interconnections:
Reference Image (Underlay):

Used by: Canvas (tracing guide)
Enables: Accurate proportions without art skill
Persists across: All views (South, North, East, West)

Shape Palette:

Used by: Canvas
Populates: All body parts
Enables: Consistent geometric style

Body Part Tags:

Uses: Shapes from canvas
Enables: Pose system (can't rotate untagged shapes)
Enables: Animation system (templates need named body parts)
Enables: Multi-direction (tags persist across views)

Pivot Points:

Set during: Body part tagging
Used by: Pose system (rotation origin)
Critical for: Natural-looking animation (rotate at joint, not center)

Pose System:

Uses: Body part tags + pivots
Creates: Rotation data (degrees per part)
Enables: Animation templates (templates interpolate between poses)
Enables: Re-posing (change pose = all animations update)

Animation Templates:

Uses: Poses (requires 2-3 poses per template)
Uses: Body part hierarchy (parents pull children)
Generates: Frame-by-frame sprite data
Output to: Export system

Multi-Direction System:

Uses: Body part tags (tags same across views)
Uses: Poses (can reuse or create view-specific)
Uses: Animation templates (same templates across views)
Enables: 4-direction export

Export System:

Uses: All animation frame data
Uses: All direction variants
Outputs: Multiple formats (sprite sheet, individual, Godot scene)
Saves: JSON for re-editing


The User Mental Model
What User Thinks They're Doing:
Phase 1: "I'm building a character"

Placing shapes to match reference image
Like digital LEGO
Intuitive: See reference, trace with shapes

Phase 2: "I'm defining how it moves"

Tagging which shapes are arms, legs, etc.
Setting where things rotate (shoulder, elbow)
Like articulating an action figure

Phase 3: "I'm creating key poses"

Rotating limbs to extreme positions
Walk pose, attack pose, hurt pose
Like posing an action figure for photos

Phase 4: "I'm generating animations"

Tool does the hard work
Smoothly blends between my poses
Magic happens automatically

Phase 5: "I'm exporting for my game"

Drop into Godot
Character animates perfectly
Victory!

What's Actually Happening (Technical):
Phase 1:

Constructing 2D geometry
Building shape hierarchy (z-order layers)
Creating visual representation

Phase 2:

Building skeletal rig
Establishing hierarchical transforms
Defining pivot matrices

Phase 3:

Capturing rotation states
Storing transform data per frame
Creating keyframe animation data

Phase 4:

Interpolating rotation curves
Propagating transforms down hierarchy
Rendering frames with applied transforms

Phase 5:

Rasterizing vector data to pixels
Packaging sprite sheets
Generating animation metadata

User doesn't need to know technical details.
Tool abstracts complexity into simple workflow.

Design Philosophy
1. "Show, Don't Configure"
Bad design:
Rotation Mode: [Dropdown: Euler/Quaternion/Matrix]
Interpolation: [Dropdown: Linear/Cubic/Hermite]
Frame Blending: [Checkbox] Enable
Blend Mode: [Dropdown: ...]
User has no idea what these mean.
Good design:
[Preview Animation]
[If looks bad: Adjust pose rotations]
[If still bad: Tweak template settings]
User sees result, adjusts visually.

2. "Make It Work, Then Make It Perfect"
V1 Goal:
Get 57 characters animated in 30 hours total.
NOT V1 Goal:
Perfect sub-pixel anti-aliasing, motion blur, 60 FPS preview, etc.
Philosophy:

Functional > Beautiful (for tool UI)
Fast iteration > Perfect result (can always refine)
Ship games > Perfect tools


3. "Intelligence in Templates, Simplicity in UI"
Where complexity lives:

Animation templates (encode how humans walk)
Interpolation algorithms (smooth blending)
Export formats (handle Godot integration)

Where simplicity lives:

UI (click, drag, rotate)
Workflow (linear progression: shapes → tag → pose → animate)
User-facing concepts (body parts, poses, animations)


4. "Reuse Over Perfection"
Character doesn't look perfect from all angles?

Good enough > never shipping
Player sees each character for 3-5 seconds in combat
As long as readable and consistent, it works



Feature 1: Character Canvas (20 hours)
What it does:
- 64×64 grid (or adjustable)
- Reference image underlay (opacity slider)
- Shape palette:
  - Rectangles (armor plates, torso, limbs)
  - Circles (heads, joints, shoulders)
  - Ellipses (organic shapes)
  - Triangles (helmet spikes, armor points)
- Color palette (per-kingdom themes)
- Layer system (front → back)
- Grid snap (for clean shapes)

Interface:
┌─────────────────────────────────────────┐
│ Reference: [thorne_ref.jpg] [50% Opacity]│
├─────────────────────────────────────────┤
│                                         │
│  CANVAS (64x64)                         │
│  ┌────────────────────┐                │
│  │  [Assembled         │                │
│  │   character         │                │
│  │   with reference    │                │
│  │   showing behind]   │                │
│  └────────────────────┘                │
│                                         │
│ TOOLS:                                  │
│ [Rectangle] [Circle] [Ellipse]         │
│ Colors: ████ ████ ████                 │
│ Layer: [5/12]  [↑] [↓]                 │
└─────────────────────────────────────────┘
This is exactly like your mech editor - reuse that code!

Feature 2: Body Part Tagging System (30 hours)
This is the KEY innovation.
Body Part Hierarchy:

Character
├─ Head
│  └─ Pivot: Neck joint
├─ Neck
│  └─ Pivot: Base of neck
├─ Torso
│  └─ Pivot: Waist/hip
├─ Left Arm
│  ├─ Upper Arm (pivot: shoulder)
│  ├─ Lower Arm (pivot: elbow)
│  └─ Hand (pivot: wrist)
├─ Right Arm
│  ├─ Upper Arm
│  ├─ Lower Arm
│  └─ Hand
├─ Left Leg
│  ├─ Upper Leg (pivot: hip)
│  ├─ Lower Leg (pivot: knee)
│  └─ Foot (pivot: ankle)
└─ Right Leg
   ├─ Upper Leg
   ├─ Lower Leg
   └─ Foot

14 body parts total
How It Works:
Step 1: Paint Shapes (just like mech editor)
User paints 6 rectangles to form torso
User paints 2 circles for head
User paints 8 rectangles for arms
etc.
Step 2: Tag Shapes with Body Parts
Select shapes 1-6 → Tag as "Torso"
Select shapes 7-8 → Tag as "Head"
Select shapes 9-12 → Tag as "Left Upper Arm"
Select shapes 13-16 → Tag as "Left Lower Arm"
Step 3: Set Pivot Points
For "Left Upper Arm":
- Pivot at shoulder (where it rotates)
- Parent: Torso (arm moves with torso)

For "Left Lower Arm":
- Pivot at elbow
- Parent: Left Upper Arm (lower arm rotates with upper arm)
Result: Hierarchical Character Rig
When torso rotates 10°:
├─ Arms rotate 10° (follow parent)
│  └─ Lower arms rotate 10° + their own rotation
├─ Head rotates 10° (follow parent)
└─ Legs stay fixed (different parent)
UI:
┌─────────────────────────────────────────┐
│ BODY PART TAGGER                        │
├─────────────────────────────────────────┤
│                                         │
│ Selected Shapes: [6 rectangles]        │
│                                         │
│ Assign to Body Part:                    │
│ [Dropdown: Torso ▼]                     │
│                                         │
│ Set Pivot Point:                        │
│ X: [32] Y: [28] [Snap to Center]       │
│                                         │
│ Parent Part:                            │
│ [Dropdown: None ▼]                      │
│                                         │
│ [Apply Tags]                            │
│                                         │
│ CURRENT RIG:                            │
│ └─ Torso (6 shapes)                     │
│    ├─ Head (8 shapes) [parent: Torso]  │
│    ├─ L Upper Arm (4 shapes)            │
│    │  └─ L Lower Arm (4 shapes)         │
│    │     └─ L Hand (3 shapes)           │
│    └─ R Upper Arm...                    │
└─────────────────────────────────────────┘
This enables animation!

Feature 3: Pose System (25 hours)
Instead of animating frame-by-frame, create "poses" that you blend.
How It Works:
Step 1: Define Key Poses
Idle Pose:
- All body parts at 0° rotation
- Neutral stance

Walk Pose 1 (Left foot forward):
- Left Upper Leg: +30° forward
- Left Lower Leg: -20° bend
- Left Foot: +10° angle
- Right Upper Leg: -20° back
- Right Lower Leg: -10° bend
- Left Arm: -15° back (opposite of leg)
- Right Arm: +15° forward

Walk Pose 2 (Right foot forward):
- Mirror of Walk Pose 1

Attack Pose 1 (Windup):
- Right Arm: +90° back
- Torso: -10° lean back
- Left Arm: +30° guard

Attack Pose 2 (Swing):
- Right Arm: -120° forward
- Torso: +20° lean forward
Step 2: Interpolate Between Poses
Walk Animation:
Frame 1: Idle (100%)
Frame 2: 75% Idle + 25% Walk1
Frame 3: 50% Idle + 50% Walk1
Frame 4: 25% Idle + 75% Walk1
Frame 5: Walk1 (100%)
Frame 6: 75% Walk1 + 25% Walk2
Frame 7: 50% Walk1 + 50% Walk2
Frame 8: Walk2 (100%)
Frame 9: Back to Idle...

Smooth 8-frame walk cycle!
UI:
┌─────────────────────────────────────────┐
│ POSE EDITOR                             │
├─────────────────────────────────────────┤
│                                         │
│ Current Pose: [Walk Left Foot Forward] │
│                                         │
│ BODY PART ROTATIONS:                    │
│                                         │
│ Head:           [0°]  [Reset]           │
│ Torso:          [0°]  [Reset]           │
│ L Upper Arm:   [-15°] [Reset]           │
│ L Lower Arm:    [5°]  [Reset]           │
│ L Hand:         [0°]  [Reset]           │
│ L Upper Leg:   [+30°] ← Adjusted        │
│ L Lower Leg:  [-20°] ← Adjusted         │
│ L Foot:        [+10°] ← Adjusted        │
│                                         │
│ [Preview Pose] [Save Pose]              │
│                                         │
│ SAVED POSES:                            │
│ - Idle                                  │
│ - Walk_Left                             │
│ - Walk_Right                            │
│ - Attack_Windup                         │
│ - Attack_Swing                          │
│ - Hurt                                  │
│ - Death                                 │
│                                         │
│ [+New Pose] [Delete Pose]               │
└─────────────────────────────────────────┘

Feature 4: Animation Templates (15 hours)
Pre-built animation logic that uses your poses.
WALK CYCLE TEMPLATE:
Input Poses:
- Idle
- Walk_Left
- Walk_Right

Generated Frames: 8
1. Idle → Walk_Left (25%)
2. Idle → Walk_Left (50%)
3. Idle → Walk_Left (75%)
4. Walk_Left (100%)
5. Walk_Left → Walk_Right (50%)
6. Walk_Right (100%)
7. Walk_Right → Idle (50%)
8. Idle (back to start)

---

ATTACK TEMPLATE:
Input Poses:
- Idle
- Attack_Windup
- Attack_Swing

Generated Frames: 6
1. Idle (100%)
2. Idle → Windup (50%)
3. Windup (100%)
4. Windup → Swing (50%)
5. Swing (100%)
6. Swing → Idle (50%)

---

IDLE BREATHING TEMPLATE:
Input Poses:
- Idle

Generated Frames: 4
Subtle movement:
- Frame 1: Torso 0°
- Frame 2: Torso +2° (inhale)
- Frame 3: Torso 0°
- Frame 4: Torso -2° (exhale)
UI:
┌─────────────────────────────────────────┐
│ ANIMATION GENERATOR                     │
├─────────────────────────────────────────┤
│                                         │
│ Template: [Walk Cycle ▼]               │
│                                         │
│ Required Poses:                         │
│ - Idle: [✓ Assigned]                   │
│ - Walk_Left: [✓ Assigned]              │
│ - Walk_Right: [✓ Assigned]             │
│                                         │
│ Settings:                               │
│ Frames: [8]  FPS: [12]                 │
│                                         │
│ [Generate Animation]                    │
│                                         │
│ PREVIEW:                                │
│ [▶ Play] [⏸ Pause] [Frame: 1/8]       │
│ ┌────────────┐                         │
│ │ [Animated  │                         │
│ │  character │                         │
│ │  preview]  │                         │
│ └────────────┘                         │
│                                         │
│ [Export Frames] [Save Animation]       │
└─────────────────────────────────────────┘
Available Templates:

Walk Cycle (8 frames)
Run Cycle (8 frames, faster)
Idle Breathing (4 frames)
Attack (6 frames)
Hurt Recoil (3 frames)
Death Collapse (6 frames)
Victory Pose (4 frames)
Jump (6 frames, if needed)

User can tweak template parameters:

Frame count
Interpolation speed
Hold duration on key poses


Feature 5: Multi-Direction Support (10 hours)
Generate 4 directions from one character design:
Method 1: Simple Flip (Fast)
- North: Flip character vertically
- South: Original
- East: Original (side view)
- West: Flip East horizontally

Method 2: Semi-Manual (Better)
- South: User designs (front view)
- North: User designs (back view)
- East: User designs (side view)
- West: Auto-flip East

Method 3: Full Manual (Best quality)
- User designs all 4 directions separately
- Most work but highest quality
Recommendation: Method 2

Design 3 views (front, back, side)
Auto-generate 4th (west = flipped east)
Time per character: +5 minutes

UI:
┌─────────────────────────────────────────┐
│ DIRECTION VARIANTS                      │
├─────────────────────────────────────────┤
│                                         │
│ [South] [North] [East] [West]          │
│   ▼       ▼       ▼       ▼            │
│                                         │
│ Currently Editing: South (Front View)  │
│                                         │
│ [Switch to North View]                  │
│ [Switch to East View]                   │
│ [Auto-Generate West (Flip East)]       │
│                                         │
│ Copy Settings from South:               │
│ [✓] Body part tags                     │
│ [✓] Pivot points                       │
│ [✓] Poses                              │
│ [ ] Shape positions (manual per view)   │
│                                         │
│ [Generate All Directions]               │
└─────────────────────────────────────────┘

Feature 6: Export System (10 hours)
Export formats:
A. Sprite Sheet
Grid layout:
[Idle1][Idle2][Idle3][Idle4]
[Walk1][Walk2][Walk3][Walk4][Walk5][Walk6][Walk7][Walk8]
[Atk1][Atk2][Atk3][Atk4][Atk5][Atk6]
[Hurt1][Hurt2][Hurt3]
[Death1][Death2][Death3][Death4][Death5][Death6]

One PNG with all frames
B. Individual Frames
thorne_south_idle_001.png
thorne_south_idle_002.png
thorne_south_walk_001.png
...
C. Godot AnimatedSprite2D Scene
Generates .tscn with all animations pre-configured:

AnimatedSprite2D
├─ Animation: idle_south (4 frames, 6 FPS)
├─ Animation: idle_north (4 frames, 6 FPS)
├─ Animation: walk_south (8 frames, 12 FPS)
├─ Animation: walk_north (8 frames, 12 FPS)
├─ Animation: attack_south (6 frames, 12 FPS)
└─ ...

Ready to drop into game!
D. JSON Character Data
json{
  "character_id": "thorne",
  "body_parts": {
    "head": {
      "shapes": [...],
      "pivot": {"x": 32, "y": 8},
      "parent": "neck"
    },
    "torso": {
      "shapes": [...],
      "pivot": {"x": 32, "y": 32},
      "parent": null
    }
  },
  "poses": {
    "idle": {...},
    "walk_left": {...}
  },
  "animations": {
    "walk_cycle": {
      "template": "walk",
      "frames": 8,
      "fps": 12
    }
  }
}
```

Save this to re-edit character later!

---