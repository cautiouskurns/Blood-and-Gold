# VFX Color Best Practices

**Consistent color language makes effects instantly readable.**

## Element Color Palettes

### Fire / Explosion
```
Primary:   #ff6b35 (bright orange)
Secondary: #ff4136 (red-orange)
Accent:    #ffdc00 (yellow)
Glow:      #ff8c42 (warm orange)
Dark:      #8b2500 (burnt orange)
```

**Usage:**
- Projectile body: Primary
- Trail particles: Secondary
- Flash/burst center: Accent
- Light2D glow: Glow
- Smoke: Dark with low alpha

### Ice / Frost
```
Primary:   #3b82f6 (bright blue)
Secondary: #06b6d4 (cyan)
Accent:    #e0f2fe (pale ice blue)
Glow:      #60a5fa (soft blue)
Dark:      #1e3a5f (deep blue)
```

**Usage:**
- Projectile/crystal: Primary or Accent
- Particles: Secondary
- Flash: Accent (near white)
- Glow: Glow
- Character tint (frozen): Primary at 30% alpha

### Poison / Nature
```
Primary:   #22c55e (green)
Secondary: #84cc16 (lime/yellow-green)
Accent:    #dcfce7 (pale green)
Glow:      #4ade80 (bright green)
Dark:      #14532d (forest green)
```

**Usage:**
- Projectile: Primary
- Dripping particles: Secondary
- Bubbles: Accent
- Ground glow: Glow at 50% alpha
- Toxic cloud: Dark with 60% alpha

### Lightning / Energy
```
Primary:   #f0f9ff (white-blue)
Secondary: #38bdf8 (electric blue)
Accent:    #fef08a (yellow spark)
Glow:      #7dd3fc (bright cyan)
Core:      #ffffff (pure white)
```

**Usage:**
- Bolt core: Core or Primary
- Bolt edge: Secondary
- Sparks: Accent
- Glow: Glow
- Flash: Primary (blindingly bright)

### Holy / Healing
```
Primary:   #fbbf24 (gold)
Secondary: #fef3c7 (pale gold)
Accent:    #ffffff (pure white)
Glow:      #fcd34d (warm gold)
Soft:      #fef9c3 (cream)
```

**Usage:**
- Main effect: Primary
- Particles rising: Secondary or Accent
- Flash/burst: Accent
- Aura glow: Glow
- Healing circle: Primary center, Soft edge

### Dark / Shadow
```
Primary:   #7c3aed (purple)
Secondary: #a78bfa (light purple)
Accent:    #1e1b4b (near black)
Glow:      #8b5cf6 (violet)
Void:      #000000 (pure black)
```

**Usage:**
- Main effect: Primary
- Edge highlights: Secondary
- Core/center: Accent or Void
- Glow (inverted feel): Glow
- Shadow particles: Void at 70% alpha

### Physical / Neutral
```
Primary:   #d4d4d4 (light gray)
Secondary: #a3a3a3 (medium gray)
Accent:    #ffffff (white)
Glow:      #e5e5e5 (soft white)
Steel:     #71717a (steel gray)
```

**Usage:**
- Slash trails: Accent (white)
- Sparks: Primary fading to Accent
- Impact dust: Secondary
- Metal clang flash: Accent

## Color by Damage Type

Quick reference for "what color should this be?"

| Damage Type | Primary Color | Hex |
|-------------|--------------|-----|
| Physical | White/Gray | `#ffffff` / `#d4d4d4` |
| Fire | Orange | `#ff6b35` |
| Ice/Cold | Blue | `#3b82f6` |
| Lightning | Cyan/White | `#38bdf8` |
| Poison | Green | `#22c55e` |
| Acid | Yellow-Green | `#84cc16` |
| Holy/Radiant | Gold | `#fbbf24` |
| Dark/Necrotic | Purple | `#7c3aed` |
| Psychic | Pink/Magenta | `#ec4899` |
| Force | Blue-White | `#60a5fa` |

## UI Number Colors

| Number Type | Color | Hex |
|-------------|-------|-----|
| Damage (normal) | Red | `#dc2626` |
| Damage (critical) | Yellow/Gold | `#fbbf24` |
| Healing | Green | `#22c55e` |
| Shield/Block | Blue | `#3b82f6` |
| Miss/Dodge | Gray | `#9ca3af` |
| Mana cost | Blue | `#3b82f6` |
| Gold gain | Gold | `#fbbf24` |
| XP gain | Purple | `#a855f7` |

## Color Relationships

### Complementary (High Contrast)
Use for opposing effects or to make something "pop":
- Fire (orange) vs Ice (blue)
- Poison (green) vs Holy (gold)
- Light (white) vs Dark (purple/black)

### Analogous (Harmonious)
Use for related effects or smooth transitions:
- Fire → Lightning (orange → yellow → white)
- Ice → Lightning (blue → cyan → white)
- Poison → Nature (green → lime → yellow)

### Gradient Usage

**Particle color over lifetime:**
```
Fire: Yellow (#ffdc00) → Orange (#ff6b35) → Red (#ff4136) → Transparent
Ice: White (#ffffff) → Cyan (#06b6d4) → Blue (#3b82f6) → Transparent
Poison: Lime (#84cc16) → Green (#22c55e) → Dark (#14532d) → Transparent
```

## Alpha (Transparency) Guidelines

| Effect Type | Alpha Range |
|-------------|-------------|
| Solid projectile | 100% |
| Particle trail | 60-100% → 0% |
| AOE circle | 40-70% |
| Ground glow | 30-50% |
| Status aura | 50-70% |
| Screen flash | 30-60% peak |
| Ghost/fade | 20-40% |

## Light2D Color Tips

- **Energy:** 1.0-2.0 for subtle, 2.0-3.0 for bright, 3.0+ for blinding
- **Color:** Usually match effect color, slightly brighter
- **Scale:** Match effect size roughly

```gdscript
# Good light setup for fireball
light.color = Color("#ff8c42")  # Warm orange
light.energy = 1.5
light.texture_scale = 1.5  # Slightly larger than projectile
```

## Readability Rules

1. **Ally vs Enemy:** Use distinct color families
   - Ally heals: Green/Gold
   - Enemy attacks: Red/Purple

2. **Danger Indicators:** Red/Orange always means "avoid this"

3. **Buffs vs Debuffs:**
   - Buffs: Gold, Green, Blue (positive colors)
   - Debuffs: Red, Purple, Gray (negative colors)

4. **Background Contrast:** Effects should be visible on both light and dark backgrounds
   - Add black outline to light effects
   - Add white/bright core to dark effects

## Common Mistakes

❌ Using pure red `#ff0000` (too saturated, harsh)
✅ Use softer reds like `#dc2626` or `#ef4444`

❌ Fire effects that are yellow (looks like lightning)
✅ Fire should lean orange-red, not yellow

❌ Healing that looks like poison (both green)
✅ Healing: warm green with gold. Poison: sickly lime-green

❌ All effects same brightness
✅ Vary intensity by power level

❌ Transparent effects with no outline/glow
✅ Add subtle glow or outline for visibility
