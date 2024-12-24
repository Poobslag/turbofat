extends PopupPanel
## A popup which includes a ColorPicker, similar to ColorPickerButton.

## emitted when the color is changed via the color picker ui
signal color_changed(color)

## Virtual property; value is only exposed through getters/setters
var color_presets: Array setget set_color_presets

## Virtual property; value is only exposed through getters/setters
var selected_color: Color setget set_selected_color, get_selected_color

onready var _color_picker := $ColorPicker

func _ready() -> void:
	_refresh_size()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		return
	if not is_visible_in_tree():
		# ignore input unless our Popup is showing
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		if not get_global_rect().has_point(event.position):
			hide()
			if is_inside_tree():
				get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		hide()
		if is_inside_tree():
			get_tree().set_input_as_handled()


func set_color_presets(new_color_presets: Array) -> void:
	_color_picker.color_presets = new_color_presets


func set_selected_color(new_selected_color: Color) -> void:
	_color_picker.color = new_selected_color


func get_selected_color() -> Color:
	return _color_picker.color


func _refresh_size() -> void:
	rect_size = _color_picker.rect_min_size


func _on_about_to_show() -> void:
	_refresh_size()
	_color_picker.grab_focus()


func _on_ColorPicker_color_changed(color: Color) -> void:
	emit_signal("color_changed", color)


func _on_ColorPicker_resized() -> void:
	if not _color_picker:
		# _color_picker's resized signal is called once before our onready signal
		return
	
	# Avoid a Stack Overflow where changing our size triggers another _on_resized() event
	_color_picker.disconnect("resized", self, "_on_ColorPicker_resized")
	_refresh_size()
	_color_picker.connect("resized", self, "_on_ColorPicker_resized")


func _on_visibility_changed() -> void:
	if visible:
		if is_inside_tree():
			yield(get_tree(), "idle_frame")
		_color_picker.grab_focus()
