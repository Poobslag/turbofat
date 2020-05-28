extends Control
"""
Menu which lists a set of scenarios which the player can play over and over and try to beat their high scores.
"""

# Rank required to unlock harder levels. Rank 24 is an S-
const RANK_TO_UNLOCK := 24.0

func _ready() -> void:
	var unlock_message: String = "(%s to unlock)" % Global.grade(RANK_TO_UNLOCK)
	if PlayerData.get_best_scenario_rank("sprint-normal") > RANK_TO_UNLOCK:
		$VBoxContainer/Sprint/Expert.disable(unlock_message)
	if PlayerData.get_best_scenario_rank("ultra-normal", "seconds") > RANK_TO_UNLOCK:
		$VBoxContainer/Ultra/Hard.disable(unlock_message)
	if PlayerData.get_best_scenario_rank("ultra-hard", "seconds") > RANK_TO_UNLOCK:
		$VBoxContainer/Ultra/Expert.disable(unlock_message)
	if PlayerData.get_best_scenario_rank("marathon-normal") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Hard.disable(unlock_message)
	if PlayerData.get_best_scenario_rank("marathon-hard") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Expert.disable(unlock_message)
	if PlayerData.get_best_scenario_rank("marathon-expert") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Master.disable(unlock_message)
	if OS.has_feature("web"):
		$OverworldButton.visible = false
	
	# grab focus so the player can navigate with the keyboard
	$VBoxContainer/Marathon/Normal/Button.grab_focus()


func launch_scenario(scenario_name: String) -> void:
	var scenario_settings := ScenarioLibrary.load_scenario_from_name(scenario_name)
	Global.overworld_puzzle = false
	ScenarioLibrary.push_scenario_trail(scenario_settings)


func _on_PracticeButton_chose_scenario(scenario_name: String) -> void:
	launch_scenario(scenario_name)


func _on_TutorialButton_pressed() -> void:
	launch_scenario(MainMenu.BEGINNER_TUTORIAL_SCENARIO)


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "unlock":
		var enabled_count := 0
		for button_obj in [
			$VBoxContainer/Sprint/Expert,
			$VBoxContainer/Ultra/Hard,
			$VBoxContainer/Ultra/Expert,
			$VBoxContainer/Marathon/Hard,
			$VBoxContainer/Marathon/Expert,
			$VBoxContainer/Marathon/Master
		]:
			var button: PracticeButton = button_obj
			if button.is_disabled():
				button.enable()
				enabled_count += 1
		if enabled_count >= 1:
			detector.play_cheat_sound(true)
