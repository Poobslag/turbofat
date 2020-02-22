"""
Contains logic for displaying the player's score. This includes their cumulative score as well as the score for the
current combo.
"""
extends Control

var score = 0 setget set_score
var combo_score = 0 setget set_combo_score

func set_score(new_score):
	score = new_score
	$ScoreValue.text = str(new_score)
	
func set_combo_score(new_combo_score):
	combo_score = new_combo_score
	if new_combo_score == 0:
		$ComboScoreValue.text = "-"
	else:
		$ComboScoreValue.text = "+" + str(new_combo_score)

func add_score(score_delta):
	set_score(score + score_delta)

func add_combo_score(combo_score_delta):
	set_combo_score(combo_score + combo_score_delta)

"""
Reset all score data for a new game.
"""
func start_game():
	set_score(0)
	set_combo_score(0)