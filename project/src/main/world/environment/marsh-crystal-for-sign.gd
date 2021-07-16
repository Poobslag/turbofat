extends OverworldObstacle
"""
The marsh crystal which obstructs the Buttercup Cafe sign.
"""

func _ready() -> void:
	if PlayerData.level_history.is_level_finished("marsh/pulling_for_everyone"):
		# the tree has been chopped down
		queue_free()
