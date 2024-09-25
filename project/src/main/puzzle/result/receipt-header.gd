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
	
	var level_failed := false
	if blueprint.rank_result.lost:
		# player quit or lost all their lives
		level_failed = true
	elif CurrentLevel.boss_level and not blueprint.rank_result.success:
		# player failed a career mode boss level
		level_failed = true
	
	if level_failed:
		_label.text = tr("Level\nFailed...")
	else:
		_label.text = tr("Level\nComplete!")
