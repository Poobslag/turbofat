@tool
extends EditorScript

func _run() -> void:
	var all_nodes := get_all_children(get_editor_interface().get_edited_scene_root())
	var tilemap_nodes: Array = filter(all_nodes, TileMap)
	for tilemap in tilemap_nodes:
		remove_all_alternative_tiles(tilemap.tile_set)


## There is seemingly no way to update the next_alternative_id on a TileSetSource, so perform the following regex to
## reset them to their default:
##
## ^[0-9]*:[0-9]*/next_alternative_id = [0-9]*\n
func remove_all_alternative_tiles(tileset: TileSet) -> void:
	var stats := {}
	for source_idx in tileset.get_source_count():
		stats["sources"] = stats.get("sources", 0) + 1
		var source := tileset.get_source(tileset.get_source_id(source_idx))
		for tile_idx in source.get_tiles_count():
			stats["tiles"] = stats.get("tiles", 0) + 1
			var coord := source.get_tile_id(tile_idx)
			while source.get_alternative_tiles_count(coord) > 1:
				stats["alternative_tiles"] = stats.get("alternative_tiles", 0) + 1
				var alt := source.get_alternative_tile_id(coord, 1)
				if alt != 0: # don't remove main
					stats["removed_alternative_tiles"] = stats.get("removed_alternative_tiles", 0) + 1
					source.remove_alternative_tile(coord, alt)
	print("alternative_tile_remover: %s" % [stats])


func get_all_children(in_node: Node, arr := []) -> Array:
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr


func filter(node_list: Array, type: Variant) -> Array:
	var result := []
	
	for node in node_list:
		if is_instance_of(node, type):
			result.append(node)
	
	return result
