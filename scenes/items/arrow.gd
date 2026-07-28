extends Area2D
class_name Arrow

## Bow projectile. Travels in a cardinal direction, damages the first enemy it
## touches, and is destroyed on enemy/wall contact or after a short lifetime.
## Spawned by the player on the "bow" action (see player.gd _shoot_arrow).

const SPEED: float = 190.0
const LIFETIME: float = 2.0
const ARROW_DAMAGE: int = 1
const ARROW_KNOCKBACK: float = 80.0

@onready var sprite: Sprite2D = $Sprite2D

var _velocity: Vector2 = Vector2.ZERO
var _direction: Vector2i = Vector2i.RIGHT
var _life: float = 0.0

func _ready() -> void:
	_build_sprite()
	if sprite != null:
		sprite.texture_filter = 1  # pixel-perfect
	monitoring = true
	body_entered.connect(_on_body_entered)

func setup(direction: Vector2i, origin: Vector2) -> void:
	_direction = direction if direction != Vector2i.ZERO else Vector2i.DOWN
	_velocity = Vector2(_direction) * SPEED
	global_position = origin
	rotation = Vector2(_direction).angle()

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta
	_life += delta
	if _life >= LIFETIME:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if body.is_in_group("player"):
		return  # never hit the archer who fired it
	if body is Enemy:
		body.take_damage(ARROW_DAMAGE, _direction, ARROW_KNOCKBACK)
		queue_free()
	elif body is StaticBody2D:
		queue_free()  # hit a wall

func _build_sprite() -> void:
	var img := Image.create(12, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for x in range(1, 9):
		img.set_pixel(x, 1, Color(0.8, 0.7, 0.4, 1.0))
		img.set_pixel(x, 2, Color(0.8, 0.7, 0.4, 1.0))
	img.set_pixel(9, 0, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(9, 1, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(9, 2, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(9, 3, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(10, 1, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(10, 2, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(11, 1, Color(0.9, 0.9, 0.95, 1.0))
	img.set_pixel(11, 2, Color(0.9, 0.9, 0.95, 1.0))
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	if sprite != null:
		sprite.texture = tex
