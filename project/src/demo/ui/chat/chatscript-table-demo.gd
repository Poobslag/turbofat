extends Control
## Generates a BBCode Chatscript mood table for the wiki.
##
## This process is automated because the list of emoticons is likely to expand or change.

## The number of columns in the BBCode table
var _table_width := 1

## key: An int corresponding to a mood from ChatEvent.Mood
## value: An array of string chat prefixes (emoticons)
var _prefixes_by_mood := {}

## TextEdit containing the BBCode table
onready var _text_edit := $TextEdit

func _ready() -> void:
	_recalculate_prefixes_by_mood()
	_recalculate_table_width()
	_add_header_row()
	_add_mood_rows()


func _recalculate_prefixes_by_mood() -> void:
	_prefixes_by_mood.clear()
	for mood_prefix in ChatscriptParser.MOOD_PREFIXES:
		var mood: int = ChatscriptParser.MOOD_PREFIXES[mood_prefix]
		if not _prefixes_by_mood.has(mood):
			_prefixes_by_mood[mood] = []
		_prefixes_by_mood[mood].append(mood_prefix)


func _recalculate_table_width() -> void:
	_table_width = 1
	for mood in _prefixes_by_mood:
		_table_width = max(_table_width, _prefixes_by_mood[mood].size() + 1)


func _add_header_row() -> void:
	_text_edit.text = ""
	
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
	var mood_names := ChatEvent.Mood.keys()
	mood_names.sort()
	
	for mood_name in mood_names:
		var mood: int = ChatEvent.Mood.get(mood_name)
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
