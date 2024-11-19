extends Node
## Reads and writes data about the system from a file.
##
## This data includes configuration data like language, keybindings, and which save slot is active.

signal before_save
signal after_save
signal save_slot_deleted

const SYSTEM_DATA_VERSION := "5a24"

## Save files older than July 2021 which should be deleted during an upgrade
const OLD_SAVES_TO_DELETE := [
	"user://turbofat0.this-hour.save.bak",
	"user://turbofat0.this-day.save.bak",
	"user://turbofat0.this-week.save.bak",
	"user://turbofat0.prev-hour.save.bak",
	"user://turbofat0.prev-day.save.bak",
	"user://turbofat0.prev-week.save.bak",
]

## Player data filenames organized by save slot
const FILENAMES_BY_SAVE_SLOT: Dictionary = {
	MiscSettings.SaveSlot.SLOT_A: "user://saveslot0.save",
	MiscSettings.SaveSlot.SLOT_B: "user://saveslot1.save",
	MiscSettings.SaveSlot.SLOT_C: "user://saveslot2.save",
	MiscSettings.SaveSlot.SLOT_D: "user://saveslot3.save",
}

## Filename for saving/loading system data. Can be changed for tests
var data_filename := "user://config.json"

## 'true' if the data filename has been overridden for tests. Prevents our save slot logic from resetting the filename
## back to its default.
var ignore_save_slot_filename := false

## Filename for loading data older than July 2021. Can be changed for tests
var legacy_filename := "user://turbofat0.save"

## 'true' if the previous 'load_system_data' upgraded the loaded data.
var _load_performed_upgrade := false

## Provides backwards compatibility with older save formats
var _upgrader := SystemSaveUpgrader.new().new_save_item_upgrader()

func _ready() -> void:
	load_system_data()
	_refresh_save_slot()
	SystemData.misc_settings.connect("save_slot_changed", self, "_on_MiscSettings_save_slot_changed")
	PlayerSave.load_player_data()


## Writes the system's in-memory data to a save file.
func save_system_data() -> void:
	emit_signal("before_save")
	var save_json := []
	save_json.append(SaveItem.new("version", SYSTEM_DATA_VERSION).to_json_dict())
	save_json.append(SaveItem.new("gameplay_settings", SystemData.gameplay_settings.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("graphics_settings", SystemData.graphics_settings.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("volume_settings", SystemData.volume_settings.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("touch_settings", SystemData.touch_settings.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("keybind_settings", SystemData.keybind_settings.to_json_dict()).to_json_dict())
	save_json.append(SaveItem.new("misc_settings", SystemData.misc_settings.to_json_dict()).to_json_dict())
	FileUtils.write_file(data_filename, Utils.print_json(save_json))
	
	if FileUtils.file_exists(legacy_filename):
		# Data older than July 2021 used a different filename.
		# We load it once and then move it aside when saving.
		var dir := Directory.new()
		dir.open("user://")
		var rename_from := legacy_filename.trim_prefix("user://")
		var rename_to := rename_from + ".bak"
		dir.rename(rename_from, rename_to)
		
		# Legacy data includes player data and configuration data.
		# Save the player data as well to ensure both halves are written to disk.
		PlayerSave.save_player_data()
		
		# Preserve turbofat0.save.bak, but delete the hourly/daily/weekly backups
		for save_slot_filename in OLD_SAVES_TO_DELETE:
			Directory.new().remove(save_slot_filename)
	
	SystemData.has_unsaved_changes = false
	emit_signal("after_save")


## Populates the system's in-memory data based on a save file.
##
## Returns 'true' if the data is loaded successfully.
func load_system_data() -> bool:
	SystemData.reset()
	_load_performed_upgrade = false
	
	var filename_to_load := data_filename
	if not FileUtils.file_exists(data_filename) and FileUtils.file_exists(legacy_filename):
		# If the player only has older July 2021 save data, we load that instead
		filename_to_load = legacy_filename
	
	if not FileUtils.file_exists(filename_to_load):
		# file does not exist
		return false
	
	var file := File.new()
	var open_result := file.open(filename_to_load, File.READ)
	if open_result != OK:
		# validation failed; couldn't open file
		push_warning("Couldn't open file '%s' for reading: %s" % [filename_to_load, open_result])
		return false
	
	var save_json_text := FileUtils.get_file_as_text(filename_to_load)
	
	var validate_json_result := validate_json(save_json_text)
	if validate_json_result != "":
		# validation failed; invalid json
		push_warning("Invalid json in file '%s': %s" % [filename_to_load, validate_json_result])
		return false
	
	var json_save_items: Array = parse_json(save_json_text)
	
	if _upgrader.needs_upgrade(json_save_items):
		json_save_items = _upgrader.upgrade(json_save_items)
		_load_performed_upgrade = true
	
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		_load_line(save_item.type, save_item.key, save_item.value)
	
	if _load_performed_upgrade:
		# after loading old data, immediately save it so that the old data doesn't persist
		save_system_data()
	
	# emit a signal indicating the level history was loaded
	PlayerData.emit_signal("level_history_changed")
	
	return true


## Returns the playtime in seconds for the specified save slot.
func get_save_slot_playtime(save_slot: int) -> float:
	var save_slot_filename: String = FILENAMES_BY_SAVE_SLOT[save_slot]
	return PlayerSave.get_save_slot_playtime(save_slot_filename)


## Returns the player's short name for the specified save slot.
func get_save_slot_player_short_name(save_slot: int) -> String:
	var save_slot_filename: String = FILENAMES_BY_SAVE_SLOT[save_slot]
	return PlayerSave.get_save_slot_player_short_name(save_slot_filename)


## Returns a human-readable name for the specified save slot.
func get_save_slot_name(save_slot: int) -> String:
	var prefix: String = MiscSettings.SAVE_SLOT_PREFIXES[save_slot]
	var save_slot_filename: String = FILENAMES_BY_SAVE_SLOT[save_slot]
	var save_slot_name: String
	if FileUtils.file_exists(save_slot_filename):
		var player_short_name := get_save_slot_player_short_name(save_slot)
		save_slot_name = "%s: %s" % [prefix, player_short_name]
	else:
		save_slot_name = "%s: (empty)" % [prefix]
	return save_slot_name


## Deletes the specified save slot and all of its backups.
func delete_save_slot(save_slot: int) -> void:
	var save_slot_filename: String = FILENAMES_BY_SAVE_SLOT[save_slot]
	var rolling_backups := RollingBackups.new()
	rolling_backups.data_filename = save_slot_filename
	rolling_backups.delete_all_backups()
	emit_signal("save_slot_deleted")


## Populates the player's in-memory data based on a single line from their save file.
##
## Parameters:
## 	'type': A string unique to each type of data (level-data, player-data)
## 	'_key': A string identifying a specific data item (sophie, marathon-normal)
## 	'json_value': The value object (array, dictionary, string) containing the data
func _load_line(type: String, _key: String, json_value) -> void:
	match type:
		"version":
			var value: String = json_value
			if value != SYSTEM_DATA_VERSION:
				push_warning("Unrecognized save data version: '%s'" % value)
		"gameplay_settings":
			var value: Dictionary = json_value
			SystemData.gameplay_settings.from_json_dict(value)
		"graphics_settings":
			var value: Dictionary = json_value
			SystemData.graphics_settings.from_json_dict(value)
		"volume_settings":
			var value: Dictionary = json_value
			SystemData.volume_settings.from_json_dict(value)
		"touch_settings":
			var value: Dictionary = json_value
			SystemData.touch_settings.from_json_dict(value)
		"keybind_settings":
			var value: Dictionary = json_value
			SystemData.keybind_settings.from_json_dict(value)
		"misc_settings":
			var value: Dictionary = json_value
			SystemData.misc_settings.from_json_dict(value)
		_:
			push_warning("Unrecognized save data type: '%s'" % type)


func _refresh_save_slot() -> void:
	if not FILENAMES_BY_SAVE_SLOT.has(SystemData.misc_settings.save_slot):
		SystemData.misc_settings.save_slot = MiscSettings.SaveSlot.SLOT_A
	
	if ignore_save_slot_filename:
		# prevent filenames from changing if we're overriding them for tests
		pass
	else:
		var save_slot_filename: String = FILENAMES_BY_SAVE_SLOT[SystemData.misc_settings.save_slot]
		PlayerSave.data_filename = save_slot_filename


func _on_MiscSettings_save_slot_changed() -> void:
	_refresh_save_slot()
