extends Node
"""
Starts and stops music during the puzzle mode.
"""

func _ready() -> void:
	PuzzleState.connect("game_ended", self, "_on_PuzzleState_game_ended")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")


func start_puzzle_music() -> void:
	if CurrentLevel.settings.other.tutorial:
		MusicPlayer.play_tutorial_bgm()
	else:
		MusicPlayer.play_upbeat_bgm()


func _on_PuzzleState_game_prepared() -> void:
	start_puzzle_music()


func _on_PuzzleState_game_ended() -> void:
	MusicPlayer.play_chill_bgm()
	MusicPlayer.fade_in()
