# Art Style Guide

## Game Title: The Shadows of the Mirror
### Resolution: 256x224 (NES resolution)

## Color Palette

### Core Palette (32 colors)
- **Sky/Background**: Soft blues, warm grays
- **Grass**: Multiple shades of green (dark to light)
- **Stone/Brick**: Earthy browns with purple accents
- **Water**: Blues with highlights
- **Dungeon**: Dark purples, grays, and deep blues

### Shadow Palette
- Dark blues and grays
- No pure black — use dark blue (#2A2A3E)

### Light Palette
- Soft yellows and whites
- Use for highlights on surfaces

### Player Palette
- **Heroine**: Blue tunic (#3A5FC0), brown hair (#7B5B3B)
- **Hero**: Green tunic (#3A7A3A), blonde hair (#D4A04B)

### Enemy Palettes
- Use distinct 4-color palettes
- Keep enemy colors readable against backgrounds
- Avoid green enemies on green backgrounds

## Character Design

### Player Character
- **Size**: 8x8 pixels (4x4 tiles)
- **Style**: Top-down Zelda-like
- **Animation frames**: 3 per direction (idle, walk)
- **Directional**: 4 cardinal directions

### Enemies
- **Small enemies**: 4x4 pixels (2x2 tiles)
- **Large enemies**: 8x8 pixels (4x4 tiles)
- **Bosses**: 16x16 pixels (8x8 tiles)

### NPCs
- Use simple 4x4 pixel sprites
- Color-coded by role (shopkeeper, quest giver)

## Tileset Design

### Overworld Tiles
- **Size**: 8x8 pixels (4x4 tiles)
- **Grid**: 16x16 tiles per screen
- **Layers**: 2 (foreground/background)

### Dungeon Tiles
- **Size**: 8x8 pixels (4x4 tiles)
- **Grid**: 16x16 tiles per screen
- **Layers**: 2 (foreground/background)

## UI Elements

### HUD
- Health bars: 3x8 pixel blocks
- Hearts: 8x8 pixel icons
- Mini-map: 8x8 pixel display

### Menu System
- Use pixel-perfect fonts (6x8 pixel font)
- Color-coded buttons (green = confirm, red = cancel)
- Consistent border style (dark purple with light highlight)

## Animation Guidelines

### Frame Rate
- 30 FPS
- Player: 3 frames per animation cycle
- Enemies: 2-4 frames per cycle

### Transition
- Use dissolve effect between screens
- Fade to black between scenes
- 15-frame transition animations
