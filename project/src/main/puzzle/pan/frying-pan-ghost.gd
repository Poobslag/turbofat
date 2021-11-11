extends Sprite
## A frying pan which vanishes when the player loses a life.

export (Vector2) var velocity: Vector2

func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.is_editor_hint():
		queue_free()
