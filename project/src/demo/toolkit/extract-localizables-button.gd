extends ReleaseToolButton
## Extracts localizable strings from levels and chats as a part of the localization process.
##
## The pybabel tool creates a PO template file from our script and scene files. However, level and chat data is stored
## in a proprietary JSON format which pybabel doesn't understand. This demo looks at all levels and chat in the game
## and exports any localizable strings into a format accessible by pybabel.

## file where we write the localizable strings
const OUTPUT_PATH := "res://assets/main/locale/localizables-extracted.py"

## List of String lines to be written to the file.
var _file_contents: Array = []

onready var _creature_editor_library := Global.get_creature_editor_library()

## Extracts localizable strings from levels and chats and writes them to a file.
func run() -> void:
	_file_contents.clear()
	
	# Temporarily set the locale to 'en' to ensure we extract english keys
	var old_locale := TranslationServer.get_locale()
	TranslationServer.set_locale("en")
	
	_append_comment("Localizable strings extracted by LocalizationDemo.tscn")
	_append_header_comment("Career regions")
	_extract_localizables_from_career_regions()
	_append_header_comment("Cutscenes")
	_extract_localizables_from_cutscenes()
	_append_header_comment("Creature editor")
	_extract_localizables_from_creature_editor()
	_append_header_comment("Levels")
	_extract_localizables_from_levels()
	_append_header_comment("Scancodes")
	_extract_localizables_from_scancodes()
	_append_header_comment("Locales")
	_extract_localizables_from_locales()
	
	FileUtils.write_file(OUTPUT_PATH, PoolStringArray(_file_contents).join("\n") + "\n")
	TranslationServer.set_locale(old_locale)
	_output.add_line("Wrote %s lines to %s." % [
			StringUtils.comma_sep(_file_contents.size()),
			OUTPUT_PATH])


## Appends a comment to the '_file_contents' to be written to a file later.
func _append_comment(comment: String) -> void:
	_file_contents.append("# %s" % [comment])


## Appends a section header to the '_file_contents' to be written to a file later.
func _append_header_comment(comment: String) -> void:
	_file_contents.append("")
	_file_contents.append("# %s" % [comment])


## Appends a localizable to the '_file_contents' to be written to a file later.
func _append_localizable(localizable: String) -> void:
	if localizable.empty():
		return
	
	var sanitized_string := localizable
	sanitized_string = sanitized_string.replace("\"", "\\\"")
	sanitized_string = sanitized_string.replace("\n", "\\n")
	_file_contents.append("tr(\"%s\")" % [sanitized_string])


## Extracts localizable strings from regions in career mode.
func _extract_localizables_from_career_regions() -> void:
	for region_obj in CareerLevelLibrary.regions:
		var region: CareerRegion = region_obj
		_append_localizable(region.name)
		_append_localizable(region.description)
	for region_obj in OtherLevelLibrary.regions:
		var region: OtherRegion = region_obj
		_append_localizable(region.name)
		_append_localizable(region.description)


## Extracts localizable strings from a chat event and adds them to the in-memory list of localizables.
##
## This includes the chat event's dialog, branches, and meta items like restaurant names the player can choose.
func _extract_localizables_from_chat_event(event: ChatEvent) -> void:
	# append a line of chat as a localizable
	_append_localizable(event.text)
	
	# Append the list of player-selected chat choices as localizables.
	if event.link_texts.size() == 1:
		# We do not localize chat which only has one choice because the player is not prompted.
		pass
	else:
		for link_text in event.link_texts:
			_append_localizable(link_text)
	
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
					
					_append_localizable(PoolStringArray(args.slice(1, args.size())).join(" "))
				"default_phrase":
					if args.size() < 2:
						push_warning("Invalid token count for default_phrase call. Expected 2 but was %s"
								% [args.size()])
					
					_append_localizable(PoolStringArray(args.slice(1, args.size())).join(" "))
				"nametag_text":
					if args.size() < 1:
						push_warning("Invalid token count for nametag_text call. Expected 1 but was %s"
								% [args.size()])
					
					_append_localizable(PoolStringArray(args.slice(0, args.size())).join(" "))


## Extracts localizable strings from all cutscenes/chats and adds them to the in-memory list of localizables.
func _extract_localizables_from_cutscenes() -> void:
	for path in CareerCutsceneLibrary.find_career_cutscene_resource_paths():
		var chat_tree := ChatLibrary.chat_tree_from_file(path)
		for event_sequence in chat_tree.events.values():
			for event_obj in event_sequence:
				_extract_localizables_from_chat_event(event_obj)


func _extract_localizables_from_creature_editor() -> void:
	for category in _creature_editor_library.categories:
		_append_localizable(category.name)


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
		
		# extract level's name and description as localizables
		_append_localizable(level_settings.name)
		_append_localizable(level_settings.description)


## Extract localizables from OS.get_scancode_string()
##
## This is a workaround for Godot #4140 (https://github.com/godotengine/godot/issues/4140). Because Godot does not
## offer a way to localize scancode strings, we must extract and localize them ourselves.
func _extract_localizables_from_scancodes() -> void:
	# ascii printable characters: space, comma, period, slash...
	for i in range(256):
		var scancode_string := OS.get_scancode_string(i)
		if scancode_string.length() > 1:
			_append_localizable(scancode_string)
	
	# non-ascii printable characters: F1, left, caps lock...
	for i in range(16777217, 16777359):
		var scancode_string := OS.get_scancode_string(i)
		if scancode_string.length() > 1:
			_append_localizable(scancode_string)


## Extract localizables from TranslationServer.get_loaded_locales()
func _extract_localizables_from_locales() -> void:
	var locale_names := []
	for locale in TranslationServer.get_loaded_locales():
		locale_names.append(TranslationServer.get_locale_name(locale))
	locale_names.sort()
	for locale_name in locale_names:
		_append_localizable(locale_name)
