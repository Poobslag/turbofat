tool
extends Sprite

enum Size {
	SMALL,
	LARGE,
}

export (Size) var size := Size.SMALL

## Editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle

onready var _animation_player := $AnimationPlayer

func _ready():
	if Engine.editor_hint:
		# update the tree's appearance, but don't play any animations
		_refresh_grass_in_editor()
	else:
		# launch the grass's animations
		_animation_player.play("small" if size == Size.SMALL else "large")
		_animation_player.advance(rand_range(0, _animation_player.get_current_animation_length()))


func _refresh_grass_in_editor() -> void:
	frame = 3 if size == Size.SMALL else 0


## Randomizes the grass's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	size = Utils.rand_value([Size.SMALL, Size.LARGE])
	flip_h = randf() < 0.5
	
	_refresh_grass_in_editor()
	property_list_changed_notify()
