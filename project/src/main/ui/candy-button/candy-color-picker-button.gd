class_name CandyColorPickerButton
extends Button
## Button showing a color preset within the candy color picker.

const DEFAULT_BORDER_COLOR := Color("cbaec1")
const FOCUSED_BORDER_COLOR := Color.white
const HOVERED_BORDER_COLOR := Color.white

## The currently selected color.
export var color: Color = Color.black setget set_color

## Panel which draws the button's graphics.
onready var _panel := $Panel

func _ready() -> void:
	_refresh()


func set_color(new_color: Color) -> void:
	color = new_color
	_refresh()


## Update the panel's appearance based on the currently selected color and button state.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	if has_focus():
		_panel.get("custom_styles/panel").set_border_color(FOCUSED_BORDER_COLOR)
	elif is_hovered():
		_panel.get("custom_styles/panel").set_border_color(HOVERED_BORDER_COLOR)
	else:
		_panel.get("custom_styles/panel").set_border_color(DEFAULT_BORDER_COLOR)
	_panel.get("custom_styles/panel").set_bg_color(color)


func _on_mouse_entered() -> void:
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
	_refresh()


func _on_mouse_exited() -> void:
	if is_inside_tree():
		yield(get_tree(), "idle_frame")
	_refresh()


func _on_focus_entered() -> void:
	_refresh()


func _on_focus_exited() -> void:
	_refresh()
