extends VBoxContainer
"""
User interface control which lets the player pick their mode in practice mode.

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
func set_selected_mode(selected_mode: String) -> void:
	match selected_mode:
		"Survival":
			$Buttons/Survival.pressed = true
		"Ultra":
			$Buttons/Ultra.pressed = true
		"Sprint":
			$Buttons/Sprint.pressed = true
		"Rank":
			$Buttons/Rank.pressed = true


"""
Sets the currently selected scenario, used for generating a description.
"""
func set_scenario(scenario: ScenarioSettings) -> void:
	var new_description := ""
	match get_selected_mode():
		"Survival":
			var target_value := scenario.finish_condition.value
			if scenario.finish_condition.has_meta("lenient_value"):
				target_value = scenario.finish_condition.get_meta("lenient_value")
			
			new_description = "Survive as the pieces get faster and faster! Can you clear %s lines?" \
					% StringUtils.comma_sep(target_value)
		"Ultra":
			new_description = "Earn ¥%s as quickly as possible!" \
					% StringUtils.comma_sep(scenario.finish_condition.value)
		"Sprint":
			new_description = "Earn as much money as you can in %s!" \
					% StringUtils.format_duration(scenario.finish_condition.value)
		"Rank":
			new_description = "An escalating set of challenges."
			match scenario.success_condition.type:
				Milestone.SCORE:
					new_description += " Finish with ¥%s to achieve this rank!" \
							% StringUtils.comma_sep(scenario.success_condition.value)
				Milestone.TIME_UNDER:
					new_description += " Finish in %s to achieve this rank!" \
							% StringUtils.format_duration(scenario.success_condition.value)
	$Desc.text = new_description


func _on_Button_pressed() -> void:
	emit_signal("mode_changed")
