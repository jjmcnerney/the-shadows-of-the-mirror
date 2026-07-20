# Player Controller
# 8-directional movement, dash, sword combat, spin attack, passive shield block

class_name Player extends CharacterBody2D

## Movement constants
const TILE_SIZE: int = 16
const WALK_SPEED: float = 100.0
const DASH_SPEED: float = 250.0
const SWIM_SPEED: float = 60.0
const ACCELERATION: float = 800.0
const FRICTION: float = 1200.0

## Combat constants
const SWORD_DAMAGE: int = 1
const SPIN_ATTACK_DAMAGE: int = 2
const SPIN_ATTACK_DURATION: float = 0.3
const CHARGE_TIME: float = 0.4  # time to hold for spin attack
const INVINCIBILITY_FRAMES: float = 1.0  # frames after taking damage

## Player state enum
enum State {
	IDLE,
	WALKING,
	DASHING,
	ATTACKING,
	SPIN_ATTACKING,
	CHARGING,
	HURT,
	SWIMMING,
	CLIMBING,
}

## Player properties
@export var walk_speed: float = WALK_SPEED
@export var dash_speed: float = DASH_SPEED

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# Facing direction (cardinal only for attacks)
var facing: Vector2i = Vector2i.RIGHT

# Movement input
var move_input: Vector2 = Vector2.ZERO

# Dash state
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_button_held: bool = false

# Sword charge timer (for spin attack)
var sword_charge_timer: float = 0.0
var is_charging: bool = false

# Invincibility after hurt
var invincible: bool = false
var invincibility_timer: float = 0.0

# Animation reference
var anim_player: AnimationPlayer

# Hitbox for sword
@onready var sword_hitbox: CollisionShape2D = $SwordHitbox

# Shield visual
@onready var shield_visual: Sprite2D = $Shield

# Camera follow
@onready var camera: Camera2D = $Camera2D

## Signals
signal attacked(direction: Vector2i, damage: int)
signal spin_attacked(damage: int)
signal shot_arrow(direction: Vector2i)
signal used_item(direction: Vector2i)
signal hurt(amount: int)
signal died

func _ready() -> void:
	if has_node("AnimationPlayer"):
		anim_player = $AnimationPlayer
	
	# Sword hitbox starts disabled
	if sword_hitbox:
		sword_hitbox.disabled = true

func _process(delta: float) -> void:
	_update_input()
	_handle_state(delta)
	_update_facing()
	_update_invincibility(delta)
	_update_animation()

func _physics_process(delta: float) -> void:
	_update_velocity(delta)
	_move_and_collide()

# ---------- Input ----------

func _input(event: InputEvent) -> void:
	if GameManager.game_paused:
		return
	
	if current_state == State.HURT:
		return
	
	## Sword attack / charge
	if event.is_action_pressed("attack"):
		_start_attack_charge()
	elif event.is_action_released("attack"):
		_end_attack_charge()
	
	## Bow shot
	if event.is_action_pressed("bow"):
		_shoot_arrow()
	
	## Use equipped item
	if event.is_action_pressed("item"):
		_use_item()
	
	## Interact / Dash
	if event.is_action_pressed("interact"):
		_interact()
	
	## Quick swap
	if event.is_action_pressed("quick_swap"):
		_quick_swap_item()
	
	## Pause
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _update_input() -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

# ---------- State Management ----------

func _handle_state(delta: float) -> void:
	if invincible and current_state != State.HURT:
		return
	
	match current_state:
		State.IDLE, State.WALKING:
			_handle_movement_state(delta)
		State.DASHING:
			_handle_dash_state(delta)
		State.ATTACKING:
			_handle_attack_state(delta)
		State.SPIN_ATTACKING:
			_handle_spin_attack_state(delta)
		State.CHARGING:
			_handle_charging_state(delta)
		State.HURT:
			_handle_hurt_state(delta)

func _handle_movement_state(delta: float) -> void:
	var speed: float = walk_speed
	
	# Check if dashing
	if Input.is_action_just_pressed("interact") and not is_dashing:
		_start_dash()
		return
	
	# Determine movement state
	if move_input != Vector2.ZERO:
		if current_state != State.WALKING:
			previous_state = current_state
			current_state = State.WALKING
	else:
		if current_state != State.IDLE:
			previous_state = current_state
			current_state = State.IDLE
	
	# Apply movement acceleration
	var target_velocity: Vector2 = move_input.normalized() * speed
	velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)

func _handle_dash_state(delta: float) -> void:
	var target_velocity: Vector2 = dash_direction * dash_speed
	velocity = target_velocity
	
	# Dash ends when player stops holding or hits terrain (handled in collision)
	if not Input.is_action_pressed("interact"):
		_end_dash()

func _handle_attack_state(delta: float) -> void:
	# Single frame attack — just deal damage and return to previous state
	previous_state = current_state
	current_state = previous_state

func _handle_spin_attack_state(delta: float) -> void:
	# Spin attack lasts for SPIN_ATTACK_DURATION seconds
	sword_charge_timer -= delta
	if sword_charge_timer <= 0:
		_deactivate_sword()
		previous_state = current_state
		current_state = State.IDLE

func _handle_charging_state(delta: float) -> void:
	sword_charge_timer += delta
	# If charge time exceeded, trigger spin attack
	if sword_charge_timer >= CHARGE_TIME:
		_perform_spin_attack()

func _handle_hurt_state(delta: float) -> void:
	sword_charge_timer += delta
	if sword_charge_timer >= INVINCIBILITY_FRAMES:
		invincible = false
		sword_charge_timer = 0.0
		previous_state = current_state
		current_state = State.IDLE

# ---------- Dash ----------

func _start_dash() -> void:
	if current_state == State.HURT or is_dashing:
		return
	
	# Dash only in cardinal direction
	dash_direction = Vector2(facing.x, facing.y)
	is_dashing = true
	previous_state = current_state
	current_state = State.DASHING

func _end_dash() -> void:
	is_dashing = false
	current_state = previous_state if previous_state != State.DASHING else State.IDLE

# ---------- Combat ----------

func _start_attack_charge() -> void:
	if current_state == State.HURT or invincible:
		return
	
	if current_state == State.DASHING:
		# Tap sword while dashing — single slash in dash direction
		_perform_single_attack(dash_direction)
		return
	
	is_charging = true
	sword_charge_timer = 0.0
	current_state = State.CHARGING

func _end_attack_charge() -> void:
	if not is_charging:
		return
	
	is_charging = false
	
	if current_state == State.CHARGING:
		# Released before charge time — single slash
		_perform_single_attack(facing)
		current_state = State.IDLE
		sword_charge_timer = 0.0

func _perform_single_attack(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		direction = facing
	
	facing = direction
	_activate_sword(direction)
	attacked.emit(facing, GameManager.get_sword_damage())
	
	# Brief attack animation
	if anim_player and anim_player.has_animation("attack_%s" % _direction_string(facing)):
		anim_player.play("attack_%s" % _direction_string(facing))
	
	# Deactivate after short delay
	await get_tree().create_timer(0.15).timeout
	_deactivate_sword()

func _perform_spin_attack() -> void:
	is_charging = false
	sword_charge_timer = SPIN_ATTACK_DURATION
	current_state = State.SPIN_ATTACKING
	
	# Full 360 hitbox — activate for duration
	_activate_sword_360()
	spin_attacked.emit(GameManager.get_sword_damage() + 1)  # +1 for spin
	
	if anim_player and anim_player.has_animation("spin_attack"):
		anim_player.play("spin_attack")

func _activate_sword(direction: Vector2i) -> void:
	if sword_hitbox:
		sword_hitbox.disabled = false
		# Position and rotate hitbox
		match direction:
			Vector2i.RIGHT:
				$SwordHitbox.position = Vector2(TILE_SIZE, 0)
				$SwordHitbox.rotation = 0
			Vector2i.LEFT:
				$SwordHitbox.position = Vector2(-TILE_SIZE, 0)
				$SwordHitbox.rotation = PI
			Vector2i.UP:
				$SwordHitbox.position = Vector2(0, -TILE_SIZE)
				$SwordHitbox.rotation = -PI / 2
			Vector2i.DOWN:
				$SwordHitbox.position = Vector2(0, TILE_SIZE)
				$SwordHitbox.rotation = PI / 2

func _activate_sword_360() -> void:
	# For now, activate all 4 directions
	if sword_hitbox:
		sword_hitbox.disabled = false
		$SwordHitbox.position = Vector2.ZERO
		$SwordHitbox.rotation = 0

func _deactivate_sword() -> void:
	if sword_hitbox:
		sword_hitbox.disabled = true

func _shoot_arrow() -> void:
	# Bow shot in facing direction — cardinal only
	# Requires Bow key item
	if not GameManager.has_key_item("bow"):
		return
	if GameManager.consumables.get("arrows", 0) <= 0:
		return
	
	GameManager.consumables["arrows"] -= 1
	
	# Emit signal for arrow spawning — cardinal direction only
	shot_arrow.emit(facing)

func _use_item() -> void:
	# Use equipped item in facing direction — cardinal only
	# Placeholder: will be wired to inventory system
	if not GameManager.has_equipped_item():
		return
	
	used_item.emit(facing)

# ---------- Collision & Movement ----------

func _update_velocity(delta: float) -> void:
	# Friction when no input
	if move_input == Vector2.ZERO and current_state == State.IDLE:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		if velocity.length() < 5.0:
			velocity = Vector2.ZERO

func _move_and_collide() -> void:
	move_and_slide()
	
	# Handle X-axis collision
	var collision_count: int = get_slide_collision_count()
	for i in range(collision_count):
		var collision = get_slide_collision(i)
		var normal: Vector2 = collision.get_normal()
		if abs(normal.x) > 0.5:
			# X-axis hit — stop horizontal movement
			velocity.x = 0
			if is_dashing:
				_end_dash()
			break
	
	# Handle Y-axis collision — snap to tile grid
	if is_on_floor():
		# Snap feet to tile top
		var tile_y: int = int(ceilf(position.y / float(TILE_SIZE)))
		position.y = float(tile_y) * float(TILE_SIZE)
	
	if is_on_ceiling():
		# Snap head to tile bottom
		var head_y: float = position.y + float(TILE_SIZE)
		var tile_y: int = int(floorf(head_y / float(TILE_SIZE)))
		position.y = float(tile_y + 1) * float(TILE_SIZE) - float(TILE_SIZE)

# ---------- Facing ----------

func _update_facing() -> void:
	if move_input != Vector2.ZERO:
		# Snap to nearest cardinal direction
		var abs_x: float = absf(move_input.x)
		var abs_y: float = absf(move_input.y)
		
		if abs_x > abs_y:
			facing = Vector2i(sign(move_input.x), 0)
		elif abs_y > abs_x:
			facing = Vector2i(0, sign(move_input.y))

# ---------- Damage ----------

func take_damage(amount: int, from_direction: Vector2i) -> void:
	if invincible:
		return
	
	# Passive shield block — check if facing the attack direction
	if GameManager.can_block_projectile(false):
		var facing_dir: Vector2 = Vector2(facing)
		# Check if player is facing the attack source
		var dot: float = facing_dir.dot(Vector2(from_direction))
		if dot <= 0:  # facing the attack
			# Blocked — no damage
			return
	
	# Apply damage
	amount -= GameManager.armor_level  # armor reduces by level
	amount = max(amount, 1)
	
	GameManager.player_health -= amount
	invincible = true
	invincibility_timer = INVINCIBILITY_FRAMES
	sword_charge_timer = 0.0
	current_state = State.HURT
	hurt.emit(amount)
	
	if anim_player and anim_player.has_animation("hurt"):
		anim_player.play("hurt")
	
	if GameManager.player_health <= 0:
		died.emit()
		GameManager.game_over.emit()

# ---------- Helpers ----------

func _interact() -> void:
	# Interact with nearby objects
	pass  # handled by world objects

func _quick_swap_item() -> void:
	# Cycle through key items
	pass  # handled by inventory system

func _toggle_pause() -> void:
	GameManager.game_paused = not GameManager.game_paused
	get_tree().paused = GameManager.game_paused

func _update_invincibility(delta: float) -> void:
	if invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			invincible = false

func _update_animation() -> void:
	if anim_player == null:
		return
	
	match current_state:
		State.IDLE:
			anim_player.play("idle_%s" % _direction_string(facing))
		State.WALKING:
			anim_player.play("walk_%s" % _direction_string(facing))
		State.DASHING:
			anim_player.play("dash_%s" % _direction_string(dash_direction))
		State.HURT:
			anim_player.play("hurt")

static func _direction_string(dir: Vector2i) -> String:
	match dir:
		Vector2i.RIGHT:
			return "right"
		Vector2i.LEFT:
			return "left"
		Vector2i.UP:
			return "up"
		Vector2i.DOWN:
			return "down"
		_:
			return "right"
