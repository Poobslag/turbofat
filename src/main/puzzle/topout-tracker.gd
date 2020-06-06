extends Node

onready var _game_over_voices := [$GameOverVoice0, $GameOverVoice1, $GameOverVoice2, $GameOverVoice3, $GameOverVoice4]
onready var _puzzle: Puzzle = $".."
onready var _playfield: Playfield = _puzzle.get_playfield()
onready var _piece_manager: PieceManager = _puzzle.get_piece_manager()

func _input(event: InputEvent) -> void:
	if PuzzleScore.game_active and event.is_action_pressed("ui_menu"):
		make_player_lose()


func make_player_lose() -> void:
	if not Scenario.settings.lose_condition.finish_on_lose:
		PuzzleScore.scenario_performance.lost = true
	PuzzleScore.end_game()


"""
When the current piece can't be placed, we end the game and emit the appropriate signals.
"""
func _on_PieceManager_topped_out() -> void:
	_game_over_voices[randi() % _game_over_voices.size()].play()
	PuzzleScore.scenario_performance.top_out_count += 1
	
	if PuzzleScore.scenario_performance.top_out_count >= Scenario.settings.lose_condition.top_out:
		make_player_lose()
	else:
		var top_out_delay := PieceSpeeds.current_speed.appearance_delay + PieceSpeeds.current_speed.lock_delay
		_playfield.break_combo()
		if Scenario.settings.blocks_during.clear_on_top_out:
			_playfield.schedule_line_clears(range(0, Playfield.ROW_COUNT), top_out_delay, false)
		else:
			_playfield.schedule_line_clears(range(Playfield.ROW_COUNT - 6, Playfield.ROW_COUNT), top_out_delay, false)
		_piece_manager.enter_top_out_state(top_out_delay)
