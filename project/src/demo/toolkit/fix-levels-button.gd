extends ReleaseToolButton
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

var _upgrader := LevelSettingsUpgrader.new()

## string level paths which have been successfully converted to the newest version
var _converted := []
var _problem_count := 0

func run() -> void:
	_problem_count = 0
	
	_upgrade_levels()
	
	_soften_intro_levels("lemon", "S-", 0.64)
	_soften_intro_levels("lemon_2", "S-", 0.8)
	_round_goals_for_levels()
	
	_report_invalid_career_levels()
	_report_invalid_career_music()
	_report_unused_career_levels()
	_report_level_icons()
	_report_vertical_line_piece_levels()
	_alphabetize_career_levels()
	if _problem_count == 0:
		_output.add_line("No level files have problems.")


## Upgrades all levels to the newest version.
func _upgrade_levels() -> void:
	_converted.clear()
	
	var level_paths := _find_level_paths(LEVEL_DIRS)
	for level_path in level_paths:
		_upgrade_settings(level_path)
	
	if _converted:
		_report_problem("Upgraded %d levels to settings version %s." % [_converted.size(),
				Levels.LEVEL_DATA_VERSION])


## Rounds all level master rank goals to nice numbers.
func _round_goals_for_levels() -> void:
	var rounded_level_id_set := {}
	
	var level_paths := _find_level_paths(LEVEL_DIRS)
	for level_path in level_paths:
		var did_round := _round_goals_for_level(level_path)
		if did_round:
			rounded_level_id_set[level_path] = true
	
	if rounded_level_id_set:
		_report_problem("Rounded %d level goals." % [rounded_level_id_set.size()])


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


func _round_goals_for_level(path: String) -> bool:
	var did_round := false
	
	# sanitize time/score goals by rounding and clamping to reasonable values
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	var level_id := LevelSettings.level_key_from_path(path)
	var settings := LevelSettings.new()
	settings.load_from_text(level_id, old_text)
	for grade in settings.rank.rank_criteria.thresholds_by_grade:
		var old_threshold: int = settings.rank.rank_criteria.thresholds_by_grade[grade]
		var new_threshold: int = settings.rank.rank_criteria.sanitize_threshold(old_threshold)
		if old_threshold != new_threshold:
			did_round = true
			settings.rank.rank_criteria.thresholds_by_grade[grade] = new_threshold
	
	# sanitize durations by rounding and clamping to reasonable values
	var old_duration := settings.rank.duration
	var new_duration := settings.rank.rank_criteria.sanitize_threshold(old_duration)
	if old_duration != new_duration:
		did_round = true
		settings.rank.duration = new_duration
	
	if did_round:
		var new_text := Utils.print_json(settings.to_json_dict())
		FileUtils.write_file(path, new_text)
	return did_round


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
		_report_problem("Invalid levels in career regions: %s" % [keys_to_print])


## Reports any regions in career-regions.json with missing or invalid music track ids
func _report_invalid_career_music() -> void:
	var invalid_region_ids := {}
	
	for region in CareerLevelLibrary.regions:
		if region.music.menu_track_id == null:
			push_warning("%s - menu_track_id is empty" % [region.id])
			invalid_region_ids[region.id] = true
		elif MusicPlayer.track_for_id(region.music.menu_track_id) == null:
			push_warning("%s - invalid menu_track_id: %s" % [region.id, region.music.menu_track_id])
			invalid_region_ids[region.id] = true
		
		if not region.music.puzzle_track_ids:
			push_warning("%s - puzzle_track_ids is empty" % [region.id])
			invalid_region_ids[region.id] = true
		else:
			for puzzle_track_id in region.music.puzzle_track_ids:
				if MusicPlayer.track_for_id(puzzle_track_id) == null:
					push_warning("%s - invalid puzzle_track_id: %s" % [region.id, puzzle_track_id])
					invalid_region_ids[region.id] = true
	
	if invalid_region_ids:
		var keys_to_print := invalid_region_ids.keys()
		keys_to_print.sort()
		_report_problem("Invalid music in career regions: %s" % [keys_to_print])


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
		_report_problem("Level keys not in career regions: %s" % [level_keys_not_in_career_regions])


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
		_report_problem("Levels missing icons: %s" % [PoolStringArray(missing_icons_level_ids).join(", ")])
	
	if bad_icons:
		_report_problem("Levels with bad icons: %s" % [PoolStringArray(bad_icons).join(", ")])


## Report levels where line pieces will cause a top out.
##
## Levels like 'Carrot Alley' were frustrating for players using the line piece cheat, so we made those levels
## automatically rotate line pieces. Any level which blocks line pieces should rotate them automatically.
func _report_vertical_line_piece_levels() -> void:
	var level_ids := []
	level_ids.append_array(CareerLevelLibrary.all_level_ids())
	level_ids.append_array(OtherLevelLibrary.all_level_ids())
	
	# Cells at the top center of the playfield. Technically only four of these will cause a top out, but we check for
	# all five.
	var top_cells := [
		Vector2(2, 3), Vector2(3, 3), Vector2(4, 3), Vector2(5, 3), Vector2(6, 3),
	]
	
	var bad_line_piece_level_ids := []
	for level_id in level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		var occupied_top_cells := Utils.intersection(
				level_settings.tiles.blocks_start().block_tiles.keys(), top_cells)
		if occupied_top_cells and not level_settings.other.vertical_line_pieces:
			bad_line_piece_level_ids.append(level_id)
	
	if bad_line_piece_level_ids:
		_report_problem("Levels which need 'vertical_line_pieces' setting: %s"
				% [PoolStringArray(bad_line_piece_level_ids).join(", ")])


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
		_report_problem("Sorted career level ids: %s" % [PoolStringArray(sorted_region_ids.keys()).join(", ")])


## Updates the grade criteria for the specified intro levels, to make the grade easier to attain.
##
## For levels in the first two regions, we don't want players to get discouraged with bad grades so we make it easier
## to get 'S' ranks for the achievements. This algorithm takes the scoring requirements for an 'S' rank and decreases
## them by a factor.
##
## Parameters:
## 	'region_id': career region id
##
## 	'grade': grade whose requirements should be made easier
##
## 	'ease_factor': A number in the range (0, 1.0) for how much to decrease the scoring requirements. A small number
## 		like 0.1 represents a large decrease, a large number like  0.9 represents a small decrease.
func _soften_intro_levels(region_id: String, grade: String, ease_factor: float) -> void:
	var softened_level_id_set := {}
	
	var region: CareerRegion = CareerLevelLibrary.region_for_id(region_id)
	var level_ids := {}
	for career_level in region.levels:
		level_ids[career_level.level_id] = true
	if region.boss_level:
		level_ids[region.boss_level.level_id] = true
	if region.intro_level:
		level_ids[region.intro_level.level_id] = true
	for level_id in level_ids:
		var settings := LevelSettings.new()
		settings.load_from_resource(level_id)
		
		var level_needs_softening := false
		if not settings.rank.rank_criteria.thresholds_by_grade.has(grade):
			level_needs_softening = true
		else:
			var old_goal: int = settings.rank.rank_criteria.thresholds_by_grade[grade]
			settings.rank.rank_criteria.soften(grade, ease_factor)
			var new_goal: int = settings.rank.rank_criteria.thresholds_by_grade[grade]
			if old_goal != new_goal:
				level_needs_softening = true
		
		if level_needs_softening:
			softened_level_id_set[level_id] = true
			settings.rank.rank_criteria.soften(grade, ease_factor)
			var new_text := Utils.print_json(settings.to_json_dict())
			FileUtils.write_file(LevelSettings.path_from_level_key(level_id), new_text)
	
	var softened_level_ids := softened_level_id_set.keys()
	softened_level_ids.sort()
	if softened_level_ids:
		_report_problem("Softened %s levels: %s" % [softened_level_ids.size(), softened_level_ids])


func _compare_by_id(obj0: Dictionary, obj1: Dictionary) -> bool:
	return obj0.get("id") < obj1.get("id")


func _report_problem(problem: String) -> void:
	_output.add_line(problem)
	_problem_count += 1
