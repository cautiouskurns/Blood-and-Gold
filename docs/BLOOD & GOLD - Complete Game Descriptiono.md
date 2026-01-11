# BLOOD & GOLD - Complete Game Design Document

**Tales from the Shattered Kingdoms - Episode 1**

---

## Executive Summary

**Genre:** Party-Based Tactical CRPG  
**Setting:** Dark Fantasy (Low Magic)  
**Playtime:** 15-18 hours  
**Platform:** PC (Steam), later Mac/Linux  
**Engine:** Godot 4.x  
**Target Audience:** CRPG fans (Baldur's Gate, Divinity, Pathfinder)  
**Development Time:** 8-10 months (solo/small team with AI assistance)  
**Price Point:** $12-15  

**Core Premise:**  
Found a mercenary company with 3 partners. Take 15 contracts over 60 days. Build your base, recruit soldiers, navigate war between five kingdoms. Choose which side to support in the final battle. Your decisions shape the political landscape and set up future games.

**Unique Selling Points:**
- Build mercenary company from nothing to legend
- Command NPC soldiers in large-scale tactical battles
- Meaningful choice: Pick which kingdom wins the war
- Interconnected world (references in future games)
- Classic CRPG power fantasy progression
- Companion loyalty system with permanent consequences

---

# WORLD BUILDING & LORE

## The Shattered Kingdoms - Foundation for All 5 Games

### **The Ancient Empire: "The Radiant Throne"** (Year 0-800)

**What It Was:**
- Unified empire spanning entire continent (500,000 sq miles)
- Capital: Luminar (now ruins in Ashenvale)
- Population: 12 million at peak
- Ruled by god-emperors wielding divine magic
- Golden age: Arts, magic, technology flourished
- Built: Massive roads, aqueducts, fortresses still standing

**The Fall (Year 800-803):**
- Emperor Solon IX attempted to ascend to godhood
- Ritual in Luminar required sacrifice of 100,000 citizens
- Ritual succeeded... partially
- Solon became something OTHER (not god, not mortal)
- Entity known as "The Hollow King" emerged
- Capital destroyed in cataclysm
- Empire fractured overnight

**The Shattering:**
- Five regions declared independence simultaneously
- Civil war lasted 3 years (800-803)
- Hollow King disappeared into Ashenvale ruins
- Each region crowned new rulers
- Became: The Five Kingdoms

**Current Era (Year 1212):**
- 409 years since the Fall
- Five kingdoms uneasy neighbors
- Ancient empire ruins dot landscape
- Magic faded but not gone
- Old roads still used
- Prophecies warn: "When kingdoms war, the Hollow King returns"

---

### **Geography: The Continent of Uthara**

```
                    NORTH
                      ↑
        
    ╔═══════════════════════════════════╗
    ║         IRONMARK (North)          ║
    ║    Mountains, Military, Honor     ║
    ╠═══════════╦═══════════════════════╣
    ║ THORNWOOD ║     ASHENVALE         ║
    ║  (West)   ║     (Center)          ║
    ║  Forests  ║   Ancient Ruins       ║
    ║  Druids   ║    Contested          ║
    ╠═══════════╬═══════════╦═══════════╣
    ║ SILVERMERE║ SUNSPIRE  ║           ║
    ║  (South)  ║  (East)   ║           ║
    ║  Coastal  ║  Deserts  ║           ║
    ║  Merchants║  Mages    ║           ║
    ╚═══════════╩═══════════╩═══════════╝
```

**Total Continent:** ~500,000 square miles (size of Alaska)

---

### **The Five Kingdoms - Detailed**

---

#### **1. IRONMARK (Northern Kingdom)**

**Geography:**
- Mountainous terrain (Iron Mountains)
- Cold climate, harsh winters
- Rich in iron ore, coal, timber
- Capital: Ironhaven (pop. 80,000)
- Total population: 2 million

**Culture:**
- Militaristic, honor-bound
- Strength = virtue
- Trial by combat legal tradition
- Clan-based society (12 great clans)
- Women fight equally (pragmatic necessity)

**Government:**
- Monarchy with military council
- Current ruler: King Aldric Ironhelm (age 52)
- Council of Wardens (12 clan leaders)
- Succession by combat if disputed

**Military:**
- Strongest standing army (40,000 professional soldiers)
- Heavy infantry, siege weapons
- Ironclad Knights (elite heavy cavalry)
- Every citizen serves 2 years mandatory

**Economy:**
- Exports: Iron, weapons, armor, mercenaries
- Imports: Food, luxury goods
- GDP: Medium-High (military industrial complex)

**Religion:**
- Worship **Valdyr the Unyielding** (war god)
- Temples double as training grounds
- Priests are also warriors
- Believe strength is divine gift

**Current Issues (Year 1212):**
- Succession crisis brewing (king aging, 3 sons rivalry)
- Noble corruption exposed (Game 1: Prison Break aftermath)
- Border disputes with Thornwood
- Expansionist faction wants to reunify empire by force

**Game 1 Role:** Major faction, many contracts available, final choice option

**Game 2 (Prison Break) Connection:** Set in Blackstone Keep, Ironmark prison

---

#### **2. SILVERMERE (Southern Kingdom)**

**Geography:**
- Coastal, temperate climate
- Natural harbors, trade routes
- Rolling hills, farmland
- Capital: Argentum (pop. 120,000) - largest city
- Total population: 3 million (most populous)

**Culture:**
- Merchant republic (pretends to be kingdom)
- Wealth = power
- Contract law sacred
- Cosmopolitan, diverse
- "Everything has a price"

**Government:**
- Constitutional monarchy (king is figurehead)
- Real power: Merchant Council (7 guild masters)
- Current "king": King Elden III (age 64, puppet)
- Council controls: Trade, law, military funding

**Military:**
- Small professional army (15,000)
- Large navy (200 ships)
- Relies on mercenaries (YOU)
- Economic warfare preferred

**Economy:**
- Wealthiest kingdom (controls sea trade)
- Exports: Spices, silk, wine, manufactured goods
- Imports: Raw materials
- GDP: Highest

**Religion:**
- Worship **Aurelia the Coin-Mother** (goddess of prosperity)
- Temples are also banks
- Tithing = investment
- "Profit is divine blessing"

**Current Issues (Year 1212):**
- Guild wars (internal power struggle)
- Pirates disrupting trade
- Other kingdoms resent economic dominance
- Secret: Funding all sides of conflicts for profit

**Game 1 Role:** Quest givers, quest targets, neutral zone, final choice option

**Game 4 (Political) Connection:** Set in Silvermere capital

---

#### **3. THORNWOOD (Western Kingdom)**

**Geography:**
- Dense ancient forests (Thornwood Forest covers 70%)
- Rivers, lakes abundant
- Mild climate, heavy rainfall
- Capital: Greenvale (pop. 40,000) - built INTO forest
- Total population: 1.5 million

**Culture:**
- Druidic, nature-focused
- Isolation preference
- Oral tradition (few written records)
- Communal living
- Suspicious of outsiders

**Government:**
- Druid Council (elder druids vote)
- Current Archdruid: Moira Oakenheart (age 78)
- No hereditary power
- Druids = judges, priests, leaders combined

**Military:**
- Small (10,000) but guerrilla warfare experts
- Rangers, scouts, archers
- Fight defensively (home terrain advantage)
- Use animal companions, nature magic

**Economy:**
- Subsistence + barter
- Exports: Herbs, medicines, rare woods, furs
- Imports: Metal goods, salt
- GDP: Lowest (but self-sufficient)

**Religion:**
- Worship **The Green Mother** (nature goddess)
- No temples (forest is temple)
- Animistic beliefs
- Sacred groves

**Current Issues (Year 1212):**
- Logging disputes with Ironmark
- Refugee crisis (fleeing other kingdoms)
- Young druids want to open borders
- Old druids resist modernization

**Game 1 Role:** Defensive contracts, moral complexity, final choice option

**Game 2 (Caravan) Connection:** Journey through Thornwood

---

#### **4. SUNSPIRE (Eastern Kingdom)**

**Geography:**
- Desert, oases, mesas
- Extreme temperatures (hot days, cold nights)
- Ancient magical ley lines visible
- Capital: Luminara (pop. 90,000) - tiered city
- Total population: 1.8 million

**Culture:**
- Academic, magical elite
- Knowledge = power
- Meritocracy (mages rule)
- Strict hierarchy (arcane rank)
- Art and philosophy valued

**Government:**
- Magocracy (council of 7 archmages)
- Current leader: Archmage Vayne (age 120+) 
- Mages Guild controls everything
- Non-mages = second-class citizens

**Military:**
- Small (12,000) but magically enhanced
- Battlemages, war golems, flying constructs
- Emphasize magical warfare
- Defensive wards on cities

**Economy:**
- Exports: Magical items, scrolls, education, consulting
- Imports: Food, water, everything else
- GDP: Medium (niche but valuable)

**Religion:**
- Worship **Nyx the Veiled** (goddess of knowledge and secrets)
- Temples are libraries
- Priests are scholars
- Some sects worship as mystery cult (dangerous)

**Current Issues (Year 1212):**
- Magical accident aftermath (Game 3 consequence)
- Eye of Nyx artifact containment crisis
- Non-mage rebellion brewing
- Experimenting with forbidden magic

**Game 1 Role:** Magical contracts, ethical dilemmas, final choice option

**Game 3 (Cult) Connection:** Set in Sunspire, cult worships Nyx

---

#### **5. ASHENVALE (Central Contested Territory)**

**Geography:**
- Ancient empire ruins
- Blasted wasteland around Luminar (capital ruins)
- Magical anomalies common
- No permanent settlements
- Total population: ~50,000 (transient)

**Status:**
- NOT a kingdom
- Claimed by all 5 kingdoms
- Actually controlled by none
- Dangerous, haunted
- Treasure hunters, exiles, bandits

**What's There:**
- Ruins of Luminar (ancient capital)
- The Hollow Throne (emperor's palace, intact but sealed)
- Ancient roads connecting kingdoms
- Magical artifacts buried
- The Hollow King (sleeping?)

**Dangers:**
- Undead (empire's fallen soldiers)
- Magical anomalies (reality tears)
- Bandits, deserters
- Aberrations (twisted creatures)
- The Hollow King's influence

**Current Issues (Year 1212):**
- Kingdoms fight over ruins
- Scavengers seeking artifacts
- Dark cults gathering
- Prophecy: "War awakens the sleeper"

**Game 1 Role:** Optional dangerous contracts, rare loot, foreshadowing

**Game 5 (Convergence) Connection:** Main setting, final battle location

---

### **Magic System (For All 5 Games)**

**Magic Level:** Low to Medium (magic exists but rare)

**Three Sources of Magic:**

#### **1. Divine Magic (Clerics, Paladins)**
- Granted by gods through faith
- Healing, protection, light
- Requires devotion, prayer
- Most common type
- **Limitation:** God can revoke power

**Available to:**
- Clerics (worship any god)
- Paladins (sworn oaths)
- Priests (NPCs mostly)

#### **2. Arcane Magic (Wizards, Sorcerers)**
- Studied from ancient texts
- Manipulation of reality
- Requires intelligence, discipline
- Destructive but difficult
- **Limitation:** Years of study required

**Available to:**
- Wizards (studied magic)
- Sorcerers (innate gift, rare)
- Battlemages (military mages)

#### **3. Primal Magic (Druids, Rangers)**
- Connection to nature
- Shapeshifting, animal companions, growth
- Requires harmony with nature
- Subtle, supportive
- **Limitation:** Can't use in cities/artificial areas

**Available to:**
- Druids (Thornwood)
- Rangers (scouts)
- Shamans (tribal)

**Magic Rules:**
- Spells have limited uses per day (rest to recover)
- No resurrection (death is permanent)
- Healing is slow (magical healing helps but not instant)
- Magic items are RARE (ancient empire artifacts)
- Most NPCs are NOT magical

---

### **Races & Peoples**

**Single Race: Humans**
- No elves, dwarves, orcs, etc.
- Humans only (simpler lore, easier to write)
- Regional variations (appearance, culture)

**Regional Characteristics:**

**Ironmark Humans:**
- Pale skin, dark hair
- Tall, broad (average 6'0")
- Hardy, resilient

**Silvermere Humans:**
- Diverse (trade hub, mixed ancestry)
- All skin tones, hair colors
- Average height (5'8")

**Thornwood Humans:**
- Tan skin, brown/red hair
- Wiry, agile (average 5'6")
- Nature-adapted

**Sunspire Humans:**
- Dark skin, dark hair
- Lean, tall (average 5'10")
- Desert-adapted

**Ashenvale Humans:**
- Pale, sickly (radiation from magic)
- Shorter lifespan
- Outcasts, desperate

---

### **Religion & The Pantheon**

**The Five Gods** (one per kingdom):

#### **1. Valdyr the Unyielding** (Ironmark)
- Domain: War, Honor, Strength
- Symbol: Iron fist
- Values: Courage, loyalty, victory
- Clerics: Warrior-priests
- **Actually:** War god, accepts any who fight honorably

#### **2. Aurelia the Coin-Mother** (Silvermere)
- Domain: Prosperity, Trade, Contracts
- Symbol: Golden scales
- Values: Wealth, fairness, ambition
- Clerics: Merchants who heal
- **Actually:** Goddess of civilization, order

#### **3. The Green Mother** (Thornwood)
- Domain: Nature, Growth, Cycles
- Symbol: Oak tree
- Values: Balance, harmony, patience
- Clerics: Druids
- **Actually:** Primordial nature spirit, not "good"

#### **4. Nyx the Veiled** (Sunspire)
- Domain: Knowledge, Secrets, Magic
- Symbol: Covered eye
- Values: Wisdom, curiosity, mystery
- Clerics: Scholar-priests
- **Actually:** Ambiguous entity, possibly dangerous
- **Note:** Game 3 cult worships twisted version

#### **5. The Hollow King** (Ashenvale/None)
- Domain: Death, Entropy, Endings
- Symbol: Empty throne
- Values: ???
- Clerics: None (cultists)
- **Actually:** Emperor Solon transformed, not truly a god
- **Note:** Main antagonist of Game 5

**Religious Tolerance:**
- Most kingdoms tolerate other faiths
- Except Hollow King worship (forbidden everywhere)
- Missionaries travel between kingdoms

---

### **Timeline of Critical Events**

**For reference across all 5 games:**

```
Year 0: Radiant Throne founded
Year 400: Empire at peak
Year 800: The Fall (Emperor Solon's ritual)
Year 803: Five Kingdoms declared
Year 900: Border wars (kingdoms stabilize)
Year 1000: Long peace begins

Year 1205: [GAME 2 - PRISON BREAK]
- Blackstone Keep scandal
- Warden Gareth exposed
- Ironmark destabilized

Year 1207: [GAME 3 - CARAVAN]
- Refugee crisis from Ironmark
- Thornwood isolationism debates
- First hints of cult activity

Year 1210: [GAME 4 - CULT]
- Eye of Nyx incident
- Sunspire magical disaster
- Cult infiltrated and exposed

Year 1212-1213: [GAME 1 - MERCENARY] ← THIS GAME
- War between kingdoms erupts
- Ancient tensions boil over
- Player chooses winner

Year 1215: [GAME 5 - CONVERGENCE]
- Consequences of war
- Hollow King awakens
- Heroes from all games unite

Year 1220: [BIG GAME]
- 5 years after Convergence
- World shaped by all previous events
- Epic conclusion
```

---

### **Current Political Situation (Year 1212)**

**Why War Breaks Out:**

**Immediate Causes:**
1. **Ironmark succession crisis** (Game 2 aftermath)
   - Three sons fighting for throne
   - Each builds army, tensions rise
   
2. **Sunspire disaster** (Game 3 aftermath)
   - Eye of Nyx containment failed
   - Magical radiation spreading
   - Other kingdoms demand Sunspire "fix it"
   
3. **Economic warfare** (Silvermere)
   - Blockades, tariffs, trade wars
   - Other kingdoms suffering
   
4. **Thornwood refugees** (Game 3 period)
   - Fleeing war, strain other kingdoms
   - Border conflicts

5. **Ashenvale artifact rush**
   - All kingdoms seeking ancient weapons
   - Skirmishes over ruins

**Factions:**

**Warmongers:** Ironmark expansionists, Silvermere profiteers
**Peacekeepers:** Thornwood druids, some Sunspire mages
**Opportunists:** Bandits, mercenaries, cults

**Your Role:**
- Mercenary company, technically neutral
- But everyone wants to hire you
- Eventually must choose side

---

### **The Prophecy** (Foreshadowing Game 5)

**Ancient text found in Luminar ruins:**

> *"When the kingdoms five clash with fury bright,*  
> *The sleeper wakes from ancient night.*  
> *The Hollow King shall rise from dust,*  
> *And all the world to ash reduce must.*  
> *Unless the Shattered find their way,*  
> *To stand as one and greet the day."*

**Interpretation:**
- "Kingdoms five clash" = This game's war
- "Sleeper wakes" = Hollow King returns
- "Shattered find their way" = Five heroes (one from each game) unite

**Nobody believes it... yet.**

---

# GAME OVERVIEW

## Core Pillars

**1. Build & Command**
- Grow mercenary company (4 → 20 members)
- Upgrade fortress base
- Command soldiers in battle

**2. Meaningful Choice**
- Contract selection (can't do everything)
- Faction reputation (make enemies)
- Companion loyalty (can lose them)
- War outcome (choose winning side)

**3. Tactical Combat**
- Grid-based battles
- Environmental tactics
- Party + NPC soldiers
- Large-scale encounters (20v40)

**4. Character Progression**
- Level 3 → 10
- Multiple builds viable
- Equipment matters
- Companion growth

**5. Interconnected World**
- Five kingdoms feel alive
- NPCs have agendas
- Choices have consequences
- Sets up future games

---

## Target Audience

**Primary:**
- CRPG fans (Baldur's Gate, Divinity, Pathfinder)
- Ages 25-45
- Enjoy tactical combat
- Value story/choice
- Play 10+ hours/week

**Secondary:**
- Tactics game fans (XCOM, Fire Emblem)
- Strategy RPG fans (Mount & Blade)
- Dark fantasy readers

**NOT targeting:**
- Casual mobile gamers
- Souls-like fans (different combat style)
- MMO players (solo experience)

---

## Unique Selling Points

1. **Build mercenary company** (underserved fantasy)
2. **Command NPC soldiers** (large-scale battles)
3. **Shape kingdom war** (kingmaker fantasy)
4. **Interconnected episodes** (anthology series)
5. **Companion permadeath** (real stakes)
6. **Classic CRPG depth** (indie price)

---

# NARRATIVE ARC

## Three-Act Structure

### **ACT 1: "Establishing the Company" (Contracts 1-5, Days 1-20)**

**Story Goal:** Build reputation, establish base

**Opening:**
- Founding scene: 4 companions meet in tavern
- Decide to found mercenary company
- Name it (player choice)
- Acquire ruined Fort Raven's Rest
- Take first contract

**Key Beats:**
1. **Tutorial Contract** (Escort merchant)
   - Learn combat, basics
   - Low stakes, easy success
   - Paid 200 gold

2. **First Real Challenge** (Clear goblins)
   - Harder fight
   - Environmental hazards
   - First loot drop

3. **Moral Choice** (Border skirmish)
   - Ironmark hires you
   - Defend against Thornwood "raiders"
   - BUT: Raiders are refugees
   - Choice: Follow orders OR let them flee
   - Consequence: Reputation shift

4. **Personal Stakes** (Deserter hunt)
   - Companion recognizes target
   - Thorne's former squadmate
   - Deserter pleads innocence
   - Choice: Turn him in OR help him escape
   - Thorne's loyalty tested

5. **Reputation Milestone** (Caravan defense)
   - Big pay contract (700g)
   - Multiple encounters
   - Success = noticed by kingdoms
   - **ACT 1 END:** "The Free Lances are making a name..."

**Act 1 Themes:**
- Building something from nothing
- Testing companion loyalties
- Establishing moral compass
- "What kind of company are we?"

**Companion Arcs (Act 1):**
- Thorne: Haunted by past atrocity (begin to explore)
- Lyra: Trust issues (slowly opening up)
- Matthias: Questioning faith (sees war's cost)
- Player: Define your character's values

---

### **ACT 2: "The War Begins" (Contracts 6-10, Days 21-40)**

**Story Goal:** Navigate escalating conflict, choose side

**Rising Tension:**
- Kingdoms openly at war
- Bigger contracts, higher stakes
- Companions disagree on which side to support
- Your fort gets attacked

**Key Beats:**
6. **The Siege** (Choose first faction)
   - Ironmark vs Thornwood major battle
   - MUST choose which side to fight for
   - Can't stay neutral anymore
   - Consequences: Other side now hostile
   - **This is the point of no return**

7. **Dark Contract** (Assassination)
   - Hired to kill enemy commander
   - Target is: Sleeping, defenseless, has family
   - Matthias REFUSES (faith crisis)
   - Choice: Do it (money, success) OR refuse (principle, lose pay)
   - Companion loyalty severely tested

8. **Sunspire Crisis** (Magical disaster)
   - Magical accident (callback to Game 3)
   - Fight corrupted elementals
   - Less pay but desperate need
   - Lyra's hometown affected
   - Emotional stakes

9. **Mercenary Rival** (PvP battle)
   - Rival company challenges you
   - "There's only room for one legendary company"
   - Tough tactical fight (intelligent enemies)
   - Can recruit survivors afterward

10. **Defense of Fort Raven** (Home defense)
    - Kingdom you opposed attacks YOUR base
    - Tower defense scenario
    - NPCs you recruited fight alongside you
    - If you lose: Operate from temporary camp
    - High emotional stakes (your soldiers die)
    - **ACT 2 END:** "This is war. Choose your side."

**Act 2 Themes:**
- Moral compromise (how far will you go?)
- Loyalty tested (companions may leave)
- No good choices (war is messy)
- "Can we stay honorable in dishonorable times?"

**Companion Arcs (Act 2):**
- Thorne: Confronts past commander (Contract 7 target)
- Lyra: Hometown threatened (Contract 8)
- Matthias: Faith crisis (refuses assassination)
- **Divergence point:** Companions may leave if loyalty too low

---

### **ACT 3: "The Final Campaign" (Contracts 11-15, Days 41-60)**

**Story Goal:** Support chosen kingdom, win war

**All-In:**
- Fully committed to one kingdom
- Other kingdoms hostile
- Building toward climax
- Companions reconcile (or are gone)

**Key Beats:**
11-14. **Kingdom-Specific Campaign** (4 contracts)
    - Unique missions per chosen kingdom
    - Building toward final battle
    - Relationships with commanders
    - Seeing war from chosen side

**Example: Ironmark Path**
- Contract 11: Assault Thornwood border
- Contract 12: Siege enemy fortress
- Contract 13: Capture enemy general
- Contract 14: Defend capital from counterattack

**Example: Thornwood Path**
- Contract 11: Guerrilla raid supply lines
- Contract 12: Defend sacred grove
- Contract 13: Rally scattered forces
- Contract 14: Protect Archdruid from assassination

15. **The Deciding Battle** (Finale)
    - Massive battle (your 20 vs 40+ enemies)
    - Multi-phase encounter
    - Companion abilities matter
    - Environmental destruction
    - Boss fight: Enemy kingdom's champion
    - Victory: Your kingdom wins war

**Climax:**
- Epic battle
- Everything you've built matters
- Soldiers you trained fight
- Companions you kept help
- Equipment you bought saves you
- **All decisions culminate**

**Resolution:**
- Peace treaty signed
- Your company legendary
- Kingdom grateful
- Personal epilogues

**But...**
- Post-credit scene: Ashenvale glows
- Ancient evil stirring
- **Setup for Game 5**

**Act 3 Themes:**
- Commitment (living with choices)
- Brotherhood (companions as family)
- Legacy (what did we build?)
- "Was it worth it?"

**Companion Arcs (Act 3):**
- Thorne: Redemption OR acceptance
- Lyra: Learns to trust (found family)
- Matthias: Restored faith OR new purpose
- **Resolution based on loyalty**

---

## Character Arcs (Detailed)

### **Captain Thorne Blackwood** (Fighter)

**Starting Point:**
- Cynical veteran, "war is business"
- Haunted by past atrocity
- Drinks to forget
- Pushes people away

**The Past (Revealed Over Time):**
- 15 years ago: Ironmark-Thornwood border war
- Thorne commanded unit
- Ordered to massacre Thornwood village (suspected rebel base)
- Followed orders
- Village was innocent (women, children, elders)
- Haunted by screams
- Deserted, became mercenary

**Arc Path A: Redemption**
- If player shows compassion
- If Thorne confronts past
- If mercy shown to enemies
- **Outcome:** Finds peace, leads honorably, retires to teach

**Arc Path B: Embrace Darkness**
- If player shows ruthlessness
- If Thorne buries guilt
- If pragmatic always
- **Outcome:** Becomes cold killer, wealthy but hollow

**Arc Path C: Departure**
- If loyalty too low
- If player contradicts his values too much
- **Outcome:** Leaves company mid-game, player must continue without him

**Key Moments:**
- Contract 7: Assassination target is his former commander
- Contract 10: Fort defense (shows he cares about company)
- Contract 13: Captured prisoner is survivor from massacre village
- Ending: Speech to company reflecting his journey

---

### **Lyra Swiftblade** (Rogue)

**Starting Point:**
- Sarcastic, guarded
- Trust nobody
- In it for money
- Hides emotions

**The Past:**
- Thornwood ranger, best unit
- Commander sold out her team to bandits
- Everyone died except her
- Survived 3 days alone, hunted
- Killed commander in revenge
- Now fugitive from Thornwood

**Arc Path A: Trust Restored**
- If player shows loyalty
- If player keeps promises
- If company becomes family
- **Outcome:** Finds home, settles down, leads ranger school

**Arc Path B: Lone Wolf**
- If player betrays trust
- If player unreliable
- **Outcome:** Takes her share, leaves before finale

**Key Moments:**
- Contract 3: Sees Thornwood refugees (flashback)
- Contract 8: Hometown affected by magical disaster
- Contract 12: Former commander's brother appears (wants revenge on her)
- Ending: Decides if this company is home

---

### **Brother Matthias** (Cleric)

**Starting Point:**
- Former priest, crisis of faith
- Drinks heavily
- Bitter, weary
- Still prays (habit)

**The Past:**
- Priest in Silvermere
- Discovered church leadership corrupt
- Embezzling donations, fake relics
- Tried to expose them
- Church expelled him as heretic
- Lost everything
- Faith shaken but not destroyed

**Arc Path A: Restored Faith**
- If player shows compassion
- If mercy chosen
- If innocents protected
- **Outcome:** Returns to priesthood, reforms church, becomes saint

**Arc Path B: New Purpose**
- If player pragmatic but fair
- If violence unavoidable
- **Outcome:** Faith in people, not gods; company chaplain

**Arc Path C: Lost Faith**
- If player cruel
- If innocents killed
- **Outcome:** Becomes cynical mercenary, "gods are lies"

**Key Moments:**
- Contract 7: REFUSES assassination (moral line)
- Contract 10: Prays during fort defense (reveals he still believes)
- Contract 12: Church sends assassins after him
- Ending: Decides what he believes

---

### **Player Character** (Customizable)

**5 Background Options:**

**1. Disgraced Noble** (Ironmark)
- Family implicated in Game 2 scandal
- Seeking redemption/wealth/revenge
- Start: +10 Ironmark reputation
- Bonus: +2 CHA, +1 Leadership skill

**2. Thornwood Exile**
- Disagreed with druid council isolation
- Wanted to help refugees
- Exiled for defiance
- Start: +10 Thornwood reputation
- Bonus: +2 WIS, +1 Survival skill

**3. Cult Survivor** (Sunspire)
- Escaped after Game 3 events
- Seeking purpose/penance
- Traumatized by experience
- Start: +10 Sunspire reputation
- Bonus: +2 INT, +1 Arcana skill

**4. Sellsword Veteran**
- Professional mercenary for years
- Purely business
- Wants legendary company
- Start: Neutral all kingdoms
- Bonus: +2 STR, +1 Combat skill

**5. Idealistic Knight**
- Believes mercenaries can be heroes
- Wants to prove it
- Naive but determined
- Start: +5 all kingdoms
- Bonus: +2 CON, +1 Diplomacy skill

**Player Arc:**
- Defined by choices
- No fixed path
- Companions react to player's decisions
- Ending reflects values shown

---

## Branching Narrative

**Major Decision Points:**

**1. Contract 6 - The Siege**
- Choose: Ironmark OR Thornwood
- Locks out opposite kingdom
- Affects available contracts 11-15

**2. Contract 7 - Assassination**
- Choice: Accept, refuse, or sabotage
- Affects Matthias loyalty
- Affects reputation

**3. Contract 10 - Fort Defense**
- Success/failure affects Act 3
- Loss = harder missions, temporary base

**4. Contracts 11-14 - Kingdom Path**
- Different missions per kingdom
- 4 unique paths (Ironmark/Thornwood/Silvermere/Sunspire)

**5. Companion Loyalty**
- Throughout game
- Can lose companions permanently
- Affects finale difficulty

**6. Final Battle**
- Multiple outcomes based on:
  - Which kingdom supported
  - Companion loyalty
  - Reputation
  - Fort status

---

## Endings (16 Major Variants)

**Based on:**
1. Kingdom supported (4 options)
2. Companion loyalty (all/some/none)
3. Reputation (heroic/pragmatic/ruthless)
4. Fort status (upgraded/defended/lost)

**Sample Endings:**

**Ending 1: "The King's Own"** (Ironmark, all companions, heroic)
- Ironmark wins, unifies through strength
- Company becomes royal guard
- Thorne redeemed, Lyra trusted, Matthias faithful
- But: Other kingdoms resentful, rebellion brewing

**Ending 2: "The Free Company"** (Thornwood, mixed companions)
- Thornwood independent, guerrilla victory
- Company famous but fractured
- Thorne left, Lyra stayed, Matthias conflicted
- Pyrrhic victory

**Ending 3: "The Mercenary Kings"** (Silvermere, no companions, ruthless)
- Economic victory, merchant republic
- Wealthy but alone
- All companions left in disgust
- Hollow victory

**Ending 4: "The Last Stand"** (Any kingdom, fort lost, heroic)
- Victory but at terrible cost
- Half your soldiers dead
- Fort destroyed
- But: Saved kingdom, legendary sacrifice

**All endings:**
- Personal epilogues for each companion (if loyal)
- Narrator describes kingdom's fate
- Company's legend spreads
- Post-credit: Ashenvale glows (setup Game 5)
- **"Your choices will echo through the Shattered Kingdoms..."**

---

# CORE SYSTEMS

## 1. Character Progression System

### **Level Progression**

**Starting Level:** 3 (competent but not masters)  
**Maximum Level:** 10 (legendary)  
**XP Curve:** 500 XP per level

**XP Sources:**
- Combat encounters: 100-500 XP (based on difficulty)
- Quest completion: 200-800 XP
- Skill checks (success): 50 XP
- Discovering locations: 100 XP
- Companion loyalty milestones: 100 XP

**Level Up Gains:**
- +2 Stat Points (allocate freely)
- +1 Skill Point (improve skills)
- +5% HP
- +1 Ability Point (every 2 levels)

---

### **Stats (6 Core)**

**Strength (STR):**
- Melee damage (+1 damage per 2 STR)
- Carry capacity (+10 lbs per STR)
- Athletics checks
- Intimidation

**Dexterity (DEX):**
- Ranged damage (+1 damage per 2 DEX)
- Dodge chance (+1% per DEX)
- Initiative (+1 per 2 DEX)
- Stealth, Lockpicking

**Constitution (CON):**
- HP (+5 HP per CON)
- Physical resistance
- Endurance checks
- Resist disease/poison

**Intelligence (INT):**
- Spell damage (mages)
- Skill points (+1 per 2 INT)
- Crafting quality
- Investigation, Arcana

**Wisdom (WIS):**
- Spell power (clerics)
- Perception checks
- Insight (detect lies)
- Willpower saves

**Charisma (CHA):**
- Persuasion/Deception
- Leadership (NPC morale)
- Merchant prices (±5% per CHA)
- Companion loyalty gain rate

**Stat Ranges:**
- 8-10: Average human
- 11-14: Above average
- 15-17: Exceptional
- 18-20: Peak human
- 21+: Legendary (requires items)

---

### **Skills (12 Core)**

**Combat Skills:**
- **Melee Combat:** Hit chance, damage (STR)
- **Ranged Combat:** Hit chance, damage (DEX)
- **Defense:** Dodge, block (DEX/CON)

**Physical Skills:**
- **Athletics:** Climb, swim, jump (STR)
- **Stealth:** Sneak, hide (DEX)
- **Survival:** Track, forage (WIS)

**Knowledge Skills:**
- **Arcana:** Magic knowledge (INT)
- **History:** Lore, kingdoms (INT)
- **Medicine:** Heal, diagnose (WIS)

**Social Skills:**
- **Persuasion:** Convince, charm (CHA)
- **Intimidation:** Threaten, scare (STR/CHA)
- **Insight:** Read people (WIS)

**Skill Ranks:**
- 0: Untrained (-2 penalty)
- 1-3: Novice
- 4-6: Proficient
- 7-9: Expert
- 10+: Master

**Skill Checks:**
```
Roll = d20 + Stat Modifier + Skill Rank
Success if: Roll >= Difficulty

Difficulty ranges:
Easy: 10
Medium: 15
Hard: 20
Very Hard: 25
Nearly Impossible: 30
```

---

### **Abilities (Class-Based)**

**Each class has 3 ability trees, 4 abilities per tree = 12 total**

**Fighter Example:**
- **Weapon Master Tree:** Cleave, Whirlwind, Execute, Bladestorm
- **Defender Tree:** Shield Bash, Taunt, Last Stand, Fortress
- **Tactician Tree:** Rally, Battle Shout, Commandeer, Warlord

**Mage Example:**
- **Destruction Tree:** Fireball, Lightning, Meteor, Annihilation
- **Control Tree:** Slow, Stun, Freeze, Time Stop
- **Support Tree:** Shield, Haste, Teleport, Mass Buff

**Cleric Example:**
- **Healing Tree:** Heal, Mass Heal, Resurrection (unconscious only), Divine Shield
- **Smite Tree:** Holy Strike, Turn Undead, Divine Wrath, Judgment
- **Support Tree:** Bless, Protection, Inspire, Sanctuary

**Rogue Example:**
- **Assassination Tree:** Backstab, Poison, Shadowstep, Execute
- **Utility Tree:** Lockpick, Disarm Trap, Sleight of Hand, Invisibility
- **Combat Tree:** Dual Wield, Riposte, Evasion, Bladedance

**Ability Points:**
- Gain 1 per 2 levels (total: 4 by level 10)
- Can spread across trees OR specialize
- Abilities scale with level

---

## 2. Combat System

### **Core Combat Loop**

**Turn-Based Tactical:**
- Grid-based (hex or square)
- Initiative order (DEX-based)
- Move + Action per turn
- Environmental interaction

---

### **Grid Layout**

**Typical Battle:**
```
Enemy Side (6-12 units)
[E] [E] [E] [E]
[E] [E] [E] [E]
    [E] [E]

Neutral Zone (terrain)
[🌳][🪨][🌳][💧]

Your Side (4 party + 4-8 soldiers)
[S] [Thorne] [You] [S]
[S] [Lyra] [Matthias] [S]
```

**Grid Size:** 12x12 typical (144 tiles)

---

### **Turn Structure**

**Phase 1: Initiative Roll**
```
All units roll: d20 + DEX modifier
Highest goes first
Ties: Player units win
```

**Phase 2: Turn Sequence**
```
On your turn:
1. Move (up to movement speed)
2. Action (attack, ability, item)
3. Bonus Action (if available)
4. End Turn
```

**Phase 3: Reactions**
```
Triggered during enemy turns:
- Attacks of Opportunity (if enemy moves away)
- Counter-attack (if ability equipped)
- Block/Dodge (if defending)
```

---

### **Movement**

**Movement Speed:**
- Light armor: 6 tiles
- Medium armor: 5 tiles
- Heavy armor: 4 tiles
- Difficult terrain: Half speed

**Movement Rules:**
- Can move before OR after action
- Can't split movement (must move all at once)
- Diagonal costs 1.5 tiles
- Leaving threatened tile = attack of opportunity

---

### **Actions**

**Standard Actions:**

**1. Attack (Melee)**
```
To Hit Roll: d20 + STR + Melee Skill vs Enemy Defense
If Hit: Weapon Damage + STR modifier
Critical (natural 20): Double damage
Miss (natural 1): No damage, lose balance (enemy advantage next turn)
```

**2. Attack (Ranged)**
```
To Hit Roll: d20 + DEX + Ranged Skill vs Enemy Defense
Range: 8 tiles (short), 12 tiles (long, disadvantage)
If Hit: Weapon Damage + DEX modifier
Cover: -2 to hit if enemy in cover
```

**3. Use Ability**
```
Cast spell or use special ability
Costs: Ability point (limited uses)
Effects: Varies per ability
```

**4. Use Item**
```
Potion: Drink (heal, buff)
Throw: Grenade, oil flask (AoE)
Tool: Rope, lockpick (situational)
```

**5. Defend**
```
Until next turn:
+4 to Defense
-2 to Initiative next round
```

**6. Help**
```
Aid adjacent ally:
They get +2 on next action
You use full turn
```

---

### **Bonus Actions**

**Available if:**
- Specific ability grants it
- Class feature (Rogue: Hide as bonus action)
- Item (quickdraw potion)

**Examples:**
- Rogue: Hide after attacking
- Fighter: Second Wind (self-heal)
- Mage: Cantrip (minor spell)

---

### **Combat Mechanics**

**Attack Resolution:**
```
Attacker rolls: d20 + Attack Bonus
Defender has: Defense Value (10 + DEX + Armor)

If Attack Roll >= Defense: Hit
Damage: Weapon Die + Stat Modifier
```

**Example:**
```
Thorne attacks bandit:
Roll: d20 (rolled 14) + STR (4) + Melee Skill (3) = 21
Bandit Defense: 10 + DEX (2) + Armor (3) = 15
21 >= 15: HIT

Damage: Longsword (d8) rolled 6 + STR (4) = 10 damage
Bandit had 18 HP, now has 8 HP
```

---

### **Damage Types**

**Physical:**
- Slashing (swords, axes)
- Piercing (spears, arrows)
- Bludgeoning (maces, hammers)

**Magical:**
- Fire (burn, area denial)
- Ice (slow, freeze)
- Lightning (chain, stun)
- Holy (undead bonus)
- Necrotic (life drain)

**Resistances:**
- Heavy armor: -3 to slashing/piercing
- Shields: -2 to all physical
- Magic resistance: -50% to magic damage (rare)

---

### **Status Effects**

**Buffs:**
- Blessed: +2 to all rolls (3 turns)
- Hasted: +2 movement, +1 action (2 turns)
- Shielded: +5 to Defense (until hit)
- Inspired: +4 to next attack (1 turn)

**Debuffs:**
- Bleeding: 2 damage/turn (until healed)
- Poisoned: -2 to attacks (3 turns)
- Stunned: Skip turn (1 turn)
- Slowed: Half movement (2 turns)
- Feared: Move away from source (2 turns)

---

### **Environmental Tactics**

**Terrain Features:**

**High Ground:**
- +2 to ranged attacks
- +1 to Defense
- Advantage on sight checks

**Cover:**
- Half cover: +2 Defense
- Full cover: Can't be targeted (ranged)
- Destructible: Some cover breaks

**Hazards:**
- Fire: 5 damage/turn if standing in it
- Water: Half movement, soaked (lightning vulnerability)
- Oil: Flammable, slippery (DEX save or fall)
- Ice: Slippery (DEX save or fall)

**Interactables:**
- Barrels: Push onto enemies (STR check, 2d6 damage)
- Chandeliers: Drop on enemies (chain, 3d6 damage, AoE)
- Bridges: Collapse (strand enemies)
- Doors: Close to funnel enemies

---

### **Party + Soldiers Combat**

**Large Battles (8+ allies):**

**Direct Control:**
- 4 party members (you control fully)

**Orders System:**
- NPC soldiers follow orders:
  - **Advance:** Move forward, attack nearest enemy
  - **Hold Line:** Stay in position, defend
  - **Focus Fire:** All attack same target
  - **Retreat:** Fall back to safe position
  - **Protect:** Guard specific party member

**Soldier AI:**
- Follows orders until new order given
- Reacts to threats (won't ignore being attacked)
- Morale matters (low morale = flee)

**Example Battle:**
```
Your 8 units vs 12 enemies

Setup:
[4 Soldiers] "Hold Line" (front)
[Thorne] [Lyra] [You] [Matthias] (back)

Turn 1:
- Soldiers engage front enemies (4v6)
- You give order: "Focus Fire on Mage"
- Lyra + Matthias target mage
- Thorne supports soldiers

Soldiers handle front, you handle priority targets
```

---

### **Victory/Defeat Conditions**

**Victory:**
- All enemies dead/fled OR
- Objective completed (varies by mission)

**Defeat:**
- All party members unconscious OR
- Objective failed (VIP died, timer expired)

**Retreat Option:**
- Can flee mid-battle (if losing)
- Must reach map edge
- Enemies pursue
- Lose loot, fail quest

---

### **Injuries & Death**

**Unconscious (0 HP):**
- Fall unconscious
- 3 turns to stabilize (someone must heal)
- If not stabilized: Death

**Death:**
- Companions: PERMADEATH (gone forever)
- Soldiers: Permadeath (recruit new ones)
- Party wipe: Game Over (reload save)

**Stabilization:**
- Medicine check (WIS + Medicine skill)
- Healing spell (instant)
- Healing potion (if someone gives it)

---

## 3. Equipment & Loot System

### **Equipment Slots**

**Per Character:**
- Weapon (main hand)
- Offhand (shield, second weapon, or empty)
- Armor (chest)
- Helmet (head)
- Gloves (hands)
- Boots (feet)
- Amulet (neck)
- Ring 1 (finger)
- Ring 2 (finger)

**Total: 9 slots**

---

### **Weapon Types**

**Melee Weapons:**

| Weapon | Damage | Type | Properties |
|--------|--------|------|------------|
| Dagger | 1d4 | Piercing | Light, throwable |
| Shortsword | 1d6 | Slashing | Light, versatile |
| Longsword | 1d8 | Slashing | Standard |
| Greatsword | 2d6 | Slashing | Two-handed, slow |
| Mace | 1d6 | Bludgeoning | Standard |
| Warhammer | 1d10 | Bludgeoning | Two-handed |
| Spear | 1d6 | Piercing | Reach (2 tiles) |
| Axe | 1d8 | Slashing | High crit (x3) |

**Ranged Weapons:**

| Weapon | Damage | Range | Properties |
|--------|--------|-------|------------|
| Shortbow | 1d6 | 8 tiles | Standard |
| Longbow | 1d8 | 12 tiles | Two-handed |
| Crossbow | 1d10 | 10 tiles | Reload, powerful |
| Throwing Knife | 1d4 | 6 tiles | Light, reusable |

**Magic Weapons:**
- Staff | 1d6 | Two-handed | +2 to spell damage
- Wand | 1d4 | One-handed | +1 to spell accuracy

---

### **Armor Types**

**Light Armor:**
| Armor | Defense | Movement | Properties |
|-------|---------|----------|------------|
| Cloth | +1 | 6 tiles | Mage only |
| Leather | +2 | 6 tiles | Standard |
| Studded Leather | +3 | 6 tiles | Best light |

**Medium Armor:**
| Armor | Defense | Movement | Properties |
|-------|---------|----------|------------|
| Hide | +3 | 5 tiles | Cheap |
| Chain Shirt | +4 | 5 tiles | Standard |
| Scale Mail | +5 | 5 tiles | Best medium |

**Heavy Armor:**
| Armor | Defense | Movement | Properties |
|-------|---------|----------|------------|
| Chain Mail | +5 | 4 tiles | Entry heavy |
| Splint | +6 | 4 tiles | Standard |
| Plate Armor | +8 | 4 tiles | Best armor |

**Shields:**
- Buckler: +1 Defense, keep offhand free
- Shield: +2 Defense, blocks offhand
- Tower Shield: +3 Defense, -1 movement

---

### **Equipment Progression Curve**

**Early Game (Level 3-5):**
```
Weapons: Iron equipment
- Iron Sword: 1d8
- Iron Armor: +3 Defense
- Cost: 50-100 gold
```

**Mid Game (Level 6-8):**
```
Weapons: Steel equipment
- Steel Sword: 1d8+1
- Steel Armor: +5 Defense
- Cost: 200-400 gold
- Special: Some have minor enchantments
```

**Late Game (Level 9-10):**
```
Weapons: Enchanted equipment
- Flaming Sword: 1d8+2, +1d6 fire
- Plate Armor +1: +9 Defense
- Cost: 800-1500 gold OR quest reward
- Special: Unique effects
```

**Legendary (Rare Drops):**
```
Ancient Empire artifacts:
- Radiant Blade: 2d6+2, heals wielder
- Emperor's Plate: +10 Defense, immunity fear
- Unique effects, one-of-a-kind
```

---

### **Loot Sources**

**1. Enemy Drops:**
- Bandits: 5-20 gold, leather armor, iron weapons
- Knights: 50-100 gold, steel armor, potions
- Mages: 20-50 gold, scrolls, magic items
- Bosses: 200-500 gold, unique items

**2. Chests/Containers:**
- Common: 10-30 gold, consumables
- Uncommon: 50-100 gold, weapons/armor
- Rare: 200+ gold, enchanted items

**3. Quest Rewards:**
- Gold (contract payment)
- Equipment (specific to quest)
- Unique items (one-time rewards)

**4. Merchants:**
- Buy/sell (prices vary by CHA)
- Inventory refreshes every 5 days
- Better merchants in capital cities

**5. Crafting:**
- Blacksmith (upgrade weapons)
- Leatherworker (upgrade armor)
- Alchemist (craft potions)

---

### **Consumables**

**Potions:**
- Minor Healing: +2d4+2 HP (30g)
- Healing: +4d4+4 HP (60g)
- Greater Healing: +8d4+8 HP (120g)
- Antidote: Cure poison (40g)
- Buff: +2 to stat for 3 turns (50g)

**Scrolls:**
- Cast spell once (varies by spell)
- Usable by anyone
- Cost: 50-200g

**Grenades:**
- Alchemist's Fire: 2d6 fire, AoE (50g)
- Acid Flask: 2d4 acid, armor reduction (40g)
- Smoke Bomb: Obscures vision (30g)

**Food:**
- Rations: Required for travel (5g/day)
- Feast: +10% HP for next battle (20g)

---

### **Magic Items (Rare)**

**Found in:**
- Ancient ruins (Ashenvale)
- Boss drops
- Quest rewards
- Rare merchant stock

**Examples:**

**Ring of Protection:**
- +1 to Defense
- Passive effect
- Value: 500g

**Boots of Speed:**
- +1 movement
- Ignore difficult terrain
- Value: 800g

**Amulet of Health:**
- +2 CON
- +10 HP
- Value: 1000g

**Cloak of Resistance:**
- +2 to all saves
- Value: 1200g

**Flaming Sword:**
- 1d8+1 slashing, +1d6 fire
- Light source
- Value: 1500g

---

### **Crafting System**

**Blacksmith (Fort Raven):**
- Upgrade weapons: +1 damage (200g + materials)
- Repair equipment: 50g
- Craft arrows: 10g per 20

**Alchemist (Town):**
- Brew potions: Cost varies
- Requires: Herbs (foraged or bought)
- Time: 1 day

**Enchanter (Sunspire only):**
- Add enchantment to weapon/armor
- Requires: Magic essence + 500g
- Time: 3 days
- Random effect OR specific (costs more)

---

## 4. Quest System

### **Quest Types**

**1. Main Quests (15 Contracts):**
- Given by kingdoms/leaders
- Advance story
- Fixed structure
- Combat-heavy
- High rewards

**2. Side Quests (10 Optional):**
- Given by NPCs
- Character development
- Flexible approach
- Mix of combat/social
- Unique rewards

**3. Companion Quests (3 per companion):**
- Personal to companion
- Affect loyalty
- Story-focused
- Unlock abilities/items

---

### **Quest Structure**

**Phase 1: Acceptance**
```
Quest Giver: Presents problem
Player: Accept OR Refuse
If Accept: Quest added to log
Quest Log: Tracks objectives
```

**Phase 2: Execution**
```
Objectives:
- Primary: Must complete
- Secondary: Optional (bonus reward)

Example Contract:
PRIMARY: Escort caravan to Ironhaven
SECONDARY: Protect all merchants (no deaths)
SECONDARY: Deliver within 3 days (speed bonus)
```

**Phase 3: Completion**
```
Return to quest giver:
- Report success/failure
- Receive rewards
- Gain reputation
- Unlock follow-up quests
```

---

### **Quest Log UI**

```
════════════════════════
QUEST LOG
════════════════════════

MAIN QUESTS:
☑ Contract 1: Merchant's Escort (Complete)
☑ Contract 2: Goblin Infestation (Complete)
► Contract 3: Border Skirmish (Active)
  └─ Objective: Defend Fort Threshold
  └─ Optional: Minimize civilian casualties

SIDE QUESTS:
► The Blacksmith's Favor
  └─ Find Gregor's stolen tools
  └─ Location: Bandit camp, 5 miles north

COMPANION QUESTS:
► Thorne's Past (Active)
  └─ Investigate Thorne's former commander
  └─ Next step: Talk to Thorne at camp
```

---

### **Contract Structure (15 Main Quests)**

Each contract has:

**1. Brief:**
- Quest giver introduction
- Problem explanation
- Proposed payment
- Accept/refuse choice

**2. Preparation:**
- Optional: Gather intel, buy supplies, recruit soldiers
- Time passes (1-2 days)

**3. Mission:**
- Travel to location
- Complete objectives
- Combat encounters
- Choices/consequences

**4. Resolution:**
- Return to quest giver
- Report outcome
- Receive payment
- Reputation changes
- Story consequences

**5. Aftermath:**
- Camp scene (companions react)
- Time passes (1-3 days)
- Prepare for next contract

---

### **Side Quest Examples**

**"The Blacksmith's Favor"**
```
Giver: Gregor (civilian in caravan)
Problem: Tools stolen by bandits
Objectives:
- Find bandit camp
- Retrieve tools (can buy, steal, or fight)
- Return tools to Gregor

Rewards:
- 100 gold
- Gregor crafts weapon for free
- Gregor joins as company blacksmith (if offered)
```

**"The Healer's Dilemma"**
```
Giver: Healer in Silvermere
Problem: Rare herb needed, grows in dangerous area
Objectives:
- Travel to Thornwood swamp
- Harvest Moon Lily (guarded by monsters)
- Return within 5 days (patient dying)

Rewards:
- 150 gold
- Healer gives discount potions forever
- Medicine skill +1
- Companion: Matthias approves
```

**"The Deserter's Plea"**
```
Giver: Deserter (random encounter)
Problem: Wrongly accused, hunted by kingdom
Objectives:
- Help escape OR turn him in
- If help: Find evidence of innocence
- If turn in: Escort to authorities

Rewards (Help):
- Deserter's sword (unique item)
- +10 with rebels
- Companion: Thorne remembers this

Rewards (Turn In):
- 200 gold bounty
- +10 with Ironmark
- Companion: Matthias disapproves
```

---

## 5. Company Management System

### **Fort Raven's Rest (Your Base)**

**Starting State:**
- Ruined fortress
- No amenities
- 4 members
- 100 gold

**Upgrade Tree:**

**Tier 1 (Early Game):**
```
Barracks (500g):
- House 5 more soldiers (capacity: 9 total)
- Soldiers heal faster

Armory (800g):
- Store equipment
- Better gear available from merchant
- Repair station (50% cost)

Training Yard (600g):
- Soldiers gain XP 50% faster
- Practice duels (companions train)
- +1 to all combat skills for company
```

**Tier 2 (Mid Game):**
```
Infirmary (400g):
- Heal injuries faster (1 day vs 3 days)
- Free healing (no potion costs)
- Resurrect unconscious companions (normally lost)

War Room (700g):
- See contract details before accepting
- Plan missions (bonus to first battle)
- Strategy meetings (NPC suggestions)

Tavern (300g):
- Recruit better soldiers
- Morale boost (+10%)
- Companions socialize (loyalty gain)
```

**Tier 3 (Late Game):**
```
Walls (1000g):
- Defend against raids
- +5 Defense in Fort Defense mission
- Intimidation factor (enemies less likely to attack)

Stables (500g):
- Travel 50% faster between contracts
- Mounted combat options
- Horse care (mounts don't die)

Vault (600g):
- Store 10,000g safely (no theft risk)
- Hide contraband
- Secret passage (escape route)
```

**Total Cost (All Upgrades):** 5,600 gold

---

### **Soldier Recruitment**

**Hiring:**
- Available at: Tavern (your fort), Taverns (cities)
- Cost: 50-300g depending on type/level
- Capacity: 4 (starting) + 5 per Barracks upgrade (max 20)

**Soldier Types:**

**Infantry** (50g):
- Melee fighters, frontline
- HP: Medium, Damage: Medium
- Equipment: Sword + shield

**Archers** (100g):
- Ranged support, backline
- HP: Low, Damage: Medium
- Equipment: Bow + leather armor

**Cavalry** (200g):
- Mobile, flanking
- HP: Medium, Damage: High
- Equipment: Lance + horse
- Can't enter buildings

**Mages** (300g):
- Spell support, AoE
- HP: Low, Damage: High (AoE)
- Equipment: Staff

**Healers** (250g):
- Support, heal allies
- HP: Low, Utility: High
- Equipment: Staff + robes

---

### **Soldier Management**

**Stats:**
- Level: 1-5 (gain XP from battles)
- HP: Varies by type
- Morale: 0-100%

**Morale System:**
- **High Morale (80-100%):** +10% damage, won't flee
- **Medium Morale (50-79%):** Normal performance
- **Low Morale (20-49%):** -10% damage, might flee if losing
- **Broken Morale (0-19%):** Will flee, refuse to fight

**Morale Factors:**
- Victory: +10%
- Defeat: -20%
- Soldier dies: -5% (all soldiers)
- Paid on time: +5%
- Good equipment: +5%
- Tavern built: +10%
- Player reputation: +1% per 10 reputation

---

### **Company Finances**

**Income:**
- Contracts: 200-1500g per contract
- Loot: 50-200g per mission (variable)
- Side quests: 100-300g each

**Expenses:**
- Soldier wages: 10g per soldier per week
- Fort upkeep: 50g per week
- Equipment repairs: 20-100g per mission
- Food/supplies: 30g per week

**Cash Flow Example:**
```
Week 1:
Income: +700g (contract)
Expenses: -150g (wages, upkeep, repairs)
Net: +550g

Week 2:
Income: +1000g (contract)
Expenses: -180g
Net: +820g

Week 8 (15 soldiers, fort upgraded):
Income: +1200g
Expenses: -350g (higher wages, more soldiers)
Net: +850g
```

**Financial Pressure:**
- Early game: Tight budget, careful spending
- Mid game: Comfortable, can invest
- Late game: Wealthy, buy whatever

---

### **Company Reputation**

**Reputation Score (0-100 per kingdom):**

| Score | Title | Effects |
|-------|-------|---------|
| 0-19 | Unknown | No special contracts, high prices |
| 20-39 | Known | Basic contracts available |
| 40-59 | Respected | Good contracts, fair prices |
| 60-79 | Renowned | Great contracts, discounts |
| 80-100 | Legendary | Best contracts, preferential treatment |

**How to Gain Reputation:**
- Complete contracts: +10-30
- Succeed without civilian deaths: +5 bonus
- Help kingdom in crisis: +20
- Companion is from that kingdom: +5 starting

**How to Lose Reputation:**
- Fail contracts: -20
- Betray employer: -50
- Attack kingdom's forces: -30
- Work for enemy kingdom: -15

**Reputation Effects:**
- Unlock contracts (some require min reputation)
- Merchant prices (±20% at extremes)
- NPC reactions (hostile, neutral, friendly)
- Ending outcomes (kingdom's gratitude)

---

## 6. Companion System

### **Core Mechanics**

**Loyalty Score (0-100 per companion):**

| Score | Status | Effects |
|-------|--------|---------|
| 0-29 | Disloyal | Will leave soon, poor combat |
| 30-49 | Neutral | Stays but minimal help |
| 50-69 | Loyal | Solid ally, normal performance |
| 70-89 | Devoted | +10% combat stats, unlocks quest |
| 90-100 | Bonded | +20% combat stats, special ability, romance |

---

### **Loyalty Gain/Loss**

**Gain Loyalty:**
- Conversation choices (align with values): +5
- Complete companion quest: +20
- Make choice they approve: +10
- Give them relevant loot: +5
- Camp interactions: +2

**Lose Loyalty:**
- Choices they disapprove: -10
- Ignore their requests: -5
- Let them die in combat: -30
- Betray their values: -20

**Companion-Specific Triggers:**

**Thorne:**
- Approve: Honor in combat, mercy to defeated
- Disapprove: Assassination, betrayal
- Crisis: Contract 7 (assassination)

**Lyra:**
- Approve: Protecting team, keeping promises
- Disapprove: Betrayal, unnecessary risk
- Crisis: Contract 12 (betrayed by former ally)

**Matthias:**
- Approve: Protecting innocents, mercy
- Disapprove: Cruelty, greed
- Crisis: Contract 7 (refuses assassination)

---

### **Companion Quests (3 per companion)**

**Thorne's Arc:**
```
Quest 1: "Shadows of the Past"
- Thorne reveals massacre guilt
- Player can: Listen, judge, or dismiss
- Reward: +15 loyalty, unlock backstory

Quest 2: "The Old Commander"
- Thorne's former commander is Contract 7 target
- Player choice: Kill commander OR spare (Thorne conflicted)
- Reward: +20 loyalty, unlock redemption path

Quest 3: "Absolution"
- Survivor from massacre appears
- Can: Seek forgiveness, fight, or flee
- Reward: +25 loyalty, unlock ultimate ability, ending variation
```

**Lyra's Arc:**
```
Quest 1: "Trust Issues"
- Lyra tests player's reliability
- Keep promise OR break it
- Reward: +15 loyalty

Quest 2: "Ghosts of Thornwood"
- Return to homeland, face commander's brother
- He wants revenge on Lyra
- Player choice: Support Lyra OR stay neutral
- Reward: +20 loyalty, unlock backstory

Quest 3: "Home"
- Lyra decides: Stay with company OR leave
- Depends on loyalty + player romance
- Reward: +25 loyalty, Lyra permanently stays, special ability
```

**Matthias's Arc:**
```
Quest 1: "Crisis of Faith"
- Matthias questions if gods care
- Player can: Encourage faith OR embrace doubt
- Reward: +15 loyalty

Quest 2: "The Church's Sins"
- Church sends assassins after Matthias
- Defend him, then choice: Forgive church OR seek revenge
- Reward: +20 loyalty, unlock backstory

Quest 3: "Redemption"
- Matthias has vision (real or imagined?)
- God offers him second chance
- Restore faith OR new purpose
- Reward: +25 loyalty, unlock divine ability OR new path
```

---

### **Romance System (Optional)**

**Romanceable Companions:**
- Lyra (for male/female player)
- Matthias (for female player)
- Thorne (no romance, deep friendship only)

**Requirements:**
- Loyalty 80+
- Complete all 3 companion quests
- Choose romantic dialogue options

**Romance Milestones:**
- First hint: Contract 8 (camp scene)
- Confession: Contract 12 (emotional moment)
- Relationship: Contract 15 (before finale)

**Romance Benefits:**
- Companion never leaves
- +25% combat effectiveness
- Unique ending epilogue
- Special ability (duo combo attack)

**Romance Endings:**
- Settle down together (retire from company)
- Continue as partners (lead company together)
- Bittersweet (one dies in finale, other lives on)

---

### **Camp System (Companion Interactions)**

**Every Night: Camp Scene**

**Structure:**
1. **Set up camp** (choose secure OR visible)
2. **Assign watch** (who guards when?)
3. **Character interactions** (2-3 scenes per night)
4. **Random events** (30% chance: ambush/visitor/wildlife)
5. **Rest** (heal HP, restore abilities)

**Interaction Types:**

**1. Companion to Companion:**
```
Example:
Thorne and Lyra argue about tactics.

THORNE: "We should've charged. Quick victory."
LYRA: "And gotten soldiers killed. Your way is reckless."
YOU:
> Side with Thorne (Thorne +3, Lyra -2)
> Side with Lyra (Lyra +3, Thorne -2)
> Mediate (Both +1, leadership check)
> Stay silent (no change, they remember)
```

**2. Companion to Player:**
```
Example:
Matthias drinks alone, stares at stars.

MATTHIAS: "Do you believe the gods care? About any of this?"
YOU:
> "They watch over us." (Faith response, Matthias +5 if loyal)
> "Gods or not, we make our own fate." (Pragmatic, neutral)
> "No. We're alone." (Nihilistic, Matthias -5)
> "What do you believe?" (Turn question back, Matthias appreciates)
```

**3. Player Initiates:**
- Walk around camp
- Approach any companion
- Start conversation (loyalty-dependent dialogue)

**4. Group Scenes:**
- All 4 together
- Discuss recent events
- Joke, argue, bond
- Build camaraderie

---

### **Companion Combat Abilities**

**Loyalty-Locked Abilities:**

**Thorne (Fighter):**
- Loyalty 0-49: Basic attacks only
- Loyalty 50-69: Unlocks "Rally" (buff allies)
- Loyalty 70-89: Unlocks "Last Stand" (absorb damage for ally)
- Loyalty 90-100: Unlocks "Warlord's Fury" (AOE devastating attack)

**Lyra (Rogue):**
- Loyalty 0-49: Basic attacks only
- Loyalty 50-69: Unlocks "Shadowstep" (teleport behind enemy)
- Loyalty 70-89: Unlocks "Assassinate" (massive damage to low HP target)
- Loyalty 90-100: Unlocks "Dance of Blades" (attack all adjacent enemies)

**Matthias (Cleric):**
- Loyalty 0-49: Basic healing only
- Loyalty 50-69: Unlocks "Sanctuary" (protect ally from 1 attack)
- Loyalty 70-89: Unlocks "Divine Wrath" (smite evil enemy)
- Loyalty 90-100: Unlocks "Resurrection" (revive unconscious ally mid-battle)

**This incentivizes keeping companions happy.**

---

## 7. Economy & Merchants

### **Currency**

**Gold (g):**
- Standard currency
- 1g = 1 gold coin
- Carried automatically (no weight)

**Starting Gold:** 100g  
**Average Contract Pay:** 500-1000g  
**End Game Wealth:** 10,000-20,000g

---

### **Merchant Types**

**1. Weapon Merchant:**
- Sells: Weapons (melee, ranged)
- Quality: Iron → Steel → Enchanted
- Locations: All cities
- Prices: 50-1500g

**2. Armor Merchant:**
- Sells: Armor, shields, accessories
- Quality: Leather → Chain → Plate
- Locations: All cities
- Prices: 100-2000g

**3. General Goods:**
- Sells: Potions, food, tools, scrolls
- Locations: All cities + fort (after tavern built)
- Prices: 5-200g

**4. Black Market:**
- Sells: Rare items, stolen goods, contraband
- Quality: Enchanted, unique
- Locations: Silvermere only, hidden
- Prices: 500-3000g

**5. Recruiter:**
- Sells: Soldiers (hire NPCs)
- Quality: Level 1-3
- Locations: Taverns
- Prices: 50-300g

---

### **Buy/Sell System**

**Buying:**
```
Base Price: Item's listed value
Charisma Modifier: ±5% per CHA point
Reputation Modifier: ±10% based on kingdom reputation

Final Price = Base × (1 - CHA% - Rep%)

Example:
Steel Sword: 300g base
Player CHA: 14 (+2 = -10% price)
Ironmark reputation: 65 (Renowned = -10% price)
Final: 300 × 0.8 = 240g
```

**Selling:**
```
Sell Price = 50% of base value
(No CHA modifier on selling)

Example:
Looted Iron Sword: 100g base value
Sell for: 50g
```

---

### **Merchant Inventory Refresh**

**Timing:**
- Every 5 in-game days
- New stock appears
- Old stock remains (doesn't disappear)

**Quality Progression:**
- Days 1-20: Iron equipment, basic potions
- Days 21-40: Steel equipment, better potions, some enchanted
- Days 41-60: Enchanted equipment, rare items, scrolls

---

# GAMEPLAY LOOP

## Core Loop (Per Contract)

```
1. AT FORT (1-2 days)
   ├─ Rest (heal, restore abilities)
   ├─ Manage company (recruit, upgrade fort)
   ├─ Buy equipment (merchants)
   ├─ Talk to companions (loyalty, quests)
   └─ Choose next contract (quest board)

2. PREPARATION (Optional, 1 day)
   ├─ Gather intel (scout reports)
   ├─ Recruit soldiers (if needed)
   └─ Craft items (potions, upgrades)

3. TRAVEL (0-2 days)
   ├─ Journey to contract location
   ├─ Random encounters (30% chance)
   └─ Camp scenes (companion interactions)

4. MISSION (1-3 days)
   ├─ Complete objectives
   ├─ Combat encounters (2-5 battles)
   ├─ Choices/consequences
   └─ Loot rewards

5. RETURN (0-1 day)
   ├─ Travel back to quest giver
   ├─ Report success/failure
   ├─ Receive payment
   └─ Reputation changes

6. AFTERMATH (Camp scene)
   ├─ Companions react to mission
   ├─ Story consequences unfold
   └─ Time passes → Repeat
```

**Total Time per Contract:** 4-8 in-game days  
**15 Contracts × 4-8 days = 60 days total**

---

## Session Structure (Player Experience)

**Play Session: 2-3 hours**

**Hour 1: Management**
- Return from last mission
- Manage company (15 min)
- Buy equipment (10 min)
- Companion conversations (20 min)
- Choose next contract (5 min)
- Prepare (10 min)

**Hour 2: Travel & Mission**
- Travel montage (5 min)
- Camp scene (10 min)
- First combat encounter (20 min)
- Story/exploration (15 min)
- Second combat (20 min)

**Hour 3: Completion**
- Final combat (25 min)
- Resolution/choices (15 min)
- Return to quest giver (10 min)
- Rewards/reputation (5 min)
- **Save game, end session**

**Result: 1 contract completed per 2-3 hour session**

**Total Playtime: 15 contracts × 2-3 hours = 30-45 hours** 
(But we said 15-18 hours target, so some contracts faster)

**Adjusted: Some contracts shorter (1-2 hours)**

---

## Pacing (60-Day Campaign)

**Week 1 (Days 1-7): Learning the Ropes**
- Contracts 1-2
- Tutorial phase
- Meet companions
- Establish fort

**Week 2-3 (Days 8-21): Building Reputation**
- Contracts 3-5
- Moral choices introduced
- First major upgrade (fort)
- Companion quests unlock

**Week 4-5 (Days 22-35): War Begins**
- Contract 6 (choose side)
- Contracts 7-9
- High stakes
- Companion loyalty tested

**Week 6-7 (Days 36-49): The Push**
- Contract 10 (fort defense)
- Contracts 11-14 (kingdom path)
- Building toward finale
- Upgrade company fully

**Week 8 (Days 50-60): The Finale**
- Contract 15 (final battle)
- Epic climax
- Resolution
- Endings

---

# TECHNICAL REQUIREMENTS

## Core Systems (To Build)

### **1. Character System**
```
character.gd
├─ Stats (6 core)
├─ Skills (12 skills)
├─ Abilities (class-based)
├─ Equipment (9 slots)
├─ Inventory (items)
├─ Level up (XP, progression)
└─ Save/load (serialization)
```

### **2. Combat System**
```
combat_manager.gd
├─ Grid (hex or square)
├─ Turn order (initiative)
├─ Move + Action (turn structure)
├─ Attack resolution (to-hit, damage)
├─ Abilities (spell casting)
├─ Status effects (buffs/debuffs)
├─ AI (enemy behavior)
└─ Victory/defeat (conditions)
```

### **3. Dialogue System**
```
dialogue_tree.gd
├─ Speaker (character portraits)
├─ Choices (branching)
├─ Skill checks (persuasion, etc.)
├─ Flags (story state tracking)
├─ Consequences (reputation, loyalty)
└─ Parser (load from JSON/YAML)
```

### **4. Quest System**
```
quest_manager.gd
├─ Quest log (UI)
├─ Objectives (tracking)
├─ Quest giver (NPCs)
├─ Rewards (gold, items, XP)
├─ Consequences (reputation)
└─ Quest state (active, complete, failed)
```

### **5. Company Management**
```
company.gd
├─ Fort (upgrades)
├─ Soldiers (NPC units)
├─ Finances (income, expenses)
├─ Reputation (per kingdom)
└─ Morale (company-wide)
```

### **6. Companion System**
```
companion.gd
├─ Loyalty (0-100)
├─ Dialogue (camp scenes)
├─ Quests (personal arcs)
├─ Romance (optional)
├─ Combat AI (orders)
└─ Reactions (to choices)
```

### **7. UI Framework**
```
ui/
├─ character_sheet.tscn
├─ inventory.tscn
├─ quest_log.tscn
├─ dialogue_box.tscn
├─ combat_hud.tscn
├─ company_management.tscn
└─ main_menu.tscn
```

### **8. Save System**
```
save_manager.gd
├─ Save game state (entire world)
├─ Load game state
├─ Multiple save slots (3)
├─ Auto-save (after each contract)
└─ Cloud save (optional, Steam)
```

---

## Assets Needed

### **Art Assets**

**Characters (2D Sprites):**
- 4 party members (Thorne, Lyra, Matthias, Player × 4 classes)
- 20 enemy types (bandits, soldiers, monsters, bosses)
- 10 NPC soldiers (infantry, archer, cavalry, mage, healer × 2 variants)
- 15 quest givers (kingdom leaders, merchants, NPCs)

**Total: 49 character sprites** (plus animations)

**Animations per character:**
- Idle (4 directions)
- Walk (4 directions)
- Attack (4 directions)
- Hurt
- Death
- Victory

**Environments:**
- Fort Raven's Rest (base, 8 rooms)
- 5 city hubs (Ironhaven, Argentum, Greenvale, Luminara, border town)
- 15 combat maps (varied terrain)
- 10 travel locations (camps, ruins, forests)

**Total: 30+ environment maps**

**UI Elements:**
- Character portraits (50+)
- Icons (items, abilities, status effects: 100+)
- Frames, buttons, panels
- Map markers, quest indicators

---

### **Audio Assets**

**Music (8 tracks):**
1. Main Theme (menu)
2. Fort Theme (base management)
3. Travel Theme (journey)
4. Camp Theme (companion scenes)
5. Combat Theme (battles)
6. Boss Theme (finale)
7. Victory Theme (ending)
8. Somber Theme (tragic moments)

**SFX (50+ sounds):**
- Weapon swings/impacts (10)
- Magic spells (15)
- UI clicks (5)
- Footsteps (4)
- Ambient (10)
- Voice grunts (combat, 6)

---

### **Writing (Text Volume)**

**Dialogue Lines:**
- Main story: 5,000 lines
- Companion conversations: 3,000 lines
- NPC dialogue: 2,000 lines
- Barks (combat, reactions): 1,000 lines

**Total: 11,000 dialogue lines**

**Quest Text:**
- Quest descriptions: 30 quests × 200 words = 6,000 words
- Codex entries (lore): 50 entries × 150 words = 7,500 words

**Total Written Content: ~150,000 words** (short novel length)

---

## Performance Targets

**Resolution:** 1920×1080 (Full HD)  
**Frame Rate:** 60 FPS (combat), 30 FPS (dialogue/menus acceptable)  
**Load Times:** <5 seconds (between scenes)  
**Save File Size:** <10 MB per save  
**Install Size:** <2 GB total

---

# CONTENT BREAKDOWN

## Detailed Asset Count

### **Characters**

**Party Members:** 4
- Thorne Blackwood (Fighter)
- Lyra Swiftblade (Rogue)
- Matthias (Cleric)
- Player (4 class variants: Fighter, Mage, Cleric, Ranger)

**Total Party Sprites:** 7

**Enemy Types:** 20
- Bandits (3 variants: melee, archer, leader)
- Ironmark Soldiers (3 variants: infantry, knight, archer)
- Thornwood Rangers (2 variants: scout, druid)
- Sunspire Mages (2 variants: battlemage, elementalist)
- Silvermere Mercenaries (3 variants)
- Wildlife (3 variants: wolves, bears, giant spiders)
- Undead (2 variants: skeleton, ghoul)
- Aberrations (2 variants: cultist, demon)
- Bosses (5 unique: one per kingdom + finale)

**NPC Soldiers:** 5 types × 2 gender variants = 10
- Infantry (male/female)
- Archer (male/female)
- Cavalry (male/female)
- Mage (male/female)
- Healer (male/female)

**Quest Givers & NPCs:** 20
- 5 kingdom leaders
- 10 quest givers
- 5 important NPCs (recurring characters)

**Total Character Sprites:** 57

---

### **Locations**

**Fort Raven's Rest:** 8 rooms
- Courtyard (hub)
- Barracks
- Armory
- Training Yard
- Infirmary
- War Room
- Tavern
- Your Quarters

**Cities:** 5 major + 2 minor = 7
1. Ironhaven (Ironmark capital)
2. Argentum (Silvermere capital)
3. Greenvale (Thornwood capital)
4. Luminara (Sunspire capital)
5. Border Town (neutral)
6. Wayrest (small town)
7. Crossroads (small town)

**Combat Maps:** 15 unique
- Forest clearing (3 variants)
- Canyon pass (2 variants)
- Ruins (3 variants)
- Fort/castle (2 variants)
- City streets (2 variants)
- Plains (2 variants)
- Desert (1 variant)

**Travel Locations:** 10
- Camp sites (3 variants)
- Roadside inn (1)
- Bridge crossing (1)
- Cave shelter (1)
- Abandoned farm (1)
- Ancient ruins (2 variants)
- Mountain pass (1)

**Total Location Maps:** 40

---

### **Items**

**Weapons:** 40
- 8 weapon types × 5 tiers (rusty/iron/steel/enchanted/legendary)

**Armor:** 30
- 6 armor types × 5 tiers

**Accessories:** 20
- Rings (8)
- Amulets (7)
- Boots (5)

**Consumables:** 20
- Potions (8)
- Scrolls (7)
- Grenades (5)

**Quest Items:** 15
- Story-specific items

**Total Items:** 125

---

### **Abilities**

**Per Class:** 12 abilities
**4 Classes:** 48 total player abilities

**Companion Abilities:** 12 each × 3 = 36

**Enemy Abilities:** 30 (shared across enemy types)

**Total Abilities:** 114

---

### **Quests**

**Main Quests (Contracts):** 15

**Side Quests:** 10
- 5 generic (repeatable style)
- 5 unique (one-off stories)

**Companion Quests:** 9
- 3 per companion (Thorne, Lyra, Matthias)

**Total Quests:** 34

---

## Development Time Estimate (Solo with AI Assistance)

### **Phase 1: Core Systems (3 months)**
```
Month 1: Character & Combat
- Character system (stats, skills, progression)
- Combat system (grid, turns, actions)
- Basic UI (character sheet, combat HUD)

Month 2: Dialogue & Quests
- Dialogue tree system
- Quest system (log, objectives)
- Save/load system

Month 3: Company & Companions
- Company management (fort, soldiers)
- Companion system (loyalty, camp scenes)
- Economy (merchants, loot)
```

### **Phase 2: Content Creation (4 months)**
```
Month 4: Act 1 Content
- Contracts 1-5 (write, implement)
- Fort Raven + 3 cities
- 20 characters (art + implementation)
- 5 combat maps

Month 5: Act 2 Content
- Contracts 6-10
- 2 more cities
- 20 more characters
- 5 combat maps
- Companion quests (first half)

Month 6: Act 3 Content
- Contracts 11-15
- Final locations
- 17 remaining characters
- 5 combat maps
- Companion quests (second half)

Month 7: Side Content & Polish
- 10 side quests
- Random encounters
- Loot tables
- Balance combat
```

### **Phase 3: Polish & Release (2 months)**
```
Month 8: Alpha Testing
- Full playthrough (15-18 hours)
- Bug fixing
- Balance adjustments
- Audio implementation

Month 9: Beta & Release
- External playtesting
- Final polish
- Trailer, store page
- Release build
```

**Total: 9 months** (with AI assistance for art, writing, code)

**Without AI:** 18-24 months (traditional solo dev)

---

# REUSABLE SYSTEMS (For Games 2-5)

## What Gets Reused 100%

### **Core Engine:**
- Character system (stats, skills, levels)
- Combat system (grid, turns, attacks)
- Dialogue system (trees, choices, flags)
- Quest system (log, objectives, rewards)
- Save/load system
- UI framework (all interfaces)
- Input handling
- Camera system

**Time Saved:** 150-200 hours (Games 2-5 don't rebuild these)

---

## What Gets Modified Per Game

### **Game 2: Prison Break**
**Reuse:** Character, dialogue, combat (90%)  
**New:** Suspicion system, escape routes (10%)  
**Time:** 120 hours (vs 250 for building from scratch)

### **Game 3: Caravan**
**Reuse:** Character, combat, quest (90%)  
**New:** Resource management, route branching (10%)  
**Time:** 120 hours

### **Game 4: Cult**
**Reuse:** Character, dialogue, suspicion from Game 2 (95%)  
**New:** Infiltration-specific mechanics (5%)  
**Time:** 100 hours

### **Game 5: Convergence**
**Reuse:** Everything from Games 1-4 (95%)  
**New:** Epic-scale battles, save import (5%)  
**Time:** 150 hours (more content than systems)

---

## Shared Lore Database

**Create once, reference everywhere:**

```
lore_database.json
{
  "kingdoms": [...],  // 5 kingdoms, all details
  "npcs": [...],      // Recurring NPCs across games
  "timeline": [...],  // 1205-1220, all events
  "factions": [...],  // Organizations
  "artifacts": [...], // The Eye of Nyx, etc.
  "gods": [...]       // The Pantheon
}
```

**Import into each game:**
- Consistent lore
- No contradictions
- Cross-references work
- Easter eggs easy

**Time Saved:** 40-60 hours (writing lore per game)

---

## Total Development Timeline (All 5 Games)

```
Game 1 (Mercenary): 9 months (250 hours)
Game 2 (Prison): 5 months (120 hours)
Game 3 (Caravan): 5 months (120 hours)
Game 4 (Cult): 4 months (100 hours)
Game 5 (Convergence): 6 months (150 hours)

Total: 29 months (~2.5 years)

Without reusable systems: 45+ months (4+ years)
```

**Efficiency Gain: 35% faster development**

---

# CONCLUSION

This design document provides:

✅ **Complete world building** (5 kingdoms, history, magic, lore)  
✅ **Detailed game design** (systems, combat, quests, characters)  
✅ **Narrative structure** (3 acts, companion arcs, 16 endings)  
✅ **Technical requirements** (assets, performance, scope)  
✅ **Reusability plan** (how all 5 games connect)  

**Next Steps:**
1. Prototype core combat system (1 month)
2. Build dialogue system (2 weeks)
3. Create 1 sample contract start-to-finish (1 month)
4. Validate fun/scope (playtest)
5. Full production (if validated)

---

**This is your blueprint. Ready to build?**