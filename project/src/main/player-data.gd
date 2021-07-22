extends Node
"""
Stores data about the player's progress in memory.

This data includes how well they've done on each level and how much money they've earned.
"""

signal money_changed(value)

# emitted when the player beats a level, or when the level history is reset or reloaded
signal level_history_changed

# how often in seconds to increment the 'seconds_played' value
const SECONDS_PLAYED_INCREMENT := 0.619

var level_history := LevelHistory.new()
var chat_history := ChatHistory.new()

var creature_library := CreatureLibrary.new()
var creature_queue := CreatureQueue.new()

var gameplay_settings := GameplaySettings.new()
var graphics_settings := GraphicsSettings.new()
var volume_settings := VolumeSettings.new()
var touch_settings := TouchSettings.new()
var keybind_settings := KeybindSettings.new()
var misc_settings := MiscSettings.new()

var money := 0 setget set_money

# the player's playtime in seconds
var seconds_played := 0.0

# periodically increments the 'seconds_played' value
var seconds_played_timer: Timer

func _ready() -> void:
	seconds_played_timer = Timer.new()
	seconds_played_timer.wait_time = SECONDS_PLAYED_INCREMENT
	seconds_played_timer.connect("timeout", self, "_on_SecondsPlayedTimer_timeout")
	add_child(seconds_played_timer)
	seconds_played_timer.start()


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
	seconds_played = 0.0
	
	emit_signal("level_history_changed")


func set_money(new_money: int) -> void:
	money = new_money
	emit_signal("money_changed", money)


func _on_SecondsPlayedTimer_timeout() -> void:
	seconds_played += SECONDS_PLAYED_INCREMENT
