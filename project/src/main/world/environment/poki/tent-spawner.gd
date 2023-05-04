@tool
extends ObstacleSpawner
## Conditionally spawns a tent on the overworld.
##
## Provides a utility method in the editor for shuffling the tent's appearance.

## Editor toggle which randomizes the obstacle's appearance
@export var shuffle: bool: set = set_shuffle

## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	target_properties["frame"] = randi() % 6
	target_properties["flip_h"] = randf() > 0.5
	
	notify_property_list_changed()
