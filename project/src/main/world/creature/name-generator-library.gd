extends Node
## Generates names for different species using different algorithms.

## key: (Creatures.Type) creature type such as 'squirrel'
## value: (NameGenerator) generator for the specified creature type
var _generators_by_type := {}

func _ready() -> void:
	_generators_by_type[Creatures.Type.DEFAULT] = _default_generator()
	_generators_by_type[Creatures.Type.SQUIRREL] = _squirrel_generator()


## Generates a name for the specified creature type.
##
## Parameters:
## 	type: Enum from Creatures.Type for a creature type such as 'squirrel'
func generate_name(type: int = Creatures.Type.DEFAULT) -> String:
	return _generators_by_type[type].generate_name()


func _default_generator() -> NameGenerator:
	var result := NameGenerator.new()
	result.add_seed_resource("res://assets/main/world/creature/names/animals.txt")
	result.add_seed_resource("res://assets/main/world/creature/names/american-male-given-names.txt")
	result.add_seed_resource("res://assets/main/world/creature/names/american-female-given-names.txt")
	result.order = 2.7
	result.min_length = 4
	result.max_length = 11
	return result


func _squirrel_generator() -> NameGenerator:
	var result := NameGenerator.new()
	result.add_seed_resource("res://assets/main/world/creature/names/trees.txt")
	result.add_seed_resource("res://assets/main/world/creature/names/greek-mythological-figures.txt")
	result.order = 2.3
	result.min_length = 6
	result.max_length = 12
	return result
