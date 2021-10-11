extends Node

const LINES_CLEARED_ON_TOP_OUT := 10

onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]
onready var _puzzle: Puzzle = $".."
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

func _ready() -> void:
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")


func _on_PuzzleState_topped_out() -> void:
	Utils.rand_value(_game_over_voices).play()
	
	if not PuzzleState.level_performance.lost:
		var top_out_delay := PieceSpeeds.current_speed.appearance_delay + PieceSpeeds.current_speed.lock_delay
		_playfield.break_combo()
		if CurrentLevel.settings.blocks_during.clear_on_top_out:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT),
					top_out_delay, false)
		else:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT - LINES_CLEARED_ON_TOP_OUT, PuzzleTileMap.ROW_COUNT),
					top_out_delay, false)
		_piece_manager.enter_top_out_state(top_out_delay)
