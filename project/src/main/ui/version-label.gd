extends Label
## Displays a version label like '0.3100' in the bottom right corner.

func _ready() -> void:
	text = ProjectSettings.get_setting("application/config/version")


## When the label is resized, we move it to the bottom-right corner.
func _on_resized() -> void:
	set_global_position(get_viewport_rect().size - rect_size - Vector2(10, 10))
