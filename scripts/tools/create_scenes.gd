# create_scenes.gd — Run once via: godot --headless --execute-script res://scripts/tools/create_scenes.gd
# Creates the main menu and test world scenes programmatically

extends SceneTree

func _init() -> void:
	create_main_menu_scene()
	create_test_world_scene()
	create_player_scene()
	print("[create_scenes] All scenes created successfully.")
	quit()

func create_main_menu_scene() -> void:
	# Main menu root
	var root := Control.new()
	root.name = "MainMenu"
	
	# Script
	var script: Script = load("res://scenes/main/main_menu.gd") as Script
	root.set_script(script)
	
	# Background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.05, 0.05, 0.1, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	
	# Title label
	var title := Label.new()
	title.name = "Title"
	title.text = "The Shadows of the Mirror"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.set_anchors_and_margin_preset(Control.PRESET_TOP_WIDE)
	title.anchor_bottom = 0.0
	title.offset_top = 80.0
	title.offset_bottom = 140.0
	root.add_child(title)
	
	# Button container
	var vbox := VBoxContainer.new()
	vbox.name = "Buttons"
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = 320.0
	vbox.offset_top = 200.0
	vbox.offset_right = 440.0
	vbox.offset_bottom = 340.0
	root.add_child(vbox)
	
	# New Game button
	var new_btn := Button.new()
	new_btn.name = "NewGame"
	new_btn.text = "New Game"
	vbox.add_child(new_btn)
	
	# Load Game button
	var load_btn := Button.new()
	load_btn.name = "LoadGame"
	load_btn.text = "Load Game"
	vbox.add_child(load_btn)
	
	# Quit button
	var quit_btn := Button.new()
	quit_btn.name = "Quit"
	quit_btn.text = "Quit"
	vbox.add_child(quit_btn)
	
	# Save
	var packer := ResourceSaver.new()
	packer.save(root, "res://scenes/main/main_menu.tscn")
	print("[create_scenes] Created main_menu.tscn")

func create_test_world_scene() -> void:
	# Test world root
	var root := Node2D.new()
	root.name = "TestWorld"
	
	# Ground collision
	var ground := CollisionShape2D.new()
	ground.name = "Ground"
	var ground_shape := SegmentShape2D.new()
	ground_shape.a = Vector2(-512, 224)
	ground_shape.b = Vector2(512, 224)
	ground.shape = ground_shape
	root.add_child(ground)
	
	# Ceiling
	var ceiling := CollisionShape2D.new()
	ceiling.name = "Ceiling"
	var ceiling_shape := SegmentShape2D.new()
	ceiling_shape.a = Vector2(-512, -256)
	ceiling_shape.b = Vector2(512, -256)
	ceiling.shape = ceiling_shape
	root.add_child(ceiling)
	
	# Walls
	var wall_left := CollisionShape2D.new()
	wall_left.name = "WallLeft"
	var wall_left_shape := SegmentShape2D.new()
	wall_left_shape.a = Vector2(-256, -256)
	wall_left_shape.b = Vector2(-256, 224)
	wall_left.shape = wall_left_shape
	root.add_child(wall_left)
	
	var wall_right := CollisionShape2D.new()
	wall_right.name = "WallRight"
	var wall_right_shape := SegmentShape2D.new()
	wall_right_shape.a = Vector2(256, -256)
	wall_right_shape.b = Vector2(256, 224)
	wall_right.shape = wall_right_shape
	root.add_child(wall_right)
	
	# Player
	var player_scene := PackedScene.new()
	# Load player scene if it exists
	var player_path := "res://scenes/player/player.tscn"
	if ResourceLoader.exists(player_path):
		var player: Node = ResourceLoader.load(player_path) as Node
		if player:
			player.position = Vector2(0, 192)
			root.add_child(player)
	else:
		print("[create_scenes] Player scene not found at %s" % player_path)
	
	# Camera
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = false
	root.add_child(camera)
	
	# Save
	var packer := ResourceSaver.new()
	packer.save(root, "res://scenes/main/test_world.tscn")
	print("[create_scenes] Created test_world.tscn")

func create_player_scene() -> void:
	# Player root (CharacterBody2D)
	var root := CharacterBody2D.new()
	root.name = "Player"
	
	# Script
	var script: Script = load("res://scenes/player/player.gd") as Script
	root.set_script(script)
	
	# Sprite
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.scale = Vector2(3.0, 3.0)
	root.add_child(sprite)
	
	# Sword hitbox
	var sword := CollisionShape2D.new()
	sword.name = "SwordHitbox"
	sword.disabled = true
	var sword_shape := RectangleShape2D.new()
	sword_shape.size = Vector2(16, 8)
	sword.shape = sword_shape
	root.add_child(sword)
	
	# Shield visual
	var shield := Sprite2D.new()
	shield.name = "Shield"
	root.add_child(shield)
	
	# Camera
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = false
	root.add_child(camera)
	
	# Save
	var packer := ResourceSaver.new()
	packer.save(root, "res://scenes/player/player.tscn")
	print("[create_scenes] Created player.tscn")
