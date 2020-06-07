extends Node2D
"""
Handles animations and audio/visual effects for the restaurant and its creatures.
"""

# the creature which food is currently being served to
var current_creature_index := 0

# fields which control the screen shake effect
var _shake_total_seconds := 0.0
var _shake_remaining_seconds := 0.0
var _shake_magnitude := 2.5

var _shake_position: Vector2
var camera_position := Vector2(-89.881, -104.904)

# all of the seats in the scene. each 'seat' includes a table, chairs, a creature, etc...
onready var _seats := [$Seat1, $Seat2, $Seat3]
onready var _creatures := [$Creature1, $Creature2, $Creature3]

func _ready() -> void:
	for i in range(3):
		_get_seat(i).set_creature(_creatures[i])
		_get_seat(i).refresh()


func _process(delta: float) -> void:
	if _shake_remaining_seconds > 0:
		_shake_remaining_seconds -= delta
		if _shake_remaining_seconds <= 0:
			_shake_position = Vector2.ZERO
		else:
			var max_shake := _shake_magnitude * _shake_remaining_seconds / _shake_total_seconds
			_shake_position = Vector2(rand_range(-max_shake, max_shake), rand_range(-max_shake, max_shake))
	position = _shake_position + camera_position


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.

Parameters:
	'creature_def': The colors and textures used to draw the creature.
"""
func summon_creature(creature_def: Dictionary, creature_index: int = -1) -> void:
	get_creature(creature_index).summon(creature_def)
	_get_seat(creature_index).refresh()


func set_fatness(fatness_percent: float, creature_index: int = -1) -> void:
	get_creature(creature_index).set_fatness(fatness_percent)


func get_fatness(creature_index: int = -1) -> float:
	return get_creature(creature_index).get_fatness()


"""
Returns the creature with the specified optional index. Defaults to the creature being fed.
"""
func get_creature(creature_index: int = -1) -> Control:
	return _creatures[current_creature_index] if creature_index == -1 else _creatures[creature_index]


"""
Returns the seat with the specified optional index. Defaults to the seat of the creature being fed.
"""
func _get_seat(seat_index: int = -1) -> Control:
	return _seats[current_creature_index] if seat_index == -1 else _seats[seat_index]


func _on_Creature_food_eaten() -> void:
	_shake_total_seconds = 0.16
	_shake_remaining_seconds = 0.16
