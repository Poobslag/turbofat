extends CanvasLayer
## UI elements for the career map's settings menu.

func _on_SettingsButton_pressed() -> void:
	$SettingsMenu.show()


func _on_SettingsMenu_show() -> void:
	$Control/SettingsButton.hide()


func _on_SettingsMenu_hide() -> void:
	$Control/SettingsButton.show()


func _on_SettingsMenu_quit_pressed() -> void:
	SceneTransition.pop_trail()


func _on_SettingsMenu_other_quit_pressed() -> void:
	PlayerData.career.hours_passed = CareerData.HOURS_PER_CAREER_DAY
	PlayerData.career.push_career_trail()
