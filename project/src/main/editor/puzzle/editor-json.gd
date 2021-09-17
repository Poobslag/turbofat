extends TextEdit
"""
A text editor window which shows the current level's json representation.

This script includes logic for populating the json model from the level editor, and vice-versa.
"""

# these fields store different parts of the parsed json
var _json_tree: Dictionary

export (NodePath) var playfield_editor_path: NodePath

onready var _playfield_editor: PlayfieldEditorControl = get_node(playfield_editor_path)

"""
Parses our text as json, storing the results in the various _json properties.

Returns 'false' if the json cannot be parsed.
"""
func can_parse_json() -> bool:
	var parsed = parse_json(text)
	_json_tree = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	return not _json_tree.empty()


"""
Refreshes the playfield editor based on our json text.
"""
func refresh_playfield_editor() -> void:
	if not can_parse_json():
		return
	
	# update the playfield editor's list of 'tiles keys'
	var new_tiles_keys: Array = _json_tree.get("tiles", {}).keys()
	_playfield_editor.tiles_keys = new_tiles_keys
	
	var tile_map := _playfield_editor.get_tile_map()
	var json_tiles_set: Array = _json_tree.get("tiles", {}).get(_playfield_editor.tiles_key, [])
	tile_map.clear()
	PuzzleTileMapReader.read(json_tiles_set, funcref(tile_map, "set_block"))


"""
Refreshes our json text based on the tiles keys.

This occurs when new tiles keys are added or removed.
"""
func _refresh_json_tiles_keys() -> void:
	if not can_parse_json():
		return
	
	var json_tiles_keys: Array = _json_tree.get("tiles", {}).keys()
	var editor_tiles_keys := _playfield_editor.tiles_keys
	
	# remove any tiles keys which the player removed
	var tiles_keys_to_remove := Utils.subtract(json_tiles_keys, editor_tiles_keys)
	for tiles_key_to_remove in tiles_keys_to_remove:
		if not _json_tree.has("tiles"):
			continue
		_json_tree.get("tiles", {}).erase(tiles_key_to_remove)
	
	# add any tiles keys which the player added
	var tiles_keys_to_add := Utils.subtract(editor_tiles_keys, json_tiles_keys)
	for tiles_key_to_add in tiles_keys_to_add:
		if tiles_key_to_add == "start":
			# 'start' tiles key is added conditionally in _refresh_json_tile_map()
			continue
		
		if not _json_tree.has("tiles"):
			_json_tree["tiles"] = {}
		_json_tree["tiles"][tiles_key_to_add] = []
	
	# remove the 'tiles' entry entirely if we don't need it
	if _json_tree.has("tiles") and _json_tree["tiles"].empty():
		_json_tree.erase("tiles")
	
	text = Utils.print_json(_json_tree)


"""
Refreshes our json text based on the tilemap.

This occurs when new blocks are added or removed from the tilemap.
"""
func _refresh_json_tile_map() -> void:
	if not can_parse_json():
		return
	
	var tile_map := _playfield_editor.get_tile_map()
	var new_json_tiles_set := []
	for used_cell in tile_map.get_used_cells():
		var autotile_coord: Vector2 = tile_map.get_cell_autotile_coord(used_cell.x, used_cell.y)
		var tile_index: int = tile_map.get_cellv(used_cell)
		var json_tile := {
			"pos": "%s %s" % [used_cell.x, used_cell.y],
			"tile": "%s %s %s" % [tile_index, autotile_coord.x, autotile_coord.y]
		}
		new_json_tiles_set.append(json_tile)
	
	if _playfield_editor.tiles_key == "start" and new_json_tiles_set.empty():
		# clear 'start' tiles
		_json_tree.get("tiles", {}).erase("start")
		if not _json_tree.get("tiles"):
			_json_tree.erase("tiles")
	else:
		# populate
		if not _json_tree.has("tiles"):
			_json_tree["tiles"] = {}
		_json_tree["tiles"][_playfield_editor.tiles_key] = new_json_tiles_set
	
	text = Utils.print_json(_json_tree)


func _on_PlayfieldEditor_tiles_keys_changed(_tiles_keys: Array, _tiles_key: String) -> void:
	# when tiles keys are added/removed, we update our json.
	_refresh_json_tiles_keys()
	# when the player selects a new tile key, we refresh the playfield blocks.
	refresh_playfield_editor()


func _on_PlayfieldEditor_tile_map_changed() -> void:
	# when the player changes the tiles, we update our json.
	_refresh_json_tile_map()


func _on_text_changed() -> void:
	refresh_playfield_editor()
