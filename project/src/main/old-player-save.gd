class_name OldPlayerSave
"""
Provides backwards compatibility with older player save formats.

This class will grow with each change to our save system. Once it gets too large (600 lines or so) we should drop
backwards compatibility for older versions.
"""

# chat history prefixes to replace when upgrading from version 2743
# key: old string prefix to be replaced
# value: new string prefix
const PREFIX_REPLACEMENTS_2743 := {
	"chat/bones": "creature/bones",
	"chat/skins": "creature/skins",
	"chat/shirts": "creature/shirts",
	"chat/richie": "creature/richie",
	"chat/bort": "creature/bort",
	"chat/boatricia": "creature/boatricia",
	"chat/ebe": "creature/ebe",
	"creatures/primary/": "creature/",
	"puzzle/levels/cutscenes/": "level/",
}


"""
Creates and configures a SaveConverter capable of converting older player save formats.
"""
func new_save_converter() -> SaveConverter:
	var _save_converter := SaveConverter.new()
	_save_converter.add_method(self, "_convert_2783", "2783", "27bb")
	_save_converter.add_method(self, "_convert_2743", "2743", "2783")
	_save_converter.add_method(self, "_convert_2743", "252a", "2783")
	_save_converter.add_method(self, "_convert_24cc", "24cc", "252a")
	_save_converter.add_method(self, "_convert_245b", "245b", "24cc")
	_save_converter.add_method(self, "_convert_1b3c", "1b3c", "245b")
	_save_converter.add_method(self, "_convert_19c5", "19c5", "1b3c")
	_save_converter.add_method(self, "_convert_199c", "199c", "19c5")
	_save_converter.add_method(self, "_convert_1922", "1922", "199c")
	_save_converter.add_method(self, "_convert_1682", "1682", "1922")
	_save_converter.add_method(self, "_convert_163e", "163e", "1682")
	_save_converter.add_method(self, "_convert_15d2", "15d2", "163e")
	return _save_converter


func _convert_2783(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"player_info":
			var money: int = save_item.value.get("money", 0)
			
			# Old versions didn't measure playtime. We approximate their playtime by guessing that a typical
			# player earns ¥300 per minute. This may be too high but we want a big playtime number when we warn
			# them about accidentally deleting their main save file.
			# warning-ignore:integer_division
			save_item.value["seconds_played"] = money / 5
		"gameplay_settings", "graphics_settings", "keybind_settings", \
		"misc_settings", "miscellaneous_settings", "touch_settings", "volume_settings":
			save_item = null
	return save_item


func _convert_2743(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history":
			_replace_chat_history_prefixes_for_2743(save_item.value)
		"creature_library":
			_replace_fatness_keys_for_2743(save_item.value.get("fatnesses", {}))
	return save_item


"""
Replace chat history keys like 'chat/richie/filler_000' with 'creature/richie/filler_000'
"""
func _replace_chat_history_prefixes_for_2743(dict: Dictionary) -> void:
	for sub_dict in dict.values():
		for key in sub_dict.keys():
			var new_key: String = key
			if "-" in new_key:
				# some older keys have hyphens, perhaps due to bugs
				new_key = StringUtils.hyphens_to_underscores(new_key)
			for prefix in PREFIX_REPLACEMENTS_2743:
				if new_key.begins_with(prefix):
					new_key = PREFIX_REPLACEMENTS_2743[prefix] + new_key.trim_prefix(prefix)
			if key != new_key:
				# if two keys conflict, take the higher value of the two
				sub_dict[new_key] = max(sub_dict[key], sub_dict.get(new_key, 0))
				sub_dict.erase(key)


"""
Replace hyphens with underscores in fatness keys like '#filler-033#'
"""
func _replace_fatness_keys_for_2743(dict: Dictionary) -> void:
	for key in dict.keys():
		var new_key: String = key
		if "-" in new_key:
			# some older keys have hyphens
			new_key = StringUtils.hyphens_to_underscores(new_key)
			
			# if two keys conflict, take the higher value of the two
			dict[new_key] = max(dict[key], dict.get(new_key, 0))
			dict.erase(key)


func _convert_24cc(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history":
			_replace_dialog_with_chat(save_item.value.get("history_items", {}))
			_replace_dialog_with_chat(save_item.value.get("counts", {}))
			_replace_dialog_with_chat(save_item.value.get("filler_counts", {}))
	return save_item


func _replace_dialog_with_chat(dict: Dictionary) -> void:
	for key_obj in dict.keys():
		var key: String = key_obj
		if key.begins_with("dialog/") or key == "dialog":
			dict["chat" + key.trim_prefix("dialog")] = dict[key]
			dict.erase(key)


func _convert_245b(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			if save_item.key in [
					"marsh/hello_everyone",
					"marsh/hello_skins",
					"marsh/pulling_for_skins",
					"marsh/goodbye_skins"]:
				# some levels were made much harder/different, and their scores should not be carried forward
				save_item = null
	return save_item


func _convert_1b3c(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			save_item.key = _convert_1b3c_level_id(save_item.key)
		"successful_levels", "finished_levels":
			var new_levels := {}
			var levels: Dictionary = save_item.value
			for level_id in levels:
				var new_level_id := _convert_1b3c_level_id(level_id)
				new_levels[new_level_id] = levels[level_id]
			save_item.value = new_levels
	return save_item


func _convert_1b3c_level_id(value: String) -> String:
	var new_value := value
	if value.begins_with("practice/survival_"):
		new_value = "practice/marathon_%s" % [value.trim_prefix("practice/survival_")]
	return new_value


func _convert_19c5(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			save_item.key = _convert_199c_level_id(save_item.key)
		"successful_levels", "finished_levels":
			var new_levels := {}
			var levels: Dictionary = save_item.value
			for level_id in levels:
				var new_level_id := _convert_199c_level_id(level_id)
				new_levels[new_level_id] = levels[level_id]
			save_item.value = new_levels
	return save_item


func _convert_199c(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"scenario_history":
			save_item.type = "level_history"
		"successful_scenarios":
			save_item.type = "successful_levels"
		"finished_scenarios":
			save_item.type = "finished_levels"
	return save_item


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


func _convert_1922(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history":
			_replace_dialog_with_creatures_primary(save_item.value)
	return save_item


func _replace_dialog_with_creatures_primary(dict: Dictionary) -> void:
	for sub_dict in dict.values():
		for key in sub_dict.keys():
			for creature_id in ["boatricia", "ebe", "bort"]:
				var search_string := "dialog/%s" % [creature_id]
				var replacement := "creatures/primary/%s" % [creature_id]
				if key.find(search_string) != -1:
					var new_key: String = key.replace(search_string, replacement)
					sub_dict[new_key] = sub_dict[key]
					sub_dict.erase(key)


func _convert_1682(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat-history":
			save_item.type = StringUtils.hyphens_to_underscores(save_item.type)
			save_item.key = StringUtils.hyphens_to_underscores(save_item.key)
			if typeof(save_item.value) == TYPE_DICTIONARY:
				_replace_key_hyphens_with_underscores(save_item.value)
			_replace_key_hyphens_with_underscores(save_item.value["history_items"])
		_:
			save_item.type = StringUtils.hyphens_to_underscores(save_item.type)
			save_item.key = StringUtils.hyphens_to_underscores(save_item.key)
			if typeof(save_item.value) == TYPE_DICTIONARY:
				_replace_key_hyphens_with_underscores(save_item.value)
	return save_item


func _replace_key_hyphens_with_underscores(dict: Dictionary) -> void:
	for key in dict.keys():
		if key.find("-") != -1:
			dict[StringUtils.hyphens_to_underscores(key)] = dict[key]
			dict.erase(key)


func _convert_163e(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"scenario-history":
			for rank_result_obj in save_item.value:
				var rank_result_dict: Dictionary = rank_result_obj
				if rank_result_dict.get("lost", true):
					rank_result_dict["success"] = false
	return save_item


func _convert_15d2(save_item: SaveItem) -> SaveItem:
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
	return save_item


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
