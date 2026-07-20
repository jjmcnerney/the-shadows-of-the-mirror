# Octorok — spits rocks at range, hides in shell when hit
# Per requirements §11.1: "Spits rocks at range, hides in shell. Weakness: Sword (when exposed), Arrow to head"

extends Enemy

## Octorok-specific properties
enum OctorokState {
	NORMAL,    # exposed, can be hit by sword
	SHELL,     # hiding in shell, only arrow to head works
}

var octorok_state: OctorokState = OctorokState.NORMAL
var shell_timer: float = 0.0
const SHELL_DURATION: float = 1.5

## Rock projectile (will be a scene later)
const ROCK_SPEED: float = 120.0
var shoot_cooldown: float = 0.0
const SHOOT_INTERVAL: float = 2.0

func _ready() -> void:
	super._ready()
	health = 2
	max_health = 2
	move_speed = 30.0
	aggro_radius = 100.0
	attack_radius = 90.0  # shoots from range
	contact_damage = 1

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
			_handle_octorok_attack(delta)
		State.STUNNED:
			_handle_stunned(delta)
		State.DEAD:
			pass

func _handle_octorok_attack(delta: float) -> void:
	velocity = Vector2.ZERO
	
	if player_ref == null:
		current_state = State.PATROL
		return
	
	# Shoot rock at player on cooldown
	shoot_cooldown -= delta
	if shoot_cooldown <= 0.0:
		_shoot_rock()
		shoot_cooldown = SHOOT_INTERVAL
	
	# If player gets too close, retreat/patrol
	var dist: float = global_position.distance_to(player_ref.global_position)
	if dist < attack_radius * 0.5:
		current_state = State.CHASE
	elif dist > aggro_radius * 1.5:
		current_state = State.PATROL

func _shoot_rock() -> void:
	# Placeholder: would spawn a RockProjectile scene
	# For now, just print (will be wired to projectile system)
	print("[Octorok] shoots rock toward player")

func _handle_shell_state(delta: float) -> void:
	shell_timer -= delta
	velocity = Vector2.ZERO
	if shell_timer <= 0.0:
		octorok_state = OctorokState.NORMAL

## Override take_damage for shell mechanic
func take_damage(amount: int, from_direction: Vector2i, knockback: float = 100.0) -> void:
	if current_state == State.DEAD:
		return
	
	if octorok_state == OctorokState.SHELL:
		# Only arrow to head can hit — sword bounces off
		# For Phase 1, we treat any hit as effective (placeholder)
		# TODO: check if hit is arrow + head
		pass
	
	health -= amount
	knockback_velocity = Vector2(from_direction) * knockback
	
	if health <= 0:
		_die()
	else:
		# Octorok hides in shell when hit
		octorok_state = OctorokState.SHELL
		shell_timer = SHELL_DURATION
		current_state = State.STUNNED
		stun_timer = STUN_DURATION
