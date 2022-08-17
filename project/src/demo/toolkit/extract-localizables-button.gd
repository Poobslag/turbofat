extends Button
## Extracts localizable strings from levels and chats as a part of the localization process.
##
## The pybabel tool creates a PO template file from our script and scene files. However, level and chat data is stored
## in a proprietary JSON format which pybabel doesn't understand. This demo looks at all levels and chat in the game
## and exports any localizable strings into a format accessible by pybabel.

## the file where we write the localizable strings
const OUTPUT_PATH := "res://assets/main/locale/localizables-extracted.py"
const SCANCODE_OUTPUT_PATH := "res://assets/main/locale/localizables-scancodes.py"

export (NodePath) var output_label_path: NodePath

## localizable strings extracted from levels and chats
var _localizables := []

## localizable strings extracted from scancodes (input keys)
var _scancode_localizables := []

## label for outputting messages to the user
onready var _output_label := get_node(output_label_path)

## Extracts localizable strings from levels and chats and writes them to a file.
func _extract_and_write_localizables() -> void:
	_localizables.clear()
	_scancode_localizables.clear()
	
	# Temporarily set the locale to 'en' to ensure we extract english keys
	var old_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	
	_extract_localizables_from_career_regions()
	_extract_localizables_from_levels()
	_extract_localizables_from_chat_trees()
	_extract_localizables_from_scancode_strings()
	_write_localizables(OUTPUT_PATH, _localizables)
	_write_localizables(SCANCODE_OUTPUT_PATH, _scancode_localizables)
	
	TranslationServer.set_locale(old_locale)
	_output_label.text = "Wrote %s strings to %s, %s." % [
			StringUtils.comma_sep(_localizables.size() + _scancode_localizables.size()),
			OUTPUT_PATH, SCANCODE_OUTPUT_PATH]


## Extracts localizable strings from regions in career mode.
func _extract_localizables_from_career_regions() -> void:
	for region_obj in CareerLevelLibrary.regions:
		var region: CareerRegion = region_obj
		_localizables.append(region.name)
		_localizables.append(region.description)
	for region_obj in OtherLevelLibrary.regions:
		var region: OtherRegion = region_obj
		_localizables.append(region.name)
		_localizables.append(region.description)


## Extracts localizable strings from worlds/levels and adds them to the in-memory list of localizables.
func _extract_localizables_from_levels() -> void:
	# Create a sorted list of all level IDs
	var level_id_set := {}
	for level_id in CareerLevelLibrary.all_level_ids():
		level_id_set[level_id] = true
	for level_id in OtherLevelLibrary.all_level_ids():
		level_id_set[level_id] = true
	var level_ids := level_id_set.keys()
	level_ids.sort()
	
	for level_id in level_ids:
		var level_settings := LevelSettings.new()
		level_settings.load_from_resource(level_id)
		
		# extract level's title and description as localizables
		_localizables.append(level_settings.title)
		_localizables.append(level_settings.description)


## Extracts localizable strings from all cutscenes/chats and adds them to the in-memory list of localizables.
func _extract_localizables_from_chat_trees() -> void:
	for path in CareerCutsceneLibrary.find_career_cutscene_resource_paths():
		var chat_tree := ChatLibrary.chat_tree_from_file(path)
		for event_sequence in chat_tree.events.values():
			for event_obj in event_sequence:
				_extract_localizables_from_chat_event(event_obj)


## Extracts localizable strings from a chat event and adds them to the in-memory list of localizables.
##
## This includes the chat event's dialog, branches, and meta items like restaurant names the player can choose.
func _extract_localizables_from_chat_event(event: ChatEvent) -> void:
	# append a line of chat as a localizable
	_localizables.append(event.text)
	
	# Append the list of player-selected chat choices as localizables.
	if event.link_texts.size() == 1:
		# We do not localize chat which only has one choice because the player is not prompted.
		pass
	else:
		for link_text in event.link_texts:
			_localizables.append(link_text)
	
	# append player choices such as restaurant names as localizables.
	for meta_item in event.meta:
		var tokens: Array = meta_item.split(" ")
		var args: Array = tokens.slice(1, tokens.size())
		if tokens:
			match tokens[0]:
				"set_phrase":
					if args.size() < 2:
						push_warning("Invalid token count for set_phrase call. Expected 2 but was %s"
								% [args.size()])
					
					_localizables.append(PoolStringArray(args.slice(1, args.size())).join(" "))
				"default_phrase":
					if args.size() < 2:
						push_warning("Invalid token count for default_phrase call. Expected 2 but was %s"
								% [args.size()])
					
					_localizables.append(PoolStringArray(args.slice(1, args.size())).join(" "))


## Extract localizables from OS.get_scancode_string()
##
## This is a workaround for Godot #4140 (https://github.com/godotengine/godot/issues/4140). Because Godot does not
## offer a way to localize scancode strings, we must extract and localize them ourselves.
func _extract_localizables_from_scancode_strings() -> void:
	# ascii printable characters: space, comma, period, slash...
	for i in range(256):
		var scancode_string := OS.get_scancode_string(i)
		if scancode_string.length() > 1:
			_scancode_localizables.append(scancode_string)
	
	# non-ascii printable characters: F1, left, caps lock...
	for i in range(16777217, 16777319):
		var scancode_string := OS.get_scancode_string(i)
		if scancode_string.length() > 1:
			_scancode_localizables.append(scancode_string)


## Writes the in-memory list of localizables to a file, in a format accessible by pybabel.
func _write_localizables(output_path: String, localizables: Array) -> void:
	var f := File.new()
	f.open(output_path, f.WRITE)
	f.store_string("# Localizable strings extracted by LocalizationDemo.tscn\n")
	for localizable_string_obj in localizables:
		var localizable_string: String = localizable_string_obj
		if localizable_string.empty():
			continue
		
		var sanitized_string := localizable_string
		sanitized_string = sanitized_string.replace("\"", "\\\"")
		sanitized_string = sanitized_string.replace("\n", "\\n")
		f.store_string("tr(\"%s\")\n" % [sanitized_string])
	f.close()


func _on_pressed() -> void:
	_extract_and_write_localizables()
