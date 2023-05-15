@tool
extends OverworldObstacle
## Overworld obstacle with different cosmetic variations in a sprite sheet.

## Current frame to display from the sprite sheet.
@export (int) var frame: int: set = set_frame

## If true, the sprite's texture is flipped horizontally.
@export (bool) var flip_h: bool: set = set_flip_h

## Editor toggle which randomizes the obstacle's appearance
@export (bool) var shuffle: bool: set = set_shuffle

@onready var _sprite := $Sprite2D

func _ready() -> void:
	_refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_sprite = $Sprite2D


func set_frame(new_frame: int) -> void:
	frame = new_frame
	_refresh()


func set_flip_h(new_flip_h: bool) -> void:
	flip_h = new_flip_h
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_sprite.frame = frame
	_sprite.flip_h = flip_h


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	set_frame(randi() % (_sprite.hframes * _sprite.vframes))
	set_flip_h(randf() > 0.5)
	scale = Vector2.ONE
	
	notify_property_list_changed()
