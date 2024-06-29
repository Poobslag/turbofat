extends PopupPanel
## A popup which includes a ColorPicker, similar to ColorPickerButton.

signal color_changed(color)

## Virtual property; value is only exposed through getters/setters
var selected_color: Color setget set_selected_color, get_selected_color

onready var _color_picker := $ColorPicker

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		# ignore input unless our Popup is showing
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if not get_global_rect().has_point(event.position):
			hide()
	elif event.is_action_pressed("ui_cancel"):
		hide()


func set_selected_color(new_selected_color: Color) -> void:
	_color_picker.color = new_selected_color


func get_selected_color() -> Color:
	return _color_picker.color


func _on_ColorPicker_color_changed(color: Color) -> void:
	emit_signal("color_changed", color)
