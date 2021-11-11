class_name OverworldObstacle
extends KinematicBody2D
## Something which blocks the player on the overworld, such as a tree or bush.
##
## These objects can also be inspected (talked to) if the chat_key is set.

## the size of the shadow cast by this object
export (float) var shadow_scale: float = 1.0 setget set_shadow_scale

## The key identifying the chat resource for this object. If set, the object will have a thought bubble and the player
## will be able to inspect it.
export (String) var chat_key: String setget set_chat_key

func _init() -> void:
	add_to_group("shadow_casters")


## When the shadow scale is set, we update the node's metadata so the shadow will be rendered correctly.
func set_shadow_scale(new_shadow_scale: float) -> void:
	shadow_scale = new_shadow_scale
	set_meta("shadow_scale", shadow_scale)


## When the chat path is set, we update the node's groups and metadata to integrate the node into the chat framework.
func set_chat_key(new_chat_key: String) -> void:
	chat_key = new_chat_key
	if new_chat_key:
		add_to_group("chattables")
		set_meta("chat_key", new_chat_key)
		set_meta("chat_bubble_type", ChatIcon.THOUGHT)
	else:
		remove_from_group("chattables")
		set_meta("chat_key", null)
		set_meta("chat_bubble_type", null)
