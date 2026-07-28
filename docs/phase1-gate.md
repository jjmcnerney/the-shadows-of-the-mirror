# Phase 1 Gate — Acceptance Criteria

**Project:** The Shadows of the Mirror (16-bit Zelda-like, Godot 4.7.1)
**Gate status:** ✅ PASSED
**Verified:** 2026-07-28 (off-tree harness, 14/14 tests; Windows export rebuilt)

This document defines "done" for Phase 1 so the gate is objective and
re-checkable from the repo, not from chat history. Each criterion is backed by
a test in `scripts/tools/test_player.gd` (run via `scenes/main/test_root.tscn`)
and/or an in-editor manual check.

## Engine & pipeline
- [x] Godot 4.7.1 project, 256×224 internal res, integer upscale (pixel-perfect).
- [x] `GameManager` + `AudioManager` autoloads reachable and functional.
- [x] Windows export preset builds and runs (main scene = `main_menu`).

## Player controller (T1.4.x)
- [x] 8-directional movement w/ accel + friction.
- [x] Sword attack on key-down, cardinal, single-hit per swing, cooldown.
- [x] Passive frontal shield block (Basic Shield key item).
- [x] Hurt/stun + i-frames, regains control after stun.

## Dungeon — Cathedral Crypts (prologue, T1.4.5)
- [x] Tilemap built with `TileSet` (16×16 source), NOT a sprite-dungeon fallback.
- [x] 3 connected rooms, 2-tile-tall doorways (player fits w/o pixel-stick).
- [x] Walls collide on all 4 sides (basic collision verified).
- [x] Enemies present (octorok + moblin), enemy count HUD updates.
- [x] Save point trigger + reusable `SavePoint` scene; `GameManager.save/load`.

## Inventory & items (criterion 9 — "working bow stack")
- [x] **Bow pickup** is a *visible* `Pickup` (sprite + jingle), grants the Bow
      key item **and a starter quiver of 10 arrows** on acquisition.
- [x] **Arrow projectile** spawns on the `bow` action (K), travels in the facing
      cardinal direction, deals damage to the first enemy hit, is consumed (1/ shot).
- [x] **Arrow pickup** exists (+5 arrows) and demo consumable pickups (rupees,
      heart refill) prove the spawn/acquire procedure for all kinds.
- [x] Starting ammo defaults to 0 — no free arrows; all ammo comes from pickups.
- [x] HUD shows live **Arrows** and **Rupees** counts (update on pickup / shot).

## Tests (off-tree harness, `test_root.tscn`)
T1–T12 (engine, player, dungeon, save) + **T13** (Pickup grants bow+arrows) +
**T14** (Arrow damages enemy on contact). All 14 pass.

## Manual in-engine checks (player-verified)
- [x] Bow fires a real, damage-dealing arrow at good speed/feel.
- [x] Arrow count: 0 at spawn → 10 after bow → 15 after arrow tile; decrements per shot.
- [x] Rupees: 0 → 5 after rupee tile (HUD readout).

## Known limitations (explicitly NOT Phase 1)
- Lamp / Bomb Bag / Shield pickups *record* the key item but their mechanics
  (dark-room light, placed bombs, block tuning) are Phase 2.
- Heart pieces (4 → 1 heart container) are wired in `GameManager` but not yet
  placed in a dungeon (per requirements, they belong in the overworld).
- No art pass yet — sprites are procedural/placeholder, pixel-perfect by design.

## How to re-verify
```bash
# Run the off-tree test harness (headless)
~/godot --headless --path . res://scenes/main/test_root.tscn

# Rebuild the Windows export
~/godot --headless --path . --export-release "Windows" export/shadows_of_the_mirror.exe
```
