extends Node
## Stores data about the system and its configuration.
##
## This data includes configuration data like language, keybindings, and graphics settings.
##
## Data about the player's progress and high scores is stored in the PlayerData class, not here.

var gameplay_settings := GameplaySettings.new()
var graphics_settings := GraphicsSettings.new()
var volume_settings := VolumeSettings.new()
var touch_settings := TouchSettings.new()
var keybind_settings := KeybindSettings.new()
var misc_settings := MiscSettings.new()

## We accelerate scene transitions and animations during development.
var fast_mode := OS.is_debug_build()

## Resets the system's in-memory data to a default state.
func reset() -> void:
	gameplay_settings.reset()
	graphics_settings.reset()
	volume_settings.reset()
	touch_settings.reset()
	keybind_settings.reset()
	misc_settings.reset()
