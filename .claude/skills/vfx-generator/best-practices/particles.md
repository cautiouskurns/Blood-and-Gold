# GPUParticles2D Best Practices

## Essential Properties

### Amount
Number of particles to emit.

| Effect Type | Recommended Amount |
|-------------|-------------------|
| Subtle trail | 8-15 |
| Normal trail | 15-25 |
| Impact burst | 20-40 |
| AOE ground | 15-30 |
| Status effect | 8-15 |
| Melee sparks | 5-15 |
| Heavy explosion | 40-60 |

**Rule:** Start low, increase until it looks right. More isn't always better.

### Lifetime
How long each particle lives (in seconds).

| Effect Type | Lifetime |
|-------------|----------|
| Quick spark | 0.1-0.3s |
| Trail | 0.3-0.6s |
| Burst | 0.3-0.5s |
| Floating | 0.8-1.5s |
| Smoke/fog | 1.0-2.0s |
| Ambient | 1.5-3.0s |

### One Shot
- `true`: Emits once then stops (impacts, bursts)
- `false`: Continuous emission (trails, status effects)

### Explosiveness
How particles are distributed over time (0.0-1.0).

| Value | Behavior | Use For |
|-------|----------|---------|
| 0.0 | Spread evenly over lifetime | Trails, continuous |
| 0.5 | Some bunching | Pulsing effects |
| 1.0 | All at once | Explosions, bursts |

### Local Coords
- `true`: Particles move with emitter
- `false`: Particles stay in world space

**Use `false` for:**
- Projectile trails (trail stays behind)
- Movement effects (footsteps, dust)

**Use `true` for:**
- Auras that follow character
- Status effects attached to entities

## ParticleProcessMaterial Settings

### Emission Shape

```gdscript
# Point (default) - all from center
emission_shape = EMISSION_SHAPE_POINT

# Sphere - random within sphere
emission_shape = EMISSION_SHAPE_SPHERE
emission_sphere_radius = 10.0

# Box - random within box
emission_shape = EMISSION_SHAPE_BOX
emission_box_extents = Vector3(10, 5, 0)

# Ring - circular emission (great for AOE)
emission_shape = EMISSION_SHAPE_RING
emission_ring_radius = 32.0
emission_ring_inner_radius = 28.0
emission_ring_height = 2.0
```

**Common uses:**
- Point: Simple projectiles, centered effects
- Sphere: Explosions, character auras
- Box: Ground dust, rectangular areas
- Ring: AOE circles, magic circles

### Direction & Spread

```gdscript
# Direction particles travel (normalized)
direction = Vector3(0, -1, 0)  # Up in 2D (Y is inverted)

# How much particles deviate from direction (degrees)
spread = 45.0  # 45 degree cone

# For omnidirectional burst:
direction = Vector3(0, 0, 0)
spread = 180.0  # Full sphere
```

### Gravity

```gdscript
# World gravity applied to particles
gravity = Vector3(0, 98, 0)   # Fall down (default)
gravity = Vector3(0, 0, 0)    # Float (magic)
gravity = Vector3(0, -50, 0)  # Rise up (fire, holy)
gravity = Vector3(0, 30, 0)   # Gentle fall (leaves, snow)
```

### Velocity

```gdscript
# Initial speed range
initial_velocity_min = 50.0
initial_velocity_max = 100.0

# For bursts, use higher values:
initial_velocity_min = 100.0
initial_velocity_max = 200.0
```

### Damping

```gdscript
# How quickly particles slow down (0 = never)
damping_min = 1.0
damping_max = 3.0

# High damping for quick stops:
damping_min = 5.0
damping_max = 10.0
```

### Scale

```gdscript
# Particle size range
scale_min = 0.5
scale_max = 1.0

# For variety:
scale_min = 0.3
scale_max = 1.2

# Scale over lifetime (requires scale curve)
# Particles shrink as they age
```

### Color

```gdscript
# Single color
color = Color(1.0, 0.5, 0.2, 1.0)  # Orange

# Gradient over lifetime (requires color ramp)
# Start bright, fade to transparent
```

## Common Particle Recipes

### Fire Trail
```gdscript
var mat = ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
mat.direction = Vector3(-1, 0, 0)  # Backward
mat.spread = 20.0
mat.gravity = Vector3(0, -30, 0)  # Rise
mat.initial_velocity_min = 50.0
mat.initial_velocity_max = 100.0
mat.damping_min = 1.0
mat.damping_max = 2.0
mat.scale_min = 0.4
mat.scale_max = 1.0
mat.color = Color("#ff6b35")

particles.amount = 15
particles.lifetime = 0.5
particles.local_coords = false
```

### Explosion Burst
```gdscript
var mat = ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
mat.emission_sphere_radius = 8.0
mat.direction = Vector3(0, 0, 0)
mat.spread = 180.0  # Omnidirectional
mat.gravity = Vector3(0, 150, 0)  # Fall
mat.initial_velocity_min = 120.0
mat.initial_velocity_max = 220.0
mat.damping_min = 2.0
mat.damping_max = 4.0
mat.scale_min = 0.5
mat.scale_max = 1.5
mat.color = Color("#ff6b35")

particles.amount = 35
particles.lifetime = 0.4
particles.one_shot = true
particles.explosiveness = 1.0
```

### Status Effect (Burning)
```gdscript
var mat = ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
mat.emission_sphere_radius = 10.0
mat.direction = Vector3(0, -1, 0)  # Up
mat.spread = 25.0
mat.gravity = Vector3(0, -40, 0)  # Rise
mat.initial_velocity_min = 25.0
mat.initial_velocity_max = 45.0
mat.damping_min = 0.5
mat.damping_max = 1.0
mat.scale_min = 0.3
mat.scale_max = 0.7
mat.color = Color("#ff6b35")

particles.amount = 12
particles.lifetime = 0.8
particles.local_coords = true  # Follow target
```

### Ring/Circle AOE
```gdscript
var mat = ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
mat.emission_ring_radius = 48.0
mat.emission_ring_inner_radius = 40.0
mat.emission_ring_height = 2.0
mat.direction = Vector3(0, -1, 0)  # Up
mat.spread = 30.0
mat.gravity = Vector3(0, -30, 0)  # Float up
mat.initial_velocity_min = 20.0
mat.initial_velocity_max = 40.0
mat.scale_min = 0.3
mat.scale_max = 0.8
mat.color = Color("#22c55e")  # Green

particles.amount = 20
particles.lifetime = 1.0
```

### Sparks (Melee Hit)
```gdscript
var mat = ParticleProcessMaterial.new()
mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
mat.direction = Vector3(1, -1, 0)  # Up-right
mat.spread = 45.0
mat.gravity = Vector3(0, 200, 0)  # Fall fast
mat.initial_velocity_min = 80.0
mat.initial_velocity_max = 150.0
mat.damping_min = 2.0
mat.damping_max = 4.0
mat.scale_min = 0.3
mat.scale_max = 0.8
mat.color = Color("#fef08a")  # Yellow-white

particles.amount = 10
particles.lifetime = 0.3
particles.one_shot = true
particles.explosiveness = 1.0
```

## Color Gradients

For particles that change color over lifetime:

```gdscript
# Create gradient
var gradient = Gradient.new()
gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
gradient.colors = PackedColorArray([
	Color("#ffdc00"),  # Start: yellow
	Color("#ff6b35"),  # Mid: orange
	Color("#ff4136", 0.0)  # End: red, transparent
])

# Create gradient texture
var gradient_tex = GradientTexture1D.new()
gradient_tex.gradient = gradient

# Apply to material
mat.color_ramp = gradient_tex
```

## Performance Tips

1. **Keep amounts low:** 50+ particles per effect adds up
2. **Use one_shot:** Prevents continuous emission when not needed
3. **Shorter lifetimes:** Fewer active particles at once
4. **Simple shapes:** Default circle particle is fine
5. **Avoid complex color ramps:** Simple 2-3 color gradients work

## Debugging Particles

**Particles not visible?**
1. Check `amount > 0`
2. Check `lifetime > 0`
3. Check `emitting = true`
4. Check `process_material` is set
5. Check particles aren't behind other nodes (z_index)
6. Check `modulate.a > 0`

**Particles going wrong direction?**
1. Remember Y is inverted in 2D
2. `direction = Vector3(0, -1, 0)` = UP
3. `direction = Vector3(0, 1, 0)` = DOWN

**Particles not trailing behind projectile?**
1. Set `local_coords = false`
2. Particles should stay in world space
