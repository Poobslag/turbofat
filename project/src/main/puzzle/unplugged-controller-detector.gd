extends Node
## Pops up a "controller disconnected" message in the settings menu when the player's controller disconnects.

onready var _settings_menu: SettingsMenu = get_parent()

func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


## If the player's controller disconnects during gameplay, we pop up the settings menu with a message.
##
## When the player's controller reconnects, we hide the message.
func _on_joy_connection_changed(_device_id: int, connected: bool) -> void:
	if connected == false \
			and InputManager.input_mode == InputManager.InputMode.JOYPAD \
			and PuzzleState.game_active:
		# show the 'controller disconnected' message
		_settings_menu.show()
		_settings_menu.controller_unplugged_message.show()
	
	if connected == true:
		# hide the 'controller disconnected' message
		_settings_menu.controller_unplugged_message.hide()
