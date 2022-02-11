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
	
	CurrentCutscene.connect("cutscene_played", self, "_on_CurrentCutscene_cutscene_played")


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


## When an epilogue cutscene is played in career mode, we advance the player to the next region
func _on_CurrentCutscene_cutscene_played(chat_key: String) -> void:
	var region := CareerLevelLibrary.region_for_distance(career.distance_travelled)
	if chat_key == region.get_epilogue_chat_key():
		# advance the player to the next region
		var old_distance_travelled := career.distance_travelled
		career.distance_travelled = max(career.distance_travelled, region.distance + region.length)
		career.max_distance_travelled = max(career.max_distance_travelled, career.distance_travelled)
		if career.distance_travelled > old_distance_travelled:
			career.distance_earned += (career.distance_travelled - old_distance_travelled)
