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

# the object's original position before the screen shake effect began
var _shake_original_position: Vector2

# all of the seats in the scene. each 'seat' includes a table, chairs, a creature, etc...
onready var _seats := [$Seat1, $Seat2, $Seat3]

func _ready() -> void:
	$Seat1.set_door_sound_position(Vector2(-500, 0))
	$Seat2.set_door_sound_position(Vector2(-1500, 0))
	$Seat3.set_door_sound_position(Vector2(-2500, 0))
	play_door_chime(0.0)


func _process(delta: float) -> void:
	if _shake_remaining_seconds > 0:
		_shake_remaining_seconds -= delta
		if _shake_remaining_seconds <= 0:
			position = _shake_original_position
		else:
			var max_shake := _shake_magnitude * _shake_remaining_seconds / _shake_total_seconds
			var shake_vector := Vector2(rand_range(-max_shake, max_shake), rand_range(-max_shake, max_shake))
			position = _shake_original_position + shake_vector


"""
Launches the 'feed' animation, hurling a piece of food at the creature and having them catch it.
"""
func feed() -> void:
	_seats[current_creature_index].get_node("Creature").feed()


"""
Recolors the creature according to the specified creature definition. This involves updating shaders and sprite
properties.

Parameters:
	'creature_def': The colors and textures used to draw the creature.
"""
func summon_creature(creature_def: Dictionary, creature_index: int = -1) -> void:
	get_seat(creature_index).get_node("Creature").summon(creature_def)


"""
Increases/decreases the creature's fatness, playing an animation which gradually applies the change.

Parameters:
	'fatness_percent': Controls how fat the creature should be; 5.0 = 5x normal size
	
	'creature_index': (Optional) The creature to be altered. Defaults to the current creature.
"""
func set_fatness(fatness_percent: float, creature_index: int = -1) -> void:
	get_seat(creature_index).get_node("Creature/FatPlayer").set_fatness(fatness_percent)


"""
Returns the creature's fatness, a float which determines how fat the creature should be; 5.0 = 5x normal size

Parameters:
	'creature_index': (Optional) The creature to ask about. Defaults to the current creature.
"""
func get_fatness(creature_index: int = -1) -> float:
	return get_seat(creature_index).get_node("Creature/FatPlayer").get_fatness()


"""
Returns the seat corresponding to the specified optional index. If the index is omitted, returns the current seat of
the creature currently being fed.

Parameters:
	'creature_index': (Optional) The creature to ask about. Defaults to the current creature.
"""
func get_seat(creature_index: int = -1) -> Control:
	return _seats[current_creature_index] if creature_index == -1 else _seats[creature_index]


"""
Plays a door chime sound effect, for when a creature enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	get_seat().play_door_chime(delay)


"""
Plays a 'mmm!' creature voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	get_seat().play_combo_voice()


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice() -> void:
	get_seat().play_hello_voice()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	get_seat().play_goodbye_voice()


func _on_Creature_food_eaten() -> void:
	_shake_original_position = position
	_shake_total_seconds = 0.16
	_shake_remaining_seconds = 0.16
