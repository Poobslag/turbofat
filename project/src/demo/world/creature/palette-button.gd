class_name PaletteButton
extends ColorRect
## Clickable control which shows a palette's colors.

signal pressed

## Updates the button's colors to match the specified palette.
func set_palette(palette: Dictionary) -> void:
	color = palette["line_rgb"]
	$HBoxContainer/Body.color = Color(palette["body_rgb"])
	$HBoxContainer/VBoxContainer/Eye.color = Color(palette["eye_rgb_0"])
	$HBoxContainer/VBoxContainer/Belly.color = Color(palette["belly_rgb"])
	$HBoxContainer/VBoxContainer/Horn.color = Color(palette["horn_rgb"])


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_click"):
		if is_inside_tree():
			get_tree().set_input_as_handled()
		emit_signal("pressed")
