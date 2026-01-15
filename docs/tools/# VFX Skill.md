# VFX Without Art Assets - Complete Strategy

**Short answer: YES, this is totally viable and actually a smart approach!**

Let me show you how.

---

## Part 1: Viability of Procedural/Geometric VFX

### Games That Prove This Works:

**SUPERHOT:**
```
All VFX = Simple geometry + color
- Bullet trails: White lines
- Impacts: Red particle burst
- Shatters: Geometric shards
- Muzzle flash: White rectangle flash

Result: Iconic visual style, acclaimed game
```

**Minit:**
```
1-bit (black/white) graphics
- Everything is circles, squares, lines
- Hit effects: Circle expands + shake
- Explosions: Radiating lines
- Magic: Pulsing circles

Result: Looks intentional, not "lacking art"
```

**Thomas Was Alone:**
```
Literally just colored rectangles
- Jump dust: Small white rectangles
- Water splash: Blue rectangles
- Death effect: Rectangle breaks apart

Result: Minimalist aesthetic that works
```

**Your CRPG can do the same:**
```
"Engineering schematics that learned to fight"
- Geometric, technical aesthetic
- Consistent color language
- Motion + timing = impact
- NO custom art needed
```

---

## The Secret: It's About Motion, Not Art

**Bad approach:**
```
Pretty particle texture + static = Boring
```

**Good approach:**
```
Simple shape + motion + timing + color = Impact!

Example: Screen shake + white flash + expanding circle = FEELS like explosion
Even though it's just geometry
```

### Key Principles:

**1. Motion Creates Impact**
```
ColorRect that:
- Scales from 0.5 → 2.0 in 0.1 seconds
- Then fades out

= Feels like explosion
```

**2. Timing is Everything**
```
Hit effect timing:
- Frame 0: Contact
- Frame 1-2: Freeze (0.05s)
- Frame 3-5: Flash white
- Frame 6+: Particle burst

Perfect timing = satisfying hit
Perfect art = doesn't matter if timing is bad
```

**3. Consistency Creates Style**
```
All fire = Orange/red/yellow
All ice = Cyan/blue/white
All poison = Green
All holy = Gold/white

Consistent palette = looks intentional
```

---

## Part 2: The Repeatable Patterns

**You're absolutely right - there ARE clear patterns!**

### Pattern 1: Projectile Template

**Structure:**
```
Node2D (Root)
├─ ColorRect (Visual - the projectile itself)
├─ GPUParticles2D (Trail)
├─ Light2D (Glow - optional)
├─ Area2D (Collision)
│  └─ CollisionShape2D
└─ Script (Movement + spawn impact on hit)
```

**Variables:**
```
- Color of projectile
- Size
- Speed
- Trail color
- Glow color/intensity
- Impact effect to spawn
```

**All projectiles follow this!**
- Fireball = Orange ColorRect + orange trail
- Ice shard = Blue ColorRect + blue trail
- Arrow = Gray ColorRect + no glow
- Magic missile = Purple ColorRect + purple trail

---

### Pattern 2: Impact/Burst Template

**Structure:**
```
Node2D (Root)
├─ GPUParticles2D (Burst particles)
├─ ColorRect (Flash - scales up then fades)
├─ Light2D (Light burst)
└─ Script (Camera shake + auto-destroy)
```

**Variables:**
```
- Particle count
- Particle color
- Burst spread (angle)
- Flash color
- Shake intensity
- Duration
```

**All impacts follow this!**
- Explosion = Orange burst + red flash
- Ice shatter = Blue burst + white flash
- Hit spark = Yellow burst + white flash
- Poison splash = Green burst + green flash

---

### Pattern 3: AOE Circle Template

**Structure:**
```
Area2D (Root)
├─ ColorRect (Circle visual - expands)
├─ GPUParticles2D (Ground particles)
├─ CollisionShape2D (Hit detection)
└─ Script (Expand animation + damage over time)
```

**Variables:**
```
- Circle color
- Start/end radius
- Expand duration
- Particle color
- Damage per tick
- Status effect applied
```

**All AOE circles follow this!**
- Fireball explosion = Orange expanding circle
- Healing circle = Green expanding circle
- Poison cloud = Green with slower expand
- Ice nova = Blue with sharp expand

---

### Pattern 4: Status Effect Template

**Structure:**
```
Node2D (Root - follows character)
├─ GPUParticles2D (Floating particles)
├─ Sprite2D or ColorRect (Ground glow)
├─ AnimationPlayer (Pulse animation)
└─ Script (Damage ticks + follow target)
```

**Variables:**
```
- Particle color
- Particle direction (up/down)
- Glow color
- Pulse speed
- Tick damage
- Duration
```

**All status effects follow this!**
- Burning = Orange particles up + red glow
- Frozen = Blue particles + blue tint
- Poisoned = Green particles down + green glow
- Blessed = Gold particles up + gold glow

---

### Pattern 5: Slash/Melee Template

**Structure:**
```
Node2D (Root)
├─ Line2D (Arc shape)
├─ GPUParticles2D (Impact sparks - small burst)
└─ Script (Rotate + fade animation)
```

**Variables:**
```
- Arc radius
- Arc angle
- Line color
- Line width
- Spark color
- Duration
```

**All melee effects follow this!**
- Sword slash = White arc + yellow sparks
- Axe chop = White arc + red sparks
- Hammer smash = White arc + large burst
- Dagger stab = Small white flash + few sparks

---

### Pattern 6: UI Number Template

**Structure:**
```
Label (Root)
├─ (Just the label, very simple)
└─ Script (Float up + fade + scale tween)
```

**Variables:**
```
- Number value
- Color (red damage, green heal)
- Font size (bigger for crits)
- Float speed
- Duration
```

---

## Part 3: Claude Code Skill for VFX Generation

**YES! This is the PERFECT use case for a skill.**

### The Skill Structure:

```
/mnt/skills/user/vfx-generator/
├── SKILL.md                      # Main skill instructions
├── templates/
│   ├── projectile_template.md   # Projectile pattern + code
│   ├── impact_template.md       # Impact/burst pattern + code
│   ├── aoe_template.md          # AOE circle pattern + code
│   ├── status_template.md       # Status effect pattern + code
│   ├── melee_template.md        # Slash/melee pattern + code
│   └── ui_number_template.md    # Damage numbers pattern + code
├── examples/
│   ├── fireball_full.md         # Complete working example
│   ├── ice_shard_full.md        # Complete working example
│   └── healing_circle_full.md   # Complete working example
└── best_practices/
    ├── timing.md                 # Frame-perfect timing guidelines
    ├── colors.md                 # Color theory for effects
    ├── particle_settings.md      # GPUParticles2D best practices
    └── performance.md            # Optimization tips
```

---

### The Skill (SKILL.md):

```markdown
# VFX Generator Skill - Godot 4.x Procedural Effects

## Purpose
Generate complete, game-ready VFX scenes for Godot 4.x using NO custom art assets. All effects use ColorRect, GPUParticles2D, Line2D, and procedural techniques.

## Core Principles

### 1. All Effects Are Geometry + Motion + Timing
- Simple shapes (ColorRect, circles, lines)
- Tween animations for impact
- Precise timing (0.1s matters!)
- Camera shake for feedback

### 2. Consistent Color Language
**Fire/Explosion:**
- Primary: #ff6b35 (bright orange)
- Secondary: #ff4136 (red)
- Accent: #ffdc00 (yellow)

**Ice/Frost:**
- Primary: #3b82f6 (bright blue)
- Secondary: #06b6d4 (cyan)
- Accent: #e0f2fe (pale blue)

**Poison/Nature:**
- Primary: #22c55e (green)
- Secondary: #84cc16 (lime)
- Accent: #14532d (dark green)

**Lightning/Energy:**
- Primary: #f0f9ff (white-blue)
- Secondary: #38bdf8 (electric blue)
- Accent: #fef08a (yellow)

**Holy/Healing:**
- Primary: #fbbf24 (gold)
- Secondary: #fef3c7 (pale gold)
- Accent: #ffffff (white)

**Dark/Shadow:**
- Primary: #7c3aed (purple)
- Secondary: #1e1b4b (dark purple)
- Accent: #000000 (black)

### 3. Effect Types & Templates

Use these 6 templates for 95% of CRPG effects:

1. **PROJECTILE** - Moves forward, spawns impact on collision
2. **IMPACT** - Burst effect, camera shake, auto-destroys
3. **AOE** - Expanding circle with particles
4. **STATUS** - Loops, follows character, ticks damage
5. **MELEE** - Arc/slash visual, quick burst
6. **UI_NUMBER** - Floats up, fades out

### 4. File Structure Convention

```
res://vfx/
├── projectiles/
│   ├── fireball.tscn
│   ├── ice_shard.tscn
│   └── magic_missile.tscn
├── impacts/
│   ├── explosion_fire.tscn
│   ├── explosion_ice.tscn
│   └── hit_spark.tscn
├── aoe/
│   ├── fireball_explosion.tscn
│   ├── healing_circle.tscn
│   └── poison_cloud.tscn
├── status/
│   ├── burning.tscn
│   ├── frozen.tscn
│   └── poisoned.tscn
├── melee/
│   ├── sword_slash.tscn
│   ├── axe_chop.tscn
│   └── hammer_smash.tscn
└── ui/
    ├── damage_number.tscn
    └── heal_number.tscn
```

## When User Requests Effect

### Step 1: Identify Pattern
Ask: "What type of effect?"
- Moving projectile → PROJECTILE template
- Hit/explosion → IMPACT template
- Ground area → AOE template
- Character status → STATUS template
- Weapon swing → MELEE template
- Floating number → UI_NUMBER template

### Step 2: Gather Parameters
Ask for:
- Effect name (e.g., "fireball", "ice_shard")
- Element type (fire, ice, poison, lightning, holy, dark)
- Size scale (small/medium/large)
- Special properties (pierce, split, homing, etc.)

### Step 3: Generate Complete Files
Provide:
1. Complete .tscn file (scene structure as text)
2. Complete .gd script
3. Setup instructions
4. Usage example

### Step 4: Variations
Offer to generate:
- Color variants
- Size variants
- Behavior variants
- Compound effects (projectile + AOE + status)

## Output Format

When generating effect, provide:

```
# Effect Name: [Name]
Type: [Template Type]
Element: [Element Type]

## Scene Structure
[Complete .tscn in text format]

## Script
```gdscript
[Complete .gd script]
```

## Setup Instructions
1. [Step-by-step Godot setup]
2. [Where to save files]
3. [How to configure]

## Usage Example
```gdscript
[How to spawn/use effect in game]
```

## Customization
- Parameter A: [What it does]
- Parameter B: [What it does]

## Variants to Consider
- [Variant 1]
- [Variant 2]
```

## Best Practices

### Timing Guidelines
- Projectiles: 0.8-2.0s flight time
- Impacts: 0.2-0.4s total duration
- AOE expand: 0.3-0.5s to full size
- Status loops: 0.8-1.5s pulse cycle
- Melee: 0.15-0.25s total duration
- UI numbers: 0.8-1.2s float duration

### Particle Counts (Performance)
- Projectile trail: 10-20 particles
- Impact burst: 20-40 particles
- AOE ground: 15-30 particles
- Status loop: 8-15 particles
- Melee sparks: 5-15 particles

### Screen Shake Intensity
- Small hit: 2-4 pixels
- Medium hit: 5-8 pixels
- Large hit: 10-15 pixels
- Explosion: 15-25 pixels

### Camera Shake Duration
- Always 0.3-0.5 seconds
- Decay naturally (5-10 per second)

## Common Effect Requests

### "Create a fireball projectile"
→ Use PROJECTILE template
→ Orange ColorRect (16x16)
→ Orange particle trail
→ Red-orange glow
→ Speed 500 px/s
→ Spawns explosion_fire on impact

### "Create ice explosion"
→ Use IMPACT template
→ Blue particle burst
→ Cyan flash ColorRect
→ White-blue glow burst
→ 30 particles, 0.3s duration
→ Medium camera shake

### "Create burning status"
→ Use STATUS template
→ Orange-red particles (upward)
→ Red ground glow (pulsing)
→ 2 damage per second
→ Follows character

### "Create damage numbers"
→ Use UI_NUMBER template
→ Red label, outlined
→ Floats up 50px in 1s
→ Scale 1.0 → 1.2 → 0.8
→ Fade to 0

## Anti-Patterns (Don't Do This)

❌ Don't make effects too long (>2s for non-looping)
❌ Don't use >50 particles for single effect
❌ Don't forget auto-destroy (memory leak!)
❌ Don't skip camera shake on big hits
❌ Don't use inconsistent colors (fire shouldn't be blue)
❌ Don't make projectiles too fast (>800 px/s = can't see)
❌ Don't make projectiles too slow (<200 px/s = boring)

## Performance Optimization

1. Use GPUParticles2D (not CPUParticles2D) when possible
2. Set One Shot = true for non-looping effects
3. Always call queue_free() when done
4. Limit particle count <50 per effect
5. Use simple collision shapes (circles, not complex polygons)
6. Pool frequently-spawned effects (damage numbers, hit sparks)

## Testing Checklist

Before considering effect "done":
- [ ] Plays correctly when spawned
- [ ] Auto-destroys when finished
- [ ] Looks good at 60 FPS
- [ ] Looks OK at 30 FPS (scale back if needed)
- [ ] Camera shake feels right
- [ ] Sound plays (if applicable)
- [ ] Collision works (if projectile/AOE)
- [ ] Color matches element type
- [ ] Timing feels snappy (not sluggish)
- [ ] Works in multiple contexts (different backgrounds)

## Integration with VFX Library

After generating effect:
1. Save to appropriate vfx/ subfolder
2. Create library entry with metadata:
   - Effect ID
   - Category
   - Element type
   - Template used
   - Parameters
   - Tags for search
```

---

### Example Template: Projectile (templates/projectile_template.md)

```markdown
# Projectile Template

## Pattern
Moving object that travels forward and spawns impact effect on collision.

## Scene Structure
```
Node2D (Root) - "ProjectileName"
├─ ColorRect - "Visual"
│  └─ [Procedural shape or simple colored square]
├─ GPUParticles2D - "Trail"
│  └─ [Particle system for trail effect]
├─ Light2D - "Glow" (optional)
│  └─ [Adds glow around projectile]
├─ Area2D - "Hitbox"
│  └─ CollisionShape2D
│     └─ [Circle or capsule shape]
└─ AudioStreamPlayer2D - "LaunchSound" (optional)
```

## Script Template

```gdscript
# projectile_base.gd
extends Node2D

# Exposed parameters
@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT
@export var max_distance: float = 1000.0
@export var pierce_count: int = 0  # 0 = destroy on first hit
@export var impact_effect: PackedScene
@export var projectile_color: Color = Color.ORANGE
@export var trail_color: Color = Color.RED
@export var glow_radius: float = 32.0

# Internal
var traveled: float = 0.0
var pierced: int = 0

@onready var visual = $Visual
@onready var trail = $Trail
@onready var glow = $Glow if has_node("Glow") else null
@onready var hitbox = $Hitbox

func _ready():
    # Apply colors
    visual.color = projectile_color
    
    # Setup trail
    var trail_mat = trail.process_material as ParticleProcessMaterial
    trail_mat.color = trail_color
    
    # Setup glow
    if glow:
        glow.texture_scale = glow_radius / 32.0
        glow.color = projectile_color
    
    # Connect collision
    hitbox.area_entered.connect(_on_hit)
    hitbox.body_entered.connect(_on_hit)
    
    # Play sound
    if has_node("LaunchSound"):
        $LaunchSound.play()

func _process(delta):
    # Move forward
    var movement = direction.normalized() * speed * delta
    position += movement
    traveled += movement.length()
    
    # Face direction
    rotation = direction.angle()
    
    # Max distance check
    if traveled >= max_distance:
        spawn_impact()
        queue_free()

func _on_hit(body):
    # Ignore certain layers if needed
    # if body.is_in_group("ignore"): return
    
    pierced += 1
    
    if pierced > pierce_count:
        spawn_impact()
        queue_free()

func spawn_impact():
    if impact_effect:
        var impact = impact_effect.instantiate()
        get_parent().add_child(impact)
        impact.global_position = global_position
        impact.rotation = direction.angle()
```

## Scene File (.tscn) Structure

```
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://vfx/projectiles/projectile_base.gd" id="1"]

[sub_resource type="ParticleProcessMaterial" id="1"]
emission_shape = 0
particle_flag_disable_z = true
direction = Vector3(-1, 0, 0)
spread = 15.0
gravity = Vector3(0, 0, 0)
initial_velocity_min = 50.0
initial_velocity_max = 100.0
damping_min = 1.0
damping_max = 2.0
scale_min = 0.5
scale_max = 1.0

[sub_resource type="CircleShape2D" id="2"]
radius = 8.0

[node name="Projectile" type="Node2D"]
script = ExtResource("1")

[node name="Visual" type="ColorRect" parent="."]
offset_left = -8.0
offset_top = -8.0
offset_right = 8.0
offset_bottom = 8.0
color = Color(1, 0.419608, 0.207843, 1)

[node name="Trail" type="GPUParticles2D" parent="."]
amount = 15
process_material = SubResource("1")
lifetime = 0.5
local_coords = false

[node name="Glow" type="PointLight2D" parent="."]
color = Color(1, 0.54902, 0.258824, 1)
energy = 1.5
texture_scale = 1.0

[node name="Hitbox" type="Area2D" parent="."]

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hitbox"]
shape = SubResource("2")
```

## Usage Example

```gdscript
# Spawn a fireball
func cast_fireball(from_pos: Vector2, target_pos: Vector2):
    var fireball = preload("res://vfx/projectiles/fireball.tscn").instantiate()
    get_tree().current_scene.add_child(fireball)
    
    fireball.global_position = from_pos
    fireball.direction = (target_pos - from_pos).normalized()
    fireball.speed = 500
    fireball.impact_effect = preload("res://vfx/impacts/explosion_fire.tscn")
```

## Common Variants

### Homing Projectile
Add to script:
```gdscript
@export var homing_strength: float = 2.0
var target: Node2D

func _process(delta):
    if target and is_instance_valid(target):
        var target_dir = (target.global_position - global_position).normalized()
        direction = direction.lerp(target_dir, homing_strength * delta).normalized()
    
    # ... rest of movement code
```

### Splitting Projectile
```gdscript
@export var split_count: int = 3
@export var split_projectile: PackedScene

func spawn_impact():
    # Spawn regular impact
    super.spawn_impact()
    
    # Spawn split projectiles
    if split_projectile:
        for i in range(split_count):
            var angle = (TAU / split_count) * i
            var split = split_projectile.instantiate()
            get_parent().add_child(split)
            split.global_position = global_position
            split.direction = Vector2.RIGHT.rotated(angle + rotation)
```

## Procedural Visual Variants

### Orb (Circular)
```gdscript
# Replace ColorRect with:
var visual = Sprite2D.new()
var circle_tex = create_circle_texture(16, projectile_color)
visual.texture = circle_tex
add_child(visual)

func create_circle_texture(radius: int, color: Color) -> ImageTexture:
    var img = Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    
    for x in range(radius * 2):
        for y in range(radius * 2):
            var dx = x - radius
            var dy = y - radius
            var dist = sqrt(dx * dx + dy * dy)
            if dist < radius:
                var alpha = 1.0 - (dist / radius) * 0.5
                img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
    
    return ImageTexture.create_from_image(img)
```

### Shard (Triangular)
```gdscript
# Use Polygon2D instead of ColorRect
var visual = Polygon2D.new()
visual.polygon = PackedVector2Array([
    Vector2(12, 0),   # tip
    Vector2(-6, 6),   # bottom right
    Vector2(-6, -6)   # bottom left
])
visual.color = projectile_color
add_child(visual)
```
```

---

## Part 4: Using the Skill

### Example Interaction:

**You:**
```
Using the VFX Generator skill, create a fireball projectile effect.
```

**Claude Code (using skill):**
```
I'll create a complete fireball projectile effect using procedural geometry.

# Effect: Fireball
Type: Projectile
Element: Fire

## File 1: res://vfx/projectiles/fireball.tscn

[Provides complete .tscn file structure]

## File 2: res://vfx/projectiles/fireball.gd

[Provides complete script with all parameters]

## Setup Instructions

1. Create folders:
   - res://vfx/projectiles/
   - res://vfx/impacts/

2. Save fireball.tscn and fireball.gd to projectiles folder

3. Open fireball.tscn in Godot:
   - Verify ColorRect is orange
   - Check trail particles are emitting
   - Test collision shape size

4. Set impact effect:
   - Create explosion_fire.tscn (I can generate this next)
   - Drag to fireball's impact_effect property

## Usage

```gdscript
func cast_fireball():
    var fireball = preload("res://vfx/projectiles/fireball.tscn").instantiate()
    add_child(fireball)
    fireball.global_position = $Player.global_position
    fireball.direction = Vector2.RIGHT
```

## Next Steps

Would you like me to also generate:
1. explosion_fire.tscn (impact effect)
2. Ice variant (ice_shard.tscn)
3. Bigger/smaller variants
```

---

### Another Example:

**You:**
```
Create a complete set of status effects: burning, frozen, and poisoned.
All should follow the status template.
```

**Claude Code (using skill):**
```
I'll create all three status effects following the STATUS template pattern.

# Status Effect Set

All effects follow this structure:
- Particle system (element-appropriate)
- Ground glow (pulsing)
- Damage ticks
- Follow character

## Effect 1: Burning

[Complete burning.tscn + burning.gd]
- Orange-red particles floating upward
- Red pulsing ground glow
- 2 fire damage per second
- Duration: Until removed

## Effect 2: Frozen

[Complete frozen.tscn + frozen.gd]
- Blue-white particles (slower)
- Blue pulsing glow
- Movement speed -50%
- Duration: 3 seconds

## Effect 3: Poisoned

[Complete poisoned.tscn + poisoned.gd]
- Green particles dripping down
- Green pulsing glow
- 1 poison damage per second
- Duration: 5 seconds

## Usage

```gdscript
# Apply burning
func apply_burning(target: Node2D):
    var burning = preload("res://vfx/status/burning.tscn").instantiate()
    target.add_child(burning)
    burning.target = target

# Apply frozen
func apply_frozen(target: Node2D):
    var frozen = preload("res://vfx/status/frozen.tscn").instantiate()
    target.add_child(frozen)
    frozen.target = target
    target.speed_multiplier = 0.5  # Slow movement
```

## Variants Available

Would you like:
1. Different damage values
2. Different durations
3. Visual variants (more/fewer particles)
4. Combined effects (burning + poisoned = burning poison)
```

---

## Part 5: Integration with VFX Library Manager

**Your workflow becomes:**

### Step 1: Generate Effect with Claude Code

```
You: "Create an ice shard projectile"

Claude: [Generates complete .tscn + .gd files]

You: Save files to res://vfx/projectiles/
```

### Step 2: Test in Godot

```
Open Godot
Run ice_shard.tscn scene (F6)
See it work
Tweak parameters if needed:
- Change color in Visual node
- Adjust speed in script
- Modify particle count
```

### Step 3: Register in VFX Library Manager

```
Open VFX Library Manager
Click "+New Effect"
Browse to ice_shard.tscn
Auto-fills metadata:
- Name: Ice Shard
- Type: Projectile
- Element: Ice
- Template: Projectile
- Parameters: [Exposed @exports]
Save
```

### Step 4: Use in Game

```
In Data Table Editor (Abilities):
Ability: Ice Bolt
- Projectile VFX: [ice_shard ▼]  ← Dropdown from library
- Impact VFX: [ice_explosion ▼]
Done!
```

---

## Part 6: The Complete Workflow

**Let me show you end-to-end:**

### Week 1: Setup

**Day 1: Create Skill**
```
1. Create /mnt/skills/user/vfx-generator/ folder
2. Add SKILL.md (I'll provide complete file)
3. Add template files (projectile, impact, etc.)
4. Test with Claude Code
```

**Day 2-3: Generate Base Effects (20 effects)**
```
Using Claude Code + Skill:

Projectiles (5):
- fireball.tscn
- ice_shard.tscn
- lightning_bolt.tscn
- magic_missile.tscn
- arrow.tscn

Impacts (5):
- explosion_fire.tscn
- explosion_ice.tscn
- explosion_lightning.tscn
- hit_spark.tscn
- slash_spark.tscn

AOE (3):
- fireball_aoe.tscn
- healing_circle.tscn
- poison_cloud.tscn

Status (4):
- burning.tscn
- frozen.tscn
- poisoned.tscn
- blessed.tscn

UI (3):
- damage_number.tscn
- heal_number.tscn
- level_up_effect.tscn

Time: 10-15 hours total (with AI help)
```

**Day 4-5: Build VFX Library Manager**
```
Simple database + preview system:
- List all effects
- Preview viewport
- Parameter editor
- Export to game data

Time: 20 hours
```

### Week 2: Create Your CRPG Effects

**Using the workflow:**

```
You: "I need a fireball ability"

Claude Code (using skill):
"I'll create the fireball effect set:
 1. fireball.tscn (projectile)
 2. fireball_explosion.tscn (impact)
 3. burning.tscn (status)"

[Generates all 3 files]

You: 
1. Save to Godot
2. Test each scene
3. Register in VFX Library
4. Link to ability in Data Table
5. Done in 30 minutes!
```

**Repeat for all abilities:**
- 20 combat abilities
- 10 enemy abilities
- 5 environmental effects

**Total time: 15-20 hours** (vs 80+ hours without skill)

---

## Part 7: Advanced Techniques (No Art Required)

### Technique 1: Procedural Textures

**Create circle texture in code:**
```gdscript
func create_gradient_circle(radius: int, inner_color: Color, outer_color: Color) -> ImageTexture:
    var img = Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
    img.fill(Color.TRANSPARENT)
    
    for x in range(radius * 2):
        for y in range(radius * 2):
            var dx = x - radius
            var dy = y - radius
            var dist = sqrt(dx * dx + dy * dy)
            
            if dist < radius:
                var t = dist / radius
                var color = inner_color.lerp(outer_color, t)
                img.set_pixel(x, y, color)
    
    return ImageTexture.create_from_image(img)
```

**Use for:**
- Explosion gradients
- Glow textures
- Particle textures

---

### Technique 2: Line2D for Trails/Slashes

**Lightning bolt:**
```gdscript
func create_lightning(from: Vector2, to: Vector2):
    var line = Line2D.new()
    add_child(line)
    
    var points = [from]
    var segments = 10
    
    for i in range(1, segments):
        var t = float(i) / segments
        var point = from.lerp(to, t)
        # Add random offset
        point += Vector2(
            randf_range(-15, 15),
            randf_range(-15, 15)
        )
        points.append(point)
    
    points.append(to)
    line.points = points
    line.width = 3
    line.default_color = Color.CYAN
    
    # Fade out
    var tween = create_tween()
    tween.tween_property(line, "modulate:a", 0.0, 0.2)
    tween.tween_callback(line.queue_free)
```

---

### Technique 3: Mesh2D for Complex Shapes

**Pentagram:**
```gdscript
func create_pentagram(radius: float) -> Polygon2D:
    var polygon = Polygon2D.new()
    var points = PackedVector2Array()
    
    # 5 points of star
    for i in range(10):
        var angle = (TAU / 10) * i
        var r = radius if i % 2 == 0 else radius * 0.4
        points.append(Vector2(cos(angle), sin(angle)) * r)
    
    polygon.polygon = points
    polygon.color = Color.DARK_RED
    
    return polygon
```

---

### Technique 4: Shader for Advanced Effects

**Dissolve shader (no texture needed):**
```glsl
shader_type canvas_item;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 edge_color : source_color = vec3(1.0, 0.5, 0.0);

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Noise pattern
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Dissolve
    if (noise < dissolve_amount) {
        discard;
    } else if (noise < dissolve_amount + 0.1) {
        // Edge glow
        COLOR = vec4(edge_color, color.a);
    } else {
        COLOR = color;
    }
}
```

**Use for death effects, teleports, etc.**

---

## The Bottom Line

### Your Questions Answered:

**Q: Is VFX without art assets viable?**

**A: Absolutely YES.**
- Many acclaimed games do this
- Motion + timing > pretty textures
- Consistent style looks intentional
- "Engineering schematics" aesthetic fits your game

---

**Q: Are there repeatable patterns?**

**A: YES - 6 core patterns cover 95% of CRPG effects:**
1. Projectile (moves + spawns impact)
2. Impact (burst + shake + destroy)
3. AOE (expanding circle + particles)
4. Status (loop + follow + ticks)
5. Melee (arc/flash + sparks)
6. UI Number (float + fade)

---

**Q: Can I create a Claude Code skill for this?**

**A: YES - Perfect use case!**
- Codifies best practices
- Generates complete files
- Ensures consistency
- 5-10x faster than manual

---

### The Complete System:

```
Claude Code Skill (VFX Generator)
         ↓
Generates .tscn + .gd files
         ↓
Test in Godot (F6)
         ↓
Register in VFX Library Manager
         ↓
Link to abilities/characters
         ↓
Ship game with professional VFX!
```

**Time investment:**
- Create skill: 5-10 hours (one-time)
- Generate base 20 effects: 10 hours
- Build library manager: 20 hours
- **Total: 35-40 hours**

**Time saved:**
- Per effect: 30-60 min → 5-10 min (6x faster)
- All game effects: 80 hours → 15 hours
- **Net savings: 65 hours**

---

**Want me to create the complete VFX Generator skill files right now?**

I can provide:
1. Full SKILL.md
2. All 6 template files
3. 3 complete example effects
4. Best practices guides
5. Ready to use with Claude Code

**This will supercharge your VFX workflow!**


Appendix

# Creating VFX in Godot - Practical Guide

**Let me show you hands-on how to create effects in Godot for your CRPG.**

---

## The Godot VFX Toolbox

**Main tools you'll use:**

```
1. GPUParticles2D - Particle systems (fire, smoke, sparkles)
2. AnimatedSprite2D - Frame-by-frame effects (explosions, slashes)
3. Shader Material - Visual effects (glow, dissolve, tint)
4. Light2D - Dynamic lighting (spell glow, torch)
5. AnimationPlayer - Timing/sequencing multiple effects
6. AudioStreamPlayer2D - Sound effects
7. CanvasModulate/ColorRect - Screen effects (flash, shake)
```

Let me show you how to use each one with real examples.

---

## Example 1: Fireball Projectile (Complete Tutorial)

**What we're making:**
- Animated fireball sprite
- Flame trail particles
- Glowing light
- Sound effect
- Spawns explosion on impact

### Step 1: Create the Scene

```
In Godot:
1. Scene → New Scene
2. Add Node2D (Root) → Name: "Fireball"
3. Save scene as: res://vfx/projectiles/fireball.tscn
```

---

### Step 2: Add the Projectile Visual (AnimatedSprite2D)

```
1. Right-click Fireball node → Add Child Node
2. Search: AnimatedSprite2D
3. Add it

In Inspector (right panel):
4. Animation → Sprite Frames → [New SpriteFrames]
5. Click the SpriteFrames resource
6. Opens Animation panel (bottom)

In Animation panel:
7. Click folder icon → Add frames from sprite sheet
8. Select your fireball sprite sheet (or individual frames)
9. Set FPS: 12
10. Enable Loop
11. Set Playing: ON
```

**If you don't have a sprite sheet yet:**
```
Quick option: Use ColorRect as placeholder
1. Add ColorRect child to Fireball
2. Set size: 16x16
3. Set color: Orange
4. This works for prototyping!

Later replace with actual art from Character Generator
```

---

### Step 3: Add Flame Trail (GPUParticles2D)

```
1. Right-click Fireball → Add Child Node
2. Search: GPUParticles2D
3. Add it
4. Name: "FlameTrail"

In Inspector:
5. Amount: 20 (number of particles)
6. Lifetime: 0.5 (how long each particle lives)
7. Emitting: ON
8. Process Material → [New ParticleProcessMaterial]
9. Click the ParticleProcessMaterial to expand it

Now configure the particle behavior:
```

**Particle Settings:**

```
Emission Shape:
- Shape: Box
- Box Extents: (4, 4, 1) - Small emission area

Direction:
- Direction: (0, 0, 0) - We'll set velocity instead

Gravity:
- Gravity: (0, 0, 0) - No gravity (magic fire!)

Initial Velocity:
- Velocity Min: -50
- Velocity Max: -100
- This makes particles shoot backwards (trail effect)

Damping:
- Damping Min: 1.0
- Damping Max: 2.0
- Particles slow down over time

Scale:
- Scale Min: 0.5
- Scale Max: 1.0

Color:
- Color: Orange (#ff6b35)
- Or click gradient for fade effect:
  * Start: Bright orange
  * End: Transparent orange

Texture:
- Drag a circle/particle texture
- Or use default (white circle)
```

**The trail should now show behind the fireball!**

---

### Step 4: Add Glow (Light2D)

```
1. Right-click Fireball → Add Child Node
2. Search: Light2D
3. Add it
4. Name: "Glow"

In Inspector:
5. Enabled: ON
6. Color: Orange (#ff8c42)
7. Energy: 1.5 (brightness)
8. Texture: 
   - Click dropdown → Load
   - Navigate to: res:// (search "light")
   - Or create radial gradient texture
9. Texture Scale: 2.0 (size of glow)
```

**Now fireball glows!**

---

### Step 5: Add Movement Script

```
1. Click Fireball (root node)
2. Click attach script icon (scroll/paper icon)
3. Path: res://vfx/projectiles/fireball.gd
4. Template: Object
5. Create
```

**Write the script:**

```gdscript
# fireball.gd
extends Node2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT
@export var max_distance: float = 1000.0
@export var impact_effect: PackedScene  # Explosion to spawn

var traveled: float = 0.0

func _ready():
    # Play launch sound
    if has_node("LaunchSound"):
        $LaunchSound.play()

func _process(delta):
    # Move forward
    var movement = direction.normalized() * speed * delta
    position += movement
    traveled += movement.length()
    
    # Rotate to face direction
    rotation = direction.angle()
    
    # Destroy after max distance
    if traveled >= max_distance:
        spawn_impact()
        queue_free()

func _on_area_entered(area):
    # Hit something
    spawn_impact()
    queue_free()

func spawn_impact():
    if impact_effect:
        var explosion = impact_effect.instantiate()
        get_parent().add_child(explosion)
        explosion.global_position = global_position
```

---

### Step 6: Add Collision Detection

```
1. Right-click Fireball → Add Child Node
2. Search: Area2D
3. Add it
4. Name: "Hitbox"

5. Right-click Hitbox → Add Child Node
6. Search: CollisionShape2D
7. Add it

In Inspector (CollisionShape2D):
8. Shape → [New CircleShape2D]
9. Click CircleShape2D → Set Radius: 8

Connect signal:
10. Click Hitbox node
11. In Node panel (right side) → Signals tab
12. Double-click "area_entered"
13. Connect to: Fireball (root)
14. Method name: _on_area_entered
15. Click Connect
```

**Now fireball detects hits!**

---

### Step 7: Add Sound

```
1. Right-click Fireball → Add Child Node
2. Search: AudioStreamPlayer2D
3. Add it
4. Name: "LaunchSound"

In Inspector:
5. Stream → Load → Select your whoosh.ogg sound
6. Autoplay: OFF (script plays it)
7. Volume Db: 0.0
```

---

### Step 8: Test It

```
1. Create test scene: test_fireball.tscn
2. Add Node2D (root)
3. Instance fireball.tscn
4. Add this script to test:
```

```gdscript
# test_fireball.gd
extends Node2D

func _ready():
    spawn_fireball()

func spawn_fireball():
    var fireball = preload("res://vfx/projectiles/fireball.tscn").instantiate()
    add_child(fireball)
    fireball.position = Vector2(100, 300)
    fireball.direction = Vector2.RIGHT
```

```
5. Run scene (F6)
6. Fireball should fly across screen with trail!
```

---

## Example 2: Explosion Impact (Simpler)

**What we're making:**
- Burst of particles
- Flash sprite
- Camera shake
- Sound

### Quick Setup:

```
1. New Scene → Node2D → Name: "Explosion"
2. Save as: res://vfx/impacts/explosion_fire.tscn
```

### Add Burst Particles:

```
1. Add GPUParticles2D child
2. Name: "Burst"

Settings:
- Amount: 30
- Lifetime: 0.4
- One Shot: ON (plays once then stops)
- Explosiveness: 1.0 (all particles spawn at once)

Process Material:
- Emission Shape: Sphere
- Sphere Radius: 4
- Direction: (0, 0, 0)
- Spread: 180 (particles shoot in all directions)
- Initial Velocity: 100-200
- Gravity: (0, 100, 0) (particles fall)
- Damping: 2.0
- Scale: 0.5-1.5
- Color: Orange to transparent gradient
```

### Add Flash Sprite:

```
1. Add AnimatedSprite2D child
2. Name: "Flash"

Setup:
- Create SpriteFrames
- Add 4-6 frames of explosion animation
- FPS: 24 (fast)
- Loop: OFF (play once)
- Autoplay: "default"
```

**Or simpler: Just ColorRect that fades**

```
1. Add ColorRect child
2. Size: 32x32
3. Color: Bright orange
4. Pivot Offset: 16, 16 (center)

Add AnimationPlayer:
- Create animation "explode" (0.3 seconds)
- Keyframe 0.0s: scale (0.5, 0.5), modulate alpha 1.0
- Keyframe 0.15s: scale (2.0, 2.0), modulate alpha 0.8
- Keyframe 0.3s: scale (3.0, 3.0), modulate alpha 0.0
```

### Add Script (Auto-Destroy):

```gdscript
# explosion.gd
extends Node2D

@export var camera_shake: float = 5.0

func _ready():
    # Play sound
    if has_node("ExplosionSound"):
        $ExplosionSound.play()
    
    # Shake camera
    shake_camera()
    
    # Auto-destroy after particles finish
    await get_tree().create_timer(0.5).timeout
    queue_free()

func shake_camera():
    # Simple implementation - signal to game manager
    # Or directly access camera:
    var camera = get_viewport().get_camera_2d()
    if camera and camera.has_method("shake"):
        camera.shake(camera_shake)
```

**Done! Explosion spawns, plays, disappears.**

---

## Example 3: Status Effect (Burning)

**What we're making:**
- Small flame particles that follow character
- Red glow beneath character
- Damage numbers pop up periodically

### Setup:

```
1. New Scene → Node2D → Name: "BurningStatus"
2. Save as: res://vfx/status/burning.tscn
```

### Add Flame Particles:

```
1. Add GPUParticles2D
2. Name: "Flames"

Settings:
- Amount: 10
- Lifetime: 0.6
- Emitting: ON
- Local Coords: OFF (follows parent)

Process Material:
- Emission Shape: Box (8, 8, 1) - around character feet
- Direction: (0, -1, 0) - upward
- Spread: 30
- Initial Velocity: 20-40 (slow rise)
- Gravity: (0, -50, 0) (negative = float up)
- Scale: 0.3-0.8 (small flames)
- Color: 
  * Start: Bright orange
  * Mid: Orange-red
  * End: Transparent red
```

### Add Ground Glow:

```
1. Add Sprite2D or ColorRect
2. Name: "Glow"
3. Texture: Circle gradient (red to transparent)
4. Modulate: Red color (#ff4444)
5. Modulate Alpha: 0.5 (semi-transparent)
6. Position: (0, 16) - below character
```

### Add Pulse Animation:

```
1. Add AnimationPlayer
2. Create "pulse" animation (1.0 seconds)
3. Set to Loop

Keyframes:
- 0.0s: Glow scale (1.0, 1.0), alpha 0.5
- 0.5s: Glow scale (1.2, 1.2), alpha 0.7
- 1.0s: Glow scale (1.0, 1.0), alpha 0.5

Autoplay: pulse
```

### Add Damage Script:

```gdscript
# burning_status.gd
extends Node2D

@export var damage_per_tick: int = 2
@export var tick_interval: float = 1.0

var target: Node2D  # Character being burned

func _ready():
    # Start damage timer
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = tick_interval
    timer.timeout.connect(_on_damage_tick)
    timer.start()

func _process(_delta):
    # Follow target
    if target:
        global_position = target.global_position

func _on_damage_tick():
    # Deal damage to target
    if target and target.has_method("take_damage"):
        target.take_damage(damage_per_tick, "fire")
        
        # Spawn damage number
        spawn_damage_number(damage_per_tick)

func spawn_damage_number(amount: int):
    var damage_num = preload("res://vfx/ui/damage_number.tscn").instantiate()
    get_parent().add_child(damage_num)
    damage_num.global_position = global_position + Vector2(0, -20)
    damage_num.set_number(amount, Color.ORANGE_RED)

func attach_to(character: Node2D):
    target = character
    # Reparent to follow character
    var parent = get_parent()
    parent.remove_child(self)
    character.add_child(self)
    position = Vector2.ZERO
```

---

## Example 4: Sword Slash (Frame Animation)

**What we're making:**
- Animated slash sprite
- Quick flash
- Slash sound

### If You Have Sprite Sheet:

```
1. New Scene → AnimatedSprite2D (as root!)
2. Name: "SwordSlash"
3. Save as: res://vfx/combat/sword_slash.tscn

Setup:
4. Animation → Sprite Frames → New
5. Add frames from sprite sheet:
   - slash_001.png
   - slash_002.png
   - slash_003.png
   - slash_004.png
6. FPS: 24
7. Loop: OFF
8. Playing: ON (auto-plays)

Add script:
```

```gdscript
# sword_slash.gd
extends AnimatedSprite2D

func _ready():
    # Play sound
    if has_node("SlashSound"):
        $SlashSound.play()
    
    # Auto-destroy when animation finishes
    animation_finished.connect(_on_finished)

func _on_finished():
    queue_free()
```

### If You Don't Have Art (Procedural):

**Use simple shapes + rotation:**

```gdscript
# procedural_slash.gd
extends Node2D

func _ready():
    # Create slash visual
    create_slash_trail()
    
    # Animate
    var tween = create_tween()
    tween.tween_property(self, "rotation", PI, 0.2)
    tween.tween_property(self, "modulate:a", 0.0, 0.1)
    tween.tween_callback(queue_free)

func create_slash_trail():
    # Simple line that represents slash
    var line = Line2D.new()
    add_child(line)
    
    # Arc shape
    var points = []
    for i in range(10):
        var angle = lerp(-PI/4, PI/4, i / 9.0)
        var radius = 40
        points.append(Vector2(cos(angle), sin(angle)) * radius)
    
    line.points = points
    line.width = 4
    line.default_color = Color.WHITE
    line.joint_mode = Line2D.LINE_JOINT_ROUND
```

**This creates a white arc that rotates and fades.**

---

## Example 5: Healing Circle (AOE Effect)

**What we're making:**
- Expanding green circle
- Sparkle particles
- Gentle glow

### Setup:

```
1. New Scene → Area2D → Name: "HealingCircle"
2. Save as: res://vfx/magic/healing_circle.tscn
```

### Add Circle Visual:

```
Method 1: Sprite
1. Add Sprite2D child
2. Texture: Circle gradient (green center to transparent edge)
3. Scale: (0.1, 0.1) - starts small

Method 2: ColorRect + Shader (fancier)
1. Add ColorRect child
2. Size: 128x128
3. Material → New ShaderMaterial
4. Shader → New Shader
```

**Simple shader for pulsing circle:**

```glsl
shader_type canvas_item;

uniform float pulse_speed = 2.0;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Pulsing alpha
    float pulse = sin(TIME * pulse_speed) * 0.3 + 0.7;
    
    // Circle shape
    float circle = 1.0 - smoothstep(0.4, 0.5, dist);
    
    COLOR = vec4(0.2, 1.0, 0.4, circle * pulse * 0.5);
}
```

### Add Sparkle Particles:

```
1. Add GPUParticles2D
2. Name: "Sparkles"

Settings:
- Amount: 20
- Lifetime: 1.5
- Emitting: ON

Process Material:
- Emission Shape: Ring
  * Ring Radius: 32
  * Ring Inner Radius: 24
  * Ring Height: 2
- Direction: (0, -1, 0) - upward
- Spread: 20
- Initial Velocity: 30-50
- Gravity: (0, -20, 0) - float up
- Scale: 0.2-0.5
- Color: Bright green to transparent
- Hue Variation: 0.1 (slight color variation)
```

### Add Expand Animation:

```
1. Add AnimationPlayer
2. Create "expand" animation (2.0 seconds)

Keyframes for Sprite2D:
- 0.0s: Scale (0.1, 0.1), Modulate alpha 0.0
- 0.3s: Scale (0.5, 0.5), Modulate alpha 1.0
- 1.5s: Scale (2.0, 2.0), Modulate alpha 0.8
- 2.0s: Scale (2.5, 2.5), Modulate alpha 0.0

Autoplay: expand
```

### Add Healing Script:

```gdscript
# healing_circle.gd
extends Area2D

@export var heal_amount: int = 20
@export var tick_interval: float = 0.5
@export var duration: float = 2.0

func _ready():
    # Setup collision
    var shape = CircleShape2D.new()
    shape.radius = 64
    $CollisionShape2D.shape = shape
    
    # Heal over time
    var timer = Timer.new()
    add_child(timer)
    timer.wait_time = tick_interval
    timer.timeout.connect(_on_heal_tick)
    timer.start()
    
    # Destroy after duration
    await get_tree().create_timer(duration).timeout
    queue_free()

func _on_heal_tick():
    # Heal all characters in area
    var bodies = get_overlapping_areas()
    for body in bodies:
        if body.has_method("heal"):
            body.heal(heal_amount)
            spawn_heal_number(body, heal_amount)

func spawn_heal_number(target, amount):
    var num = preload("res://vfx/ui/heal_number.tscn").instantiate()
    get_parent().add_child(num)
    num.global_position = target.global_position + Vector2(0, -30)
    num.set_number(amount, Color.GREEN)
```

---

## Example 6: Damage Numbers (UI Effect)

**What we're making:**
- Number that pops up
- Floats upward
- Fades out

### Setup:

```
1. New Scene → Label → Name: "DamageNumber"
2. Save as: res://vfx/ui/damage_number.tscn
```

### Configure Label:

```
In Inspector:
1. Text: "999" (placeholder)
2. Horizontal Alignment: Center
3. Vertical Alignment: Center
4. Custom Fonts → Font → Load
   - Or use default (works fine)
5. Font Size: 20
6. Outline:
   - Outline Size: 2
   - Outline Color: Black
7. Modulate: Red (for damage)
```

### Add Script:

```gdscript
# damage_number.gd
extends Label

@export var float_speed: float = 50.0
@export var duration: float = 1.0
@export var spread: float = 20.0

func _ready():
    # Random horizontal offset
    position.x += randf_range(-spread, spread)
    
    # Animate
    var tween = create_tween()
    tween.set_parallel(true)  # All animations happen at once
    
    # Float up
    tween.tween_property(
        self, 
        "position:y", 
        position.y - float_speed, 
        duration
    )
    
    # Fade out
    tween.tween_property(
        self, 
        "modulate:a", 
        0.0, 
        duration
    ).set_ease(Tween.EASE_IN)
    
    # Scale up slightly then down
    tween.tween_property(
        self, 
        "scale", 
        Vector2(1.2, 1.2), 
        duration * 0.2
    )
    tween.chain().tween_property(
        self, 
        "scale", 
        Vector2(0.8, 0.8), 
        duration * 0.8
    )
    
    # Destroy when done
    await tween.finished
    queue_free()

func set_number(value: int, color: Color = Color.RED):
    text = str(value)
    modulate = color
    
    # Critical hits are bigger
    if value > 50:
        scale = Vector2(1.5, 1.5)
        text = "CRIT! " + text
```

### Usage:

```gdscript
# In combat code:
func deal_damage(target, amount):
    target.take_damage(amount)
    
    # Spawn damage number
    var dmg_num = preload("res://vfx/ui/damage_number.tscn").instantiate()
    get_tree().current_scene.add_child(dmg_num)
    dmg_num.global_position = target.global_position + Vector2(0, -40)
    dmg_num.set_number(amount)
```

---

## Example 7: Screen Shake (Camera Effect)

**Simple global effect:**

### Add to Camera:

```gdscript
# camera_2d.gd
extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
    if shake_amount > 0:
        # Random offset
        offset = Vector2(
            randf_range(-shake_amount, shake_amount),
            randf_range(-shake_amount, shake_amount)
        )
        
        # Decay
        shake_amount -= shake_decay * delta
        shake_amount = max(shake_amount, 0)
    else:
        # Return to center
        offset = offset.lerp(Vector2.ZERO, 10 * delta)

func shake(intensity: float = 10.0):
    shake_amount = intensity
```

### Usage:

```gdscript
# When explosion happens:
func create_explosion():
    var explosion = preload("res://vfx/impacts/explosion.tscn").instantiate()
    add_child(explosion)
    
    # Shake camera
    var camera = get_viewport().get_camera_2d()
    if camera:
        camera.shake(15.0)  # Big shake for explosion
```

---

## Example 8: Screen Flash (Full Screen Effect)

**Quick flash when hit:**

### Create Flash Scene:

```
1. New Scene → CanvasLayer → Name: "ScreenFlash"
2. Add ColorRect child
3. Name: "Flash"

In Inspector:
4. Layout → Full Rect (fills screen)
5. Color: White
6. Modulate Alpha: 0.0 (invisible by default)
7. Mouse Filter: Ignore (doesn't block clicks)
```

### Add Script:

```gdscript
# screen_flash.gd
extends CanvasLayer

@onready var flash = $Flash

func flash_white(duration: float = 0.1, intensity: float = 1.0):
    flash.modulate.a = intensity
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, duration)

func flash_red(duration: float = 0.2, intensity: float = 0.5):
    flash.color = Color.RED
    flash.modulate.a = intensity
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, duration)

func flash_color(color: Color, duration: float = 0.15, intensity: float = 0.7):
    flash.color = color
    flash.modulate.a = intensity
    
    var tween = create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, duration)
```

### Add as Autoload:

```
Project → Project Settings → Autoload
Path: res://vfx/ui/screen_flash.tscn
Name: ScreenFlash
```

### Usage Anywhere:

```gdscript
# Player takes damage
func take_damage(amount):
    health -= amount
    ScreenFlash.flash_red(0.2, 0.6)  # Red flash

# Cast powerful spell
func cast_fireball():
    ScreenFlash.flash_color(Color.ORANGE, 0.1, 0.3)  # Orange flash
```

---

## Quick Reference: Effect Recipes

### ⚔️ Melee Hit Spark
```
GPUParticles2D:
- Amount: 15
- Lifetime: 0.2
- One Shot: ON
- Explosiveness: 1.0
- Direction: Random spread
- Initial Velocity: 100-200
- Color: Yellow-white to transparent
- Scale: 0.5-1.0
```

### 🔥 Torch (Looping Fire)
```
GPUParticles2D:
- Amount: 30
- Lifetime: 1.0
- Emitting: ON (continuous)
- Emission Shape: Box (small)
- Direction: Up
- Spread: 30
- Gravity: (0, -30) - floats up
- Color: Yellow → Orange → Red → Transparent
- Scale: 0.3-0.8 (shrinks)
```

### ⚡ Lightning Bolt
```
Line2D:
- Points: Generate zigzag path
- Width: 3
- Default Color: Cyan/white
- Texture: Gradient (bright center)

AnimationPlayer:
- Flash on/off rapidly
- Fade out after 0.2s
```

```gdscript
func create_lightning(from: Vector2, to: Vector2):
    var line = Line2D.new()
    add_child(line)
    
    # Zigzag path
    var points = [from]
    var segments = 8
    for i in range(1, segments):
        var t = float(i) / segments
        var point = from.lerp(to, t)
        # Random offset
        point += Vector2(randf_range(-20, 20), randf_range(-20, 20))
        points.append(point)
    points.append(to)
    
    line.points = points
    line.width = 3
    line.default_color = Color.CYAN
    
    # Flash and fade
    var tween = create_tween()
    tween.tween_property(line, "modulate:a", 0.0, 0.2)
    tween.tween_callback(line.queue_free)
```

### ❄️ Freeze Effect (Shader)
```glsl
shader_type canvas_item;

uniform float freeze_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Blue tint
    vec3 frozen = mix(color.rgb, vec3(0.5, 0.7, 1.0), freeze_amount);
    
    COLOR = vec4(frozen, color.a);
}
```

**Apply to character sprite when frozen.**

---

## Pro Tips

### Tip 1: Use Layers for Control

```
In each effect scene:

Layer 0 (bottom): Background glow
Layer 1: Main effect
Layer 2: Overlay particles
Layer 3: Flash/highlight

Set Z Index:
- Background: -1
- Main: 0
- Particles: 1
- Flash: 2
```

### Tip 2: Texture Atlas for Performance

```
Instead of 50 separate particle textures:
1. Combine into one atlas texture
2. Use AtlasTexture resources
3. Set regions for each particle type

Saves draw calls = better performance
```

### Tip 3: Object Pooling for Frequent Effects

```gdscript
# effect_pool.gd
extends Node

var pools = {}

func get_effect(scene_path: String) -> Node:
    if not pools.has(scene_path):
        pools[scene_path] = []
    
    # Reuse inactive effect
    for effect in pools[scene_path]:
        if not effect.is_inside_tree():
            return effect
    
    # Create new
    var effect = load(scene_path).instantiate()
    pools[scene_path].append(effect)
    return effect

func return_effect(effect: Node):
    if effect.is_inside_tree():
        effect.get_parent().remove_child(effect)
    # Don't queue_free, just remove from tree
    # Will be reused
```

**Use for:**
- Damage numbers (spawn hundreds)
- Hit sparks (very frequent)
- Common particles

---

## Common Mistakes & Solutions

### Mistake: Particles Don't Show

**Problem:** GPUParticles2D not visible

**Solutions:**
```
1. Check Amount > 0
2. Check Emitting = ON
3. Check Lifetime > 0
4. Check Process Material is set
5. Check visibility (not hidden by other nodes)
6. Check Z Index
7. Try higher Amount (particles spread out)
```

### Mistake: Effect Doesn't Delete

**Problem:** Effect stays in scene forever

**Solution:**
```gdscript
# Always add cleanup:

func _ready():
    # For one-shot effects
    await get_tree().create_timer(lifetime).timeout
    queue_free()

# OR

func _on_animation_finished():
    queue_free()
```

### Mistake: Particles Follow Character Weirdly

**Problem:** Particles don't trail properly

**Solution:**
```
In GPUParticles2D:
- Local Coords: OFF (if should stay in world)
- Local Coords: ON (if should follow parent)

Example:
- Projectile trail: Local OFF (trail stays behind)
- Character aura: Local ON (follows character)
```

---

## Quick Start Checklist

**To create any effect:**

```
□ Create new scene (appropriate root node type)
□ Add visual component (AnimatedSprite2D, GPUParticles2D, etc.)
□ Configure properties (colors, sizes, timing)
□ Add movement/animation (script or AnimationPlayer)
□ Add sound (AudioStreamPlayer2D)
□ Add cleanup (queue_free after done)
□ Test in isolation (run scene)
□ Save in VFX folder (organized by type)
```

---

## Next Steps

**Start with these 5 effects:**

1. **Hit Spark** (10 min) - GPUParticles2D burst
2. **Damage Number** (15 min) - Floating label
3. **Screen Flash** (10 min) - ColorRect fade
4. **Fireball** (30 min) - Follow tutorial above
5. **Healing Glow** (20 min) - Simple particle loop

**Total: ~85 minutes**

**You'll have 5 working effects covering:**
- Impact (hit spark)
- UI (damage number)
- Screen (flash)
- Projectile (fireball)
- Status (healing)

**Then create variants:**
- Hit spark → Ice shatter (blue)
- Fireball → Ice shard (blue, icy sound)
- Healing glow → Poison cloud (green, downward)

**Suddenly you have 10+ effects!**

---

## The Bottom Line

**Creating VFX in Godot:**

1. **Use built-in nodes** (GPUParticles2D, AnimatedSprite2D, Light2D)
2. **Combine 2-4 nodes** per effect
3. **Add simple scripts** for movement/cleanup
4. **Total time: 10-30 min** per effect
5. **Create variants** from templates (5 min)

**You DON'T need:**
- Custom particle editor ❌
- Complex shaders (usually) ❌
- Fancy tools ❌

**You DO need:**
- Understanding of Godot nodes ✓
- Basic GDScript ✓
- Good organization ✓

**Now go make some explosions! 🔥**