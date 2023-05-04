class_name ShadowCasterShadows
extends Node2D
## Manages shadows for all 'shadow casters' in a scene.
##
## Shadow casters are objects which cast shadows. This doesn't include environment tiles and creatures, which have
## special shadow casting logic.

@export var OvalShadowScene: PackedScene

func _ready() -> void:
	for shadow_caster in get_tree().get_nodes_in_group("shadow_casters"):
		create_shadow(shadow_caster)


func create_shadow(shadow_caster: Node2D) -> void:
	var oval_shadow: OvalShadow = OvalShadowScene.instantiate()
	add_child(oval_shadow)
	oval_shadow.shadow_caster_path = oval_shadow.get_path_to(shadow_caster)
	shadow_caster.tree_exited.connect(_on_Node2D_tree_exited.bind(oval_shadow))


func _on_Node2D_tree_exited(oval_shadow: OvalShadow) -> void:
	oval_shadow.queue_free()
