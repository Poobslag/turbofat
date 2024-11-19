class_name SystemSaveUpgrader
## Provides backwards compatibility with older system save formats.
##
## This class will grow with each change to our save system. Once it gets too large (600 lines or so) we should drop
## backwards compatibility for older versions.

## Creates and configures a SaveItemUpgrader capable of upgrading older system save formats.
func new_save_item_upgrader() -> SaveItemUpgrader:
	var upgrader := SaveItemUpgrader.new()
	upgrader.current_version = "5b9b"
	upgrader.add_upgrade_method(self, "_upgrade_5a24", "5a24", "5b9b")
	upgrader.add_upgrade_method(self, "_upgrade_37b3", "37b3", "5a24")
	upgrader.add_upgrade_method(self, "_upgrade_27bb", "27bb", "37b3")
	upgrader.add_upgrade_method(self, "_upgrade_2783", "2783", "27bb")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "2743", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "252a", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "24cc", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "245b", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "1b3c", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "19c5", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "199c", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "1922", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "1682", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "163e", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "15d2", "2783")
	return upgrader


func _upgrade_5a24(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"gameplay_settings":
			# ensure 'legacy_properties' property exists
			if not "legacy_properties" in save_item:
				save_item.value["legacy_properties"] = {}
			
			# move removed properties from gameplay_settings to gameplay_settings.legacy_properties
			for property in ["hold_piece", "line_piece", "speed"]:
				if save_item.value.has(property):
					save_item.value["legacy_properties"][property] = save_item.value.get(property)
	return save_item


func _upgrade_37b3(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"keybind_settings":
			if save_item.value.get("custom_keybinds") is Dictionary:
				save_item.value["custom_keybinds"]["next_tab"] = [{"type": "key", "scancode": 88}, {}, {}]
				save_item.value["custom_keybinds"]["prev_tab"] = [{"type": "key", "scancode": 90}, {}, {}]
	return save_item


func _upgrade_27bb(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"keybind_settings":
			if save_item.value.get("custom_keybinds") is Dictionary:
				save_item.value["custom_keybinds"].erase("interact")
				save_item.value["custom_keybinds"].erase("phone")
				save_item.value["custom_keybinds"].erase("walk_down")
				save_item.value["custom_keybinds"].erase("walk_left")
				save_item.value["custom_keybinds"].erase("walk_right")
				save_item.value["custom_keybinds"].erase("walk_up")
	return save_item


func _upgrade_2783(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history", "creature_library", "finished_levels", "level_history", "player_info", "successful_levels":
			save_item = null
	return save_item


func _upgrade_2743(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"miscellaneous_settings":
			save_item.type = "misc_settings"
	return save_item
