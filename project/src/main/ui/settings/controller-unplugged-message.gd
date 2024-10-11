extends Panel
## Shows a "controller disconnected" message in the settings menu.
##
## When the player's controller disconnects during a puzzle, we pop up the settings menu and display a message.

func _ready() -> void:
	# hide by default; must be explicitly shown after the settings menu
	hide()


func _on_SettingsMenu_show() -> void:
	# hide by default; must be explicitly shown after the settings menu
	hide()
