class_name Customer3D
extends KinematicBody
"""
Script for representing a customer in the 3D overworld.
"""

# Turbo cannot land on customers easily, but it is possible
var foothold_radius := 4.0

func _ready() -> void:
	$CollisionShape.disabled = true
	$ShadowMesh.visible = false
	$Viewport/Customer/Shadow.visible = false
	var customer_def := get_customer_def()
	if customer_def:
		$Viewport/Customer.summon(customer_def)


"""
Subclasses can override this method to define the customer's appearance.
"""
func get_customer_def() -> Dictionary:
	return {}


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Customer/MovementAnims, omitting the directional suffix
	
	'movement_direction': A unit vector in the (X, Y) direction the customer is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	$Viewport/Customer.play_movement_animation(animation_prefix, movement_direction)


"""
Animates the customer's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The customer's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	$Viewport/Customer.play_mood(mood)


"""
Orients this customer so they're facing the specified spatial.
"""
func orient_toward(spatial: Spatial) -> void:
	if not $Viewport/Customer.is_idle():
		# don't change this customer's orientation if they're performing an activity
		return
	
	# calculate the relative direction of the object this customer should face
	var direction_xz := Vector2(spatial.translation.x - translation.x, spatial.translation.z - translation.z)
	var direction_dot := 0.0
	if direction_xz.length() > 0:
		direction_dot = direction_xz.normalized().dot(Vector2(1.0, -1.0).normalized())
		if direction_dot == 0.0:
			# if two characters are directly above/below each other, make them face opposite directions
			direction_dot = direction_xz.normalized().dot(Vector2(1.0, 0))
	
	if direction_dot > 0:
		# the object is to the right; face right
		$Viewport/Customer.set_orientation(Customer.Orientation.SOUTHEAST)
	elif direction_dot < 0:
		# the object is to the left; face left
		$Viewport/Customer.set_orientation(Customer.Orientation.SOUTHWEST)


func get_orientation() -> int:
	return $Viewport/Customer.get_orientation()


func _on_Customer_customer_arrived() -> void:
	# initialize physics and shadows when the customer textures load
	$CollisionShape.disabled = false
	$ShadowMesh.visible = true


func _on_Customer_movement_animation_started(anim_name: String) -> void:
	# animate our shadows when the customer moves
	if anim_name in ["run-se", "run-nw"]:
		$ShadowMesh/AnimationPlayer.play("run")
	elif anim_name in ["jump-se", "jump-nw"]:
		$ShadowMesh/AnimationPlayer.play("jump")
	else:
		$ShadowMesh/AnimationPlayer.stop()
		$ShadowMesh.set_shadow_scale(1.0)
