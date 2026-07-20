# Requirements Document
## 16-Bit RPG Game Clone — *Legend of Zelda: A Link to the Past* Style

**Version:** 1.1  
**Status:** Draft — Ready for Review  
**Date:** July 18, 2026

**Title** The Shadows of the Mirror
**Scope:** Indie experience  
**Target Playtime:** ~6 hours (less than 1 hour per dungeon/zone)  
**Dark World Mechanic:** Simplified — temporary single-screen forays only (no persistent world flip)  
**Procedural Generation:** None at runtime — procedural tools used only during development for layout drafts, all content hand-tuned  
**New Game+:** Not included  
**Localization:** English only  
**Achievements/Trophies:** Not planned

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Game Concept & Vision](#2-game-concept--vision)
3. [Target Platform & Engine](#3-target-platform--engine)
4. [Visual Design Requirements](#4-visual-design-requirements)
5. [Audio Design Requirements](#5-audio-design-requirements)
6. [Core Gameplay Mechanics](#6-core-gameplay-mechanics)
7. [Combat System](#7-combat-system)
8. [Items & Inventory](#8-items--inventory)
9. [World & Map Design](#9-world--map-design)
10. [Dungeons & Progression](#10-dungeons--progression)
11. [Character & Enemy Design](#11-character--enemy-design)
12. [Narrative & Quests](#12-narrative--quests)
13. [Technical Requirements](#13-technical-requirements)
14. [Performance Requirements](#14-performance-requirements)
15. [Milestone & Delivery Plan](#15-milestone--delivery-plan)

---

## 1. Executive Summary

This document outlines the requirements for developing a 16-bit era action-adventure RPG that draws heavy inspiration from *The Legend of Zelda: A Link to the Past* (SNES, 1991). The game will feature a top-down perspective, a handcrafted world, a sword-and-shield combat system, a diverse item collection, and interconnected dungeons — all rendered in an authentic 16-bit pixel art aesthetic.

The goal is to deliver a complete, polished, and fun indie experience that pays homage to the SNES era while offering its own unique identity.

---

## 2. Game Concept & Vision

### 2.1 Core Pillars

| Pillar | Description |
|--------|-------------|
| **Exploration-First** | The world is the game. Exploration, secrets, and backtracking with new abilities drive progression. |
| **16-Bit Authenticity** | Pixel-perfect art, chiptune-inspired audio, and gameplay feel rooted in the SNES era (1990–1996). |
| **Combat Satisfaction** | Swordplay, arrow shooting, and item usage must feel tight, responsive, and rewarding. |
| **Interconnected World** | A seamless overworld with dungeons, towns, and hidden areas that interconnect logically. |
| **Progression Through Items** | Key items unlock new areas — the player's growing toolkit is the primary progression system. |

### 2.2 Design Inspirations

- *The Legend of Zelda: A Link to the Past* (SNES, 1991) — primary reference
- *The Legend of Zelda: Oracle of Ages / Seasons* (GBC, 2001)
- *Secret of Mana* (SNES, 1993) — for magic systems
- *Zelda II: The Adventure of Link* (NES, 1987) — for side-view dungeon segments

### 2.3 Target Audience

- Fans of classic action-adventure / action RPGs
- Players who appreciate retro pixel art and chiptune soundtracks
| **E (Everyone)** | Mild fantasy violence, no gore |

---

## 3. Target Platform & Engine

### 3.1 Platform

- **Primary:** PC (Windows, macOS, Linux)
- **Distribution:** Steam and/or itch.io
- **Note:** No Nintendo Switch port planned at this time

### 3.2 Recommended Engine Options

| Engine | Pros | Cons |
|--------|------|------|
| **Godot 4.x** | Free, open-source, excellent 2D support, built-in 16-bit pipeline | Less community for retro-style games |
| **GameMaker Studio 2** | Great for 2D, fast iteration, large community | Paid license, less control over internals |
| **Unity 2D (URP)** | Huge ecosystem, asset store, familiar toolset | Overhead for a 2D project, license costs |
| **Custom (SDL2 / PixiJS)** | Maximum control, zero licensing | Significant dev time for tooling |

**Recommended:** Godot 4.x or GameMaker Studio 2

### 3.3 Resolution & Scaling

- Native resolution: **256 × 224** (SNES mode 7 reference)
- Pixel art scale: **3× or 4×** integer scaling for modern displays
- Art style: **16-bit pixel art** with careful use of color palettes (32–64 colors per sprite)

---

## 4. Visual Design Requirements

### 4.1 Pixel Art

| Element | Spec |
|---------|------|
| **Player Sprite** | 16×16 to 24×24 pixels per frame |
| **Enemy Sprites** | 16×16 to 32×32 pixels per frame |
| **Tilesets** | 16×16 tiles with parallax layers |
| **Animations** | Minimum 4 frames per direction for walking; 8+ frames for combat |
| **Color Palette** | Hand-picked palettes; dithering for texture variation |
| **Effects** | Limited particle system for spells, damage, pickups |

### 4.2 World Tiles

- **Overworld:** 32×32 pixel tiles with 1–2 layers of parallax
- **Dungeons:** 16×16 pixel tiles with detailed environmental storytelling
- **Indoors:** Town interiors, cave systems, boss rooms
- **Transitions:** Smooth fade between overworld, dungeons, and interiors

### 4.3 UI/HUD

- **Heart Container Display:** 16×16 pixel heart icons (full / the quarters / half / one quarter / empty)
- **Item HUD:** 8-slot inventory bar at screen bottom
- **Boss Health Bar:** Decorative banner with animated health indicator
- **Minimap:** Toggleable, dungeon-only, 8×8 pixel style
- **Dialogue Box:** Classic SNES-style text box with scrolling text

### 4.4 Visual Effects

- Screen flash on damage (red)
- Enemy flash on hit (white alternate frame)
- Transition fades between areas (crossfade or wipe)
- Item acquisition sparkle animation
- Secret reveal effects (shaking blocks, dissolving walls)
- Screen shake on heavy hits

---

## 5. Audio Design Requirements

### 5.1 Music

| **Style** | **Count** | **Details** |
|-----------|-----------|-------------|
| Overworld themes | 7 | One per overworld zone |
| Dungeon theme | 1 | Shared across all 7 main dungeons |
| Boss theme | 1 | Shared across all dungeon bosses |
| Final dungeon theme | 1 | Unique theme for final dungeon |
| Final boss theme | 1 | Unique theme for final boss |
| **Total** | **11** | |

Each theme: 5–7 minutes, loops seamlessly.

### 5.2 Sound Effects

| Category | Examples |
|----------|----------|
| **Combat** | Sword swing, arrow release, item use, shield passive block |
| **Damage** | Player hurt, enemy hit, boss pain |
| **Pickups** | Heart refill, rupee, key, item acquisition jingle |
| **World** | Doors, switches, water, walking on different surfaces |
| **UI** | Menu navigation, item selection, save confirmation |

### 5.3 Audio Format

- **Music:** WAV or OGG (compressed for runtime)
- **SFX:** OGG or WAV
- **Tools:** LSDj (Game Boy tracker), Famitracker, or FL Studio with chiptune plugins

---

## 6. Core Gameplay Mechanics

### 6.1 Player Character

- **Movement:** 8-directional movement (4 cardinal + 4 diagonal)
- **Actions:** Attack, Shoot Bow, Use Item, Interact/Dash (Actions only in 4 cardinal directions)
- **Health:** Starting 4 Hearts (Max 20 Hearts); collect Heart Pieces and Heart Containers to expand
- **Magic Meter:** Depletes on special items, regenerates at fairies/spring
- **Death:** Reverts to last save point (no rupee death penalty)

### 6.2 Movement & Physics

| Action | Details |
|--------|---------|
| **Walk** | Normal speed, 8-directional |
| **Dash** | Hold button, dashes in cardinal direction until stopped by terrain, sword aimed forward while dashing |
| **Jump** | Contextual (down slopes, over gaps); no coyote time needed for SNES feel |
| **Swim** | Restricted movement, can breathe indefinitely (no underwater breathing meter) |
| **Climb** | Climb stairs/ladders/ramps only |
| **Push** | Pushable blocks, weighted enemies, platforms |

### 6.3 Exploration Systems

- **Secrets:** Hidden blocks (hit with sword), breakable walls (bomb or dash), burning bush (lantern or Fire Rod, pushable block
- **Shrines/Challenges:** Optional mini-dungeons for rewards (heart pieces, upgrades)
- **NPCs:** Simple dialog, shops, save points (bonfires/beds)

---

## 7. Combat System

### 7.1 Sword Combat

- **Primary Attack:** Tap Sword button for a single slash in cardinal directions. Tap only — holding does not trigger a charged hit.
- **Spin Attack:** Hold Sword button for a moment to power up; release to unleash a 360° slash that knocks back nearby enemies. Spin Attack is unlocked by default from the start.

### 7.2 Shield

- **Passive Block:** Automatic frontal block — no shield button required. Player faces forward and blocks incoming projectiles naturally. Player can still move while blocking.
- **Basic Shield:** Blocks small/medium enemy projectiles. Does not block boss attacks.
- **Hylian Shield:** Blocks all non-boss projectiles, including large enemy projectiles.

### 7.3 Enemy Behavior

- Enemies have **aggro radius**, **patrol paths**, and **alert states**
- Damage scaling: small enemies (1 hit), medium (2 hits), large/bosses (3–6 hits)
- Knockback on hit (varies by enemy size)
- Enemies can be **stunned** (stuck in place for 2s) after sufficient damage

### 7.4 Boss Fights

- Multi-phase bosses with at least 2 attack patterns per phase
- Telegraphed attacks (warning animation before strike)
- Weak point targeting where applicable
- Arena design encourages movement (not just standing and hitting)
- Boss music speeds up with phase changes

---

## 8. Items & Inventory

### 8.1 Key Items (Progression-Critical)

| Item | Function | Unlock Location |
|------|----------|-----------------|
| **Lamp** | Light dark rooms, burn bushes | Prologue dungeon (first half) |
| **Basic Shield** | Blocks frontal attacks | Prologue dungeon (end) |
| **Bow & Arrows** | Long-range attack, hit switches, light torches | Dungeon 1 |
| **Bomb Bag** | Carry up to 20 bombs, detonate breakable rocks | Prologue dungeon (miniboss reward) |
| **Hookshot/Clawshot** | Grapple to distant targets, pull self to ledges | Dungeon 2 |
| **Red Armor** | Reduces enemy damage, heat resistance | Dungeon 3 |
| **Blue Armor** | Enhanced damage reduction (upgrade to Red Armor) | Blacksmith (purchased after completing Storm Tower) |
| **Hammer** | Drive stakes, crack ground, power generators | Dungeon 4 |
| **Power Glove** | Lift heavy objects | Dungeon 5 |
| **Mirror Shield** | Reflect beams and lasers | Dungeon 6 |
| **Magic Cape** | Phase through obstacles, invincibility frames | Dungeon 7 |
| **Silver Bow** | Powerful ranged attack, defeats final boss | Dungeon 8 |
| **Flippers** | Swim in deep water | Overworld lake |
| **Bug-Catching Net** | Catch butterflies, bees, fireflies | Early overworld |
| **Shovel** | Dig in soft soil for hidden items | Shop |
| **Pegasus Boots** | Dash attack, ram through barriers | Overworld secret |
| **Fire Rod** | Elemental attack, light torches | Witch's Hut shop |
| **Ice Rod** | Elemental attack, freeze water | Witch's Hut shop (unlocked after Ice Cavern) |

**Note:** Fire Rod and Ice Rod are purchased from the Witch's Hut (see §11.2). Fire Rod required to enter Ice Cavern.

### 8.2 Consumables

| Item | Effect |
|------|--------|
| **Rupees** | Currency (Green=1, Blue=5, Red=20, Purple=50, Silver=100) |
| **Hearts** | Restore 1–4 hearts when collected or from heart containers |
| **Fairies** | Auto-resurrect once on death (carried in inventory) |
| **Potions** | Restore health or stamina (buy from shops) |
| **Bombs** | One-time use, breakable surfaces (limited carry) |

### 8.3 Inventory System

- **Main Inventory:** Pause screen to manually select items (key items + consumables)
- **Item Descriptions:** Read about items in Main Inventory in one-line description 
- **Quick-Swap:** Press button to switch key item without pausing

---

## 9. World & Map Design


### 9.1 Overworld Structure

The game world is divided into **regions**, each with its own biomes, enemies, and secrets:

| Region | Theme | Key Features |
|--------|-------|--------------|
| **Central Kingdom** | Green fields, villages, castle | Hub area, main NPCs, save points |
| **Dark Forest** | Eerie woods, haunted ruins | Early-game challenge, secret cave |
| **Swamplands** | Murky marsh, poison water | Navigation puzzles, underwater ruins |
| **Mountain Region** | Peaks, caves, volcanic | Climbing puzzles, lava hazards |
| **Desert** | Sand dunes, ancient tombs | Heat damage, hidden oases, sand worms |
| **Coastal Region** | Beaches, lighthouse, shipwrecks | Boats, diving, sea caves |
| **Sky Islands** | Floating landmasses, wind currents | Late-game area, navigated with Hookshot |

### 9.2 Settlements

- **1 large town** (4 screens): Central Kingdom — main NPCs, blacksmith, shops, save point
- **3 medium towns** (2 screens each): One in each of 3 regions — shops, basic NPCs, save point
- **4 villages** (1 screen each): Scattered across regions — minimal shops, NPC dialogue, save point
- **Save points:** 1 per overworld zone (~7 total), typically a restful location (inn, church, stable, campfire)

### 9.3 Transition System

- **Overworld ↔ Dungeon:** Walk through entrance, fade transition
- **Overworld ↔ Interior:** Walk through door, fade transition
- **Region to Region:** Walk across border, seamless or fade
- **Temporary Dark World Forays:** Single-screen or small-area dark mirrors for specific puzzles/challenges (not a full world flip). These are isolated encounters, not a persistent alternate world state.

### 9.4 Map Requirements

- Overworld map: Hand-drawn, covers 800×600 tiles minimum
- Dungeon maps: Separate files per dungeon
- Fog-of-war: Unexplored areas hidden until visited (optional toggle)
- Map markers: Player can place flags on the map

### 9.5 Secrets & Hidden Items

**Overworld Secrets: 58 total**
- Heart pieces: 36 (see §12.2)
- Rupees: ~15 scattered throughout
- Arrows: ~4 per region (8 total)
- Bombs: ~2 per region (4 total)
- Heart refills: ~1 per region (7 total)

**Dungeon Secrets: 42 total**
- Approximately 6 per dungeon
- Mostly rewarding rupees, arrows, bombs, heart refills
- Types: hidden doors, bomb doors, burning bushes, moving blocks/graves, pickup rocks, etc.

**Total Game Secrets: 100**
- Each secret should be discoverable with the right item or approach
- Rewards are balanced to keep player funded without being trivial

### 9.6 Development Notes — Procedural Tools

- **No runtime procedural generation.** All maps, dungeons, enemy placements, and secrets are handcrafted.
- During **development**, procedural layout tools may be used to draft blockouts, which are then hand-tuned by designers.
- No dynamic/randomized content at runtime — every encounter and secret is placed intentionally.

---

## 10. Dungeons & Progression

### 10.1 Dungeon Structure (8 Dungeons)

| # | Name | Region | Theme | Key Item Unlocked | Miniboss | Boss |
|---|------|--------|-------|-------------------|----------|------|
| P | **Cathedral Crypts** (Prologue) | Central Kingdom | Unassuming cathedral above, haunted crypts below | Lamp, Basic Shield, Bomb Bag | Stalfos skeleton guards Bomb Bag | — |
| 1 | **Cave of Beginnings** | Dark Forest | Forest/caves | Bow & Arrows | 1 miniboss guards item room | Gohma-like creature |
| 2 | **Sunken Temple** | Swamplands | Underwater | Hookshot | 1 miniboss guards item room | Serpent boss |
| 3 | **Volcanic Fortress** | Mountain Region | Lava/mountains | Red Armor | 1 miniboss guards item room | Dragon-like boss |
| 4 | **Ice Cavern** | Mountain Region | Frozen caves | Hammer | 1 miniboss guards item room | Frost giant |
| 5 | **Desert Pyramid** | Desert | Sand/tombs | Power Glove | 1 miniboss guards item room | Mummy/pharaoh boss |
| 6 | **Storm Tower** | Coastal Region | Wind/heights | Mirror Shield | 1 miniboss guards item room | Storm elemental |
| 7 | **Shadow Castle** | Dark Forest | Dark/haunted | Magic Cape | 1 miniboss guards item room | Shadow king |
| 8 | **Sky Citadel** | Sky Islands | Floating/climbing | Silver Bow | — | Final boss |

**Note:** Dungeons 1–7 grant heart containers upon boss defeat. Dungeon 8 (Sky Citadel) does **not** grant a heart container — defeating the final boss ends the game.

### 10.2 Dungeon Design Rules

- Each dungeon contains: **puzzles (3)**, **1 miniboss guarding the item room**, **1 boss room**, **key item room**
- Dungeons are **non-linear internally** (multiple paths)
- Key Item in each dungeon unlocks a new overworld area or ability
- Mini-boss guards item rooms in dungeons 1–7
- Post-completion: dungeon may become a fast-travel hub

### 10.3 Difficulty Curve

| Phase | Content | Purpose |
|-------|---------|---------|
| **Early** | Tutorial dungeon, simple overworld | Teach basics, build confidence |
| **Mid-Early** | 2nd–3rd dungeon, open overworld | Introduce complexity, branching paths |
| **Mid-Late** | 4th–5th dungeon, interconnected world | Require backtracking with new items |
| **Late** | 6th–7th dungeon, optional challenges | Test mastery, increase difficulty |
| **Endgame** | 8th dungeon | Peak challenge, prepare for final boss |

---

## 11. Character & Enemy Design

### 11.1 Enemies (15+ Types Minimum)

| Enemy | Behavior | Weakness |
|-------|----------|----------|
| **Moblin** | Patrols, charges when player enters range | Sword (2 hits), Arrow |
| **Octorok** | Spits rocks at range, hides in shell | Sword (when exposed), Arrow to head |
| **Lynel** | Aggressive melee, charges, teleports | Shield bash → sword combo |
| **Stalfos** | Skeleton warrior, reassembles if not all parts destroyed | Bomb to separate limbs |
| **Like Like** | Swallows player, steals item from inventory | Bomb inside mouth, fire |
| **Poe** | Invisible until attacked, drops rupees on death | Light (Lamp) + sword |
| **Darknut** | Armored, deflects sword strikes from front | Hit from behind, arrow to helmet |
| **Armos** | Statue that activates when stepped on | Bomb, Fire Rod |
| **Peahat** | Flying flower, drops seeds | Arrow (when grounded), spin attack |
| **Gibdo** | Mummified enemy, explodes when lit on fire | Fire Rod, Bomb |
| **Bubble** | Flying skull, disables shield on contact | Arrow, Magic Cape |
| **Wizzrobe** | Teleports and fires elemental projectiles | Arrow mid-teleport |
| **Keese** | Bat, flies erratically in caves | Sword swing, Arrow |
| **ChuChu** | Gelatinous blob, splits when hit | Fire Rod, Bomb |
| **Pirate Captain** | Mini-boss, uses sword + shield | Shield bash combo |

### 11.2 Enemy Density

- **Early game:** Sparse encounters — gives player time to learn mechanics and build up
- **Scaled density:** Enemy density increases as player acquires more powerful items, matching the action RPG feel of A Link to the Past
- **Pacing:** Zones get progressively denser; final dungeon zones are dense but fair

### 11.3 NPCs & Towns

- **NPC Dialogue:** Straightforward, no branching trees. Simple yes/no questions to advance plot or trigger events. Target: 50–75 total dialogue lines across all NPCs.
- **Blacksmith:** Upgrades sword (3 tiers), upgrades shield (2 tiers)
- **Shopkeeper:** Sells bombs, potions, arrows
- **Herbalist:** Heals full health, sells fairy potions
- **Sage Candidates:** 7 sages to rescue across the world (side quest)
- **Witch's Hut** Sells heart refills, Fire Rod and Ice Rod if unlocked
- **Mini-game Masters:** Bow contest, fishing, digging competitions
- **Mini-game Types:** 3 total — bow contest, fishing, digging
- **Shop Economy:** Flat pricing across all regions (no scaling)

### 11.4 Player Upgrades

| Upgrade | Source | Effect |
|---------|--------|--------|
| **Progressive Sword** | Sword Shrine (3 tiers) | +1 damage per tier (max +3 total) |
| **Hylian Shield** | Blacksmith (upgrades Basic Shield) | Blocks all non-boss attacks |
| **Blue Armor** | Blacksmith (purchased after completing Storm Tower) | Enhanced damage reduction (upgrade to Red Armor) |
| **Heart Containers** | Dungeon bosses (7) + Overworld (36 pieces / 4) | 4 starting + 7 from dungeons + 9 from pieces = **20 max hearts** |
| **Magic Meter** | Enabled by default | Enables special item usage (Lamp, Rods, Cape) |

**Note:** Mirror Shield (Dungeon 6) and Magic Cape (Dungeon 7) are key items, not permanent upgrades. They are listed in §8.1 Key Items table.

## 12. Narrative & Quests

### 12.1 Main Storyline

A world is threatened by a rising dark force. The player, a young hero from a peaceful village, must:

1. **Awaken** — Discover their destiny after a mysterious event in their village
2. **Gather Items** — Traverse the world, complete dungeons, collect key items
3. **Rescue Sages** — Free 7 sages imprisoned in dungeons (side objective)
4. **Face the Dark** — Enter the final dungeon and defeat the antagonist

**Story delivery:** No cutscenes. Classic 16-bit Zelda style — NPC dialogue and exposition text moves the plot forward.

### 12.2 Side Quests

- **Sage Rescue:** 6 sages scattered across the overworld and dungeons
- **Heart Piece Collection:** 36 Heart Pieces scattered throughout the overworld (not in dungeons). 4 pieces = 1 full heart container. Collecting all 36 grants 9 additional hearts beyond dungeon boss rewards.
- **Shopkeeper's Tasks:** Fetching items, defeating specific enemies for rewards
- **Mini-Game Challenges:** Compete in bow contests, fishing tournaments
- **Secret Cave Challenges:** Optional rooms with unique rewards

### 12.3 Puzzle Chambers (Temporary Dark World)

- **Dark Mirrors:** Each overworld zone has 1 Dark Mirror puzzle — a single-screen or small-area challenge where the environment is temporarily inverted (light ↔ dark). These are standalone puzzle encounters, not a persistent alternate world.
- **Completion:** Solving a Dark Mirror puzzle may unlock a shortcut or grant a small reward (rupees, heart piece).
- **No Persistent World Change:** The overworld remains unchanged outside these designated chambers.

---

## 13. Technical Requirements

### 13.1 Development Tools

| Tool | Purpose |
|------|---------|
| **Aseprite** or **Pyxel Edit** | Pixel art creation |
| **LSDj / Famitracker** | Chiptune music composition |
| **Godot 4.x / GameMaker** | Game engine |
| **Git** | Version control |
| **Jira / Trello** | Task tracking |
| **Figma / Miro** | World map and level design |
| **Audacity** | Sound effect editing |

### 13.2 Asset Pipeline

1. **Concept Art** → Approved by lead designer
2. **Pixel Art Sprites** → Reviewed for palette consistency
3. **Tileset Assembly** → Tested in-engine for seamless tiling
4. **Music/SFX** → Integrated and mixed
5. **Level Assembly** → Editor-tested for gameplay flow
6. **Playtest** → Internal team feedback loop

### 13.3 Save System

- **Manual Save:** At save points (beds, shrines, campsites)
- **Auto-Save:** After completing a dungeon or acquiring a key item
- **Save File Format:** Binary or JSON (encrypted to prevent cheating)
- **Multiple Saves:** Up to 3 save slots

### 13.4 Input Support

- **Keyboard:** WASD movement, J/K/L for attack/bow/item. Space for interact/dash
- **Gamepad:** Xbox/PS controller support (primary recommended input)
- **Controls Menu:** Remappable key bindings
- **Accessibility:** Option to reduce screen shake, disable flashing effects

### 13.5 Scope Boundaries

- **No New Game+** — The player completes the game in a single playthrough.
- **English Only** — No localization or multi-language support planned.
- **No Achievements/Trophies** — The game ships without Steam achievements or platform trophies.
- **Indie Scope** — This is a modest-scale project. Prioritize quality of experience over sheer quantity of content. The focus is on a well-crafted, complete 4–6 hour experience rather than a 50+ hour epic.

---

## 14. Performance Requirements

### 14.1 Target Specifications

| Spec | Requirement |
|------|-------------|
| **Frame Rate** | 60 FPS locked (native 60 Hz display) |
| **Load Times** | < 3 seconds for area transitions |
| **Dungeon Transitions** | < 1.5 seconds with fade |
| **Max On-Screen Sprites** | 50+ simultaneous without framerate drop |
| **Save File Size** | < 500 KB per save slot |
| **Total Install Size** | < 500 MB (including audio) |
| **Memory Usage** | < 256 MB at runtime |

### 14.2 Optimization Targets

- Tilemap culling: Only render tiles within viewport + 1 tile buffer
- Sprite batching: Group by palette for draw call reduction
- Particle limit: Max 200 active particles simultaneously
- Music streaming: Stream from disk (no full-load into memory)
- Enemy AI: Distant enemies use simplified AI, only activate when player is in range

---

## 15. Milestone & Delivery Plan

### Phase 1: Pre-Production (Weeks 1–4)

| Milestone | Deliverable |
|-----------|-------------|
| M1.1 | Game Design Document (GDD) — full detail |
| M1.2 | Engine setup, core player controller (movement, collision) |
| M1.3 | Art style guide — 16-bit palette reference |
| M1.4 | Music direction — 3 theme samples approved |
| M1.5 | World map blockout (hand-placed regions; procedural tools for layout drafts only) |

### Phase 2: Vertical Slice (Weeks 5–10)

| Milestone | Deliverable |
|-----------|-------------|
| M2.1 | Playable overworld section (1 region) |
| M2.2 | Dungeon 1 (complete, with boss) |
| M2.3 | Core combat system (sword, bow, basic enemies) |
| M2.4 | UI/HUD implemented (hearts, inventory, dialogue) |
| M2.5 | Music for overworld + dungeon 1 |

### Phase 3: Full Content Production (Weeks 11–24)

| Milestone | Deliverable |
|-----------|-------------|
| M3.1 | All 8 dungeons complete with bosses |
| M3.2 | Full overworld with all regions |
| M3.3 | All key items and enemy types implemented |
| M3.4 | NPC dialog, quests, and shop system |
| M3.5 | Dark Mirror puzzle chambers implemented |
| M3.6 | Complete music and sound design |
| M3.7 | Save system, menus, settings |

### Phase 4: Polish & Launch (Weeks 25–30)

| Milestone | Deliverable |
|-----------|-------------|
| M4.1 | Bug fix pass (internal QA) |
| M4.2 | Balance pass (difficulty, item placement) |
| M4.3 | External playtest feedback |
| M4.4 | Performance optimization |
| M4.5 | Store page, trailers, press kit |
| M4.6 | **Launch** — PC (Steam / itch.io) |

### Phase 5: Post-Launch (Weeks 31+)

- Bug fixes and patches
- Community feedback and potential content additions

---

## Appendix

### A. Glossary

| Term | Definition |
|------|-----------|
| **Rupee** | In-game currency (Green, Blue, Red, Purple, Silver) |
| **Heart Piece** | Collectible that fills a Heart Container (4 pieces = 1 heart) |
| **Sage** | NPCs who guard dungeons and grant story progression |
| **Hookshot** | Grappling hook item for traversal and combat |
| **Dark Mirror** | A temporary single-screen puzzle chamber with an inverted light/dark environment |
| **Fair Trade** | Trade system — give specific item to NPC to receive reward |
| **Pegasus Boots** | Item that allows dashing and ramming |
| **Magic Meter** | Resource that depletes when using special items, regenerates over time |

### B. References

- *The Legend of Zelda: A Link to the Past* (SNES, 1991) — Nintendo
- *The Legend of Zelda: Tears of the Kingdom* (Switch, 2023) — Nintendo
- *Secret of Mana* (SNES, 1993) — Square Enix
- *Zelda II: The Adventure of Link* (NES, 1987) — Nintendo
- *Oracle of Ages / Seasons* (GBC, 2001) — Nintendo

### C. Decisions Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | Indie experience | Smaller team, faster iteration, quality over quantity |
| Dark World | Temporary single-screen forays only | Reduces complexity significantly while keeping the dark world feel |
| Procedural Generation | None at runtime | All content handcrafted for quality; procedural tools allowed in dev only |
| New Game+ | No | Out of scope for an indie release |
| Localization | English only | Reduces translation/testing overhead for a first release |
| Achievements | No | Out of scope; focus on core gameplay experience |

---

*End of Requirements Document*
