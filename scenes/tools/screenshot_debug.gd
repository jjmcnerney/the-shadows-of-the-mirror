extends Node

func _ready() -> void:
	var src := TileSetAtlasSource.new()
	src.texture = load("res://assets/art/dungeons/crypt_tileset.png")
	src.texture_region_size = Vector2i(16, 16)
	src.use_texture_padding = false
	
	# Check what tiles auto-exist
	var count = src.get_tiles_count()
	print("Auto-created tiles: %d" % count)
	
	for i in range(count):
		var tid = src.get_tile_id(i)
		print("  Tile ID %d" % tid)
	
	# Check has_tile at various coords
	for r in range(2):
		for c in range(4):
			var has = src.has_tile(Vector2i(c, r))
			print("has_tile(%d,%d) = %s" % [c, r, str(has)])
	
	# Check get_tile_at_coords
	for r in range(2):
		for c in range(4):
			var tile = src.get_tile_at_coords(Vector2i(c, r))
			print("get_tile_at_coords(%d,%d) = %s" % [c, r, str(tile)])
	
	# Check get_tile_id
	for r in range(2):
		for c in range(4):
			var id = src.get_tile_id(r * 4 + c)
			print("get_tile_id(%d) = %d" % [r * 4 + c, id])
	
	# Check TileMapLayer set_cell signature
	var layer = TileMapLayer.new()
	var lmethods = layer.get_method_list()
	for m in lmethods:
		var name = str(m["name"])
		if "set_cell" in name:
			print("\nset_cell method: %s" % name)
			for arg in m["args"]:
				print("  arg: %s type=%d" % [str(arg["name"]), arg["type"]])
	
	# Check TileSetAtlasSource.get_tile_id signature
	var src_methods = src.get_method_list()
	for m in src_methods:
		var name = str(m["name"])
		if "tile_id" in name.to_lower() or "atlas" in name.to_lower():
			print("\nMethod: %s" % name)
			for arg in m["args"]:
				print("  arg: %s type=%d" % [str(arg["name"]), arg["type"]])
	
	get_tree().quit(0)
