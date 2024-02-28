class_name CreatureShadows
extends Node2D
## Manages shadows for all creatures in a scene.

export (NodePath) var creature_parent_path: NodePath setget set_creature_parent_path

export (PackedScene) var CreatureShadowScene: PackedScene

## Node containing all creatures in the scene. This doesn't need to be a direct parent, but all creatures need to be an
## ancestor of this node or they will not receive shadows.
var _creature_parent: Node

## key: (Creature) Creature shown in the environment
## value: (CreatureShadow) Creature's shadow
var _shadows_by_creature: Dictionary

func _ready() -> void:
	_refresh_creature_parent_path()


func set_creature_parent_path(new_creature_parent_path: NodePath) -> void:
	creature_parent_path = new_creature_parent_path
	_refresh_creature_parent_path()


func create_shadow(creature: Creature) -> void:
	var creature_shadow: CreatureShadow = CreatureShadowScene.instance()
	creature_shadow.shadow_scale = creature.scale * Global.CREATURE_SCALE
	add_child(creature_shadow)
	creature_shadow.creature_path = creature_shadow.get_path_to(creature)
	_shadows_by_creature[creature] = creature_shadow
	creature.connect("tree_exited", self, "_on_Creature_tree_exited", [creature])


func _refresh_creature_parent_path() -> void:
	if not is_inside_tree():
		return
	
	_creature_parent = get_node(creature_parent_path) if creature_parent_path else null
	
	for creature in Utils.get_child_members(_creature_parent, "creatures"):
		if _shadows_by_creature.has(creature):
			# creature already has a shadow
			continue
		
		create_shadow(creature)


func _on_Creature_tree_exited(creature: Creature) -> void:
	_shadows_by_creature[creature].queue_free()
	_shadows_by_creature.erase(creature)
