extends CheckBox
"""
UI control for toggling whether or not the protagonists have very long names.

This is useful for preventing bugs where a player with a long name causes text to overrun the chat window.
"""

# long name to substitute for the creature_name field
const LONG_NAME := "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"

# long name to substitute for the creature_short_name field
const LONG_SHORT_NAME := "WWWWWWWWWWWWWWW"


func _ready() -> void:
	pressed = PlayerData.creature_library.get_player_def().creature_name == LONG_NAME


func _on_toggled(button_pressed: bool) -> void:
	if button_pressed:
		PlayerData.creature_library.get_player_def().creature_name = LONG_NAME
		PlayerData.creature_library.get_player_def().creature_short_name = LONG_SHORT_NAME
		PlayerData.creature_library.get_sensei_def().creature_name = LONG_NAME
		PlayerData.creature_library.get_sensei_def().creature_short_name = LONG_SHORT_NAME
	else:
		PlayerData.creature_library.get_player_def().creature_name = CreatureDef.DEFAULT_NAME
		PlayerData.creature_library.get_player_def().creature_short_name = CreatureDef.DEFAULT_NAME
		PlayerData.creature_library.get_sensei_def().creature_name = "Fat Sensei"
		PlayerData.creature_library.get_sensei_def().creature_short_name = "Turbo"
