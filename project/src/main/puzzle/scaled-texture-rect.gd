extends TextureRect
## A TextureRect which uses the 'rect_scale' property to display its texture at a different scale.
##
## This TextureRect should be placed within a parent control. It will adjust itself to occopy the same region as its
## parent.
##
## TextureRects support tiling, but have no concept of a tile offset or tile scale. Controls have a 'rect_scale'
## property, but scaling controls causes issues with the layout manager. This script adjusts its rect_scale value
## despite these layout manager issues, adjusting its size and position to remedy them.

func _ready() -> void:
	get_parent().connect("resized", self, "_on_Control_resized")


func _on_Control_resized() -> void:
	# Adjust the size to match its parent, adjusting for scaling.
	rect_size = get_parent().rect_size / rect_scale
