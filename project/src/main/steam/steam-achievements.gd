extends Node
## Unlocks Steam achievements and updates stats.
##
## Most of this functionality is actually handled by SteamAchievement child nodes.

## Returns a list of SteamAchievement nodes for all steam achievements in the game.
func get_achievements() -> Array:
	return Utils.get_child_members(self, "steam_achievements")


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "pain-whistle-elastic-union":
		detector.play_cheat_sound(true)
		SteamUtils.reset_all_stats(true)
