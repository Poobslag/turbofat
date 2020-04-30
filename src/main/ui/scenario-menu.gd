extends Control
"""
Menu which lists a set of scenarios which the player can play over and over and try to beat their high scores.
"""

# Rank required to unlock harder levels. Rank 23 is an A-
const RANK_TO_UNLOCK := 23.0

func _ready() -> void:
	var unlock_message: String = "(%s to unlock)" % Global.grade(RANK_TO_UNLOCK)
	if ScenarioHistory.get_best_rank("sprint-normal") > RANK_TO_UNLOCK:
		$VBoxContainer/Sprint/Expert.disable(unlock_message)
	if ScenarioHistory.get_best_rank("ultra-normal", "seconds") > RANK_TO_UNLOCK:
		$VBoxContainer/Ultra/Hard.disable(unlock_message)
	if ScenarioHistory.get_best_rank("ultra-hard", "seconds") > RANK_TO_UNLOCK:
		$VBoxContainer/Ultra/Expert.disable(unlock_message)
	if ScenarioHistory.get_best_rank("marathon-normal") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Hard.disable(unlock_message)
	if ScenarioHistory.get_best_rank("marathon-hard") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Expert.disable(unlock_message)
	if ScenarioHistory.get_best_rank("marathon-expert") > RANK_TO_UNLOCK:
		$VBoxContainer/Marathon/Master.disable(unlock_message)
	
	# grab focus so the player can navigate with the keyboard
	$VBoxContainer/Marathon/Normal/Button.grab_focus()


func _change_scenario_scene(scenario_settings: ScenarioSettings) -> void:
	ScenarioLibrary.change_scenario_scene(scenario_settings, false)


func _on_MarathonNormal_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.marathon_normal)


func _on_MarathonHard_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.marathon_hard)


func _on_MarathonExpert_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.marathon_expert)


func _on_MarathonMaster_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.marathon_master)


func _on_SprintNormal_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.sprint_normal)


func _on_SprintExpert_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.sprint_expert)


func _on_UltraNormal_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.ultra_normal)


func _on_UltraHard_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.ultra_hard)


func _on_UltraExpert_pressed() -> void:
	_change_scenario_scene(ScenarioLibrary.ultra_expert)


func _on_OverworldButton_pressed() -> void:
	get_tree().change_scene("res://src/main/world/Overworld.tscn")
