class_name CritterPoof
extends Sprite2D
## Poof cloud which appears when a critter appears/disappears.

## emitted when the 'poof' animation finishes
signal animation_finished

@onready var _animation_player := $AnimationPlayer

func _ready() -> void:
	visible = false


func play_poof_animation() -> void:
	_animation_player.play("poof")


func is_poof_animation_playing() -> bool:
	return _animation_player.is_playing()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_signal("animation_finished")
