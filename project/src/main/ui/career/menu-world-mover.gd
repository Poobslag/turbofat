extends Node2D
## Keeps the overworld centered on top of a menu scene.
##
## This should likely be implemented with a Camera2D, but the Camera2D was introducing other bugs. This is an easy
## short-term fix.

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_Viewport_size_changed")
	_refresh_position()


func _refresh_position() -> void:
	position = (get_viewport_rect().size - Vector2(1024, 600)) * Vector2(0.5, 0.5)


func _on_Viewport_size_changed() -> void:
	_refresh_position()
