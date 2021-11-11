class_name LevelTriggerEffect
## An abstract class describing the effect of a level trigger.
##
## A LevelTriggerEffect might subtract points from the player's score, rotate a piece or turn the playfield invisible.

## Executes this level trigger effect.
func run() -> void:
	pass


## Populates this level trigger with the specified string parameters.
##
## Parameters:
## 	'new_config': A dictionary of string parameters parsed from json. For example, a level trigger effect which
## 		rotates the piece could pass in parameters specifying the direction to rotate.
func set_config(_new_config: Dictionary = {}) -> void:
	pass


## Extracts a dictionary of string parameters from this level trigger.
##
## This performs the inverse of the 'set_config' function, extracting values from the trigger's properties and using
## them to populate a dictionary.
##
## Returns:
## 	A dictionary of string parameters parsed from json. For example, a level trigger effect which rotates the piece
## 		could pass in parameters specifying the direction to rotate.
func get_config() -> Dictionary:
	return {}
