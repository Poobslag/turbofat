extends Node
## Reads and writes data about demos from a file.
##
## This allows demos to remember a developer's selections, so that they don't need to keep retyping or reselecting the
## same choices.
##
## This data is stored independently of the player data to prevent demos from overwriting the developer's game data
## with invalid data. Demos often put the game into a weird state temporarily, and we don't want to persist this weird
## temporary data.

## path to the save file
const FILENAME := "user://demo-data.json"

## json data read from the save file
var demo_data := {}

func _ready() -> void:
	demo_data.clear()
	load_demo_data()


## Writes the developer's in-memory data to a save file.
func save_demo_data() -> void:
	FileUtils.write_file(FILENAME, Utils.print_json(demo_data))


## Populates the player's in-memory data based on their save files.
func load_demo_data() -> void:
	var file := FileAccess.open(FILENAME, FileAccess.READ)
	if file.get_open_error() == OK:
		var save_json_text := FileUtils.get_file_as_text(FILENAME)
		demo_data = JSON.parse_string(save_json_text)
	else:
		# validation failed; couldn't open file
		push_warning("Couldn't open file '%s' for reading: %s" % [FILENAME, file.get_open_error()])
