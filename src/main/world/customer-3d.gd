class_name Customer3D
extends KinematicBody
"""
Script for representing a customer in the 3D overworld.
"""

# Turbo cannot land on customers easily, but it is possible
var foothold_radius := 4.0

func _ready():
	$CollisionShape.disabled = true
	$ShadowMesh.visible = false
	$Viewport/Customer/Shadow.visible = false
	var customer_definition = get_customer_definition()
	if customer_definition:
		$Viewport/Customer.summon(customer_definition)


"""
Subclasses can override this method to define the customer's appearance.
"""
func get_customer_definition() -> Dictionary:
	return {}


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Customer/MovementAnims, omitting the directional suffix
	
	'movement_direction': A unit vector in the (X, Y) direction the customer is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2) -> void:
	$Viewport/Customer.play_movement_animation(animation_prefix, movement_direction)


func _on_Customer_customer_arrived():
	# We initialize our physics and shadows when the customer textures load
	$CollisionShape.disabled = false
	$ShadowMesh.visible = true
