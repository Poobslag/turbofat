extends Node
"""
Stores data about the player's progress in memory.

This data includes how well they've done on each level and how much money they've earned.
"""

signal money_changed(value)

# emitted when the player beats a level, or when the level history is reset or reloaded
signal level_history_changed

var level_history := LevelHistory.new()
var chat_history := ChatHistory.new()

var creature_library := CreatureLibrary.new()
var creature_queue := CreatureQueue.new()

var gameplay_settings := GameplaySettings.new()
var volume_settings := VolumeSettings.new()
var touch_settings := TouchSettings.new()
var keybind_settings := KeybindSettings.new()
var miscellaneous_settings := MiscellaneousSettings.new()

var money := 0 setget set_money

"""
Resets the player's in-memory data to a default state.
"""
func reset() -> void:
	level_history.reset()
	chat_history.reset()
	creature_library.reset()
	
	gameplay_settings.reset()
	volume_settings.reset()
	touch_settings.reset()
	keybind_settings.reset()
	money = 0
	
	emit_signal("level_history_changed")


func set_money(new_money: int) -> void:
	money = new_money
	emit_signal("money_changed", money)
