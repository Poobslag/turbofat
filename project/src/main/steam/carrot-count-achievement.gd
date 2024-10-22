extends UniqueLevelAchievement
## Unlocks an achievement when the player has a specific number of carrots visible on a level.

## The carrot count the player needs to achieve
export (int) var target_carrot_count: int

func prepare_level_listeners() -> void:
	_carrots().connect("carrot_added", self, "_on_Carrots_carrot_added")


func remove_level_listeners() -> void:
	if CurrentLevel.puzzle \
			and _carrots().is_connected("carrot_added", self, "_on_Carrots_carrot_added"):
		_carrots().disconnect("carrot_added", self, "_on_Carrots_carrot_added")


func refresh_achievement() -> void:
	if CurrentLevel.puzzle and _carrots().get_carrot_count() >= target_carrot_count:
		SteamUtils.set_achievement(achievement_id)


func _carrots() -> Carrots:
	return CurrentLevel.puzzle.get_carrots()


func _on_Carrots_carrot_added() -> void:
	refresh_achievement()
