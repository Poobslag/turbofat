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

"""
Launches the 'feed' animation, hurling a piece of food at the customer and having them catch it.
"""
func feed() -> void:
	$Customer.feed()

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
