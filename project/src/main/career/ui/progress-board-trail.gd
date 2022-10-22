class_name ProgressBoardTrail
extends Control
## Spots and lines drawn to show a trail across the progress board.

export (NodePath) var path2d_path: NodePath

## Number of spots on the trail, including the start and ending spot.
export (int) var spot_count := 8 setget set_spot_count

## True if the number of spots on the board is truncated. Normally the player's start space is bigger, but when
## truncated the start space looks like just another spot. This way it looks like the player's already travelled a
## great distance.
export (bool) var spots_truncated := false setget set_spots_truncated

## The Path2D defining the shape of the trail.
onready var path2d: Path2D = get_node(path2d_path)

## Lines drawn between the spots on the trail.
onready var _lines := $Lines

## Spots drawn along the trail.
onready var _spots := $Spots

func _ready() -> void:
	_lines.path2d = path2d
	_spots.path2d = path2d
	_refresh_spots()


func set_spot_count(new_spot_count: int) -> void:
	spot_count = new_spot_count
	_refresh_spots()


func get_spot_position(i: int) -> Vector2:
	return _spots.get_child(i).rect_position


func set_spots_truncated(new_spots_truncated: bool) -> void:
	spots_truncated = new_spots_truncated
	_refresh_spots()


func _refresh_spots() -> void:
	if not is_inside_tree():
		return
	
	_spots.spot_count = spot_count
	_spots.spots_truncated = spots_truncated
