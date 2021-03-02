extends Node
"""
Populates/unpopulates the creatures and obstacles on the overworld.
"""

export (NodePath) var creature_shadows_path: NodePath
export (NodePath) var chat_icons_path: NodePath
export (PackedScene) var CreaturePackedScene: PackedScene

onready var _creature_shadows: CreatureShadows = get_node(creature_shadows_path)
onready var _chat_icons: ChatIcons = get_node(chat_icons_path)
onready var _overworld_ui: OverworldUi = Global.get_overworld_ui()

func _ready() -> void:
	if Global.player_spawn_id:
		move_creature_to_spawn(ChattableManager.player, Global.player_spawn_id)
	
	if Global.sensei_spawn_id:
		move_creature_to_spawn(ChattableManager.sensei, Global.sensei_spawn_id)
	
	if Level.level_state != Level.LevelState.NONE:
		_launch_cutscene()
	
	$Camera.position = ChattableManager.player.position
	ChattableManager.refresh_creatures()


func _launch_cutscene() -> void:
	_overworld_ui.cutscene = true
	
	# remove all of the creatures from the overworld except for the player and sensei
	for node in get_tree().get_nodes_in_group("creatures"):
		if node != ChattableManager.player and node != ChattableManager.sensei:
			# remove it immediately so we don't find it in the tree later
			node.get_parent().remove_child(node)
			node.queue_free()
	
	# add the cutscene creature
	var cutscene_creature: Creature = _add_creature(Level.launched_creature_id)
	ChattableManager.player.input_disabled = true
	
	# get the location, spawn location data
	var chat_tree: ChatTree
	match Level.level_state:
		Level.LevelState.BEFORE:
			chat_tree = ChatLibrary.chat_tree_for_preroll(Level.launched_level_id)
		Level.LevelState.AFTER:
			chat_tree = ChatLibrary.chat_tree_for_postroll(Level.launched_level_id)
		_:
			push_warning("Unexpected Level.level_state: %s" % [Level.level_state])
	
	if not chat_tree.spawn_locations:
		# apply a default position to the cutscene creature
		cutscene_creature.position = ChattableManager.player.position
		cutscene_creature.position += Vector2(cutscene_creature.chat_extents.x, 0)
		cutscene_creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
		cutscene_creature.position += Vector2(60, 0)
	else:
		for creature_id in chat_tree.spawn_locations:
			var creature := _find_creature(creature_id)
			if not creature:
				creature = _add_creature(creature_id)
			creature.set_collision_disabled(true)
			
			# move the creature to its spawn location
			move_creature_to_spawn(creature, chat_tree.spawn_locations[creature_id])
	
	yield(get_tree(), "idle_frame")
	_overworld_ui.start_chat(chat_tree, cutscene_creature)


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
func _add_creature(creature_id: String) -> Creature:
	var creature: Creature = CreaturePackedScene.instance()
	creature.creature_id = creature_id
	creature.add_to_group("chattables")
	$Obstacles.add_child(creature)
	_chat_icons.create_icon(creature)
	_creature_shadows.create_shadow(creature)
	return creature


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
