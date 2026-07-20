# Moblin — patrols, charges when aggroed
# Per requirements §11.1: "Patrols, charges when player enters range. Weakness: Sword (2 hits), Arrow"

extends Enemy

## Moblin-specific
var charge_speed: float = 120.0
var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO
var charge_timer: float = 0.0
const CHARGE_DURATION: float = 0.8
var charge_cooldown: float = 0.0
const CHARGE_COOLDOWN: float = 1.5

func _ready() -> void:
	super._ready()
	health = 2
	max_health = 2
	move_speed = 45.0
	aggro_radius = 90.0
	attack_radius = 20.0
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
			_handle_moblin_chase(delta)
		State.ATTACK:
			_handle_moblin_charge(delta)
		State.STUNNED:
			_handle_stunned(delta)
		State.DEAD:
			pass

func _handle_moblin_chase(delta: float) -> void:
	if player_ref == null:
		current_state = State.PATROL
		return
	
	var dist: float = global_position.distance_to(player_ref.global_position)
	
	# Return to patrol if player leaves
	if dist > aggro_radius * 1.5:
		current_state = State.PATROL
		return
	
	# Move toward player at normal speed
	var direction: Vector2 = (player_ref.global_position - global_position).normalized()
	velocity = direction * move_speed
	
	# Charge when in mid-range and cooldown ready
	charge_cooldown -= delta
	if dist < aggro_radius and dist > attack_radius * 2 and charge_cooldown <= 0.0:
		_start_charge(direction)

func _start_charge(direction: Vector2) -> void:
	is_charging = true
	charge_direction = direction
	charge_timer = CHARGE_DURATION
	current_state = State.ATTACK
	if sprite and sprite.material is ShaderMaterial:
		pass  # would tint red

func _handle_moblin_charge(delta: float) -> void:
	if not is_charging:
		current_state = State.CHASE
		return
	
	charge_timer -= delta
	velocity = charge_direction * charge_speed
	
	if charge_timer <= 0.0:
		is_charging = false
		charge_cooldown = CHARGE_COOLDOWN
		# After charge, brief pause then chase
		current_state = State.STUNNED
		stun_timer = 0.3
