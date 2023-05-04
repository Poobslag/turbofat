extends Node
## Shows the settings menu.
##
## The settings menu is invisible by default, so a demo is necessary to view it.

func _ready() -> void:
	$SettingsMenu.show_settings_menu()
