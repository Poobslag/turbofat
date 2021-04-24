class_name OldSave
"""
Provides backwards compatibility with older save formats.

This class's size will worsen with each change to our save system. Once it gets too large (600 lines or so) we should
consider dropping backwards compatibility for older versions.
"""

# Filename for v0.0517 data. Can be changed for tests
var player_data_filename_0517 := "user://turbofat.save"

"""
Returns 'true' if the player has an old save file but no new save file.

This indicates we should convert their old save file to the new format.
"""
func only_has_old_save() -> bool:
	return has_old_save() and not has_new_save()


"""
Returns 'true' if the player has a save file in the current format.
"""
func has_new_save() -> bool:
	return FileUtils.file_exists(PlayerSave.current_player_data_filename)


"""
Returns 'true' if the player has a save file in an old format.
"""
func has_old_save() -> bool:
	return FileUtils.file_exists(player_data_filename_0517)


"""
Converts the player's old save file to the new format.
"""
func transform_old_save() -> void:
	if has_new_save():
		push_error("Won't overwrite new save with old save")
		return
	if not has_old_save():
		push_error("No old save to restore")
		return
	
	# transform 0.0517 data to current format
	var save_json_text := FileUtils.get_file_as_text(player_data_filename_0517)
	var transformer := StringTransformer.new(save_json_text)
	transformer.transformed += "\n{\"type\":\"version\",\"value\":\"15d2\"}"
	transformer.sub("plyr({.*})", "{\"type\":\"player-info\",\"value\":$1},")
	transformer.sub("\"marathon-", "\"survival-")
	transformer.sub("scenario_name", "key")
	transformer.sub("scen{\"scenario_history\":(\\[.*\\])(.*)}", "{\"type\":\"scenario-history\",\"value\":$1$2},")
	transformer.sub("\"died\":false", "\"top_out_count\":0,\"lost\":false")
	transformer.sub("\"died\":true", "\"top_out_count\":1,\"lost\":true")
	transformer.transformed = "[%s]" % transformer.transformed
	transformer.transformed = _append_compare_flag_for_0517(transformer.transformed)
	save_json_text = transformer.transformed
	
	FileUtils.write_file(PlayerSave.current_player_data_filename, save_json_text)


"""
Returns 'true' if the specified json save items don't match the latest version.
"""
func is_old_save_items(json_save_items: Array) -> bool:
	var is_old: bool = false
	var version_string := get_version_string(json_save_items)
	match version_string:
		PlayerSave.PLAYER_DATA_VERSION:
			is_old = false
		"1b3c", "19c5", "199c", "1922", "1682", "163e", "15d2", "245b":
			is_old = true
		_:
			push_warning("Unrecognized save data version: '%s'" % version_string)
	return is_old


"""
Extracts a version string from the specified json save items.
"""
func get_version_string(json_save_items: Array) -> String:
	var version: SaveItem
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		if save_item.type == "version":
			version = save_item
			break
	return version.value if version else ""


"""
Transforms the specified json save items to the latest format.
"""
func transform_old_save_items(json_save_items: Array) -> Array:
	var version_string := get_version_string(json_save_items)
	match version_string:
		"245b":
			json_save_items = _convert_245b(json_save_items)
		"1b3c":
			json_save_items = _convert_1b3c(json_save_items)
		"19c5":
			json_save_items = _convert_19c5(json_save_items)
		"199c":
			json_save_items = _convert_199c(json_save_items)
		"1922":
			json_save_items = _convert_1922(json_save_items)
		"1682":
			json_save_items = _convert_1682(json_save_items)
		"163e":
			json_save_items = _convert_163e(json_save_items)
		"15d2":
			json_save_items = _convert_15d2(json_save_items)
	return json_save_items


func _convert_245b(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "24cc"
			"level_history":
				if save_item.key in [
						"marsh/hello_everyone",
						"marsh/hello_skins",
						"marsh/pulling_for_skins",
						"marsh/goodbye_skins"]:
					# some levels were made much harder/different, and their scores should not be carried forward
					save_item = null
		
		if save_item:
			new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _convert_1b3c(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "245b"
			"level_history":
				save_item.key = _convert_1b3c_level_id(save_item.key)
			"successful_levels", "finished_levels":
				var new_levels := {}
				var levels: Dictionary = save_item.value
				for level_id in levels:
					var new_level_id := _convert_1b3c_level_id(level_id)
					new_levels[new_level_id] = levels[level_id]
				save_item.value = new_levels
		
		new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _convert_1b3c_level_id(value: String) -> String:
	var new_value := value
	if value.begins_with("practice/survival_"):
		new_value = "practice/marathon_%s" % [value.trim_prefix("practice/survival_")]
	return new_value


func _convert_19c5(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "1b3c"
			"level_history":
				save_item.key = _convert_199c_level_id(save_item.key)
			"successful_levels", "finished_levels":
				var new_levels := {}
				var levels: Dictionary = save_item.value
				for level_id in levels:
					var new_level_id := _convert_199c_level_id(level_id)
					new_levels[new_level_id] = levels[level_id]
				save_item.value = new_levels
		
		new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _convert_199c(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "19c5"
			"scenario_history":
				save_item.type = "level_history"
		new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _convert_199c_level_id(value: String) -> String:
	var new_value := value
	if value.begins_with("tutorial_"):
		new_value = "tutorial/%s" % [value.trim_prefix("tutorial_")]
	elif value == "oh_my":
		new_value = "tutorial/%s" % [value]
	elif value.begins_with("rank_"):
		new_value = "rank/%s" % [value.trim_prefix("rank_")]
	elif value.begins_with("sandbox_") \
			or value.begins_with("sprint_") \
			or value.begins_with("survival_") \
			or value.begins_with("ultra_"):
		new_value = "practice/%s" % [value]
	return new_value


func _convert_1922(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		save_item.type = save_item.type.replace("-", "_")
		save_item.key = save_item.key.replace("-", "_")
		if typeof(save_item.value) == TYPE_DICTIONARY:
			_replace_key_hyphens_with_underscores(save_item.value)
		
		match save_item.type:
			"version":
				save_item["value"] = "199c"
			"chat_history":
				_replace_dialog_with_creatures_primary(save_item["value"])
		
		new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _replace_dialog_with_creatures_primary(dict: Dictionary) -> void:
	for sub_dict in dict.values():
		for key in sub_dict.keys():
			for creature_id in ["boatricia", "ebe", "bort"]:
				var search_string: String = "dialog/%s" % creature_id
				var replacement: String = "creatures/primary/%s" % creature_id
				if key.find(search_string) != -1:
					sub_dict[key.replace(search_string, replacement)] = sub_dict[key]
					sub_dict.erase(key)


func _convert_1682(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		save_item.type = save_item.type.replace("-", "_")
		save_item.key = save_item.key.replace("-", "_")
		if typeof(save_item.value) == TYPE_DICTIONARY:
			_replace_key_hyphens_with_underscores(save_item.value)
		
		match save_item.type:
			"version":
				save_item["value"] = "1922"
			"chat_history":
				_replace_key_hyphens_with_underscores(save_item["value"]["history_items"])
		
		new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _replace_key_hyphens_with_underscores(dict: Dictionary) -> void:
	for key in dict.keys():
		if key.find("-") != -1:
			dict[key.replace("-", "_")] = dict[key]
			dict.erase(key)


func _convert_163e(json_save_items: Array) -> Array:
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"scenario-history":
				for rank_result_obj in save_item.value:
					var rank_result_dict: Dictionary = rank_result_obj
					if rank_result_dict.get("lost", true):
						rank_result_dict["success"] = false
			"version":
				json_save_item_obj["value"] = "1682"
	return json_save_items


func _convert_15d2(json_save_items: Array) -> Array:
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"scenario-history":
				match save_item.key:
					"rank-7k": _append_score_success_for_15d2(save_item, 200)
					"rank-6k": _append_score_success_for_15d2(save_item, 200)
					"rank-5k": _append_score_success_for_15d2(save_item, 750)
					"rank-4k": _append_score_success_for_15d2(save_item, 300)
					"rank-3k": _append_score_success_for_15d2(save_item, 999)
					"rank-2k": _append_time_success_for_15d2(save_item, 180)
					"rank-1k": _append_score_success_for_15d2(save_item, 1000)
					"rank-1d": _append_score_success_for_15d2(save_item, 1200)
					"rank-2d": _append_time_success_for_15d2(save_item, 300)
					"rank-3d": _append_score_success_for_15d2(save_item, 750)
					"rank-4d": _append_score_success_for_15d2(save_item, 2000)
					"rank-5d": _append_score_success_for_15d2(save_item, 2500)
					"rank-6d": _append_time_success_for_15d2(save_item, 180)
					"rank-7d": _append_score_success_for_15d2(save_item, 4000)
					"rank-8d": _append_score_success_for_15d2(save_item, 4000)
					"rank-9d": _append_score_success_for_15d2(save_item, 6000)
					"rank-10d": _append_score_success_for_15d2(save_item, 15000)
			"version":
				json_save_item_obj["value"] = "163e"
	return json_save_items


"""
Adds a 'success' key for a RankResult if the player met a target score and didn't lose.

Provides backwards compatibility with 15d2, which did not include 'success' keys in rank results.
"""
func _append_score_success_for_15d2(save_item: SaveItem, target_score: int) -> void:
	for rank_result_obj in save_item.value:
		var rank_result_dict: Dictionary = rank_result_obj
		rank_result_dict["success"] = not rank_result_dict.get("lost", true) \
				and rank_result_dict.get("score", 0) >= target_score


"""
Adds a 'success' key for a RankResult if the player met a target time and didn't lose

Provides backwards compatibility with 15d2, which did not include 'success' keys in rank results.
"""
func _append_time_success_for_15d2(save_item: SaveItem, target_time: float) -> void:
	for rank_result_obj in save_item.value:
		var rank_result_dict: Dictionary = rank_result_obj
		rank_result_dict["success"] = not rank_result_dict.get("lost", true) \
				and rank_result_dict.get("seconds", 0.0) <= target_time


"""
Appends a 'compare' flag to the ultra records.

This method temporarily converts the save file into json. I couldn't figure out a regular expression to accomplish
this.
"""
func _append_compare_flag_for_0517(save_json_text: String) -> String:
	var json_save_items: Array = parse_json(save_json_text)
	for json_save_item_obj in json_save_items:
		var save_item: Dictionary = json_save_item_obj
		if save_item.get("type") == "scenario-history" and save_item.get("key").begins_with("ultra-"):
			for value_obj in save_item.get("value"):
				var value: Dictionary = value_obj
				value["compare"] = "-seconds"
	return Utils.print_json(json_save_items)
