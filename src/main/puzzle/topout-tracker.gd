extends Node

onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]
onready var _puzzle: Puzzle = $".."
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

func make_player_lose() -> void:
	PuzzleScore.scenario_performance.lost = true
	$GameOverSound.play()
	_puzzle.end_game(2.4, "Game over")


"""
When the current piece can't be placed, we end the game and emit the appropriate signals.
"""
func _on_PieceManager_topped_out() -> void:
	_game_over_voices[randi() % _game_over_voices.size()].play()
	PuzzleScore.scenario_performance.top_out_count += 1
	
	if PuzzleScore.scenario_performance.top_out_count >= Global.scenario_settings.lose_condition.top_out:
		make_player_lose()
	else:
		var top_out_delay := PieceSpeeds.current_speed.appearance_delay + PieceSpeeds.current_speed.lock_delay
		_playfield.break_combo()
		_playfield.schedule_line_clears(range(Playfield.ROW_COUNT - 6, Playfield.ROW_COUNT), top_out_delay, false)
		_piece_manager.enter_top_out_state(top_out_delay)
