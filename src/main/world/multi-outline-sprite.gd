class_name MultiOutlineSprite
extends Sprite
"""
Draws an outline behind the parent's sprite.

For simple objects made of one sprite, an outline shader can be applied to the sprite itself. For complex objects made
of multiple sprites, an outline shader needs to be appied to the entire sprite group as a whole.
Unfortunately I can't find a way to accomplish this, so for now I am instead creating several small sprites which
follow the individual sprites around. It is a clumsy solution and I hope to fix this.
"""

onready var _parent := get_parent()

func _ready() -> void:
	z_as_relative = true
	
	# a z_index >= 0 would make this sprite not display the way it's supposed to
	z_index = min(-1, z_index)


func _process(delta) -> void:
	if texture != _parent.texture:
		texture = _parent.texture
		offset = _parent.offset
		vframes = _parent.vframes
		hframes = _parent.hframes
	if frame != _parent.frame:
		if vframes * hframes > 1:
			# setting frame when vframes * hframes <= 1 throws an error
			frame = _parent.frame
