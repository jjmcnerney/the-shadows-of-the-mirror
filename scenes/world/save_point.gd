# SavePoint — interactable save trigger
# Phase 1 (T1.4.6): manual save at save point, 3 save slots
#
# Player walks onto the save point and presses interact (Space) to save.
# A prompt appears while standing on it. Per requirements §13.3 (manual save
# at save points) and §13.4 (Space = interact/dash).

extends Area2D

@export var save_slot: int = 0  # 0..2 -> save slots 1..3

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

var player_inside: bool = false

func _ready() -> void:
	# Pixel-perfect: force NEAREST filtering on the save point sprite.
	if sprite != null:
		sprite.texture_filter = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt:
		prompt.visible = false

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	player_inside = true
	if prompt:
		prompt.visible = true
		prompt.text = "Press SPACE to save"

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	player_inside = false
	if prompt:
		prompt.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not player_inside:
		return
	if event.is_action_pressed("interact"):
		_do_save()

func _do_save() -> void:
	var err: Error = GameManager.save(save_slot)
	if err == OK:
		if prompt:
			prompt.text = "Saved!"
			# Reset prompt text after a moment
			await get_tree().create_timer(1.0).timeout
			if player_inside and prompt:
				prompt.text = "Press SPACE to save"
	else:
		printerr("[SavePoint] Save failed, slot %d, err %d" % [save_slot, err])
