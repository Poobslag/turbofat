class_name OldSave
"""
Provides backwards compatibility with older save formats.

This class's size will worsen with each change to our save system. Once it gets too large (600 lines or so) we should
consider dropping backwards compatibility for older versions.
"""

"""
Returns 'true' if the specified json save items don't match the latest version.
"""
func is_old_save_items(json_save_items: Array) -> bool:
	var is_old: bool = false
	var version_string := get_version_string(json_save_items)
	match version_string:
		PlayerSave.PLAYER_DATA_VERSION:
			is_old = false
		"1b3c", "19c5", "199c", "1922", "1682", "163e", "15d2", "245b", "24cc":
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
		"24cc":
			json_save_items = _convert_24cc(json_save_items)
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


func _convert_24cc(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "252a"
			"chat_history":
				_replace_dialog_with_chat(save_item.value.get("history_items", {}))
				_replace_dialog_with_chat(save_item.value.get("counts", {}))
				_replace_dialog_with_chat(save_item.value.get("filler_counts", {}))
		
		if save_item:
			new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _replace_dialog_with_chat(dict: Dictionary) -> void:
	for key_obj in dict.keys():
		var key: String = key_obj
		if key.begins_with("dialog/") or key == "dialog":
			dict["chat" + key.trim_prefix("dialog")] = dict[key]
			dict.erase(key)


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
		save_item.type = StringUtils.hyphens_to_underscores(save_item.type)
		save_item.key = StringUtils.hyphens_to_underscores(save_item.key)
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
				var search_string := "dialog/%s" % [creature_id]
				var replacement := "creatures/primary/%s" % [creature_id]
				if key.find(search_string) != -1:
					sub_dict[key.replace(search_string, replacement)] = sub_dict[key]
					sub_dict.erase(key)


func _convert_1682(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		save_item.type = StringUtils.hyphens_to_underscores(save_item.type)
		save_item.key = StringUtils.hyphens_to_underscores(save_item.key)
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
			dict[StringUtils.hyphens_to_underscores(key)] = dict[key]
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
