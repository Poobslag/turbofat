extends Control

var score = 0 setget set_score
var combo_score = 0 setget set_combo_score

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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

func start_game():
	set_score(0)
	set_combo_score(0)