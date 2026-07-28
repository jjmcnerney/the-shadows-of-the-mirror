# Phase 1 Summary: Engine Foundation, Player, & Prologue Dungeon

## Status: ✅ COMPLETE (gate passed — see `docs/phase1-gate.md`)

## Timeline: Weeks 1–? (pre-production + technical foundation)

## What We Built

### Engine & Pipeline
- Godot 4.7.1 at `~/godot`; project at 256×224 internal res, integer upscale.
- `GameManager` + `AudioManager` autoload singletons (inventory, save/load,
  SFX bus).
- Windows export preset (main scene = `main_menu`); builds + runs.

### Player Controller (`scenes/player/`)
- 8-directional movement (accel/friction), tilemap collision on all 4 sides.
- Sword attack (key-down, cardinal, single-hit/swing + cooldown).
- Passive frontal shield block (Basic Shield key item).
- Hurt/stun + i-frames (control returns after stun, not after i-frames).

### Cathedral Crypts — Prologue Dungeon (`scenes/dungeons/cathedral_crypts.gd`)
- Real `TileSet`-driven tilemap (16×16 source). The earlier sprite-dungeon
  fallback was abandoned per plan.
- 3 rooms, 2-tile-tall doorways, enemy spawns (octorok + moblin).
- Save point + reusable `SavePoint` scene; `GameManager.save/load`.

### Inventory & Items (criterion 9)
- Generic visible `Pickup` scene (`scenes/items/pickup.tscn`) — sprite + jingle,
  grants key items / consumables / heart refill on overlap.
- **Bow**: pickup grants Bow + 10 starter arrows. `K` fires a real `Arrow`
  projectile (`scenes/items/arrow.tscn`) that damages the first enemy hit and is
  consumed (1/shot). Starting ammo defaults to 0 — ammo comes only from pickups.
- Demo consumable pickups (arrows +5, rupees +5, heart refill) prove the
  acquire procedure for all item kinds.
- HUD (`scenes/ui/hud.gd`) shows hearts, enemy count, **Arrows**, **Rupees**.

### Audio
- Procedural `item_get` jingle (arpeggio) added to `AudioManager`.

## File Structure (current)
```
the-shadows-of-the-mirror/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── player/      player.tscn / player.gd
│   ├── dungeons/    cathedral_crypts.tscn / .gd
│   ├── enemies/     enemy_base.gd, octorok.*, moblin.*
│   ├── items/       pickup.tscn/.gd, arrow.tscn/.gd
│   ├── ui/          hud.tscn / .gd
│   ├── world/       save_point.tscn / .gd
│   ├── main/        main_menu.*, test_root.tscn
│   └── tools/       screenshot_debug.gd
├── scripts/
│   ├── core/        game_manager.gd, audio_manager.gd
│   └── tools/       test_player.gd   (headless harness, 14 tests)
├── assets/          art/, audio/sfx/, tilesets/
└── docs/            phase1-gate.md, phase1-summary.md, art-style-guide.md
```

## Test Results
- ✅ 14/14 off-tree harness tests pass (`test_root.tscn`):
  engine, player, dungeon load, save/load, **T13** Pickup→bow+arrows,
  **T14** Arrow→enemy damage.
- ✅ Player-verified in-editor: bow feel, arrow count (0→10→15, decrements),
  rupees readout.
- ✅ Windows export rebuilds clean.

## Known Issues / Out of Scope (Phase 2)
- Lamp / Bomb Bag / Shield *record* the key item; their mechanics are Phase 2.
- Heart pieces wired in `GameManager` but not yet placed in a dungeon.
- Art is placeholder/procedural; no music yet.

## How to Run / Verify
```bash
# tests
~/godot --headless --path . res://scenes/main/test_root.tscn
# windows export
~/godot --headless --path . --export-release "Windows" export/shadows_of_the_mirror.exe
```

## Next Steps (Phase 2)
1. Vertical slice: Central Kingdom → Cathedral Crypts → Cave → Gohma (boss).
2. Dungeon generation / richer room content.
3. Enemy AI polish.
4. Full UI (menus, dialog, inventory screen).
5. Audio: music + remaining SFX.
6. Save-system hardening (multiple slots, meta-progression).
7. Art pass (replace placeholders).
