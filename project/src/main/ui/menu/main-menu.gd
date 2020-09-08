class_name MainMenu
extends Control
"""
The menu the user sees when they start the game.

Includes buttons starting a new game, launching the level editor, and exiting the game.
"""

func _ready() -> void:
	if not PlayerData.scenario_history.finished_scenarios.has(Scenario.BEGINNER_TUTORIAL):
		_launch_tutorial()
	
	# Fade in music when redirected from a scene with no music, such as the level editor
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
		MusicPlayer.fade_in()
	
	$Play/Practice.grab_focus()


func _launch_tutorial() -> void:
	var settings := ScenarioSettings.new()
	settings.load_from_resource(Scenario.BEGINNER_TUTORIAL)
	Scenario.overworld_puzzle = false
	Scenario.push_scenario_trail(settings)


func _on_PlayStory_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/world/Overworld.tscn")


func _on_PlayPractice_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/PracticeMenu.tscn")


func _on_CreateLevels_pressed() -> void:
	MusicPlayer.stop()
	Breadcrumb.push_trail("res://src/main/editor/puzzle/LevelEditor.tscn")


func _on_CreateCreatures_pressed() -> void:
	MusicPlayer.stop()
	Breadcrumb.push_trail("res://src/main/editor/creature/CreatureEditor.tscn")


func _on_System_quit_pressed() -> void:
	get_tree().quit()


func _on_Tutorial_pressed() -> void:
	_launch_tutorial()


func _on_LevelSelect_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/level-select/LevelSelect.tscn")
