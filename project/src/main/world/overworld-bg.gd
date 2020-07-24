extends ColorRect
"""
Background drawn behind the overworld.
"""

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	rect_size = get_viewport_rect().size


func _on_Viewport_size_changed() -> void:
	rect_size = get_viewport_rect().size
