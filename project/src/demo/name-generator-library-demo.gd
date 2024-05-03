extends Node
## Demonstrates the name generator.

onready var _creature_type_button: OptionButton = $HBoxContainer/CreatureType

func _ready() -> void:
	for creature_type_key in Creatures.Type.keys():
		_creature_type_button.add_item(StringUtils.capitalize_words(creature_type_key))


func _on_Generate_pressed() -> void:
	var creature_type := _creature_type_button.selected
	
	$Label.text = ""
	for _i in range(20):
		$Label.text += "%s\n" % NameGeneratorLibrary.generate_name(creature_type)
