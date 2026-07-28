extends CanvasLayer

# Phase 1 debug HUD: shows hearts (driven by GameManager.player_health in
# half-heart units) and a live enemy count. Minimal blockout UI — no art
# assets yet, hearts are drawn procedurally.

@onready var heart_container: HBoxContainer = $Margin/VBox/HeartContainer
@onready var enemy_label: Label = $Margin/VBox/EnemyCount
@onready var arrow_label: Label = $Margin/VBox/ArrowLabel
@onready var rupee_label: Label = $Margin/VBox/RupeeLabel

const HEART_SIZE := 16

var _full_tex: Texture2D = null
var _half_tex: Texture2D = null
var _empty_tex: Texture2D = null

func _ready() -> void:
	_build_heart_textures()
	if GameManager.player_health_changed.is_connected(_on_health_changed):
		pass
	GameManager.player_health_changed.connect(_on_health_changed)
	GameManager.enemy_count_changed.connect(_on_enemy_count_changed)
	GameManager.consumable_changed.connect(_on_consumable_changed)
	_refresh()
	_update_ammo()
	if enemy_label:
		enemy_label.text = "Enemies: 0"

func _on_health_changed(_h: int) -> void:
	_refresh()

func _on_enemy_count_changed(n: int) -> void:
	if enemy_label:
		enemy_label.text = "Enemies: %d" % n

# Keep arrow + rupee readouts live as pickups are collected / arrows fired.
func _on_consumable_changed(_item_id: String, _amount: int) -> void:
	_update_ammo()

func _update_ammo() -> void:
	if arrow_label:
		arrow_label.text = "Arrows: %d" % GameManager.get_consumable("arrows")
	if rupee_label:
		rupee_label.text = "Rupees: %d" % GameManager.get_consumable("rupees")

func _refresh() -> void:
	if heart_container == null:
		return
	# Clear existing
	for c in heart_container.get_children():
		c.queue_free()
	var max_half: int = GameManager.player_max_health
	var cur_half: int = GameManager.player_health
	for i in range(ceili(max_half / 2.0)):
		var tex_rect := TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.texture_filter = 1  # Nearest — keep hearts pixel-perfect
		tex_rect.custom_minimum_size = Vector2(HEART_SIZE, HEART_SIZE)
		tex_rect.size = Vector2(HEART_SIZE, HEART_SIZE)
		var remaining := cur_half - i * 2
		if remaining >= 2:
			tex_rect.texture = _full_tex
		elif remaining == 1:
			tex_rect.texture = _half_tex
		else:
			tex_rect.texture = _empty_tex
		heart_container.add_child(tex_rect)

func _build_heart_textures() -> void:
	if _full_tex != null:
		return
	_full_tex = _make_heart(Color(0.95, 0.2, 0.35, 1.0))
	_half_tex = _make_heart(Color(0.95, 0.2, 0.35, 1.0), true)
	_empty_tex = _make_heart(Color(0.25, 0.25, 0.3, 1.0))

# Draw a simple 8x7 pixel heart. half=true draws only the left half filled.
func _make_heart(fill: Color, half: bool = false) -> Texture2D:
	var w := 8
	var h := 7
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# heart pixel map (1 = filled)
	var map := [
		[0,1,1,0,0,1,1,0],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[0,1,1,1,1,1,1,0],
		[0,0,1,1,1,1,0,0],
		[0,0,0,1,1,0,0,0],
	]
	for y in range(h):
		for x in range(w):
			if map[y][x] == 1:
				if half and x >= 4:
					continue
				img.set_pixel(x, y, fill)
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	return tex
