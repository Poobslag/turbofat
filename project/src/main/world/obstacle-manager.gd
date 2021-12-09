class_name ObstacleManager
extends Node
## Maintains creatures and obstacles for an overworld scene

## (Optional) path to the ChatIcons node which maintains chat icons for chattables in the scene tree.
export (NodePath) var chat_icons_path: NodePath

export (NodePath) var creature_shadows_path: NodePath
export (NodePath) var shadow_caster_shadows_path: NodePath
export (NodePath) var obstacles_path: NodePath
export (PackedScene) var CreatureScene: PackedScene

onready var _chat_icons: ChatIcons
onready var _creature_shadows: CreatureShadows = get_node(creature_shadows_path)
onready var _obstacles: Node2D = get_node(obstacles_path)
onready var _shadow_caster_shadows: ShadowCasterShadows = get_node(shadow_caster_shadows_path)

func _ready() -> void:
	if chat_icons_path:
		# the overworld has chat icons, but career mode does not
		_chat_icons = get_node(chat_icons_path)


## Relocate a creature to a spawn point.
func move_creature_to_spawn(creature: Creature, spawn_id: String) -> void:
	var target_spawn: Spawn
	for spawn_obj in get_tree().get_nodes_in_group("spawns"):
		var spawn: Spawn = spawn_obj
		if spawn.id == spawn_id:
			target_spawn = spawn
		elif spawn.id == spawn_id.trim_prefix("!"):
			# Spawn locations prefixed with a '!' indicate that the creature should spawn invisible.
			creature.visible = false
			target_spawn = spawn

	if target_spawn:
		target_spawn.move_creature(creature)
	else:
		push_warning("Could not locate spawn with id '%s'" % [spawn_id])


## Creates a new creature with the specified creature_id and adds it to the scene.
##
## Parameters:
## 	'creature_id': (Optional) The id of a creature to load from the CreatureLibrary. If omitted, the returned
## 		creature will assume a default appearance.
##
## 	'chattable': (Optional) 'True' if the player can walk up and speak to the creature.
func add_creature(creature_id: String = "", chattable: bool = true) -> Creature:
	var creature: Creature = CreatureScene.instance()
	creature.creature_id = creature_id
	_obstacles.add_child(creature)
	if chattable:
		creature.add_to_group("chattables")
		var chat_bubble_type := ChatLibrary.chat_icon_for_creature(creature)
		creature.set_meta("chat_bubble_type", chat_bubble_type)
		ChattableManager.register_creature(creature)
	process_new_obstacle(creature)
	return creature


## Creates shadows and chat icons when an obstacle is added to the world.
func process_new_obstacle(obstacle: Node2D) -> void:
	# create chat icon
	if _chat_icons and obstacle.is_in_group("chattables"):
		_chat_icons.create_icon(obstacle)
	
	# create shadow
	if obstacle is Creature:
		_creature_shadows.create_shadow(obstacle)
	else:
		_shadow_caster_shadows.create_shadow(obstacle)


## Locates the creature with the specified creature_id.
func find_creature(creature_id: String) -> Creature:
	var creature: Creature
	
	for creature_node in get_tree().get_nodes_in_group("creatures"):
		if creature_node.creature_id == creature_id:
			creature = creature_node
			break
	
	return creature
