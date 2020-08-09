extends ColorRect
"""
Darkens and pauses the game while a dialog is displayed.
"""

func _on_ConfirmationDialog_about_to_show() -> void:
	get_tree().paused = true
	show()


func _on_ConfirmationDialog_popup_hide() -> void:
	get_tree().paused = false
	hide()
