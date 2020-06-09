class_name Creature3D
extends KinematicBody
"""
Script for representing a creature in the 3D overworld.
"""

# Spira cannot land on creatures easily, but it is possible
var foothold_radius := 2.0

onready var _creature := $Viewport/Creature


func _ready() -> void:
	$CollisionShape.disabled = true
	$ShadowMesh.visible = false
	_creature.get_node("Sprites/Shadow").visible = false


func set_creature_def(creature_def: Dictionary) -> void:
	set_meta("creature_def", creature_def)
	_creature.summon(creature_def)


"""
Plays a movement animation with the specified prefix and direction, such as a 'run' animation going left.

Parameters:
	'animation_prefix': A partial name of an animation on $Creature/MovementAnims, omitting the directional suffix
	
	'movement_direction': A vector in the (X, Y) direction the creature is moving.
"""
func play_movement_animation(animation_prefix: String, movement_direction: Vector2 = Vector2.ZERO) -> void:
	_creature.play_movement_animation(animation_prefix, movement_direction)


"""
Animates the creature's appearance according to the specified mood: happy, angry, etc...

Parameters:
	'mood': The creature's new mood from ChatEvent.Mood
"""
func play_mood(mood: int) -> void:
	_creature.play_mood(mood)


"""
Orients this creature so they're facing the specified spatial.
"""
func orient_toward(target: Spatial) -> void:
	if not _creature.is_idle():
		# don't change this creature's orientation if they're performing an activity
		return
	
	# calculate the relative direction of the object this creature should face
	var direction := Vector2(target.translation.x - translation.x, target.translation.z - translation.z)
	var direction_dot := 0.0
	if direction:
		direction_dot = direction.normalized().dot(Vector2(1.0, -1.0).normalized())
		if direction_dot == 0.0:
			# if two characters are directly above/below each other, make them face opposite directions
			direction_dot = direction.normalized().dot(Vector2(1.0, 0))
	
	if direction_dot > 0:
		# the target is to the right; face right
		_creature.set_orientation(Creature.Orientation.SOUTHEAST)
	elif direction_dot < 0:
		# the target is to the left; face left
		_creature.set_orientation(Creature.Orientation.SOUTHWEST)


func get_orientation() -> int:
	return _creature.orientation


func _on_Creature_creature_arrived() -> void:
	# initialize physics and shadows when the creature textures load
	$CollisionShape.disabled = false
	$ShadowMesh.visible = true


func _on_Creature_movement_animation_started(anim_name: String) -> void:
	# animate our shadows when the creature moves
	if anim_name in ["run-se", "run-nw"]:
		$ShadowMesh/AnimationPlayer.play("run")
	elif anim_name in ["jump-se", "jump-nw"]:
		$ShadowMesh/AnimationPlayer.play("jump")
	else:
		$ShadowMesh/AnimationPlayer.stop()
		$ShadowMesh.set_shadow_scale(1.0)


func _on_Creature_jumped() -> void:
	$JumpSound.play()


func _on_Creature_landed() -> void:
	$HopSound.play()
