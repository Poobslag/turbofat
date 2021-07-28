class_name OldSystemSave
"""
Provides backwards compatibility with older system save formats.

This class will grow with each change to our save system. Once it gets too large (600 lines or so) we should drop
backwards compatibility for older versions.
"""

"""
Returns 'true' if the specified json save items are from an older version of the game.
"""
func is_old_save_items(json_save_items: Array) -> bool:
	var is_old: bool = false
	var version_string := get_version_string(json_save_items)
	match version_string:
		PlayerSave.PLAYER_DATA_VERSION:
			is_old = false
		"1b3c", "19c5", "199c", "1922", "1682", "163e", "15d2", "245b", "24cc", "252a", "2743", "2783":
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
		"2783":
			json_save_items = _convert_2783(json_save_items)
		"2743", "252a", "24cc", "245b", "1b3c", "19c5", "199c", "1922", "1682", "163e", "15d2":
			json_save_items = _convert_252a(json_save_items)
	return json_save_items


func _convert_2783(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "27bb"
			"chat_history", "creature_library", "finished_levels", "level_history", "player_info", "successful_levels":
				save_item = null
		if save_item:
			new_save_items.append(save_item.to_json_dict())
	return new_save_items


func _convert_252a(json_save_items: Array) -> Array:
	var new_save_items := []
	for json_save_item_obj in json_save_items:
		var save_item: SaveItem = SaveItem.new()
		save_item.from_json_dict(json_save_item_obj)
		match save_item.type:
			"version":
				save_item["value"] = "2783"
			"miscellaneous_settings":
				save_item.type = "misc_settings"
		new_save_items.append(save_item.to_json_dict())
	return new_save_items
