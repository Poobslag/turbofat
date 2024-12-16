class_name LevelSettingsUpgrader

## Externally defined method which provides version-specific updates.
class UpgradeMethod:
	## Name of the method which performs the upgrade
	var method: String
	
	## Old save data version which the method upgrades from
	var old_version: String
	
	## New save data version which the method upgrades to
	var new_version: String

## Newest version which everything should upgrade to.
var current_version: String

## Internally defined methods which provide version-specific updates.
## key: (String) old save data version from which the method upgrades
## value: (UpgradeMethod) method to call
var _upgrade_methods := {}

func _init() -> void:
	current_version = Levels.LEVEL_DATA_VERSION
	_add_upgrade_method("_upgrade_5a6b", "5a6b", "5c84")
	_add_upgrade_method("_upgrade_59c3", "59c3", "5a6b")
	_add_upgrade_method("_upgrade_4c5c", "4c5c", "59c3")
	_add_upgrade_method("_upgrade_49db", "49db", "4c5c")
	_add_upgrade_method("_upgrade_4373", "4373", "49db")
	_add_upgrade_method("_upgrade_39e5", "39e5", "4373")
	_add_upgrade_method("_upgrade_392b", "392b", "39e5")
	_add_upgrade_method("_upgrade_2cb4", "2cb4", "392b")
	_add_upgrade_method("_upgrade_297a", "297a", "2cb4")
	_add_upgrade_method("_upgrade_19c5", "19c5", "297a")
	_add_upgrade_method("_upgrade_1922", "1922", "19c5")


## Upgrades the specified json settings to the newest format.
func upgrade(json_settings: Dictionary) -> Dictionary:
	var new_json := json_settings
	while needs_upgrade(new_json):
		# upgrade the old save file to a new format
		var old_version := _get_version_string(new_json)
		
		if not _upgrade_methods.has(old_version):
			push_warning("Couldn't upgrade old settings version '%s'" % old_version)
			break
		
		var upgrade_method: UpgradeMethod = _upgrade_methods[old_version]
		var old_json := new_json
		new_json = {}
		for old_key in old_json:
			match old_key:
				"version":
					new_json["version"] = upgrade_method.new_version
				_:
					call(upgrade_method.method, old_json, old_key, new_json)
		
		if _get_version_string(new_json) == old_version:
			# failed to upgrade, but the data might still load
			push_warning("Couldn't upgrade old settings '%s'" % old_version)
			break
	
	return new_json


## Returns 'true' if the specified json settings are from an older version of the game.
func needs_upgrade(json_settings: Dictionary) -> bool:
	var result: bool = false
	var version := _get_version_string(json_settings)
	if version == current_version:
		result = false
	elif _upgrade_methods.has(version):
		result = true
	else:
		push_warning("Unrecognized settings version: '%s'" % version)
	return result


## Adds a new internally defined method which provides version-specific updates.
##
## Upgrade methods include three parameters:
## 	'old_json': (Dictionary) Old parsed level settings from which data should be upgraded
##
## 	'old_key': (String) Key corresponding to a key/value pair in the old_json dictionary which should be upgraded
##
## 	'new_json': (Dictionary) Destination dictionary to which upgraded data should be written
##
## Parameters:
## 	'method': The name of the method which performs the upgrade.
##
## 	'old_version': The old settings version which the method upgrades from
##
## 	'new_version': The new settings version which the method upgrades to
func _add_upgrade_method(method: String, old_version: String, new_version: String) -> void:
	var upgrade_method: UpgradeMethod = UpgradeMethod.new()
	upgrade_method.method = method
	upgrade_method.old_version = old_version
	upgrade_method.new_version = new_version
	_upgrade_methods[old_version] = upgrade_method


func _upgrade_5a6b(old_json: Dictionary, old_key: String, new_json: Dictionary) -> void:
	match old_key:
		"rank":
			var new_value: Array = old_json[old_key]
			
			var rank_criteria_property_index := -1
			for rank_property_index in range(old_json[old_key].size()):
				if old_json[old_key][rank_property_index].begins_with("rank_criteria "):
					rank_criteria_property_index = rank_property_index
					break
			
			if rank_criteria_property_index != -1:
				# grab the end part of the rank_criteria string, "m=3350 s-=550"
				var criteria_strings := StringUtils.substring_after(
						old_json[old_key][rank_criteria_property_index], "rank_criteria ")
				var criteria_strings_split := criteria_strings.split(" ")
				
				# replace the "m=3350" string with "top=3350"
				for i in criteria_strings_split.size():
					var criteria_string := criteria_strings_split[i]
					if criteria_string.begins_with("m="):
						criteria_strings_split[i] = "top=%s" % StringUtils.substring_after(criteria_string, "m=")
						break
				new_value[rank_criteria_property_index] = "rank_criteria %s" % [PoolStringArray(criteria_strings_split).join(" ")]
				new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]


func _upgrade_59c3(old_json: Dictionary, old_key: String, new_json: Dictionary) -> void:
	match old_key:
		"blocks_during":
			var new_value := []
			for old_blocks_during in old_json[old_key]:
				match old_blocks_during:
					"clear_on_top_out":
						new_value.append("top_out_effect clear")
					"refresh_on_top_out":
						new_value.append("top_out_effect refresh")
					_:
						new_value.append(old_blocks_during)
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]


## Simplify level rank metadata.
##
## Version 59c3 eliminated granular rank fields like "box_factor" and "combo_factor".
func _upgrade_4c5c(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"rank":
			new_json["rank"] = []
			for rank_entry in old_json.get("rank", []):
				match rank_entry.split(" ")[0]:
					"box_factor", \
					"combo_factor", \
					"customer_combo", \
					"extra_seconds_per_piece", \
					"hide_boxes_rank", \
					"hide_combos_rank", \
					"hide_lines_rank", \
					"hide_pickups_rank", \
					"hide_pieces_rank", \
					"hide_speed_rank", \
					"leftover_lines", \
					"master_pickup_score", \
					"master_pickup_score_per_line", \
					"preplaced_pieces", \
					"show_boxes_rank", \
					"show_combos_rank", \
					"show_lines_rank", \
					"show_pickups_rank", \
					"show_pieces_rank", \
					"show_speed_rank":
						pass
					_:
						new_json["rank"].append(rank_entry)
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_49db(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"tiles":
			var new_value: Dictionary = old_json[old_key].duplicate(true)
			for block_bunch in new_value.values():
				for block_obj in block_bunch:
					_upgrade_block_obj_49db(block_obj)
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


## Increases block bunch autotile coordinates.
##
## Version 4c5c added cheese pieces to row 5 of the sprite sheet. Any autotile coordinates at or below row 5 need to
## be incremented.
func _upgrade_block_obj_49db(block_dict: Dictionary) -> void:
	if block_dict.has("tile"):
		var pos_array: Array = block_dict["tile"].split(" ")
		if int(pos_array[2]) >= 4:
			pos_array[2] = int(pos_array[2]) + 1
		block_dict["tile"] = PoolStringArray(pos_array).join(" ")
	if block_dict.has("pickup"):
		var pickup_int := int(block_dict["pickup"])
		if pickup_int >= 4:
			pickup_int += 1
		block_dict["pickup"] = String(pickup_int)


func _upgrade_4373(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"timers":
			var new_value: Array = old_json[old_key].duplicate(true)
			for timer in new_value:
				if timer.has("initial_interval"):
					timer["start"] = timer["initial_interval"]
					timer.erase("initial_interval")
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_39e5(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"triggers":
			var new_value: Array = old_json[old_key].duplicate(true)
			for trigger in new_value:
				for phase_index in range(trigger.get("phases", []).size()):
					var phase: String = trigger["phases"][phase_index]
					if phase.begins_with("piece_written "):
						trigger["phases"][phase_index] = _increment_phase_string(phase, "n")
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _increment_phase_string(phase: String, condition: String) -> String:
	var result: String = phase
	var split := phase.split(" ")
	for i_split in range(split.size()):
		var phase_fragment: String = split[i_split]
		
		if phase_fragment.begins_with("%s=" % [condition]):
			split[i_split] = increment_string(phase_fragment)
			result = PoolStringArray(split).join(" ")
			break
	
	return result


func _upgrade_392b(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"triggers":
			var new_value: Array = old_json[old_key].duplicate(true)
			for trigger in new_value:
				for phase_index in range(trigger.get("phases", []).size()):
					var phase: String = trigger["phases"][phase_index]
					if phase.begins_with("after_line_cleared "):
						trigger["phases"][phase_index] = phase.replace("after_line_cleared", "line_cleared")
					if phase.begins_with("after_piece_written "):
						trigger["phases"][phase_index] = phase.replace("after_piece_written", "piece_written")
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_2cb4(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"title":
			new_json["name"] = old_json[old_key]
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_297a(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"blocks_during":
			var new_value := []
			for old_blocks_during in old_json[old_key]:
				if old_blocks_during == "random_tiles_start":
					new_value.append("shuffle_inserted_lines slice")
				else:
					new_value.append(old_blocks_during)
			new_json[old_key] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_19c5(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"blocks_start":
			new_json["tiles"] = {"start": old_json[old_key].get("tiles", [])}
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


func _upgrade_1922(old_json: Dictionary, old_key: String, new_json: Dictionary) -> Dictionary:
	match old_key:
		"start_level":
			new_json["start_speed"] = old_json[old_key]
		"level_ups":
			var new_value := []
			for old_level_up in old_json[old_key]:
				var new_level_up: Dictionary = old_level_up.duplicate()
				new_level_up["speed"] = new_level_up.get("level")
				new_level_up.erase("level")
				new_value.append(new_level_up)
			new_json["speed_ups"] = new_value
		_:
			new_json[old_key] = old_json[old_key]
	return new_json


## Increments all integers in a string by one.
##
## 	increment_string(""):      ""
## 	increment_string("1 2 3"): "2 3 4"
## 	increment_string("1,200"): "2,201"
## 	increment_string("-96"):   "-97"
##
## Symbols like '-' and ',' are treated as non-numeric data and ignored.
static func increment_string(s: String) -> String:
	var result := ""
	var num_buffer := ""
	for c in s:
		if StringUtils.is_digit(c):
			# digit; add to buffer
			num_buffer += c
		elif num_buffer:
			# non-digit;
			result += str(int(num_buffer) + 1)
			num_buffer = ""
			result += c
		else:
			result += c
	
	if num_buffer:
		result += str(int(num_buffer) + 1)
	
	return result


## Extracts a version string from the specified json settings.
static func _get_version_string(json_settings: Dictionary) -> String:
	return json_settings.get("version")
