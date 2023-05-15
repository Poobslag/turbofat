extends TextureRect
## TextureRect which uses the 'rect_scale' property to display its texture at a different scale.
##
## This TextureRect should be placed within a parent control. It will adjust itself to occopy the same region as its
## parent.
##
## TextureRects support tiling, but have no concept of a tile offset or tile scale. Controls have a 'rect_scale'
## property, but scaling controls causes issues with the layout manager. This script adjusts its rect_scale value
## despite these layout manager issues, adjusting its size and position to remedy them.

enum TileMode {
	TILE_BOTH,
	TILE_X,
	TILE_Y,
}

@export (TileMode) var tile_mode: int = TileMode.TILE_BOTH

func _ready() -> void:
	get_parent().connect("resized", Callable(self, "_on_Control_resized"))


func _on_Control_resized() -> void:
	# adjust the scale
	match tile_mode:
		TileMode.TILE_BOTH:
			pass
		TileMode.TILE_Y:
			scale.x = get_parent().size.x / texture.get_size().x
			scale.y = scale.x
		TileMode.TILE_X:
			scale.y = get_parent().size.y / texture.get_size().y
			scale.x = scale.y
	
	# Adjust the size to match its parent, adjusting for scaling.
	size = get_parent().size / scale
