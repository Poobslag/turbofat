extends Node
## Unlocks Steam achievements and updates stats.
##
## Most of this functionality is actually handled by SteamAchievement child nodes.

func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "pain-whistle-elastic-union":
		detector.play_cheat_sound(true)
		Steam.reset_all_stats(true)
