class_name RegionMusic
## Describes the music in a career region.
##
## Each region defines a menu music id and set of puzzle music ids. These music ids correspond to entries in
## MusicPlayer.bgms_by_id. The list of puzzle music ids obey two unusual rules:
##
## 1. The first item in the list of puzzle music ids is the 'main puzzle music id'. This main puzzle music is played
## for the first puzzle of each career data and for the boss level.
##
## 2. Json puzzle music ids prefixed with a '+' will play twice as often.

## Music to play while the player navigates menus
var menu_music_id: String

## String music ids to play while the player is playing a level
var puzzle_music_ids: Array

## Puzzle music which should be played more frequently than other music
##
## key: (String) music id
## value: (bool) true
var _favored_puzzle_music_ids := {}

## Returns a random music id to play while the player is playing a level from this region.
func random_puzzle_music_id() -> String:
	var music_id_pool: Array = []
	for puzzle_music_id in puzzle_music_ids:
		music_id_pool.append(puzzle_music_id)
		if _favored_puzzle_music_ids.has(puzzle_music_id):
			music_id_pool.append(puzzle_music_id)
	
	return Utils.rand_value(music_id_pool)


## Returns the main music id to play while the player is playing a level from this region.
##
## The main music id is played at the start of every career day, and for every boss level.
func main_puzzle_music_id() -> String:
	return puzzle_music_ids[0]


func from_json_dict(json: Dictionary) -> void:
	_favored_puzzle_music_ids.clear()
	menu_music_id = json.get("menu", "")
	for puzzle_music_id in json.get("puzzle", []):
		var new_puzzle_music_id: String = puzzle_music_id
		if puzzle_music_id.begins_with("+"):
			# json puzzle music ids prefixed with a '+' will play twice as often
			new_puzzle_music_id = puzzle_music_id.trim_prefix("+")
			_favored_puzzle_music_ids[new_puzzle_music_id] = true
		puzzle_music_ids.append(new_puzzle_music_id)
