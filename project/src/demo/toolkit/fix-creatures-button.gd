extends Button
## Upgrades old creatures to the newest format.
##
## Recursively searches for creatures, upgrading them if they are out of date.

## directories containing creatures which should be upgraded
const CREATURE_DIRS := ["res://assets/main/creatures", "res://assets/test/secondary-creatures"]

export (NodePath) var output_label_path: NodePath

## string creature paths which have been successfully converted to the newest version
var _converted := []

## label for outputting messages to the user
onready var _output_label: Label = get_node(output_label_path)

## Upgrades all creatures to the newest version.
func _upgrade_creatures() -> void:
	_converted.clear()
	
	var creature_paths := _find_creature_paths()
	for creature_path in creature_paths:
		_upgrade_creature(creature_path)
	
	if _converted:
		_output_label.text = "Upgraded %d creatures to settings version %s." \
				% [_converted.size(), Creatures.CREATURE_DATA_VERSION]
	else:
		_output_label.text = "No creatures required upgrading."


## Upgrades a creature to the newest version.
##
## Parameters:
## 	'path': Path to a json resource containing creature data to upgrade.
func _upgrade_creature(path: String) -> void:
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	if old_json.get("version") != Creatures.CREATURE_DATA_VERSION:
		# converting the json into a CreatureDef and back upgrades the json
		var creature_def := CreatureDef.new()
		creature_def.from_json_dict(old_json)
		var new_json := creature_def.to_json_dict()
		
		var new_text := Utils.print_json(new_json)
		FileUtils.write_file(path, new_text)
		_converted.append(path)


## Returns a list of all creature paths within 'CREATURE_DIRS', performing a tree traversal.
##
## Returns:
## 	List of string paths to json resources containing creature data to upgrade.
func _find_creature_paths() -> Array:
	var result := []
	
	# directories remaining to be traversed
	var dir_queue := CREATURE_DIRS.duplicate()
	
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
	_upgrade_creatures()
