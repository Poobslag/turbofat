extends Node
## Demonstrates the eight-way touchscreen inputs.
##
## Enable emulate_desktop_from_mouse in the project settings to use this demo.
##
## Keys:
## 	[+,-]: Increase/decrease the size of the EightWay

var actions := [
	"ui_up", "ui_down", "ui_left", "ui_right",
	"soft_drop", "hard_drop", "rotate_cw", "rotate_ccw",
]

onready var _eight_way := $EightWay
onready var _label := $Label

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_EQUAL: _eight_way.rect_scale *= 1.3
		KEY_MINUS: _eight_way.rect_scale /= 1.3


func _process(_delta: float) -> void:
	var output := ""
	for action in actions:
		if Input.is_action_just_pressed(action):
			output += "!%s! " % action
		elif Input.is_action_pressed(action):
			output += "%s " % action
	_label.text = output
