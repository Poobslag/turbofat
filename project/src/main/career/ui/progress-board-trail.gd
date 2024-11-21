class_name ProgressBoardTrail
extends Control
## Spots and lines drawn to show a trail across the progress board.

export (NodePath) var path2d_path: NodePath setget set_path2d_path

## Number of spots on the trail, including the start and ending spot.
export (int) var spot_count := 8 setget set_spot_count

## True if the number of spots on the board is truncated. Normally the player's start space is bigger, but when
## truncated the start space looks like just another spot. This way it looks like the player's already travelled a
## great distance.
export (bool) var spots_truncated := false setget set_spots_truncated

## Shape of the trail.
onready var path2d: Path2D

## Lines between the spots on the trail.
onready var _lines := $Lines

## Spots drawn along the trail.
onready var _spots := $Spots

func _ready() -> void:
	_refresh_path2d_path()


func set_path2d_path(new_path2d_path: NodePath) -> void:
	path2d_path = new_path2d_path
	_refresh_path2d_path()


func set_spot_count(new_spot_count: int) -> void:
	spot_count = new_spot_count
	_refresh_spots()


## Returns the position along the trail of the specified spot.
##
## This can be called with a whole number like '3' which will return the position of the fourth spot. It can also be
## called with a decimal like '3.5' which will return a position half-way between the fourth and fifth spot.
##
## Parameters:
## 	'i': The spot whose position should be returned. This can be a whole number like '3' to obtain a spot's exact
## 		position, or a decimal like '3.5' to obtain a position between two spots.
##
## Returns:
## 	The position of the specified spot, or a position between the two specified spots.
func get_spot_position(i: float) -> Vector2:
	return _spots.get_spot_position(i)


func get_goal_position() -> Vector2:
	return _spots.get_spot_position(_spots.spot_count)


func set_spots_truncated(new_spots_truncated: bool) -> void:
	spots_truncated = new_spots_truncated
	_refresh_spots()


func _refresh_path2d_path() -> void:
	if not is_inside_tree():
		return
	
	path2d = get_node(path2d_path) if path2d_path else null
	
	_lines.path2d = path2d
	_spots.path2d = path2d
	
	_refresh_spots()


func _refresh_spots() -> void:
	if not is_inside_tree():
		return
	
	_spots.has_goal = PlayerData.career.current_region().has_end()
	_spots.spot_count = spot_count
	_spots.spots_truncated = spots_truncated


## When the player reaches the goal, the trail flashes different colors.
func _on_Player_travelling_finished() -> void:
	if PlayerData.career.is_boss_level() and PlayerData.career.can_play_more_levels():
		_spots.set_cycle_colors(true)
		_lines.set_cycle_colors(true)
