# Main Menu

extends Control

@onready var new_game_button: Button = $Buttons/NewGame
@onready var load_game_button: Button = $Buttons/LoadGame
@onready var quit_button: Button = $Buttons/Quit

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	load_game_button.pressed.connect(_on_load_game)
	quit_button.pressed.connect(_on_quit)
	
	# Check for autosaves
	_update_load_button()

func _on_new_game() -> void:
	GameManager.game_running = true
	GameManager.game_paused = false
	get_tree().change_scene_to_file("res://scenes/main/test_world.tscn")

func _on_load_game() -> void:
	print("[MainMenu] Load game not yet implemented")

func _on_quit() -> void:
	get_tree().quit()

func _update_load_button() -> void:
	var slots = GameManager.get_save_slots()
	var has_any: bool = false
	for slot in slots:
		if slot["has_save"]:
			has_any = true
			break
	load_game_button.disabled = not has_any
