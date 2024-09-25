extends Control
## Draws a stamp for the results hud.
##
## This animates a hand stamping down, leaving an ink stamp on the receipt.

## key: (String) grade
## value: (int) ink sprite animation frame for the specified grade
const INK_FRAMES_BY_GRADE := {
	"-": 1,
	"B-": 2,
	"B": 3,
	"B+": 4,
	"A-": 5,
	"A": 6,
	"A+": 7,
	"AA": 8,
	"AA+": 9,
	"S-": 10,
	"S": 11,
	"S+": 12,
	"SS": 13,
	"SS+": 14,
	"SSS": 15,
	"M": 16,
}

var _blueprint: ResultsHudBlueprint

onready var _animation_player := $AnimationPlayer

onready var _ink := $InkClip/Ink
onready var _hand := $Hand

## Plays an animation of a hand stamping down, leaving an ink stamp on the receipt.
func play(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	_animation_player.play("play")
	
	var rank := _blueprint.rank_result.rank
	var grade := Ranks.grade(rank)
	_ink.frame = INK_FRAMES_BY_GRADE.get(grade, 1)


## Resets the stamp to its default state before the animation plays.
func reset(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	_ink.visible = false
	_hand.visible = false
	_animation_player.stop()
