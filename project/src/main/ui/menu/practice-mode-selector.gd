extends VBoxContainer
"""
UI control for picking a mode in practice mode.

Also displays a description of the mode, 'Score 200 points as quickly as possible!'
"""

signal mode_changed

# group which ensures only one mode button is pressed
onready var button_group: ButtonGroup = $Buttons/Survival.group

"""
Returns the currently selected mode string such as 'Normal' or 'Expert'
"""
func get_selected_mode() -> String:
	return button_group.get_pressed_button().name


"""
Sets the currently selected mode string such as 'Survival' or 'Sprint'
"""
func set_selected_mode(new_selected_mode: String) -> void:
	match new_selected_mode:
		"Survival":
			$Buttons/Survival.pressed = true
		"Ultra":
			$Buttons/Ultra.pressed = true
		"Sprint":
			$Buttons/Sprint.pressed = true
		"Rank":
			$Buttons/Rank.pressed = true
		"Sandbox":
			$Buttons/Sandbox.pressed = true


"""
Sets the currently selected level, used for generating a description.
"""
func set_level(new_level: LevelSettings) -> void:
	var new_description := ""
	match get_selected_mode():
		"Survival":
			var target_value: int = new_level.finish_condition.value
			
			new_description = tr("Survive as the pieces get faster and faster! Can you clear %s lines?") \
					% StringUtils.comma_sep(target_value)
		"Ultra":
			new_description = tr("Earn ¥%s as quickly as possible!") \
					% StringUtils.comma_sep(new_level.finish_condition.value)
		"Sprint":
			new_description = tr("Earn as much money as you can in %s!") \
					% StringUtils.format_duration(new_level.finish_condition.value)
		"Rank":
			new_description = tr("An escalating set of challenges.")
			match new_level.success_condition.type:
				Milestone.SCORE:
					new_description += " " + tr("Finish with ¥%s to achieve this rank!") \
							% StringUtils.comma_sep(new_level.success_condition.value)
				Milestone.TIME_UNDER:
					new_description += " " + tr("Finish in %s to achieve this rank!") \
							% StringUtils.format_duration(new_level.success_condition.value)
		"Sandbox":
			new_description = tr("Just relax! There is no way to win or lose this mode.")
	$Desc.text = new_description


func _on_Button_pressed() -> void:
	emit_signal("mode_changed")
