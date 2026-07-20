# Test world - runs for a few frames then quits
extends Node2D

func _ready():
	# Run for a few physics frames
	await get_tree().create_timer(0.1).timeout
	
	# Test player movement
	var player = $Player
	if player:
		print("Player found at: ", player.position)
		
		# Simulate some input
		Input.set_vector("move_left", "move_right", "move_up", "move_down", Vector2.RIGHT)
		
		# Test health
		print("Player health: ", GameManager.player_health)
		
		# Test damage
		player.take_damage(1, Vector2i.LEFT)
		print("After damage: ", GameManager.player_health)
	
	# Quit after test
	await get_tree().create_timer(0.05).timeout
	get_tree().quit(0)
