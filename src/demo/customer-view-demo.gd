extends Node2D
"""
A demo which shows off the customer view.

Keys:
	[F]: Feed the customer
	[D]: Ring the doorbell
	[V]: Say something
	[P]: Print the current animation details
	[1-9,0]: Change the customer's size from 10% to 100%
	[Q,W,E]: Switch to the 1st, 2nd or 3rd customer.
	brace keys: Change the customer's appearance
"""

const FATNESS_KEYS = [10.0, 1.0, 1.5, 2.0, 3.0, 5.0, 6.0, 7.0, 8.0, 9.0]

var _current_color_index := -1

func _ready():
	# Ensure customers are random
	randomize()


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F) and not event.is_echo():
		$CustomerView/SceneClip/CustomerSwitcher/Scene.feed()
	if Input.is_key_pressed(KEY_D) and not event.is_echo():
		$CustomerView/SceneClip/CustomerSwitcher/Scene.play_door_chime(0)
	if Input.is_key_pressed(KEY_V) and not event.is_echo():
		$CustomerView/SceneClip/CustomerSwitcher/Scene.play_goodbye_voice()
	if Global.is_num_just_pressed():
		$CustomerView.set_fatness(FATNESS_KEYS[Global.get_num_just_pressed()])
	if Input.is_key_pressed(KEY_Q) and not event.is_echo():
		$CustomerView.set_current_customer_index(0)
	if Input.is_key_pressed(KEY_W) and not event.is_echo():
		$CustomerView.set_current_customer_index(1)
	if Input.is_key_pressed(KEY_E) and not event.is_echo():
		$CustomerView.set_current_customer_index(2)
	if Input.is_key_pressed(KEY_BRACELEFT) and not event.is_echo():
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index += CustomerLoader.DEFINITIONS.size()
			_current_color_index = (_current_color_index - 1) % CustomerLoader.DEFINITIONS.size()
		$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index])
	if Input.is_key_pressed(KEY_BRACERIGHT) and not event.is_echo():
		if _current_color_index == -1:
			_current_color_index = 0
		else:
			_current_color_index = (_current_color_index + 1) % CustomerLoader.DEFINITIONS.size()
		$CustomerView.summon_customer(CustomerLoader.DEFINITIONS[_current_color_index])
	if Input.is_key_pressed(KEY_P) and not event.is_echo():
		print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.current_animation)
		print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.is_playing())
