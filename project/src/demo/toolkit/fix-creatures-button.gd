extends Button
## Fixes and reports problems with creature files.
##
## Recursively searches for creatures, upgrading them if they are out of date.
##
## Reports any creature files which are in the wrong directory.

## directories containing creatures which should be upgraded
const CREATURE_DIRS := ["res://assets/main/creatures", "res://assets/test/nonstory-creatures"]

export (NodePath) var output_label_path: NodePath

## string creature paths which have been successfully converted to the newest version
var _converted := []

## label for outputting messages to the user
onready var _output_label: Label = get_node(output_label_path)

## Recursively searches for creatures, upgrading them if they are out of date.
func _upgrade_creatures() -> void:
	_converted.clear()
	
	var creature_paths := _find_creature_paths()
	for creature_path in creature_paths:
		_upgrade_creature(creature_path)
	
	if _output_label.text:
		_output_label.text += "\n"
	
	if _converted:
		_output_label.text += "Upgraded %d creatures to settings version %s." \
				% [_converted.size(), Creatures.CREATURE_DATA_VERSION]


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


## Reports any creature files which are in the wrong directory.
func _report_story_creatures() -> void:
	var career_creature_ids := _career_creature_ids()
	
	# get a list of creature ids from the /story/ directory
	var story_ids := _creature_ids_from_directory("res://assets/main/creatures/story")
	
	# report any story creatures who are not in our list of career creature ids
	var move_to_nonstory_ids := Utils.subtract(story_ids, career_creature_ids)
	move_to_nonstory_ids.sort()
	if move_to_nonstory_ids:
		if _output_label.text:
			_output_label.text += "\n"
		_output_label.text += "%s creatures should be moved from /story to /nonstory: %s" \
				% [move_to_nonstory_ids.size(), move_to_nonstory_ids]
	
	# get a list of creature ids from the /nonstory/ directory
	var nonstory_ids := _creature_ids_from_directory("res://assets/main/creatures/nonstory")
	
	# report any story creatures who are in our list of career creature ids
	var move_to_story_ids := Utils.intersection(nonstory_ids, career_creature_ids)
	if move_to_story_ids:
		if _output_label.text:
			_output_label.text += "\n"
		_output_label.text += "%s creatures should be moved from /nonstory to /story: %s" \
				% [move_to_story_ids.size(), move_to_story_ids]


## Returns a list of creature ids which appear in career mode's story.
func _career_creature_ids() -> Array:
	var result := {}
	# get a list of 'story creature ids' from the cutscenes
	for path in CareerCutsceneLibrary.find_career_cutscene_resource_paths():
		var chat_tree := ChatLibrary.chat_tree_from_file(path)
		for creature_id in chat_tree.creature_ids:
			result[creature_id] = true
	return result.keys()


## Returns a list of creature ids in all creature files in a directory.
func _creature_ids_from_directory(dir_string: String) -> Array:
	var result := {}
	var dir := Directory.new()
	dir.open(dir_string)
	dir.list_dir_begin(true, true)
	while true:
		var file := dir.get_next()
		if not file:
			break
		else:
			var creature_def: CreatureDef = CreatureDef.new()
			creature_def = creature_def.from_json_path("%s/%s" % [dir.get_current_dir(), file.get_file()])
			result[creature_def.creature_id] = true
	dir.list_dir_end()
	return result.keys()


## Reports any career regions whose population has bad creature ids.
func _report_population_creatures() -> void:
	for region_obj in CareerLevelLibrary.regions:
		var invalid_creature_ids := {}
		var region: CareerRegion = region_obj
		var appearances := []
		appearances.append_array(region.population.chefs)
		appearances.append_array(region.population.customers)
		appearances.append_array(region.population.observers)
		for appearance in appearances:
			if PlayerData.creature_library.get_creature_def(appearance.id) == null:
				invalid_creature_ids[appearance.id] = true
		if invalid_creature_ids:
			if _output_label.text:
				_output_label.text += "\n"
			_output_label.text += "Region '%s' has bad creature ids: %s" % [region.id, invalid_creature_ids.keys()]


func _on_pressed() -> void:
	_output_label.text = ""
	_upgrade_creatures()
	_report_story_creatures()
	_report_population_creatures()
	if not _output_label.text:
		_output_label.text = "No creature files have problems."
