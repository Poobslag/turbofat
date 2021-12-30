extends Control
## Draws the circles on the left side of career mode's chalkboard map.

var _circles_resources := [
	preload("res://assets/main/ui/career/map/circles-1.png"),
	preload("res://assets/main/ui/career/map/circles-2.png"),
	preload("res://assets/main/ui/career/map/circles-3.png"),
	preload("res://assets/main/ui/career/map/circles-4.png"),
	preload("res://assets/main/ui/career/map/circles-5.png"),
	preload("res://assets/main/ui/career/map/circles-6-plus.png"),
]

## The number of circles representing past landmarks
export (int) var circle_count: int = 1 setget set_circle_count

onready var _texture_rect := $TextureRect

func _ready() -> void:
	if not is_inside_tree():
		return
	
	_refresh()


## The position on the right side the circles where a chalk line can connect.
##
## This position is relative to the entire map, not relative to this landmark.
func right_connection_point() -> Vector2:
	var center := rect_position + rect_size * Vector2(0.5, 0.5)
	return center + Vector2(48, 18)


func set_circle_count(new_circle_count: int) -> void:
	circle_count = new_circle_count
	_refresh()


func _refresh() -> void:
	_texture_rect.texture = _circles_resources[clamp(circle_count - 1, 0, _circles_resources.size())]
