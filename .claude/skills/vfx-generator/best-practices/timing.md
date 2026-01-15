# VFX Timing Best Practices

**The secret to impactful VFX is timing, not art quality.**

## The Golden Rule

```
Perfect timing + simple shapes = FEELS impactful
Perfect art + bad timing = FEELS weak
```

## Frame-Perfect Hit Effects

### Ideal Hit Sequence (60 FPS)

```
Frame 0 (0.00s): Contact point
Frame 1-2 (0.03s): Freeze frame (optional but powerful)
Frame 3-4 (0.07s): White flash peak
Frame 5-8 (0.13s): Particle burst begins
Frame 9-15 (0.25s): Particles spread, flash fades
Frame 16+ (0.27s+): Cleanup, particles settle
```

### Implementation

```gdscript
func play_hit_effect() -> void:
	# Frame 0: Contact - spawn effect
	var impact = impact_scene.instantiate()
	add_child(impact)
	impact.position = hit_position

	# Frame 1-2: Freeze (hitstop)
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.03).timeout
	Engine.time_scale = 1.0

	# Frame 3-8: Effect plays automatically via tween
```

## Duration Guidelines by Effect Type

| Effect Type | Ideal Duration | Min | Max |
|-------------|---------------|-----|-----|
| Hit spark | 0.15-0.2s | 0.1s | 0.3s |
| Explosion | 0.3-0.5s | 0.2s | 0.6s |
| Projectile flight | 0.5-1.5s | 0.3s | 2.0s |
| AOE expand | 0.3-0.5s | 0.2s | 0.8s |
| AOE total | 2-5s | 1s | 10s |
| Status pulse | 0.8-1.2s | 0.5s | 2.0s |
| Melee slash | 0.15-0.25s | 0.1s | 0.35s |
| UI number float | 0.8-1.2s | 0.6s | 1.5s |
| Screen flash | 0.05-0.15s | 0.03s | 0.2s |
| Camera shake | 0.3-0.5s | 0.2s | 0.8s |

## Speed Guidelines

### Projectile Speed (pixels/second)

| Feel | Speed | Example |
|------|-------|---------|
| Slow/heavy | 200-300 | Poison glob, boulder |
| Normal | 400-500 | Fireball, arrow |
| Fast | 600-800 | Lightning, bullet |
| Instant | 1000+ | Laser beam |

**Rule:** If player can't track it, it's too fast. If it feels sluggish, it's too slow.

### Float/Rise Speed (UI numbers, particles)

| Element | Speed |
|---------|-------|
| Damage numbers | 40-60 px/s |
| Heal numbers | 35-50 px/s |
| Fire particles (up) | 30-50 px/s |
| Poison particles (down) | 15-25 px/s |
| Sparkles | 20-40 px/s |

## Hitstop (Freeze Frames)

Hitstop creates weight and impact. Use sparingly.

| Hit Type | Hitstop Duration |
|----------|-----------------|
| Light hit | 0.02-0.03s (1-2 frames) |
| Medium hit | 0.04-0.05s (2-3 frames) |
| Heavy hit | 0.06-0.08s (4-5 frames) |
| Critical | 0.08-0.12s (5-7 frames) |
| Boss attack | 0.1-0.15s (6-9 frames) |

### Implementation

```gdscript
func apply_hitstop(duration: float) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(duration).timeout
	Engine.time_scale = 1.0

# Or with slow-mo instead of full stop:
func apply_slowmo(duration: float, time_scale: float = 0.1) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0
```

## Animation Curves

### Scale Pop (UI Numbers, Impacts)

```
Time:  0.0 ─── 0.1 ─── 0.3 ─── 1.0
Scale: 1.0 ─── 1.3 ─── 1.1 ─── 0.8

Ease: EASE_OUT for grow, EASE_IN for shrink
```

```gdscript
var tween = create_tween()
tween.tween_property(node, "scale", Vector2(1.3, 1.3), 0.1).set_ease(Tween.EASE_OUT)
tween.tween_property(node, "scale", Vector2(0.8, 0.8), 0.9).set_ease(Tween.EASE_IN)
```

### Fade Timing

```
Instant appear, slow fade:
- Appear: 0.0s (instant)
- Hold: 0.0-0.5s (full opacity)
- Fade: 0.5-1.0s (to transparent)

Soft appear, soft fade:
- Appear: 0.0-0.2s (fade in)
- Hold: 0.2-0.6s (full opacity)
- Fade: 0.6-1.0s (fade out)
```

### Expansion (AOE, Explosions)

```
For impactful expansion:
- Use EASE_OUT + TRANS_BACK for "overshoot" effect
- Expand quickly (0.2-0.4s)
- Hold at full size
- Fade out slowly (0.3-0.5s)
```

```gdscript
var tween = create_tween()
tween.tween_property(circle, "scale", Vector2(1.0, 1.0), 0.3)
tween.set_ease(Tween.EASE_OUT)
tween.set_trans(Tween.TRANS_BACK)  # Overshoot then settle
```

## Layering Multiple Effects

When combining effects, stagger slightly:

```
0.00s: Screen flash begins
0.02s: Particles spawn
0.03s: Camera shake starts
0.05s: Sound plays
0.10s: Flash fades
0.30s: Shake ends
0.50s: Particles settle
```

```gdscript
func play_big_impact() -> void:
	# Layer 1: Flash (immediate)
	flash.modulate.a = 1.0

	# Layer 2: Particles (slight delay)
	await get_tree().create_timer(0.02).timeout
	particles.emitting = true

	# Layer 3: Shake (with particles)
	await get_tree().create_timer(0.01).timeout
	shake_camera(15.0)

	# Layer 4: Sound (with everything)
	await get_tree().create_timer(0.02).timeout
	sound.play()
```

## Common Timing Mistakes

### Too Long
❌ Explosions lasting 2+ seconds
❌ Screen shake lasting 1+ seconds
❌ Projectiles taking 3+ seconds to reach target
✅ Keep effects snappy - players want to keep playing

### Too Short
❌ Impacts that last 0.05s (blink and miss)
❌ Status effects with no visual presence
✅ Give players time to register what happened

### No Variation
❌ Every hit feels the same
✅ Vary timing by damage amount, crit status, element

### Wrong Easing
❌ Linear everything (feels robotic)
✅ EASE_OUT for impacts, EASE_IN for fades
