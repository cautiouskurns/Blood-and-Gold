---
name: vfx-generator
description: Generate complete, game-ready VFX scenes for Godot 4.x using NO custom art assets. Creates procedural effects using GPUParticles2D, ColorRect, Line2D, and geometric shapes. Use this when the user wants to create visual effects without sprites.
domain: vfx
type: generator
version: 1.0.0
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
  - Grep
---

# VFX Generator Skill - Godot 4.x Procedural Effects

This skill generates complete, game-ready VFX scenes for Godot 4.x using **NO custom art assets**. All effects use ColorRect, GPUParticles2D, Line2D, shaders, and procedural techniques to create professional-looking visual effects.

## When to Use This Skill

Invoke this skill when the user:
- Says "create a [effect-name] effect" or "generate VFX for [X]"
- Asks for "procedural effects" or "effects without sprites"
- Says "make a fireball/explosion/healing circle/etc."
- Wants visual effects for combat, magic, status effects, or UI
- Says "create VFX" or "generate particles"

## How to Use This Skill

**IMPORTANT: Always announce at the start that you are using the VFX Generator skill.**

Example: "I'm using the **VFX Generator** skill to create a procedural [effect-name] effect."

---

## Core Principles

### 1. All Effects Are Geometry + Motion + Timing

The secret to great VFX without art is:
- **Simple shapes** (ColorRect, circles, lines)
- **Tween animations** for impact
- **Precise timing** (0.1s matters!)
- **Camera shake** for feedback

**Bad approach:** Pretty particle texture + static = Boring
**Good approach:** Simple shape + motion + timing + color = IMPACT!

### 2. Consistent Color Language

**Fire/Explosion:**
- Primary: `#ff6b35` (bright orange)
- Secondary: `#ff4136` (red)
- Accent: `#ffdc00` (yellow)

**Ice/Frost:**
- Primary: `#3b82f6` (bright blue)
- Secondary: `#06b6d4` (cyan)
- Accent: `#e0f2fe` (pale blue)

**Poison/Nature:**
- Primary: `#22c55e` (green)
- Secondary: `#84cc16` (lime)
- Accent: `#14532d` (dark green)

**Lightning/Energy:**
- Primary: `#f0f9ff` (white-blue)
- Secondary: `#38bdf8` (electric blue)
- Accent: `#fef08a` (yellow)

**Holy/Healing:**
- Primary: `#fbbf24` (gold)
- Secondary: `#fef3c7` (pale gold)
- Accent: `#ffffff` (white)

**Dark/Shadow:**
- Primary: `#7c3aed` (purple)
- Secondary: `#1e1b4b` (dark purple)
- Accent: `#000000` (black)

**Physical/Neutral:**
- Primary: `#d4d4d4` (light gray)
- Secondary: `#a3a3a3` (gray)
- Accent: `#ffffff` (white)

### 3. Six Core Templates

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
│   └── hammer_smash.tscn
└── ui/
    ├── damage_number.tscn
    └── heal_number.tscn
```

---

## Workflow

### Step 1: Identify Pattern

Ask: "What type of effect?"
- Moving projectile → **PROJECTILE** template
- Hit/explosion → **IMPACT** template
- Ground area → **AOE** template
- Character status → **STATUS** template
- Weapon swing → **MELEE** template
- Floating number → **UI_NUMBER** template

### Step 2: Gather Parameters

Determine:
- **Effect name** (e.g., "fireball", "ice_shard")
- **Element type** (fire, ice, poison, lightning, holy, dark, physical)
- **Size scale** (small/medium/large)
- **Special properties** (pierce, split, homing, etc.)

### Step 3: Generate Complete Files

Provide:
1. Complete `.tscn` file content
2. Complete `.gd` script
3. Setup instructions
4. Usage example

### Step 4: Offer Variations

After generating, offer:
- Color variants
- Size variants
- Behavior variants
- Compound effects (projectile + AOE + status)

---

## Output Format

When generating an effect, provide this structure:

```markdown
# Effect: [Name]
**Type:** [Template Type]
**Element:** [Element Type]
**Files:** [List of files to create]

---

## Scene Structure
[ASCII tree of node hierarchy]

## File 1: res://vfx/[category]/[name].tscn
```
[Complete .tscn file content]
```

## File 2: res://vfx/[category]/[name].gd
```gdscript
[Complete script with all functionality]
```

## Setup Instructions
1. Create the directories if needed
2. Save the .tscn file
3. Save the .gd file
4. [Any additional configuration]

## Usage Example
```gdscript
# How to spawn and use this effect
var effect = preload("res://vfx/[path].tscn").instantiate()
get_tree().current_scene.add_child(effect)
effect.global_position = target_position
```

## Customization
- **Parameter A:** [What it does, how to change]
- **Parameter B:** [What it does, how to change]

## Variants Available
Want me to also generate:
1. [Variant 1 description]
2. [Variant 2 description]
```

---

## Template Reference

### PROJECTILE Template

**Scene Structure:**
```
Node2D (Root) - [ProjectileName]
├── ColorRect or Polygon2D - "Visual"
├── GPUParticles2D - "Trail"
├── PointLight2D - "Glow" (optional)
├── Area2D - "Hitbox"
│   └── CollisionShape2D
└── AudioStreamPlayer2D - "LaunchSound" (optional)
```

**Key Parameters:**
- `speed: float` - Movement speed (300-600 typical)
- `direction: Vector2` - Travel direction
- `max_distance: float` - Destroy after this distance
- `pierce_count: int` - How many targets to pierce (0 = destroy on first hit)
- `impact_effect: PackedScene` - Effect to spawn on hit

**Timing Guidelines:**
- Flight time: 0.8-2.0s
- Trail particles: 10-20 count

---

### IMPACT Template

**Scene Structure:**
```
Node2D (Root) - [ImpactName]
├── GPUParticles2D - "Burst"
├── ColorRect - "Flash"
├── PointLight2D - "LightBurst"
└── AudioStreamPlayer2D - "ImpactSound" (optional)
```

**Key Parameters:**
- `particle_count: int` - Burst particle amount (20-40)
- `burst_spread: float` - Angle spread in degrees
- `flash_color: Color` - Flash overlay color
- `shake_intensity: float` - Camera shake amount
- `duration: float` - Total effect duration

**Timing Guidelines:**
- Total duration: 0.2-0.4s
- Flash peak: 0.05s
- Shake duration: 0.3-0.5s

---

### AOE Template

**Scene Structure:**
```
Area2D (Root) - [AOEName]
├── ColorRect or Sprite2D - "CircleVisual"
├── GPUParticles2D - "GroundParticles"
├── CollisionShape2D - "HitArea"
├── PointLight2D - "Glow" (optional)
└── AudioStreamPlayer2D - "LoopSound" (optional)
```

**Key Parameters:**
- `start_radius: float` - Initial size
- `end_radius: float` - Final expanded size
- `expand_duration: float` - Time to expand
- `damage_per_tick: int` - Damage dealt
- `tick_interval: float` - Time between damage ticks
- `total_duration: float` - How long effect lasts

**Timing Guidelines:**
- Expand duration: 0.3-0.5s
- Pulse cycle: 0.8-1.5s

---

### STATUS Template

**Scene Structure:**
```
Node2D (Root) - [StatusName]
├── GPUParticles2D - "Particles"
├── Sprite2D or ColorRect - "GroundGlow"
├── AnimationPlayer - "PulseAnimation"
└── Timer - "DamageTick"
```

**Key Parameters:**
- `particle_direction: Vector2` - Up for fire/holy, down for poison
- `particle_color: Color` - Element color
- `glow_color: Color` - Ground effect color
- `pulse_speed: float` - Animation speed
- `damage_per_tick: int` - Damage dealt
- `tick_interval: float` - Time between ticks

**Timing Guidelines:**
- Pulse cycle: 0.8-1.5s
- Particle count: 8-15

---

### MELEE Template

**Scene Structure:**
```
Node2D (Root) - [MeleeName]
├── Line2D - "SlashArc"
├── GPUParticles2D - "Sparks"
└── AudioStreamPlayer2D - "SlashSound" (optional)
```

**Key Parameters:**
- `arc_radius: float` - Size of slash arc
- `arc_angle: float` - Sweep angle in radians
- `line_color: Color` - Arc color (usually white)
- `line_width: float` - Arc thickness
- `spark_color: Color` - Impact spark color
- `duration: float` - Total animation time

**Timing Guidelines:**
- Total duration: 0.15-0.25s
- Particle count: 5-15

---

### UI_NUMBER Template

**Scene Structure:**
```
Label (Root) - [NumberType]
└── [Script handles animation]
```

**Key Parameters:**
- `float_speed: float` - Upward movement speed
- `duration: float` - Total visibility time
- `spread: float` - Random horizontal offset
- `scale_start: float` - Initial scale
- `scale_peak: float` - Maximum scale during pop

**Timing Guidelines:**
- Float duration: 0.8-1.2s
- Scale pop: 0.2s

---

## Best Practices

### Timing is Everything

```
Hit effect timing:
- Frame 0: Contact
- Frame 1-2: Freeze (0.05s)
- Frame 3-5: Flash white
- Frame 6+: Particle burst

Perfect timing = satisfying hit
Perfect art = doesn't matter if timing is bad
```

### Screen Shake Intensity

| Effect Type | Shake Amount | Duration |
|-------------|--------------|----------|
| Small hit | 2-4 pixels | 0.3s |
| Medium hit | 5-8 pixels | 0.4s |
| Large hit | 10-15 pixels | 0.4s |
| Explosion | 15-25 pixels | 0.5s |

### Particle Counts (Performance)

| Effect Type | Particle Count |
|-------------|---------------|
| Projectile trail | 10-20 |
| Impact burst | 20-40 |
| AOE ground | 15-30 |
| Status loop | 8-15 |
| Melee sparks | 5-15 |

### Auto-Cleanup

**ALWAYS include cleanup code:**
```gdscript
# For one-shot effects
await get_tree().create_timer(duration).timeout
queue_free()

# OR connect to animation finished
animation_player.animation_finished.connect(_on_animation_finished)
func _on_animation_finished(_anim_name):
    queue_free()
```

---

## Anti-Patterns (Don't Do This)

- **Don't** make effects too long (>2s for non-looping)
- **Don't** use >50 particles for single effect
- **Don't** forget auto-destroy (memory leak!)
- **Don't** skip camera shake on big hits
- **Don't** use inconsistent colors (fire shouldn't be blue)
- **Don't** make projectiles too fast (>800 px/s = can't see)
- **Don't** make projectiles too slow (<200 px/s = boring)

---

## Testing Checklist

Before considering effect "done":
- [ ] Plays correctly when spawned
- [ ] Auto-destroys when finished
- [ ] Looks good at 60 FPS
- [ ] Camera shake feels right (if applicable)
- [ ] Collision works (if projectile/AOE)
- [ ] Color matches element type
- [ ] Timing feels snappy (not sluggish)
- [ ] Works on different backgrounds

---

## Common Effect Requests

### "Create a fireball projectile"
→ Use PROJECTILE template
→ Orange ColorRect (16x16)
→ Orange-red particle trail
→ Orange glow
→ Speed 500 px/s
→ Spawns explosion_fire on impact

### "Create ice explosion"
→ Use IMPACT template
→ Blue-white particle burst
→ Cyan flash ColorRect
→ White-blue glow burst
→ 30 particles, 0.3s duration
→ Medium camera shake

### "Create burning status"
→ Use STATUS template
→ Orange-red particles (upward)
→ Red pulsing ground glow
→ 2 damage per second
→ Follows character

### "Create damage numbers"
→ Use UI_NUMBER template
→ Red label, black outline
→ Floats up 50px in 1s
→ Scale 1.0 → 1.2 → 0.8
→ Fade to 0

### "Create sword slash"
→ Use MELEE template
→ White arc Line2D
→ Yellow-white sparks
→ 0.2s total duration
→ 45 degree arc sweep

---

## Example Invocations

User: "Create a fireball effect"
User: "Generate VFX for ice magic"
User: "Make a healing circle AOE"
User: "Create damage numbers that float up"
User: "Generate a poison status effect"
User: "Make a sword slash visual effect"
User: "Create an explosion without sprites"

---

## Workflow Summary

1. **User requests VFX** for specific effect
2. **Skill identifies template** (projectile, impact, AOE, status, melee, UI)
3. **Skill determines element** (fire, ice, poison, lightning, holy, dark)
4. **Skill generates complete files** (.tscn scene + .gd script)
5. **Skill provides usage example** and customization options
6. **User saves files** to vfx/ directory
7. **User tests in Godot** (F6 to run scene)
8. **Skill offers variants** (color, size, behavior)

This skill transforms effect requests into complete, working Godot scenes using only procedural techniques - no custom art required!
