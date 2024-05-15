extends Node

const LINES_CLEARED_ON_TOP_OUT := 10

onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]
onready var _puzzle: Puzzle = $".."
onready var _playfield: Playfield = _puzzle.get_playfield()

func _ready() -> void:
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	_playfield.connect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")
	_playfield.connect("after_lines_filled", self, "_on_Playfield_after_lines_filled")


func _on_PuzzleState_topped_out() -> void:
	Utils.rand_value(_game_over_voices).play()
	
	if not PuzzleState.level_performance.lost:
		_playfield.break_combo()
		if CurrentLevel.settings.blocks_during.refresh_on_top_out:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT),
					PieceSpeeds.current_speed.playfield_clear_delay(), false)
		elif CurrentLevel.settings.blocks_during.clear_on_top_out:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT),
					PieceSpeeds.current_speed.playfield_clear_delay(), false)
		else:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT - LINES_CLEARED_ON_TOP_OUT,
					PuzzleTileMap.ROW_COUNT), PieceSpeeds.current_speed.playfield_clear_delay(), false)


func _on_Playfield_after_lines_deleted(_lines: Array) -> void:
	if PuzzleState.topping_out and not CurrentLevel.settings.blocks_during.refresh_on_top_out:
		# The current level's top out process ends with the lines which were just deleted. Exit the top out state.
		PuzzleState.topping_out = false


func _on_Playfield_after_lines_filled() -> void:
	if PuzzleState.topping_out and CurrentLevel.settings.blocks_during.refresh_on_top_out:
		# The current level's top out process ends with the lines which were just filled. Exit the top out state.
		PuzzleState.topping_out = false
