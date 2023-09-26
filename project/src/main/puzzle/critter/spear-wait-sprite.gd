class_name SpearWaitSprite
extends Sprite
## Draws the speech bubble warning the player that a spear will appear soon.

onready var _animation_player := $AnimationPlayer

## Shows a '...' speech bubble warning the player that a spear will appear soon.
func show_wait() -> void:
	show()
	_animation_player.play("wait")


## Shows a '!' speech bubble warning the player that a spear will appear immediately.
func show_wait_end() -> void:
	show()
	_animation_player.play("wait-end")
