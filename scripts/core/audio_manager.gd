# AudioManager — Singleton
# Manages music, SFX, and audio bus mixing

extends Node

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

var music_player: AudioStreamPlayer = null

var current_theme: String = ""
var fade_duration: float = 1.0

# SFX player pool
const MAX_SFX_PLAYERS := 8

func _ready() -> void:
	# Create music player dynamically
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var sfx := AudioStreamPlayer2D.new()
		sfx.bus = SFX_BUS
		add_child(sfx)

# ---------- Music ----------

func play_music(stream_path: String, volume: float = -6.0) -> void:
	var stream: AudioStream = load(stream_path)
	if stream == null:
		printerr("[AudioManager] Failed to load music: %s" % stream_path)
		return
	
	# Crossfade if another theme is playing
	if current_theme != "" and music_player.playing:
		await _fade_out_music()
	
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()
	current_theme = stream_path
	print("[AudioManager] Playing: %s" % stream_path)

func stop_music(fade: bool = false) -> void:
	if fade:
		await _fade_out_music()
	else:
		music_player.stop()
	current_theme = ""

func _fade_out_music() -> void:
	if not music_player.playing:
		return
	
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
	await tween.finished
	music_player.stop()

# ---------- SFX ----------

func play_sfx(stream_path: String, position: Vector2 = Vector2.ZERO, volume: float = 0.0) -> void:
	var stream: AudioStream = load(stream_path)
	if stream == null:
		printerr("[AudioManager] Failed to load SFX: %s" % stream_path)
		return
	
	for child in get_children():
		if child is AudioStreamPlayer2D:
			var sfx_player: AudioStreamPlayer2D = child
			if not sfx_player.playing:
				sfx_player.stream = stream
				sfx_player.position = position
				sfx_player.volume_db = volume
				sfx_player.play()
				return
	
	# All players busy — recycle the first one
	var first_sfx := get_child(0)
	if first_sfx is AudioStreamPlayer2D:
		first_sfx.stream = stream
		first_sfx.position = position
		first_sfx.volume_db = volume
		first_sfx.play()

# ---------- Volume Control ----------

func set_music_volume(db: float) -> void:
	var bus_idx := _find_bus_index(MUSIC_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)

func set_sfx_volume(db: float) -> void:
	var bus_idx := _find_bus_index(SFX_BUS)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)

func _find_bus_index(name: String) -> int:
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == name:
			return i
	return -1

# ---------- Mute ----------

func set_music_muted(muted: bool) -> void:
	if muted:
		set_music_volume(-80.0)
	else:
		set_music_volume(-6.0)

func set_sfx_muted(muted: bool) -> void:
	if muted:
		set_sfx_volume(-80.0)
	else:
		set_sfx_volume(0.0)
