extends UniqueLevelAchievement
## Unlocks an achievement when the player has a specific number of carrots visible on a level.

## The carrot count the player needs to achieve
export (int) var target_carrot_count: int

func prepare_level_listeners() -> void:
	_carrots().connect("carrot_added", self, "_on_Carrots_carrot_added")


func refresh_achievement() -> void:
	if get_tree().current_scene is Puzzle and _carrots().get_carrot_count() >= target_carrot_count:
		Steam.set_achievement(achievement_id)


func _carrots() -> Carrots:
	return get_tree().current_scene.get_carrots()


func _on_Carrots_carrot_added() -> void:
	refresh_achievement()
