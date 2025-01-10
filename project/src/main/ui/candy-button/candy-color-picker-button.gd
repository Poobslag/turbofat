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


func _apply_mouse_entered_effects() -> void:
	# disconnect our one-shot method
	if get_tree().is_connected("idle_frame", self, "_apply_mouse_entered_effects"):
		get_tree().disconnect("idle_frame", self, "_apply_mouse_entered_effects")
	_refresh()


func _apply_mouse_exited_effects() -> void:
	if get_tree().is_connected("idle_frame", self, "_apply_mouse_exited_effects"):
		get_tree().disconnect("idle_frame", self, "_apply_mouse_exited_effects")
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
		# Wait a frame before applying mouse entered effects. We use a one-shot listener method instead of a yield
		# statement to avoid 'class instance is gone' errors.
		if not get_tree().is_connected("idle_frame", self, "_apply_mouse_entered_effects"):
			get_tree().connect("idle_frame", self, "_apply_mouse_entered_effects")
	else:
		_apply_mouse_entered_effects()


func _on_mouse_exited() -> void:
	if is_inside_tree():
		# Wait a frame before applying mouse exited effects. We use a one-shot listener method instead of a yield
		# statement to avoid 'class instance is gone' errors.
		if not get_tree().is_connected("idle_frame", self, "_apply_mouse_exited_effects"):
			get_tree().connect("idle_frame", self, "_apply_mouse_exited_effects")
	else:
		_apply_mouse_exited_effects()


func _on_focus_entered() -> void:
	_refresh()


func _on_focus_exited() -> void:
	_refresh()
