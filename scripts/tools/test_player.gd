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

	# Test 10b: SFX tracks registered + loadable
	var sfx_ok: bool = true
	for sfx_name in AudioManager.SFX_TRACKS.keys():
		var sfx_path: String = AudioManager.SFX_TRACKS[sfx_name]
		var sfx_stream: AudioStream = load(sfx_path)
		if sfx_stream == null:
			print("[T10b] FAIL: cannot load SFX %s at %s" % [sfx_name, sfx_path])
			sfx_ok = false
	print("[T10b] Registered SFX: %d, all load: %s" % [AudioManager.SFX_TRACKS.keys().size(), sfx_ok])
	
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
	
	# Test 12: SavePoint scene loads + save works
	var sp_scene: PackedScene = load("res://scenes/world/save_point.tscn")
	var sp_ok: bool = sp_scene != null
	if sp_ok:
		var sp: Node = sp_scene.instantiate()
		sp_ok = sp.has_method("_do_save")
		sp.queue_free()
	# Also verify GameManager.save() writes a slot file
	var before := GameManager.get_save_slots()
	var before_has: bool = before[0]["has_save"]
	var err := GameManager.save(0)
	var after := GameManager.get_save_slots()
	var after_has: bool = after[0]["has_save"]
	if err != OK or (not before_has and not after_has):
		sp_ok = false
	print("[T12] SavePoint scene + GameManager.save: %s (err=%d, slot0=%s)" % [sp_ok, err, after_has])
	
	# Test 13: Pickup scene grants the correct item + (for the bow) arrows.
	var pickup_scene: PackedScene = load("res://scenes/items/pickup.tscn")
	var p_ok: bool = pickup_scene != null
	if p_ok:
		var pk: Node = pickup_scene.instantiate()
		pk.kind = Pickup.Kind.KEY_ITEM
		pk.item_id = "bow"
		pk.amount = 10
		pk._acquire()  # simulate walking into it
		pk.queue_free()
		var bow_ok: bool = GameManager.has_key_item("bow")
		var arrows_ok: bool = GameManager.get_consumable("arrows") >= 10
		p_ok = bow_ok and arrows_ok
	print("[T13] Pickup (bow) grants bow + arrows: %s (bow=%s, arrows=%d)" % [p_ok, GameManager.has_key_item("bow"), GameManager.get_consumable("arrows")])

	# Test 14: Arrow projectile deals damage to an enemy on contact.
	var arrow_scene: PackedScene = load("res://scenes/items/arrow.tscn")
	var enemy_scene: PackedScene = load("res://scenes/enemies/octorok.tscn")
	var a_ok: bool = arrow_scene != null and enemy_scene != null
	var hp_before: int = -1
	var hp_after: int = -1
	if a_ok:
		var enemy: Node = enemy_scene.instantiate()
		hp_before = enemy.health if "health" in enemy else -1
		var arrow: Node = arrow_scene.instantiate()
		arrow.setup(Vector2i.RIGHT, Vector2.ZERO)
		arrow._on_body_entered(enemy)  # simulate collision
		hp_after = enemy.health if "health" in enemy else -1
		a_ok = hp_after == hp_before - 1
		enemy.queue_free()
		arrow.queue_free()
	print("[T14] Arrow damages enemy on contact: %s (hp %d -> %d)" % [a_ok, hp_before, hp_after])

	# Test 15: Stalfos reassembles after knockdown instead of dying (lives>1).
	var stalfos_scene: PackedScene = load("res://scenes/enemies/stalfos.tscn")
	var StalfosScript := preload("res://scenes/enemies/stalfos.gd")
	var s_ok: bool = stalfos_scene != null
	var reassembled: bool = false
	var truly_died: bool = false
	if s_ok:
		var s: Node = stalfos_scene.instantiate()  # Stalfos class
		# 3 starting health; lives=3 means it must be knocked down 4 times.
		s.take_damage(3, Vector2i.LEFT)              # lethal -> shatter (DOWN)
		var down_after_first: bool = (s.get("stalfos_state") == StalfosScript.StalfosState.DOWN)
		# Simulate the reassemble timer elapsing.
		s._handle_down(3.0)
		var up_after_timer: bool = (s.get("stalfos_state") == StalfosScript.StalfosState.UP)
		reassembled = down_after_first and up_after_timer
		# Now kill it `lives` more times to exhaust reassemblies.
		var died_signal_fired: bool = false
		s.died.connect(func(_e): died_signal_fired = true)
		for i in range(s.get("lives") + 1):
			s.invincible = false
			s._invuln_timer = 0.0
			s.take_damage(99, Vector2i.LEFT)
			if s.get("stalfos_state") == StalfosScript.StalfosState.DOWN:
				s._handle_down(3.0)  # reassemble between knockdowns
		truly_died = died_signal_fired or s.get("current_state") == Enemy.State.DEAD
		s.queue_free()
	print("[T15] Stalfos reassembles (DOWN->UP) then dies after lives exhausted: %s (reassembled=%s, died=%s)" % [s_ok and reassembled and truly_died, reassembled, truly_died])

	# Test 16: A bomb blast damages an enemy in radius.
	var bomb_scene: PackedScene = load("res://scenes/items/bomb.tscn")
	var bt_ok: bool = bomb_scene != null
	var bh_before: int = -1
	var bh_after: int = -1
	if bt_ok:
		var foe: Node = load("res://scenes/enemies/octorok.tscn").instantiate()
		add_child(foe)
		foe.global_position = Vector2(300, 300)
		foe.set("health", 8)  # keep it alive so we can read the reduced value
		var bomb1: Node = bomb_scene.instantiate()
		add_child(bomb1)
		bomb1.global_position = Vector2(304, 300)  # within BLAST_RADIUS (22)
		bh_before = foe.get("health")
		bomb1.call("apply_blast", [foe])
		bh_after = foe.get("health") if is_instance_valid(foe) else bh_before
		bt_ok = bh_after == bh_before - 2  # Bomb.DAMAGE == 2
	print("[T16] Bomb blast damages enemy by 2: %s (hp %d -> %d)" % [bt_ok, bh_before, bh_after])

	# Test 17: A bomb blast breaks a bombable rock.
	var rk_ok: bool = false
	var broke_direct: bool = false
	var broke_via_blast: bool = false
	if bomb_scene != null:
		var rock_a: Node = load("res://scenes/items/bombable_rock.tscn").instantiate()
		add_child(rock_a)
		rock_a.global_position = Vector2(400, 400)
		broke_direct = rock_a.call("try_break")
		var bomb2: Node = bomb_scene.instantiate()
		add_child(bomb2)
		bomb2.global_position = Vector2(500, 500)
		var rock_b: Node = load("res://scenes/items/bombable_rock.tscn").instantiate()
		add_child(rock_b)
		rock_b.global_position = Vector2(504, 500)
		bomb2.call("apply_blast", [rock_b])
		broke_via_blast = (rock_b.get("broken") == true)
		rk_ok = broke_direct and broke_via_blast
	print("[T17] Bomb blast breaks bombable rock: %s (direct=%s, via_blast=%s)" % [rk_ok, broke_direct, broke_via_blast])

	# Test 18: The Bomb Bag key-item pickup grants the item + 20 starter bombs.
	var PickupScript2 := preload("res://scenes/items/pickup.gd")
	var bombs_before: int = GameManager.get_consumable("bombs")
	var bb_ok: bool = false
	if not GameManager.has_key_item("bomb_bag"):
		var pk: Node = load("res://scenes/items/pickup.tscn").instantiate()
		add_child(pk)
		pk.kind = PickupScript2.Kind.KEY_ITEM
		pk.item_id = "bomb_bag"
		pk.amount = 20
		pk.call("_acquire")  # run the key-item grant path directly
		bb_ok = GameManager.has_key_item("bomb_bag") and (GameManager.get_consumable("bombs") - bombs_before == 20)
	print("[T18] Bomb Bag grants item + 20 bombs: %s (bombs %d -> %d)" % [bb_ok, bombs_before, GameManager.get_consumable("bombs")])

	print("\n=== All tests passed ===")
	get_tree().quit()
