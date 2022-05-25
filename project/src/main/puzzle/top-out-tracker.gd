extends Node

const LINES_CLEARED_ON_TOP_OUT := 10

## 'True' if the playfield is currently going through the top out process, but the player hasn't lost.
var _topping_out := false

onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]
onready var _puzzle: Puzzle = $".."
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

func _ready() -> void:
	PuzzleState.connect("topped_out", self, "_on_PuzzleState_topped_out")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	_playfield.connect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")
	_playfield.connect("after_lines_filled", self, "_on_Playfield_after_lines_filled")


func _on_PuzzleState_topped_out() -> void:
	Utils.rand_value(_game_over_voices).play()
	
	if not PuzzleState.level_performance.lost:
		_topping_out = true
		_playfield.break_combo()
		if CurrentLevel.settings.blocks_during.refresh_on_top_out:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT),
					PieceSpeeds.current_speed.playfield_clear_delay(), false)
		elif CurrentLevel.settings.blocks_during.clear_on_top_out:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT),
					PieceSpeeds.current_speed.playfield_clear_delay(), false)
		else:
			_playfield.schedule_line_clears(range(PuzzleTileMap.ROW_COUNT - LINES_CLEARED_ON_TOP_OUT, PuzzleTileMap.ROW_COUNT),
					PieceSpeeds.current_speed.playfield_clear_delay(), false)
		_piece_manager.enter_top_out_state()


func _on_PuzzleState_game_prepared() -> void:
	_topping_out = false


func _on_Playfield_after_lines_deleted() -> void:
	if _topping_out and not CurrentLevel.settings.blocks_during.refresh_on_top_out:
		# The current level's top out process ends with the lines which were just deleted. Restore piece mobility.
		_topping_out = false
		_piece_manager.exit_top_out_state()


func _on_Playfield_after_lines_filled() -> void:
	if _topping_out and CurrentLevel.settings.blocks_during.refresh_on_top_out:
		# The current level's top out process ends with the lines which were just filled. Restore piece mobility.
		_piece_manager.exit_top_out_state()
