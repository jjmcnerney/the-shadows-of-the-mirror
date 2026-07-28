extends Node

func _ready() -> void:
	var scene = preload("res://scenes/dungeons/cathedral_crypts.tscn")
	var inst = scene.instantiate()
	add_child(inst)
	
	await get_tree().create_timer(0.1).timeout
	
	var tm = inst.get_node("TileMap")
	var ts = tm.tile_set
	
	var src_id = ts.get_source_id(0)
	var src = ts.get_source(src_id)
	
	# List ALL TileSetAtlasSource properties
	print("=== TileSetAtlasSource properties ===")
	var props = src.get_property_list()
	for p in props:
		var name = str(p["name"])
		if "origin" in name.to_lower() or "separation" in name.to_lower() or "margin" in name.to_lower() or "tile_size" in name.to_lower() or "texture" in name.to_lower():
			print("  %s = %s (usage=0x%x)" % [name, str(src.get(p["name"])), p["usage"]])
	
	# Check TileMapLayer
	for child in tm.get_children():
		if child is TileMapLayer:
			var layer: TileMapLayer = child
			print("\nLayer: %s" % layer.name)
			# List layer properties
			var lprops = layer.get_property_list()
			for p in lprops:
				var name = str(p["name"])
				if "render" in name.to_lower() or "layer" in name.to_lower() or "visible" in name.to_lower():
					print("  Layer.%s = %s" % [name, str(layer.get(p["name"]))])
	
	# Player
	for c in inst.get_children():
		if c.is_in_group("player"):
			print("\nPlayer pos: %s" % str(c.position))
			for cc in c.get_children():
				if cc is Camera2D:
					print("Camera zoom: %s pos: %s" % [str(cc.zoom), str(cc.position)])
	
	print("\n--- Done ---")
	get_tree().quit(0)
