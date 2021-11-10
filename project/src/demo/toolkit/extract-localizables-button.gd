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
	
	_extract_localizables_from_levels()
	_extract_localizables_from_creatures()
	_extract_localizables_from_scancode_strings()
	_write_localizables(OUTPUT_PATH, _localizables)
	_write_localizables(SCANCODE_OUTPUT_PATH, _scancode_localizables)
	
	TranslationServer.set_locale(old_locale)
	_output_label.text = "Wrote %s strings to %s, %s." % [
			StringUtils.comma_sep(_localizables.size() + _scancode_localizables.size()),
			OUTPUT_PATH, SCANCODE_OUTPUT_PATH]


## Extracts localizable strings from levels and adds them to the in-memory list of localizables.
func _extract_localizables_from_levels() -> void:
	var level_ids := LevelLibrary.all_level_ids()
	level_ids.sort()
	for level_id in level_ids:
		var level_settings := LevelLibrary.level_settings(level_id)
		
		# extract level's title and description as localizables
		_localizables.append(level_settings.title)
		_localizables.append(level_settings.description)
		
		# extract level's cutscene chat as localizables
		if ChatLibrary.has_preroll(level_id):
			var chat_tree := ChatLibrary.chat_tree_for_preroll(level_id)
			_extract_localizables_from_chat_tree(chat_tree)
		if ChatLibrary.has_postroll(level_id):
			var chat_tree := ChatLibrary.chat_tree_for_postroll(level_id)
			_extract_localizables_from_chat_tree(chat_tree)


## Extracts localizable strings from creature chats and adds them to the in-memory list of localizables.
func _extract_localizables_from_creatures() -> void:
	var creature_ids := PlayerData.creature_library.creature_ids()
	creature_ids.sort()
	for creature_id in creature_ids:
		var creature_def := PlayerData.creature_library.get_creature_def(creature_id)
		
		# extract the creature's filler chat as localizables
		for filler_id in ChatLibrary.filler_ids_for_creature(creature_id):
			var chat_tree := ChatLibrary.chat_tree_for_creature_chat_id(creature_def, filler_id)
			_extract_localizables_from_chat_tree(chat_tree)
		
		# extract the creature's level/story chat as localizables
		for chat_selector_obj in creature_def.chat_selectors:
			var chat_selector: Dictionary = chat_selector_obj
			var chat_tree := ChatLibrary.chat_tree_for_creature_chat_id(creature_def, chat_selector.get("chat"))
			_extract_localizables_from_chat_tree(chat_tree)


## Extracts localizable strings from a chat tree and adds them to the in-memory list of localizables.
func _extract_localizables_from_chat_tree(chat_tree: ChatTree) -> void:
	for event_sequence in chat_tree.events.values():
		for event_obj in event_sequence:
			var event: ChatEvent = event_obj
			
			# append a line of chat as a localizable
			_localizables.append(event.text)
			
			# Append the list of player-selected chat choices as localizables.
			if event.link_texts.size() == 1:
				# We do not localize chat which only has one choice because the player is not prompted.
				pass
			else:
				for link_text in event.link_texts:
					_localizables.append(link_text)


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
		var sanitized_string := localizable_string
		sanitized_string = sanitized_string.replace("\"", "\\\"")
		sanitized_string = sanitized_string.replace("\n", "\\n")
		f.store_string("tr(\"%s\")\n" % [sanitized_string])
	f.close()


func _on_pressed() -> void:
	_extract_and_write_localizables()
