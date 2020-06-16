class_name OldSave
"""
Provides backwards compatibility with older save formats.

This class's size will worsen with each change to our save system. Once it gets too large (600 lines or so) we should
consider dropping backwards compatibility for older versions.
"""

# Filename for v0.0517 data. Can be changed for tests
var player_data_filename_0517 := "user://turbofat.save"

class StringTransformer:
	"""
	Applies a series of regex transformations.
	"""
	
	var _regex := RegEx.new()
	var transformed: String
	
	func _init(s: String) -> void:
		transformed = s
	
	"""
	Apply a regex transformation.
	"""
	func sub(pattern: String, replacement: String) -> void:
		_regex.compile(pattern)
		transformed = _regex.sub(transformed, replacement, true)


"""
Returns 'true' if the player has an old save file, but no new save file.

This indicates we should convert their old save file to the new format.
"""
func only_has_old_save() -> bool:
	return has_old_save() and not has_new_save()


"""
Returns 'true' if the player has a save file in the current format.
"""
func has_new_save() -> bool:
	return FileUtils.file_exists(PlayerSave.player_data_filename)


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
	transformer.transformed = JSONBeautifier.beautify_json(transformer.transformed, 1)
	transformer.transformed = _append_compare_flag_for_0517(transformer.transformed)
	save_json_text = transformer.transformed
	
	FileUtils.write_file(PlayerSave.player_data_filename, save_json_text)


"""
Returns 'true' if the specified json save items don't match the latest version.
"""
func is_old_save_items(json_save_items: Array) -> bool:
	var is_old: bool = false
	var version_string := get_version_string(json_save_items)
	match version_string:
		PlayerSave.PLAYER_DATA_VERSION:
			is_old = false
		"163e":
			is_old = true
		"15d2":
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
		"163e":
			json_save_items = _convert_163e(json_save_items)
		"15d2":
			json_save_items = _convert_15d2(json_save_items)
	return json_save_items


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
				json_save_item_obj["value"] = PlayerSave.PLAYER_DATA_VERSION
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
	return to_json(json_save_items)
