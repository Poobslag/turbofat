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
	
	var preset = ConfigFile.new()
	preset.load("res://export_presets.cfg")
	$Version.text = preset.get_value("preset.0.options", "application/file_version")


func _load_scenario() -> void:
	get_tree().change_scene("res://src/main/puzzle/Scenario.tscn")


func _on_MarathonNormal_pressed() -> void:
	Global.scenario_settings.set_name("marathon-normal")
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.add_level_up("lines", 10, PieceSpeeds.beginner_level_1)
	Global.scenario_settings.add_level_up("lines", 20, PieceSpeeds.beginner_level_2)
	Global.scenario_settings.add_level_up("lines", 30, PieceSpeeds.beginner_level_3)
	Global.scenario_settings.add_level_up("lines", 40, PieceSpeeds.beginner_level_4)
	Global.scenario_settings.add_level_up("lines", 50, PieceSpeeds.beginner_level_5)
	Global.scenario_settings.add_level_up("lines", 60, PieceSpeeds.beginner_level_6)
	Global.scenario_settings.add_level_up("lines", 70, PieceSpeeds.beginner_level_7)
	Global.scenario_settings.add_level_up("lines", 80, PieceSpeeds.beginner_level_8)
	Global.scenario_settings.add_level_up("lines", 90, PieceSpeeds.beginner_level_9)
	Global.scenario_settings.set_win_condition("lines", 100)
	_load_scenario()


func _on_MarathonHard_pressed() -> void:
	Global.scenario_settings.set_name("marathon-hard")
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_1)
	Global.scenario_settings.add_level_up("lines", 50, PieceSpeeds.hard_level_2)
	Global.scenario_settings.add_level_up("lines", 60, PieceSpeeds.hard_level_3)
	Global.scenario_settings.add_level_up("lines", 70, PieceSpeeds.hard_level_4)
	Global.scenario_settings.add_level_up("lines", 80, PieceSpeeds.hard_level_5)
	Global.scenario_settings.add_level_up("lines", 90, PieceSpeeds.hard_level_6)
	Global.scenario_settings.add_level_up("lines", 100, PieceSpeeds.hard_level_7)
	Global.scenario_settings.add_level_up("lines", 115, PieceSpeeds.hard_level_8)
	Global.scenario_settings.add_level_up("lines", 130, PieceSpeeds.hard_level_9)
	Global.scenario_settings.add_level_up("lines", 150, PieceSpeeds.hard_level_10)
	Global.scenario_settings.set_win_condition("lines", 200, 150)
	_load_scenario()


func _on_MarathonExpert_pressed() -> void:
	Global.scenario_settings.set_name("marathon-expert")
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_5)
	Global.scenario_settings.add_level_up("lines", 75, PieceSpeeds.hard_level_10)
	Global.scenario_settings.add_level_up("lines", 100, PieceSpeeds.hard_level_11)
	Global.scenario_settings.add_level_up("lines", 125, PieceSpeeds.hard_level_12)
	Global.scenario_settings.add_level_up("lines", 150, PieceSpeeds.hard_level_13)
	Global.scenario_settings.add_level_up("lines", 175, PieceSpeeds.hard_level_14)
	Global.scenario_settings.add_level_up("lines", 200, PieceSpeeds.hard_level_15)
	Global.scenario_settings.set_win_condition("lines", 300, 200)
	_load_scenario()


func _on_MarathonMaster_pressed() -> void:
	Global.scenario_settings.set_name("marathon-master")
	Global.scenario_settings.set_start_level(PieceSpeeds.crazy_level_2)
	Global.scenario_settings.add_level_up("lines", 100, PieceSpeeds.crazy_level_3)
	Global.scenario_settings.add_level_up("lines", 200, PieceSpeeds.crazy_level_4)
	Global.scenario_settings.add_level_up("lines", 300, PieceSpeeds.crazy_level_5)
	Global.scenario_settings.add_level_up("lines", 400, PieceSpeeds.crazy_level_6)
	Global.scenario_settings.add_level_up("lines", 500, PieceSpeeds.crazy_level_7)
	Global.scenario_settings.set_win_condition("lines", 1000, 500)
	_load_scenario()


func _on_SprintNormal_pressed() -> void:
	Global.scenario_settings.set_name("sprint-normal")
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("time", 150)
	_load_scenario()


func _on_SprintExpert_pressed() -> void:
	Global.scenario_settings.set_name("sprint-expert")
	Global.scenario_settings.set_start_level(PieceSpeeds.crazy_level_0)
	Global.scenario_settings.set_win_condition("time", 180)
	_load_scenario()


func _on_UltraNormal_pressed() -> void:
	Global.scenario_settings.set_name("ultra-normal")
	Global.scenario_settings.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario_settings.set_win_condition("score", 200)
	_load_scenario()


func _on_UltraHard_pressed() -> void:
	Global.scenario_settings.set_name("ultra-hard")
	Global.scenario_settings.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario_settings.set_win_condition("score", 1000)
	_load_scenario()


func _on_UltraExpert_pressed() -> void:
	Global.scenario_settings.set_name("ultra-expert")
	Global.scenario_settings.set_start_level(PieceSpeeds.crazy_level_0)
	Global.scenario_settings.set_win_condition("score", 3000)
	_load_scenario()
