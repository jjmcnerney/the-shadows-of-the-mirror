# BombableRock — a static obstacle that a bomb blast destroys, opening a path.
# Per development plan T2.2.3: "breakable rocks."
#
# Sits as a solid StaticBody2D (blocks movement) until try_break() is called by
# a bomb blast; then it flashes, shrinks, and is removed. Non-breakable rocks
# (breakable = false) simply resist the blast — used for future hard walls.

extends StaticBody2D

@export var breakable: bool = true

var broken: bool = false
var _sprite: Sprite2D = null

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	add_to_group("bombable_rock")
	_build_sprite()

## Called by a bomb blast. Returns whether the rock actually broke.
func try_break() -> bool:
	if broken:
		return false
	if not breakable:
		return false
	broken = true
	# Disable collision immediately so the path opens even before the node frees.
	var cs := get_node_or_null("CollisionShape2D")
	if cs != null:
		cs.set_deferred("disabled", true)
	if _sprite != null:
		var tw: Tween = create_tween()
		tw.tween_property(_sprite, "modulate", Color(2.2, 2.0, 1.6, 1.0), 0.08)
		tw.tween_property(_sprite, "scale", Vector2(0.2, 0.2), 0.18)
		tw.tween_interval(0.10)
	queue_free()
	return true

func _build_sprite() -> void:
	var img := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# A blocky gray rock with a couple of cracks.
	for y in range(3, 13):
		for x in range(2, 12):
			# carve an irregular rock silhouette
			if y <= 4 and (x <= 3 or x >= 10):
				continue
			if y >= 12 and (x <= 2 or x >= 11):
				continue
			img.set_pixel(x, y, Color(0.45, 0.44, 0.48, 1.0))
	# shading + cracks
	for x in range(2, 12):
		img.set_pixel(x, 4, Color(0.62, 0.62, 0.66, 1.0))
	img.set_pixel(6, 7, Color(0.3, 0.3, 0.34, 1.0))
	img.set_pixel(7, 8, Color(0.3, 0.3, 0.34, 1.0))
	img.set_pixel(8, 9, Color(0.3, 0.3, 0.34, 1.0))
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	_sprite = Sprite2D.new()
	_sprite.texture = tex
	add_child(_sprite)
