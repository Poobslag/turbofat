extends Node
## Reads and writes data about the player's progress from a file.
##
## This data includes how well they've done on each level and how much money they've earned.

signal save_scheduled

signal before_save

signal before_load

signal after_save

signal after_load

## Current version for saved player data. Should be updated if and only if the player format changes.
## This version number follows a 'ymdh' hex date format which is documented in issue #234.
const PLAYER_DATA_VERSION := "5b9b"

var rolling_backups := RollingBackups.new()

## Enum from RollingBackups for the backup which was successfully loaded, 'RollingBackups.CURRENT' if the current
## file worked.
##
## Virtual property; value is only exposed through getters/setters
var loaded_backup: int setget ,get_loaded_backup

## Newly renamed save files which couldn't be loaded
## Virtual property; value is only exposed through getters/setters
var corrupt_filenames: Array setget ,get_corrupt_filenames

## Filename for saving/loading player data. Can be changed for tests
var data_filename := "user://saveslot0.json" setget set_data_filename

## Filename for loading data older than July 2021. Can be changed for tests
var legacy_filename := "user://turbofat0.save" setget set_legacy_filename

## 'true' if the previous '_save_items_from_file' call upgraded the loaded data.
var load_performed_upgrade := false

## 'true' if rank data should be populated, and invalid levels purged from the player's save. Can be changed for tests
var populate_rank_data := true

## 'true' if player data will be saved during the next scene transition
var save_scheduled := false

## Provides backwards compatibility with older save formats
var _upgrader := PlayerSaveUpgrader.new().new_save_item_upgrader()

## The currently active thread which is saving the player's data.
##
## This thread is assigned when saving begins, and reset to null when saving completes.
var _save_thread: Thread = null

func _ready() -> void:
	rolling_backups.data_filename = data_filename
	rolling_backups.legacy_filename = legacy_filename
	
	Breadcrumb.connect("before_scene_changed", self, "_on_Breadcrumb_before_scene_changed")


func _exit_tree() -> void:
	if _save_thread:
		_save_thread.wait_to_finish()


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


## Schedules player data to be saved later.
##
## Serializing the player's in-memory data into a large JSON file takes about 50 milliseconds or longer. To prevent
## stuttering or frame drops, we do this during scene transitions.
func schedule_save() -> void:
	save_scheduled = true
	emit_signal("save_scheduled")


## Writes the player's in-memory data to a save file.
##
## Parameters:
## 	'threaded': If 'true', saving occurs on a secondary thread (if supported). This reduces lag but isn't suitable
## 		for atomic save operations.
func save_player_data(threaded: bool = false) -> void:
	if _save_thread:
		# A save thread is already active; don't start another until it's finished.
		return
	
	# Godot issue #12699; Threads not supported for HTML5
	var use_threaded := threaded and not OS.has_feature("web")
	
	if use_threaded:
		emit_signal("before_save")
		_save_thread = Thread.new()
		_save_thread.start(self, "_threaded_write_file")
		# The after_save signal is emitted from within the thread.
	else:
		emit_signal("before_save")
		_save_player_data_internal()
		emit_signal("after_save")


## Populates the player's in-memory data based on their save files.
func load_player_data() -> void:
	load_performed_upgrade = false
	emit_signal("before_load")
	PlayerData.reset()
	rolling_backups.load_newest_save(self, "load_player_data_from_file")
	emit_signal("after_load")


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


## Populates the player's in-memory data based on a save file.
##
## Returns 'true' if the data is loaded successfully.
func load_player_data_from_file(filename: String) -> bool:
	load_performed_upgrade = false
	var json_save_items := _save_items_from_file(filename)
	if json_save_items.empty():
		return false
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		_load_line(save_item.type, save_item.key, save_item.value)

	if populate_rank_data:
		_purge_invalid_levels_from_level_history()
		_calculate_rank_for_level_history()
	
	if load_performed_upgrade:
		# after loading old data, immediately save it so that the old data doesn't persist
		schedule_save()

	# emit a signal indicating the level history was loaded
	PlayerData.emit_signal("level_history_changed")
	return true


func _purge_invalid_levels_from_level_history() -> void:
	for level_id in PlayerData.level_history.level_names():
		if not FileUtils.file_exists(LevelSettings.path_from_level_key(level_id)):
			push_warning("Invalid level: %s" % [level_id])
			PlayerData.level_history.delete_results(level_id)


func _calculate_rank_for_level_history() -> void:
	var rank_calculator := RankCalculator.new()
	for level_id in PlayerData.level_history.level_names():
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		CurrentLevel.start_level(level_settings, true)
		for level_history_item in PlayerData.level_history.rank_results[level_id]:
			rank_calculator.calculate_rank(level_history_item)
	CurrentLevel.reset()


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
		load_performed_upgrade = true
	
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
				PlayerData.level_history.add_result(key, rank_result)
			PlayerData.level_history.prune(key)
		"chat_history":
			var value: Dictionary = json_value
			PlayerData.chat_history.from_json_dict(value)
		"creature_library":
			var value: Dictionary = json_value
			PlayerData.creature_library.from_json_dict(value)
		"difficulty":
			var value: Dictionary = json_value
			PlayerData.difficulty.from_json_dict(value)
		"finished_levels":
			var value: Dictionary = json_value
			PlayerData.level_history.finished_levels = value
		"successful_levels":
			var value: Dictionary = json_value
			PlayerData.level_history.successful_levels = value
		"career":
			var value: Dictionary = json_value
			PlayerData.career.from_json_dict(value)
		"menu_region":
			var value: String = json_value
			if CareerLevelLibrary.region_for_id(value):
				PlayerData.menu_region = CareerLevelLibrary.region_for_id(value)
		"practice":
			var value: Dictionary = json_value
			PlayerData.practice.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)


## Saves the player data.
##
## This code is meant to be invoked from within a secondary thread.
func _threaded_write_file() -> void:
	_save_player_data_internal()
	call_deferred("_after_threaded_write_file")


## Performs cleanup steps after a threaded save operation.
##
## This code is meant to be invoked on the main thread, after a threaded save operation completes on a secondary
## thread.
func _after_threaded_write_file() -> void:
	call_deferred("emit_signal", "after_save")
	_save_thread.wait_to_finish()
	_save_thread = null


## Saves the player data.
##
## This code is sometimes launched on the main thread or sometimes in a secondary thread, so it should not emit
## signals or interact with the scene tree.
func _save_player_data_internal() -> void:
	var save_json := []
	save_json.append(SaveItem.new("version", PLAYER_DATA_VERSION).to_json_dict())
	var player_info := {}
	player_info["money"] = PlayerData.money
	player_info["seconds_played"] = PlayerData.seconds_played
	save_json.append(SaveItem.new("player_info", player_info).to_json_dict())
	for level_name in PlayerData.level_history.level_names():
		var rank_results_json := []
		for rank_result in PlayerData.level_history.results(level_name):
			rank_results_json.append(rank_result.to_json_dict())
		save_json.append(SaveItem.new("level_history", rank_results_json, level_name).to_json_dict())
	save_json.append(SaveItem.new("chat_history", PlayerData.chat_history.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("creature_library", PlayerData.creature_library.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("career", PlayerData.career.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("difficulty", PlayerData.difficulty.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("menu_region", PlayerData.menu_region.id).to_json_dict())
	save_json.append(SaveItem.new("practice", PlayerData.practice.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("successful_levels",
			PlayerData.level_history.successful_levels).to_json_dict())
	save_json.append(SaveItem.new("finished_levels",
			PlayerData.level_history.finished_levels).to_json_dict())
	FileUtils.write_file(data_filename, Utils.print_json(save_json))
	rolling_backups.rotate_backups()


func _on_Breadcrumb_before_scene_changed() -> void:
	if save_scheduled:
		Global.print_verbose("Scene changing; saving player data")
		save_player_data()
		Global.print_verbose("Finished saving player data")
		save_scheduled = false
