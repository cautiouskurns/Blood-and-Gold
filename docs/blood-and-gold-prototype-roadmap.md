# BLOOD & GOLD - Prototype Implementation Roadmap

**Based On:** Prototype GDD v0.1 - Core Loop Prototype
**Timeline:** 4 weeks (160 hours)
**Target:** Validate that commanding a mercenary company with NPC soldiers in tactical grid combat feels strategic and satisfying
**Created:** January 2026

---

## Quick Start

**Critical Path to Playable Core Loop:**
1. Combat grid visible with placeholder tiles (Task 1.1)
2. Unit sprites on grid, clickable (Task 1.2, 1.4)
3. Movement with visual feedback (Task 1.5)
4. Basic attack with damage numbers (Task 1.7)

**Estimated time to first playable:** 12 hours (end of Day 2)

**First Playtest Milestone:** One fighter vs 3 bandits, move and attack working

---

## Phase 1: Combat Visuals & Basic Interaction (Week 1, Days 1-3)

**Goal:** See the combat grid, see units, click to select, click to move

**Deliverables:**
- 12x12 combat grid visible on screen
- Unit sprites (placeholder) placed on grid
- Click-to-select with visual indicator
- Click-to-move with pathfinding visualization
- HP bars above units
- Turn order UI panel

**Test Criteria:** Can see a grid, click a unit, see it highlight, click a tile, watch it move there

---

### Task 1.1: Combat Grid Display

**Time:** 2 hours

**What:** 12x12 grid visible in center of screen using TileMapLayer with distinct walkable/obstacle tiles.

**How:**
- Create `scenes/combat/CombatGrid.tscn` with TileMapLayer node
- Create simple tileset with 2 tile types (walkable, obstacle)
- Place grid centered in 1920x1080 viewport
- Add visual distinction (color/shade) between walkable and blocked

**Acceptance:**
- [ ] Grid renders 12x12 tiles on screen
- [ ] Grid is visually centered
- [ ] Walkable vs obstacle tiles are visually distinct
- [ ] Grid fills approximately 60-70% of screen width

**Files:**
- `scenes/combat/CombatGrid.tscn` - Grid scene
- `scripts/combat/combat_grid.gd` - Grid logic
- `assets/sprites/tiles/` - Placeholder tile images

**Hardcoded Values:**
- Grid size: 12 x 12 tiles
- Tile size: 64 x 64 pixels
- Walkable color: #4a6741 (forest green)
- Obstacle color: #2d3436 (dark gray)

**Dependencies:** None

---

### Task 1.2: Unit Placeholder Sprites

**Time:** 1.5 hours

**What:** Colored rectangle sprites for party members and enemies visible on the grid.

**How:**
- Create `scenes/combat/Unit.tscn` base scene with Sprite2D
- Create placeholder sprites (colored squares with letter: P, T, L, M for party, E for enemy)
- Party = blue tones, Enemies = red tones
- Units snap to grid tile positions

**Acceptance:**
- [ ] Can instantiate unit on any grid tile
- [ ] Unit sprite centered on tile
- [ ] Party units visually distinct from enemy units
- [ ] Unit size fits within tile (slightly smaller than 64x64)

**Files:**
- `scenes/combat/Unit.tscn` - Base unit scene
- `scripts/combat/unit.gd` - Unit script
- `assets/sprites/units/placeholder_party.png`
- `assets/sprites/units/placeholder_enemy.png`

**Hardcoded Values:**
- Unit sprite size: 56 x 56 pixels
- Party color: #3498db (blue)
- Enemy color: #e74c3c (red)
- Companion colors: Thorne #2980b9, Lyra #9b59b6, Matthias #f39c12

**Dependencies:** Task 1.1 (grid must exist)

---

### Task 1.3: HP Bars Above Units

**Time:** 1 hour

**What:** Health bars floating above each unit showing current/max HP.

**How:**
- Add ProgressBar node as child of Unit.tscn
- Position above unit sprite (offset Y)
- Green fill for HP, red background
- Update bar when HP changes

**Acceptance:**
- [ ] HP bar visible above each unit
- [ ] Bar shows correct fill percentage
- [ ] Bar updates when damage taken (test with debug key)
- [ ] Bar color changes at low HP (<25% = red)

**Files:**
- Modify `scenes/combat/Unit.tscn` - Add HP bar
- Modify `scripts/combat/unit.gd` - HP tracking

**Hardcoded Values:**
- HP bar width: 48 pixels
- HP bar height: 6 pixels
- HP bar offset Y: -40 pixels (above sprite)
- Low HP threshold: 25%
- Healthy color: #27ae60 (green)
- Low HP color: #c0392b (red)

**Dependencies:** Task 1.2 (units must exist)

---

### Task 1.4: Click-to-Select Unit

**Time:** 1.5 hours

**What:** Clicking a unit selects it, showing a visible selection indicator.

**How:**
- Add Area2D with CollisionShape2D to Unit.tscn for click detection
- Create selection indicator (yellow outline or glow)
- Track `selected_unit` in CombatManager autoload
- Clicking empty space or enemy deselects

**Acceptance:**
- [ ] Clicking friendly unit shows selection indicator
- [ ] Only one unit selected at a time
- [ ] Clicking elsewhere deselects current unit
- [ ] Selection indicator is clearly visible

**Files:**
- Modify `scenes/combat/Unit.tscn` - Add click detection
- Create `scripts/autoload/combat_manager.gd` - Selection tracking
- `assets/sprites/ui/selection_indicator.png`

**Hardcoded Values:**
- Selection indicator: Yellow (#f1c40f) outline, 3px
- Click detection radius: 28 pixels (half unit size)

**Dependencies:** Task 1.2 (units must exist)

---

### Task 1.5: Click-to-Move with Path Preview

**Time:** 3 hours

**What:** With unit selected, clicking a walkable tile shows path preview, then unit moves along path.

**How:**
- Implement AStar2D pathfinding on grid
- Highlight valid move tiles when unit selected (based on movement range)
- Show path line from unit to hovered tile
- On click, tween unit position along path
- Deselect after move complete

**Acceptance:**
- [ ] Valid move tiles highlighted when unit selected
- [ ] Hovering tile shows path preview line
- [ ] Clicking valid tile moves unit along path
- [ ] Unit cannot move to invalid/occupied tiles
- [ ] Movement animation smooth (not instant teleport)

**Files:**
- Create `scripts/combat/pathfinding.gd` - AStar2D wrapper
- Modify `scripts/combat/combat_grid.gd` - Valid tile highlighting
- Modify `scripts/combat/unit.gd` - Movement execution

**Hardcoded Values:**
- Movement range (Fighter): 5 tiles
- Movement tween duration: 0.15 seconds per tile
- Valid tile highlight: #27ae60 with 40% opacity
- Path preview color: #3498db (blue line)

**Dependencies:** Task 1.4 (selection must work)

---

### Task 1.6: Turn Order UI Panel

**Time:** 1.5 hours

**What:** UI panel showing turn order with unit portraits/icons in sequence.

**How:**
- Create `scenes/UI/TurnOrderPanel.tscn` - horizontal bar at top
- Show unit icons in initiative order
- Highlight current unit's turn
- Update when units die or turn ends

**Acceptance:**
- [ ] Turn order panel visible at top of screen
- [ ] Shows all units in initiative order
- [ ] Current unit clearly highlighted
- [ ] Dead units removed from display

**Files:**
- `scenes/UI/TurnOrderPanel.tscn`
- `scripts/UI/turn_order_panel.gd`
- `assets/sprites/ui/turn_indicator.png`

**Hardcoded Values:**
- Panel position: Top center
- Icon size: 40 x 40 pixels
- Current turn highlight: Gold border (#f1c40f)
- Panel background: #1a1a2e with 80% opacity

**Dependencies:** Task 1.2 (units must exist)

---

### Task 1.7: Basic Melee Attack Action

**Time:** 2.5 hours

**What:** Selected unit can attack adjacent enemy, showing damage number popup.

**How:**
- Add "Attack" button to combat UI (or right-click enemy)
- Check if target is adjacent (1 tile)
- Roll attack vs defense (d20 + modifier vs defense value)
- Apply damage, show floating damage number
- Kill unit if HP <= 0

**Acceptance:**
- [ ] Can initiate attack on adjacent enemy
- [ ] Attack roll resolves correctly
- [ ] Damage number floats up from target
- [ ] Target HP bar updates
- [ ] Target removed if HP reaches 0

**Files:**
- Create `scripts/combat/attack_resolver.gd` - Damage calculation
- Create `scenes/UI/DamageNumber.tscn` - Floating text
- Modify `scripts/combat/unit.gd` - Take damage, death

**Hardcoded Values:**
- Player attack bonus: +4 (STR 14 = +2, Skill +2)
- Bandit defense: 12
- Player damage: 1d8 + 2 (sword + STR)
- Damage number float: 1 second, move up 50 pixels
- Damage number color: #e74c3c (red)

**Dependencies:** Task 1.5 (movement for positioning)

---

### Task 1.8: Turn System Framework

**Time:** 2 hours

**What:** Units take turns in initiative order, turn advances after move + action.

**How:**
- Roll initiative for all units at battle start (d20 + DEX)
- Create turn state machine: WaitingForInput → Moving → Acting → TurnEnd
- After action, advance to next unit
- Enemy units skip (placeholder AI in Phase 2)

**Acceptance:**
- [ ] Initiative rolled at battle start
- [ ] Current turn unit highlighted in UI and on grid
- [ ] Turn advances after player acts
- [ ] Can complete full rotation through all units

**Files:**
- Create `scripts/combat/turn_manager.gd` - Turn sequencing
- Modify `scripts/autoload/combat_manager.gd` - State machine

**Hardcoded Values:**
- Initiative: d20 + DEX modifier
- Player DEX modifier: +1 (DEX 12)
- Bandit DEX modifier: +1

**Dependencies:** Task 1.6 (turn order UI), Task 1.7 (attack action)

---

### Task 1.9: Victory/Defeat Detection

**Time:** 1 hour

**What:** Battle ends when all enemies dead (victory) or all party dead (defeat).

**How:**
- Check unit counts after each death
- Display victory/defeat popup
- Victory: "Battle Won!" with gold reward
- Defeat: "Party Defeated" with retry option (for now)

**Acceptance:**
- [ ] Victory triggers when last enemy dies
- [ ] Defeat triggers when last party member dies
- [ ] Appropriate popup displayed
- [ ] Can restart battle (temporary, for testing)

**Files:**
- Create `scenes/UI/BattleResultPopup.tscn`
- Modify `scripts/combat/turn_manager.gd` - End battle check

**Hardcoded Values:**
- Victory gold reward: 100g (placeholder)
- Popup display duration: Until player clicks

**Dependencies:** Task 1.7 (units can die)

---

**Phase 1 Checkpoint:**
- [ ] Grid displays 12x12 tiles
- [ ] Units visible with HP bars
- [ ] Click to select works
- [ ] Click to move with path preview works
- [ ] Attack deals damage with floating numbers
- [ ] Turn system cycles through units
- [ ] Battle ends on victory/defeat
- **Manual Test:** Player can solo-kill 3 bandits using movement and attacks

---

## Phase 2: Full Combat with Abilities & Soldiers (Week 1 Day 4 - Week 2 Day 3)

**Goal:** 4 party members with abilities, soldiers following orders, all 5 enemy types

**Deliverables:**
- 3 additional party members (Thorne, Lyra, Matthias)
- 12 abilities (4 per party member)
- Ranged attacks
- 2 soldier types (Infantry, Archer)
- Soldier order system (5 orders)
- Cover and high ground bonuses
- Attack of opportunity
- Basic enemy AI
- 3 combat maps

**Test Criteria:** Party + 4 soldiers defeat 8 bandits using abilities and orders. Commanding soldiers feels good.

---

### Task 2.1: Add Thorne, Lyra, Matthias Units

**Time:** 2 hours

**What:** Three companion units with distinct sprites and base stats.

**How:**
- Create variant scenes for each companion (inherit from Unit.tscn)
- Assign distinct colors/icons for each
- Set base stats (HP, STR, DEX, etc.)
- Place all 4 party members at battle start

**Acceptance:**
- [ ] All 4 party members appear at battle start
- [ ] Each has distinct visual appearance
- [ ] Each has correct HP value
- [ ] All can be selected and moved

**Files:**
- `scenes/combat/units/PlayerUnit.tscn`
- `scenes/combat/units/ThorneUnit.tscn`
- `scenes/combat/units/LyraUnit.tscn`
- `scenes/combat/units/MatthiasUnit.tscn`

**Hardcoded Values:**
- Player HP: 35, Thorne HP: 40, Lyra HP: 25, Matthias HP: 30
- Player STR: 14, Thorne STR: 16, Lyra DEX: 16, Matthias WIS: 16

**Dependencies:** Phase 1 complete

---

### Task 2.2: Ability UI Panel

**Time:** 1.5 hours

**What:** When unit selected, show 4 ability buttons at bottom of screen.

**How:**
- Create ability bar UI at bottom
- Show 4 ability icons with names
- Gray out unavailable abilities (already used, no valid target)
- Click ability to enter targeting mode

**Acceptance:**
- [ ] Ability bar shows when unit selected
- [ ] 4 abilities displayed with icons
- [ ] Can click ability button
- [ ] Unavailable abilities grayed out

**Files:**
- `scenes/UI/AbilityBar.tscn`
- `scripts/UI/ability_bar.gd`
- `assets/sprites/ui/ability_icons/` - Placeholder icons

**Hardcoded Values:**
- Ability bar position: Bottom center
- Icon size: 48 x 48 pixels
- Bar background: #1a1a2e with 90% opacity

**Dependencies:** Task 2.1 (party members exist)

---

### Task 2.3: Implement Player Abilities (4)

**Time:** 2.5 hours

**What:** Player character's 4 abilities: Power Attack, Shield Bash, Rally, Basic Attack.

**How:**
- Create ability system (Ability resource class)
- Power Attack: +50% damage, -2 to hit, melee only
- Shield Bash: Stun target 1 turn, melee only
- Rally: All soldiers +2 attack for 2 turns, no target needed
- Basic Attack: Standard melee attack

**Acceptance:**
- [ ] Power Attack deals 50% more damage
- [ ] Shield Bash stuns enemy (skip their turn)
- [ ] Rally buffs soldiers (visible buff indicator)
- [ ] Each ability can only be used once per battle (except Basic Attack)

**Files:**
- `scripts/resources/ability.gd` - Ability resource class
- `resources/abilities/power_attack.tres`
- `resources/abilities/shield_bash.tres`
- `resources/abilities/rally.tres`
- Modify `scripts/combat/unit.gd` - Ability usage

**Hardcoded Values:**
- Power Attack damage bonus: 50%
- Power Attack hit penalty: -2
- Shield Bash stun duration: 1 turn
- Rally attack bonus: +2
- Rally duration: 2 turns

**Dependencies:** Task 2.2 (ability UI)

---

### Task 2.4: Implement Thorne Abilities (4)

**Time:** 2 hours

**What:** Thorne's 4 abilities: Cleave, Taunt, Last Stand, Basic Attack.

**How:**
- Cleave: Hit 2 adjacent enemies in arc
- Taunt: All enemies in 3 tiles must attack Thorne next turn
- Last Stand: If HP drops to 0, survive with 1 HP for 1 turn
- Basic Attack: Standard melee

**Acceptance:**
- [ ] Cleave hits 2 enemies if positioned correctly
- [ ] Taunt forces enemies to target Thorne
- [ ] Last Stand triggers on lethal damage
- [ ] Abilities appear in Thorne's ability bar

**Files:**
- `resources/abilities/cleave.tres`
- `resources/abilities/taunt.tres`
- `resources/abilities/last_stand.tres`

**Hardcoded Values:**
- Cleave arc: 90 degrees, hits enemies in adjacent tiles
- Taunt range: 3 tiles
- Taunt duration: 1 turn
- Last Stand HP: 1

**Dependencies:** Task 2.3 (ability system exists)

---

### Task 2.5: Implement Lyra Abilities (4)

**Time:** 2 hours

**What:** Lyra's 4 abilities: Backstab, Shadowstep, Poison Blade, Basic Attack.

**How:**
- Backstab: Double damage if attacking from behind
- Shadowstep: Teleport up to 4 tiles (no pathfinding needed)
- Poison Blade: Next 3 attacks deal +2 damage
- Basic Attack: Standard melee (dagger, 1d4)

**Acceptance:**
- [ ] Backstab doubles damage from behind
- [ ] Shadowstep teleports without walking
- [ ] Poison Blade adds damage for 3 attacks
- [ ] "Behind" detected correctly (opposite facing direction)

**Files:**
- `resources/abilities/backstab.tres`
- `resources/abilities/shadowstep.tres`
- `resources/abilities/poison_blade.tres`

**Hardcoded Values:**
- Backstab damage multiplier: 2x
- Shadowstep range: 4 tiles
- Poison Blade bonus damage: +2
- Poison Blade duration: 3 attacks

**Dependencies:** Task 2.3 (ability system exists)

---

### Task 2.6: Implement Matthias Abilities (4)

**Time:** 2 hours

**What:** Matthias's 4 abilities: Heal, Bless, Smite, Basic Attack.

**How:**
- Heal: Restore 2d8+4 HP to ally (range 5)
- Bless: All party members +2 to all rolls for 3 turns
- Smite: 1d8 holy damage to enemy (range 3)
- Basic Attack: Staff, 1d6 damage

**Acceptance:**
- [ ] Heal restores HP to targeted ally
- [ ] Bless adds +2 bonus (visible buff icon)
- [ ] Smite deals damage at range
- [ ] Can target allies for Heal, enemies for Smite

**Files:**
- `resources/abilities/heal.tres`
- `resources/abilities/bless.tres`
- `resources/abilities/smite.tres`

**Hardcoded Values:**
- Heal amount: 2d8 + 4 (avg 13)
- Heal range: 5 tiles
- Bless bonus: +2 all rolls
- Bless duration: 3 turns
- Smite damage: 1d8 (avg 4.5)
- Smite range: 3 tiles

**Dependencies:** Task 2.3 (ability system exists)

---

### Task 2.7: Ranged Attack System

**Time:** 1.5 hours

**What:** Units with bows/crossbows can attack at range with line-of-sight check.

**How:**
- Add weapon range property
- Check line of sight (raycast or Bresenham)
- Show range indicator when selecting attack
- Ranged attacks don't provoke opportunity attacks

**Acceptance:**
- [ ] Ranged units can attack from distance
- [ ] Range shown when selecting attack
- [ ] Cannot attack through walls/obstacles
- [ ] Damage resolved same as melee

**Files:**
- Modify `scripts/combat/attack_resolver.gd` - Range handling
- Modify `scripts/combat/combat_grid.gd` - Line of sight

**Hardcoded Values:**
- Shortbow range: 8 tiles
- Crossbow range: 10 tiles
- Line of sight blocks: Obstacle tiles, other units (partial cover)

**Dependencies:** Task 1.7 (melee attack exists)

---

### Task 2.8: Soldier Unit Type (Infantry)

**Time:** 1.5 hours

**What:** Infantry soldier NPC that follows orders, not directly controlled.

**How:**
- Create SoldierUnit.tscn (inherits Unit)
- Add "current_order" property
- Infantry: Melee fighter, moves toward enemy if ADVANCE, holds if HOLD
- Show order icon above soldier

**Acceptance:**
- [ ] Infantry soldier appears with distinct sprite
- [ ] Soldier acts on its turn based on current order
- [ ] Order icon visible above soldier
- [ ] Soldier targets appropriate enemy based on order

**Files:**
- `scenes/combat/units/InfantrySoldier.tscn`
- `scripts/combat/soldier_ai.gd` - Order execution
- `assets/sprites/units/infantry_soldier.png`

**Hardcoded Values:**
- Infantry HP: 20
- Infantry ATK: 1d6 + 1
- Infantry DEF: 13
- Infantry move: 4 tiles

**Dependencies:** Task 2.1 (unit system)

---

### Task 2.9: Soldier Unit Type (Archer)

**Time:** 1 hour

**What:** Archer soldier NPC with ranged attacks.

**How:**
- Create ArcherSoldier.tscn
- Archer: Stays at range, shoots enemies
- If enemies close, retreats then shoots

**Acceptance:**
- [ ] Archer attacks from range
- [ ] Archer maintains distance if possible
- [ ] Archer follows orders appropriately

**Files:**
- `scenes/combat/units/ArcherSoldier.tscn`
- `assets/sprites/units/archer_soldier.png`

**Hardcoded Values:**
- Archer HP: 15
- Archer ATK: 1d6 (range 8)
- Archer DEF: 11
- Archer move: 5 tiles

**Dependencies:** Task 2.8 (infantry exists), Task 2.7 (ranged attacks)

---

### Task 2.10: Soldier Order System UI

**Time:** 2 hours

**What:** UI panel to issue orders to soldier groups.

**How:**
- Create Order Panel (5 buttons): Advance, Hold, Focus Fire, Retreat, Protect
- Select order, then click soldier or group
- Show current order for each soldier
- Orders persist until changed

**Acceptance:**
- [ ] Order panel visible during combat
- [ ] Can click order, then soldier to assign
- [ ] Order icon updates above soldier
- [ ] All 5 orders selectable

**Files:**
- `scenes/UI/OrderPanel.tscn`
- `scripts/UI/order_panel.gd`
- `assets/sprites/ui/order_icons/` - 5 order icons

**Hardcoded Values:**
- Order icons: 32 x 32 pixels
- Order panel position: Right side of screen

**Dependencies:** Task 2.8 (soldiers exist)

---

### Task 2.11: Soldier Order Behavior Implementation

**Time:** 3 hours

**What:** Soldiers execute their assigned orders during their turn.

**How:**
- ADVANCE: Move toward nearest enemy, attack if adjacent
- HOLD LINE: Stay in place, attack enemies in range
- FOCUS FIRE: All soldiers attack designated target
- RETREAT: Move toward map edge, don't attack
- PROTECT: Stay adjacent to protected ally, intercept attacks

**Acceptance:**
- [ ] Each order produces distinct behavior
- [ ] Soldiers act autonomously based on order
- [ ] Focus Fire targets designated enemy
- [ ] Protect keeps soldier near ally

**Files:**
- Modify `scripts/combat/soldier_ai.gd` - All order behaviors

**Hardcoded Values:**
- Protect range: 1 tile from protected ally
- Retreat destination: Starting edge of map

**Dependencies:** Task 2.10 (order UI)

---

### Task 2.12: Cover and High Ground System

**Time:** 1.5 hours

**What:** Tiles marked as cover give +2 Defense, high ground gives +2 to ranged attacks.

**How:**
- Add tile properties to TileMap (cover, high_ground)
- Check unit's tile when calculating defense/attack
- Show cover/height indicator on tiles

**Acceptance:**
- [ ] Units behind cover get +2 Defense
- [ ] Units on high ground get +2 ranged attack
- [ ] Cover/height visually indicated on map
- [ ] Bonuses appear in combat log/tooltips

**Files:**
- Modify `scripts/combat/combat_grid.gd` - Tile properties
- Modify `scripts/combat/attack_resolver.gd` - Apply bonuses

**Hardcoded Values:**
- Cover defense bonus: +2
- High ground attack bonus: +2

**Dependencies:** Task 1.1 (grid exists)

---

### Task 2.13: Attack of Opportunity

**Time:** 1.5 hours

**What:** Moving away from adjacent enemy provokes free attack.

**How:**
- Check if unit is adjacent to enemy when starting move
- If moving away, enemy gets free attack (before move)
- Only one opportunity attack per enemy per turn

**Acceptance:**
- [ ] Moving away from enemy triggers their attack
- [ ] Attack resolves before movement
- [ ] Enemy only gets one opportunity attack per turn
- [ ] Visual/audio indicator for opportunity attack

**Files:**
- Modify `scripts/combat/unit.gd` - Movement trigger
- Modify `scripts/combat/attack_resolver.gd` - Opportunity attack

**Hardcoded Values:**
- Opportunity attack: Uses enemy's basic attack
- Opportunity attacks per turn: 1 per enemy

**Dependencies:** Task 1.7 (attack system)

---

### Task 2.14: Enemy AI Basic

**Time:** 2.5 hours

**What:** Enemies act automatically on their turns with simple behaviors.

**How:**
- Bandit Melee: Move toward nearest party/soldier, attack if adjacent
- Bandit Archer: Stay at range, shoot weakest target
- Bandit Leader: Stay protected, use Rally Bandits if available
- Add aggro priority (target low HP or high threat)

**Acceptance:**
- [ ] Enemies act without player input
- [ ] Melee enemies close distance
- [ ] Ranged enemies maintain range
- [ ] Leader uses abilities appropriately

**Files:**
- Create `scripts/combat/enemy_ai.gd` - Behavior tree/state machine

**Hardcoded Values:**
- Aggro priority: Lowest HP > Highest damage dealer > Nearest
- Archer preferred range: 5-8 tiles

**Dependencies:** Task 2.7 (ranged), Task 2.8 (soldier exists to target)

---

### Task 2.15: All 5 Enemy Types

**Time:** 2 hours

**What:** Implement remaining enemy types: Ironmark Soldier, Ironmark Knight.

**How:**
- Ironmark Soldier: Shield Wall ability (+2 DEF when adjacent to ally)
- Ironmark Knight: Charge (move + attack, bonus damage), Intimidate (morale check)
- Set correct stats from GDD

**Acceptance:**
- [ ] Both Ironmark enemies appear with distinct sprites
- [ ] Shield Wall bonus applies correctly
- [ ] Charge moves and attacks in one action
- [ ] All enemy types can appear in battles

**Files:**
- `scenes/combat/units/IronmarkSoldier.tscn`
- `scenes/combat/units/IronmarkKnight.tscn`
- `assets/sprites/units/ironmark_soldier.png`
- `assets/sprites/units/ironmark_knight.png`

**Hardcoded Values:**
- Ironmark Soldier: HP 25, DEF 15, ATK 1d8+2
- Ironmark Knight: HP 40, DEF 17, ATK 1d10+4
- Charge bonus damage: +1d6
- Shield Wall bonus: +2 DEF

**Dependencies:** Task 2.14 (enemy AI)

---

### Task 2.16: Combat Map - Forest Clearing

**Time:** 1.5 hours

**What:** First combat map with trees (cover), stream (difficult terrain).

**How:**
- Create 12x12 TileMap with terrain
- Place trees as cover tiles
- Place stream as difficult terrain (half movement)
- Define spawn points for party and enemies

**Acceptance:**
- [ ] Map renders with distinct terrain types
- [ ] Trees provide cover bonus
- [ ] Stream costs double movement
- [ ] Spawn points work correctly

**Files:**
- `scenes/combat/maps/ForestClearing.tscn`

**Hardcoded Values:**
- Map size: 12 x 12 tiles
- Trees: 8-10 scattered
- Stream: 2-tile wide band

**Dependencies:** Task 2.12 (cover system)

---

### Task 2.17: Combat Map - Ruined Fort

**Time:** 1.5 hours

**What:** Second combat map with walls, rubble, high ground tower.

**How:**
- Create 14x14 TileMap (slightly larger)
- Walls block movement and line of sight
- Rubble is difficult terrain
- Tower is high ground

**Acceptance:**
- [ ] Map larger than Forest Clearing
- [ ] Walls block movement and projectiles
- [ ] Tower provides high ground bonus
- [ ] Tactical options different from forest

**Files:**
- `scenes/combat/maps/RuinedFort.tscn`

**Hardcoded Values:**
- Map size: 14 x 14 tiles
- Tower: 2x2 tile area, high ground

**Dependencies:** Task 2.16 (first map done)

---

### Task 2.18: Combat Map - Open Field

**Time:** 1 hour

**What:** Third combat map with minimal cover, wide flanking options.

**How:**
- Create 12x12 open map
- Few scattered rocks (cover)
- No chokepoints, open for maneuver

**Acceptance:**
- [ ] Map feels open and exposed
- [ ] Flanking is viable strategy
- [ ] Minimal cover forces different tactics

**Files:**
- `scenes/combat/maps/OpenField.tscn`

**Hardcoded Values:**
- Map size: 12 x 12 tiles
- Cover spots: 3-4 rocks only

**Dependencies:** Task 2.16 (first map done)

---

**Phase 2 Checkpoint:**
- [ ] All 4 party members with 4 abilities each
- [ ] 2 soldier types following orders
- [ ] All 5 enemy types with behaviors
- [ ] Cover and high ground working
- [ ] Attack of opportunity triggers
- [ ] 3 combat maps playable
- **Manual Test:** Party + 4 soldiers vs 8 enemies, full tactical battle

---

## Phase 3: Meta Loop & Companions (Week 2 Day 4 - Week 3)

**Goal:** Contract selection, company management, camp scenes with loyalty

**Deliverables:**
- Contract board UI
- 3 contracts implemented
- Fort management screen
- Soldier recruitment
- Merchant (buy equipment)
- Camp scene system
- Loyalty tracking and display
- 3 camp scenes

**Test Criteria:** Player chooses contracts, recruits soldiers, talks to companions, sees loyalty change

---

### Task 3.1: Main Hub Scene Structure

**Time:** 1.5 hours

**What:** Central hub scene connecting all management screens.

**How:**
- Create Hub.tscn with background (fort interior)
- Navigation buttons: Contracts, Barracks, Merchant, Camp
- Gold display in corner
- Scene transition system between hub screens

**Acceptance:**
- [ ] Hub scene displays with fort background
- [ ] All 4 navigation buttons work
- [ ] Gold amount visible
- [ ] Can navigate to each sub-screen

**Files:**
- `scenes/hub/Hub.tscn`
- `scripts/hub/hub.gd`
- `assets/sprites/backgrounds/fort_interior.png`

**Hardcoded Values:**
- Starting gold: 500g
- Hub background: Placeholder interior image

**Dependencies:** Phase 2 complete

---

### Task 3.2: Contract Board UI

**Time:** 2 hours

**What:** Screen showing available contracts with descriptions and rewards.

**How:**
- Create ContractBoard.tscn with list of contracts
- Each contract shows: Name, brief, reward, difficulty indicator
- Click contract to see full details
- "Accept" button starts contract

**Acceptance:**
- [ ] Contract board shows 2-3 available contracts
- [ ] Can click to view details
- [ ] Reward and difficulty clearly shown
- [ ] Accept button transitions to contract

**Files:**
- `scenes/hub/ContractBoard.tscn`
- `scripts/hub/contract_board.gd`
- `scripts/resources/contract.gd` - Contract data class

**Hardcoded Values:**
- Contracts shown: 2-3 at a time
- Contract card size: 300 x 150 pixels

**Dependencies:** Task 3.1 (hub exists)

---

### Task 3.3: Contract 1 - Merchant's Escort (Tutorial)

**Time:** 3 hours

**What:** Tutorial contract with escort objective and simple combat.

**How:**
- Create contract data (briefing, objectives, rewards)
- Combat setup: Forest Clearing map, 4 Bandits + 2 Archers
- Add merchant wagon unit (protect objective)
- Tutorial popups explaining movement, attack, orders
- Camp scene after: Meet Thorne

**Acceptance:**
- [ ] Contract brief displayed before combat
- [ ] Merchant wagon appears and must survive
- [ ] Tutorial prompts appear at right moments
- [ ] Victory gives 300 gold
- [ ] Transitions to camp scene after

**Files:**
- `resources/contracts/merchants_escort.tres`
- `scenes/contracts/MerchantsEscort.tscn` - Contract flow
- `scripts/contracts/merchants_escort.gd`

**Hardcoded Values:**
- Enemies: 4 Bandit Melee, 2 Bandit Archer
- Reward: 300 gold
- Map: Forest Clearing

**Dependencies:** Task 3.2 (contract board), Phase 2 (combat)

---

### Task 3.4: Contract 2 - Clear the Ruins (Full Combat)

**Time:** 2.5 hours

**What:** Tougher combat with leader enemy and optional cache objective.

**How:**
- Combat setup: Ruined Fort map, 6 Melee + 3 Archer + 1 Leader
- Hidden cache: Find by moving to specific tile
- Leader uses Rally Bandits ability
- Camp scene after: Lyra reveals distrust

**Acceptance:**
- [ ] Contract flows from board to combat to resolution
- [ ] Hidden cache findable (bonus gold)
- [ ] Leader enemy uses abilities
- [ ] Harder than tutorial

**Files:**
- `resources/contracts/clear_the_ruins.tres`
- `scenes/contracts/ClearTheRuins.tscn`

**Hardcoded Values:**
- Enemies: 6 Melee, 3 Archer, 1 Leader
- Base reward: 500 gold
- Cache bonus: 200 gold
- Map: Ruined Fort

**Dependencies:** Task 3.3 (contract system proven)

---

### Task 3.5: Contract 3 - The Border Dispute (Choice)

**Time:** 3.5 hours

**What:** Choice-focused contract with moral decision and branching outcomes.

**How:**
- Pre-combat scene: Dialogue with Ironmark commander, see refugees
- Choice: A) Drive off refugees, B) Let them pass, C) Negotiate
- Each choice leads to different combat or resolution
- Loyalty changes based on choice
- Camp scene after: Group discussion

**Acceptance:**
- [ ] Pre-combat dialogue presents choice
- [ ] Each choice leads to different outcome
- [ ] Combat varies by choice (or no combat for some)
- [ ] Loyalty changes display after resolution

**Files:**
- `resources/contracts/border_dispute.tres`
- `scenes/contracts/BorderDispute.tscn`
- `scripts/contracts/border_dispute.gd`

**Hardcoded Values:**
- Option A: Fight refugees (4 defenders), 600g, Matthias -20
- Option B: No combat, 300g, Matthias +10, Thorne +5
- Option C: CHA check DC 15, success = 500g + all loyalty

**Dependencies:** Task 3.4 (contract flow), Task 3.9 (loyalty system)

---

### Task 3.6: Fort Management Screen

**Time:** 2 hours

**What:** Screen to view/purchase fort upgrades.

**How:**
- Create FortManagement.tscn
- Show current upgrades and available upgrades
- Display cost, click to purchase
- Upgrades: Barracks (500g), Training Yard (600g), Tavern (300g)

**Acceptance:**
- [ ] Shows owned and available upgrades
- [ ] Cost displayed, grayed if can't afford
- [ ] Purchase deducts gold
- [ ] Upgrade effects apply (e.g., soldier capacity increases)

**Files:**
- `scenes/hub/FortManagement.tscn`
- `scripts/hub/fort_management.gd`
- `scripts/resources/fort_upgrade.gd`

**Hardcoded Values:**
- Barracks: 500g, +4 soldier capacity
- Training Yard: 600g, +50% soldier XP
- Tavern: 300g, better recruitment pool

**Dependencies:** Task 3.1 (hub exists)

---

### Task 3.7: Soldier Recruitment Screen

**Time:** 2 hours

**What:** Screen to hire soldiers with gold.

**How:**
- Create Recruitment.tscn (part of Barracks or separate)
- Show available soldiers (Infantry, Archer)
- Display cost, stats preview
- Hire button adds to company (if capacity allows)

**Acceptance:**
- [ ] Shows available soldier types
- [ ] Cost and stats displayed
- [ ] Can hire if gold and capacity sufficient
- [ ] Hired soldiers appear in next combat

**Files:**
- `scenes/hub/Recruitment.tscn`
- `scripts/hub/recruitment.gd`

**Hardcoded Values:**
- Infantry cost: 50g
- Archer cost: 100g
- Starting capacity: 4 soldiers
- With Barracks: 8 soldiers

**Dependencies:** Task 3.6 (fort management)

---

### Task 3.8: Merchant Screen

**Time:** 1.5 hours

**What:** Simple buy screen for weapons and armor.

**How:**
- Create Merchant.tscn
- List of items with prices
- Click to buy, equip automatically or to inventory
- Show current equipment vs new

**Acceptance:**
- [ ] Shows weapons and armor for sale
- [ ] Can purchase with gold
- [ ] Equipment appears in character stats
- [ ] Can see comparison before buying

**Files:**
- `scenes/hub/Merchant.tscn`
- `scripts/hub/merchant.gd`

**Hardcoded Values:**
- Iron Sword: 100g, Steel Sword: 300g
- Leather Armor: 50g, Chain Shirt: 150g, Scale Mail: 300g

**Dependencies:** Task 3.1 (hub exists)

---

### Task 3.9: Loyalty System Implementation

**Time:** 2 hours

**What:** Track loyalty per companion, apply thresholds.

**How:**
- Create loyalty data per companion (0-100)
- Functions to add/remove loyalty
- Check thresholds for status changes
- Display current loyalty in character screen

**Acceptance:**
- [ ] Loyalty tracked per companion
- [ ] Changes from choices reflected
- [ ] Thresholds affect companion status
- [ ] Loyalty visible in UI

**Files:**
- `scripts/systems/loyalty_manager.gd`
- Modify character sheet UI to show loyalty

**Hardcoded Values:**
- Starting loyalty: 50
- Thresholds: 0-29 Disloyal, 30-49 Neutral, 50-69 Loyal, 70-89 Devoted, 90-100 Bonded
- Stat modifiers: Disloyal -10%, Devoted +10%, Bonded +20%

**Dependencies:** Task 3.1 (hub exists)

---

### Task 3.10: Camp Scene System

**Time:** 2.5 hours

**What:** Dialogue scenes with companions between contracts.

**How:**
- Create CampScene.tscn with background, character portraits
- Dialogue system: Speaker, text, choices
- Choices affect loyalty
- Show loyalty change popup after choice

**Acceptance:**
- [ ] Camp scene displays with character portraits
- [ ] Dialogue advances on click
- [ ] Choices presented with distinct options
- [ ] Loyalty change shown after choice

**Files:**
- `scenes/camp/CampScene.tscn`
- `scripts/camp/camp_scene.gd`
- `scripts/systems/dialogue_manager.gd`
- `assets/sprites/portraits/` - Character portraits

**Hardcoded Values:**
- Portrait size: 200 x 250 pixels
- Dialogue box: Bottom third of screen
- Loyalty change popup: "+5 Thorne" style

**Dependencies:** Task 3.9 (loyalty system)

---

### Task 3.11: Camp Scene - Thorne (Post Contract 1)

**Time:** 1.5 hours

**What:** First camp scene after tutorial, meet Thorne properly.

**How:**
- Thorne discusses mercenary work, his cynicism
- Choice: Agree (neutral), Disagree (slight disapproval), Ask why (approval)
- Sets up his character for later

**Acceptance:**
- [ ] Scene triggers after Contract 1
- [ ] Thorne's personality established
- [ ] Choice affects his loyalty
- [ ] Transitions back to hub after

**Files:**
- `resources/dialogue/thorne_camp_1.json`

**Hardcoded Values:**
- Agree: 0 loyalty change
- Disagree: -5 Thorne loyalty
- Ask why: +5 Thorne loyalty

**Dependencies:** Task 3.10 (camp system)

---

### Task 3.12: Camp Scene - Lyra (Post Contract 2)

**Time:** 1.5 hours

**What:** Lyra reveals distrust of Ironmark.

**How:**
- Lyra questions why you took Ironmark's contract
- Choice: Defend Ironmark, Agree with suspicion, Neutral
- Foreshadows Contract 3 choice

**Acceptance:**
- [ ] Scene triggers after Contract 2
- [ ] Lyra's personality and backstory hinted
- [ ] Choice affects loyalty
- [ ] Sets up Contract 3 thematically

**Files:**
- `resources/dialogue/lyra_camp_1.json`

**Hardcoded Values:**
- Defend Ironmark: -5 Lyra, +5 Thorne
- Agree with suspicion: +5 Lyra, -5 Thorne
- Neutral: 0 all

**Dependencies:** Task 3.10 (camp system)

---

### Task 3.13: Camp Scene - Matthias (Post Contract 3)

**Time:** 1.5 hours

**What:** Group discusses Contract 3 outcome, Matthias reveals his values.

**How:**
- Matthias reacts to player's choice in Contract 3
- If helped refugees: Approval, discusses protecting innocents
- If drove them off: Disappointment, questions player's morality
- Shows loyalty system consequences

**Acceptance:**
- [ ] Scene varies based on Contract 3 choice
- [ ] Matthias's faith/values shown
- [ ] Loyalty already changed by contract choice
- [ ] Proper conclusion to prototype arc

**Files:**
- `resources/dialogue/matthias_camp_1.json`

**Hardcoded Values:**
- Varies by Contract 3 choice (already applied)
- Additional +2 for engaging with Matthias in conversation

**Dependencies:** Task 3.5 (Contract 3), Task 3.10 (camp system)

---

**Phase 3 Checkpoint:**
- [ ] Hub navigation works
- [ ] Contract board shows and accepts contracts
- [ ] All 3 contracts playable with distinct objectives
- [ ] Fort upgrades purchasable
- [ ] Soldiers recruitable
- [ ] Merchant buy screen works
- [ ] Loyalty tracked and displayed
- [ ] 3 camp scenes trigger and affect loyalty
- **Full Playthrough Test:** Complete all 3 contracts with camp scenes

---

## Phase 4: Polish, Balance & Playtest (Week 4)

**Goal:** Polished, balanced prototype ready for external playtesting

**Deliverables:**
- Balance pass on all numbers
- Bug fixes
- UI polish
- Tutorial guidance
- End screen with stats
- 3 external playtest sessions
- Feedback documentation

**Test Criteria:** Playtesters complete prototype, understand systems, provide actionable feedback

---

### Task 4.1: Combat Balance Pass

**Time:** 3 hours

**What:** Adjust HP, damage, and ability values for good pacing.

**How:**
- Play each combat multiple times
- Target: 5-10 minutes per battle
- Ensure player can lose but not easily
- Make abilities feel impactful

**Acceptance:**
- [ ] Tutorial combat: ~5 minutes, low difficulty
- [ ] Contract 2 combat: ~8 minutes, medium difficulty
- [ ] Contract 3 combat: ~10 minutes, high difficulty (if fighting soldiers)
- [ ] Healing doesn't trivialize combat, but prevents attrition

**Files:**
- All unit .tres files (stat adjustments)
- Ability .tres files (damage/duration adjustments)

**Hardcoded Values:**
- (To be determined through testing)
- Document final values after balance

**Dependencies:** Phase 3 complete

---

### Task 4.2: Economy Balance Pass

**Time:** 2 hours

**What:** Ensure gold economy feels tight but not frustrating.

**How:**
- Track gold across full playthrough
- Player should be able to afford 2-3 soldiers OR 1 upgrade
- Not enough to buy everything
- Contract rewards should feel meaningful

**Acceptance:**
- [ ] Player makes meaningful economic choices
- [ ] Can't afford everything (must prioritize)
- [ ] Upgrades feel worthwhile
- [ ] Not broke by end of prototype

**Files:**
- Contract reward values
- Upgrade costs
- Soldier costs
- Merchant prices

**Hardcoded Values:**
- Target gold after 3 contracts: ~1200g (before spending)
- Should afford: 2-3 soldiers + 1 upgrade + some equipment

**Dependencies:** Task 4.1 (combat balance affects gold needs)

---

### Task 4.3: Combat UI Polish

**Time:** 3 hours

**What:** Make combat UI clear and readable.

**How:**
- Improve turn indicator visibility
- Add ability tooltips (hover to see description)
- Add action confirmation (click target to confirm)
- Add combat log (scrolling text of events)

**Acceptance:**
- [ ] Clear whose turn it is
- [ ] Abilities have tooltip descriptions
- [ ] Combat log shows what happened
- [ ] No confusion about UI elements

**Files:**
- Modify `scenes/UI/AbilityBar.tscn` - Tooltips
- Create `scenes/UI/CombatLog.tscn`
- Modify `scenes/UI/TurnOrderPanel.tscn` - Polish

**Hardcoded Values:**
- Tooltip delay: 0.5 seconds
- Combat log lines: 8 visible

**Dependencies:** Phase 2 UI exists

---

### Task 4.4: Tutorial Enhancement

**Time:** 2 hours

**What:** Add clear guidance for new players in Contract 1.

**How:**
- Add tutorial popups at key moments
- Highlight first move tile, first attack target
- Explain soldier orders when first available
- Don't overwhelm, just the basics

**Acceptance:**
- [ ] First-time player understands movement
- [ ] First-time player understands attacking
- [ ] Soldier orders explained simply
- [ ] Can skip tutorial prompts

**Files:**
- Create `scripts/systems/tutorial_manager.gd`
- `scenes/UI/TutorialPopup.tscn`

**Hardcoded Values:**
- Tutorial steps: 5-6 popups maximum
- Popup duration: Until click or action complete

**Dependencies:** Task 3.3 (tutorial contract)

---

### Task 4.5: Choice Feedback Enhancement

**Time:** 1.5 hours

**What:** Make choice consequences clearer.

**How:**
- After major choice, show consequence popup
- "Matthias disapproves (-20 Loyalty)"
- Add companion reaction portraits during choices
- Make tradeoffs visible

**Acceptance:**
- [ ] Loyalty changes shown immediately
- [ ] Companion reaction visible during choice
- [ ] Player understands what happened

**Files:**
- Modify `scripts/systems/dialogue_manager.gd`
- Create consequence popup UI

**Hardcoded Values:**
- Popup duration: 2 seconds or until click
- Show companion portrait with emotion

**Dependencies:** Task 3.9 (loyalty system)

---

### Task 4.6: End Screen

**Time:** 1.5 hours

**What:** Summary screen after completing all 3 contracts.

**How:**
- Show: Contracts completed, gold earned, soldiers lost
- Show: Final loyalty with each companion
- Show: "Thanks for playing the prototype!"
- Option to restart

**Acceptance:**
- [ ] End screen triggers after Contract 3 camp scene
- [ ] Shows meaningful stats
- [ ] Clear this is end of prototype
- [ ] Can restart or quit

**Files:**
- `scenes/UI/EndScreen.tscn`
- `scripts/UI/end_screen.gd`

**Hardcoded Values:**
- Stats to show: Contracts (3), Gold (total), Soldiers lost, Loyalty per companion

**Dependencies:** Task 3.13 (final camp scene)

---

### Task 4.7: Bug Fix Sprint

**Time:** 4 hours

**What:** Fix all known bugs from internal testing.

**How:**
- Create bug list during Phase 3
- Prioritize game-breaking bugs
- Fix UI bugs
- Fix edge cases in combat

**Acceptance:**
- [ ] No game-breaking bugs
- [ ] No softlocks
- [ ] UI doesn't overlap or break
- [ ] Combat resolves correctly

**Files:**
- Various (depends on bugs found)

**Hardcoded Values:**
- N/A

**Dependencies:** Phases 1-3 complete

---

### Task 4.8: Internal Playtest (Full)

**Time:** 3 hours

**What:** Complete playthrough by developer, noting all issues.

**How:**
- Play entire prototype start to finish
- Note any confusion, bugs, balance issues
- Time each section
- Document feedback

**Acceptance:**
- [ ] Full playthrough completed
- [ ] Issues documented
- [ ] Timing recorded
- [ ] Ready for external testers

**Files:**
- `docs/internal-playtest-notes.md`

**Hardcoded Values:**
- Target total time: 45-60 minutes

**Dependencies:** Task 4.7 (bugs fixed)

---

### Task 4.9: External Playtest Sessions (3)

**Time:** 6 hours (2 hours each x 3)

**What:** Watch 3 different people play the prototype.

**How:**
- Brief tester minimally ("Play this, I'll watch")
- Don't help unless stuck
- Note where they struggle, what they enjoy
- Ask questions after (from GDD metrics)

**Acceptance:**
- [ ] 3 playtesters recruited
- [ ] Each session observed and documented
- [ ] Post-play questions asked
- [ ] Feedback compiled

**Files:**
- `docs/playtest-feedback.md`

**Hardcoded Values:**
- Questions: "Most fun?", "Most frustrating?", "Care about companions?", "Would play full version?"

**Dependencies:** Task 4.8 (internal test done)

---

### Task 4.10: Feedback Compilation & Scoring

**Time:** 2 hours

**What:** Compile all feedback, score critical questions.

**How:**
- Review all playtest notes
- Score each critical question 1-5 based on observations
- Calculate total score
- Determine next steps (build/iterate/pivot)

**Acceptance:**
- [ ] All 5 critical questions scored
- [ ] Total score calculated
- [ ] Decision documented
- [ ] Next steps clear

**Files:**
- `docs/prototype-evaluation.md`

**Hardcoded Values:**
- Score thresholds: 20-25 proceed, 15-19 iterate, <15 pivot/kill

**Dependencies:** Task 4.9 (playtest complete)

---

**Phase 4 Checkpoint:**
- [ ] Combat balanced (5-10 min battles)
- [ ] Economy balanced (meaningful choices)
- [ ] UI polished and clear
- [ ] Tutorial effective
- [ ] Choices feel consequential
- [ ] End screen shows stats
- [ ] Bugs fixed
- [ ] 3 external playtests completed
- [ ] Evaluation documented

---

## Daily Schedule

### Week 1

**Day 1 (Monday): Grid & Units Visual**
- Morning (4h): Tasks 1.1, 1.2, 1.3
- Afternoon (4h): Tasks 1.4, 1.5
- **End of Day:** Grid visible, units on grid, click-to-select, click-to-move

**Day 2 (Tuesday): Combat Foundation**
- Morning (4h): Tasks 1.6, 1.7
- Afternoon (4h): Tasks 1.8, 1.9
- **End of Day:** Full turn-based combat working (1 fighter vs 3 bandits)

**Day 3 (Wednesday): Party & Abilities**
- Morning (4h): Tasks 2.1, 2.2, 2.3
- Afternoon (4h): Tasks 2.4, 2.5
- **End of Day:** All party members with most abilities

**Day 4 (Thursday): Abilities & Ranged**
- Morning (4h): Tasks 2.6, 2.7
- Afternoon (4h): Tasks 2.8, 2.9
- **End of Day:** All abilities done, soldiers exist, ranged attacks work

**Day 5 (Friday): Soldier Orders & AI**
- Morning (4h): Tasks 2.10, 2.11
- Afternoon (4h): Tasks 2.12, 2.13
- **End of Day:** Soldiers follow orders, cover/height working, AoO working

### Week 2

**Day 6 (Monday): Enemy AI & Maps**
- Morning (4h): Tasks 2.14, 2.15
- Afternoon (4h): Tasks 2.16, 2.17, 2.18
- **End of Day:** Full Phase 2 complete - full tactical combat

**Day 7 (Tuesday): Hub & Contracts**
- Morning (4h): Tasks 3.1, 3.2
- Afternoon (4h): Task 3.3
- **End of Day:** Hub navigation, contract board, tutorial contract playable

**Day 8 (Wednesday): Contracts & Management**
- Morning (4h): Tasks 3.4, 3.5 (start)
- Afternoon (4h): Tasks 3.5 (finish), 3.6
- **End of Day:** All contracts playable, fort management works

**Day 9 (Thursday): Recruitment & Merchant**
- Morning (4h): Tasks 3.7, 3.8
- Afternoon (4h): Tasks 3.9, 3.10
- **End of Day:** Full economy loop, camp system working

**Day 10 (Friday): Camp Scenes**
- Morning (4h): Tasks 3.11, 3.12, 3.13
- Afternoon (4h): Integration testing, bug fixes
- **End of Day:** Full Phase 3 complete - meta loop working

### Week 3

**Days 11-12: Buffer & Polish Start**
- Catch up on any delayed tasks
- Begin Task 4.1 (combat balance)
- Begin Task 4.2 (economy balance)

**Days 13-14: UI Polish**
- Tasks 4.3, 4.4, 4.5
- Begin internal testing

**Day 15: End Screen & Bug Fixes**
- Task 4.6, 4.7
- Full internal playthrough

### Week 4

**Days 16-17: Final Polish & Internal Test**
- Task 4.8 (internal playtest)
- Fix discovered issues

**Days 18-20: External Playtests**
- Task 4.9 (3 playtest sessions)
- Document feedback

**Day 21: Evaluation**
- Task 4.10 (compile feedback, score, decide)
- Write up results

---

## Content Checklist

### Party Members
- [ ] Player Character (Fighter) - 4 abilities
- [ ] Thorne Blackwood (Fighter) - 4 abilities
- [ ] Lyra Swiftblade (Rogue) - 4 abilities
- [ ] Brother Matthias (Cleric) - 4 abilities

### Abilities (12 total)
- [ ] Power Attack, Shield Bash, Rally (Player)
- [ ] Cleave, Taunt, Last Stand (Thorne)
- [ ] Backstab, Shadowstep, Poison Blade (Lyra)
- [ ] Heal, Bless, Smite (Matthias)

### Enemy Types (5)
- [ ] Bandit Melee (HP 15, DEF 12, ATK 1d6+2)
- [ ] Bandit Archer (HP 10, DEF 11, ATK 1d6 range 8)
- [ ] Bandit Leader (HP 30, DEF 14, ATK 1d8+3, Rally ability)
- [ ] Ironmark Soldier (HP 25, DEF 15, ATK 1d8+2, Shield Wall)
- [ ] Ironmark Knight (HP 40, DEF 17, ATK 1d10+4, Charge, Intimidate)

### Soldier Types (2)
- [ ] Infantry (HP 20, DEF 13, ATK 1d6+1, Move 4)
- [ ] Archer (HP 15, DEF 11, ATK 1d6 range 8, Move 5)

### Combat Maps (3)
- [ ] Forest Clearing (12x12, trees, stream)
- [ ] Ruined Fort (14x14, walls, tower, rubble)
- [ ] Open Field (12x12, minimal cover)

### Contracts (3)
- [ ] Merchant's Escort (Tutorial, 300g, 6 enemies)
- [ ] Clear the Ruins (Combat, 500g+, 10 enemies)
- [ ] The Border Dispute (Choice, 300-600g, varies)

### Camp Scenes (3)
- [ ] Thorne post-Contract 1
- [ ] Lyra post-Contract 2
- [ ] Matthias post-Contract 3

### Fort Upgrades (3)
- [ ] Barracks (500g, +4 capacity)
- [ ] Training Yard (600g, +50% XP)
- [ ] Tavern (300g, better recruits)

---

## Risk Mitigation Plan

**Risk: Commanding soldiers feels like micromanagement**
- **If This Happens:** Playtesters ignore soldiers, say "too many units"
- **Action Items:**
  - Reduce default soldier count to 2
  - Simplify orders to "Attack" and "Defend" only
  - Add auto-resolve option for soldiers

**Risk: Combat takes too long with 12+ units**
- **If This Happens:** Battles exceed 15 minutes
- **Action Items:**
  - Group soldier turns (all act at once)
  - Speed up animations 2x
  - Reduce enemy count

**Risk: Grid combat feels sterile/boring**
- **If This Happens:** Playtesters don't use positioning, say "boring"
- **Action Items:**
  - Add more environmental hazards
  - Make cover more impactful (+3 instead of +2)
  - Add dramatic hit/miss feedback

**Risk: Companion loyalty system feels arbitrary**
- **If This Happens:** Playtesters don't notice or care about loyalty
- **Action Items:**
  - Bigger loyalty change popups
  - Companions comment on loyalty during combat
  - More frequent loyalty checks

**Risk: Contract choices don't feel meaningful**
- **If This Happens:** Playtesters pick randomly, don't deliberate
- **Action Items:**
  - Make gold differences larger
  - Add immediate visible consequence
  - Add "what would have happened" narration

**Risk: 4 weeks isn't enough time**
- **If This Happens:** Behind schedule by end of Week 2
- **Action Items:**
  - Cut Contract 3 combat (choice only, no fight)
  - Simplify camp scenes to single choice
  - Cut fort upgrades, keep recruitment only

---

## Technical Notes

### File Structure
```
blood-&-gold/
├── scenes/
│   ├── combat/
│   │   ├── CombatGrid.tscn
│   │   ├── Unit.tscn
│   │   ├── units/ (party, soldiers, enemies)
│   │   └── maps/ (ForestClearing, RuinedFort, OpenField)
│   ├── hub/
│   │   ├── Hub.tscn
│   │   ├── ContractBoard.tscn
│   │   ├── FortManagement.tscn
│   │   ├── Recruitment.tscn
│   │   └── Merchant.tscn
│   ├── camp/
│   │   └── CampScene.tscn
│   ├── contracts/
│   │   ├── MerchantsEscort.tscn
│   │   ├── ClearTheRuins.tscn
│   │   └── BorderDispute.tscn
│   └── UI/
│       ├── AbilityBar.tscn
│       ├── TurnOrderPanel.tscn
│       ├── OrderPanel.tscn
│       ├── CombatLog.tscn
│       └── DamageNumber.tscn
├── scripts/
│   ├── autoload/
│   │   ├── game_manager.gd
│   │   └── combat_manager.gd
│   ├── combat/
│   │   ├── combat_grid.gd
│   │   ├── unit.gd
│   │   ├── pathfinding.gd
│   │   ├── turn_manager.gd
│   │   ├── attack_resolver.gd
│   │   ├── soldier_ai.gd
│   │   └── enemy_ai.gd
│   ├── hub/
│   ├── camp/
│   ├── systems/
│   │   ├── loyalty_manager.gd
│   │   ├── dialogue_manager.gd
│   │   └── tutorial_manager.gd
│   ├── resources/
│   │   ├── ability.gd
│   │   ├── contract.gd
│   │   └── fort_upgrade.gd
│   └── UI/
├── resources/
│   ├── abilities/ (.tres files)
│   ├── contracts/ (.tres files)
│   └── dialogue/ (.json files)
└── assets/
    └── sprites/
        ├── units/
        ├── tiles/
        ├── ui/
        ├── portraits/
        └── backgrounds/
```

### Autoload Singletons
- `GameManager` - Game state, gold, soldiers owned, upgrades
- `CombatManager` - Combat state, selected unit, current turn

### Key Signals
- `unit_selected(unit)` - When player clicks unit
- `unit_moved(unit, from, to)` - When movement completes
- `unit_attacked(attacker, target, damage)` - When attack resolves
- `unit_died(unit)` - When HP reaches 0
- `turn_ended(unit)` - When turn completes
- `battle_ended(victory: bool)` - When battle resolves
- `loyalty_changed(companion, amount)` - When loyalty updates

---

**END OF ROADMAP**

**Next Steps:**
1. Review this roadmap
2. Set up Godot project (already done via godot-project-setup)
3. Start Phase 1, Task 1.1: Combat Grid Display
4. Test after each task, track progress with checkboxes

**Total Tasks:** 46
**Total Estimated Hours:** 148 (within 160-hour budget)
**Buffer Time:** 12 hours for unexpected issues

