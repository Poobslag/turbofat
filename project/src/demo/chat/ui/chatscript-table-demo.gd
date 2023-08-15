extends Node
## Generates BBCode Chatscript tables for the wiki.
##
## This process is automated because the list of emoticons and locations is likely to expand or change.
##
## Keys:
## 	[L]: Generates a BBCode Chatscript location table.
## 	[M]: Generates a BBCode Chatscript mood table.

## key: (String) location ID corresponding to an entry in ChatTree.ENVIRONMENT_SCENE_PATHS_BY_ID
## value: (String) location description for the ChatScript wiki page
const LOCATION_DESCRIPTIONS_BY_ID := {
	"filming": "Generic Turbo Fat restaurant interior with cameras",
	"inside_turbo_fat": "Generic Turbo Fat restaurant interior",
	"lemon": "\"Lemony Thickets\" environment",
	"lemon/walk": "\"Lemony Thickets\" walking environment",
	"lemon_2": "\"Welcome To Turbo Fat\" environment",
	"marsh": "\"Merrymellow Marsh\" environment",
	"marsh/walk": "\"Merrymellow Marsh\" walking environment",
	"poki": "\"Poki Desert\" environment",
	"poki/walk": "\"Poki Desert\" walking environment",
	"sand": "\"Cannoli Sandbar\" environment",
	"sand/banana_hq": "\"Cannoli Sandbar\" Banana HQ interior",
	"sand/walk": "\"Cannoli Sandbar\" walking environment",
}

## Number of columns in the BBCode table
var _table_width := 1

## key: (Creatures.Mood)
## value: (Array, String) string chat prefixes (emoticons)
var _prefixes_by_mood := {}

## TextEdit containing the BBCode table
onready var _text_edit := $TextEdit

func _ready() -> void:
	_show_mood_table()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_M:
			_show_mood_table()
		KEY_L:
			_show_location_table()


func _show_location_table() -> void:
	_text_edit.text = ""
	_table_width = 2
	_add_table_row(["location", "description"])
	_add_table_row(["---", "---"])
	var location_ids := ChatTree.ENVIRONMENT_SCENE_PATHS_BY_ID.keys()
	location_ids.sort()
	for location in location_ids:
		_add_table_row([location, LOCATION_DESCRIPTIONS_BY_ID.get(location, "")])


func _show_mood_table() -> void:
	_text_edit.text = ""
	_recalculate_prefixes_by_mood()
	_recalculate_mood_table_width()
	_add_mood_header_row()
	_add_mood_rows()


func _recalculate_prefixes_by_mood() -> void:
	_prefixes_by_mood.clear()
	for mood_prefix in ChatscriptParser.MOOD_PREFIXES:
		var mood: int = ChatscriptParser.MOOD_PREFIXES[mood_prefix]
		Utils.put_if_absent(_prefixes_by_mood, mood, [])
		_prefixes_by_mood[mood].append(mood_prefix)


func _recalculate_mood_table_width() -> void:
	_table_width = 1
	for mood in _prefixes_by_mood:
		_table_width = max(_table_width, _prefixes_by_mood[mood].size() + 1)


func _add_mood_header_row() -> void:
	# | mood | 1 | 2 | 3 |
	var header_row := ["mood"]
	while header_row.size() < _table_width:
		header_row.append(header_row.size())
	_add_table_row(header_row)
	
	# | --- | --- | --- | --- |
	var header_separator := []
	while header_separator.size() < _table_width:
		header_separator.append("---")
	_add_table_row(header_separator)


func _add_mood_rows() -> void:
	var mood_names := Creatures.Mood.keys()
	mood_names.sort()
	
	for mood_name in mood_names:
		var mood: int = Creatures.Mood.get(mood_name)
		if not _prefixes_by_mood.has(mood):
			# skip moods with no chat prefixes, such as Mood.NONE
			continue
		
		# | awkward0 | `<_<` | `>_>` |  |
		var table_row := [mood_name.to_lower()]
		for prefix in _prefixes_by_mood[mood]:
			table_row.append("`%s`" % [prefix])
		_add_table_row(table_row)


## Add a BBCode row to the TextEdit.
##
## Parameters:
## 	'row': An array of strings corresponding to the row's contents. Empty columns will be filled in if the array has
## 		fewer entries than the number of columns in the table.
func _add_table_row(row: Array) -> void:
	var pool_array := PoolStringArray(row)
	
	# fill the array if it has fewer entries than the number of columns in the table
	while pool_array.size() < _table_width:
		pool_array.append("")
	
	_text_edit.text += "| " + pool_array.join(" | ") + " |\n"
