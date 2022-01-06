extends Node
## Populates/unpopulates the creatures and obstacles in the career mode's world.

## horizontal distance to maintain when placing the player and the sensei
const X_DIST_BETWEEN_PLAYER_AND_SENSEI := 180

## horizontal distance to maintain when placing customers
const X_DIST_BETWEEN_CUSTOMERS := 200

## vertical distance separating the customers from the player's path
const Y_DIST_BETWEEN_CUSTOMERS_AND_PATH := 80

## List of moods customers have when their level is chosen.
const MOODS_COMMON := [Creatures.Mood.SMILE0, Creatures.Mood.SMILE1, Creatures.Mood.WAVE0, Creatures.Mood.WAVE1]
const MOODS_UNCOMMON := [Creatures.Mood.LAUGH0, Creatures.Mood.LAUGH1, Creatures.Mood.LOVE1, Creatures.Mood.AWKWARD0]
const MOODS_RARE := [Creatures.Mood.AWKWARD1, Creatures.Mood.SIGH0, Creatures.Mood.SWEAT0, Creatures.Mood.THINK0]

export (NodePath) var player_path2d_path: NodePath

export (PackedScene) var MileMarkerScene: PackedScene

## List of moods each customer has when their level is chosen. Index 0 corresponds to the leftmost customer. Each
## entry is an enum in Creatures.Mood.
var _customer_moods := []

## List of Customer instances for the level's customers. Index 0 holds the leftmost customer.
var customers := []

## path on which which the player and sensei are placed
onready var _player_path2d: Path2D = get_node(player_path2d_path)

onready var _obstacles := $Obstacles
onready var _obstacle_manager: ObstacleManager = $ObstacleManager
onready var _camera: Camera2D = $Camera

func _ready() -> void:
	var percent := _distance_percent()
	_move_player_to_path(percent)
	_move_sensei_to_path(percent)
	for _i in range(3):
		_add_customer(percent)
	_add_mile_markers_to_path()
	_move_camera()


## Calculates how far to the right the player should be positioned.
##
## Returns:
## 	A number in the range [0.0, 1.0] describing how far to the right the customer should be positioned.
func _distance_percent() -> float:
	var percent: float
	var region := CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	if region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		# for 'endless regions' just put them somewhere arbitrary
		percent = randf()
	else:
		# for typicalregions, move them to the right gradually as they progress
		percent = CareerLevelLibrary.region_weight_for_distance(region, PlayerData.career.distance_travelled)
	return percent


## Adds a customer to a position slightly above _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the customer should be positioned.
func _add_customer(percent: float) -> void:
	var customer := _obstacle_manager.add_creature()
	customers.append(customer)
	var mood: int
	if randf() < 0.8:
		mood = Utils.rand_value(MOODS_COMMON)
	elif randf() < 0.8:
		mood = Utils.rand_value(MOODS_UNCOMMON)
	else:
		mood = Utils.rand_value(MOODS_RARE)
	_customer_moods.append(mood)
	customer.creature_def = CreatureLoader.random_def()
	
	# determine the customer's position
	var customer_range := _camera_x_range()
	customer.position.x = lerp(customer_range.min_value, customer_range.max_value, percent) \
			+ X_DIST_BETWEEN_CUSTOMERS * (customers.size() - 2)
	customer.position.y = _player_path2d_y(customer.position.x)
	
	match customers.size():
		1:
			# leftmost customer faces right
			customer.orientation = Creatures.SOUTHEAST
			customer.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH * 0.4
		2:
			# middle customer faces right
			customer.orientation = Creatures.SOUTHEAST
			customer.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH
		_:
			# rightmost customer faces left
			customer.orientation = Creatures.SOUTHWEST
			customer.position.y -= Y_DIST_BETWEEN_CUSTOMERS_AND_PATH * 0.4


## Moves the player creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the player should be positioned.
func _move_player_to_path(percent: float) -> void:
	var player := _find_player()
	var player_range := _camera_x_range()
	player.position.x = lerp(player_range.min_value, player_range.max_value, percent) \
			+ X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	player.position.y = _player_path2d_y(player.position.x)


## Moves the sensei creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the sensei should be positioned.
func _move_sensei_to_path(percent: float) -> void:
	var sensei := _find_sensei()
	var sensei_range := _camera_x_range()
	sensei.position.x = lerp(sensei_range.min_value, sensei_range.max_value, percent) \
			- X_DIST_BETWEEN_PLAYER_AND_SENSEI / 2.0
	sensei.position.y = _player_path2d_y(sensei.position.x)


## Moves the camera so all creatures are visible.
func _move_camera() -> void:
	var creatures := []
	creatures.append(_find_sensei())
	creatures.append(_find_player())
	creatures.append_array(customers)
	_camera.zoom_in_on_creatures(creatures)


## Places mile markers along the path to indicate the distance of each customer.
##
## Mile markers are positioned relative to the customers, not to the _player_path2d. Customers must be placed first.
func _add_mile_markers_to_path() -> void:
	# Calculate the values of the left and right mile marker
	var left_num: int
	var right_num: int
	var curr_region: CareerRegion = CareerLevelLibrary.region_for_distance(PlayerData.career.distance_travelled)
	if curr_region.length == CareerData.MAX_DISTANCE_TRAVELLED:
		# In the final (endless) region, numbers count up from 0-99, and then reset back to 0
		right_num = PlayerData.career.distance_travelled - curr_region.distance
		left_num = right_num - PlayerData.career.distance_penalties()[0]
		left_num %= 100
		right_num %= 100
	else:
		# In most regions, numbers count down to 0. 0 is a 'boss level'
		right_num = curr_region.length + curr_region.distance - 1 - PlayerData.career.distance_travelled
		left_num = right_num + PlayerData.career.distance_penalties()[0]
	
	_add_mile_marker(customers[0].position + Vector2(-100, 20), left_num)
	if right_num != left_num:
		# Only place the right mile marker if it has a different value. We don't want two redundant mile markers for
		# boss levels or when starting a new career session.
		_add_mile_marker(customers[2].position + Vector2(100, 20), right_num)


## Places a mile marker at the specified position.
func _add_mile_marker(position: Vector2, mile_number: int) -> void:
		var marker: MileMarker = MileMarkerScene.instance()
		_obstacle_manager.add_obstacle(marker)
		
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


func _find_player() -> Creature:
	return _obstacle_manager.find_creature(CreatureLibrary.PLAYER_ID)


func _find_sensei() -> Creature:
	return _obstacle_manager.find_creature(CreatureLibrary.SENSEI_ID)


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


## When a new level button is selected, the player/sensei orient towards it.
func _on_LevelSelect_level_button_focused(button_index: int) -> void:
	var button_count := 1 if PlayerData.career.is_boss_level() else 3
	var button_x := inverse_lerp(0, button_count - 1, button_index)
	
	var player := _find_player()
	player.orientation = Creatures.SOUTHEAST if button_x >= 0.7 else Creatures.SOUTHWEST
	
	var sensei := _find_sensei()
	sensei.orientation = Creatures.SOUTHWEST if button_x <= 0.3 else Creatures.SOUTHEAST
	
	if not PlayerData.career.is_boss_level():
		for i in range(customers.size()):
			if i == button_index:
				customers[i].play_mood(_customer_moods[i])
			else:
				customers[i].play_mood(Creatures.Mood.DEFAULT)
