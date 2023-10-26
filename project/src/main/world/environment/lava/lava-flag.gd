tool
extends OverworldObstacle
## Flag which appears in the overworld for Chocolava Canyon.
##
## This script handles the horizontal flip logic, which is slightly different than most sprites because the flag sprite
## is lopsided.

export (bool) var flip_h: bool = false setget set_flip_h

onready var _sprite := $Sprite

func _ready() -> void:
	_refresh()


func set_flip_h(new_flip_h: bool) -> void:
	flip_h = new_flip_h
	_refresh()


func _initialize_onready_variables() -> void:
	_sprite = $Sprite


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	if Engine.editor_hint and not _sprite:
		_initialize_onready_variables()
	
	_sprite.scale.x = -1 if flip_h else 1
