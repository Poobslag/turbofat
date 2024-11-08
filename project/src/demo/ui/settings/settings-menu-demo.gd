extends Node
## Shows the settings menu.
##
## The settings menu is invisible by default, so a demo is necessary to view it.
##
## Keys:
## 	'1-6': Update quit type: QUIT, SAVE_AND_QUIT, GIVE_UP, SAVE_AND_QUIT_OR_GIVE_UP, RESTART_OR_GIVE_UP,
## 		QUIT_TO_DESKTOP

onready var _label := $Label
onready var _settings_menu := $SettingsMenu

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	_settings_menu.show()


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1:
			_settings_menu.quit_type = SettingsMenu.QuitType.QUIT
			_label.text = "QuitType.QUIT"
		KEY_2:
			_settings_menu.quit_type = SettingsMenu.QuitType.SAVE_AND_QUIT
			_label.text = "QuitType.SAVE_AND_QUIT"
		KEY_3:
			_settings_menu.quit_type = SettingsMenu.QuitType.GIVE_UP
			_label.text = "QuitType.GIVE_UP"
		KEY_4:
			_settings_menu.quit_type = SettingsMenu.QuitType.SAVE_AND_QUIT_OR_GIVE_UP
			_label.text = "QuitType.SAVE_AND_QUIT_OR_GIVE_UP"
		KEY_5:
			_settings_menu.quit_type = SettingsMenu.QuitType.RESTART_OR_GIVE_UP
			_label.text = "QuitType.RESTART_OR_GIVE_UP"
		KEY_6:
			_settings_menu.quit_type = SettingsMenu.QuitType.QUIT_TO_DESKTOP
			_label.text = "QuitType.QUIT_TO_DESKTOP"
