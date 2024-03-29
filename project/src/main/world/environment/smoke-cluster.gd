class_name SmokeCluster
extends Particles2D

## Velocity applied to the food when in the 'floating' state
export (Vector2) var velocity := Vector2(0, -250)

func _ready() -> void:
	emitting = true


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if not emitting:
		queue_free()
