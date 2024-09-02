extends Button
## Upgrades old levels to the newest format.
##
## Recursively searches for levels, upgrading them if they are out of date.

## directories containing levels which should be upgraded
const LEVEL_DIRS := [
	"res://assets/main/puzzle/levels",
	"res://assets/demo/puzzle/levels",
	"res://assets/demo/puzzle/levels/retired",
]

const CAREER_LEVEL_DIRS := ["res://assets/main/puzzle/levels/career"]

export (NodePath) var output_label_path: NodePath

var _upgrader := LevelSettingsUpgrader.new()

## string level paths which have been successfully converted to the newest version
var _converted := []

## label for outputting messages to the user
onready var _output_label: Label = get_node(output_label_path)

## Upgrades all levels to the newest version.
func _upgrade_levels() -> void:
	_converted.clear()
	
	var level_paths := _find_level_paths(LEVEL_DIRS)
	for level_path in level_paths:
		_upgrade_settings(level_path)
	
	if _converted:
		_output_label.add_line("Upgraded %d levels to settings version %s." % [_converted.size(),
				Levels.LEVEL_DATA_VERSION])


## Upgrades a level to the newest version.
##
## Parameters:
## 	'path': Path to a json resource containing level data to upgrade.
func _upgrade_settings(path: String) -> void:
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	
	if _upgrader.needs_upgrade(old_json):
		var level_id := LevelSettings.level_key_from_path(path)
		# immediately parse and rewrite the level; LevelEditor will behave strangely with older level formats
		var settings := LevelSettings.new()
		settings.load_from_text(level_id, old_text)
		var new_text := Utils.print_json(settings.to_json_dict())
		FileUtils.write_file(path, new_text)
		_converted.append(path)


## Returns a list of all level paths within 'LEVEL_DIRS', performing a tree traversal.
##
## Returns:
## 	List of string paths to json resources containing level data to upgrade.
func _find_level_paths(dirs: Array) -> Array:
	var result := []
	
	# directories remaining to be traversed
	var dir_queue := dirs.duplicate()
	
	# recursively look for json files under the specified paths
	var dir: Directory
	var file: String
	while true:
		if file:
			var resource_path := "%s/%s" % [dir.get_current_dir(), file.get_file()]
			if file.ends_with(".json"):
				result.append(resource_path)
			elif dir.current_is_dir():
				dir_queue.append(resource_path)
		else:
			if dir:
				dir.list_dir_end()
			if dir_queue.empty():
				break
			# there are more directories. open the next directory
			dir = Directory.new()
			dir.open(dir_queue.pop_front())
			dir.list_dir_begin(true, true)
		file = dir.get_next()
	
	return result


## Reports any level ids in career-regions.json which don't have corresponding files
func _report_invalid_career_levels() -> void:
	var level_keys_in_career_regions := CareerLevelLibrary.all_level_ids()
	
	var invalid_level_keys := {}
	for level_key in level_keys_in_career_regions:
		var text := FileUtils.get_file_as_text(LevelSettings.path_from_level_key(level_key))
		if not text:
			invalid_level_keys[level_key] = true
	
	if invalid_level_keys:
		var keys_to_print := invalid_level_keys.keys()
		keys_to_print.sort()
		_output_label.add_line("Invalid levels in career regions: %s" % [keys_to_print])


## Reports any regions in career-regions.json with missing or invalid music ids
func _report_invalid_career_music() -> void:
	var invalid_region_ids := {}
	
	for region in CareerLevelLibrary.regions:
		if region.music.menu_music_id == null:
			push_warning("%s - menu_music_id is empty" % [region.id])
			invalid_region_ids[region.id] = true
		elif MusicPlayer.bgm_for_id(region.music.menu_music_id) == null:
			push_warning("%s - invalid menu_music_id: %s" % [region.id, region.music.menu_music_id])
			invalid_region_ids[region.id] = true
		
		if not region.music.puzzle_music_ids:
			push_warning("%s - puzzle_music_ids is empty" % [region.id])
			invalid_region_ids[region.id] = true
		else:
			for puzzle_music_id in region.music.puzzle_music_ids:
				if MusicPlayer.bgm_for_id(puzzle_music_id) == null:
					push_warning("%s - invalid puzzle_music_id: %s" % [region.id, puzzle_music_id])
					invalid_region_ids[region.id] = true
	
	if invalid_region_ids:
		var keys_to_print := invalid_region_ids.keys()
		keys_to_print.sort()
		_output_label.add_line("Invalid music in career regions: %s" % [keys_to_print])


## Reports any levels in CAREER_LEVEL_DIRS which are not actually available in career mode.
func _report_unused_career_levels() -> void:
	var level_keys_in_dir := []
	var level_paths_in_dir := _find_level_paths(CAREER_LEVEL_DIRS)
	for level_path in level_paths_in_dir:
		level_keys_in_dir.append(LevelSettings.level_key_from_path(level_path))
	
	var level_keys_in_career_regions := CareerLevelLibrary.all_level_ids()
	
	var level_keys_not_in_career_regions := Utils.subtract(level_keys_in_dir, level_keys_in_career_regions)
	level_keys_not_in_career_regions.sort()
	
	if level_keys_not_in_career_regions:
		_output_label.add_line("Level keys not in career regions: %s" % [level_keys_not_in_career_regions])


## Reports any levels with missing or invalid 'icons' data.
func _report_level_icons() -> void:
	var missing_icons_level_ids := []
	var bad_icons := []
	
	var level_ids := []
	level_ids.append_array(CareerLevelLibrary.all_level_ids())
	level_ids.append_array(OtherLevelLibrary.all_level_ids())
	
	for level_id in level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		
		if level_settings.other.tutorial:
			pass
		elif not level_settings.icons:
			missing_icons_level_ids.append(level_id)
	
	for level_id in level_ids:
		var text := FileUtils.get_file_as_text(LevelSettings.path_from_level_key(level_id))
		var json: Dictionary = parse_json(text)
		for icon_string in json.get("icons", []):
			if not LevelSettings.LevelIcon.has(icon_string.to_upper()):
				bad_icons.append("%s/%s" % [level_id, icon_string])
	
	if missing_icons_level_ids:
		_output_label.add_line("Levels missing icons: %s" % [PoolStringArray(missing_icons_level_ids).join(", ")])
	
	if bad_icons:
		_output_label.add_line("Levels with bad icons: %s" % [PoolStringArray(bad_icons).join(", ")])


## Reports any unusual show_rank and hide_rank settings
func _report_bad_show_rank() -> void:
	var bad_level_id_set := {}
	
	for level_id in CareerLevelLibrary.all_level_ids():
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		
		if level_settings.rank.show_boxes_rank in [RankRules.ShowRank.SHOW, RankRules.ShowRank.DEFAULT]:
			if level_settings.rank.box_factor < 0.1:
				push_warning("%s - show_boxes_rank enabled with box_factor of %s"
						% [level_id, level_settings.rank.box_factor])
				bad_level_id_set[level_id] = true
		
		if level_settings.rank.show_combos_rank in [RankRules.ShowRank.SHOW, RankRules.ShowRank.DEFAULT]:
			if level_settings.rank.combo_factor < 0.1:
				push_warning("%s - show_combos_rank enabled with combo_factor of %s"
						% [level_id, level_settings.rank.box_factor])
				bad_level_id_set[level_id] = true
			if level_settings.combo_break.pieces == ComboBreakRules.UNLIMITED_PIECES:
				push_warning("%s - show_combos_rank enabled with combo_break.pieces == %s"
						% [level_id, level_settings.combo_break.pieces])
				bad_level_id_set[level_id] = true
		
		if not level_settings.rank.show_pickups_rank in [RankRules.ShowRank.SHOW]:
			if level_settings.rank.master_pickup_score_per_line > 1.0:
				push_warning("%s - show_pickups_rank disabled with master_pickup_score_per_line of %s"
						% [level_id, level_settings.rank.master_pickup_score_per_line])
	
	var bad_level_ids := bad_level_id_set.keys()
	bad_level_ids.sort()
	if bad_level_ids:
		_output_label.add_line("Level keys with bad show_rank settings: %s" % [bad_level_ids])


## Reports bad SteamAchievement achievement_ids, region_ids, level_ids
func _report_bad_achievements() -> void:
	var invalid_achievement_properties := []
	for achievement in SteamAchievements.get_achievements():
		if not achievement.achievement_id:
			invalid_achievement_properties.append("%s/%s=%s" % [achievement.name, "achievement_id", ""])
		if achievement.get("region_id"):
			var region_id: String = achievement.get("region_id")
			if not CareerLevelLibrary.region_for_id(region_id):
				invalid_achievement_properties.append("%s/%s=%s" % [achievement.name, "region_id", region_id])
		if achievement.get("level_id"):
			var level_id: String = achievement.get("level_id")
			if level_id.find("-") \
					or not LevelSettings.level_exists_with_key(level_id):
				invalid_achievement_properties.append("%s/%s=%s" % [achievement.name, "level_id", level_id])


## Alphabetizes the levels in 'career-regions.json'
func _alphabetize_career_levels() -> void:
	var sorted_region_ids := {}
	
	var old_text := FileUtils.get_file_as_text(CareerLevelLibrary.DEFAULT_REGIONS_PATH)
	var old_json: Dictionary = parse_json(old_text)
	var new_json := old_json.duplicate(true)
	for region in new_json.get("regions", []):
		var old_levels: Array = region.get("levels", [])
		var new_levels := old_levels.duplicate()
		new_levels.sort_custom(self, "_compare_by_id")
		if not new_levels == old_levels:
			sorted_region_ids[region.get("id", "(unknown)")] = true
			region["levels"] = new_levels
	
	if sorted_region_ids:
		var new_text := Utils.print_json(new_json)
		FileUtils.write_file(CareerLevelLibrary.DEFAULT_REGIONS_PATH, new_text)
		_output_label.add_line("Sorted career level ids: %s" % [PoolStringArray(sorted_region_ids.keys()).join(", ")])


func _compare_by_id(obj0: Dictionary, obj1: Dictionary) -> bool:
	return obj0.get("id") < obj1.get("id")


func _on_pressed() -> void:
	_output_label.text = ""
	_upgrade_levels()
	_report_invalid_career_levels()
	_report_invalid_career_music()
	_report_unused_career_levels()
	_report_level_icons()
	_report_bad_show_rank()
	_report_bad_achievements()
	_alphabetize_career_levels()
	if not _output_label.text:
		_output_label.text = "No level files have problems."
