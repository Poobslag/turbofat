extends Node
"""
Populates/unpopulates the creatures and obstacles on the overworld.
"""

export (NodePath) var creature_shadows_path: NodePath
export (NodePath) var chat_icons_path: NodePath
export (NodePath) var overworld_ui_path: NodePath
export (PackedScene) var CreaturePackedScene: PackedScene

onready var _creature_shadows: CreatureShadows = get_node(creature_shadows_path)
onready var _chat_icons: ChatIcons = get_node(chat_icons_path)
onready var _overworld_ui: OverworldUi = get_node(overworld_ui_path)

func _ready() -> void:
	if Scenario.launched_scenario_id:
		_overworld_ui.cutscene = true
		
		# remove all of the creatures from the overworld
		for child in [$Obstacles/Bort, $Obstacles/Ebe, $Obstacles/Boatricia]:
			child.queue_free()
		
		# add the cutscene creatures
		var creature: Creature = CreaturePackedScene.instance()
		creature.creature_id = Scenario.launched_creature_id
		creature.position = Vector2(444, 150)
		creature.add_to_group("chattables")
		$Obstacles.add_child(creature)
		_chat_icons.create_icon(creature)
		_creature_shadows.create_shadow(creature)
		
		_schedule_chat(creature)


func _schedule_chat(creature: Creature) -> void:
	yield(get_tree(), "idle_frame")
	var chat_tree := ChatLibrary.load_chat_events_for_creature(creature, Scenario.launched_level_num)
	_overworld_ui.start_chat(chat_tree, [creature])
