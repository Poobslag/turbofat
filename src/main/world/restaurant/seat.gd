extends Node2D
"""
The 'seat' scene includes a creature and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'creature shadow' object as the creature grows in size.
"""

"""
Plays a door chime sound effect, for when a creature enters the restaurant.

Parameter: 'delay' is the delay in seconds before the chime sound plays. The default value of '-1' results in a random
	delay.
"""
func play_door_chime(delay: float = -1) -> void:
	$Creature.play_door_chime(delay)


"""
Sets the relative position of sound affects related to the restaurant door. Each seat has a different position
relative to the restaurant's entrance; some are close to the door, some are far away.

Parameter: 'position' is the position of the door relative to this seat, in world coordinates.
"""
func set_door_sound_position(position: Vector2) -> void:
	for chime_sound in $Creature.chime_sounds:
		chime_sound.position = position
	for hello_voice in $Creature.hello_voices:
		hello_voice.position = position


"""
Plays a 'mmm!' creature voice sample, for when a player builds a big combo.
"""
func play_combo_voice() -> void:
	$Creature.play_combo_voice()


"""
Plays a 'hello!' voice sample, for when a creature enters the restaurant
"""
func play_hello_voice() -> void:
	$Creature.play_hello_voice()


"""
Plays a 'check please!' voice sample, for when a creature is ready to leave
"""
func play_goodbye_voice() -> void:
	$Creature.play_goodbye_voice()


"""
When the creature arrives, we draw a shadowy version of the stool they sat upon.
"""
func _on_Creature_creature_arrived() -> void:
	$Stool0L.texture = preload("res://assets/main/world/restaurant/stool-occupied.png")


"""
When the creature leaves, we draw an unshadowed version of the stool they stood up from.
"""
func _on_Creature_creature_left() -> void:
	$Stool0L.texture = preload("res://assets/main/world/restaurant/stool.png")
