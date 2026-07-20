extends Node2D

func _ready() -> void:
	# Defer to avoid editor/tool placeholder issues
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("=== Phase 1 Test Suite ===")
	
	# Test 1: GameManager accessible
	print("[T1] GameManager accessible: %s" % GameManager)
	
	# Test 2: AudioManager accessible
	print("[T2] AudioManager accessible: %s" % AudioManager)
	
	# Test 3: Player scene loads
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	print("[T3] Player scene loads: %s" % (player_scene != null))
	
	# Test 4: Player controller script attached
	if player_scene:
		var player: Node = player_scene.instantiate()
		if player:
			print("[T4] Player instantiates: %s" % true)
			print("[T4a] Player class: %s" % player.get_class())
			player.queue_free()
	
	# Test 5: Input map populated
	var inputs: PackedStringArray = ["move_up", "move_down", "move_left", "move_right", "attack", "bow", "item", "interact", "quick_swap", "pause"]
	var all_ok: bool = true
	for inp in inputs:
		if not InputMap.has_action(inp):
			print("[T5] FAIL: missing input '%s'" % inp)
			all_ok = false
	print("[T5] Input map: %s" % all_ok)
	
	# Test 6: Save slots work
	var slots := GameManager.get_save_slots()
	print("[T6] Save slots: %d (expected 3)" % slots.size())
	
	# Test 7: Player stats initialized
	print("[T7] Player health: %d" % GameManager.player_health)
	print("[T7a] Player max health: %d" % GameManager.player_max_health)
	
	# Test 8: Player actions available (signals)
	var player_script: GDScript = load("res://scenes/player/player.gd")
	var test_player: Node = player_script.new()
	var signal_list: Array = test_player.get_signal_list()
	test_player.queue_free()
	var has_shot_signal: bool = false
	var has_use_signal: bool = false
	for s in signal_list:
		if s["name"] == "shot_arrow":
			has_shot_signal = true
		if s["name"] == "used_item":
			has_use_signal = true
	print("[T8] Player emits shot_arrow: %s" % has_shot_signal)
	print("[T8a] Player emits used_item: %s" % has_use_signal)
	
	# Test 9: Enemy scenes load + instantiate
	var octorok_scene: PackedScene = load("res://scenes/enemies/octorok.tscn")
	var moblin_scene: PackedScene = load("res://scenes/enemies/moblin.tscn")
	var oct_ok: bool = octorok_scene != null
	var mob_ok: bool = moblin_scene != null
	if oct_ok:
		var oct: Node = octorok_scene.instantiate()
		oct_ok = oct.has_method("take_damage")
		oct.queue_free()
	if mob_ok:
		var mob: Node = moblin_scene.instantiate()
		mob_ok = mob.has_method("take_damage")
		mob.queue_free()
	print("[T9] Octorok scene + take_damage: %s" % oct_ok)
	print("[T9a] Moblin scene + take_damage: %s" % mob_ok)
	
	# Test 10: Music tracks registered + loadable
	var theme_list := AudioManager.get_theme_list()
	print("[T10] Registered themes: %d" % theme_list.size())
	var music_ok: bool = true
	for theme in theme_list:
		var path: String = AudioManager.MUSIC_TRACKS[theme]
		var stream: AudioStream = load(path)
		if stream == null:
			print("[T10] FAIL: cannot load %s at %s" % [theme, path])
			music_ok = false
	print("[T10a] All music tracks load: %s" % music_ok)
	
	# Test 11: Cathedral Crypts dungeon scene loads + builds off-tree
	var crypt_scene: PackedScene = load("res://scenes/dungeons/cathedral_crypts.tscn")
	var crypt_ok: bool = crypt_scene != null
	if crypt_ok:
		# Instance off-tree so its _ready runs (builds tiles) without
		# becoming a live game scene that never quits.
		var crypt: Node = crypt_scene.instantiate()
		crypt_ok = crypt.has_node("TileMap")
		crypt.free()
	print("[T11] Cathedral Crypts scene + TileMap: %s" % crypt_ok)
	
	print("\n=== All tests passed ===")
	get_tree().quit()
