---
name: pixellab-animate-character
description: Add animations to existing PixelLab characters. Lists available characters, shows animation templates organized by category (movement, combat, utility), and supports custom action descriptions. Use this when the user wants to animate a character sprite.
domain: art
type: generator
version: 1.0.0
allowed-tools:
  - mcp__pixellab__animate_character
  - mcp__pixellab__list_characters
  - mcp__pixellab__get_character
  - AskUserQuestion
---

# PixelLab Character Animator Skill

This skill adds animations to existing PixelLab characters through an **interactive selection process**, offering categorized animation templates and custom action support.

---

## When to Use This Skill

Invoke this skill when the user:
- Asks to "animate a character" or "add animations"
- Says "I need walk/run/attack animations"
- Wants to add movement or combat animations to sprites
- Says "make the character move/fight/idle"
- Needs to complete a character with animation sets

---

## Available Animation Templates

### Movement Animations

| Template ID | Description | Best For |
|-------------|-------------|----------|
| `breathing-idle` | Subtle breathing idle | All characters - essential |
| `walk` | Standard walk cycle | All characters - essential |
| `walking-4-frames` | Simple 4-frame walk | Smaller sprites, NPCs |
| `walking-6-frames` | Medium 6-frame walk | Standard units |
| `walking-8-frames` | Smooth 8-frame walk | Player, companions |
| `running-4-frames` | Quick 4-frame run | Chase sequences |
| `running-6-frames` | Medium run cycle | Standard combat |
| `running-8-frames` | Smooth run cycle | Player character |
| `sad-walk` | Dejected walking | Defeated/sad NPCs |
| `scary-walk` | Menacing walk | Enemies, undead |
| `crouched-walking` | Stealthy crouch walk | Rogues, scouts |

### Combat - Basic Attacks

| Template ID | Description | Best For |
|-------------|-------------|----------|
| `fight-stance-idle-8-frames` | Combat ready stance | All combat units |
| `cross-punch` | Punching attack | Unarmed, brawlers |
| `lead-jab` | Quick jab | Fast attackers |
| `surprise-uppercut` | Uppercut attack | Heavy hitters |
| `high-kick` | High kick attack | Martial artists |
| `roundhouse-kick` | Spinning kick | Martial artists |
| `leg-sweep` | Sweeping leg attack | Knockdown moves |
| `hurricane-kick` | Spinning multi-kick | Special attacks |

### Combat - Advanced

| Template ID | Description | Best For |
|-------------|-------------|----------|
| `fireball` | Casting fireball | Mages, spellcasters |
| `flying-kick` | Leaping kick | Agile fighters |
| `taking-punch` | Getting hit reaction | All combat units |
| `falling-back-death` | Death fall backward | All units - essential |
| `getting-up` | Rising from ground | After knockdown |

### Movement - Special

| Template ID | Description | Best For |
|-------------|-------------|----------|
| `jumping-1` | Simple jump | Basic platforming |
| `jumping-2` | Alternative jump | Variety |
| `two-footed-jump` | Standing jump | Combat jumps |
| `running-jump` | Running leap | Athletic moves |
| `running-slide` | Sliding dodge | Rogues, agile units |
| `backflip` | Backflip dodge | Acrobatic units |
| `front-flip` | Forward flip | Acrobatic attacks |
| `crouching` | Crouch/duck | Taking cover |
| `falling-back-death` | Falling backward | Death animation |

### Utility Actions

| Template ID | Description | Best For |
|-------------|-------------|----------|
| `drinking` | Drinking potion | Healing animation |
| `picking-up` | Picking up item | Looting, collecting |
| `throw-object` | Throwing motion | Grenades, items |
| `pushing` | Pushing object | Environmental |
| `pull-heavy-object` | Pulling heavy item | Environmental |

---

## Animation Sets by Character Role

### Essential Set (All Characters)
```
1. breathing-idle - Rest state
2. walking-8-frames - Movement
3. falling-back-death - Death
```

### Combat Unit Set (Soldiers, Enemies)
```
Essential Set +
4. fight-stance-idle-8-frames - Combat idle
5. running-6-frames - Chase/retreat
6. taking-punch - Hit reaction
7. [Attack animation based on weapon]
```

### Player/Companion Set (Full)
```
Combat Unit Set +
8. drinking - Potion use
9. picking-up - Looting
10. getting-up - Recovery
```

### Weapon-Specific Attack Recommendations

| Weapon Type | Recommended Animations |
|-------------|----------------------|
| Sword/Melee | `cross-punch`, `lead-jab` (slash motions) |
| Two-handed | `surprise-uppercut` (overhead swing) |
| Unarmed | `cross-punch`, `high-kick`, `roundhouse-kick` |
| Staff/Polearm | `leg-sweep` (wide swing) |
| Magic/Casting | `fireball`, `throw-object` |
| Bow/Ranged | `throw-object` (drawing motion) |
| Shield | `pushing` (shield bash) |

---

## Interactive Workflow

### Phase 1: Select Character

**Start by listing available characters:**

```
I'll help you add animations to a character! First, let me show your available characters:

[Call mcp__pixellab__list_characters]

Which character would you like to animate?
- Select by name or ID
- Or describe which one (e.g., "the knight", "the mage I just created")
```

**Wait for user response.**

---

### Phase 2: Check Current Animations

**After character selection:**

```
[Call mcp__pixellab__get_character with character_id]

**Character: [Name]**
- Size: [X]px
- Directions: [4/8]
- Current Animations: [List any existing]

What animations does this character need?
```

---

### Phase 3: Select Animation Type

**Present categorized options:**

```
What type of animation would you like to add?

**Movement:**
- [ ] Idle (breathing-idle) - Essential resting animation
- [ ] Walk (walking-8-frames) - Standard movement
- [ ] Run (running-6-frames) - Fast movement
- [ ] Special movement (crouch, jump, slide)

**Combat:**
- [ ] Combat idle (fight-stance-idle-8-frames)
- [ ] Attack animation (various styles)
- [ ] Hit reaction (taking-punch)
- [ ] Death (falling-back-death)

**Utility:**
- [ ] Drinking (potion use)
- [ ] Picking up (looting)
- [ ] Throwing (grenades, items)

**Quick Sets:**
- [ ] Essential Set (idle, walk, death)
- [ ] Combat Set (essential + combat idle, attack, hit reaction)
- [ ] Full Set (all standard animations)

**Custom:**
- [ ] Custom action (describe your own)
```

**Wait for user response.**

---

### Phase 4: Custom Action Description (If Selected)

**If user wants custom action:**

```
Describe the action you want the character to perform.

**Tips for good action descriptions:**
- Focus on the MOVEMENT, not the result
- Keep it simple and clear
- Describe the pose/motion

**Good examples:**
- "walking stealthily with weapon drawn"
- "casting spell with hands raised"
- "swinging sword in horizontal slash"
- "blocking with shield raised"
- "kneeling in prayer"

**Avoid:**
- Environmental details ("walking through forest")
- Complex sequences ("attack then dodge then attack")
- Emotions without movement ("feeling angry")

Your action description:
```

---

### Phase 5: Confirm and Generate

**Present summary before generating:**

```
**Animation Summary:**
- Character: [Name] ([ID])
- Animation: [Template or Custom]
- Action Description: [If custom]
- Directions: [Will match character's directions]

**Estimated Time:** 2-4 minutes per animation

Ready to generate? [Yes / Modify / Add More]
```

---

### Phase 6: Execute Generation

**Call the PixelLab API:**

```gdscript
# Use mcp__pixellab__animate_character with:
{
  "character_id": "[character UUID]",
  "template_animation_id": "[template ID]",
  "animation_name": "[optional custom name]",
  "action_description": "[optional - for custom actions]"
}
```

**After submission:**

```
Animation queued!

**Job Details:**
- Character: [Name]
- Animation: [Type]
- Status: Processing
- Estimated Time: 2-4 minutes

The animation will automatically generate for all [4/8] directions.

**Next Steps:**
1. Queue more animations while this processes
2. Check status with get_character
3. Download when complete
```

---

## Batch Animation Workflow

**For adding multiple animations efficiently:**

```
Would you like to add a standard animation set?

**Essential Set (3 animations):**
1. breathing-idle
2. walking-8-frames
3. falling-back-death

**Combat Set (6 animations):**
Essential Set +
4. fight-stance-idle-8-frames
5. cross-punch (or weapon-appropriate attack)
6. taking-punch

**Full Set (10 animations):**
Combat Set +
7. running-6-frames
8. drinking
9. picking-up
10. getting-up

Select a set and I'll queue all animations at once.
```

**Queue multiple animations in sequence:**
```
Queuing Essential Set for [Character Name]:

1/3 - breathing-idle... ✓ Queued
2/3 - walking-8-frames... ✓ Queued
3/3 - falling-back-death... ✓ Queued

All animations queued! Total processing time: ~6-12 minutes

I'll check on them periodically, or ask me "check animations for [character]"
```

---

## Custom Action Guidelines

### Writing Effective Action Descriptions

**DO:**
- Focus on body movement and pose
- Describe the motion arc
- Keep under 50 words
- Match the character's role

**DON'T:**
- Include environmental context
- Describe emotions without motion
- Request multiple sequential actions
- Use overly complex descriptions

### Examples by Character Type

**Fighter/Knight:**
```
"swinging sword in wide horizontal arc"
"raising shield in defensive block"
"thrusting spear forward"
"heavy overhead axe chop"
```

**Rogue/Assassin:**
```
"quick dagger stab"
"throwing knife with side-arm motion"
"rolling dodge to the side"
"sneaking with low crouch"
```

**Mage/Cleric:**
```
"raising staff with magical energy gathering"
"hands together in prayer pose"
"throwing magical projectile"
"reading from spell book"
```

**Archer/Ranger:**
```
"drawing bow and releasing arrow"
"notching arrow while moving"
"kneeling to aim"
"rolling while drawing bow"
```

---

## Animation Naming Conventions

**Recommended naming for Godot import:**

```
[character]_[action]_[direction]

Examples:
- ironmark_fighter_idle_s
- ironmark_fighter_walk_sw
- ironmark_fighter_attack_e
- ironmark_fighter_death_n
```

**Animation names in PixelLab:**
- Use descriptive names: "Combat Idle", "Sword Slash", "Hit Reaction"
- These help identify animations in the character list
- Names can include the action type for clarity

---

## Post-Animation Workflow

**After animations complete:**

1. **Check Status:**
   ```
   mcp__pixellab__get_character(character_id, include_preview=true)
   ```

2. **Review Animations:**
   - Verify all directions animated correctly
   - Check timing feels right
   - Confirm style matches base character

3. **Download Assets:**
   - Individual frame PNGs
   - Sprite sheets per animation
   - Combined character ZIP

4. **Import to Godot:**
   ```
   assets/sprites/characters/[faction]/[character]/
   ├── idle/
   │   ├── idle_s.png
   │   ├── idle_sw.png
   │   └── ...
   ├── walk/
   ├── attack/
   └── death/
   ```

5. **Setup AnimationPlayer:**
   - Create animation tracks for each action
   - Set appropriate frame rates (8-12 FPS typical)
   - Configure looping (idle/walk loop, attack/death don't)

---

## Quick Animation (Skip Interactive)

**If user specifies animation directly:**

```
User: "Add a walk animation to the Ironmark fighter"

Skip to Phase 6 with:
- character_id: [find by name match]
- template_animation_id: "walking-8-frames"
- animation_name: "Walk Cycle"
```

```
User: "Give the knight a sword slash attack"

Skip to Phase 6 with:
- character_id: [find by name match]
- template_animation_id: "cross-punch"
- action_description: "swinging sword in horizontal slash"
- animation_name: "Sword Slash"
```

---

## Error Handling

**If animation fails:**
1. Verify character exists and is complete
2. Check template_animation_id is valid
3. Simplify custom action description
4. Ensure character has directional views generated

**If style doesn't match:**
1. Animation inherits character's style settings
2. If mismatch, may need to regenerate character
3. Try different template that better fits character type

---

## Example Invocations

User: "Add animations to my knight character"
User: "I need walk and attack animations for the new enemy"
User: "Animate the Ironmark fighter with combat moves"
User: "Give all my characters idle animations"
User: "Add a custom spell casting animation to the mage"

---

## Reference: Animation Processing Times

| Animation Type | Approximate Time |
|---------------|------------------|
| Simple (idle, death) | 2-3 minutes |
| Movement (walk, run) | 2-4 minutes |
| Combat (attacks) | 3-4 minutes |
| Complex (multi-frame) | 3-5 minutes |
| Full Set (10 anims) | 20-40 minutes |

*Times are per animation, processing is sequential per character.*
