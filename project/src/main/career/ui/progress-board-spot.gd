class_name ProgressBoardSpot
tool
extends Control
## Draws a spot on the progress board trail.
##
## A spot is usually represented by a single sprite frame, but large spots will have an empty space in the middle which
## looks bad. We cover this large spot with a 'hole sprite'.

export (int) var frame: int setget set_frame

## Sprite representing a spot on the progress board trail.
onready var _spot_sprite := $SpotSprite

## Covers up the empty area in the middle of a spot.
onready var _hole := $Hole

func _ready() -> void:
	_refresh_frame()


func set_frame(var new_frame: int) -> void:
	frame = new_frame
	_refresh_frame()


## Updates the spot sprite's frame, and toggles the 'hole sprite'.
func _refresh_frame() -> void:
	if not is_inside_tree():
		return
	
	_spot_sprite.frame = frame
	_hole.visible = true if frame == 12 else false
