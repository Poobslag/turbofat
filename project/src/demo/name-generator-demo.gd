extends Control
"""
Demonstrates the name generator.
"""

var _name_generator := NameGenerator.new()

func _ready() -> void:
	_name_generator.min_length = 5
	_name_generator.max_length = 11
	_name_generator.add_seed_resource("res://src/demo/markov-words-0.txt")
	_name_generator.add_seed_resource("res://src/demo/markov-words-1.txt")


func _on_Button_pressed() -> void:
	$Label.text = ""
	for _i in range(20):
		$Label.text += "%s\n" % _name_generator.generate_name()
