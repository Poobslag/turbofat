class_name OldSystemSave
"""
Provides backwards compatibility with older system save formats.

This class will grow with each change to our save system. Once it gets too large (600 lines or so) we should drop
backwards compatibility for older versions.
"""

"""
Creates and configures a SaveConverter capable of converting older system save formats.
"""
func new_save_converter() -> SaveConverter:
	var _save_converter := SaveConverter.new()
	_save_converter.add_method(self, "_convert_2783", "2783", "27bb")
	_save_converter.add_method(self, "_convert_2743", "2743", "2783")
	_save_converter.add_method(self, "_convert_2743", "252a", "2783")
	_save_converter.add_method(self, "_convert_2743", "24cc", "2783")
	_save_converter.add_method(self, "_convert_2743", "245b", "2783")
	_save_converter.add_method(self, "_convert_2743", "1b3c", "2783")
	_save_converter.add_method(self, "_convert_2743", "19c5", "2783")
	_save_converter.add_method(self, "_convert_2743", "199c", "2783")
	_save_converter.add_method(self, "_convert_2743", "1922", "2783")
	_save_converter.add_method(self, "_convert_2743", "1682", "2783")
	_save_converter.add_method(self, "_convert_2743", "163e", "2783")
	_save_converter.add_method(self, "_convert_2743", "15d2", "2783")
	return _save_converter


func _convert_2783(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history", "creature_library", "finished_levels", "level_history", "player_info", "successful_levels":
			save_item = null
	return save_item


func _convert_2743(save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"miscellaneous_settings":
			save_item.type = "misc_settings"
	return save_item
