class_name OverworldObstacle
extends CharacterBody2D
## Something which obstructs the player on the overworld, such as a tree or bush.
##
## These objects can also be inspected (talked to) if the chat_key is set.

## size of the shadow cast by this object
@export (float) var shadow_scale: float = 1.0: set = set_shadow_scale

func _init() -> void:
	add_to_group("shadow_casters")


## When the shadow scale is set, we update the node's metadata so the shadow will be rendered correctly.
func set_shadow_scale(new_shadow_scale: float) -> void:
	shadow_scale = new_shadow_scale
	
	if Engine.is_editor_hint():
		# Avoid metadata edits in the editor for OverworldObstacles that are tool scripts.
		return
	
	set_meta("shadow_scale", shadow_scale)
