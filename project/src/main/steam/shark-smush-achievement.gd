extends SteamAchievement
## Unlocks an achievement when the player squishes a shark with a piece.

func connect_signals() -> void:
	.connect_signals()
	disconnect_save_signal()
	disconnect_load_signal()
	Breadcrumb.connect("after_scene_changed", self, "_on_Breadcrumb_after_scene_changed")


func _on_Breadcrumb_after_scene_changed() -> void:
	if get_tree().current_scene is Puzzle:
		var puzzle: Puzzle = get_tree().current_scene
		puzzle.get_sharks().connect("shark_squished", self, "_on_Sharks_shark_squished")


func _on_Sharks_shark_squished(_shark: Shark) -> void:
	SteamUtils.set_achievement(achievement_id)
