tool
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles in the career mode's world.

## horizontal distance to maintain when placing the player and the sensei
const X_DIST_BETWEEN_PLAYER_AND_SENSEI := 240

## horizontal distance to maintain when placing customers
const X_DIST_BETWEEN_CUSTOMERS := 300

## vertical distance separating the customers from the player's path
const Y_DIST_BETWEEN_CUSTOMERS_AND_PATH := 80

## List of moods customers have when their level is chosen.
const MOODS_COMMON := [Creatures.Mood.SMILE0, Creatures.Mood.SMILE1, Creatures.Mood.WAVE0, Creatures.Mood.WAVE1]
const MOODS_UNCOMMON := [Creatures.Mood.LAUGH0, Creatures.Mood.LAUGH1, Creatures.Mood.LOVE1, Creatures.Mood.AWKWARD0]
const MOODS_RARE := [Creatures.Mood.AWKWARD1, Creatures.Mood.SIGH0, Creatures.Mood.SWEAT0, Creatures.Mood.THINK0]

## Path to the scene resource defining creatures and obstacles for career regions which do not specify an
## environment, or regions which specify an invalid environment
const DEFAULT_ENVIRONMENT_PATH := "res://src/main/world/environment/marsh/MarshEnvironment.tscn"

## key: (String) an Environment id which appears in the json definitions
## value: (String) Path to the scene resource defining creatures and obstacles which appear in
## 	that environment
const ENVIRONMENT_PATH_BY_ID := {
	"lava": "res://src/main/world/environment/lava/LavaEnvironment.tscn",
	"lemon": "res://src/main/world/environment/lemon/LemonEnvironment.tscn",
	"lemon_2": "res://src/main/world/environment/lemon/Lemon2Environment.tscn",
	"marsh": "res://src/main/world/environment/marsh/MarshEnvironment.tscn",
	"poki": "res://src/main/world/environment/poki/PokiEnvironment.tscn",
	"sand": "res://src/main/world/environment/sand/SandEnvironment.tscn",
}

export (PackedScene) var MileMarkerScene: PackedScene

## Creature instances for 'level creatures', chefs and customers associated with each level.
var _level_creatures := []

## Index of the focused level creature. This is usually the same as the index of the focused level button, but not
## always. Sometimes two level buttons correspond to the same level creature.
var _focused_level_creature_index := -1

## 'true' if the player is being moved manually with a cheat code
var _move_cheat_enabled := false

## path on which which the player and sensei are placed
onready var _player_path2d: Path2D

onready var _camera: Camera2D = $Camera

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	_fill_environment_scene()
	_move_objects_to_path()


func _input(event: InputEvent) -> void:
	if not _move_cheat_enabled:
		# input handling is only for move cheat
		return
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_right") != event.is_action_pressed("ui_left"):
			# calculate how far to move
			var distance := 1
			if event.shift:
				distance *= 5
			if event.is_action_pressed("ui_left"):
				distance *= -1
			
			# move the player forward/backward but keep them in the same region
			var region := PlayerData.career.current_region()
			PlayerData.career.distance_travelled = clamp(PlayerData.career.distance_travelled + distance,
					region.start, region.end)
			_move_objects_to_path()
		
		if PlayerData.career.is_boss_level():
			MusicPlayer.play_boss_track()
		else:
			MusicPlayer.play_menu_track()


func initial_environment_path() -> String:
	return _career_environment_path()


## Refreshes the environment and creatures based on the player's progress through career mode.
##
## Parameters:
## 	'level_posses': LevelPosse instances for creatures which should appear for each level.
func refresh_from_career_data(level_posses: Array) -> void:
	if not is_inside_tree():
		return
	
	if EnvironmentScene.resource_path != _career_environment_path():
		set_environment_scene(load(initial_environment_path()))
		_fill_environment_scene()
	_move_objects_to_path()
	
	for creature in _level_creatures:
		if creature.is_in_group("customers"):
			creature.remove_from_group("customers")
	
	if level_posses.size() == 1:
		_refresh_single_level_creatures(level_posses[0])
	else:
		_refresh_multi_level_creatures(level_posses)
	
	_move_camera()


func get_visible_customers(level_index: int) -> Array:
	var result: Array
	if PlayerData.career.level_choice_count() == 1:
		# only one level choice; return all visible customers
		result = get_tree().get_nodes_in_group("customers")
	else:
		# multiple level choices; return the appropriate level creature if they're a customer and not a chef
		if _level_creatures[level_index].is_in_group("customers"):
			result = [_level_creatures[level_index]]
	return result


## Adds environment objects like the player, sensei, level creatures, mile markers, and camera.
##
## This method merely adds them to the scene, but does not give them the correct position and appearance. That is
## handled by the _move_objects_to_path() function.
func _fill_environment_scene() -> void:
	_level_creatures.clear()
	
	if not overworld_environment.player:
		var player := overworld_environment.add_creature()
		player.creature_id = CreatureLibrary.PLAYER_ID
	
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		# don't add the sensei if they're not present in this region
		pass
	else:
		if not overworld_environment.sensei:
			var sensei := overworld_environment.add_creature()
			sensei.creature_id = CreatureLibrary.SENSEI_ID
	
	_player_path2d = overworld_environment.get_node("PlayerPath")
	
	for _i in range(3):
		_add_level_creature()


## Rearranges environment objects like the player, sensei, level creatures, mile markers, and camera.
func _move_objects_to_path() -> void:
	if not is_inside_tree():
		return
	
	var percent := _distance_percent()
	_move_player_to_path(percent)
	_move_sensei_to_path(percent)
	for i in range(3):
		_move_level_creature_to_path(i, percent)
	_remove_mile_markers()
	_add_mile_markers_to_path()
	_move_camera()


func _remove_mile_markers() -> void:
	if not is_inside_tree():
		return
	
	for mile_marker in get_tree().get_nodes_in_group("mile_markers"):
		mile_marker.queue_free()


func _career_environment_path() -> String:
	var environment_id := PlayerData.career.current_region().overworld_environment_id
	return ENVIRONMENT_PATH_BY_ID.get(environment_id, DEFAULT_ENVIRONMENT_PATH)


## Updates the creature/chef IDs for a boss/intro level, where the player only has one choice.
##
## For a boss/intro level, we show the chef and up to two customers. If a boss/intro level has a designed chef, the
## chef is in the middle.
##
## Parameters:
## 	'level_posse': Creatures which should appear for this level.
func _refresh_single_level_creatures(level_posse: LevelPosse) -> void:
	var remaining_customer_ids: Array = level_posse.customer_ids.duplicate()
	var remaining_creature_indexes := [1, 0, 2]
	
	if level_posse.chef_id and not _is_excluded_from_level_creatures(level_posse.chef_id):
		# if there's a chef_id, add the chef
		var creature: Creature = _level_creatures[remaining_creature_indexes.pop_front()]
		creature.creature_id = level_posse.chef_id
	
	if level_posse.observer_id and not _is_excluded_from_level_creatures(level_posse.observer_id):
		# if there's an observer_id, add the observer
		var creature: Creature = _level_creatures[remaining_creature_indexes.pop_front()]
		creature.creature_id = level_posse.observer_id
	
	while remaining_creature_indexes:
		# assign/randomize the remaining customer appearances
		var creature: Creature = _level_creatures[remaining_creature_indexes.pop_front()]
		creature.add_to_group("customers")
		
		# skip any excluded level creatures
		while remaining_customer_ids and _is_excluded_from_level_creatures(remaining_customer_ids.front()):
			remaining_customer_ids.pop_front()
		
		if remaining_customer_ids:
			# assign the next customer
			creature.creature_id = remaining_customer_ids.pop_front()
		else:
			# randomize the customer
			creature.creature_def = PlayerData.random_customer_def()
	
	_hide_duplicate_creatures()


## Returns 'true' if the specified creature shouldn't appear on the career map.
func _is_excluded_from_level_creatures(creature_id: String) -> bool:
	var result := false
	if creature_id == CreatureLibrary.PLAYER_ID:
		result = true
	if creature_id == CreatureLibrary.SENSEI_ID \
			and not PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		result = true
	return result


## Updates the creature/chef IDs for a non-boss level, where the player has three choices.
##
## For a non-boss/non-intro level, we show one creature for each of the different levels. We show the chef if the
## level has a designated chef, otherwise we show the level's customer.
##
## Parameters:
## 	'level_posses': LevelPosse instances for creatures which should appear for each level.
func _refresh_multi_level_creatures(level_posses: Array) -> void:
	for i in range(level_posses.size()):
		var chef_id: String = level_posses[i].chef_id
		var customer_ids: Array = level_posses[i].customer_ids
		var creature: Creature = _level_creatures[i]
		var refreshed_creature := false
		
		if chef_id and not _is_excluded_from_level_creatures(chef_id):
			# if there's a chef_id, show the level's chef
			creature.creature_id = chef_id
			refreshed_creature = true
		
		if not refreshed_creature and customer_ids:
			# if there's a customer_id, show the level's customer
			for next_customer_id in customer_ids:
				if not _is_excluded_from_level_creatures(next_customer_id):
					creature.add_to_group("customers")
					creature.creature_id = next_customer_id
					refreshed_creature = true
					break
		
		if not refreshed_creature:
			# randomize the customer
			creature.add_to_group("customers")
			creature.creature_def = PlayerData.random_customer_def()
	
	_hide_duplicate_creatures()


## Hides any duplicate creatures, if the same creature is visible for multiple levels.
##
## If two levels have the same chef or the same customer, we only show the rightmost duplicated creature.
func _hide_duplicate_creatures() -> void:
	var creatures_by_id := {}
	for creature_obj in _level_creatures:
		var creature: Creature = creature_obj
		creature.visible = true
		if creatures_by_id.has(creature.creature_id):
			creatures_by_id[creature.creature_id].visible = false
		creatures_by_id[creature.creature_id] = creature


## Calculates how far to the right the player should be positioned.
##
## Returns:
## 	A number in the range [0.0, 1.0] describing how far to the right the customer should be positioned.
func _distance_percent() -> float:
	var percent: float
	var region := PlayerData.career.current_region()
	if region.has_end():
		# for typical regions, move the player to the right gradually as they progress
		percent = CareerLevelLibrary.region_weight_for_distance(region, PlayerData.career.distance_travelled)
	else:
		# for the final endless region, put the player somewhere arbitrary
		percent = randf()
	return percent


## Adds a 'level creature', a chef or customer associated with a level.
func _add_level_creature() -> void:
	var creature := overworld_environment.add_creature()
	_level_creatures.append(creature)
	
	var mood: int
	if randf() < 0.8:
		mood = Utils.rand_value(MOODS_COMMON)
	elif randf() < 0.8:
		mood = Utils.rand_value(MOODS_UNCOMMON)
	else:
		mood = Utils.rand_value(MOODS_RARE)
	creature.set_meta("mood_when_hovered", mood)


## Repositions the specified 'level creature', a chef or customer associated with a level.
##
## Parameters:
## 	'creature_index': A number in the range [0, 2] specifying the creature to move.
##
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the creature should be positioned.
func _move_level_creature_to_path(creature_index: int, percent: float) -> void:
	# Determine the level creature's position. The creature is positioned slightly above _player_path2d.
	var creature_x_range := _camera_x_range()
	var creature: Creature = _level_creatures[creature_index]
	creature.position.x = lerp(creature_x_range.min_value, creature_x_range.max_value, percent) \
			+ X_DIST_BETWEEN_CUSTOMERS * (creature_index - 1)
	creature.position.y = _player_path2d_y(creature.position.x)
	
	if creature_index == 1:
		# the center creature is placed above the path
		creature.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH
	else:
		# the left and right creatures are closer to the path
		creature.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH * 0.4
	
	# turn creature towards player
	var player := overworld_environment.player
	if player:
		creature.orientation = Creatures.SOUTHEAST if player.position.x > creature.position.x else Creatures.SOUTHWEST


## Moves the player creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the player should be positioned.
func _move_player_to_path(percent: float) -> void:
	if not overworld_environment.player:
		return
	
	var player := overworld_environment.player
	var player_range := _camera_x_range()
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		# move player slightly left of the center creature
		player.position.x = lerp(player_range.min_value, player_range.max_value, percent) \
				- X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	else:
		# move player slightly right of the center creature
		player.position.x = lerp(player_range.min_value, player_range.max_value, percent) \
				+ X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	player.position.y = _player_path2d_y(player.position.x)


## Moves the sensei creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the sensei should be positioned.
func _move_sensei_to_path(percent: float) -> void:
	if not overworld_environment.sensei:
		return
	
	var sensei := overworld_environment.sensei
	var sensei_range := _camera_x_range()
	sensei.position.x = lerp(sensei_range.min_value, sensei_range.max_value, percent) \
			- X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	sensei.position.y = _player_path2d_y(sensei.position.x)


## Moves the camera so all creatures are visible.
func _move_camera() -> void:
	var creatures := []
	var sensei := overworld_environment.sensei
	if sensei:
		creatures.append(overworld_environment.sensei)
	creatures.append(overworld_environment.player)
	creatures.append_array(_level_creatures)
	_camera.zoom_in_on_creatures(creatures)


## Places mile markers along the path to indicate the distance of each customer.
##
## Mile markers are positioned relative to the _customers, not to the _player_path2d. Customers must be placed first.
func _add_mile_markers_to_path() -> void:
	# Calculate the values of the left and right mile marker
	var left_num: int
	var right_num: int
	var curr_region: CareerRegion = PlayerData.career.current_region()
	if curr_region.has_end():
		# In most regions, numbers count down to 0. 0 is a 'boss level'
		right_num = curr_region.length + curr_region.start - 1 - PlayerData.career.distance_travelled
		left_num = right_num + PlayerData.career.distance_penalties()[0]
	else:
		# In the final endless region, numbers count up from 0-99, and then reset back to 0
		right_num = PlayerData.career.distance_travelled - curr_region.start
		left_num = right_num - PlayerData.career.distance_penalties()[0]
		left_num %= 100
		right_num %= 100
	
	_add_mile_marker(_level_creatures[0].position + Vector2(-100, 20), left_num)
	if right_num != left_num:
		# Only place the right mile marker if it has a different value. We don't want two redundant mile markers for
		# boss levels or when starting a new career session.
		_add_mile_marker(_level_creatures[2].position + Vector2(100, 20), right_num)


## Places a mile marker at the specified position.
func _add_mile_marker(position: Vector2, mile_number: int) -> void:
		var marker: MileMarker = MileMarkerScene.instance()
		overworld_environment.add_obstacle(marker)
		
		marker.position = position
		marker.mile_number = mile_number


## Calculates and returns the leftmost/rightmost camera x position within the _player_path2d.
##
## The _player_path2d includes a range of x values where creatures can be placed, but the range of camera x values is
## slightly narrower than this.
##
## Returns:
## 	A dictionary defining 'min_value' and 'max_value' float values for the leftmost/rightmost camera x position
## 		within the _player_path2d
func _camera_x_range() -> Dictionary:
	var result := {}
	result.min_value = _player_path2d_point(0).x
	result.max_value = result.min_value
	for i in range(1, _player_path2d.curve.get_point_count()):
		var point_x := _player_path2d_point(i).x
		result.min_value = min(result.min_value, point_x)
		result.max_value = max(result.max_value, point_x)
	
	result.min_value += X_DIST_BETWEEN_CUSTOMERS
	result.max_value -= X_DIST_BETWEEN_CUSTOMERS
	
	return result


## Returns the absolute position of the vertex idx in _player_path2d.
func _player_path2d_point(idx: int) -> Vector2:
	return _player_path2d.curve.get_point_position(idx) + _player_path2d.position


## Returns the y coordinate corresponding to the specified x coordinate in _player_path2d.
##
## This assumes _player_path2d's vertices are arranged from left to right.
func _player_path2d_y(path2d_x: float) -> float:
	var path2d_y := _player_path2d_point(_player_path2d.curve.get_point_count() - 1).y
	
	for i in range(1, _player_path2d.curve.get_point_count()):
		var left_point := _player_path2d_point(i - 1)
		var right_point := _player_path2d_point(i)
		if right_point.x >= path2d_x:
			var f := inverse_lerp(left_point.x, right_point.x, path2d_x)
			path2d_y = lerp(left_point.y, right_point.y, f)
			break
	
	return path2d_y


## Update the '_focused_level_creature_index' value based on the selected level button.
##
## Parameters:
## 	'button_index': The index of the level button the player has selected.
func _update_focused_level_creature_index(button_index: int) -> void:
	if PlayerData.career.level_choice_count() == 1:
		# for boss/intro levels we focus the middle creature
		_focused_level_creature_index = 1
	elif _level_creatures[button_index].visible:
		# for nonboss/intro levels we focus the corresponding creature, if they're visible
		_focused_level_creature_index = button_index
	else:
		# If the level's corresponding creature is invisible, it's because the creature is assigned to multiple
		## levels. Update _focused_level_creature_index to the visible version of the creature.
		_focused_level_creature_index = -1
		for i in range(2):
			if _level_creatures[i].creature_id == _level_creatures[button_index].creature_id \
					and _level_creatures[i].visible:
				_focused_level_creature_index = i
				break


## Turns the player and sensei towards the focused level creature.
func _turn_towards_level_creature() -> void:
	var level_creature: Creature = _level_creatures[_focused_level_creature_index]
	
	var player := overworld_environment.player
	if player:
		player.orientation = Creatures.SOUTHEAST if level_creature.position.x > player.position.x \
				else Creatures.SOUTHWEST
	
	var sensei := overworld_environment.sensei
	if sensei:
		sensei.orientation = Creatures.SOUTHEAST if level_creature.position.x > sensei.position.x \
				else Creatures.SOUTHWEST


## Makes the currently focused level creature emote.
##
## When the player highlights a level, the focused creature smiles/laughs/pouts/etc...
func _make_level_creature_emote() -> void:
	if PlayerData.career.level_choice_count() == 1:
		return
	
	for i in range(_level_creatures.size()):
		var creature: Creature = _level_creatures[i]
		if i == _focused_level_creature_index and creature.has_meta("mood_when_hovered"):
			creature.play_mood(creature.get_meta("mood_when_hovered"))
		else:
			creature.play_mood(Creatures.Mood.DEFAULT)


## When a new level button is selected, the player/sensei orient towards it.
func _on_LevelSelect_level_button_focused(button_index: int) -> void:
	var old_focused_level_creature_index := _focused_level_creature_index
	_update_focused_level_creature_index(button_index)
	
	if _focused_level_creature_index == -1:
		# can't find a visible level creature
		pass
	elif _focused_level_creature_index == old_focused_level_creature_index:
		# Selecting a new button focused the same creature as before. This can happen if two buttons have the same
		# level creature.
		pass
	else:
		_turn_towards_level_creature()
		_make_level_creature_emote()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	match cheat:
		"cambra":
			# enable manual camera movement with arrow keys
			_camera.manual_mode = !_camera.manual_mode
			if not _camera.manual_mode:
				_move_camera()
			
			# disable the player move cheat to avoid a conflict. both cheats use the arrow keys
			if _camera.manual_mode and _move_cheat_enabled:
				_move_cheat_enabled = false
			
			detector.play_cheat_sound(_camera.manual_mode)
		"moveme":
			# enable manual player movement with arrow keys
			_move_cheat_enabled = !_move_cheat_enabled
			
			# disable the camera cheat to avoid a conflict. both cheats use the arrow keys
			if _move_cheat_enabled and _camera.manual_mode:
				_camera.manual_mode = false
				_move_camera()
			
			detector.play_cheat_sound(_move_cheat_enabled)
