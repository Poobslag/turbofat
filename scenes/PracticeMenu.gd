"""
Menu for practice mode, a mode where the player can play over and over and try to beat their high scores.
"""
extends Control

func _on_MarathonNormalButton_pressed() -> void:
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.add_level_up("lines", 10, PieceSpeeds.beginner_level_1)
	Global.scenario.add_level_up("lines", 20, PieceSpeeds.beginner_level_2)
	Global.scenario.add_level_up("lines", 30, PieceSpeeds.beginner_level_3)
	Global.scenario.add_level_up("lines", 40, PieceSpeeds.beginner_level_4)
	Global.scenario.add_level_up("lines", 50, PieceSpeeds.beginner_level_5)
	Global.scenario.add_level_up("lines", 60, PieceSpeeds.beginner_level_6)
	Global.scenario.add_level_up("lines", 70, PieceSpeeds.beginner_level_7)
	Global.scenario.add_level_up("lines", 80, PieceSpeeds.beginner_level_8)
	Global.scenario.add_level_up("lines", 90, PieceSpeeds.beginner_level_9)
	Global.scenario.set_win_condition("lines", 100)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_MarathonHardButton_pressed() -> void:
	Global.scenario.set_start_level(PieceSpeeds.hard_level_1)
	Global.scenario.add_level_up("lines", 50, PieceSpeeds.hard_level_2)
	Global.scenario.add_level_up("lines", 60, PieceSpeeds.hard_level_3)
	Global.scenario.add_level_up("lines", 70, PieceSpeeds.hard_level_4)
	Global.scenario.add_level_up("lines", 80, PieceSpeeds.hard_level_5)
	Global.scenario.add_level_up("lines", 90, PieceSpeeds.hard_level_6)
	Global.scenario.add_level_up("lines", 100, PieceSpeeds.hard_level_7)
	Global.scenario.add_level_up("lines", 115, PieceSpeeds.hard_level_8)
	Global.scenario.add_level_up("lines", 130, PieceSpeeds.hard_level_9)
	Global.scenario.add_level_up("lines", 150, PieceSpeeds.hard_level_10)
	Global.scenario.set_win_condition("lines", 200, 150)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_MarathonExpertButton_pressed() -> void:
	Global.scenario.set_start_level(PieceSpeeds.hard_level_5)
	Global.scenario.add_level_up("lines", 75, PieceSpeeds.hard_level_10)
	Global.scenario.add_level_up("lines", 100, PieceSpeeds.hard_level_11)
	Global.scenario.add_level_up("lines", 125, PieceSpeeds.hard_level_12)
	Global.scenario.add_level_up("lines", 150, PieceSpeeds.hard_level_13)
	Global.scenario.add_level_up("lines", 175, PieceSpeeds.hard_level_14)
	Global.scenario.add_level_up("lines", 200, PieceSpeeds.hard_level_15)
	Global.scenario.set_win_condition("lines", 300, 200)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_MarathonMasterButton_pressed() -> void:
	Global.scenario.set_start_level(PieceSpeeds.crazy_level_2)
	Global.scenario.add_level_up("lines", 100, PieceSpeeds.crazy_level_3)
	Global.scenario.add_level_up("lines", 200, PieceSpeeds.crazy_level_4)
	Global.scenario.add_level_up("lines", 300, PieceSpeeds.crazy_level_5)
	Global.scenario.add_level_up("lines", 400, PieceSpeeds.crazy_level_6)
	Global.scenario.add_level_up("lines", 500, PieceSpeeds.crazy_level_7)
	Global.scenario.set_win_condition("lines", 1000, 500)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_SprintNormal_pressed():
	Global.scenario.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario.set_win_condition("time", 150)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_SprintExpert_pressed():
	Global.scenario.set_start_level(PieceSpeeds.crazy_level_0)
	Global.scenario.set_win_condition("time", 180)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_UltraNormal_pressed():
	Global.scenario.set_start_level(PieceSpeeds.beginner_level_0)
	Global.scenario.set_win_condition("score", 200)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_UltraHard_pressed():
	Global.scenario.set_start_level(PieceSpeeds.hard_level_0)
	Global.scenario.set_win_condition("score", 1000)
	get_tree().change_scene("res://scenes/Marathon.tscn")

func _on_UltraExpert_pressed():
	Global.scenario.set_start_level(PieceSpeeds.crazy_level_0)
	Global.scenario.set_win_condition("score", 3000)
	get_tree().change_scene("res://scenes/Marathon.tscn")
