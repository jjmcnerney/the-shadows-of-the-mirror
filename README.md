# The Shadows of the Mirror

A 16-bit Zelda-like action-adventure built in **Godot 4.7.1**, rendered at a
256×224 internal resolution with integer upscaling for a crisp pixel-art look.

> Status: **Phase 1 complete** (engine foundation, player controller, the
> Cathedral Crypts prologue dungeon, inventory with a working bow, and a verified
> test harness). See [`docs/phase1-gate.md`](docs/phase1-gate.md) for the
> acceptance criteria and [`docs/phase1-summary.md`](docs/phase1-summary.md) for
> the milestone summary.

## Controls

| Action        | Keys                |
|---------------|---------------------|
| Move          | WASD / Arrow keys   |
| Attack (sword)| J                   |
| Bow (arrow)   | K                   |
| Use item      | L                   |
| Interact      | Space               |
| Quick-swap item | U                 |
| Pause         | Esc                 |

## Run it

Open `project.godot` in Godot 4.7.1 and press **F5** (or run `main_menu.tscn`).
From the menu, **New Game** drops you into the Cathedral Crypts.

## Test

The off-tree harness runs 14 headless assertions (engine, player, dungeon,
save, pickups, arrow damage):

```bash
~/godot --headless --path . res://scenes/main/test_root.tscn
```

A passing run prints `=== All tests passed ===`.

## Export (Windows)

```bash
~/godot --headless --path . --export-release "Windows" export/shadows_of_the_mirror.exe
```

Produces `export/shadows_of_the_mirror.exe` + `.pck` (the `.exe`/`.pck` are
git-ignored — see `.gitignore`).

## Project layout

```
the-shadows-of-the-mirror/
├── project.godot
├── export_presets.cfg
├── scenes/            # player, dungeons, enemies, items, ui, world, main, tools
├── scripts/
│   ├── core/          # GameManager, AudioManager autoloads
│   └── tools/         # test_player.gd (headless harness)
├── assets/            # art, audio, tilesets
└── docs/              # phase1-gate.md, phase1-summary.md, art-style-guide.md
```

## Notes

- Art is placeholder/procedural this early; everything is kept pixel-perfect by
  design (Nearest texture filtering, no bilinear blur).
- The `export/` directory is git-ignored; the build artifacts are not committed.
