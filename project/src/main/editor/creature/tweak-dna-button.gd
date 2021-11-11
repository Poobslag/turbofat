extends Button
## A button with a DNA symbol on it.

func _on_button_down() -> void:
	$TextureRect.modulate.a = 0.6


func _on_button_up() -> void:
	$TextureRect.modulate.a = 1.0
