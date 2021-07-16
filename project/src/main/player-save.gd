extends Node
"""
Reads and writes data about the player's progress from a file.

This data includes how well they've done on each level and how much money they've earned.
"""

# Current version for saved player data. Should be updated if and only if the player format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const PLAYER_DATA_VERSION := "2783"

var rolling_backups := RollingBackups.new()

# Enum value for the backup was successfully loaded. 'RollingBackups.CURRENT' if the current file worked.
# Virtual property; value is only exposed through getters/setters
var loaded_backup: int setget ,get_loaded_backup

# Newly renamed save files which couldn't be loaded
# Virtual property; value is only exposed through getters/setters
var corrupt_filenames: Array setget ,get_corrupt_filenames

# Filename to use when saving/loading player data. Can be changed for tests
var current_player_data_filename := "user://turbofat0.save" setget set_current_player_data_filename

# Provides backwards compatibility with older save formats
var old_save := OldSave.new()

func _ready() -> void:
	PlayerData.reset()
	rolling_backups.current_filename = current_player_data_filename
	load_player_data()


func get_corrupt_filenames() -> Array:
	return rolling_backups.corrupt_filenames


func get_loaded_backup() -> int:
	return rolling_backups.loaded_backup


func set_current_player_data_filename(new_current_player_data_filename: String) -> void:
	current_player_data_filename = new_current_player_data_filename
	rolling_backups.current_filename = current_player_data_filename


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


"""
Writes the player's in-memory data to a save file.
"""
func save_player_data() -> void:
	var save_json := []
	save_json.append(generic_data("version", PLAYER_DATA_VERSION).to_json_dict())
	save_json.append(generic_data("player_info", {"money": PlayerData.money}).to_json_dict())
	save_json.append(generic_data("gameplay_settings", PlayerData.gameplay_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("graphics_settings", PlayerData.graphics_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("volume_settings", PlayerData.volume_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("touch_settings", PlayerData.touch_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("keybind_settings", PlayerData.keybind_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("misc_settings", \
			PlayerData.misc_settings.to_json_dict()).to_json_dict())
	for level_name in PlayerData.level_history.level_names():
		var rank_results_json := []
		for rank_result in PlayerData.level_history.results(level_name):
			rank_results_json.append(rank_result.to_json_dict())
		save_json.append(named_data("level_history", level_name, rank_results_json).to_json_dict())
	save_json.append(generic_data("chat_history", PlayerData.chat_history.to_json_dict()).to_json_dict())
	save_json.append(generic_data("creature_library", PlayerData.creature_library.to_json_dict()).to_json_dict())
	save_json.append(generic_data("successful_levels",
			PlayerData.level_history.successful_levels).to_json_dict())
	save_json.append(generic_data("finished_levels",
			PlayerData.level_history.finished_levels).to_json_dict())
	FileUtils.write_file(current_player_data_filename, Utils.print_json(save_json))
	rolling_backups.rotate_backups()


"""
Populates the player's in-memory data based on their save files.
"""
func load_player_data() -> void:
	rolling_backups.load_newest_save(self, "_load_player_data_from_file")


"""
Populates the player's in-memory data based on a save file.

Returns 'true' if the data is loaded successfully.
"""
func _load_player_data_from_file(filename: String) -> bool:
	var file := File.new()
	var open_result := file.open(filename, File.READ)
	if open_result != OK:
		# validation failed; couldn't open file
		push_warning("Couldn't open file '%s' for reading: %s" % [filename, open_result])
		return false
	
	var save_json_text := FileUtils.get_file_as_text(filename)
	
	var validate_json_result := validate_json(save_json_text)
	if validate_json_result != "":
		# validation failed; invalid json
		push_warning("Invalid json in file '%s': %s" % [filename, validate_json_result])
		return false
	
	var json_save_items: Array = parse_json(save_json_text)
	
	while old_save.is_old_save_items(json_save_items):
		# convert the old save file to a new format
		var old_version := old_save.get_version_string(json_save_items)
		json_save_items = old_save.transform_old_save_items(json_save_items)
		if old_save.get_version_string(json_save_items) == old_version:
			# failed to convert, but the data might still load
			push_warning("Couldn't convert old save data version '%s'" % old_version)
			break
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		_load_line(save_item.type, save_item.key, save_item.value)
	
	# emit a signal indicating the level history was loaded
	PlayerData.emit_signal("level_history_changed")
	
	return true


"""
Populates the player's in-memory data based on a single line from their save file.

Parameters:
	'type': A string unique to each type of data (level-data, player-data)
	'key': A string identifying a specific data item (sophie, marathon-normal)
	'json_value': The value object (array, dictionary, string) containing the data
"""
func _load_line(type: String, key: String, json_value) -> void:
	match type:
		"version":
			var value: String = json_value
			if value != PLAYER_DATA_VERSION:
				push_warning("Unrecognized save data version: '%s'" % value)
		"player_info":
			var value: Dictionary = json_value
			PlayerData.money = value.get("money", 0)
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
		"gameplay_settings":
			var value: Dictionary = json_value
			PlayerData.gameplay_settings.from_json_dict(value)
		"graphics_settings":
			var value: Dictionary = json_value
			PlayerData.graphics_settings.from_json_dict(value)
		"volume_settings":
			var value: Dictionary = json_value
			PlayerData.volume_settings.from_json_dict(value)
		"touch_settings":
			var value: Dictionary = json_value
			PlayerData.touch_settings.from_json_dict(value)
		"keybind_settings":
			var value: Dictionary = json_value
			PlayerData.keybind_settings.from_json_dict(value)
		"misc_settings":
			var value: Dictionary = json_value
			PlayerData.misc_settings.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)
