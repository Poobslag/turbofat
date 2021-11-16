extends Node
## Reads and writes data about the player's progress from a file.
##
## This data includes how well they've done on each level and how much money they've earned.

## Current version for saved player data. Should be updated if and only if the player format changes.
## This version number follows a 'ymdh' hex date format which is documented in issue #234.
const PLAYER_DATA_VERSION := "27bb"

var rolling_backups := RollingBackups.new()

## Enum value for the backup was successfully loaded. 'RollingBackups.CURRENT' if the current file worked.
## Virtual property; value is only exposed through getters/setters
var loaded_backup: int setget ,get_loaded_backup

## Newly renamed save files which couldn't be loaded
## Virtual property; value is only exposed through getters/setters
var corrupt_filenames: Array setget ,get_corrupt_filenames

## Filename for saving/loading player data. Can be changed for tests
var data_filename := "user://saveslot0.json" setget set_data_filename

## Filename for loading data older than July 2021. Can be changed for tests
var legacy_filename := "user://turbofat0.save" setget set_legacy_filename

## Provides backwards compatibility with older save formats
var _upgrader := PlayerSaveUpgrader.new().new_save_item_upgrader()

func _ready() -> void:
	rolling_backups.data_filename = data_filename
	rolling_backups.legacy_filename = legacy_filename


func get_corrupt_filenames() -> Array:
	return rolling_backups.corrupt_filenames


func get_loaded_backup() -> int:
	return rolling_backups.loaded_backup


func set_data_filename(new_data_filename: String) -> void:
	data_filename = new_data_filename
	rolling_backups.data_filename = data_filename


func set_legacy_filename(new_legacy_filename: String) -> void:
	legacy_filename = new_legacy_filename
	rolling_backups.legacy_filename = legacy_filename


## Writes the player's in-memory data to a save file.
func save_player_data() -> void:
	var save_json := []
	save_json.append(_save_item("version", PLAYER_DATA_VERSION).to_json_dict())
	var player_info := {}
	player_info["money"] = PlayerData.money
	player_info["seconds_played"] = PlayerData.seconds_played
	save_json.append(_save_item("player_info", player_info).to_json_dict())
	for level_name in PlayerData.level_history.level_names():
		var rank_results_json := []
		for rank_result in PlayerData.level_history.results(level_name):
			rank_results_json.append(rank_result.to_json_dict())
		save_json.append(_save_item("level_history", rank_results_json, level_name).to_json_dict())
	save_json.append(_save_item("chat_history", PlayerData.chat_history.to_json_dict()).to_json_dict())
	save_json.append(_save_item("creature_library", PlayerData.creature_library.to_json_dict()).to_json_dict())
	save_json.append(_save_item("career", PlayerData.career.to_json_dict()).to_json_dict())
	save_json.append(_save_item("successful_levels",
			PlayerData.level_history.successful_levels).to_json_dict())
	save_json.append(_save_item("finished_levels",
			PlayerData.level_history.finished_levels).to_json_dict())
	FileUtils.write_file(data_filename, Utils.print_json(save_json))
	rolling_backups.rotate_backups()


## Populates the player's in-memory data based on their save files.
func load_player_data() -> void:
	PlayerData.reset()
	rolling_backups.load_newest_save(self, "_load_player_data_from_file")


## Returns the playtime in seconds from the specified save file.
func get_save_slot_playtime(filename: String) -> float:
	var json_save_items := _save_items_from_file(filename)
	var seconds_played := 0.0
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"player_info":
				var value: Dictionary = save_item.value
				seconds_played = value.get("seconds_played", 0.0)
	
	return seconds_played


## Returns the player's short name from the specified save file.
func get_save_slot_player_short_name(filename: String) -> String:
	var json_save_items := _save_items_from_file(filename)
	var player_short_name := ""
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"creature_library":
				var value: Dictionary = save_item.value
				var player_creature_data: Dictionary = value.get("#player#", {})
				player_short_name = player_creature_data.get("short_name", "")
	
	return player_short_name


## Creates a granular save item. The player's save data includes many of these.
##
## Note: Intuitively this method would be a static factory method on the SaveItem class, but that causes console errors
## due to Godot #30668 (https://github.com/godotengine/godot/issues/30668)
func _save_item(type: String, value, key: String = "") -> SaveItem:
	var save_item := SaveItem.new()
	save_item.type = type
	save_item.key = key
	save_item.value = value
	return save_item


## Populates the player's in-memory data based on a save file.
##
## Returns 'true' if the data is loaded successfully.
func _load_player_data_from_file(filename: String) -> bool:
	var json_save_items := _save_items_from_file(filename)
	if not json_save_items:
		return false
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		_load_line(save_item.type, save_item.key, save_item.value)
	
	# emit a signal indicating the level history was loaded
	PlayerData.emit_signal("level_history_changed")
	return true


## Loads a list of SaveItems from the specified save file.
##
## Returns:
## 	A list of SaveItem instances from the specified save file. Returns an empty array if there is an error reading the
## 	file.
func _save_items_from_file(filename: String) -> Array:
	var file := File.new()
	var open_result := file.open(filename, File.READ)
	if open_result != OK:
		# validation failed; couldn't open file
		push_warning("Couldn't open file '%s' for reading: %s" % [filename, open_result])
		return []
	
	var save_json_text := FileUtils.get_file_as_text(filename)
	var validate_json_result := validate_json(save_json_text)
	if validate_json_result != "":
		# validation failed; invalid json
		push_warning("Invalid json in file '%s': %s" % [filename, validate_json_result])
		return []
	
	var json_save_items: Array = parse_json(save_json_text)
	
	if _upgrader.needs_upgrade(json_save_items):
		json_save_items = _upgrader.upgrade(json_save_items)
	
	return json_save_items


## Populates the player's in-memory data based on a single line from their save file.
##
## Parameters:
## 	'type': A string unique to each type of data (level-data, player-data)
## 	'key': A string identifying a specific data item (sophie, marathon-normal)
## 	'json_value': The value object (array, dictionary, string) containing the data
func _load_line(type: String, key: String, json_value) -> void:
	match type:
		"version":
			var value: String = json_value
			if value != PLAYER_DATA_VERSION:
				push_warning("Unrecognized save data version: '%s'" % value)
		"player_info":
			var value: Dictionary = json_value
			PlayerData.money = value.get("money", 0)
			PlayerData.seconds_played = value.get("seconds_played", 0.0)
		"level_history":
			var value: Array = json_value
			# load the values from oldest to newest; that way the newest one is at the front
			value.invert()
			for rank_result_json in value:
				var rank_result := RankResult.new()
				rank_result.from_json_dict(rank_result_json)
				PlayerData.level_history.add(key, rank_result)
			PlayerData.level_history.prune(key)
		"chat_history":
			var value: Dictionary = json_value
			PlayerData.chat_history.from_json_dict(value)
		"creature_library":
			var value: Dictionary = json_value
			PlayerData.creature_library.from_json_dict(value)
		"finished_levels":
			var value: Dictionary = json_value
			PlayerData.level_history.finished_levels = value
		"successful_levels":
			var value: Dictionary = json_value
			PlayerData.level_history.successful_levels = value
		"career":
			var value: Dictionary = json_value
			PlayerData.career.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)
