class_name WorldSelectButton
extends LevelSelectButton
## A button on the level select screen which displays world information.

## an array of level ranks. incomplete levels are treated as rank 999
var ranks: Array

## Workaround for Godot #21789 to make get_class return class_name
func get_class() -> String:
	return "WorldSelectButton"


## Workaround for Godot #21789 to make is_class match class_name
func is_class(name: String) -> bool:
	return name == "WorldSelectButton" or .is_class(name)
