extends Node
"""
Plays sound effects at the start and end of a puzzle.
"""

onready var _go_voices := [$GoVoice0, $GoVoice1, $GoVoice2]

func _ready() -> void:
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("game_started", self, "_on_PuzzleScore_game_started")


func _on_PuzzleScore_game_prepared() -> void:
	$ReadySound.play()


func _on_PuzzleScore_game_started() -> void:
	$GoSound.play()
	Utils.rand_value(_go_voices).play()


func _on_PuzzleScore_game_ended() -> void:
	var sound: AudioStreamPlayer
	match PuzzleScore.end_result():
		PuzzleScore.LOST:
			sound = $GameOverSound
		PuzzleScore.FINISHED:
			sound = $MatchEndSound
		PuzzleScore.WON:
			sound = $ExcellentSound
	sound.play()
