extends Timer
## Activates idle animations for the robot dog.

## key: (String) animation name from the animation player
## value: (float) numeric weight for how often the animation should play
const IDLE_ANIMATION_WEIGHTS := {
	"glance-1": 5.0,
	"glance-2": 3.0,
	"walk": 2.0,
	"walk-and-glance": 1.0,
}

export (NodePath) var animation_player_path: NodePath

## defines idle animations for the robot dog
onready var _animation_player: AnimationPlayer = get_node(animation_player_path)

func _ready() -> void:
	start(rand_range(10, 20))

## When the timer times out, we play a random idle animation.
##
## The AnimationPlayer automatically returns the robot dog to the default animation afterwards using its 'auto queue'
## feature.
func _on_timeout() -> void:
	_animation_player.play(Utils.weighted_rand_value(IDLE_ANIMATION_WEIGHTS))
