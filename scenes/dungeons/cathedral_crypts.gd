# Cathedral Crypts — Prologue Dungeon Blockout
# Phase 1 (T1.4.5): dungeon tilemap with key item room + boss room
#
# Layout (3 rooms side by side, connected by doorways):
#   E = entrance      L = Lamp (first half)
#   B = Bomb Bag      S = Basic Shield (end)
#   X = exit/stairs
#
# Per requirements §10.1: Cathedral Crypts is the prologue dungeon.
# Key items: Lamp (first half), Basic Shield (end), Bomb Bag (miniboss reward).

extends Node2D

## Dungeon layout. '#' = wall, '.' = floor.
## Letters mark key-item / exit positions.
const MAP := [
	"###################",
	"#E....#.....#.....#",
	"#.....#.....#.....#",
	"#........B..#..S..#",
	"#.....#.....#.....#",
	"#.....#.....#.....#",
	"#.....#.....#.....#",
	"#.....#..........X#",
	"#..L..#.....#.....#",
	"#.....#.....#.....#",
	"###################",
]
const TILE := 16

@onready var tilemap: TileMap = $TileMap

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

func _setup_tileset() -> void:
	var ts := TileSet.new()
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/art/dungeons/crypt_tileset.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	var src_id := ts.add_source(src)
	tilemap.tile_set = ts
	tilemap.format = 2
	_tile_source_id = src_id

var _tile_source_id: int = 0

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
			tilemap.set_cell(0, Vector2i(x, y), _tile_source_id, _tile_atlas(ch))

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
	_add_marker("L", "lamp", "Got the Lamp!")
	_add_marker("B", "bomb_bag", "Got the Bomb Bag!")
	_add_marker("S", "basic_shield", "Got the Basic Shield!")
	_add_marker("X", "exit", "Reached the exit!")

func _place_save_point() -> void:
	var sp := preload("res://scenes/world/save_point.tscn").instantiate()
	# Free floor tile in entrance room (matrix row 5, col 3)
	sp.position = Vector2(3 * TILE + TILE / 2.0, 5 * TILE + TILE / 2.0)
	add_child(sp)

func _add_marker(ch: String, item: String, msg: String) -> void:
	var pos := _find_char(ch)
	if pos == Vector2i(-1, -1):
		return
	var area := Area2D.new()
	area.name = "Marker_" + ch
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2(TILE, TILE)
	area.add_child(shape)
	area.position = Vector2(pos.x * TILE + TILE / 2.0, pos.y * TILE + TILE / 2.0)
	area.body_entered.connect(_on_marker_entered.bind(item, msg, area))
	add_child(area)

func _on_marker_entered(body: Node, item: String, msg: String, area: Area2D) -> void:
	if not body.is_in_group("player"):
		return
	if item == "exit":
		print("[CathedralCrypts] " + msg)
		return
	if not GameManager.has_key_item(item):
		GameManager.add_key_item(item)
		if item == "basic_shield":
			GameManager.shield_level = 1
		print("[CathedralCrypts] " + msg)
	area.queue_free()

func _find_char(ch: String) -> Vector2i:
	for y in range(MAP.size()):
		for x in range(MAP[y].length()):
			if MAP[y][x] == ch:
				return Vector2i(x, y)
	return Vector2i(-1, -1)
