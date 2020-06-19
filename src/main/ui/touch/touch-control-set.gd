extends Control
"""
A set of four buttons the player uses to control the game.
"""

export (String) var up_action: String
export (String) var down_action: String
export (String) var left_action: String
export (String) var right_action: String

func _ready() -> void:
	$VerticalButtons/Up/Button.action = up_action
	$VerticalButtons/Down/Button.action = down_action
	$HorizontalButtons/Left/Button.action = left_action
	$HorizontalButtons/Right/Button.action = right_action
	for touch_control_button_obj in [
			$VerticalButtons/Up/Button, $VerticalButtons/Down/Button,
			$HorizontalButtons/Left/Button, $HorizontalButtons/Right/Button]:
		var touch_control_button: TouchControlButton = touch_control_button_obj
		touch_control_button.refresh()
