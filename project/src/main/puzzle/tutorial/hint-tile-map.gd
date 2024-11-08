extends TileMap
## A hint diagram which is shown during tutorials.
##
## This translucent hint diagram goes behind the playfield, showing the player where to drop their pieces.

func _ready() -> void:
	$CornerMap.dirty = true
