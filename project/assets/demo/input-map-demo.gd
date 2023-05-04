extends Control
## Demonstrates the project's input map.
##
## Any keys, mouse actions or joystick inputs will be printed to the screen.

func _process(delta: float) -> void:
	var action_string := ""
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			action_string += " +%s" % [action]
		if Input.is_action_just_released(action):
			action_string += " -%s" % [action]
	if not action_string.is_empty():
		if not $Label.text.is_empty():
			$Label.text += "\n"
		$Label.text += action_string
		
		while $Label.get_line_count() > $Label.get_visible_line_count():
			$Label.text = StringUtils.substring_after($Label.text, "\n")
