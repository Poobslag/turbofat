extends Control
## Shows an animated 'GOAL' label over the goal on the progress board.
##
## This label's letters bounce up and down, and it animates and disappears if the player reaches the goal.

var _tween: SceneTreeTween

onready var _goal_label := $Label
onready var _goal_sound := $GoalSound
onready var _animation_player := $AnimationPlayer

func _ready() -> void:
	_goal_label.bbcode_enabled = true
	_goal_label.bbcode_text = "[center][wave amp=40 freq=8]%s[/wave][/center]" % [tr("GOAL")]


## Moves the label to the goal.
##
## Parameters:
## 	'goal_spot_position': Position of the ProgressBoardSpot for the goal.
func move_to_goal_spot(goal_spot_position: Vector2) -> void:
	rect_position = goal_spot_position - rect_pivot_offset


## When the player reaches a goal level, we play a special animation.
func _on_Player_travelling_finished() -> void:
	if PlayerData.career.is_boss_level():
		_goal_sound.play()
		_animation_player.play("play")
		
		# flash different colors
		_tween = Utils.recreate_tween(self, _tween)
		var rainbow_colors := ProgressBoard.RAINBOW_CHALK_COLORS.duplicate()
		rainbow_colors.shuffle()
		for i in range(rainbow_colors.size()):
			_tween.tween_callback(_goal_label, "set", ["custom_colors/default_color", rainbow_colors[i]])
			_tween.tween_interval(ProgressBoard.RAINBOW_INTERVAL)
	else:
		_tween = Utils.kill_tween(_tween)
		_goal_label.set("custom_colors/default_color", ProgressBoard.DEFAULT_CHALK_COLOR)
