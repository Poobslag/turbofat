"""
Contains logic for displaying the player's score. This includes their cumulative score as well as the score for the
current combo.
"""
extends Control

var score := 0 setget _set_score
var combo_score := 0 setget _set_combo_score

func _set_score(new_score: int) -> void:
	score = new_score
	$ScoreValue.text = str(new_score)
	
func _set_combo_score(new_combo_score: int) -> void:
	combo_score = new_combo_score
	if new_combo_score == 0:
		$ComboScoreValue.text = "-"
	else:
		$ComboScoreValue.text = "+" + str(new_combo_score)

func add_score(score_delta: int) -> void:
	_set_score(score + score_delta)

func add_combo_score(combo_score_delta: int) -> void:
	_set_combo_score(combo_score + combo_score_delta)

func end_combo() -> void:
	add_score(combo_score)
	_set_combo_score(0)

"""
Reset all score data for a new game.
"""
func start_game() -> void:
	_set_score(0)
	_set_combo_score(0)