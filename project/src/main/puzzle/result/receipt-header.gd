extends TextureRect
## Draws the header for the results hud.
##
## This shows a dessert graphic with a message like "Level Complete!"

onready var _label := $Label
onready var _animation_player := $AnimationPlayer

func reset(_blueprint: ResultsHudBlueprint) -> void:
	visible = false
	_animation_player.stop()
	rect_scale = Vector2(1.0, 1.0)


## Plays an animation stamping the header onto the receipt, and applying a subtle shake effect.
func play(blueprint: ResultsHudBlueprint) -> void:
	visible = true
	_animation_player.play("play")
	
	if blueprint.rank_result.lost:
		_label.text = tr("Level\nFailed...")
	else:
		_label.text = tr("Level\nComplete!")
