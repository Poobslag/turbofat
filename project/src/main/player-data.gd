extends Node
## Stores data about the player's progress.
##
## This data includes how well they've done on each level and how much money they've earned.
##
## Configuration data like the graphics and keybindings is stored in the SystemData class, not here.

signal money_changed(value)

## emitted when the player beats a level, or when the level history is reset or reloaded
signal level_history_changed

## the most money the player can have
const MAX_MONEY := 9999999999999999

## how often in seconds to increment the 'seconds_played' value
const SECONDS_PLAYED_INCREMENT := 0.619

var level_history := LevelHistory.new()
var chat_history := ChatHistory.new()

var creature_library := CreatureLibrary.new()
var creature_queue := CreatureQueue.new()

var story := StoryData.new()
var career := CareerData.new()

var money := 0 setget set_money

## the player's playtime in seconds
var seconds_played := 0.0

## periodically increments the 'seconds_played' value
var seconds_played_timer: Timer

func _ready() -> void:
	seconds_played_timer = Timer.new()
	seconds_played_timer.wait_time = SECONDS_PLAYED_INCREMENT
	seconds_played_timer.connect("timeout", self, "_on_SecondsPlayedTimer_timeout")
	add_child(seconds_played_timer)
	seconds_played_timer.start()


## Resets the player's in-memory data to a default state.
func reset() -> void:
	level_history.reset()
	chat_history.reset()
	creature_library.reset()
	story.reset()
	career.reset()
	money = 0
	seconds_played = 0.0
	
	emit_signal("level_history_changed")


func set_money(new_money: int) -> void:
	money = new_money
	emit_signal("money_changed", money)


func _on_SecondsPlayedTimer_timeout() -> void:
	seconds_played += SECONDS_PLAYED_INCREMENT
	
	if career.is_career_mode():
		career.daily_seconds_played += SECONDS_PLAYED_INCREMENT
