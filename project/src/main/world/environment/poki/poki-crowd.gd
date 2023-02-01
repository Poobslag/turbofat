tool
class_name PokiCrowd
extends OverworldObstacle
## Poki desert crowd member which appears in the overworld.
##
## This script randomizes the crowd member's color, appearance and direction.

const CROWD_COLORS := [
	Color("3d291f"),
	Color("4c3125"),
	Color("5d3b2b"),
	Color("6c4331"),
]

## Current frame to display from the sprite sheet.
export (int) var frame: int setget set_frame

## If true, the sprite's texture is flipped horizontally.
export (bool) var flip_h: bool setget set_flip_h

## An editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle

export (int, 0, 3) var crowd_color_index: int setget set_crowd_color_index

onready var _sprite := $Sprite

## A timer which makes the crowd member animate slightly, alternating between two frames
onready var _wiggle_timer := $WiggleTimer

func _ready() -> void:
	if Engine.editor_hint:
		# don't animate the crowd member in the editor, otherwise it randomizes the 'frame' and 'wait_time' fields
		# polluting version control
		pass
	else:
		_wiggle_timer.start(rand_range(0.0, 7.0))
	
	_refresh()


## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_sprite = $Sprite


func set_frame(new_frame: int) -> void:
	frame = new_frame
	_refresh()


func set_flip_h(new_flip_h: bool) -> void:
	flip_h = new_flip_h
	_refresh()


func set_crowd_color_index(new_crowd_color_index: int) -> void:
	crowd_color_index = new_crowd_color_index
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_sprite.frame = frame
	_sprite.flip_h = flip_h
	_sprite.modulate = CROWD_COLORS[crowd_color_index]


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	set_frame(randi() % (_sprite.hframes * _sprite.vframes))
	set_flip_h(randf() < 0.5)
	set_crowd_color_index(Utils.randi_range(0, CROWD_COLORS.size() - 1))
	scale = Vector2.ONE
	
	property_list_changed_notify()


## When the WiggleTimer times out, we animate the crowd member slightly.
##
## Crowd members each have two frames. When the timer times out we switch to their other frame.
func _on_WiggleTimer_timeout() -> void:
	# switch the crowd member to their other frame
	if frame % 2 == 0:
		set_frame(frame + 1)
	else:
		set_frame(frame - 1)
	
	# randomly vary the wiggle timer slightly
	_wiggle_timer.start(rand_range(6.0, 7.0))
