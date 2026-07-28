# Main Menu
# Centered layout: Background (ColorRect) + CenterContainer > VBox > Title, Spacer, Buttons, Subtitle

extends Control

@onready var new_game_button: Button = $CenterContainer/VBox/NewGame
@onready var load_game_button: Button = $CenterContainer/VBox/LoadGame
@onready var quit_button: Button = $CenterContainer/VBox/Quit

func _ready() -> void:
	# Launch the window at 1024x896 (4x the 256x224 base) so the game opens
	# pixel-perfect at 4x by default. The ProjectSettings window size is not
	# reliably honored under stretch mode "viewport" + integer scaling, so we
	# set it explicitly here. The root window persists across scene changes.
	DisplayServer.window_set_size(Vector2i(1024, 896))
	new_game_button.pressed.connect(_on_new_game)
	load_game_button.pressed.connect(_on_load_game)
	quit_button.pressed.connect(_on_quit)
	
	# Check for autosaves
	_update_load_button()
	
	# Play placeholder overworld music on menu load
	AudioManager.play_theme("overworld_placeholder")

func _on_new_game() -> void:
	GameManager.game_running = true
	GameManager.game_paused = false
	get_tree().change_scene_to_file("res://scenes/dungeons/cathedral_crypts.tscn")

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
