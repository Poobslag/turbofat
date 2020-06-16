extends Node
"""
Reads and writes data about the player's progress from a file.

This data includes how well they've done on each level and how much money they've earned.
"""

# Current version for saved player data. Should be updated if and only if the player format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const PLAYER_DATA_VERSION := "1682"

# Filename to use when saving/loading player data. Can be changed for tests
var player_data_filename := "user://turbofat0.save"

# Provides backwards compatibility with older save formats
var old_save := OldSave.new()

"""
Creates a 'generic' save item, something the player has only one of.

This could be an attribute like their name, money, or how many levels they've beaten.

Note: Intuitively this method would be a static factory method on the SaveItem class, but that causes console errors
due to Godot #30668 (https://github.com/godotengine/godot/issues/30668)
"""
func generic_data(type: String, value) -> SaveItem:
	var save_item := SaveItem.new()
	save_item.type = type
	save_item.value = value
	return save_item


"""
Creates a 'named' save item, something the player has many of.

This could be attributes like items they're carrying, or their high score for each level.

Note: Intuitively this method would be a static factory method on the SaveItem class, but that causes console errors
due to Godot #30668 (https://github.com/godotengine/godot/issues/30668)
"""
func named_data(type: String, key: String, value) -> SaveItem:
	var save_item := SaveItem.new()
	save_item.type = type
	save_item.key = key
	save_item.value = value
	return save_item


func _ready() -> void:
	PlayerData.reset()
	load_player_data()


"""
Writes the player's in-memory data to a save file.
"""
func save_player_data() -> void:
	var save_json: Array = []
	save_json.append(generic_data("version", PLAYER_DATA_VERSION).to_json_dict())
	save_json.append(generic_data("player-info", {"money": PlayerData.money}).to_json_dict())
	save_json.append(generic_data("volume-settings", PlayerData.volume_settings.to_json_dict()).to_json_dict())
	for scenario_name in PlayerData.scenario_history.scenario_names():
		var rank_results_json := []
		for rank_result in PlayerData.scenario_history.results(scenario_name):
			rank_results_json.append(rank_result.to_json_dict())
		save_json.append(named_data("scenario-history", scenario_name, rank_results_json).to_json_dict())
	FileUtils.write_file(player_data_filename, to_json(save_json))


"""
Populates the player's in-memory data based on their save file.
"""
func load_player_data() -> void:
	# if the save doesn't exist, but the old save exists...
	if old_save.only_has_old_save():
		old_save.transform_old_save()
	
	if FileUtils.file_exists(player_data_filename):
		var save_json_text := FileUtils.get_file_as_text(player_data_filename)
		var json_save_items: Array = parse_json(save_json_text)
		
		while old_save.is_old_save_items(json_save_items):
			var old_version := old_save.get_version_string(json_save_items)
			json_save_items = old_save.transform_old_save_items(json_save_items)
			if old_save.get_version_string(json_save_items) == old_version:
				push_warning("Couldn't convert old save data version '%s'" % old_version)
				break
		
		for json_save_item_obj in json_save_items:
			var save_item: SaveItem = SaveItem.new()
			save_item.from_json_dict(json_save_item_obj)
			_load_line(save_item.type, save_item.key, save_item.value)


"""
Populates the player's in-memory data based on a single line from their save file.

Parameters:
	'type': A string unique to each type of data (scenario-data, player-data)
	'key': A string identifying a specific data item (sophie, marathon-normal)
	'json_value': The value object (array, dictionary, string) containing the data
"""
func _load_line(type: String, key: String, json_value) -> void:
	match type:
		"version":
			var value: String = json_value
			if value != PLAYER_DATA_VERSION:
				push_warning("Unrecognized save data version: '%s'" % value)
		"player-info":
			var value: Dictionary = json_value
			PlayerData.money = value.get("money", 0)
		"scenario-history":
			var value: Array = json_value
			for rank_result_json in value:
				var rank_result := RankResult.new()
				rank_result.from_json_dict(rank_result_json)
				PlayerData.scenario_history.add(key, rank_result)
			PlayerData.scenario_history.prune(key)
		"volume-settings":
			var value: Dictionary = json_value
			PlayerData.volume_settings.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)
