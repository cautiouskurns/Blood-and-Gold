# BLOOD & GOLD - Prototype Design Document

**Version:** 0.1 - Core Loop Prototype
**Goal:** Validate that commanding a mercenary company with NPC soldiers in tactical grid combat feels strategic and satisfying
**Timeline:** 4 weeks
**Date:** January 2026

---

## 1. CONCEPT

### Elevator Pitch

A party-based tactical CRPG where you found a mercenary company, recruit soldiers, and command them alongside your party in grid-based battles. Take contracts, build your reputation, and choose which kingdom wins the war. Think Baldur's Gate meets Mount & Blade's company management.

### Design Pillars

**Build & Command**
Players grow a mercenary company from 4 founding members to a legendary force. The fantasy of building something from nothing, recruiting soldiers, upgrading your fort, and seeing your company become famous drives long-term engagement. Command isn't just party control - it's leading NPC soldiers who follow your orders.

**Meaningful Choice**
Every contract is a choice. You can't do everything in 60 days. Pick which contracts to take, which to refuse, which kingdoms to ally with, which to betray. Companions react to your choices. The war's outcome depends on you. No optimal path - just your path.

**Tactical Combat**
Grid-based turn-based combat with environmental interaction. Not just "attack enemy" - use terrain, flank, set up ambushes, combine party abilities with soldier formations. Large-scale battles (your 8-12 units vs 15-20 enemies) that feel like commanding a warband, not just a party.

**Character Progression**
Classic CRPG power fantasy. Start at level 3 (competent but vulnerable), end at level 10 (legendary). Multiple viable builds per class. Equipment matters - finding that enchanted sword changes everything. Companions grow with you, unlock abilities through loyalty.

### Primary Influences

**Baldur's Gate / Divinity: Original Sin**
- What we're taking: Party-based tactical combat, companion loyalty systems, meaningful dialogue choices, isometric perspective
- Applies: Core combat feel, companion personal quests, camp conversations

**Mount & Blade**
- What we're taking: Mercenary company fantasy, recruiting soldiers, building reputation with factions, choosing which side to support in wars
- Applies: Company management meta-layer, soldier recruitment, kingdom reputation

**XCOM**
- What we're taking: Grid-based tactical combat, soldier permadeath, base building between missions, mission selection from pool
- Applies: Combat system, soldier management, fort upgrades, contract selection

**Fire Emblem**
- What we're taking: Turn-based grid combat, unit relationships affecting combat, permadeath consequences
- Applies: Combat mechanics, companion loyalty affecting abilities

---

## 2. WHAT WE'RE TESTING

### Critical Questions

**Q1: Does commanding NPC soldiers alongside your party feel strategic (not micromanagement hell)?**
- Success = Players give orders to soldiers, focus on party tactics, feel like a commander
- Failure = Players feel overwhelmed, ignore soldiers, or combat becomes tedious

**Q2: Does the grid-based tactical combat feel satisfying with 8-12 units vs 15-20 enemies?**
- Success = Battles feel like tactical puzzles, environmental play matters, positioning decisions meaningful
- Failure = Combat is just "everyone attack", positioning irrelevant, battles drag

**Q3: Do contract choices feel meaningful (with real tradeoffs)?**
- Success = Players deliberate on which contract to take, feel consequences of choices
- Failure = Contracts feel interchangeable, no sense of opportunity cost

**Q4: Does the mercenary company building loop feel rewarding?**
- Success = Players excited to recruit soldiers, upgrade fort, see company grow
- Failure = Management feels like busywork, no emotional connection to growth

**Q5: Do companion loyalty and camp scenes create emotional investment?**
- Success = Players care about companion opinions, seek approval, enjoy camp conversations
- Failure = Companions feel like combat stats, loyalty system ignored

### Success Criteria

After 4-week playtest, score each question 1-5:
- 1 = Doesn't work at all
- 3 = Works but needs improvement
- 5 = Works great, build full game

**Decision Threshold:**
- 20-25 points: Proceed to full production
- 15-19 points: Iterate on problem areas, retest in 2 weeks
- <15 points: Fundamental design issues - pivot or kill concept

---

## 3. CORE MECHANICS

### Combat System (Primary Mechanic)

The heart of the prototype. Grid-based, turn-based tactical combat with party members (direct control) and NPC soldiers (order-based control).

**How It Works:**
1. Battle begins - all units placed on grid (12x12 typical)
2. Initiative rolled (d20 + DEX modifier) determines turn order
3. On each unit's turn: Move (up to movement speed) + Action (attack/ability/item)
4. Party members (4): Full tactical control - you choose every action
5. NPC soldiers (4-8): Follow standing orders until you issue new ones
6. Battle ends when: All enemies dead/fled OR all your units incapacitated

**Player Inputs:**
- Click unit to select
- Click tile to move
- Click ability/attack, then target
- Issue orders to soldier groups (Advance/Hold/Focus Fire/Retreat/Protect)

**System Response:**
- Units animate movement along path
- Attack rolls resolved (d20 + modifiers vs Defense)
- Damage calculated and displayed
- Status effects applied and shown
- Death/KO triggers removal or incapacitation

**Soldier Orders System:**
```
ADVANCE: Soldiers move toward nearest enemy, engage in melee
HOLD LINE: Soldiers stay in position, attack enemies in range
FOCUS FIRE: All soldiers target the same enemy you designate
RETREAT: Soldiers fall back toward map edge
PROTECT: Soldiers guard a specific party member
```

Soldiers follow orders automatically until:
- You issue a new order
- They're attacked (they defend themselves)
- Morale breaks (they flee)

**Interactions:**
- Terrain affects movement (difficult terrain = half speed)
- High ground grants +2 ranged attacks
- Cover provides +2 Defense
- Environmental hazards (fire, oil, water) create tactical opportunities
- Flanking grants advantage on attacks

### Movement & Positioning (Supporting Mechanic)

**Specifics:**
- Light armor: 6 tiles per turn
- Medium armor: 5 tiles per turn
- Heavy armor: 4 tiles per turn
- Diagonal movement costs 1.5 tiles
- Leaving a threatened tile (adjacent to enemy) provokes attack of opportunity

**Interactions:**
- Positioning determines flanking bonuses
- Ranged units need line of sight
- Melee units need adjacency
- Chokepoints become tactical focal points

### Attack Resolution (Supporting Mechanic)

**Specifics:**
```
Attack Roll: d20 + STR/DEX modifier + Skill rank
Defense Value: 10 + DEX modifier + Armor bonus
Hit: If Attack Roll >= Defense Value
Damage: Weapon die + STR/DEX modifier
Critical: Natural 20 = double damage
```

**Damage Types:**
- Physical: Slashing, Piercing, Bludgeoning
- Magical: Fire, Ice, Lightning, Holy (prototype: Fire only)

**Interactions:**
- Armor provides damage reduction vs physical
- Vulnerabilities/resistances modify damage
- Status effects (Bleeding, Stunned, Slowed) stack from abilities

### Companion Loyalty (Supporting Mechanic)

**Specifics:**
- Loyalty score: 0-100 per companion
- Starts at 50 (neutral)
- Gains from: Approved choices (+5-10), completing companion quests (+20), camp conversations (+2)
- Losses from: Disapproved choices (-5-20), betraying their values (-20)

**Loyalty Thresholds:**
| Score | Status | Combat Effect |
|-------|--------|---------------|
| 0-29 | Disloyal | -10% stats, may leave |
| 30-49 | Neutral | Normal performance |
| 50-69 | Loyal | Normal performance |
| 70-89 | Devoted | +10% stats, unlock ability |
| 90-100 | Bonded | +20% stats, unlock ultimate |

**Interactions:**
- High loyalty unlocks powerful combat abilities
- Low loyalty causes companions to leave permanently
- Camp scenes reveal loyalty-affecting dialogue choices
- Companions disagree with each other, forcing player to choose sides

### Company Management (Supporting Mechanic)

**Specifics:**
- Soldier recruitment: Hire at taverns (50-300g each)
- Soldier types: Infantry, Archer, Mage, Healer (prototype: Infantry and Archer only)
- Soldier capacity: Starts at 4, increases with Barracks upgrade
- Fort upgrades: Spend gold to unlock benefits

**Prototype Fort Upgrades:**
```
Barracks (500g): +4 soldier capacity
Training Yard (600g): Soldiers gain XP 50% faster
Tavern (300g): Better soldier recruitment pool
```

**Interactions:**
- More soldiers = bigger battles, more tactics
- Better soldiers = easier combat, but expensive
- Fort upgrades = long-term investment vs immediate equipment

---

## 4. CONTENT SCOPE

### Party Members (4 characters)

**Player Character (Fighter):**
- Stats: STR 14, DEX 12, CON 14, INT 10, WIS 10, CHA 12
- HP: 35
- Abilities: Power Attack (+50% damage, -2 hit), Shield Bash (stun 1 turn), Rally (soldiers +2 attack for 2 turns)
- Purpose: Frontline tank, soldier commander

**Thorne Blackwood (Fighter - Companion):**
- Stats: STR 16, DEX 10, CON 14, INT 10, WIS 12, CHA 8
- HP: 40
- Abilities: Cleave (hit 2 adjacent enemies), Taunt (enemies must attack him), Last Stand (can't die for 1 turn at 0 HP)
- Purpose: Heavy melee, damage sponge
- Loyalty triggers: Honor in combat (+), Assassination (-)

**Lyra Swiftblade (Rogue - Companion):**
- Stats: STR 10, DEX 16, CON 10, INT 14, WIS 12, CHA 12
- HP: 25
- Abilities: Backstab (double damage from behind), Shadowstep (teleport 4 tiles), Poison Blade (+2 damage for 3 turns)
- Purpose: Flanker, priority target assassin
- Loyalty triggers: Protecting team (+), Betrayal (-)

**Brother Matthias (Cleric - Companion):**
- Stats: STR 10, DEX 10, CON 12, INT 12, WIS 16, CHA 14
- HP: 30
- Abilities: Heal (restore 2d8+4 HP), Bless (+2 all rolls for party, 3 turns), Smite (1d8 holy damage)
- Purpose: Healer, buffer, light damage
- Loyalty triggers: Protecting innocents (+), Cruelty (-)

### Enemy Types (5 types)

**Bandit Melee:**
- HP: 15, Defense: 12, Damage: 1d6+2
- Behavior: Rush nearest target
- Purpose: Basic fodder, test positioning

**Bandit Archer:**
- HP: 10, Defense: 11, Damage: 1d6 (range 8)
- Behavior: Stay at range, shoot priority targets
- Purpose: Force player to advance or use cover

**Bandit Leader:**
- HP: 30, Defense: 14, Damage: 1d8+3
- Abilities: Rally Bandits (+2 attack to all bandits), Power Attack
- Behavior: Stay protected, buff minions
- Purpose: Priority target, tactical decision

**Ironmark Soldier:**
- HP: 25, Defense: 15 (heavy armor), Damage: 1d8+2
- Abilities: Shield Wall (+2 Defense when adjacent to ally)
- Behavior: Hold formation, advance slowly
- Purpose: Test player's ability to break formations

**Ironmark Knight:**
- HP: 40, Defense: 17, Damage: 1d10+4
- Abilities: Charge (move + attack, bonus damage), Intimidate (soldiers morale check)
- Behavior: Aggressive charges, target player's soldiers
- Purpose: Mini-boss, force tactical response

### Weapons (8 types)

**Melee:**
| Weapon | Damage | Properties |
|--------|--------|------------|
| Iron Sword | 1d8 | Standard |
| Iron Axe | 1d8 | High crit (19-20) |
| Iron Mace | 1d6 | +2 vs armored |
| Iron Spear | 1d6 | Reach (2 tiles) |

**Ranged:**
| Weapon | Damage | Range | Properties |
|--------|--------|-------|------------|
| Shortbow | 1d6 | 8 | Standard |
| Crossbow | 1d8 | 10 | Reload (skip turn after shot) |

**Upgraded (found/bought):**
| Weapon | Damage | Properties |
|--------|--------|------------|
| Steel Sword | 1d8+1 | Standard |
| Flaming Sword | 1d8+1d4 fire | Rare drop |

### Armor (4 types)

| Armor | Defense | Movement | Cost |
|-------|---------|----------|------|
| Leather | +2 | 6 tiles | 50g |
| Chain Shirt | +4 | 5 tiles | 150g |
| Scale Mail | +5 | 5 tiles | 300g |
| Plate | +6 | 4 tiles | 600g |

### Combat Maps (3 maps)

**Forest Clearing:**
- 12x12 grid
- Features: Trees (cover), stream (difficult terrain), fallen log (chokepoint)
- Purpose: Test positioning, cover usage

**Ruined Fort:**
- 14x14 grid
- Features: Walls (full cover), rubble (difficult terrain), high ground (tower)
- Purpose: Test elevation, defensive play

**Open Field:**
- 12x12 grid
- Features: Minimal cover, wide flanking options
- Purpose: Test soldier formations, maneuver warfare

---

## 5. PROTOTYPE SCOPE

### What's IN (Minimum Viable)

**Combat System:**
- Grid-based movement (hex or square - decide in Phase 1)
- Turn order by initiative
- Basic attacks (melee and ranged)
- 4 abilities per party member (12 total)
- Soldier order system (5 orders)
- Attack of opportunity
- Cover and high ground bonuses

**Characters:**
- 4 party members (Player, Thorne, Lyra, Matthias)
- 5 enemy types
- 2 soldier types (Infantry, Archer)

**Company Management:**
- Hire soldiers (simple menu)
- 3 fort upgrades
- Gold tracking

**Contracts:**
- 3 contracts (tutorial, combat-focused, choice-focused)
- Contract selection screen
- Basic rewards (gold, reputation placeholder)

**Companion System:**
- Loyalty score tracking
- 3 camp scenes (1 per companion)
- 2 loyalty-affecting choices per contract

**UI:**
- Combat HUD (HP bars, turn order, ability buttons)
- Simple character sheet
- Contract board
- Camp menu

### What's OUT (Not for Prototype)

**Full Progression System**
- Reason: Testing core loop, not long-term progression
- Prototype: Fixed level 5 characters, no XP gain

**Equipment Crafting/Enchanting**
- Reason: Polish feature, not core loop
- Prototype: Buy/loot only, no crafting

**Full Kingdom Reputation System**
- Reason: Requires full 15-contract arc to test
- Prototype: Simple "Ironmark friendly/hostile" flag

**Romance System**
- Reason: Requires multiple playthroughs to test
- Prototype: Loyalty only, no romance

**All 5 Kingdoms**
- Reason: Scope too large for prototype
- Prototype: Ironmark only, others mentioned in dialogue

**Side Quests**
- Reason: Testing main contract loop first
- Prototype: 3 main contracts only

**Full Companion Quest Arcs**
- Reason: Requires full game to resolve
- Prototype: 1 camp scene per companion to test system

**Save/Load System**
- Reason: Technical feature, not design validation
- Prototype: Single session playthrough

**Audio/Music**
- Reason: Polish, not core loop
- Prototype: Placeholder sounds or silence

**Polished Art**
- Reason: Validate gameplay first
- Prototype: Placeholder sprites, simple shapes acceptable

### Target Playtime

**Single Prototype Playthrough:** 45-60 minutes
- Contract 1 (Tutorial): 15 minutes
- Contract 2 (Full Combat): 20 minutes
- Contract 3 (Choice + Combat): 20 minutes
- Camp scenes between: 5-10 minutes total

---

## 6. IMPLEMENTATION PHASES

### Phase 1: Combat Foundation (Week 1 - 40 hours)

**Goal:** Playable grid combat with 1 party member vs 3 enemies

**Deliverables:**
- Grid system (12x12, tile-based)
- Unit placement and selection
- Movement system (pathfinding, movement costs)
- Basic attack action (melee only)
- Turn order (initiative roll at battle start)
- HP tracking and damage
- Victory/defeat conditions
- Placeholder art (colored rectangles)

**Test:** Can one fighter move around grid and kill 3 bandits through basic attacks?

---

### Phase 2: Full Party Combat (Week 2 - 40 hours)

**Goal:** 4 party members with abilities vs 8 enemies, soldiers following orders

**Deliverables:**
- Add 3 more party members (Thorne, Lyra, Matthias)
- Implement 4 abilities per character (12 total)
- Add ranged attacks
- Add 2 soldier types (Infantry, Archer)
- Implement order system (5 orders)
- Add cover and high ground bonuses
- Add attack of opportunity
- Create 3 combat maps

**Test:** Can party + 4 soldiers defeat 8 bandits using abilities and soldier orders? Does commanding soldiers feel good or tedious?

---

### Phase 3: Meta Loop (Week 3 - 40 hours)

**Goal:** Contract selection, company management, camp scenes

**Deliverables:**
- Contract board UI (select from 2-3 contracts)
- 3 contracts with different objectives and rewards
- Fort management screen (recruit soldiers, buy upgrades)
- Merchant (buy weapons/armor)
- Camp scene system (dialogue tree, loyalty changes)
- 3 camp scenes (1 per companion)
- Loyalty tracking and display

**Test:** Does choosing contracts feel meaningful? Do camp scenes create investment in companions?

---

### Phase 4: Polish & Playtest (Week 4 - 40 hours)

**Goal:** Complete playable prototype, gather feedback

**Deliverables:**
- Balance pass (damage numbers, HP values, costs)
- Bug fixes from internal testing
- Combat UI polish (turn indicator, ability tooltips)
- 2 choice moments with companion reactions
- Tutorial contract with guidance text
- End screen (show stats, loyalty changes)
- 3 external playtest sessions
- Feedback documentation

**Test:** Do playtesters understand the systems? What do they enjoy? What frustrates them?

---

## 7. SUCCESS METRICS

### Playtester Observations (Week 4)

**During Combat:**
- Do they use soldier orders? (Good: Changes orders 2-3 times per battle. Bad: Ignores soldiers, micromanages everyone)
- Do they use positioning? (Good: Flanks, uses cover. Bad: Blob all units together)
- Do they use abilities strategically? (Good: Saves heal for emergencies. Bad: Spams abilities randomly)
- Do battles feel too long? (Good: 5-8 minutes per battle. Bad: >15 minutes or <3 minutes)

**During Contract Selection:**
- Do they read contract descriptions? (Good: Deliberates. Bad: Picks first option)
- Do they consider tradeoffs? (Good: "I want X but need Y..." Bad: "Whatever")

**During Camp Scenes:**
- Do they engage with dialogue? (Good: Reads, considers choices. Bad: Skips everything)
- Do they notice loyalty changes? (Good: "Oh no, Matthias disapproved!" Bad: Doesn't notice)

**After Playthrough:**
- Ask: "What was the most fun part?" (Want: "The big battle" or "Choosing contracts")
- Ask: "What was frustrating?" (Want: Specific feedback, not "everything")
- Ask: "Would you play a full version?" (Want: "Yes" or "Yes if you fix X")
- Ask: "Did you care about the companions?" (Want: "Yes, especially [name]")

### Quantitative Targets

- **Completion rate:** 80%+ finish all 3 contracts (indicates pacing works)
- **Combat time:** 5-10 minutes per battle (indicates balance works)
- **Soldier order usage:** 2+ order changes per battle (indicates system is used)
- **Ability usage:** All 12 abilities used at least once (indicates variety works)
- **Camp engagement:** <10% skip rate on dialogue (indicates interest)

---

## 8. RISK MITIGATION

**Risk: Commanding soldiers feels like micromanagement**
- Mitigation: Orders system (not direct control), soldiers act autonomously within orders
- Fallback: Reduce soldier count to 2, simplify to "Attack" and "Defend" only

**Risk: Combat takes too long with 12+ units**
- Mitigation: Group soldier turns (all Infantry act together), speed up animations
- Fallback: Reduce grid size, reduce unit count, add "auto-resolve" option

**Risk: Grid combat feels sterile/boring**
- Mitigation: Environmental hazards, destructible cover, dramatic ability effects
- Fallback: Reduce to simpler combat (not grid-based), focus on story/choice

**Risk: Companion loyalty system feels arbitrary**
- Mitigation: Clear feedback on loyalty changes, dialogue explains companion values
- Fallback: Simplify to "approve/disapprove" binary, show companion reaction immediately

**Risk: Contract choices don't feel meaningful in short prototype**
- Mitigation: Make consequences immediate (gold difference, difficulty difference)
- Fallback: Add post-contract narration explaining "what would have happened if..."

**Risk: 4 weeks isn't enough time**
- Mitigation: Strict scope control, cut features if behind schedule
- Fallback: Extend to 6 weeks, cut Contract 3 if needed to ship

---

## 9. POST-PROTOTYPE DECISION TREE

### If Score 20-25 (Proceed to Full Production)

**Immediate Next Steps:**
- Expand to 15 contracts
- Add remaining 4 kingdoms
- Implement full progression (levels 3-10)
- Add remaining enemy types (15 more)
- Build complete companion quest arcs
- Add side quests (10)
- Implement save/load system

**Estimated Timeline to v1.0:** 8-10 months

### If Score 15-19 (Iterate)

**Identified Issues → Solutions:**
- Soldier command tedious → Simplify to 3 orders, auto-resolve minor battles
- Combat too slow → Reduce unit count, speed up animations, add difficulty options
- Companions uninteresting → More frequent camp scenes, clearer personality expression
- Contracts feel same → Add more variety (stealth, negotiation, defense objectives)

**Timeline:** 2-week iteration sprint, retest with 3 new playtesters, reassess

### If Score <15 (Pivot or Kill)

**Exit Criteria:**
- Core combat loop isn't fun (can't be fixed with iteration)
- Soldier system fundamentally doesn't work (players hate it)
- No emotional investment possible in 45-minute playthrough

**Pivot Options:**
- Remove soldier system, focus on 4-party tactical combat (simpler, proven)
- Change to real-time with pause instead of turn-based
- Shift focus to narrative/choice, simplify combat to support story

---

## 10. TECHNICAL NOTES

### Godot 4.x Implementation

**Scene Structure:**
```
Main.tscn
├── GameManager (autoload)
├── CombatScene
│   ├── Grid
│   ├── UnitManager
│   ├── TurnManager
│   └── CombatUI
├── CampScene
│   ├── DialogueManager
│   └── CampUI
└── ManagementScene
    ├── ContractBoard
    ├── FortUpgrades
    └── Merchant
```

**Key Systems:**
- Grid: TileMap or custom grid node
- Units: CharacterBody2D with stats resource
- Turn order: Array sorted by initiative
- Pathfinding: AStar2D
- Dialogue: JSON-based dialogue trees
- Combat: State machine (Idle → Selected → Moving → Acting → Done)

**Data Format:**
- Character stats: .tres Resource files
- Dialogue: JSON files
- Maps: TileMap scenes
- Contracts: JSON with dialogue + combat references

---

## 11. PROTOTYPE CONTRACT OUTLINES

### Contract 1: "Merchant's Escort" (Tutorial)

**Brief:** Escort a merchant wagon through bandit territory.

**Objectives:**
- PRIMARY: Reach the destination (merchant survives)
- SECONDARY: No soldier deaths

**Combat Encounter:**
- 4 Bandit Melee + 2 Bandit Archer
- Forest Clearing map
- Merchant wagon in center (must protect)

**Tutorial Elements:**
- Movement explained
- Attack explained
- Soldier orders introduced (simple: just "Hold" vs "Advance")
- Ability usage prompted

**Reward:** 300 gold

**Camp Scene After:** Meet Thorne, learn his cynicism about mercenary work

---

### Contract 2: "Clear the Ruins" (Full Combat Test)

**Brief:** Ironmark wants bandits cleared from ancient ruins near their border.

**Objectives:**
- PRIMARY: Defeat all enemies
- SECONDARY: Find the hidden cache (exploration reward)

**Combat Encounter:**
- 6 Bandit Melee + 3 Bandit Archer + 1 Bandit Leader
- Ruined Fort map
- Environmental hazards: Collapsible floor (DEX save or fall)

**Tactical Challenge:**
- Leader buffs other bandits
- Archers on high ground
- Must break formation or get overwhelmed

**Reward:** 500 gold + Steel Sword (if cache found: +200 gold)

**Camp Scene After:** Lyra reveals distrust of Ironmark, tests player loyalty

---

### Contract 3: "The Border Dispute" (Choice Test)

**Brief:** Both Ironmark and Thornwood refugees claim the same crossing. Ironmark hired you to "secure" it.

**Setup:**
- Arrive to find Thornwood refugees (women, children, elderly)
- Ironmark commander wants you to drive them off
- Refugees beg for mercy

**Choice Moment:**
- **Option A:** Follow contract - Drive off refugees (Ironmark +rep, gold, Matthias -20 loyalty)
- **Option B:** Refuse - Let refugees pass (Ironmark -rep, partial gold, Matthias +10 loyalty, Thorne approves)
- **Option C:** Negotiate - Convince commander to let refugees pass (CHA check, best outcome if success)

**Combat Encounter (if Option A):**
- 4 Refugee Defenders (low stats, fight desperately)
- Open Field map
- **Note:** These enemies don't drop loot, meant to feel bad

**Combat Encounter (if Option C fails):**
- 3 Ironmark Soldiers + 1 Ironmark Knight
- They attack you for insubordination
- Harder fight, but morally clear

**Reward:**
- Option A: 600 gold, +Ironmark
- Option B: 300 gold, -Ironmark, +companion loyalty
- Option C success: 500 gold, neutral Ironmark, +all companions

**Camp Scene After:** Group discusses what happened, companions reveal their values based on player choice

---

**END OF PROTOTYPE DESIGN DOCUMENT**

This prototype tests: **Can commanding a mercenary company in tactical grid combat be both strategic and emotionally engaging?** By Week 4, you'll know.
