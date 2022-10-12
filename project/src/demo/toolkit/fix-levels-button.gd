extends Button
## Upgrades old levels to the newest format.
##
## Recursively searches for levels, upgrading them if they are out of date.

## directories containing levels which should be upgraded
const LEVEL_DIRS := ["res://assets/main/puzzle/levels"]
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
		if _output_label.text:
			_output_label.text += "\n"
		_output_label.text += "Upgraded %d levels to settings version %s." % [_converted.size(), Levels.LEVEL_DATA_VERSION]


## Upgrades a level to the newest version.
##
## Parameters:
## 	'path': Path to a json resource containing level data to upgrade.
func _upgrade_settings(path: String) -> void:
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	if _upgrader.needs_upgrade(old_json):
		var new_json := _upgrader.upgrade(old_json)
		var new_text := Utils.print_json(new_json)
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
		if _output_label.text:
			_output_label.text += "\n"
		_output_label.text += "Level keys not in career regions: %s" % [level_keys_not_in_career_regions]


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
		if _output_label.text:
			_output_label.text += "\n"
		_output_label.text += "Sorted career level ids: %s" \
			% [PoolStringArray(sorted_region_ids.keys()).join(", ")]


func _compare_by_id(obj0: Dictionary, obj1: Dictionary) -> bool:
	return obj0.get("id") < obj1.get("id")


func _on_pressed() -> void:
	_output_label.text = ""
	_upgrade_levels()
	_report_unused_career_levels()
	_alphabetize_career_levels()
	if not _output_label.text:
		_output_label.text = "No level files have problems."
