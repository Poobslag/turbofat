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
var customer_queue := CustomerQueue.new()

var career: CareerData
var practice := PracticeData.new()

var money := 0 setget set_money

## the player's playtime in seconds
var seconds_played := 0.0

## periodically increments the 'seconds_played' value
var seconds_played_timer: Timer

func _ready() -> void:
	career = CareerData.new()
	add_child(career)
	
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
	career.reset()
	practice.reset()
	money = 0
	seconds_played = 0.0
	
	emit_signal("level_history_changed")


func set_money(new_money: int) -> void:
	money = new_money
	emit_signal("money_changed", money)


## Returns a random creature definition based on the player's location.
##
## Parameters:
## 	'include_predefined_customers': If 'true' the function has a chance to return a creature from a library of
## 		predefined creatures instead of a randomly generated one.
func random_customer_def(include_predefined_customers: bool = false) -> CreatureDef:
	var creature_type: int = Creatures.Type.DEFAULT
	if PlayerData.career.is_career_mode():
		creature_type = PlayerData.career.current_region().population.random_creature_type()
	return CreatureLoader.random_customer_def(include_predefined_customers, creature_type)


func _on_SecondsPlayedTimer_timeout() -> void:
	seconds_played += SECONDS_PLAYED_INCREMENT
