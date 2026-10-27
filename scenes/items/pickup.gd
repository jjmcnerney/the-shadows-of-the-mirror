extends Area2D
class_name Pickup

## Generic, visible collectible. Drop one in any scene; on player overlap it
## grants the item via GameManager and plays the acquisition jingle, then a
## brief floating label. Replaces the old invisible marker Areas so acquiring
## an item is a real on-screen beat (key items + consumables + heart pieces).

enum Kind { KEY_ITEM, CONSUMABLE, HEART_PIECE, HEART_REFILL }

@export var kind: int = Kind.KEY_ITEM
@export var item_id: String = ""
@export var amount: int = 1
@export var message: String = ""

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_build_icon()
	if sprite != null:
		sprite.texture_filter = 1  # pixel-perfect
	body_entered.connect(_on_body_entered)
	_start_bob()

func _on_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	_acquire()
	AudioManager.play_sfx_named("item_get", global_position)
	_spawn_float_text(message)
	queue_free()

func _acquire() -> void:
	match kind:
		Kind.KEY_ITEM:
			GameManager.add_key_item(item_id)
			if item_id == "bow":
				# The Bow always comes with a starter quiver.
				GameManager.add_consumable("arrows", amount if amount > 0 else 10)
			elif item_id == "bomb_bag":
				# The Bomb Bag always comes with a starter stock (plan T2.2.3: 20 bombs).
				GameManager.add_consumable("bombs", amount if amount > 0 else 20)
		Kind.CONSUMABLE:
			GameManager.add_consumable(item_id, amount)
		Kind.HEART_PIECE:
			GameManager.add_heart_piece()
		Kind.HEART_REFILL:
			GameManager.heal(amount)

# Floating "Got the X!" text that rises and fades, parented to the world so it
# survives the pickup itself being freed.
func _spawn_float_text(txt: String) -> void:
	if txt == "" or get_parent() == null:
		return
	var label := Label.new()
	label.text = txt
	label.global_position = global_position - Vector2(0, 10)
	label.add_theme_font_size_override("font_size", 10)
	label.modulate = Color(1.0, 1.0, 0.75, 1.0)
	get_parent().add_child(label)
	var tw := create_tween()
	tw.tween_property(label, "position:y", label.position.y - 18.0, 0.9)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tw.tween_callback(label.queue_free)

func _start_bob() -> void:
	if sprite == null:
		return
	var tw := create_tween()
	tw.set_loops(0)
	tw.tween_property(sprite, "position:y", -2.0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(sprite, "position:y", 2.0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

# ---- Procedural icon (no art assets yet) ----
func _build_icon() -> void:
	var color := _icon_color()
	var img := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match item_id:
		"bow", "arrows":
			_draw_arrow(img, color)
		"heart", "heart_piece":
			_draw_heart(img, color)
		"rupees", "rupee":
			_draw_diamond(img, color)
		_:
			_draw_diamond(img, color)
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	if sprite != null:
		sprite.texture = tex

func _icon_color() -> Color:
	match item_id:
		"bow": return Color(0.82, 0.65, 0.42, 1.0)
		"lamp": return Color(1.0, 0.85, 0.2, 1.0)
		"bomb_bag": return Color(0.8, 0.25, 0.25, 1.0)
		"basic_shield": return Color(0.3, 0.7, 0.9, 1.0)
		"arrows": return Color(0.72, 0.72, 0.78, 1.0)
		"rupees", "rupee": return Color(0.2, 0.8, 0.4, 1.0)
		"heart", "heart_piece": return Color(0.95, 0.2, 0.35, 1.0)
		_: return Color(0.9, 0.9, 0.9, 1.0)

func _draw_arrow(img: Image, c: Color) -> void:
	for x in range(2, 10):
		img.set_pixel(x, 6, c)
		img.set_pixel(x, 7, c)
	img.set_pixel(10, 4, c); img.set_pixel(10, 5, c); img.set_pixel(10, 6, c)
	img.set_pixel(10, 7, c); img.set_pixel(10, 8, c); img.set_pixel(10, 9, c)
	img.set_pixel(11, 5, c); img.set_pixel(11, 6, c); img.set_pixel(11, 7, c); img.set_pixel(11, 8, c)
	img.set_pixel(12, 6, c); img.set_pixel(12, 7, c)

func _draw_heart(img: Image, c: Color) -> void:
	var map := [
		[0,1,1,0,0,1,1,0,0,0,0,0,0,0],
		[1,1,1,1,1,1,1,1,0,0,0,0,0,0],
		[1,1,1,1,1,1,1,1,0,0,0,0,0,0],
		[1,1,1,1,1,1,1,1,0,0,0,0,0,0],
		[0,1,1,1,1,1,1,0,0,0,0,0,0,0],
		[0,0,1,1,1,1,0,0,0,0,0,0,0,0],
		[0,0,0,1,1,0,0,0,0,0,0,0,0,0],
	]
	for y in range(map.size()):
		for x in range(14):
			if map[y][x] == 1:
				img.set_pixel(x, y + 3, c)

func _draw_diamond(img: Image, c: Color) -> void:
	var cx := 7
	var cy := 7
	for y in range(14):
		for x in range(14):
			if absi(x - cx) + absi(y - cy) <= 6:
				img.set_pixel(x, y, c)
