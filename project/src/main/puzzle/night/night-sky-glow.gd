extends Sprite
## A circular glow shown behind the onion.

export (NodePath) var onion_sprite_path: NodePath

## The onion which we reference when updating our position.
onready var onion_sprite: Node2D = get_node(onion_sprite_path)

## Tween which increases/decreases our size gradually.
onready var _tween := $Tween
onready var _tween_values := [Vector2(0.44, 0.44), Vector2(0.55, 0.55)]

func _ready() -> void:
	_start_tween()


func _process(_delta: float) -> void:
	position = onion_sprite.position


func _start_tween() -> void:
	_tween.interpolate_property(self, "scale", _tween_values[0], _tween_values[1],
			5.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	_tween.start()


## Increase/decrease our size slightly.
##
## Each time this is called, we restart the tween and alternate between growing or shrinking.
func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void:
	_tween_values.invert()
	_start_tween()
