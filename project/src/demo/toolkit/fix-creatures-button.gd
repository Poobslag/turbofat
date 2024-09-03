extends ReleaseToolButton
## Fixes and reports problems with creature files.
##
## Recursively searches for creatures, upgrading them if they are out of date.
##
## Reports any creature files which are in the wrong directory.

## directories containing creatures which should be upgraded
const CREATURE_DIRS := ["res://assets/main/creatures", "res://assets/test/nonstory-creatures"]

## string creature paths which have been successfully converted to the newest version
var _converted := []

## string creature paths which have been recolored
var _recolored := []

var _problem_count := 0

func run() -> void:
	_problem_count = 0
	
	_upgrade_creatures()
	_report_story_creatures()
	_report_population_creatures()
	_report_creatures_without_id()
	_recolor_creatures()
	
	if _problem_count == 0:
		_output.add_line("No creature files have problems.")


## Recursively searches for creatures, upgrading them if they are out of date.
func _upgrade_creatures() -> void:
	_converted.clear()
	
	var creature_paths := _find_creature_paths()
	for creature_path in creature_paths:
		_upgrade_creature(creature_path)
	
	if _converted:
		_report_problem("Upgraded %d creatures to settings version %s." \
				% [_converted.size(), Creatures.CREATURE_DATA_VERSION])


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
	
	# jaco appears in the credits, even though they have no lines and no cutscenes
	move_to_nonstory_ids = Utils.subtract(move_to_nonstory_ids, ["jaco"])
	
	move_to_nonstory_ids.sort()
	if move_to_nonstory_ids:
		_report_problem("%s creatures should be moved from /story to /nonstory: %s" \
				% [move_to_nonstory_ids.size(), move_to_nonstory_ids])
	
	# get a list of creature ids from the /nonstory/ directory
	var nonstory_ids := _creature_ids_from_directory("res://assets/main/creatures/nonstory")
	
	# report any story creatures who are in our list of career creature ids
	var move_to_story_ids := Utils.intersection(nonstory_ids, career_creature_ids)
	if move_to_story_ids:
		_report_problem("%s creatures should be moved from /nonstory to /story: %s" \
				% [move_to_story_ids.size(), move_to_story_ids])


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
	var creature_defs := _creature_defs_from_directory(dir_string)
	for creature_def in creature_defs:
		result[creature_def.creature_id] = true
	return result.keys()


## Returns a list of creature defs in a directory.
func _creature_defs_from_directory(dir_string: String) -> Array:
	var result := []
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
			result.append(creature_def)
	dir.list_dir_end()
	return result


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
			_report_problem("Region '%s' has bad creature ids: %s" % [region.id, invalid_creature_ids.keys()])


## Reports any creature files without a creature id.
func _report_creatures_without_id() -> void:
	var missing_creature_ids := []
	
	var creature_defs := []
	creature_defs.append_array(_creature_defs_from_directory("res://assets/main/creatures/story"))
	creature_defs.append_array(_creature_defs_from_directory("res://assets/main/creatures/nonstory"))
	for creature_def in creature_defs:
		if creature_def.get("creature_id"):
			# creature has a creature id
			continue
		
		var identifier := ""
		if not identifier and creature_def.creature_name:
			identifier = creature_def.creature_name
		if not identifier and creature_def.creature_short_name:
			identifier = creature_def.creature_short_name
		if not identifier:
			identifier = "<unknown>"
		
		missing_creature_ids.append(identifier)
	
	if missing_creature_ids:
		_report_problem("Missing creature ids: %s" % [missing_creature_ids])


## Recolors the specified creature using the Creature Editor's color palettes.
func _recolor_creature(path: String) -> void:
	var color_change_count := 0
	var old_text := FileUtils.get_file_as_text(path)
	var old_json: Dictionary = parse_json(old_text)
	var creature_def := CreatureDef.new()
	creature_def.from_json_dict(old_json)
	var new_dna := creature_def.dna.duplicate()
	
	# Create an ordered list of all color properties. Move line_rgb and hair_rgb to the end, because they depend on
	# body_rgb
	var color_properties := CreatureEditorLibrary.COLOR_PRESETS_BY_COLOR_PROPERTY.keys()
	for color_property in ["line_rgb", "hair_rgb"]:
		color_properties.remove(color_properties.find(color_property))
		color_properties.append(color_property)
	
	for color_property in color_properties:
		var color_presets: Array = CreatureEditorLibrary.get_color_presets(new_dna, color_property)
		var dna_color: Color = _get_dna_color(new_dna, color_property)
		var closest_preset := _find_closest_preset(color_presets, dna_color)
		if closest_preset.to_html(false) != dna_color.to_html(false):
			color_change_count += 1
			_set_dna_color(new_dna, color_property, closest_preset)
	
	if color_change_count > 0:
		creature_def.dna = new_dna
		var new_json := creature_def.to_json_dict()
		var new_text := Utils.print_json(new_json)
		FileUtils.write_file(path, new_text)
		_recolored.append(path)


func _get_dna_color(dna: Dictionary, color_property: String) -> Color:
	var result: Color
	if color_property == "eye_rgb_0":
		result = Color(dna["eye_rgb"].split(" ")[0])
	elif color_property == "eye_rgb_1":
		result = Color(dna["eye_rgb"].split(" ")[1])
	else:
		result = Color(dna[color_property])
	return result


func _set_dna_color(dna: Dictionary, color_property: String, color: Color) -> void:
	if color_property == "eye_rgb_0":
		dna["eye_rgb"] = "%s %s" % [color.to_html(false), dna["eye_rgb"].split(" ")[1]]
	elif color_property == "eye_rgb_1":
		dna["eye_rgb"] = "%s %s" % [dna["eye_rgb"].split(" ")[0], color.to_html(false)]
	else:
		dna[color_property] = color.to_html(false)


func _find_closest_preset(color_presets: Array, target_color: Color) -> Color:
	var closest_preset: Color = color_presets[0]
	var closest_distance := 999999.0
	for color_preset in color_presets:
		var distance := Utils.color_distance_rgb(color_preset, target_color)
		if distance < closest_distance:
			closest_distance = distance
			closest_preset = color_preset
		
		if closest_preset.to_html(false) == target_color.to_html(false):
			break
	return closest_preset


## Recursively searches for creatures, recoloring them using the Creature Editor's color palettes.
func _recolor_creatures() -> void:
	_recolored.clear()
	
	var creature_paths := _find_creature_paths()
	for creature_path in creature_paths:
		_recolor_creature(creature_path)
	
	if _recolored:
		_report_problem("Recolored %d creatures." % [_recolored.size()])


func _report_problem(problem: String) -> void:
	_output.add_line(problem)
	_problem_count += 1
