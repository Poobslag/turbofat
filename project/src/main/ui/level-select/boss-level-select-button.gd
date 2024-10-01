extends LevelSelectButton
## Button on the level select screen which launches a boss level, or a hardcore boss level.
##
## Boss levels are special because they open up new areas. They're decorated in an exciting way.

## Colors to use when the button is in different focused/pressed states
const NORMAL_CENTER := Color("00ffffff")
const NORMAL_BORDER := Color("6c4331")
const FOCUSED_CENTER := Color("2000c4ff")
const FOCUSED_BORDER := Color("80e1ff")
const PRESSED_CENTER := Color("4080e1ff")
const PRESSED_BORDER := Color("80e1ff")


func _ready() -> void:
	_refresh_button_colors()
	button_control.connect("focus_entered", self, "_on_ButtonControl_focus_entered")
	button_control.connect("focus_exited", self, "_on_ButtonControl_focus_exited")
	button_control.connect("button_down", self, "_on_ButtonControl_button_down")
	button_control.connect("button_up", self, "_on_ButtonControl_button_up")


## The boss level button does not use style colors.
func refresh_style_color(_color: Color) -> void:
	return


## When the node is resized, we update the shader so that textures are scaled appropriately.
func refresh_size() -> void:
	.refresh_size()
	
	if button_control:
		button_control.material.set_shader_param("node_size", rect_size)


## Updates the shader parameters based on whether the button is focused or pressed.
func _refresh_button_colors() -> void:
	if button_control.pressed:
		button_control.material.set_shader_param("center_color", PRESSED_CENTER)
		button_control.material.set_shader_param("border_color", PRESSED_BORDER)
	elif button_control.has_focus():
		button_control.material.set_shader_param("center_color", FOCUSED_CENTER)
		button_control.material.set_shader_param("border_color", FOCUSED_BORDER)
	else:
		button_control.material.set_shader_param("center_color", NORMAL_CENTER)
		button_control.material.set_shader_param("border_color", NORMAL_BORDER)


func _on_ButtonControl_focus_entered() -> void:
	_refresh_button_colors()
	._on_ButtonControl_focus_entered()


func _on_ButtonControl_focus_exited() -> void:
	_refresh_button_colors()
	._on_ButtonControl_focus_exited()


func _on_ButtonControl_button_down() -> void:
	_refresh_button_colors()
	._on_ButtonControl_button_down()


func _on_ButtonControl_button_up() -> void:
	_refresh_button_colors()
