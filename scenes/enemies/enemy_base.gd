# Enemy Base Class
# Shared AI: aggro radius, patrol, chase, alert, stunned states
# Per requirements §7.3 (Enemy Behavior) and §11.1 (Enemy Types)

class_name Enemy extends CharacterBody2D

## Enemy AI states
enum State {
	PATROL,      # walking along patrol path
	IDLE,        # stationary until player aggro
	CHASE,       # moving toward player
	ATTACK,      # performing attack
	STUNNED,     # stuck in place (2s after sufficient damage)
	ALERT,       # saw player, brief pause before chase
	DEAD,        # removed from scene
}

## Enemy properties (overridden by subclasses)
@export var health: int = 2
@export var max_health: int = 2
@export var move_speed: float = 40.0
@export var aggro_radius: float = 80.0
@export var attack_radius: float = 24.0
@export var contact_damage: int = 1

## AI state
var current_state: State = State.PATROL
var previous_state: State = State.PATROL

## References
var player_ref: Player = null
@onready var sprite: Sprite2D = $Sprite2D

## Patrol path (array of Vector2 world positions)
@export var patrol_points: Array[Vector2] = []
var patrol_index: int = 0
var patrol_direction: int = 1

## Stun timer
var stun_timer: float = 0.0
const STUN_DURATION: float = 2.0

## Alert timer (brief pause before chase)
var alert_timer: float = 0.0
const ALERT_DURATION: float = 0.3

## Knockback
var knockback_velocity: Vector2 = Vector2.ZERO

## Signals
signal died(enemy: Enemy)
signal attacked(enemy: Enemy, damage: int)

func _ready() -> void:
	# Find player reference
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player

func _physics_process(delta: float) -> void:
	_update_ai(delta)
	_apply_knockback(delta)
	move_and_slide()

func _update_ai(delta: float) -> void:
	match current_state:
		State.PATROL:
			_handle_patrol(delta)
		State.IDLE:
			_handle_idle(delta)
		State.ALERT:
			_handle_alert(delta)
		State.CHASE:
			_handle_chase(delta)
		State.ATTACK:
			_handle_attack(delta)
		State.STUNNED:
			_handle_stunned(delta)
		State.DEAD:
			pass

func _handle_patrol(delta: float) -> void:
	if player_ref == null:
		return
	
	var dist_to_player: float = global_position.distance_to(player_ref.global_position)
	if dist_to_player <= aggro_radius:
		_enter_alert()
		return
	
	# Move along patrol path
	if patrol_points.size() > 0:
		var target: Vector2 = patrol_points[patrol_index]
		var direction: Vector2 = (target - global_position).normalized()
		velocity = direction * move_speed
		
		if global_position.distance_to(target) < 4.0:
			# Advance patrol index (ping-pong)
			patrol_index += patrol_direction
			if patrol_index >= patrol_points.size():
				patrol_index = patrol_points.size() - 2
				patrol_direction = -1
			elif patrol_index < 0:
				patrol_index = 1
				patrol_direction = 1
	else:
		# No patrol path — just idle in place
		velocity = Vector2.ZERO

func _handle_idle(delta: float) -> void:
	if player_ref == null:
		return
	
	var dist_to_player: float = global_position.distance_to(player_ref.global_position)
	if dist_to_player <= aggro_radius:
		_enter_alert()

func _handle_alert(delta: float) -> void:
	velocity = Vector2.ZERO
	alert_timer += delta
	if alert_timer >= ALERT_DURATION:
		alert_timer = 0.0
		current_state = State.CHASE

func _handle_chase(delta: float) -> void:
	if player_ref == null:
		current_state = State.PATROL
		return
	
	var dist_to_player: float = global_position.distance_to(player_ref.global_position)
	
	# If player left aggro radius, return to patrol
	if dist_to_player > aggro_radius * 1.5:
		current_state = State.PATROL
		return
	
	# Move toward player
	var direction: Vector2 = (player_ref.global_position - global_position).normalized()
	velocity = direction * move_speed
	
	# If close enough, attack
	if dist_to_player <= attack_radius:
		current_state = State.ATTACK

func _handle_attack(delta: float) -> void:
	# Default: contact damage handled in _on_body_entered
	# Subclasses override for ranged/special attacks
	velocity = Vector2.ZERO
	
	# Return to chase after attack window
	if player_ref and global_position.distance_to(player_ref.global_position) > attack_radius:
		current_state = State.CHASE

func _handle_stunned(delta: float) -> void:
	velocity = Vector2.ZERO
	stun_timer -= delta
	if stun_timer <= 0.0:
		current_state = State.PATROL

func _apply_knockback(delta: float) -> void:
	if knockback_velocity != Vector2.ZERO:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 400.0 * delta)

func _enter_alert() -> void:
	previous_state = current_state
	current_state = State.ALERT
	alert_timer = 0.0

## Called by player sword/arrow hitbox
func take_damage(amount: int, from_direction: Vector2i, knockback: float = 100.0) -> void:
	if current_state == State.DEAD:
		return
	
	health -= amount
	
	# Knockback
	knockback_velocity = Vector2(from_direction) * knockback
	
	# Flash white (placeholder — needs actual animation)
	if sprite and sprite.material is ShaderMaterial:
		pass  # would set shader uniform here
	
	if health <= 0:
		_die()
	else:
		# Stun on hit
		current_state = State.STUNNED
		stun_timer = STUN_DURATION

func _die() -> void:
	current_state = State.DEAD
	died.emit(self)
	queue_free()

## Contact damage to player
func _on_body_entered(body: Node) -> void:
	if body is Player and current_state != State.DEAD:
		if body.has_method("take_damage"):
			var dir: Vector2i = Vector2i(sign(body.global_position.x - global_position.x), 0)
			body.take_damage(contact_damage, dir)
			attacked.emit(self, contact_damage)
