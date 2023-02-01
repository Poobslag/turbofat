tool
extends ObstacleSpawner
## Conditionally spawns a Poki Desert crowd member on the overworld.
##
## Provides a utility method in the editor for shuffling the crowd member's appearance.

## An editor toggle which randomizes the crowd member's appearance
export (bool) var shuffle: bool setget set_shuffle

## Randomizes the crowd member's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	target_properties["frame"] = randi() % 20
	target_properties["crowd_color_index"] = Utils.randi_range(0, PokiCrowd.CROWD_COLORS.size() - 1)
	
	property_list_changed_notify()


## Spawns and orients the crowd member and removes the spawner from the scene tree.
func spawn_target() -> void:
	.spawn_target()
	
	var flip_chance := 0.5
	
	if PlayerData.chat_history.is_chat_finished("chat/career/poki/100"):
		# people face the restaurant
		var entrances := get_tree().get_nodes_in_group("turbo_fat_entrances")
		var entrance: Area2D
		if entrances:
			entrance = entrances[0]
		
		if not entrance:
			push_warning("Turbo fat entrance not found")
		else:
			flip_chance = 0.1 if position.x < entrance.position.x else 0.9
	else:
		# people face right
		flip_chance = 0.1
	
	var poki_crowd: PokiCrowd = spawned_object
	poki_crowd.flip_h = randf() <= flip_chance
