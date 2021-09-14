extends TextEdit
"""
A text editor window which shows the current level's json representation.

This script includes logic for populating the json model from the level editor, and vice-versa.
"""

# these fields store different parts of the parsed json
var _json_tree: Dictionary

export (NodePath) var playfield_path: NodePath

onready var _playfield: EditorPlayfield = get_node(playfield_path)
onready var _tile_map: TileMap = _playfield.get_tile_map()

"""
Parses our text as json, storing the results in the various _json properties.

Returns 'false' if the json cannot be parsed.
"""
func can_parse_json() -> bool:
	var parsed = parse_json(text)
	_json_tree = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	return not _json_tree.empty()


"""
Refreshes the tilemap based on our json text.
"""
func refresh_tile_map() -> void:
	if can_parse_json():
		_tile_map.clear()
		var json_tiles_start: Array = _json_tree.get("tiles", {}).get("start", [])
		PuzzleTileMapReader.read(json_tiles_start, funcref(_tile_map, "set_block"))


"""
Refreshes our json text based on the tilemap.
"""
func refresh_json() -> void:
	if can_parse_json():
		var new_json_tiles_start := []
		for used_cell in _tile_map.get_used_cells():
			var autotile_coord: Vector2 = _tile_map.get_cell_autotile_coord(used_cell.x, used_cell.y)
			var tile_index: int = _tile_map.get_cellv(used_cell)
			var json_tile := {
				"pos": "%s %s" % [used_cell.x, used_cell.y],
				"tile": "%s %s %s" % [tile_index, autotile_coord.x, autotile_coord.y]
			}
			new_json_tiles_start.append(json_tile)
		
		if new_json_tiles_start.empty():
			# clear
			_json_tree.get("tiles", {}).erase("start")
			if not _json_tree.get("tiles"):
				_json_tree.erase("tiles")
		else:
			# populate
			if not _json_tree.has("tiles"):
				_json_tree["tiles"] = {}
			_json_tree["tiles"]["start"] = new_json_tiles_start
		text = Utils.print_json(_json_tree)


func _on_Playfield_tile_map_changed() -> void:
	refresh_json()


func _on_text_changed() -> void:
	refresh_tile_map()
