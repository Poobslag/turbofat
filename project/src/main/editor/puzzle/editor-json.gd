extends TextEdit
"""
A text editor window which shows the current level's json representation.

This script includes logic for populating the json model from the level editor, and vice-versa.
"""

# these fields store different parts of the parsed json
var _json_tree: Dictionary

export (NodePath) var playfield_editor_path: NodePath
export (NodePath) var properties_editor_path: NodePath

var _tile_map: PuzzleTileMap
var _pickups: EditorPickups

# cached values used for calculating pickup properties
var _score_rules := ScoreRules.new()
var _calculated_pickup_score := 0

onready var _playfield_editor: PlayfieldEditorControl = get_node(playfield_editor_path)
onready var _properties_editor: PropertiesEditorControl = get_node(properties_editor_path)

func _ready() -> void:
	_tile_map = _playfield_editor.get_tile_map()
	_pickups = _playfield_editor.get_pickups()


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
	
	var json_tiles_set: Array = _json_tree.get("tiles", {}).get(_playfield_editor.tiles_key, [])
	_tile_map.clear()
	_pickups.clear()
	PuzzleTileMapReader.read(json_tiles_set, funcref(_tile_map, "set_block"), funcref(_pickups, "set_pickup"))


"""
Refreshes the properties editor based on our json text.
"""
func refresh_properties_editor() -> void:
	if not can_parse_json():
		return
	
	if _json_tree.has("rank"):
		var rank_rules := RankRules.new()
		rank_rules.from_json_string_array(_json_tree["rank"])
		_properties_editor.set_master_pickup_score(rank_rules.master_pickup_score)


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
	
	_refresh_text_from_json_tree()


"""
Refreshes our json text based on the tilemap.

This occurs when new blocks are added or removed from the tilemap.
"""
func _refresh_json_tile_map() -> void:
	if not can_parse_json():
		return
	
	# calculate the json representation of the current playfield tiles set
	var new_json_tiles_set := []
	var used_cells := _playfield_editor_used_cells()
	for used_cell in used_cells:
		var json_tile := {
			"pos": "%s %s" % [used_cell.x, used_cell.y]
		}
		if _tile_map.get_cellv(used_cell) != -1:
			var autotile_coord: Vector2 = _tile_map.get_cell_autotile_coord(used_cell.x, used_cell.y)
			var tile_index: int = _tile_map.get_cellv(used_cell)
			json_tile["tile"] = "%s %s %s" % [tile_index, autotile_coord.x, autotile_coord.y]
		if _pickups.get_food_type(used_cell) != -1:
			json_tile["pickup"] = "%s" % [_pickups.get_food_type(used_cell)]
		new_json_tiles_set.append(json_tile)
	
	# store the new json tiles set in the json tree
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
	
	_refresh_text_from_json_tree()


func _refresh_text_from_json_tree() -> void:
	text = Utils.print_json(_json_tree)


"""
Refreshes our json tree based on the data from the properties editor.
"""
func _refresh_json_tree_from_properties() -> void:
	if not can_parse_json():
		return
	
	var new_master_pickup_score: float = _properties_editor.get_master_pickup_score()
	
	if new_master_pickup_score != 0.0:
		# add a 'rank' node if necessary, and populate it with the new master pickup score
		if not _json_tree.has("rank"):
			_json_tree["rank"] = []
		
		var master_pickup_score_index: int = _json_tree["rank"].size()
		for i in range(_json_tree["rank"].size()):
			var string: String = _json_tree["rank"][i]
			if string.begins_with("master_pickup_score "):
				master_pickup_score_index = i
				_json_tree["rank"].remove(i)
				break
		
		_json_tree["rank"].insert(master_pickup_score_index, "master_pickup_score %d" % [new_master_pickup_score])
	else:
		# remove the master pickup score, and remove the 'rank' node if no longer necessary
		if _json_tree.has("rank"):
			for i in range(_json_tree["rank"].size()):
				var string: String = _json_tree["rank"][i]
				if string.begins_with("master_pickup_score "):
					_json_tree["rank"].remove(i)
					break
			
			if _json_tree["rank"].empty():
				_json_tree.erase("rank")
	
	_refresh_text_from_json_tree()


"""
Recalculates the master pickup score and updates the properties editor.
"""
func _update_properties_master_pickup_score_with_calculated_value() -> void:
	# reset previously parsed json data
	_calculated_pickup_score = 0
	
	if _json_tree.has("score"):
		_score_rules = ScoreRules.new()
		_score_rules.from_json_string_array(_json_tree["score"])
	
	# parse json data
	var json_tiles_set: Array = _json_tree.get("tiles", {}).get("start", [])
	PuzzleTileMapReader.read(json_tiles_set, null, funcref(self, "_increment_calculated_pickup_score"))
	
	# update UI
	_properties_editor.set_master_pickup_score(_calculated_pickup_score)


"""
Returns a sorted list of used cells in the playfield editor.

This includes cells containing blocks and pickups. The result is sorted first by Y ascending, then by X ascending.
"""
func _playfield_editor_used_cells() -> Array:
	var used_cells := {
	}
	for used_cell in _tile_map.get_used_cells():
		used_cells[used_cell] = true
	for used_cell in _pickups.get_used_cells():
		used_cells[used_cell] = true
	var sorted_used_cells := used_cells.keys()
	sorted_used_cells.sort_custom(self, "_compare_by_y")
	return sorted_used_cells


func _compare_by_y(a: Vector2, b: Vector2) -> bool:
	if b.y > a.y:
		return true
	if b.y < a.y:
		return false
	return b.x > a.x


"""
Callback function which increments the pickup score for each playfield pickup.
"""
func _increment_calculated_pickup_score(_pos: Vector2, box_type: int) -> void:
	if Foods.is_snack_box(box_type):
		_calculated_pickup_score += _score_rules.snack_pickup_points
	else:
		_calculated_pickup_score += _score_rules.cake_pickup_points


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
	refresh_properties_editor()


func _on_PlayfieldEditor_pickups_changed() -> void:
	# when the player changes the pickups, we update our json.
	_refresh_json_tile_map()


func _on_PropertiesEditor_properties_changed() -> void:
	_refresh_json_tree_from_properties()


func _on_PropertiesPickupsButton_pressed() -> void:
	_update_properties_master_pickup_score_with_calculated_value()
	_refresh_json_tree_from_properties()
