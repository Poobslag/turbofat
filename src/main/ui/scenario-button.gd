class_name ScenarioButton
extends VBoxContainer
"""
Button which launches a scenario from the scenario menu. Includes a clickable button with the scenario difficulty and
the player's high score on a separate label.
"""

# signal emitted when the player presses the scenario button
signal pressed

export (String) var scenario_name: String

func _ready() -> void:
	$Button.text = scenario_name.split("-")[1].capitalize()
	$Best.text = get_best_text(scenario_name)


"""
Disables the scenario so it can't be chosen. Displays a message describing how to unlock the scenario.
"""
func disable(unlock_message: String) -> void:
	$Button.disabled = true
	$Best.text = unlock_message


"""
Calculates the label text for displaying a player's best scenario performance.
"""
func get_best_text(scenario_name: String) -> String:
	return ""


func _on_Button_pressed() -> void:
	emit_signal("pressed")
