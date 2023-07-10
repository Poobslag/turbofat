extends Node
## Demonstrates the project's input map.
##
## Any keys, mouse actions or joystick inputs will be printed to the screen.

onready var _label := $Label

func _process(_delta: float) -> void:
	var action_string := ""
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			action_string += " +%s" % [action]
		if Input.is_action_just_released(action):
			action_string += " -%s" % [action]
	if not action_string.empty():
		if not _label.text.empty():
			_label.text += "\n"
		_label.text += action_string
		
		while _label.get_line_count() > _label.get_visible_line_count():
			_label.text = StringUtils.substring_after(_label.text, "\n")
