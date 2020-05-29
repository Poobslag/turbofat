class_name MainMenu
extends Control
"""
The menu the user sees when they start the game.

Includes buttons starting a new game, launching the level editor, and exiting the game.
"""

# The mandatory tutorial the player must complete before seeing the main menu
const BEGINNER_TUTORIAL_SCENARIO := "tutorial-beginner-0"

func _ready() -> void:
	if not PlayerData.scenario_history.has(BEGINNER_TUTORIAL_SCENARIO):
		var scenario_settings := ScenarioLibrary.load_scenario_from_name(BEGINNER_TUTORIAL_SCENARIO)
		Global.overworld_puzzle = false
		ScenarioLibrary.push_scenario_trail(scenario_settings)
	
	# Fade in music when redirected from a scene with no music, such as the level editor
	if not MusicPlayer.is_playing_chill_bgm():
		MusicPlayer.play_chill_bgm()
		MusicPlayer.fade_in()
	
	$Play/Practice.grab_focus()


func _on_PlayStory_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/world/Overworld.tscn")


func _on_PlayPractice_pressed() -> void:
	Breadcrumb.push_trail("res://src/main/ui/menu/PracticeMenu.tscn")


func _on_CreateLevels_pressed() -> void:
	MusicPlayer.stop()
	Breadcrumb.push_trail("res://src/main/puzzle/editor/LevelEditor.tscn")


func _on_System_quit_pressed() -> void:
	get_tree().quit()
