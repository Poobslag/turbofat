"""
Handles animations and audio/visual effects for the restaurant and its customers.
"""
extends Node2D

# fields which control the screen shake effect
var _shake_total_seconds := 0.0
var _shake_remaining_seconds := 0.0
var _shake_magnitude := 2.5

# the object's original position before the screen shake effect began
var _shake_original_position: Vector2

# the customer which food is currently being served to
var current_customer_index := 0

# all of the seats in the scene. each 'seat' includes a table, chairs, a customer, etc...
onready var _seats := [$Seat1, $Seat2, $Seat3]

"""
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	_seats[current_customer_index].get_node("Customer").feed()

"""
Increases/decreases the customer's fatness, playing an animation which gradually applies the change.

Parameters: The 'fatness_percent' parameter controls how fat the customer should be; 5.0 = 5x normal size
The 'customer_index' parameter optionally specifies which customer should be altered. It defaults to the current
	customer.
"""
func set_fatness(fatness_percent: float, customer_index: int = -1) -> void:
	var seat
	if (customer_index == -1):
		seat = _seats[current_customer_index]
	else:
		seat = _seats[customer_index]
	seat.get_node("Customer/FatPlayer").set_fatness(fatness_percent)

"""
Returns the customer's fatness, a float which determines how fat the customer should be; 5.0 = 5x normal size

Parameters: 'customer_index' is an optional parameter which specifies the customer to ask about. If omitted, it will
	default to the customer currently being served food.
"""
func get_fatness(customer_index: int = -1) -> float:
	var seat
	if (customer_index == -1):
		seat = _seats[current_customer_index]
	else:
		seat = _seats[customer_index]
	return seat.get_node("Customer/FatPlayer").get_fatness()

func _on_Customer_food_eaten() -> void:
	_shake_original_position = position
	_shake_total_seconds = 0.16
	_shake_remaining_seconds = 0.16

func _process(delta: float) -> void:
	if _shake_remaining_seconds > 0:
		_shake_remaining_seconds -= delta
		if _shake_remaining_seconds <= 0:
			position = _shake_original_position
		else:
			var max_shake := _shake_magnitude * _shake_remaining_seconds / _shake_total_seconds
			var shake_vector := Vector2(rand_range(-max_shake, max_shake), rand_range(-max_shake, max_shake))
			position = _shake_original_position + shake_vector
