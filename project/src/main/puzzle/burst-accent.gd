tool
extends PackedSprite
## A colored accent sprite which appears behind a combo/spin/squish indicator.

## The unmodified scale/rotation before pulsing
export (Vector2) var base_scale: Vector2 = Vector2.ONE setget set_base_scale

## Scale modifiers applied by an animation
export (Vector2) var scale_modifier: Vector2 = Vector2.ONE setget set_scale_modifier

func set_base_scale(new_base_scale: Vector2) -> void:
	base_scale = new_base_scale
	_refresh_scale()


func set_scale_modifier(new_scale_modifier: Vector2) -> void:
	scale_modifier = new_scale_modifier
	_refresh_scale()


func _refresh_scale() -> void:
	scale = base_scale * scale_modifier
