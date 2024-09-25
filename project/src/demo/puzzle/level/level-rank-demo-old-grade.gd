extends HBoxContainer
## UI input for specifying the target grade

## Level to open
## Virtual property; value is only exposed through getters/setters
var value: String setget set_value, get_value

## key: (String) letter grade such as 'SSS' or 'AA+'
## value: (int) OptionButton index
var _index_by_grade := {}

func _ready() -> void:
	for i in range(Ranks.GRADES.size()):
		var grade: String = Ranks.GRADES[i]
		$OptionButton.add_item(grade, i)
		_index_by_grade[grade] = i


func set_value(new_value: String) -> void:
	$OptionButton.select(_index_by_grade[new_value])


func get_value() -> String:
	return $OptionButton.get_item_text($OptionButton.selected)
