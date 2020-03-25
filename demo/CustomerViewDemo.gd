"""
A demo which shows off the customer view.

Keys:

[F]: Feed the customer
[P]: Print the current animation details
[1-9,0]: Change the customer's size from 10% to 100%
[Q,W,E]: Switch to the 1st, 2nd or 3rd customer.
"""
extends Node2D

func _input(event: InputEvent) -> void:
	var just_pressed := event.is_pressed() && !event.is_echo()
	if Input.is_key_pressed(KEY_F) && just_pressed:
		$CustomerView/SceneClip/CustomerSwitcher/Scene.feed()
	if Input.is_key_pressed(KEY_1) && just_pressed:
		$CustomerView.set_fatness(1.0)
	if Input.is_key_pressed(KEY_2) && just_pressed:
		$CustomerView.set_fatness(1.5)
	if Input.is_key_pressed(KEY_3) && just_pressed:
		$CustomerView.set_fatness(2.0)
	if Input.is_key_pressed(KEY_4) && just_pressed:
		$CustomerView.set_fatness(3.0)
	if Input.is_key_pressed(KEY_5) && just_pressed:
		$CustomerView.set_fatness(5.0)
	if Input.is_key_pressed(KEY_6) && just_pressed:
		$CustomerView.set_fatness(6.0)
	if Input.is_key_pressed(KEY_7) && just_pressed:
		$CustomerView.set_fatness(7.0)
	if Input.is_key_pressed(KEY_8) && just_pressed:
		$CustomerView.set_fatness(8.0)
	if Input.is_key_pressed(KEY_9) && just_pressed:
		$CustomerView.set_fatness(9.0)
	if Input.is_key_pressed(KEY_0) && just_pressed:
		$CustomerView.set_fatness(10.0)
	if Input.is_key_pressed(KEY_Q) && just_pressed:
		$CustomerView.set_current_customer_index(0)
	if Input.is_key_pressed(KEY_W) && just_pressed:
		$CustomerView.set_current_customer_index(1)
	if Input.is_key_pressed(KEY_E) && just_pressed:
		$CustomerView.set_current_customer_index(2)
	if Input.is_key_pressed(KEY_P) && just_pressed:
		print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.current_animation)
		print($CustomerView/SceneClip/CustomerSwitcher/Scene/Customer/AnimationPlayer.is_playing())
