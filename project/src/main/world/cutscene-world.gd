tool
class_name CutsceneWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles during cutscenes.

export (NodePath) var overworld_bg_path: NodePath

onready var _camera: CutsceneCamera = $Camera
onready var _overworld_bg: OverworldBg = get_node(overworld_bg_path)

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	if CurrentCutscene.chat_tree.meta.has("fixed_zoom"):
		_camera.fixed_zoom = CurrentCutscene.chat_tree.meta["fixed_zoom"]
	
	if PlayerData.career.is_career_mode() and MusicPlayer.is_playing_boss_track():
		# don't interrupt boss music during career mode; it keeps playing from the level select to the puzzle
		pass
	else:
		MusicPlayer.play_menu_track()
	_launch_cutscene()


func initial_environment_path() -> String:
	return CurrentCutscene.chat_tree.chat_environment_path()


## Starts the cutscene.
##
## Replaces the environment's creatures with those necessary for the cutscene and plays the cutscene's chat tree.
func _launch_cutscene() -> void:
	_prepare_bg()
	_remove_all_creatures()
	_add_cutscene_creatures()
	_arrange_creatures()
	
	if is_inside_tree():
		yield(get_tree(), "idle_frame")

	Global.get_overworld_ui().start_chat(CurrentCutscene.chat_tree)
	_camera.snap_into_position()


## Updates the background to include an outer space background for outdoor cutscenes.
func _prepare_bg() -> void:
	var outer_space_visible := not CurrentCutscene.chat_tree.location_id in ChatTree.INDOOR_LOCATION_IDS
	_overworld_bg.outer_space_visible = outer_space_visible


## Removes all creatures from the overworld except for the player and sensei.
func _remove_all_creatures() -> void:
	for node in overworld_environment.get_creatures():
		if node is WalkingBuddy:
			# don't remove 'walking buddies'
			continue
		
		# remove the creature immediately so we don't find it in the tree later
		node.get_parent().remove_child(node)
		node.queue_free()
	
	for node in overworld_environment.get_creature_spawners():
		node.get_parent().remove_child(node)
		node.queue_free()


## Adds all creatures referenced by the cutscene's chat tree.
func _add_cutscene_creatures() -> void:
	for creature_id in CurrentCutscene.chat_tree.spawn_locations:
		var creature: Creature = overworld_environment.get_creature_by_id(creature_id)
		if not creature:
			creature = overworld_environment.add_creature(creature_id)
		creature.set_collision_disabled(true)


## Moves all cutscene creatures to their proper locations.
func _arrange_creatures() -> void:
	for creature_id in CurrentCutscene.chat_tree.spawn_locations:
		var creature: Creature = overworld_environment.get_creature_by_id(creature_id)
		var spawn_id: String = CurrentCutscene.chat_tree.spawn_locations[creature_id]
		
		# move the creature to its spawn location
		overworld_environment.move_creature_to_spawn(creature, spawn_id)
