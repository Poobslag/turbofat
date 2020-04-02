extends Node2D
"""
Handles animations and audio/visual effects for the restaurant and its customers.
"""

# the customer which food is currently being served to
var current_customer_index := 0

# fields which control the screen shake effect
var _shake_total_seconds := 0.0
var _shake_remaining_seconds := 0.0
var _shake_magnitude := 2.5

# the object's original position before the screen shake effect began
var _shake_original_position: Vector2

# all of the seats in the scene. each 'seat' includes a table, chairs, a customer, etc...
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
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	_seats[current_customer_index].get_node("Customer").feed()


"""
Recolors the customer according to the specified customer definition. This involves updating shaders and sprite
properties.

Parameter: 'customer_def' describes the colors and textures used to draw the customer.
"""
func summon_customer(customer_def: Dictionary, customer_index: int = -1) -> void:
	get_seat(customer_index).get_node("Customer").summon(customer_def)


"""
Increases/decreases the customer's fatness, playing an animation which gradually applies the change.

Parameters: The 'fatness_percent' parameter controls how fat the customer should be; 5.0 = 5x normal size
The 'customer_index' parameter optionally specifies which customer should be altered. It defaults to the current
	customer.
"""
func set_fatness(fatness_percent: float, customer_index: int = -1) -> void:
	get_seat(customer_index).get_node("Customer/FatPlayer").set_fatness(fatness_percent)


"""
Returns the customer's fatness, a float which determines how fat the customer should be; 5.0 = 5x normal size

Parameters: 'customer_index' is an optional parameter which specifies the customer to ask about. If omitted, it will
	default to the customer currently being fed.
"""
func get_fatness(customer_index: int = -1) -> float:
	return get_seat(customer_index).get_node("Customer/FatPlayer").get_fatness()


"""
Returns the seat corresponding to the specified optional index. If the index is omitted, returns the current seat of
the customer currently being fed.

Parameters: 'customer_index' is an optional parameter which specifies the customer to ask about. If omitted, it will
	default to the customer currently being fed.
"""
func get_seat(customer_index: int = -1) -> Control:
	return _seats[current_customer_index] if customer_index == -1 else _seats[customer_index]


"""
Plays a door chime sound effect, for when a customer enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	get_seat().play_door_chime(delay)


"""
Plays a 'mmm!' customer voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	get_seat().play_combo_voice()


"""
Plays a 'hello!' voice sample, for when a customer enters the restaurant
"""
func play_hello_voice() -> void:
	get_seat().play_hello_voice()


"""
Plays a 'check please!' voice sample, for when a customer is ready to leave
"""
func play_goodbye_voice() -> void:
	get_seat().play_goodbye_voice()


func _on_Customer_food_eaten() -> void:
	_shake_original_position = position
	_shake_total_seconds = 0.16
	_shake_remaining_seconds = 0.16
