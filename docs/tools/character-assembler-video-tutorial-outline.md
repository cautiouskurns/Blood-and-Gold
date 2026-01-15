# Character Assembler Video Tutorial Outline

This document outlines a comprehensive video tutorial series for the Procedural Character Assembler Godot plugin.

---

## Episode 1: Introduction & Quick Start (5-7 min)

### Opening (30 sec)
- Show a complete character with animations playing
- "Create animated characters from simple shapes in minutes"

### Tool Overview (1 min)
- Brief tour of the interface
- Left panel: Shape tools and library
- Center: Canvas workspace
- Right panel: Layers, body parts, poses, animations, export

### Your First Character (4-5 min)
1. **Create New Project**
   - File > New or Ctrl+N
   - Set canvas size to 64x64

2. **Draw Basic Shapes**
   - Select circle tool, draw head
   - Select rectangle tool, draw torso
   - Change colors using the color picker

3. **Preview Your Work**
   - Use zoom buttons (1x, 2x, 4x, 8x)
   - Toggle grid on/off
   - Enable snap for precise positioning

4. **Save Your Project**
   - File > Save As
   - Name your character

### Closing (30 sec)
- "In the next episode, we'll set up body parts for animation"
- Preview of rigged character

---

## Episode 2: Body Part Rigging (8-10 min)

### Recap (30 sec)
- Quick review of shapes created

### Understanding Body Parts (1 min)
- Explain the 14 standard body parts
- Show the hierarchy: Torso > Arms > Hands
- Why pivots matter for rotation

### Rigging Walkthrough (5-7 min)
1. **Tag the Torso**
   - Select torso shapes
   - Choose "Torso" from dropdown
   - Click "Apply"
   - Torso is the root - no parent needed

2. **Set the Pivot Point**
   - Click "Set Pivot" button
   - Click center of torso on canvas
   - Show how pivot affects rotation

3. **Rig the Head**
   - Select head shapes
   - Choose "Head"
   - Set pivot at neck joint
   - Parent to "Torso"

4. **Rig Arms (Upper → Lower → Hand)**
   - Demonstrate chain: shoulder connects to torso
   - Elbow connects to upper arm
   - Wrist connects to lower arm

5. **Rig Legs**
   - Same chain concept
   - Hip to thigh to shin to foot

### Validation (1 min)
- Check progress bar (should show 14/14)
- Show validation warnings if parts missing
- Green = ready to animate

### Closing (30 sec)
- "Now your character is ready for poses!"
- Preview of character moving

---

## Episode 3: Creating Poses (6-8 min)

### Recap (30 sec)
- Show rigged character from previous episode

### Understanding Poses (1 min)
- Poses are snapshots of body part rotations
- Used as keyframes in animations
- Built-in poses vs custom poses

### Creating Poses (4-5 min)
1. **Default Poses**
   - Show built-in poses: Idle, Walk_L, Walk_R, etc.
   - Quick select buttons for fast switching

2. **Creating an Attack Pose**
   - Click "+ New" to create new pose
   - Name it "Attack_Windup"
   - Adjust rotation sliders:
     - Torso: -10°
     - R Upper Arm: -90°
     - R Lower Arm: -45°
   - Watch preview update in real-time

3. **Mirror Feature**
   - Duplicate a pose
   - Click "Mirror L↔R" to swap sides
   - Great for walk cycles

4. **Reset and Refine**
   - "Reset All" to start over
   - Fine-tune individual parts
   - Use slider precision for subtle adjustments

### Tips (1 min)
- Keep poses subtle (15-30° rotations)
- Test poses work together (walk cycle)
- Name poses clearly (Idle, Walk_L, Walk_R, Attack_1, Attack_2)

### Closing (30 sec)
- "Next: turning poses into animations!"

---

## Episode 4: Animation Generation (8-10 min)

### Recap (30 sec)
- Show poses created in previous episode

### Animation Concepts (1 min)
- Animations interpolate between poses
- Frame count affects smoothness
- Looping for continuous animations

### Creating Animations (5-7 min)
1. **Walk Cycle Animation**
   - Click "+ New Animation"
   - Name: "walk"
   - Start pose: Idle
   - End pose: Walk_L
   - Frame count: 8
   - Check "Loop"
   - Click "Generate"

2. **Attack Animation**
   - Name: "attack"
   - Start: Idle
   - Add keyframe: Attack_Windup at frame 2
   - Add keyframe: Attack_Swing at frame 4
   - End: Idle at frame 8
   - Uncheck "Loop"
   - Generate

3. **Preview Animations**
   - Use playback controls
   - Adjust frame count for speed
   - Scrub through frames manually

4. **Hurt & Death**
   - Single-direction animations
   - Lower frame counts for snappy feel
   - Death doesn't need to loop

### Animation Tips (1 min)
- 4-8 frames for most animations
- Walk cycles: Idle → Walk_L → Idle → Walk_R → Idle
- Combat: Quick windup, slower recovery

### Closing (30 sec)
- "Ready to export!"

---

## Episode 5: Exporting Your Character (5-7 min)

### Export Options Overview (1 min)
- Sprite sheet vs individual frames
- Godot scene generation
- Metadata JSON

### Export Walkthrough (3-4 min)
1. **Configure Export Settings**
   - Character name (used in filenames)
   - Output directory
   - Select formats to export

2. **Scale Options**
   - 1x: Original pixel size
   - 2x, 4x, 8x: Upscaled (nearest neighbor)
   - Good for retro games that need larger sprites

3. **Background Options**
   - Transparent (recommended)
   - Solid color (for specific engines)

4. **Export All Directions**
   - Single direction (front-facing)
   - All 8 directions (explained in Episode 6)

5. **Run Export**
   - Click "Export"
   - Watch progress
   - Review output files

### Using in Godot (1-2 min)
- Exported .tscn file ready to use
- AnimatedSprite2D with all animations
- Drag into your game scene
- Play animations with code

### Closing (30 sec)
- "Bonus episode: multi-directional characters!"

---

## Episode 6: Multi-Directional Characters (Bonus) (8-10 min)

### Why Multi-Directional? (1 min)
- Top-down games need 4 or 8 directions
- Each direction has its own poses
- Creates illusion of 3D movement

### Direction Manager (2-3 min)
1. **Understanding Directions**
   - 8 compass directions
   - South = facing camera (default)
   - North = facing away

2. **Setting Up Directions**
   - Start with South (default view)
   - Use "Copy to Direction" for base
   - Adjust shapes for each angle

3. **Mirroring Trick**
   - East mirrors to West
   - Only need to create 5 directions
   - Tool handles mirroring on export

### Creating Side Views (3-4 min)
- Demonstrate creating East view
- Adjust shape positions for side profile
- Re-rig body parts for side perspective
- Create matching poses

### Export Multi-Directional (1-2 min)
- Enable "Export All Directions"
- Each animation × each direction
- Naming convention: walk_south, walk_east, etc.

### Closing (30 sec)
- Recap of full workflow
- Link to documentation
- "Create something amazing!"

---

## Supplementary Videos

### Quick Tips: Shape Library (3 min)
- Saving shape groups
- Built-in library items
- Creating armor/weapon variations

### Quick Tips: Reference Images (2 min)
- Loading reference images
- Adjusting opacity
- Tracing over pixel art

### Quick Tips: Undo/Redo & Auto-Save (2 min)
- Undo/redo system
- Auto-save recovery
- Best practices for saving

---

## Production Notes

### Recording Setup
- Resolution: 1920x1080
- Godot editor in maximized window
- Plugin panel clearly visible
- Cursor highlight enabled

### Pacing
- Slow, deliberate mouse movements
- Pause on important UI elements
- Repeat key actions

### Audio
- Clear narration
- Background music (subtle)
- Sound effects for clicks (optional)

### Editing
- Zoom on important areas
- Add callouts/annotations
- Include chapter markers

---

## File Assets Needed

- Example project files for each episode
- Completed character .charproj files
- Exported sprite sheets for thumbnails
- Chapter marker timestamps
