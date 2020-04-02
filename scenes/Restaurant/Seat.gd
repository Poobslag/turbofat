extends Node2D
"""
The 'seat' scene includes a customer and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'customer shadow' object as the customer grows in size.
"""

"""
Plays a door chime sound effect, for when a customer enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	$Customer.play_door_chime(delay)


"""
Sets the relative position of sound affects related to the restaurant door. Each seat has a different position
relative to the restaurant's entrance; some are close to the door, some are far away.

Parameter: 'position' is the position of the door relative to this seat, in world coordinates.
"""
func set_door_sound_position(position: Vector2) -> void:
	for chime_sound in $Customer.chime_sounds:
		chime_sound.position = position
	for hello_voice in $Customer.hello_voices:
		hello_voice.position = position


"""
Plays a 'mmm!' customer voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	$Customer.play_combo_voice()


"""
Plays a 'hello!' voice sample, for when a customer enters the restaurant
"""
func play_hello_voice() -> void:
	$Customer.play_hello_voice()


"""
Plays a 'check please!' voice sample, for when a customer is ready to leave
"""
func play_goodbye_voice() -> void:
	$Customer.play_goodbye_voice()


"""
When the customer arrives, we draw a shadowy version of the stool they sat upon.
"""
func _on_Customer_customer_arrived():
	$Stool0L.texture = preload("res://art/restaurant/stool-occupied.png")


"""
When the customer leaves, we draw an unshadowed version of the stool they stood up from.
"""
func _on_Customer_customer_left():
	$Stool0L.texture = preload("res://art/restaurant/stool.png")
