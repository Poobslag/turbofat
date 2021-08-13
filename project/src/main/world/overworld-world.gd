class_name OverworldWorld
extends Node
"""
Populates/unpopulates the creatures and obstacles on the overworld.
"""

export (NodePath) var shadow_caster_shadows_path: NodePath
export (NodePath) var creature_shadows_path: NodePath
export (NodePath) var chat_icons_path: NodePath
export (PackedScene) var CreaturePackedScene: PackedScene

onready var _shadow_caster_shadows: ShadowCasterShadows = get_node(shadow_caster_shadows_path)
onready var _creature_shadows: CreatureShadows = get_node(creature_shadows_path)
onready var _chat_icons: ChatIcons = get_node(chat_icons_path)
onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

func _ready() -> void:
	if not Breadcrumb.trail:
		# For developers accessing the Overworld scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	if CutsceneManager.is_front_chat_tree():
		_launch_cutscene()
	else:
		if Global.player_spawn_id:
			move_creature_to_spawn(ChattableManager.player, Global.player_spawn_id)
		
		if Global.sensei_spawn_id:
			move_creature_to_spawn(ChattableManager.sensei, Global.sensei_spawn_id)
	
	$Camera.position = ChattableManager.player.position
	ChattableManager.refresh_creatures()


func _launch_cutscene() -> void:
	_overworld_ui.cutscene = true
	ChattableManager.player.input_disabled = true
	ChattableManager.sensei.movement_disabled = true
	
	# remove all of the creatures from the overworld except for the player and sensei
	for node in get_tree().get_nodes_in_group("creatures"):
		if node != ChattableManager.player and node != ChattableManager.sensei:
			# remove it immediately so we don't find it in the tree later
			node.get_parent().remove_child(node)
			node.queue_free()
	
	for node in get_tree().get_nodes_in_group("creature_spawners"):
		node.get_parent().remove_child(node)
		node.queue_free()
	
	var cutscene_creature: Creature
	if CurrentLevel.creature_id:
		# add the cutscene creature
		cutscene_creature = add_creature(CurrentLevel.creature_id)
	
	# get the location, spawn location data
	var chat_tree := CutsceneManager.pop_chat_tree()
	
	if not chat_tree.spawn_locations and cutscene_creature:
		# apply a default position to the cutscene creature
		cutscene_creature.position = ChattableManager.player.position
		cutscene_creature.position += Vector2(cutscene_creature.chat_extents.x, 0)
		cutscene_creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
		cutscene_creature.position += Vector2(60, 0)
	else:
		for creature_id in chat_tree.spawn_locations:
			var creature := _find_creature(creature_id)
			if not creature:
				creature = add_creature(creature_id)
			creature.set_collision_disabled(true)
			
			# move the creature to its spawn location
			move_creature_to_spawn(creature, chat_tree.spawn_locations[creature_id])
	
	yield(get_tree(), "idle_frame")
	_overworld_ui.start_chat(chat_tree, cutscene_creature)
	
	if not chat_tree.spawn_locations and cutscene_creature:
		_overworld_ui.make_chatters_face_eachother()


"""
Relocate a creature to a spawn point.
"""
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


"""
Creates a new creature with the specified creature_id and adds it to the scene.
"""
func add_creature(creature_id: String, chattable: bool = true) -> Creature:
	var creature: Creature = CreaturePackedScene.instance()
	creature.creature_id = creature_id
	$Obstacles.add_child(creature)
	if chattable:
		creature.add_to_group("chattables")
		var chat_bubble_type := ChatLibrary.chat_icon_for_creature(creature)
		creature.set_meta("chat_bubble_type", chat_bubble_type)
		ChattableManager.register_creature(creature)
	process_new_obstacle(creature)
	return creature


func process_new_obstacle(obstacle: Node2D) -> void:
	# create chat icon
	if obstacle.is_in_group("chattables"):
		_chat_icons.create_icon(obstacle)
	
	# create shadow
	if obstacle is Creature:
		_creature_shadows.create_shadow(obstacle)
	else:
		_shadow_caster_shadows.create_shadow(obstacle)


"""
Locates the creature with the specified creature_id.
"""
func _find_creature(creature_id: String) -> Creature:
	var creature: Creature
	
	for creature_node in get_tree().get_nodes_in_group("creatures"):
		if creature_node.creature_id == creature_id:
			creature = creature_node
			break
	
	return creature
