# Player Controller
# 8-directional movement, dash, sword combat, passive shield block

class_name Player extends CharacterBody2D

## Movement constants
const TILE_SIZE: int = 16
const WALK_SPEED: float = 100.0
const DASH_SPEED: float = 250.0
const SWIM_SPEED: float = 60.0
const ACCELERATION: float = 800.0
const FRICTION: float = 1200.0
const JUMP_SPEED: float = 200.0  # horizontal speed during jump arc
const JUMP_DURATION: float = 0.35  # time in air
const JUMP_ARC_HEIGHT: float = 12.0  # visual Y offset for arc

## Combat constants
const SWORD_DAMAGE: int = 1
const SWING_COOLDOWN: float = 0.3  # min time between sword swings
const INVINCIBILITY_FRAMES: float = 1.0  # i-frames after taking damage
const STUN_DURATION: float = 0.5  # hurt/stumble duration (half of i-frames)

## Player state enum
enum State {
	IDLE,
	WALKING,
	DASHING,
	JUMPING,
	ATTACKING,
	HURT,
	SWIMMING,
	CLIMBING,
	DEAD,
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

# Sword charge timer (reused by the hurt/invincibility state)
var sword_charge_timer: float = 0.0
# Cooldown timer between swings (0 = ready)
var sword_cooldown: float = 0.0

# Jump state
var jump_direction: Vector2 = Vector2.ZERO
var jump_timer: float = 0.0
var jump_arc_offset: float = 0.0  # visual Y offset for jump arc

# Invincibility after hurt
var invincible: bool = false
var invincibility_timer: float = 0.0
# Hurt/stumble tracking (separate from i-frames so stun < invuln window)
var _hurt_timer: float = 0.0
var _hurt_knockback: Vector2 = Vector2.ZERO

# Animation reference
var anim_player: AnimationPlayer

# Sprite reference
@onready var sprite: Sprite2D = $Sprite2D

# Sword hit area (Area2D so it actually detects enemy overlaps)
@onready var sword_area: Area2D = $SwordArea
# The actual collision shape inside the area. It is created DISABLED in the
# .tscn; we enable it only for the duration of a swing and place it in front
# of the player based on facing direction.
@onready var sword_hitbox: CollisionShape2D = $SwordArea/SwordHitbox
# Visible blade shown during a swing (procedural texture, no art asset yet)
@onready var sword_swing: Sprite2D = $SwordSwing
# Enemies already struck during the current swing (prevents multi-hit)
var _hit_this_swing: Array[Node] = []

# Bow projectile scene (spawned on the "bow" action)
const ARROW_SCENE: PackedScene = preload("res://scenes/items/arrow.tscn")

# Shield visual
@onready var shield_visual: Sprite2D = $Shield

# Camera follow
@onready var camera: Camera2D = $Camera2D

## Signals
signal attacked(direction: Vector2i, damage: int)
signal shot_arrow(direction: Vector2i)
signal used_item(direction: Vector2i)
signal hurt(amount: int)
signal died

func _ready() -> void:
	if has_node("AnimationPlayer"):
		anim_player = $AnimationPlayer

	# Ensure the player is discoverable by enemies/AI. The scene's `groups`
	# declaration is sometimes dropped by the importer in this setup, so we
	# add it explicitly and defensively.
	add_to_group("player")

	# Force NEAREST texture filtering on every visual we draw so the camera
	# zoom + viewport upscale never bilinear-blurs pixel art (the project
	# default is also Nearest, but we set it explicitly to be bulletproof).
	_apply_nearest_filter()

	# Top-down game: use FLOATING motion mode so there is no "floor"/"ceiling"
	# axis and all 4 walls collide symmetrically (no platformer snap that would
	# misfire on the top/bottom walls).
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Sword area starts disabled (no monitoring until an attack)
	if sword_area:
		sword_area.monitoring = false
		sword_area.body_entered.connect(_on_sword_body_entered)
		# Track which enemies we've already hit this swing to avoid multi-hits
		_hit_this_swing.clear()
	_build_sword_texture()

	# Bow: spawn a real arrow projectile when the player shoots.
	shot_arrow.connect(_on_shot_arrow)

# Force NEAREST (value 1) texture filtering on the player's sprites. This is the
# pixel-perfect guarantee: even if a project/import default were ever Linear,
# these nodes sample with nearest-neighbor so pixel edges stay hard.
func _apply_nearest_filter() -> void:
	for sp in [sprite, shield_visual, sword_swing]:
		if sp != null:
			sp.texture_filter = 1

func _process(delta: float) -> void:
	_update_input()
	_handle_state(delta)
	_update_facing()
	_update_invincibility(delta)
	_update_animation()
	_update_invincibility_blink()
	# Tick down the sword swing cooldown.
	if sword_cooldown > 0.0:
		sword_cooldown = max(0.0, sword_cooldown - delta)

func _physics_process(delta: float) -> void:
	_update_velocity(delta)
	_move_and_collide()

# ---------- Input ----------

func _input(event: InputEvent) -> void:
	if GameManager.game_paused:
		return
	
	if current_state == State.HURT:
		return
	
	## Sword attack — swing fires on KEY DOWN (press), not release.
	# A 0.3s cooldown (SWING_COOLDOWN) prevents swing spam.
	if event.is_action_pressed("attack"):
		_try_swing()
	
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
	if current_state == State.DEAD:
		velocity = Vector2.ZERO
		return

	# NOTE: We deliberately do NOT freeze on `invincible` here. The stun is the
	# HURT state only (ends at STUN_DURATION). After the stun ends the player
	# regains full control even though i-frames (invincible) may still be
	# active — they just can't take damage. Damage immunity is enforced in
	# take_damage(), not by freezing movement here.
	match current_state:
		State.IDLE, State.WALKING:
			_handle_movement_state(delta)
		State.DASHING:
			_handle_dash_state(delta)
		State.JUMPING:
			_handle_jump_state(delta)
		State.ATTACKING:
			_handle_attack_state(delta)
		State.HURT:
			_handle_hurt_state(delta)

func _handle_movement_state(delta: float) -> void:
	var speed: float = walk_speed
	
	# Dash is gated behind the Pegasus Boots (not yet obtainable in the Phase 1
	# demo), so Space currently does nothing — this keeps "basic collision"
	# testing clean until the boots are introduced.
	if Input.is_action_just_pressed("interact") and GameManager.has_key_item("pegasus_boots") and not is_dashing:
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

	# Contextual jump (dashing off a ledge) is disabled for now. This is a
	# top-down dungeon with solid floor everywhere and up_direction = ZERO, so
	# the old "if not is_on_floor()" check fired on EVERY dash (is_on_floor is
	# always false). Re-enable once a gap/ledge system exists (see §6.2).

	# Dash ends when the player releases the button; hitting a wall ends it in
	# _move_and_collide().
	if not Input.is_action_pressed("interact"):
		_end_dash()

func _handle_jump_state(delta: float) -> void:
	jump_timer += delta
	var progress: float = jump_timer / JUMP_DURATION
	
	# Horizontal movement continues during jump
	velocity = jump_direction * JUMP_SPEED
	
	# Visual arc: sin curve from 0 to PI gives up-down arc
	jump_arc_offset = sin(progress * PI) * JUMP_ARC_HEIGHT
	
	if jump_timer >= JUMP_DURATION:
		# Land
		jump_arc_offset = 0.0
		previous_state = current_state
		current_state = State.IDLE
		jump_timer = 0.0
		if anim_player and anim_player.has_animation("land"):
			anim_player.play("land")

func _start_jump(direction: Vector2) -> void:
	if current_state == State.HURT or current_state == State.JUMPING:
		return
	
	jump_direction = direction.normalized()
	jump_timer = 0.0
	is_dashing = false  # jumping cancels dash
	previous_state = current_state
	current_state = State.JUMPING
	
	if anim_player and anim_player.has_animation("jump"):
		anim_player.play("jump")

func _handle_attack_state(delta: float) -> void:
	# Single frame attack — just deal damage and return to previous state
	previous_state = current_state
	current_state = previous_state

func _handle_hurt_state(delta: float) -> void:
	# Stumble: a short, slow drift in the knockback direction. The player's
	# prior momentum was cancelled the instant damage was taken (see
	# take_damage), so this is a fresh, slow push — not preserved velocity.
	var stumble_speed: float = WALK_SPEED * 0.35
	velocity = _hurt_knockback * stumble_speed

	# i-frames keep running for the full INVINCIBILITY_FRAMES; the stun (and
	# the stumble movement) ends earlier at STUN_DURATION.
	_hurt_timer += delta
	if _hurt_timer >= STUN_DURATION:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		_hurt_knockback = Vector2.ZERO

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

# Swing on key-down. Blocked only during the stun (HURT state); i-frames after
# the stun end DO still allow acting — they only protect from damage.
func _try_swing() -> void:
	if current_state == State.HURT:
		return
	if sword_cooldown > 0.0:
		return  # on cooldown — ignore

	if current_state == State.DASHING:
		# Tap sword while dashing — single slash in dash direction
		_perform_single_attack(dash_direction)
		return

	# Immediate single swing on press.
	_perform_single_attack(facing)

func _perform_single_attack(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		direction = facing

	facing = direction
	_activate_sword(direction)
	attacked.emit(facing, GameManager.get_sword_damage())

	# Start the swing cooldown so swings can't be spammed.
	sword_cooldown = SWING_COOLDOWN

	AudioManager.play_sfx_named("sword_slash", global_position)
	
	# Brief attack animation
	if anim_player and anim_player.has_animation("attack_%s" % _direction_string(facing)):
		anim_player.play("attack_%s" % _direction_string(facing))
	
	# Deactivate after short delay
	await get_tree().create_timer(0.15).timeout
	_deactivate_sword()

func _activate_sword(direction: Vector2i) -> void:
	_hit_this_swing.clear()
	_position_sword_hitbox(direction)
	if sword_area:
		sword_area.monitoring = true
		# Immediately hit anything already overlapping (don't depend solely on
		# the body_entered signal, which fires on the next physics frame).
		for b in sword_area.get_overlapping_bodies():
			_try_hit(b)
	# Position + show the visible blade in front of the player
	_show_sword_swing(direction)

func _deactivate_sword() -> void:
	if sword_area:
		sword_area.monitoring = false
	if sword_hitbox:
		sword_hitbox.disabled = true
	if sword_swing:
		sword_swing.visible = false

# Place the (disabled-by-default) sword hitbox in front of the player based on
# the swing direction so it actually intersects whatever the player is facing.
func _position_sword_hitbox(direction: Vector2i) -> void:
	if sword_hitbox == null:
		return
	sword_hitbox.disabled = false
	match direction:
		Vector2i.RIGHT:
			sword_hitbox.position = Vector2(TILE_SIZE, 0)
			sword_hitbox.rotation = 0
		Vector2i.LEFT:
			sword_hitbox.position = Vector2(-TILE_SIZE, 0)
			sword_hitbox.rotation = 0
		Vector2i.UP:
			sword_hitbox.position = Vector2(0, -TILE_SIZE)
			sword_hitbox.rotation = 0
		Vector2i.DOWN:
			sword_hitbox.position = Vector2(0, TILE_SIZE)
			sword_hitbox.rotation = 0
		_:
			sword_hitbox.position = Vector2(TILE_SIZE, 0)
			sword_hitbox.rotation = 0

# Apply sword damage to a body if it's an enemy we haven't hit this swing.
func _try_hit(body: Node) -> void:
	if body == self:
		return
	if body is Enemy and not (body in _hit_this_swing):
		_hit_this_swing.append(body)
		var dmg := GameManager.get_sword_damage()
		var dir := Vector2i(signi(body.global_position.x - global_position.x),
		                    signi(body.global_position.y - global_position.y))
		body.take_damage(dmg, dir)

func _show_sword_swing(direction: Vector2i) -> void:
	if sword_swing == null:
		return
	sword_swing.visible = true
	sword_swing.texture = _sword_texture
	match direction:
		Vector2i.RIGHT:
			sword_swing.position = Vector2(TILE_SIZE, 0)
			sword_swing.rotation = 0
		Vector2i.LEFT:
			sword_swing.position = Vector2(-TILE_SIZE, 0)
			sword_swing.rotation = 0
		Vector2i.UP:
			sword_swing.position = Vector2(0, -TILE_SIZE)
			sword_swing.rotation = -PI / 2
		Vector2i.DOWN:
			sword_swing.position = Vector2(0, TILE_SIZE)
			sword_swing.rotation = -PI / 2
		_:
			sword_swing.position = Vector2(TILE_SIZE, 0)
			sword_swing.rotation = 0

# Called by SwordArea.body_entered on subsequent overlaps during the swing.
func _on_sword_body_entered(body: Node) -> void:
	_try_hit(body)

# Procedurally build a tiny blade texture so the swing is visible without art.
var _sword_texture: Texture2D = null
func _build_sword_texture() -> void:
	if _sword_texture != null:
		return
	var img := Image.create(14, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.85, 0.85, 0.9, 1.0))            # blade (light steel)
	# hilt
	for x in range(14):
		img.set_pixel(x, 0, Color(0.55, 0.4, 0.2, 1.0))
		img.set_pixel(x, 5, Color(0.55, 0.4, 0.2, 1.0))
	var tex := ImageTexture.create_from_image(img)
	tex.resource_local_to_scene = true
	_sword_texture = tex

func _shoot_arrow() -> void:
	# Bow shot in facing direction — cardinal only. Requires Bow key item and
	# at least one arrow in the quiver.
	if not GameManager.has_key_item("bow"):
		return
	if not GameManager.consume_consumable("arrows", 1):
		return

	# Spawn the actual projectile (off-tree scene, reparented into the world).
	var arrow: Node2D = ARROW_SCENE.instantiate()
	arrow.setup(facing, global_position + Vector2(facing) * 12.0)
	get_parent().add_child(arrow)

	AudioManager.play_sfx_named("bow_twang", global_position)

# Spawned by the `shot_arrow` signal — kept so other systems (e.g. the HUD)
# can react to bow fire if needed. The projectile itself is spawned in
# _shoot_arrow above.
func _on_shot_arrow(_direction: Vector2i) -> void:
	pass

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

	# Top-down movement: move_and_slide() stops the player cleanly against any
	# wall (left/right/top/bottom) and zeroes the blocked velocity component on
	# its own. No grid-snapping is needed — the old vertical snap teleported
	# position.y and caused the rubbery top wall / clip-into-bottom-wall bug.
	# End a dash if we hit a wall (any axis).
	if is_dashing and get_slide_collision_count() > 0:
		_end_dash()

	# Apply jump arc visual offset to sprite (doesn't affect physics position)
	if has_node("Sprite2D"):
		$Sprite2D.position.y = -jump_arc_offset

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
	# Cancel any momentum the player had — the hurt response starts from a
	# standstill, then plays a short slow stumble (see _handle_hurt_state).
	velocity = Vector2.ZERO
	_hurt_timer = 0.0
	_hurt_knockback = Vector2(from_direction)
	current_state = State.HURT
	hurt.emit(amount)
	
	AudioManager.play_sfx_named("player_hurt", global_position)
	
	if anim_player and anim_player.has_animation("hurt"):
		anim_player.play("hurt")
	
	if GameManager.player_health <= 0:
		current_state = State.DEAD
		velocity = Vector2.ZERO
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

# Strobe the player's visuals while invulnerable so the i-frame window is
# clearly visible. A hard on/off blink (not a smooth fade) reads as "flashing".
func _update_invincibility_blink() -> void:
	if sprite == null:
		return
	var alpha := 1.0
	if invincible:
		# ~8 Hz strobe: on for first half of each 0.12s period.
		alpha = 1.0 if fmod(Time.get_ticks_msec() / 1000.0, 0.12) < 0.06 else 0.25
	sprite.modulate.a = alpha
	if shield_visual != null:
		shield_visual.modulate.a = alpha
	if sword_swing != null:
		sword_swing.modulate.a = alpha

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
		State.JUMPING:
			anim_player.play("jump")
		State.HURT:
			anim_player.play("hurt")
	
	# Flip sprite to match horizontal facing direction
	if sprite != null:
		sprite.scale.x = -1 if facing.x < 0 else 1

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
