extends Control

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
