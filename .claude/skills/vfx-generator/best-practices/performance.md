# VFX Performance Best Practices

## The Golden Rules

1. **Always `queue_free()` when done** - Memory leaks kill performance
2. **Limit particle counts** - Under 50 per effect, under 200 total on screen
3. **Use GPUParticles2D** - Not CPUParticles2D for most cases
4. **Pool frequently spawned effects** - Damage numbers, hit sparks

## Memory Management

### Always Auto-Destroy

Every effect MUST clean itself up:

```gdscript
# Method 1: Timer
func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	queue_free()

# Method 2: After tween
func _play_effect() -> void:
	var tween = create_tween()
	# ... animations ...
	await tween.finished
	queue_free()

# Method 3: After particles finish
func _ready() -> void:
	particles.emitting = true
	await particles.finished  # For one_shot particles
	queue_free()

# Method 4: After animation
func _ready() -> void:
	animation_player.animation_finished.connect(_on_finished)

func _on_finished(_anim_name: String) -> void:
	queue_free()
```

### Common Memory Leak Sources

❌ **Bad:** Creating effects without cleanup
```gdscript
func spawn_effect():
	var effect = effect_scene.instantiate()
	add_child(effect)
	# Effect never gets freed!
```

✅ **Good:** Effect cleans itself up
```gdscript
# In effect script:
func _ready():
	await get_tree().create_timer(1.0).timeout
	queue_free()
```

## Particle Count Guidelines

### Per-Effect Limits

| Effect Type | Max Particles |
|-------------|--------------|
| Trail | 20 |
| Burst/Impact | 40 |
| AOE | 30 |
| Status | 15 |
| Ambient | 20 |

### Total On-Screen

- **Target:** Under 200 total particles
- **Warning:** 300-500 particles
- **Danger:** 500+ particles (frame drops)

### Monitoring Particle Count

```gdscript
# Debug: Count all particles in scene
func count_particles() -> int:
	var count = 0
	for node in get_tree().get_nodes_in_group("particles"):
		if node is GPUParticles2D:
			count += node.amount
	return count
```

## Object Pooling

For effects that spawn frequently (damage numbers, hit sparks), use pooling:

### Simple Pool Implementation

```gdscript
# effect_pool.gd - Autoload
extends Node

var _pools: Dictionary = {}
const POOL_SIZE: int = 20

func get_effect(scene_path: String) -> Node:
	# Initialize pool if needed
	if not _pools.has(scene_path):
		_pools[scene_path] = []
		_preload_pool(scene_path)

	# Find inactive effect in pool
	for effect in _pools[scene_path]:
		if not effect.is_inside_tree():
			return effect

	# Pool exhausted - create new (with warning)
	print_debug("Pool exhausted for: ", scene_path)
	var effect = load(scene_path).instantiate()
	_pools[scene_path].append(effect)
	return effect

func _preload_pool(scene_path: String) -> void:
	var scene = load(scene_path)
	for i in range(POOL_SIZE):
		var effect = scene.instantiate()
		_pools[scene_path].append(effect)

func return_effect(effect: Node) -> void:
	# Just remove from tree, don't queue_free
	if effect.is_inside_tree():
		effect.get_parent().remove_child(effect)
	# Reset effect state
	if effect.has_method("reset"):
		effect.reset()
```

### Using the Pool

```gdscript
# Instead of:
var dmg_num = damage_number_scene.instantiate()
add_child(dmg_num)

# Use:
var dmg_num = EffectPool.get_effect("res://vfx/ui/damage_number.tscn")
add_child(dmg_num)
dmg_num.set_number(50)

# In damage_number.gd, instead of queue_free():
func _on_animation_finished() -> void:
	EffectPool.return_effect(self)

func reset() -> void:
	modulate.a = 1.0
	scale = Vector2.ONE
	position = Vector2.ZERO
```

### When to Pool

| Effect | Pool? | Reason |
|--------|-------|--------|
| Damage numbers | ✅ Yes | Very frequent |
| Hit sparks | ✅ Yes | Every attack |
| Projectiles | ⚠️ Maybe | If many at once |
| Explosions | ❌ No | Infrequent |
| Status effects | ❌ No | Few at a time |
| AOE circles | ❌ No | Infrequent |

## GPU vs CPU Particles

### Use GPUParticles2D (Default)
- Most effects
- When you need many particles
- When particles don't need physics interaction

### Use CPUParticles2D When
- Particles need to collide with world
- You need exact control over each particle
- WebGL1 compatibility required (rare)

```gdscript
# GPUParticles2D is faster but runs on GPU
# CPUParticles2D gives more control but is slower
```

## Light2D Optimization

Lights are expensive! Use sparingly.

### Guidelines

| Light Count | Performance |
|-------------|------------|
| 1-5 | Fine |
| 6-10 | Watch FPS |
| 10+ | Likely issues |

### Optimization Tips

```gdscript
# 1. Reduce energy when far from camera
func _process(delta):
	var dist_to_camera = global_position.distance_to(camera.global_position)
	light.energy = lerp(2.0, 0.0, dist_to_camera / 500.0)

# 2. Disable when off-screen
light.visible = is_on_screen()

# 3. Use lower texture_scale
light.texture_scale = 1.0  # Not 4.0

# 4. Reduce shadow quality or disable shadows
light.shadow_enabled = false  # Big performance save
```

## Shader Optimization

### Keep Shaders Simple

```glsl
// GOOD: Simple shader
shader_type canvas_item;
uniform float alpha = 1.0;

void fragment() {
	COLOR.a *= alpha;
}

// BAD: Complex per-pixel calculations
shader_type canvas_item;

void fragment() {
	float noise = 0.0;
	for (int i = 0; i < 10; i++) {  // Loop = bad
		noise += sin(UV.x * float(i) * TIME);  // TIME in loop = very bad
	}
	COLOR.rgb *= noise;
}
```

### Shader Tips

1. Avoid loops in fragment shader
2. Minimize texture samples
3. Pre-calculate values in vertex shader when possible
4. Use `hint_range` for uniforms to help compiler

## Draw Call Optimization

### Batch Similar Effects

```gdscript
# BAD: Many separate nodes
for i in range(50):
	var spark = spark_scene.instantiate()
	add_child(spark)

# GOOD: Single GPUParticles2D with amount=50
particles.amount = 50
particles.emitting = true
```

### Use CanvasGroup for Complex Effects

```gdscript
# Group multiple visual elements to render as one
var group = CanvasGroup.new()
group.add_child(flash)
group.add_child(particles)
group.add_child(glow)
add_child(group)
```

## Profiling VFX

### In Godot Editor

1. **Debugger → Monitors:** Watch FPS, draw calls
2. **Debugger → Profiler:** Find slow functions
3. **View → Visible Collision Shapes:** Check collision overhead

### Debug Output

```gdscript
# Add to a debug autoload
func _process(_delta):
	if Input.is_action_just_pressed("debug_vfx"):
		print("Active effects: ", get_tree().get_nodes_in_group("vfx").size())
		print("Active particles: ", count_particle_nodes())
		print("Active lights: ", count_light_nodes())

func count_particle_nodes() -> int:
	var count = 0
	for node in get_tree().current_scene.get_children():
		if node is GPUParticles2D:
			count += 1
	return count
```

## Performance Checklist

Before shipping an effect:

- [ ] Effect calls `queue_free()` when done
- [ ] Particle amount is under 50
- [ ] Lifetime is appropriate (not too long)
- [ ] `one_shot = true` for burst effects
- [ ] No unnecessary Light2D nodes
- [ ] Pooled if spawned frequently
- [ ] Tested with multiple effects at once
- [ ] No errors in Output panel

## Emergency Performance Fixes

If FPS drops during VFX-heavy moments:

```gdscript
# 1. Reduce particle counts globally
func reduce_vfx_quality():
	for particles in get_tree().get_nodes_in_group("particles"):
		particles.amount = int(particles.amount * 0.5)

# 2. Disable lights
func disable_vfx_lights():
	for light in get_tree().get_nodes_in_group("vfx_lights"):
		light.visible = false

# 3. Skip spawning non-essential effects
var vfx_quality: int = 2  # 0=low, 1=medium, 2=high

func spawn_hit_spark():
	if vfx_quality < 1:
		return  # Skip on low quality
	# ... spawn effect
```
