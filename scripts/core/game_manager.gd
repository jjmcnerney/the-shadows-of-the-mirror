# GameManager — Singleton
# Manages game state, save data, and global progression

extends Node

## Save system
const SAVE_DIR := "user://"
const SAVE_COUNT := 3
const AUTO_SAVE_SUFFIX := "_autosave"

## Player progression
var max_hearts: int = 20
var starting_hearts: int = 4

## Game state
var current_region: String = "central_kingdom"
var current_area: String = "overworld"
var game_paused: bool = false
var game_running: bool = false

## Player stats
var player_health: int = 4:
	set(v):
		player_health = v
		player_health_changed.emit(v)
var player_max_health: int = 4:
	set(v):
		player_max_health = v
		player_health_changed.emit(v)
var player_magic: float = 0.0
var player_max_magic: float = 100.0
var player_magic_regen_rate: float = 5.0  # per second

## Live enemy count (debug HUD). Set via set_enemy_count().
var enemy_count: int = 0:
	set(v):
		enemy_count = v
		enemy_count_changed.emit(v)

## Inventory tracking
var key_items: Array[String] = []
var consumables: Dictionary = {
	"rupees": 0,
	"bombs": 0,
	"arrows": 0,
	"fairies": 0,
	"potions": 0,
}

## Progression flags
var completed_dungeons: Array[int] = []
var sages_rescued: Array[int] = []
var heart_pieces_collected: int = 0
var dark_mirrors_solved: Array[int] = []

## Sword level (0 = basic, 1 = upgraded, 2 = master)
var sword_level: int = 0

## Shield level (0 = none, 1 = basic, 2 = hylian)
var shield_level: int = 0

## Armor level (0 = none, 1 = red, 2 = blue)
var armor_level: int = 0

## Signal definitions
signal save_game(slot: int)
signal load_game(slot: int)
signal game_over
signal dungeon_completed(dungeon_id: int)
signal key_item_acquired(item_name: String)
signal consumable_changed(item_id: String, amount: int)
signal player_hurt(amount: int)
signal player_healed(amount: int)
signal player_health_changed(health: int)
signal enemy_count_changed(count: int)
signal area_entered(area_name: String)

func _ready() -> void:
	player_max_health = starting_hearts * 2  # hearts to HP (each heart = 2 HP)
	player_health = player_max_health

# ---------- Save / Load ----------

func save(slot: int, is_auto: bool = false) -> Error:
	if slot < 0 or slot >= SAVE_COUNT:
		return ERR_INVALID_PARAMETER
	
	var save_data: Dictionary = _build_save_data()
	var file_name := "save_%d%s.dat" % [slot + 1, AUTO_SAVE_SUFFIX if is_auto else ""]
	
	var file := FileAccess.open(SAVE_DIR + file_name, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	
	file.store_string(JSON.stringify(save_data, "  "))
	file.close()
	
	save_game.emit(slot)
	print("[GameManager] Game saved to slot %d (auto=%s)" % [slot + 1, is_auto])
	return OK

func load(slot: int) -> Error:
	if slot < 0 or slot >= SAVE_COUNT:
		return ERR_INVALID_PARAMETER
	
	var file_name := "save_%d.dat" % (slot + 1)
	var file := FileAccess.open(SAVE_DIR + file_name, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	var data_str := file.get_as_text()
	file.close()
	
	var save_data: Dictionary = JSON.parse_string(data_str)
	_restore_save_data(save_data)
	
	load_game.emit(slot)
	print("[GameManager] Game loaded from slot %d" % (slot + 1))
	return OK

func get_save_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for i in range(SAVE_COUNT):
		var file_name := "save_%d.dat" % (i + 1)
		var has_save := FileAccess.file_exists(SAVE_DIR + file_name)
		var auto_file_name := "save_%d_autosave.dat" % (i + 1)
		var has_auto := FileAccess.file_exists(SAVE_DIR + auto_file_name)
		
		slots.append({
			"slot": i,
			"has_save": has_save,
			"has_autosave": has_auto,
		})
	
	return slots

func _build_save_data() -> Dictionary:
	return {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"player": {
			"health": player_health,
			"max_health": player_max_health,
			"magic": player_magic,
			"position": null,  # filled by caller
		},
		"progression": {
			"dungeons_completed": completed_dungeons,
			"sages_rescued": sages_rescued,
			"heart_pieces": heart_pieces_collected,
			"dark_mirrors": dark_mirrors_solved,
			"sword_level": sword_level,
			"shield_level": shield_level,
			"armor_level": armor_level,
		},
		"inventory": {
			"key_items": key_items,
			"consumables": consumables,
		},
	}

func _restore_save_data(data: Dictionary) -> void:
	if not data.has("player"):
		return
	
	player_health = data["player"].get("health", starting_hearts * 2)
	player_max_health = data["player"].get("max_health", starting_hearts * 2)
	player_magic = data["player"].get("magic", player_max_magic)
	
	if data.has("progression"):
		var prog_dict: Dictionary = data["progression"]
		completed_dungeons = prog_dict.get("dungeons_completed", [])
		sages_rescued = prog_dict.get("sages_rescued", [])
		heart_pieces_collected = prog_dict.get("heart_pieces", 0)
		dark_mirrors_solved = prog_dict.get("dark_mirrors", [])
		sword_level = prog_dict.get("sword_level", 0)
		shield_level = prog_dict.get("shield_level", 0)
		armor_level = prog_dict.get("armor_level", 0)
	
	if data.has("inventory"):
		var inv_dict: Dictionary = data["inventory"]
		key_items = inv_dict.get("key_items", [])
		consumables = inv_dict.get("consumables", consumables)

# ---------- Progression ----------

func add_key_item(item_name: String) -> void:
	if not key_items.has(item_name):
		key_items.append(item_name)
		key_item_acquired.emit(item_name)
		# Auto-save on key item acquisition
		save(-1, true)  # auto-save

func remove_key_item(item_name: String) -> void:
	key_items.erase(item_name)

func has_key_item(item_name: String) -> bool:
	return key_items.has(item_name)

var equipped_item: String = ""  # currently equipped item for "use item" action

func has_equipped_item() -> bool:
	return equipped_item != ""

func equip_item(item_name: String) -> void:
	equipped_item = item_name

func complete_dungeon(dungeon_id: int) -> void:
	if not completed_dungeons.has(dungeon_id):
		completed_dungeons.append(dungeon_id)
		dungeon_completed.emit(dungeon_id)
		# Heart container reward (dungeons 1-7)
		if dungeon_id < 8:  # 0-indexed, dungeon 8 is final
			add_heart_container()

func add_heart_container() -> void:
	if player_max_health < max_hearts * 2:
		player_max_health += 2
		player_health = player_max_health

func add_heart_piece() -> void:
	heart_pieces_collected += 1
	# Every 4 pieces = 1 heart container
	if heart_pieces_collected % 4 == 0:
		add_heart_container()

# ---------- Inventory: consumables ----------

func add_consumable(item_id: String, amount: int = 1) -> void:
	consumables[item_id] = consumables.get(item_id, 0) + amount
	consumable_changed.emit(item_id, consumables[item_id])

func get_consumable(item_id: String) -> int:
	return consumables.get(item_id, 0)

func consume_consumable(item_id: String, amount: int = 1) -> bool:
	var have: int = consumables.get(item_id, 0)
	if have < amount:
		return false
	consumables[item_id] = have - amount
	consumable_changed.emit(item_id, consumables[item_id])
	return true

# Heal the player by `amount` HP (half-heart units), capped at max.
func heal(amount: int) -> void:
	player_health = min(player_health + amount, player_max_health)
	player_healed.emit(amount)
	player_health_changed.emit(player_health)

# ---------- Combat helpers ----------

func get_sword_damage() -> int:
	return 1 + sword_level  # base 1, +1 per upgrade level

func get_damage_reduction() -> float:
	var reduction: float = 0.0
	if armor_level == 1:  # Red Armor
		reduction = 0.25
	elif armor_level == 2:  # Blue Armor
		reduction = 0.5
	
	if shield_level >= 1:
		reduction += 0.1
	
	return clampf(reduction, 0.0, 0.75)

func can_block_projectile(is_boss: bool) -> bool:
	if shield_level == 0:
		return false
	if is_boss:
		return false
	if shield_level == 1:  # Basic shield blocks small/medium
		return true
	if shield_level == 2:  # Hylian shield blocks all non-boss
		return true
	return false
