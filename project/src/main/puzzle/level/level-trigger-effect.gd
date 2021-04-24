class_name LevelTriggerEffect
"""
An abstract class describing the effect of a level trigger.

A LevelTriggerEffect might subtract points from the player's score, rotate a piece or turn the playfield invisible.
"""

"""
Executes this level trigger effect.

Parameters:
	'params': Parameters specific to this level trigger's phase. For example, a phase which involves clearing lines
		could pass in parameters specifying which lines were cleared.
"""
func run(_params: Array = []) -> void:
	pass


"""
Populates this level trigger with the specified string parameters.

Parameters:
	'new_config': An array of string parameters parsed from json. For example, a level trigger effect which rotates the
		piece could pass in parameters specifying the direction to rotate.
"""
func set_config(_new_config: Array = []) -> void:
	pass
