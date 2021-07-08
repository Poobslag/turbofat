extends HBoxContainer
"""
UI input for specifying the cutscene to open
"""

# The cutscene to open
# Virtual property; value is only exposed through getters/setters
var value: String setget set_value, get_value

func set_value(new_value: String) -> void:
	$LineEdit.text = new_value


func get_value() -> String:
	return $LineEdit.text
