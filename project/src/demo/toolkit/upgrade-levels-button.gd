extends Button
"""
Upgrades old levels to the newest format.

Recursively searches for levels, upgrading them if they are out of date.
"""

# directories containing levels which should be upgraded
const LEVEL_DIRS := ["res://assets/main/puzzle/levels"]

export (NodePath) var output_label_path: NodePath

var _upgrader := LevelSettingsUpgrader.new()

# string level paths which have been successfully converted to the newest version
var _converted := []

# label for outputting messages to the user
onready var _output_label: Label = get_node(output_label_path)

"""
Upgrades all levels to the newest version.
"""
func _upgrade_levels() -> void:
	_converted.clear()
	
	var level_paths := _find_level_paths()
	for level_path in level_paths:
		_upgrade_settings(level_path)
	
	if _converted:
		_output_label.text = "Upgraded %d levels to settings version %s." % [_converted.size(), Levels.LEVEL_DATA_VERSION]
	else:
		_output_label.text = "No levels required upgrading."


"""
Upgrades a level to the newest version.

Parameters:
	'path': Path to a json resource containing level data to upgrade.
"""
func _upgrade_settings(path: String) -> void:
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	if _upgrader.needs_upgrade(old_json):
		var new_json := _upgrader.upgrade(old_json)
		var new_text := Utils.print_json(new_json)
		FileUtils.write_file(path, new_text)
		_converted.append(path)


"""
Recursively searches for levels to upgrade.

Returns:
	List of string paths to json resources containing level data to upgrade.
"""
func _find_level_paths() -> Array:
	var result := []
	
	# directories remaining to be traversed
	var dir_queue := LEVEL_DIRS.duplicate()
	
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


func _on_pressed() -> void:
	_upgrade_levels()
