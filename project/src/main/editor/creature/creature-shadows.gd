class_name CreatureShadows
extends Node2D
"""
Manages shadows for all creatures in a scene.
"""

export (PackedScene) var CreatureShadowScene: PackedScene

func _ready() -> void:
	for creature in get_tree().get_nodes_in_group("creatures"):
		create_shadow(creature)


func create_shadow(creature: Creature) -> void:
	var creature_shadow: CreatureShadow = CreatureShadowScene.instance()
	creature_shadow.shadow_scale = creature.scale * Global.CREATURE_SCALE
	add_child(creature_shadow)
	creature_shadow.creature_path = creature_shadow.get_path_to(creature)
	creature.connect("tree_exited", self, "_on_Creature_tree_exited", [creature_shadow])


func _on_Creature_tree_exited(creature_shadow: CreatureShadow) -> void:
	creature_shadow.queue_free()
