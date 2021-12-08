extends Node
## Populates/unpopulates the creatures and obstacles in the career mode's world.

## horizontal distance to maintain when placing the player and the sensei
const DISTANCE_BETWEEN_PLAYER_AND_SENSEI := 300

export (NodePath) var player_path2d_path: NodePath

## path on which which the player and sensei are placed
onready var _player_path2d: Path2D = get_node(player_path2d_path)
onready var _obstacle_manager: ObstacleManager = $ObstacleManager
onready var _camera: Camera2D = $Camera2D

func _ready() -> void:
	var percent := randf()
	
	_move_player_to_path(percent)
	_move_sensei_to_path(percent)
	_move_camera(percent)


## Moves the player creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the player should be positioned.
func _move_player_to_path(percent: float) -> void:
	var player := _find_player()
	var player_range := _player_path2d_x_range()
	player_range.max_value -= DISTANCE_BETWEEN_PLAYER_AND_SENSEI
	player.position.x = lerp(player_range.min_value, player_range.max_value, percent)
	player.position.y = _player_path2d_y(player.position.x)


## Moves the sensei creature to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the sensei should be positioned.
func _move_sensei_to_path(percent: float) -> void:
	var sensei := _find_sensei()
	var sensei_range := _player_path2d_x_range()
	sensei_range.min_value += DISTANCE_BETWEEN_PLAYER_AND_SENSEI
	sensei.position.x = lerp(sensei_range.min_value, sensei_range.max_value, percent)
	sensei.position.y = _player_path2d_y(sensei.position.x)


## Moves the camera to a point along _player_path2d.
##
## Parameters:
## 	'percent': A number in the range [0.0, 1.0] describing how far to the right the camera should be positioned.
func _move_camera(percent: float) -> void:
	var camera_range := _player_path2d_x_range()
	camera_range.min_value += DISTANCE_BETWEEN_PLAYER_AND_SENSEI * 0.5
	camera_range.max_value -= DISTANCE_BETWEEN_PLAYER_AND_SENSEI * 0.5
	_camera.position.x = lerp(camera_range.min_value, camera_range.max_value, percent)
	_camera.position.y = _player_path2d_y(_camera.position.x) - 150


## Calculates and returns the leftmost/rightmost x position on _player_path2d.
##
## Returns:
## 	A dictionary defining 'min_value' and 'max_value' properties corresponding to the leftmost/rightmost x position
## 	within the _player_path2d
func _player_path2d_x_range() -> Dictionary:
	var result := {}
	result.min_value = _player_path2d_point(0).x
	result.max_value = result.min_value
	for i in range(1, _player_path2d.curve.get_point_count()):
		var point_x := _player_path2d_point(i).x
		result.min_value = min(result.min_value, point_x)
		result.max_value = max(result.max_value, point_x)
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
	var player := _find_player()
	player.orientation = Creatures.SOUTHWEST if button_index == 0 else Creatures.SOUTHEAST
	
	var sensei := _find_sensei()
	sensei.orientation = Creatures.SOUTHEAST if button_index == 2 else Creatures.SOUTHWEST
