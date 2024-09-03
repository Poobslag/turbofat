class_name RegionMusic
## Describes the music in a career region.
##
## Each region defines a menu music track id and set of puzzle music track ids. These track ids correspond to entries
## in MusicPlayer.tracks_by_id. The list of puzzle music track ids obey two unusual rules:
##
## 1. The first item in the list of puzzle music track ids is the 'main puzzle music track id'. This main puzzle track
## is played for the first puzzle of each career data and for the boss level.
##
## 2. Json puzzle music track ids prefixed with a '+' will play twice as often.

## Music to play while the player navigates menus
var menu_track_id: String

## String music track ids to play while the player is playing a level
var puzzle_track_ids: Array

## Puzzle track which should be played more frequently than other music
##
## key: (String) music track id
## value: (bool) true
var _favored_puzzle_track_ids := {}

## Returns a random music track id to play while the player is playing a level from this region.
func random_puzzle_track_id() -> String:
	var track_id_pool: Array = []
	for puzzle_track_id in puzzle_track_ids:
		track_id_pool.append(puzzle_track_id)
		if _favored_puzzle_track_ids.has(puzzle_track_id):
			track_id_pool.append(puzzle_track_id)
	
	return Utils.rand_value(track_id_pool)


## Returns the main music track id to play while the player is playing a level from this region.
##
## The main music track id is played at the start of every career day, and for every boss level.
func main_puzzle_track_id() -> String:
	return puzzle_track_ids[0]


func from_json_dict(json: Dictionary) -> void:
	_favored_puzzle_track_ids.clear()
	menu_track_id = json.get("menu", "")
	for puzzle_track_id in json.get("puzzle", []):
		var new_puzzle_track_id: String = puzzle_track_id
		if puzzle_track_id.begins_with("+"):
			# json puzzle music track ids prefixed with a '+' will play twice as often
			new_puzzle_track_id = puzzle_track_id.trim_prefix("+")
			_favored_puzzle_track_ids[new_puzzle_track_id] = true
		puzzle_track_ids.append(new_puzzle_track_id)
