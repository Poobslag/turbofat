extends Control
## Draws a 1up medal for the results hud.
##
## This animates a hand swiping by, dropping a medal on the receipt.

var _blueprint: ResultsHudBlueprint

onready var _animation_player := $AnimationPlayer

onready var _medal := $Medal
onready var _hand := $Hand

## Plays an animation of a hand swiping by, dropping a medal on the receipt.
func play(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	if _blueprint.should_show_medal():
		_animation_player.play("play")


## Resets the medal to its default state before the animation plays.
func reset(new_blueprint: ResultsHudBlueprint) -> void:
	_blueprint = new_blueprint
	_medal.visible = false
	_hand.visible = false
	_animation_player.stop()
