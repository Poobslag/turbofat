class_name LevelTriggerEffect
"""
An abstract class describing the effect of a level trigger.

A LevelTriggerEffect might subtract points from the player's score, rotate a piece or turn the playfield invisible.
"""

"""
Executes this level trigger effect.
"""
func run() -> void:
	pass


"""
Populates this level trigger with the specified string parameters.

Parameters:
	'new_config': An dictionary of string parameters parsed from json. For example, a level trigger effect which
		rotates the piece could pass in parameters specifying the direction to rotate.
"""
func set_config(_new_config: Dictionary = {}) -> void:
	pass
