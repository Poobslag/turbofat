class_name PlayerSaveUpgrader
## Provides backwards compatibility with older player save formats.
##
## This class will grow with each change to our save system. Once it gets too large (600 lines or so) we should drop
## backwards compatibility for older versions.

## Level ids to prune when upgrading from version 3776
const LEVEL_PRUNE_LIST_3776 := {
	"002": true,
	"003": true,
	"004": true,
	"005": true,
	"007": true,
	"009": true,
	"010": true,
	"011": true,
	"a_little_extra": true,
	"a_little_garbage_2": true,
	"a_little_garbage_3": true,
	"accelerator": true,
	"all_clear": true,
	"artistic_libaty": true,
	"bleah": true,
	"boatricia": true,
	"boatricia1": true,
	"boatricia2": true,
	"bogus_level": true,
	"cake_check": true,
	"career/boss_1k": true,
	"career/boss_2k": true,
	"career/boss_3k": true,
	"career/boss_4k": true,
	"career/boss_5k": true,
	"career/boss_7k": true,
	"career/fruit_on_the_top": true,
	"career/veggie_puzzle": true,
	"cookies": true,
	"donuts": true,
	"etc": true,
	"etc2": true,
	"example": true,
	"example_ac": true,
	"experiment/000": true,
	"experiment/001": true,
	"experiment/002": true,
	"experiment/003": true,
	"experiment/004": true,
	"experiment/005": true,
	"experiment/006": true,
	"experiment/007": true,
	"experiment/008": true,
	"experiment/009": true,
	"experiment/010": true,
	"experiment/011": true,
	"five_customers_no_vegetables": true,
	"flip_scenario": true,
	"freestyle": true,
	"fruit_salad": true,
	"goodbye_skins": true,
	"hello_everyone": true,
	"hello_skins": true,
	"lo_kcal": true,
	"lol": true,
	"many_boxes": true,
	"marsh/goodbye_bones": true,
	"marsh/goodbye_everyone": true,
	"marsh/goodbye_shirts": true,
	"marsh/goodbye_skins": true,
	"marsh/hello_bones": true,
	"marsh/hello_everyone": true,
	"marsh/hello_shirts": true,
	"marsh/hello_skins": true,
	"marsh/lets_all_get_merry": true,
	"marsh/pulling_for_bones": true,
	"marsh/pulling_for_bones_short": true,
	"marsh/pulling_for_everyone": true,
	"marsh/pulling_for_shirts": true,
	"marsh/pulling_for_skins": true,
	"marsh/pulling_for_skins2": true,
	"micro_customers": true,
	"micro_lines": true,
	"micro_score": true,
	"micro_time": true,
	"obnoxious": true,
	"obnoxious2": true,
	"placeholder01": true,
	"placeholder02": true,
	"placeholder03": true,
	"placeholder04": true,
	"placeholder05": true,
	"placeholder06": true,
	"placeholder07": true,
	"placeholder08": true,
	"placeholder09": true,
	"placeholder10": true,
	"placeholder11": true,
	"placeholder12": true,
	"placeholder13": true,
	"placeholder14": true,
	"placeholder15": true,
	"placeholder16": true,
	"placeholder17": true,
	"placeholder18": true,
	"placeholder2": true,
	"placeholder3": true,
	"placeholder4": true,
	"placeholder6": true,
	"placeholder7": true,
	"placeholder8": true,
	"practice/sandbox_hard": true,
	"practice/squish_test": true,
	"pulling_for_bones_short": true,
	"pulling_for_skins": true,
	"rainbows": true,
	"rocket_drop_test": true,
	"something": true,
	"spins_0": true,
	"spins_1": true,
	"spins_2": true,
	"spins_3": true,
	"spins_4": true,
	"spins_5": true,
	"spins_6": true,
	"spins_9": true,
	"spins_secret": true,
	"stacks": true,
	"strawberry_shortcut": true,
	"test_5952": true,
	"test_top_out": true,
	"the_curse": true,
	"time_level_up": true,
	"tulip": true,
	"tutorial/beginner_0": true,
	"tutorial/combo_3": true,
	"tutorial/combo_4": true,
	"tutorial/combo_5": true,
	"tutorial/combo_6": true,
	"tutorial/combos_0": true,
	"tutorial/spins_0_example": true,
	"tutorial/spins_1a": true,
	"tutorial/spins_4": true,
	"tutorial/spins_5_example": true,
	"tutorial/spins_6": true,
	"tutorial/spins_9": true,
	"tutorial/squish_1": true,
	"tutorial/squish_4": true,
	"tutorial/squish_5": true,
	"tutorial_combos_4": true,
	"tutorial_combos_6": true,
	"tutorial_squish_5": true,
	"tutorial_squish_6": true,
	"u_climb": true,
	"ultra_normal": true,
	"unfresh_fruits_2": true,
	"veggie_patty": true,
	"veggie_puzzle": true,
	"wedge": true
}

## Chat ids to prune when upgrading from version 3776
const CHAT_PRUNE_LIST_3776 := {
	"chat/level_select": true,
	"chat/level_select_2": true,
	"chat/glowy_sphere": true,
	"chat/marsh_crystal": true,
	"chat/level_select_1": true,
	"chat/meet_the_competition": true,
	"creature/boatricia/hi": true,
	"creature/boatricia/filler": true,
	"creature/ebe/filler": true,
	"creature/bort/filler": true,
	"creature/boatricia/level_1": true,
	"creature/boatricia/my_maid_died": true,
	"creature/boatricia/level_2": true,
	"creature/boatricia/life_is_so_short": true,
	"creature/ebe/no_vegetables": true,
	"creature/ebe/filler_000": true,
	"creature/shirts/filler_000": true,
	"creature/skins/filler_000": true,
	"creature/bones/filler_000": true,
	"creature/richie/filler_000": true,
	"level/marsh/hello_everyone": true,
	"level/marsh/hello_everyone_000": true,
	"level/marsh/hello_everyone_100": true,
	"level/boatricia2_000": true,
	"level/marsh/hello_bones_100": true,
	"level/marsh/hello_everyone_000.chat": true,
	"level/marsh/hello_shirts_000.chat": true,
	"level/boatricia1_000.chat": true,
	"level/boatricia2_000.chat": true,
	"level/marsh/hello_skins_100": true,
	"level/marsh/hello_shirts_000": true,
	"creature/bort/filler_000": true,
	"creature/shirts/filler_001": true,
	"creature/richie/pomodoro": true,
	"creature/bones/filler_001": true,
	"creature/richie/filler_001": true,
	"creature/bones/filler_002": true,
	"creature/richie/filler_002": true,
	"creature/bort/filler_000.chat": true,
	"creature/bones/filler_000.chat": true,
	"creature/boatricia/filler_000": true,
	"level/five_customers_no_vegetables_000": true,
	"level/marsh/pulling_for_everyone_000": true,
	"level/marsh/pulling_for_skins_100": true,
	"level/marsh/pulling_for_everyone_100": true,
	"creature/skins/filler_001": true,
	"creature/jayton/soliciting_buttercup_customers": true,
	"creature/jayton/soliciting_buttercup_customers_2": true,
	"creature/jayton/filler_000": true,
	"creature/diota/having_trouble": true,
	"level/marsh/pulling_for_bones_100": true,
	"level/marsh/goodbye_everyone_100": true,
	"chat/marsh_prologue": true,
	"chat/marsh_epilogue": true,
	"creature/shirts/filler_002": true,
	"creature/skins/filler_002": true,
	"level/marsh/lets_all_get_merry_100": true,
	"level/marsh/pulling_for_shirts_100": true,
	"level/boatricia1_000": true,
	"chat/buttercup_sign_closed": true,
	"chat/career/general_00_0": true,
	"chat/career/marsh/00": true,
	"chat/career/marsh/00_end": true,
}

## chat history prefixes to replace when upgrading from version 2743
## key: (string) old string prefix to be replaced
## value: (string) new string prefix
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


## Regex used for replacing two zeroes with a third zero. This regex is lazily initialized.
var _third_zero_regex: RegEx


## Creates and configures a SaveItemUpgrader capable of upgrading older player save formats.
func new_save_item_upgrader() -> SaveItemUpgrader:
	var upgrader := SaveItemUpgrader.new()
	upgrader.current_version = "38c3"
	upgrader.add_upgrade_method(self, "_upgrade_38c3", "37b3", "38c3")
	upgrader.add_upgrade_method(self, "_upgrade_37b3", "3776", "37b3")
	upgrader.add_upgrade_method(self, "_upgrade_375c", "375c", "3776")
	upgrader.add_upgrade_method(self, "_upgrade_36c3", "36c3", "375c")
	upgrader.add_upgrade_method(self, "_upgrade_27bb", "27bb", "36c3")
	upgrader.add_upgrade_method(self, "_upgrade_2783", "2783", "27bb")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "2743", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_2743", "252a", "2783")
	upgrader.add_upgrade_method(self, "_upgrade_24cc", "24cc", "252a")
	upgrader.add_upgrade_method(self, "_upgrade_245b", "245b", "24cc")
	upgrader.add_upgrade_method(self, "_upgrade_1b3c", "1b3c", "245b")
	upgrader.add_upgrade_method(self, "_upgrade_19c5", "19c5", "1b3c")
	upgrader.add_upgrade_method(self, "_upgrade_199c", "199c", "19c5")
	upgrader.add_upgrade_method(self, "_upgrade_1922", "1922", "199c")
	upgrader.add_upgrade_method(self, "_upgrade_1682", "1682", "1922")
	upgrader.add_upgrade_method(self, "_upgrade_163e", "163e", "1682")
	upgrader.add_upgrade_method(self, "_upgrade_15d2", "15d2", "163e")
	return upgrader


## Prepends a third zero to any two-digit numbers in the specified string.
func prepend_third_zero(s: String) -> String:
	if not _third_zero_regex:
		_third_zero_regex = RegEx.new()
		_third_zero_regex.compile("(^|[^0-9])([0-9]{2})([^0-9]|$)")
	
	return _third_zero_regex.sub(s, "${1}0$2$3", true)


func _upgrade_38c3(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history":
			# prepend a third zero to any chat keys with two-digit numbers
			var history_items: Dictionary = save_item.value.get("history_items", {})
			for chat_id in history_items.keys():
				var new_chat_id: String = prepend_third_zero(chat_id)
				if new_chat_id != chat_id:
					history_items[new_chat_id] = history_items[chat_id]
					history_items.erase(chat_id)
	return save_item


func _upgrade_37b3(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			# Convert hyphens to underscores
			save_item.key = StringUtils.hyphens_to_underscores(save_item.key)
			
			# Remove level keys for levels which aren't around as of 2022-07-22
			if save_item.key in LEVEL_PRUNE_LIST_3776:
				save_item = null
		"finished_levels", "successful_levels":
			# Convert hyphens to underscores
			for level_id in save_item.value.keys():
				if "-" in level_id:
					save_item.value[StringUtils.hyphens_to_underscores(level_id)] = save_item.value[level_id]
					save_item.value.erase(level_id)
			
			# Remove level keys for levels which aren't around as of 2022-07-22
			for level_id in save_item.value.keys():
				if level_id in LEVEL_PRUNE_LIST_3776:
					save_item.value.erase(level_id)
		"chat_history":
			var history_items: Dictionary = save_item.value.get("history_items", {})
			for chat_id in history_items.keys():
				if chat_id in CHAT_PRUNE_LIST_3776:
					history_items.erase(chat_id)
			
	return save_item


func _upgrade_375c(old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"finished_levels":
			# Save data prior to 375c had a bug where successful levels weren't recorded as finished levels. We locate
			# the successful levels entries and copy them over to the finished levels to fill in the gaps.
			
			# locate the successful_levels entries
			var successful_levels := {}
			for old_save_item in old_save_items:
				if old_save_item.get("type", "") == "successful_levels":
					successful_levels = old_save_item.value
			
			# copy over any missing successful_levels entries to finished_levels
			for key in successful_levels:
				if not save_item.value.has(key):
					save_item.value[key] = successful_levels[key]
		
		"level_history":
			# Older versions of the sandbox levels would give the player an unranked grade instead of a master rank.
			if save_item.key.begins_with("practice/sandbox_"):
				for level_history_entry in save_item.value:
					level_history_entry["score_rank"] = 0.0
	return save_item


func _upgrade_36c3(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"creature_library":
			if save_item.value.has("#player#"):
				var creature_def := CreatureDef.new()
				creature_def.from_json_dict(save_item.value["#player#"])
				save_item.value["#player#"] = creature_def.to_json_dict()
	return save_item


func _upgrade_27bb(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"career":
			save_item.value["best_distance_travelled"] = save_item.value.get("max_distance_travelled", 0)
			save_item.value.erase("max_distance_travelled")
	return save_item


func _upgrade_2783(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


func _upgrade_2743(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"chat_history":
			_replace_chat_history_prefixes_for_2743(save_item.value)
		"creature_library":
			_replace_fatness_keys_for_2743(save_item.value.get("fatnesses", {}))
	return save_item


## Replace chat keys like 'chat/richie/filler_000' with 'creature/richie/filler_000'
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


## Replace hyphens with underscores in fatness keys like '#filler-033#'
func _replace_fatness_keys_for_2743(dict: Dictionary) -> void:
	for key in dict.keys():
		var new_key: String = key
		if "-" in new_key:
			# some older keys have hyphens
			new_key = StringUtils.hyphens_to_underscores(new_key)
			
			# if two keys conflict, take the higher value of the two
			dict[new_key] = max(dict[key], dict.get(new_key, 0))
			dict.erase(key)


func _upgrade_24cc(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


func _upgrade_245b(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


func _upgrade_1b3c(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			save_item.key = _upgrade_1b3c_level_id(save_item.key)
		"successful_levels", "finished_levels":
			var new_levels := {}
			var levels: Dictionary = save_item.value
			for level_id in levels:
				var new_level_id := _upgrade_1b3c_level_id(level_id)
				new_levels[new_level_id] = levels[level_id]
			save_item.value = new_levels
	return save_item


func _upgrade_1b3c_level_id(value: String) -> String:
	var new_value := value
	if value.begins_with("practice/survival_"):
		new_value = "practice/marathon_%s" % [value.trim_prefix("practice/survival_")]
	return new_value


func _upgrade_19c5(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"level_history":
			save_item.key = _upgrade_199c_level_id(save_item.key)
		"successful_levels", "finished_levels":
			var new_levels := {}
			var levels: Dictionary = save_item.value
			for level_id in levels:
				var new_level_id := _upgrade_199c_level_id(level_id)
				new_levels[new_level_id] = levels[level_id]
			save_item.value = new_levels
	return save_item


func _upgrade_199c(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"scenario_history":
			save_item.type = "level_history"
		"successful_scenarios":
			save_item.type = "successful_levels"
		"finished_scenarios":
			save_item.type = "finished_levels"
	return save_item


func _upgrade_199c_level_id(value: String) -> String:
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


func _upgrade_1922(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


func _upgrade_1682(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


func _upgrade_163e(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
	match save_item.type:
		"scenario-history":
			for rank_result_obj in save_item.value:
				var rank_result_dict: Dictionary = rank_result_obj
				if rank_result_dict.get("lost", true):
					rank_result_dict["success"] = false
	return save_item


func _upgrade_15d2(_old_save_items: Array, save_item: SaveItem) -> SaveItem:
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


## Adds a 'success' key for a RankResult if the player met a target score and didn't lose.
##
## Provides backwards compatibility with 15d2, which did not include 'success' keys in rank results.
func _append_score_success_for_15d2(save_item: SaveItem, target_score: int) -> void:
	for rank_result_obj in save_item.value:
		var rank_result_dict: Dictionary = rank_result_obj
		rank_result_dict["success"] = not rank_result_dict.get("lost", true) \
				and rank_result_dict.get("score", 0) >= target_score


## Adds a 'success' key for a RankResult if the player met a target time and didn't lose
##
## Provides backwards compatibility with 15d2, which did not include 'success' keys in rank results.
func _append_time_success_for_15d2(save_item: SaveItem, target_time: float) -> void:
	for rank_result_obj in save_item.value:
		var rank_result_dict: Dictionary = rank_result_obj
		rank_result_dict["success"] = not rank_result_dict.get("lost", true) \
				and rank_result_dict.get("seconds", 0.0) <= target_time
