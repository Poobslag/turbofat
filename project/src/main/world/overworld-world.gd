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
	$Camera.position = ChattableManager.player.position
	
	if Global.sensei_spawn_id:
		move_creature_to_spawn(ChattableManager.sensei, Global.sensei_spawn_id)
	
	if Level.launched_level_id:
		_overworld_ui.cutscene = true
		
		# remove all of the creatures from the overworld
		for node in get_tree().get_nodes_in_group("creatures"):
			if node != ChattableManager.player and node != ChattableManager.sensei:
				node.queue_free()
		
		# add the cutscene creatures
		var creature: Creature = CreaturePackedScene.instance()
		creature.creature_id = Level.launched_creature_id
		creature.add_to_group("chattables")
		$Obstacles.add_child(creature)
		_chat_icons.create_icon(creature)
		_creature_shadows.create_shadow(creature)
		
		# reposition the cutscene creatures, ensuring fat creatures have enough space
		creature.position = ChattableManager.player.position
		creature.position += Vector2(creature.chat_extents.x, 0)
		creature.position += Vector2(ChattableManager.player.chat_extents.x, 0)
		creature.position += Vector2(60, 0)
		
		_schedule_chat(creature)
	
	ChattableManager.refresh_creatures()


func _schedule_chat(creature: Creature) -> void:
	yield(get_tree(), "idle_frame")
	var chat_tree := ChatLibrary.load_chat_events_for_creature(creature, Level.launched_level_num)
	_overworld_ui.start_chat(chat_tree, creature)


"""
Relocate a creature to a spawn point.
"""
func move_creature_to_spawn(creature: Creature, spawn_id: String) -> void:
	var target_spawn: Spawn
	for spawn_obj in get_tree().get_nodes_in_group("spawns"):
		var spawn: Spawn = spawn_obj
		if spawn.id == spawn_id:
			target_spawn = spawn

	if target_spawn:
		target_spawn.move_creature(creature)
	else:
		push_warning("Could not locate spawn with id '%s'" % [spawn_id])
