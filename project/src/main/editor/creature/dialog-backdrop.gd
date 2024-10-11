extends ColorRect
## Darkens and pauses the game while a popup dialog is displayed.

## number of dialogs currently shown; we unpause when this decrements to zero
var _shown_dialogs := 0

func _on_Dialog_about_to_show() -> void:
	_shown_dialogs += 1
	if _shown_dialogs >= 1:
		Pauser.toggle_pause("dialog-backdrop", true)
		show()


func _on_Dialog_popup_hide() -> void:
	_shown_dialogs -= 1
	if _shown_dialogs <= 0:
		Pauser.toggle_pause("dialog-backdrop", false)
		hide()
