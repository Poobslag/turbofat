extends Label
## Animates a message in the Creature Editor when the player saves.

onready var _animation_player := $AnimationPlayer

func _on_CreatureSaver_save_button_pressed() -> void:
	_animation_player.play("play")
