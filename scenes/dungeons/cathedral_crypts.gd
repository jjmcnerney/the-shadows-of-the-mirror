# Cathedral Crypts — Prologue Dungeon Blockout
# Phase 1 (T1.4.5): dungeon tilemap with key item room + boss room
#
# Layout (3 rooms side by side, connected by 2-tile-tall doorways):
#   E = entrance      L = Lamp (first half)        B = Bomb Bag
#   S = Basic Shield  P = Bow (+ starter arrows)   X = exit/stairs
#   r = rupee         h = heart refill             a = arrow refill
#
# Per requirements §10.1: Cathedral Crypts is the prologue dungeon.
# Key items: Lamp (first half), Basic Shield (end), Bomb Bag (miniboss reward).

extends Node2D

## Dungeon layout. '#' = wall, '.' = floor.
## Letters mark key-item / exit / demo-pickup positions.
## Doorways at columns 6 and 12 are 2 tiles tall (rows 3-4) so the 16x16
## player body fits through with margin (1-tile doorways cause pixel-stick).
const MAP := [
	"###################",
	"#E....#...........#",
	"#...P.#..h..#..S..#",
	"#........B..#.....#",
	"#...........#....X#",
	"#..r..#.....#.....#",
	"#.....#........a..#",
	"#..L..#...........#",
	"#.....#.....#.....#",
	"###################",
]
const TILE := 16

const ENEMY_SCENES := {
	"octorok": preload("res://scenes/enemies/octorok.tscn"),
	"moblin": preload("res://scenes/enemies/moblin.tscn"),
	"stalfos": preload("res://scenes/enemies/stalfos.tscn"),
}
const PICKUP_SCENE: PackedScene = preload("res://scenes/items/pickup.tscn")
const ROCK_SCENE: PackedScene = preload("res://scenes/items/bombable_rock.tscn")
const PickupScript := preload("res://scenes/items/pickup.gd")
var _enemy_count: int = 0
@onready var tilemap: TileMap = $TileMap

# 4.7 tilemap handles (TileMap holds the TileSet; TileMapLayer holds cells)
var _tile_source_id: int = 0
var _tile_layer: TileMapLayer

# Game-over overlay shown when the player dies (Phase 1: pause + restart).
var _game_over_label: Label = null
var _is_game_over: bool = false

func _ready() -> void:
	_setup_tileset()
	_build_tiles()
	_build_collision()
	_spawn_player()
	_place_markers()
	_place_save_point()
	# Play dungeon placeholder music (track B)
	AudioManager.play_theme("dungeon_placeholder")
	print("[CathedralCrypts] Blockout ready (%dx%d tiles)" % [MAP[0].length(), MAP.size()])
	_spawn_baseline_enemies()
	_spawn_demo_rocks()
	_add_hud()
	GameManager.game_over.connect(_on_game_over)
	# Pixel-perfect: force NEAREST filtering on the tiles + tile layer so the
	# dungeon never bilinear-blurs.
	if _tile_layer != null:
		_tile_layer.texture_filter = 1
	if tilemap != null:
		tilemap.texture_filter = 1

func _find_char(ch: String) -> Vector2i:
	for y in range(MAP.size()):
		for x in range(MAP[y].length()):
			if MAP[y][x] == ch:
				return Vector2i(x, y)
	return Vector2i(-1, -1)

# ---- Tilemap (Godot 4.7: create_tile() is mandatory; set_cell goes on a TileMapLayer) ----
func _setup_tileset() -> void:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/art/dungeons/crypt_tileset.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	src.use_texture_padding = false
	# Create ONE tile per atlas cell. NOTE: create_tile() returns void and MUST
	# NOT take a size arg in 4.7.1 (it silently fails and set_cell renders nothing).
	var tex_size := src.texture.get_size()
	var cols := tex_size.x / TILE
	var rows := tex_size.y / TILE
	for row in range(rows):
		for col in range(cols):
			src.create_tile(Vector2i(col, row))
	var src_id := ts.add_source(src)
	# A TileMap in 4.7 is a container: add a TileMapLayer child to hold the cells.
	var layer := TileMapLayer.new()
	layer.name = "Tiles"
	tilemap.add_child(layer)
	tilemap.tile_set = ts
	_tile_source_id = src_id
	_tile_layer = layer
	print("[CathedralCrypts] TileSet: %d source(s), %d tiles" % [ts.get_source_count(), src.get_tiles_count()])

func _tile_atlas(ch: String) -> Vector2i:
	match ch:
		"#": return Vector2i(1, 0)   # wall
		"L": return Vector2i(2, 0)   # lamp (yellow marker)
		"S": return Vector2i(3, 0)   # shield (cyan marker)
		"E": return Vector2i(0, 1)   # entrance (blue marker)
		"B": return Vector2i(1, 1)   # bomb bag (red marker)
		"X": return Vector2i(2, 1)   # exit (green marker)
		_: return Vector2i(0, 0)     # floor

func _build_tiles() -> void:
	for y in range(MAP.size()):
		for x in range(MAP[y].length()):
			var ch: String = MAP[y][x]
			_tile_layer.set_cell(Vector2i(x, y), _tile_source_id, _tile_atlas(ch))

func _build_collision() -> void:
	# Walls as a single StaticBody2D with one CollisionShape2D per wall tile.
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 1
	add_child(walls)
	for y in range(MAP.size()):
		for x in range(MAP[y].length()):
			if MAP[y][x] == "#":
				var shape := CollisionShape2D.new()
				shape.shape = RectangleShape2D.new()
				shape.shape.size = Vector2(TILE, TILE)
				shape.position = Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)
				walls.add_child(shape)

func _spawn_player() -> void:
	var player := preload("res://scenes/player/player.tscn").instantiate()
	var pos := _find_char("E")
	player.position = Vector2(pos.x * TILE + TILE / 2.0, pos.y * TILE + TILE / 2.0)
	add_child(player)

func _place_markers() -> void:
	# Major item markers become VISIBLE pickups now (Option B: real in-game
	# item acquisition with a sprite + jingle), not invisible Areas.
	_spawn_pickup_at("L", PickupScript.Kind.KEY_ITEM, "lamp", 0, "Got the Lamp!")
	_spawn_pickup_at("B", PickupScript.Kind.KEY_ITEM, "bomb_bag", 20, "Got the Bomb Bag! +20 bombs")
	_spawn_pickup_at("S", PickupScript.Kind.KEY_ITEM, "basic_shield", 0, "Got the Basic Shield!")
	# THE bow: comes with a starter quiver of arrows (criterion 9).
	_spawn_pickup_at("P", PickupScript.Kind.KEY_ITEM, "bow", 10, "Got the Bow! +10 arrows")
	# Demo consumable pickups so the spawn/pickup procedure is proven for
	# arrows + hearts + rupees (not just the bow).
	_spawn_pickup_at("r", PickupScript.Kind.CONSUMABLE, "rupees", 5, "+5 Rupees")
	_spawn_pickup_at("h", PickupScript.Kind.HEART_REFILL, "heart", 4, "Recovered 4 HP")
	_spawn_pickup_at("a", PickupScript.Kind.CONSUMABLE, "arrows", 5, "+5 Arrows")
	# Exit marker (visual; logs reaching the stairs).
	_spawn_pickup_at("X", PickupScript.Kind.KEY_ITEM, "exit", 0, "Reached the exit!")

func _spawn_pickup_at(ch: String, kind: int, item_id: String, amount: int, msg: String) -> void:
	var pos := _find_char(ch)
	if pos == Vector2i(-1, -1):
		return
	var pickup: Pickup = preload("res://scenes/items/pickup.tscn").instantiate()
	pickup.kind = kind
	pickup.item_id = item_id
	pickup.amount = amount
	pickup.message = msg
	# Place players/items centered on the tile.
	pickup.global_position = Vector2(pos.x * TILE + TILE / 2.0, pos.y * TILE + TILE / 2.0)
	add_child(pickup)

# Breakable rocks (plan T2.2.3). Free-standing obstacles in open floor that a
# bomb blast destroys — demonstrates the bomb mechanic without gating the main
# route. Cells are verified floor and clear of pickups/enemies/exit.
func _spawn_demo_rocks() -> void:
	for cell in [Vector2i(2, 8), Vector2i(16, 6)]:
		_spawn_rock(cell)

func _spawn_rock(cell: Vector2i) -> void:
	var rock: Node2D = ROCK_SCENE.instantiate()
	rock.global_position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
	add_child(rock)

func _place_save_point() -> void:
	var sp := preload("res://scenes/world/save_point.tscn").instantiate()
	# Free floor tile in entrance room (matrix row 5, col 3)
	sp.position = Vector2(3 * TILE + TILE / 2.0, 5 * TILE + TILE / 2.0)
	add_child(sp)

func _add_hud() -> void:
	var hud := preload("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)

# Spawn a small mixed group in the middle room so the player can test combat
# the moment they walk through the first doorway.
func _spawn_baseline_enemies() -> void:
	var spots := [
		Vector2i(8, 4), Vector2i(10, 5), Vector2i(9, 6),
		Vector2i(8, 7), Vector2i(10, 8),
	]
	for i in range(spots.size()):
		var kind := "octorok" if i % 2 == 0 else "moblin"
		_spawn_enemy(kind, spots[i])
	# Stalfos miniboss guards the Bomb Bag chamber (right room, row 3).
	_spawn_enemy("stalfos", Vector2i(13, 3))

# Gate criterion 8 stress test: F9 drops a 20-enemy batch (on top of baseline)
# so you can eyeball 60fps with 20+ sprites. Spawns them in a ring AROUND the
# player (on floor tiles) so the effect is immediately visible.
func _spawn_stress_batch() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var pc := Vector2i(1, 1)
	if player != null:
		pc = Vector2i(int(player.position.x / TILE), int(player.position.y / TILE))
	# Candidate offsets: a spiral-ish ring around the player.
	var offsets := [
		Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2),
		Vector2i(3, 0), Vector2i(-3, 0), Vector2i(0, 3), Vector2i(0, -3),
		Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2),
		Vector2i(3, 1), Vector2i(-3, 1), Vector2i(1, 3), Vector2i(1, -3),
		Vector2i(3, -1), Vector2i(-3, -1), Vector2i(-1, 3), Vector2i(-1, -3),
	]
	var spawned := 0
	for off in offsets:
		if spawned >= 20:
			break
		var cell: Vector2i = pc + off
		if cell.y < 0 or cell.y >= MAP.size():
			continue
		if cell.x < 0 or cell.x >= MAP[cell.y].length():
			continue
		if MAP[cell.y][cell.x] != ".":
			continue  # skip walls/markers
		var kind := "octorok" if spawned % 2 == 0 else "moblin"
		_spawn_enemy(kind, cell)
		spawned += 1
	# Fallback: if the ring was blocked, sweep outward until we place 20.
	var ring := 4
	while spawned < 20 and ring < 12:
		for dx in range(-ring, ring + 1):
			for dy in range(-ring, ring + 1):
				if spawned >= 20:
					break
				var cell: Vector2i = pc + Vector2i(dx, dy)
				if cell.y < 0 or cell.y >= MAP.size() or cell.x < 0 or cell.x >= MAP[cell.y].length():
					continue
				if MAP[cell.y][cell.x] != ".":
					continue
				var kind := "octorok" if spawned % 2 == 0 else "moblin"
				_spawn_enemy(kind, cell)
				spawned += 1
		ring += 1

func _spawn_enemy(kind: String, cell: Vector2i) -> void:
	if not ENEMY_SCENES.has(kind):
		return
	var e: Node2D = ENEMY_SCENES[kind].instantiate()
	e.position = Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
	# Give a small patrol wander (a few tiles around the spawn) so the enemy
	# visibly moves during the feel-test instead of idling in place.
	if "patrol_points" in e:
		var cx := cell.x * TILE + TILE / 2.0
		var cy := cell.y * TILE + TILE / 2.0
		var pts: Array[Vector2] = [
			Vector2(cx - TILE, cy), Vector2(cx + TILE, cy),
			Vector2(cx, cy + TILE), Vector2(cx - TILE, cy),
		]
		e.patrol_points = pts
	# Keep enemies on their own group for easy counting/cleanup
	e.add_to_group("enemy")
	add_child(e)
	_enemy_count += 1
	GameManager.enemy_count = _enemy_count

# ---- Game over (Phase 1) ----
# We do NOT pause the tree: pausing it would also halt input processing, so the
# "R to return" handler could never receive key events. Instead we freeze only
# the player (State.DEAD already zeroes its velocity and ignores input via
# GameManager.game_paused) and keep enemies ticking so they idle/patrol on.
func _on_game_over() -> void:
	if _is_game_over:
		return
	_is_game_over = true
	GameManager.game_paused = true
	# Stop the dungeon music for a proper death beat.
	AudioManager.stop_music()
	# Build the overlay in a CanvasLayer so it renders in SCREEN space
	# (unaffected by the player camera's 3x zoom, which previously made the
	# text huge and clipped).
	var cl := CanvasLayer.new()
	cl.layer = 100
	add_child(cl)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	cl.add_child(dim)
	var label := Label.new()
	label.text = "YOU DIED\n\nPress R to return to the Main Menu"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 28)
	label.modulate = Color(1, 0.45, 0.45, 1)
	cl.add_child(label)
	_game_over_label = label
	print("[CathedralCrypts] Game over — player died.")

func _process(_delta: float) -> void:
	if _is_game_over and Input.is_action_just_pressed("restart"):
		GameManager.game_paused = false
		GameManager.player_health = GameManager.max_health if "max_health" in GameManager else 8
		# Return to the main menu (clean restart of the run).
		get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
