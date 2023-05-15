extends Sprite2D
## Circular glow shown behind the onion.

@export (NodePath) var onion_sprite_path: NodePath

## Onion which we reference when updating our position.
@onready var onion_sprite: Node2D = get_node(onion_sprite_path)

## Increases/decreases our size gradually.
@onready var _tween: Tween
@onready var _tween_values := [Vector2(0.44, 0.44), Vector2(0.55, 0.55)]

func _ready() -> void:
	_start_tween()


func _process(_delta: float) -> void:
	position = onion_sprite.position


func _start_tween() -> void:
	scale = _tween_values[0]
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_property(self, "scale", _tween_values[1], 5.0) \
			super.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.chain().tween_callback(Callable(self, "_on_Tween_completed"))


## Increase/decrease our size slightly.
##
## Each time this is called, we restart the tween and alternate between growing or shrinking.
func _on_Tween_completed() -> void:
	_tween_values.invert()
	_start_tween()
