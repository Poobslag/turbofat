"""
The 'seat' scene includes a customer and some furniture, all of which cast shadows. But the 'seat' scene does not
contain the shadows itself, since they need to appear behind other objects outside of this scene.

This script contains logic for scaling an injected 'customer shadow' object as the customer grows in size.
"""
extends Control

# the path of the customer shadow sprite which needs to be scaled
export (NodePath) var _customer_shadow_path: NodePath setget set_customer_shadow_path

# the customer shadow sprite which needs to be scaled
var _customer_shadow: Sprite

# Redundant property which tracks the scale of the customer shadow sprite. Used for tweening and animations
export (Vector2) var _customer_shadow_scale := Vector2(1, 1) setget set_customer_shadow_scale

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
