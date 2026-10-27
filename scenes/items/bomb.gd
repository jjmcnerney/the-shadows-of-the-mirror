# Bomb — placed on the ground in front of the player, explodes after a short
# fuse and damages enemies / breaks bombable rocks in its blast radius.
# Per development plan T2.2.3: "Bombs placed on ground, explode after delay."
#
# The blast effect is applied through a public apply_blast(bodies) seam so the
# headless test can drive it deterministically (no physics-timing dependency),
# while runtime explode() feeds it from the Area's live overlap set.

extends Area2D

const FUSE_TIME: float = 1.5
const BLAST_RADIUS: float = 22.0   # ~1.4 tiles (TILE = 16)
const DAMAGE: int = 2
const KNOCKBACK: float = 150.0

var _fuse: float = FUSE_TIME
var _exploded: bool = false
var _sprite: Sprite2D = null

func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0      # the bomb does not block anything itself
	collision_mask = 1       # detect layer-1 bodies: walls, enemies, rocks, player
	_build_sprite()
	AudioManager.play_sfx_named("bomb_place", global_position)

## Place the bomb at an origin (1 tile ahead of the player) in facing direction.
func setup(origin: Vector2) -> void:
	global_position = origin

func _physics_process(delta: float) -> void:
	if _exploded:
		return
	_fuse -= delta
	if _fuse <= 0.0:
		explode()

## Runtime detonation: gather bodies currently overlapping the blast area.
func explode() -> void:
	if _exploded:
		return
	apply_blast(get_overlapping_bodies())

## Deterministic blast seam: apply effects to an explicit list of bodies.
## Enemies (duck-typed by take_damage) are damaged; rocks (try_break) are broken.
## The player who dropped it is never affected.
func apply_blast(bodies: Array) -> void:
	if _exploded:
		return
	_exploded = true
	for b in bodies:
		if b == null or not (b is Node):
			continue
		if b.is_in_group("player"):
			continue
		if b.has_method("try_break"):
			b.call("try_break")
		elif b.has_method("take_damage"):
			var dir: Vector2i = Vector2i.ZERO
			if b is Node2D:
				var off: Vector2 = (b as Node2D).global_position - global_position
				dir = Vector2i(signf(off.x), signf(off.y))
			b.call("take_damage", DAMAGE, dir, KNOCKBACK)
	_play_explosion()

func _play_explosion() -> void:
	AudioManager.play_sfx_named("bomb_explosion", global_position)
	if not is_inside_tree():
		queue_free()
		return
	if _sprite != null:
		var tw: Tween = create_tween()
		tw.tween_property(_sprite, "scale", Vector2(2.4, 2.4), 0.12)
		tw.tween_property(_sprite, "modulate", Color(2.5, 2.2, 1.4, 1.0), 0.10)
		tw.tween_interval(0.12)
		tw.tween_property(self, "modulate:a", 0.0, 0.15)
	timer(0.45, func() -> void: queue_free())

# One-shot deferred call helper (Godot 4 has no built-in delay()).
func timer(seconds: float, cb: Callable) -> void:
	var t := get_tree().create_timer(seconds)
	t.timeout.connect(cb)

func _build_sprite() -> void:
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Round bomb body (dark with a highlight).
	for y in range(3, 11):
		for x in range(2, 10):
			img.set_pixel(x, y, Color(0.15, 0.15, 0.2, 1.0))
	img.set_pixel(4, 4, Color(0.5, 0.5, 0.6, 1.0))
	img.set_pixel(3, 5, Color(0.4, 0.4, 0.5, 1.0))
	# Fuse nub on top.
	img.set_pixel(6, 2, Color(0.8, 0.7, 0.3, 1.0))
	img.set_pixel(7, 1, Color(0.9, 0.8, 0.4, 1.0))
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	_sprite = Sprite2D.new()
	_sprite.texture = tex
	add_child(_sprite)
