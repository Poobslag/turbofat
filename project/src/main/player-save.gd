extends Node
"""
Reads and writes data about the player's progress from a file.

This data includes how well they've done on each level and how much money they've earned.
"""

# Categories of rolling backups for the player's save data.
enum RollingSave {
	CURRENT, # the newest save
	THIS_HOUR, # a save which will eventually become the hourly backup
	PREV_HOUR, # a backup which is 1-2 hours old
	THIS_DAY, # a save which will eventually become the daily backup
	PREV_DAY, # a backup which is 1-2 days old
	THIS_WEEK, # a save which will eventually become the weekly backup
	PREV_WEEK, # a backup which is 1-2 weeks old
}

const CURRENT := RollingSave.CURRENT
const THIS_HOUR := RollingSave.THIS_HOUR
const PREV_HOUR := RollingSave.PREV_HOUR
const THIS_DAY := RollingSave.THIS_DAY
const PREV_DAY := RollingSave.PREV_DAY
const THIS_WEEK := RollingSave.THIS_WEEK
const PREV_WEEK := RollingSave.PREV_WEEK

# Current version for saved player data. Should be updated if and only if the player format changes.
# This version number follows a 'ymdh' hex date format which is documented in issue #234.
const PLAYER_DATA_VERSION := "1682"

const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE
const SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR

# The rolling save which was successfully loaded
var loaded_rolling_save := -1

# Newly renamed save files which couldn't be loaded
var corrupt_filenames: Array

# Filename to use when saving/loading player data. Can be changed for tests
var current_player_data_filename := "user://turbofat0.save"

# Provides backwards compatibility with older save formats
var old_save := OldSave.new()

func _ready() -> void:
	PlayerData.reset()
	load_player_data()


"""
Returns a filename with a '.corrupt' suffix to flag saves which couldn't be loaded.
"""
func corrupt_filename(in_filename: String) -> String:
	return StringUtils.substring_before_last(in_filename, ".save") + ".save.corrupt"


"""
Returns filename with a '.save' or '.bak' suffix to differentiate backup saves.

Parameters:
	'rolling_save': A constant from the RollingSave enum for to the filename to return.
"""
func rolling_filename(rolling_save: int) -> String:
	var suffix := StringUtils.substring_after_last(current_player_data_filename, ".")
	var middle := "."
	var prefix := StringUtils.substring_before_last(current_player_data_filename, ".")
	match(rolling_save):
		RollingSave.THIS_HOUR: middle += "this-hour."
		RollingSave.PREV_HOUR: middle += "prev-hour."
		RollingSave.THIS_DAY: middle += "this-day."
		RollingSave.PREV_DAY: middle += "prev-day."
		RollingSave.THIS_WEEK: middle += "this-week."
		RollingSave.PREV_WEEK: middle += "prev-week."
	if rolling_save != RollingSave.CURRENT:
		suffix += ".bak"
	return prefix + middle + suffix


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
	var save_json: Array = []
	save_json.append(generic_data("version", PLAYER_DATA_VERSION).to_json_dict())
	save_json.append(generic_data("player-info", {"money": PlayerData.money}).to_json_dict())
	save_json.append(generic_data("volume-settings", PlayerData.volume_settings.to_json_dict()).to_json_dict())
	save_json.append(generic_data("touch-settings", PlayerData.touch_settings.to_json_dict()).to_json_dict())
	for scenario_name in PlayerData.scenario_history.scenario_names():
		var rank_results_json := []
		for rank_result in PlayerData.scenario_history.results(scenario_name):
			rank_results_json.append(rank_result.to_json_dict())
		save_json.append(named_data("scenario-history", scenario_name, rank_results_json).to_json_dict())
	save_json.append(generic_data("successful-scenarios",
			PlayerData.scenario_history.successful_scenarios).to_json_dict())
	save_json.append(generic_data("finished-scenarios",
			PlayerData.scenario_history.finished_scenarios).to_json_dict())
	FileUtils.write_file(current_player_data_filename, Utils.print_json(save_json))
	rotate_backups()


"""
Deletes any old backup saves, replacing it with newer data.
"""
func rotate_backups() -> void:
	_rotate_backup(THIS_HOUR, PREV_HOUR, SECONDS_PER_HOUR)
	_rotate_backup(THIS_DAY, PREV_DAY, SECONDS_PER_DAY)
	_rotate_backup(THIS_WEEK, PREV_WEEK, 7 * SECONDS_PER_DAY)


"""
Deletes an old backup save, replacing it with newer data.

If the newer 'this-xxx' backup file is older than the specified rotation time, it replaces the older 'prev-xxx' backup
file.

Afterwards, if the 'this-xxx' backup file does not exist or was just rotated, it's replaced with the newest save file.
"""
func _rotate_backup(this_save: int, prev_save: int, rotate_millis: int) -> void:
	if not FileUtils.file_exists(current_player_data_filename):
		return
	
	var dir := Directory.new()
	var this_filename := rolling_filename(this_save)
	var prev_filename := rolling_filename(prev_save)
	
	var file_age := 0
	if dir.file_exists(this_filename):
		file_age = OS.get_unix_time() - File.new().get_modified_time(this_filename)
	if file_age >= rotate_millis:
		# replace the 'prev-xxx' backup with the 'this-xxx' backup
		var copy_result := dir.copy(this_filename, prev_filename)
		if copy_result == OK:
			dir.remove(this_filename)
	
	if not dir.file_exists(this_filename):
		# populate the 'this-xxx' backup from the current save
		dir.copy(current_player_data_filename, this_filename)

"""
Populates the player's in-memory data based on their save files.

If the newest save file can't be loaded, this tries older and older backups one is successful.
"""
func load_player_data() -> void:
	loaded_rolling_save = -1
	corrupt_filenames = []
	var bad_filenames := [] # save filenames which couldn't be loaded
	
	# if the save doesn't exist, but the old save exists...
	if old_save.only_has_old_save():
		old_save.transform_old_save()
	
	var load_successful := false
	for rolling_save in [CURRENT, THIS_HOUR, PREV_HOUR, THIS_DAY, PREV_DAY, THIS_WEEK, PREV_WEEK]:
		var rolling_filename := rolling_filename(rolling_save)
		if not FileUtils.file_exists(rolling_filename):
			# file not found; try next file
			continue
		
		var success := _load_rolling_save(rolling_filename)
		if not success:
			# couldn't load; try next file
			bad_filenames.append(rolling_filename)
			continue
		
		# loaded successfully; don't load any more files
		loaded_rolling_save = rolling_save
		load_successful = true
		break
	
	if bad_filenames:
		var dir := Directory.new()
		# loaded successfully, but there were some save files that couldn't be loaded
		for bad_filename in bad_filenames:
			# copy each bad file name to a filename like 'foo.save.corrupt'
			var corrupt_filename := corrupt_filename(bad_filename)
			dir.copy(bad_filename, corrupt_filename)
			dir.remove(bad_filename)
			corrupt_filenames.append(corrupt_filename)
		
		if load_successful:
			# copy the good filename back to 'foo.save'
			dir.copy(rolling_filename(loaded_rolling_save), current_player_data_filename)


"""
Populates the player's in-memory data based on a save file.

Returns 'true' if the data is loaded successfully.
"""
func _load_rolling_save(rolling_filename: String) -> bool:
	var file := File.new()
	var open_result := file.open(rolling_filename, File.READ)
	if open_result != OK:
		# validation failed; couldn't open file
		push_warning("Couldn't open file '%s' for reading: %s" % [rolling_filename, open_result])
		return false
	
	var save_json_text := FileUtils.get_file_as_text(rolling_filename)
	
	var validate_json_result := validate_json(save_json_text)
	if validate_json_result != "":
		# validation failed; invalid json
		push_warning("Invalid json in file '%s': %s" % [rolling_filename, validate_json_result])
		return false
	
	var json_save_items: Array = parse_json(save_json_text)
	
	while old_save.is_old_save_items(json_save_items):
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
	
	return true


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
		"finished-scenarios":
			var value: Dictionary = json_value
			PlayerData.scenario_history.finished_scenarios = value
		"successful-scenarios":
			var value: Dictionary = json_value
			PlayerData.scenario_history.successful_scenarios = value
		"volume-settings":
			var value: Dictionary = json_value
			PlayerData.volume_settings.from_json_dict(value)
		"touch-settings":
			var value: Dictionary = json_value
			PlayerData.touch_settings.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)
