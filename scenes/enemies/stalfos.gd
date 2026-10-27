# Stalfos — skeleton miniboss that reassembles after being knocked down.
# Per development plan §4 Week 6 (T2.2.4): "Skeleton guards Bomb Bag, reassembles."
#
# Mechanic: a Stalfos patrols/chases like a normal enemy, but when its health
# reaches 0 it does NOT die — it shatters into bones (a harmless "DOWN" state)
# and after REASSEMBLE_DELAY reassembles with full health and resumes the fight.
# This repeats up to `lives` times; on the final knockdown it truly dies.
# (Classic ALttP Stalfos loop, simplified: no separate bone-pile scene, just a
# timed knockdown + heal-back-up.)

extends Enemy

## Stalfos-specific sub-state layered on top of the base Enemy.State machine.
enum StalfosState {
	UP,    # normal combat (uses base PATROL/CHASE/ATTACK underneath)
	DOWN,  # shattered, lying on the floor, harmless, reassembling
}

## How many times it reassembles before truly dying (lives = reassemblies + 1).
@export var lives: int = 3

var stalfos_state: StalfosState = StalfosState.UP
var reassemble_timer: float = 0.0
const REASSEMBLE_DELAY: float = 2.5
var reassemblies_done: int = 0

## Brief post-reassemble invulnerability so it isn't instantly re-shattered.
var invincible: bool = false
var _invuln_timer: float = 0.0

func _ready() -> void:
	super._ready()
	health = 3
	max_health = 3
	move_speed = 35.0
	aggro_radius = 110.0
	attack_radius = 22.0
	contact_damage = 1
	is_boss = false

# Full physics override: gate the whole base loop on the DOWN state.
func _physics_process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
		if _invuln_timer <= 0.0:
			invincible = false

	if stalfos_state == StalfosState.DOWN:
		_handle_down(delta)
		move_and_slide()
		return

	# UP: run the normal Enemy physics loop (AI + knockback + move + contact dmg).
	super._physics_process(delta)

	# If we just popped back up, restore upright visuals.
	if sprite != null and sprite.rotation_degrees != 0.0:
		sprite.rotation_degrees = 0.0
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _update_ai(delta: float) -> void:
	# Only reached while UP (DOWN is intercepted in _physics_process).
	match current_state:
		State.PATROL: _handle_patrol(delta)
		State.IDLE:   _handle_idle(delta)
		State.ALERT:  _handle_alert(delta)
		State.CHASE:  _handle_chase(delta)
		State.ATTACK: _handle_attack(delta)
		State.STUNNED: _handle_stunned(delta)
		State.DEAD:   pass

func _handle_down(delta: float) -> void:
	velocity = Vector2.ZERO
	reassemble_timer -= delta
	if reassemble_timer <= 0.0:
		_reassemble()

func _reassemble() -> void:
	reassemblies_done += 1
	health = max_health
	stalfos_state = StalfosState.UP
	current_state = State.CHASE  # pop back up already aggroed
	invincible = true
	_invuln_timer = 0.6

## Override take_damage: on a (non-final) lethal hit, shatter instead of dying.
func take_damage(amount: int, from_direction: Vector2i, knockback: float = 100.0) -> void:
	if current_state == State.DEAD:
		return
	if stalfos_state == StalfosState.DOWN:
		return  # already shattered; ignore hits until it gets up
	if invincible:
		return  # post-reassemble grace window

	health -= amount
	knockback_velocity = Vector2(from_direction) * knockback
	AudioManager.play_sfx_named("enemy_hurt" if not is_boss else "boss_hurt", global_position)

	if health <= 0:
		if reassemblies_done < lives:
			_shatter()
		else:
			_die()
	else:
		current_state = State.STUNNED
		stun_timer = STUN_DURATION

func _shatter() -> void:
	stalfos_state = StalfosState.DOWN
	current_state = State.STUNNED
	reassemble_timer = REASSEMBLE_DELAY
	velocity = Vector2.ZERO
	# Visually drop flat — rotate the sprite to read as "fallen".
	if sprite != null:
		sprite.rotation_degrees = 90.0
		sprite.modulate = Color(0.7, 0.7, 0.7, 1.0)
