extends Node
"""
Starts and stops music during the puzzle mode.
"""

func _ready() -> void:
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")


func _on_PuzzleScore_game_prepared() -> void:
	MusicPlayer.play_upbeat_bgm()


func _on_PuzzleScore_game_ended() -> void:
	MusicPlayer.play_chill_bgm()
	MusicPlayer.fade_in()
