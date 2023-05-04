class_name SmokeCluster
extends GPUParticles2D

## Velocity applied to the food when in the 'floating' state
@export var velocity := Vector2(0, -250)

func _ready() -> void:
	emitting = true


func _physics_process(delta: float) -> void:
	position += velocity * delta
	if not emitting:
		queue_free()
