extends Node
## Starts and stops music during the puzzle mode.

func _ready() -> void:
	PuzzleState.game_ended.connect(_on_PuzzleState_game_ended)
	PuzzleState.game_prepared.connect(_on_PuzzleState_game_prepared)


func start_puzzle_music() -> void:
	if CurrentLevel.is_tutorial():
		MusicPlayer.play_tutorial_bgm(false)
	else:
		MusicPlayer.play_upbeat_bgm(false)


func _on_PuzzleState_game_prepared() -> void:
	start_puzzle_music()


func _on_PuzzleState_game_ended() -> void:
	MusicPlayer.play_chill_bgm()
