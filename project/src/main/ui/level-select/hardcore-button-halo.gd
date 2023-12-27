extends Control
## Displays a dark halo behind hardcore level select buttons.

onready var _sprite := $Sprite

func _ready() -> void:
	_refresh_size()


## Center the halo and adjust its size based on the button's size.
func _refresh_size() -> void:
	if not _sprite:
		return
	
	_sprite.scale = rect_size * 0.012
	_sprite.position = rect_size * Vector2(0.5, 0.5)


func _on_resized() -> void:
	_refresh_size()
