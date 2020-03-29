"""
The 'seat' scene includes a customer and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'customer shadow' object as the customer grows in size.
"""
extends Control

# the path of the customer shadow sprite which needs to be scaled
export (NodePath) var _customer_shadow_path: NodePath setget set_customer_shadow_path

# Redundant property which tracks the scale of the customer shadow sprite. Used for tweening and animations
export (Vector2) var _customer_shadow_scale := Vector2(1, 1) setget set_customer_shadow_scale

# the customer shadow sprite which needs to be scaled
var _customer_shadow: Sprite

func set_customer_shadow_path(customer_shadow_path: NodePath) -> void:
	_customer_shadow_path = customer_shadow_path
	if is_inside_tree():
		_update_customer_shadow_field()

func _update_customer_shadow_field() -> void:
	if _customer_shadow_path != null:
		_customer_shadow = get_node(_customer_shadow_path)
	if _customer_shadow != null:
		_customer_shadow.scale = _customer_shadow_scale

func _ready() -> void:
	_update_customer_shadow_field()

func set_customer_shadow_scale(customer_shadow_scale: Vector2) -> void:
	_customer_shadow_scale = customer_shadow_scale
	if _customer_shadow != null:
		_customer_shadow.scale = _customer_shadow_scale

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
