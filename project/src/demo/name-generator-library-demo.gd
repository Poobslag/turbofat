extends Node
## Demonstrates the name generator.

@onready var _creature_type_button: OptionButton = $HBoxContainer/CreatureType

func _ready() -> void:
	for i in range(Creatures.Type.size()):
		_creature_type_button.add_item(StringUtils.capitalize_words(Creatures.Type.keys()[i]))


func _on_Generate_pressed() -> void:
	var creature_type := _creature_type_button.selected
	
	$Label.text = ""
	for _i in range(20):
		$Label.text += "%s\n" % NameGeneratorLibrary.generate_name(creature_type)
