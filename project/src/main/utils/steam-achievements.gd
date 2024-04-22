extends Node

func _clear_achievements() -> void:
	for child in get_children():
		if child is SteamAchievement:
			child.clear_achievement()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "pain-whistle-elastic-union":
		detector.play_cheat_sound(true)
		_clear_achievements()
