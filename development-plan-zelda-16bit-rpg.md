# The Shadows of the Mirror — Development Plan

**Version:** 1.0  
**Date:** July 20, 2026  
**Based on:** Requirements Document v1.1 (`requirements-zelda-16bit-rpg.md`)  
**Status:** Ready for Execution  

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technical Architecture](#2-technical-architecture)
3. [Phase 1: Pre-Production (Weeks 1–4)](#3-phase-1-pre-production-weeks-14)
4. [Phase 2: Vertical Slice (Weeks 5–10)](#4-phase-2-vertical-slice-weeks-510)
5. [Phase 3: Full Content Production (Weeks 11–24)](#5-phase-3-full-content-production-weeks-1124)
6. [Phase 4: Polish & Launch (Weeks 25–30)](#6-phase-4-polish--launch-weeks-2530)
7. [Phase 5: Post-Launch (Weeks 31+)](#7-phase-5-post-launch-weeks-31)
8. [Risk Assessment & Mitigation](#8-risk-assessment--mitigation)
9. [Resource & Team Requirements](#9-resource--team-requirements)
10. [Quality Gates & Acceptance Criteria](#10-quality-gates--acceptance-criteria)

---

## 1. Project Overview

### 1.1 Vision
Create a polished 6-hour indie action-adventure game inspired by *A Link to the Past*, featuring handcrafted exploration, 8 dungeons, and a tight 16-bit aesthetic — all delivered on PC via Steam and/or itch.io.

### 1.2 Scope Boundaries (What We're NOT Doing)
- ❌ No New Game+
- ❌ No localization (English only)
- ❌ No achievements/trophies
- ❌ No Nintendo Switch port
- ❌ No runtime procedural generation
- ❌ No cutscenes — story delivered via dialogue

### 1.3 Key Metrics
| Metric | Target |
|--------|--------|
| Playtime | ~6 hours |
| Dungeons | 8 (1 prologue + 7 main + final) |
| Enemies | 15+ types |
| Key Items | 17+ |
| Overworld Secrets | 58 |
| Dungeon Secrets | 42 |
| Total Secrets | 100 |
| Music Themes | 11 |
| Heart Pieces | 36 (9 heart containers) |
| Max Hearts | 20 |

---

## 2. Technical Architecture

### 2.1 Engine Selection

**Recommendation: Godot 4.x**

**Rationale:**
- Free and open-source — no licensing risk for indie release
- Excellent 2D support with built-in pixel-perfect rendering pipeline
- GDScript for rapid iteration; C# option if performance-critical code needed later
- Tiled map editor integration for handcrafted levels
- Lightweight at < 100 MB download — no overhead concerns
- Strong community despite smaller retro-game focus (mitigated by our small scope)

**Fallback:** GameMaker Studio 2 if Godot proves insufficient during pre-production.

### 2.2 Project Structure

```
the-shadows-of-the-mirror/
├── assets/
│   ├── art/
│   │   ├── characters/          # Player, enemies, NPCs
│   │   ├── tilesets/            # Overworld, dungeons, interiors
│   │   ├── ui/                  # HUD, menus, dialogue boxes
│   │   ├── effects/             # Particles, transitions
│   │   └── backgrounds/         # Parallax layers
│   ├── audio/
│   │   ├── music/               # 11 themes
│   │   └── sfx/                 # Combat, damage, pickups, world, UI
│   └── maps/
│       ├── overworld/           # 800×600 tile map
│       ├── dungeons/            # Per-dungeon Tiled files
│       └── interiors/           # Towns, caves, shrines
├── scenes/
│   ├── player/                  # Player controller, animations
│   ├── enemies/                 # Enemy base classes + variants
│   ├── items/                   # Key items, consumables
│   ├── world/                   # Overworld, tiles, interactables
│   ├── ui/                      # HUD, menus, dialogue
│   ├── dungeons/                # Dungeon-specific mechanics
│   └── main/                    # Main menu, save/load
├── scripts/
│   ├── core/                    # Game state, input, camera
│   ├── gameplay/                # Combat, movement, physics
│   ├── systems/                 # Inventory, save, economy
│   └── tools/                   # Editor tools, procedural dev aids
├── data/
│   ├── configs/                 # Game settings, enemy stats, item data
│   └── dialogue/                # NPC scripts, text data
└── export/
    └── builds/                  # Exported builds per milestone
```

### 2.3 Core Systems Architecture

| System | Responsibility | Tech Approach |
|--------|---------------|---------------|
| **Game State** | Player state, inventory, progress | Singleton `GameManager` with serialized save data |
| **Input** | Keyboard + gamepad remapping | Godot `InputMap` with runtime remapping UI |
| **Movement** | 8-directional walk, dash, jump, swim, climb | State machine: Walk, Dash, Jump, Swim, Climb, Interact |
| **Combat** | Sword, spin attack, bow, item-based attacks | Attack state machine + hitbox/hurtbox overlap |
| **AI** | Enemy behavior (aggro, patrol, alert) | State machine per enemy type (Idle, Patrol, Chase, Attack, Stunned) |
| **Tilemap** | Overworld + dungeon rendering | Godot `TileMap` with custom collision + culling |
| **Inventory** | Key items, consumables, quick-swap | `Dictionary`-based with serialization |
| **Save/Load** | 3 save slots, manual + auto-save | Binary or JSON with encryption |
| **Audio** | Music streaming, SFX mixing | Godot `AudioServer` with bus routing |
| **Dialogue** | NPC text, scrolling, yes/no choices | Script-driven dialogue system |

### 2.4 Rendering Pipeline

- **Resolution:** Native 256×224, scaled 3×–4× with `pixel_snap` enabled
- **Color Pipeline:** 32–64 colors per sprite, hand-picked palettes
- **Tile Culling:** Only render viewport + 1 tile buffer (per §14.2)
- **Sprite Batching:** Group by palette for draw call reduction (per §14.2)
- **Particle Budget:** Max 200 active particles (per §14.2)
- **Sprite Budget:** 50+ on-screen without framerate drop (per §14.1)

---

## 3. Phase 1: Pre-Production (Weeks 1–4)

**Objective:** Establish foundation — engine, core movement, art direction, and world blockout.

### Week 1: Engine Setup & Core Systems

| Task | Deliverable | Owner |
|------|-------------|-------|
| T1.1.1: Install Godot 4.x, set up project | Project structure created, version control initialized | Tech Lead |
| T1.1.2: Configure rendering pipeline (256×224, pixel snap) | Pixel-perfect rendering confirmed | Tech Lead |
| T1.1.3: Set up input system with `InputMap` | WASD + J/K/L/Space mapped; gamepad skeleton | Tech Lead |
| T1.1.4: Create `GameManager` singleton | Save slot infrastructure, game state singleton | Tech Lead |
| T1.1.5: Create `AudioManager` singleton | Music streaming, SFX bus routing functional | Tech Lead |

### Week 2: Player Controller & Combat Foundation

| Task | Deliverable | Owner |
|------|-------------|-------|
| T1.2.1: Implement 8-directional movement (walk) | Player moves 8-directionally at normal speed | Tech Lead |
| T1.2.2: Implement dash (hold, cardinal only) | Dash works, sword faces forward during dash | Tech Lead |
| T1.2.3: Implement jump (contextual, slopes/gaps) | Jump works on slopes and gaps | Tech Lead |
| T1.2.4: Implement tile-based collision (X + Y axis) | No clipping through walls; landing snap works | Tech Lead |
| T1.2.5: Sword attack (tap, cardinal directions) | Sword hits enemies, damage applied | Tech Lead |
| T1.2.6: Spin attack (hold → release) | 360° slash with knockback | Tech Lead |
|| T1.2.7: Passive shield block (frontal) | Player blocks frontal projectiles while facing enemy | Tech Lead |
|| T1.2.8: Bow / Shoot action (cardinal only) | Arrow fires in facing cardinal direction; Bow item not yet acquired — placeholder action | Tech Lead |
|| T1.2.9: Item use action (cardinal only) | Use equipped item in facing cardinal direction; placeholder for item system | Tech Lead |

### Week 3: Art Style Guide & Music Direction

| Task | Deliverable | Owner |
|------|-------------|-------|
| T1.3.1: Define 16-bit color palettes (overworld) | 2–3 approved palettes for Central Kingdom region | Artist |
| T1.3.2: Create player sprite (16×16, 4 directions) | Walk + attack + dash + spin animations | Artist |
| T1.3.3: Create 2 enemy sprites (Octorok, Moblin) | Idle + attack + hurt + death animations | Artist |
| T1.3.4: Create basic overworld tileset (Central Kingdom) | 16×16 tiles: grass, path, wall, water, tree | Artist |
| T1.3.5: Compose 3 overworld theme samples | 3 distinct themes approved by lead designer | Composer |
| T1.3.6: Compose 1 dungeon theme sample | Dungeon theme sample approved | Composer |
| T1.3.7: Create core SFX (sword, enemy hit, pickup) | 5–8 basic SFX functional in-engine | Composer |

### Week 4: World Blockout & First Enemies

| Task | Deliverable | Owner |
|------|-------------|-------|
| T1.4.1: Blockout Central Kingdom region (800×600) | Tilemap with 3 biomes, basic enemy placement | Designer |
| T1.4.2: Implement enemy AI base class | Aggro radius + patrol + alert states | Tech Lead |
| T1.4.3: Implement Octorok behavior | Spits rocks, hides in shell | Tech Lead |
| T1.4.4: Implement Moblin behavior | Patrols, charges when aggroed | Tech Lead |
| T1.4.5: Create Cathedral Crypts blockout (prologue) | Dungeon tilemap with key item room, boss room | Designer |
| T1.4.6: Implement basic save system | Manual save at save point, 3 save slots | Tech Lead |

### Phase 1 Gate Review

| Criterion | Pass/Fail |
|-----------|-----------|
| Player moves 8-directionally with dash, jump, sword, spin attack, shield | ☐ |
| Player can shoot bow (cardinal action) and use items (cardinal action) | ☐ |
| 2 enemy types functional with AI | ☐ |
| Cathedral Crypts blockout exists | ☐ |
| Player sprite + 2 enemy sprites + tileset in-engine | ☐ |
| 3 music samples + 5 SFX in-engine | ☐ |
| Save system functional | ☐ |
| 60 FPS maintained with 20+ sprites on-screen | ☐ |

---

## 4. Phase 2: Vertical Slice (Weeks 5–10)

**Objective:** A playable slice demonstrating the full loop: overworld exploration → dungeon → boss → reward → overworld re-exploration.

### Week 5: Overworld Polish & Central Kingdom

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.1.1: Complete Central Kingdom overworld | Full region with NPCs, shops, save point | Designer + Artist |
| T2.1.2: Implement NPC dialogue system | Scrolling text box with yes/no options | Tech Lead |
| T2.1.3: Implement shop system | Buy/sell interface with rupee economy | Tech Lead |
| T2.1.4: Implement interactable objects | Doors, switches, save points | Tech Lead |
| T2.1.5: Add Heart Piece placement (first 4) | 1 heart container obtainable from overworld | Designer |

### Week 6: Prologue Dungeon (Cathedral Crypts)

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.2.1: Complete Cathedral Crypts tileset | Dungeon-specific tiles, parallax | Artist |
| T2.2.2: Implement Lamp (dark room lighting) | Light reveals dark areas, burns bushes | Tech Lead + Artist |
| T2.2.3: Implement Bomb Bag (20 bombs, breakable rocks) | Bombs placed on ground, explode after delay | Tech Lead |
| T2.2.4: Place Stalfos miniboss | Skeleton guards Bomb Bag, reassembles | Tech Lead |
| T2.2.5: Implement basic puzzle (switch → door) | First dungeon puzzle type | Designer |
| T2.2.6: Complete prologue dungeon flow | Player gets Lamp → Bomb Bag → exits | Designer + Tech Lead |

### Week 7: Dungeon 1 (Cave of Beginnings)

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.3.1: Complete Cave of Beginnings tileset | Forest/cave themed tiles | Artist |
| T2.3.2: Implement Bow & Arrows | Ranged attack, hits switches, lights torches | Tech Lead + Artist |
| T2.3.3: Place 3 puzzles + miniboss + boss room | Dungeon layout complete | Designer |
| T2.3.4: Create Gohma-like boss | Multi-phase boss with telegraphed attacks | Tech Lead + Artist |
| T2.3.5: Heart Container reward on boss defeat | Boss drops heart container | Tech Lead |
| T2.3.6: Complete Dungeon 1 playthrough | Full dungeon playable with Bow as reward | Team |

### Week 8: UI/HUD & Inventory

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.4.1: Implement Heart Container display | 16×16 hearts, full/half/quarter/empty | Artist + Tech Lead |
| T2.4.2: Implement 8-slot item HUD bar | Quick-swap between items | Artist + Tech Lead |
| T2.4.3: Implement pause menu inventory | Key items + consumables, one-line descriptions | Artist + Tech Lead |
| T2.4.4: Implement boss health bar | Decorative banner with animated indicator | Artist + Tech Lead |
| T2.4.5: Implement rupee counter | Green/Blue/Red rupees with proper values | Artist + Tech Lead |
| T2.4.6: Implement dialogue box | Classic SNES-style scrolling text | Artist + Tech Lead |

### Week 9: Audio Integration & Dark Forest Region

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.5.1: Overworld music for Central Kingdom + Dark Forest | 2 seamless-looping themes | Composer |
| T2.5.2: Dungeon 1 music + SFX integration | Dungeon theme, boss theme, all SFX mapped | Composer |
| T2.5.3: Blockout Dark Forest region | Eerie woods with early-game challenge | Designer |
| T2.5.4: Implement Poe + Keese enemies | Light weakness for Poe, bat behavior for Keese | Tech Lead + Artist |
| T2.5.5: Transition system (fade between areas) | Smooth fade overworld ↔ dungeon ↔ interior | Tech Lead |

### Week 10: Vertical Slice Integration

| Task | Deliverable | Owner |
|------|-------------|-------|
| T2.6.1: Play full loop: Overworld → Cathedral → Dungeon 1 | Complete experience from village to Gohma | Team |
| T2.6.2: Balance pass (difficulty, item placement) | Tuning sword damage, enemy health, rupee economy | Designer |
| T2.6.3: Polish visual effects | Screen flash, enemy flash, transitions, item sparkle | Artist |
| T2.6.4: Internal playtest session | Feedback collected, bug list created | Team |
| T2.6.5: Bug fix pass | All critical and blocking bugs resolved | Tech Lead |

### Phase 2 Gate Review

| Criterion | Pass/Fail |
|-----------|-----------|
| Complete gameplay loop: Overworld → Prologue → Dungeon 1 → Boss → Reward → Re-exploration | ☐ |
| Player has full inventory (Lamp, Sword, Bow, Bombs) | ☐ |
| All UI elements functional (hearts, HUD, pause menu, dialogue) | ☐ |
| 5+ enemy types implemented | ☐ |
| Boss fight with multi-phase behavior | ☐ |
| Music + SFX integrated | ☐ |
| Save system with 3 slots | ☐ |
| 60 FPS maintained | ☐ |

---

## 5. Phase 3: Full Content Production (Weeks 11–24)

**Objective:** Build out all 8 dungeons, all overworld regions, all key items, enemies, NPCs, and systems.

### Week 11–12: Dungeons 2–3 & New Items

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.1.1: Sunken Temple tileset + Hookshot | Hookshot grapples to targets, pulls player | Artist + Tech Lead |
| T3.1.2: Serpent boss (Sunken Temple) | Multi-phase boss | Tech Lead |
| T3.1.3: Volcanic Fortress tileset + Red Armor | Damage reduction + heat resistance | Artist + Tech Lead |
| T3.1.4: Dragon boss (Volcanic Fortress) | Multi-phase boss | Tech Lead |
| T3.1.5: Complete both dungeons | Playable with full puzzle/boss flow | Designer |
| T3.1.6: Implement swimming mechanics | Restricted movement, indefinite breathing | Tech Lead |
| T3.1.7: Swamplands region blockout + polish | Murky marsh, navigation puzzles | Designer + Artist |
| T3.1.8: Add Lynel + Stalfos (if not already) | Aggressive melee, reassembling skeleton | Tech Lead + Artist |

### Week 13–14: Dungeon 4 & Mountain Region

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.2.1: Ice Cavern tileset + Hammer | Hammer drives stakes, cracks ground | Artist + Tech Lead |
| T3.2.2: Frost giant boss (Ice Cavern) | Multi-phase boss | Tech Lead |
| T3.2.3: Mountain Region tileset + polish | Peaks, caves, volcanic areas | Artist |
| T3.2.4: Add climbing mechanics (stairs/ladders/ramps) | Ladder interaction, ramp detection | Tech Lead |
| T3.2.5: Add Wizzrobe + Armos enemies | Teleporting mage, activating statues | Tech Lead + Artist |
| T3.2.6: Complete Mountain Region secrets | Bombable rocks, pushable blocks | Designer |

### Week 15–16: Dungeon 5 & Desert Region

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.3.1: Desert Pyramid tileset + Power Glove | Lift heavy objects | Artist + Tech Lead |
| T3.3.2: Mummy/pharaoh boss (Desert Pyramid) | Multi-phase boss | Tech Lead |
| T3.3.3: Desert Region tileset + polish | Sand dunes, ancient tombs, heat damage | Artist |
| T3.3.4: Add Darknut + Like Like enemies | Armored deflector, item-stealing blob | Tech Lead + Artist |
| T3.3.5: Implement mini-games (bow contest) | Bow contest with scoring | Tech Lead |

### Week 17–18: Dungeons 6–7 & Coastal/Dark Forest

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.4.1: Storm Tower tileset + Mirror Shield | Reflects beams and lasers | Artist + Tech Lead |
| T3.4.2: Storm elemental boss (Storm Tower) | Multi-phase boss | Tech Lead |
| T3.4.3: Shadow Castle tileset + Magic Cape | Phase through obstacles, invincibility frames | Artist + Tech Lead |
| T3.4.4: Shadow king boss (Shadow Castle) | Multi-phase boss | Tech Lead |
| T3.4.5: Coastal Region tileset + polish | Beaches, lighthouse, shipwrecks | Artist |
| T3.4.6: Add Bubble + ChuChu enemies | Shield-disabling skull, splitting blob | Tech Lead + Artist |
| T3.4.7: Implement fishing mini-game | Fishing with scoring system | Tech Lead |

### Week 19: Final Dungeon & Final Boss

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.5.1: Sky Citadel tileset + Silver Bow | Powerful ranged attack, final boss weapon | Artist + Tech Lead |
| T3.5.2: Final boss encounter | Multi-phase, telegraphed attacks, weak points | Tech Lead |
| T3.5.3: Final dungeon theme + final boss theme | Unique music for both | Composer |
| T3.5.4: End-game dialogue + credits | NPC dialogue wrapping the story | Designer |

### Week 20: NPC Network, Shops, Quests

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.6.1: All town NPCs with dialogue | 50–75 dialogue lines across all NPCs | Designer |
| T3.6.2: Blacksmith (sword upgrades ×3, shield ×2) | Upgrade system with visual feedback | Tech Lead |
| T3.6.3: Herbalist (full heal + fairy potions) | Healing shop | Tech Lead |
| T3.6.4: Witch's Hut (Fire Rod, Ice Rod, heart refills) | Item shop with unlock conditions | Tech Lead |
| T3.6.5: Sage rescue side quest (7 sages) | Scattered across dungeons/overworld | Designer |
| T3.6.6: Shopkeeper tasks (fetch quests, enemy kills) | Simple NPC quests | Designer |
| T3.6.7: Digging competition mini-game | Digging with scoring system | Tech Lead |

### Week 21: Dark Mirrors & Secrets

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.7.1: 7 Dark Mirror puzzle chambers | One per overworld zone, light↔dark inversion | Designer + Artist |
| T3.7.2: All 58 overworld secrets placed | Heart pieces, rupees, arrows, bombs, refills | Designer |
| T3.7.3: All 42 dungeon secrets placed | Hidden doors, bomb doors, burning bushes | Designer |
| T3.7.4: Secret reveal effects | Shaking blocks, dissolving walls | Artist |

### Week 22: Full Music & Sound Design

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.8.1: All 11 music themes composed | Overworld ×7, Dungeon ×1, Boss ×1, Final Dungeon ×1, Final Boss ×1 | Composer |
| T3.8.2: Complete SFX library | Combat, damage, pickups, world, UI | Composer |
| T3.8.3: Audio mixing & bus configuration | Music/SFX levels balanced, no clipping | Composer |
| T3.8.4: Music transition system | Seamless crossfades between themes | Tech Lead |

### Week 23: Save System Polish & Settings

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.9.1: Auto-save (post-dungeon, post-key-item) | Triggers automatically | Tech Lead |
| T3.9.2: Save file encryption | Prevent cheating | Tech Lead |
| T3.9.3: Controls menu (remappable keys) | All bindings configurable | Tech Lead + Artist |
| T3.9.4: Accessibility options | Reduce screen shake, disable flashing | Tech Lead |
| T3.9.5: Main menu & title screen | Title, start, continue, quit | Tech Lead + Artist |
| T3.9.6: Minimap (dungeon-only, 8×8 pixel style) | Toggleable in pause menu | Artist + Tech Lead |

### Week 24: Content Completion Review

| Task | Deliverable | Owner |
|------|-------------|-------|
| T3.10.1: Full playthrough — first time | No items missing, no broken paths | Designer |
| T3.10.2: Full playthrough — 100% completion | All secrets, all sages, all heart pieces | Designer |
| T3.10.3: Content gap analysis | Missing art, audio, or systems identified | Designer |
| T3.10.4: Gap closure sprint | All gaps filled | Team |

### Phase 3 Gate Review

| Criterion | Pass/Fail |
|-----------|-----------|
| All 8 dungeons complete with bosses, items, puzzles | ☐ |
| All 7 overworld regions complete | ☐ |
| All 15+ enemy types implemented | ☐ |
| All 17+ key items functional | ☐ |
| All NPC dialog, shops, and quests working | ☐ |
| All 100 secrets placed (58 overworld + 42 dungeon) | ☐ |
| 7 Dark Mirror chambers implemented | ☐ |
| 11 music themes + full SFX library | ☐ |
| Save system (manual + auto, encrypted, 3 slots) | ☐ |
| Controls menu + accessibility options | ☐ |
| Two complete playthroughs validated (standard + 100%) | ☐ |
| 60 FPS maintained with all systems active | ☐ |

---

## 6. Phase 4: Polish & Launch (Weeks 25–30)

**Objective:** Ship a polished, bug-free game.

### Week 25: Internal QA Pass

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.1.1: Create bug tracking spreadsheet | All issues categorized (Critical/High/Medium/Low) | Designer |
| T4.1.2: First QA sweep | Playthrough with eyes on bugs, not fun | Designer |
| T4.1.3: Fix all Critical and High bugs | No crashes, no soft-locks, no missing content | Tech Lead |

### Week 26: Balance Pass

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.2.1: Sword damage tuning | Balance across all enemies | Designer |
| T4.2.2: Enemy health/damage tuning | Scaling feels right from early to late game | Designer |
| T4.2.3: Rupee economy tuning | Player never starves for bombs/arrows | Designer |
| T4.2.4: Heart Piece distribution review | 36 pieces feel rewarding without being trivial | Designer |
| T4.2.5: Boss difficulty tuning | Bosses are challenging but fair | Designer |

### Week 27: External Playtest

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.3.1: Recruit 5–10 external testers | Friends, Discord community, itch.io playtesters | Designer |
| T4.3.2: Conduct playtest sessions | Record sessions, collect feedback | Designer |
| T4.3.3: Analyze feedback | Identify top 10 issues to fix | Designer |
| T4.3.4: Implement fixes | Address highest-impact feedback | Team |

### Week 28: Performance Optimization

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.4.1: Tilemap culling optimization | Only render viewport + 1 tile | Tech Lead |
| T4.4.2: Sprite batching by palette | Reduced draw calls | Tech Lead |
| T4.4.3: Enemy AI distance gating | Distant enemies use simplified AI | Tech Lead |
| T4.4.4: Music streaming verification | No full-load into memory | Tech Lead |
| T4.4.5: Build size check | < 500 MB total install | Tech Lead |
| T4.4.6: Memory check | < 256 MB runtime | Tech Lead |
| T4.4.7: Load time check | < 3s area, < 1.5s dungeon with fade | Tech Lead |

### Week 29: Store Preparation

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.5.1: Steam/itch.io store page draft | Title, description, screenshots, trailer | Designer |
| T4.5.2: Game trailer (2–3 minutes) | Showcases gameplay, dungeons, bosses | Designer |
| T4.5.3: Press kit | Logo, screenshots, feature list, dev quotes | Designer |
| T4.5.4: Final build packaging | Windows, macOS, Linux builds | Tech Lead |

### Week 30: Launch

| Task | Deliverable | Owner |
|------|-------------|-------|
| T4.6.1: Final build verification | Complete playthrough of final build | Designer |
| T4.6.2: Submit to Steam/itch.io | Store pages live, builds accepted | Designer |
| T4.6.3: **LAUNCH** | Game available for download | Team |

### Phase 4 Gate Review

| Criterion | Pass/Fail |
|-----------|-----------|
| No Critical or High bugs remaining | ☐ |
| All performance targets met (§14.1) | ☐ |
| External playtest feedback incorporated | ☐ |
| Store pages live | ☐ |
| Builds available on all target platforms (Windows, macOS, Linux) | ☐ |
| Total install size < 500 MB | ☐ |
| Runtime memory < 256 MB | ☐ |
| 60 FPS locked | ☐ |

---

## 7. Phase 5: Post-Launch (Weeks 31+)

**Objective:** Stabilize the game and build community.

| Task | Deliverable | Owner |
|------|-------------|-------|
| T5.1.1: Monitor crash reports & player feedback | Daily triage | Tech Lead |
| T5.1.2: Patch 1.0.1 (critical bugs) | Hotfix for launch-day issues | Tech Lead |
| T5.1.3: Patch 1.1.0 (balance + quality-of-life) | Fine-tuning based on real player data | Team |
| T5.1.4: Community engagement | Discord, Reddit, itch.io discussions | Designer |
| T5.1.5: Evaluate potential content additions | Based on community feedback | Designer |

---

## 8. Risk Assessment & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Art scope overruns** — Pixel art is slower than anticipated | High | Medium | Use procedural tools for layout drafts (§9.6); prioritize tileset reuse; establish strict palette constraints early |
| **Boss fight balance** — Multi-phase bosses harder than expected | Medium | Medium | Start simple, iterate playtest-driven; have fallback single-phase bosses ready |
| **100 secrets too many** — 100 handcrafted secrets is a lot of work | Medium | High | If behind schedule, reduce to 80 (fewer overworld secrets, keep dungeon secrets) |
| **Music production bottleneck** — 11 themes + SFX is a lot for one composer | High | Medium | Prioritize overworld + boss themes; dungeon themes can reuse the single dungeon theme with variations |
| **Godot 2D pipeline not mature enough** | Medium | Low | Fallback to GameMaker Studio 2 identified; pre-production will validate this early |
| **Scope creep — New Game+, localization, etc.** | High | Medium | Hard scope boundaries defined in §1.2; no feature additions without written approval |
| **Save file corruption** — Critical for a save-everything game | High | Low | Implement save file validation + backup; test extensively with corrupted saves |
| **Collision bugs** — Tile-based movement prone to clipping | High | Medium | Implement collision system in Week 2 with thorough testing; use proven patterns (see memory: Batsylvania collision debugging patterns) |

---

## 9. Resource & Team Requirements

### 9.1 Core Team

| Role | Headcount | Responsibilities |
|------|-----------|------------------|
| **Tech Lead / Programmer** | 1 | Engine, systems, combat, AI, collision, inventory, save |
| **Lead Designer / Level Designer** | 1 | World layout, dungeon design, pacing, balance |
| **Pixel Artist** | 1 | Player, enemies, NPCs, tilesets, UI, effects |
| **Composer / Sound Designer** | 1 | Music, SFX, audio mixing |

**Total core team: 4 people**

### 9.2 Tools & Software Budget

| Tool | Cost | Purpose |
|------|------|---------|
| Godot 4.x | Free | Game engine |
| Aseprite | $20 (one-time) | Pixel art |
| LSDj or Famitracker | Free | Chiptune music |
| Audacity | Free | SFX editing |
| Tiled | Free | Map editor |
| Git (GitHub) | Free | Version control |
| Figma | Free (starter) | Map design |
| **Total** | **$20** | |

### 9.3 Timeline Summary

| Phase | Weeks | Duration |
|-------|-------|----------|
| Pre-Production | 1–4 | 4 weeks |
| Vertical Slice | 5–10 | 6 weeks |
| Full Production | 11–24 | 14 weeks |
| Polish & Launch | 25–30 | 6 weeks |
| Post-Launch | 31+ | Ongoing |
| **Total to Launch** | | **30 weeks (~7.5 months)** |

---

## 10. Quality Gates & Acceptance Criteria

### 10.1 Per-Phase Gate Process

1. **Self-review:** Lead of each discipline reviews their own output
2. **Cross-review:** Team reviews each other's work
3. **Gate meeting:** All criteria checked; no phase transition until all pass
4. **Bug triage:** Any Critical/High bugs found during gate block the transition

### 10.2 Definition of Done (Per Task)

- [ ] Code committed to repository
- [ ] Functional in-engine (not just in editor)
- [ ] No new Critical bugs introduced
- [ ] Performance within targets (§14.1)
- [ ] Tested on at least 2 platforms (Windows + one other)

### 10.3 Definition of Done (Per Phase)

- [ ] All deliverables complete
- [ ] All gate criteria passed (§3–6)
- [ ] Playtest completed (internal or external)
- [ ] Bug count: 0 Critical, ≤5 High
- [ ] Performance within targets (§14.1)
- [ ] Build exported and verified

---

## Appendix A: Cross-References to Requirements

| Dev Plan Section | Requirements Doc Section |
|-----------------|------------------------|
| §2.1 | §3.2 (Engine options) |
| §2.2 | §3.3 (Resolution & scaling) |
| §2.4 | §4.1–4.4 (Visual design) |
| §T1.2 | §6.2 (Movement & physics) |
|| §T1.2.5–7 | §7.1–7.2 (Combat) |
|| §T1.2.8 | §6.1 / §13.4 (Shoot Bow) |
|| §T1.2.9 | §6.1 / §13.4 (Use Item) |
| §T3.x | §8.1 (Key items) |
| §T3.7.1–2 | §9.5 (Secrets) |
| §T2.2–3.5 | §10.1 (Dungeons) |
| §T3.x | §11.1 (Enemies) |
| §T3.6 | §11.3–11.4 (NPCs, upgrades) |
| §T3.7.1 | §12.3 (Dark Mirrors) |
| §T3.6.5 | §12.2 (Sage rescue) |
| §T3.9 | §13.3–13.4 (Save, input) |
| §T4.4 | §14.1–14.2 (Performance) |
| §Phase milestones | §15 (Milestone plan) |

---

*End of Development Plan*
