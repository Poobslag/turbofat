class_name LoadingProgressBar
extends Node2D
## Progress bar which appears at the bottom of the loading screen.
##
## The progress bar has a full part and an empty part. The full part is drawn as a solid line, and the empty part
## is drawn as a dotted line.

## The speed at which the empty part scrolls to the left.
var LINE_SCROLL_SPEED := 60.0

## The minimum length of the full part of the progress bar. The empty part disappears behind it to create the
## scrolling effect, so if the full part is ever gone then the illusion will be ruined.
var DOTTED_LINE_PIXELS := 64.0

## A number in the range of [0.0, 1.0] for the current progress bar value
var value := 0.0 setget set_value

## The extents of the progress bar
var _extents := Rect2(Vector2(40, Global.window_size.y - 40), Vector2(Global.window_size.x - 80, 0))

## The current offset to draw the empty part of the progress bar. We gradually decrement this to cause the
## scrolling effect.
var _dotted_line_offset: float = 0

## The full part of the progress bar.
onready var _full: Line2D = $Full

## The empty part of the progress bar.
onready var _empty: Line2D = $Empty

func _ready() -> void:
	_full.points = [_extents.position, _extents.position]
	_empty.points = [_extents.end, _extents.end]


func _process(delta: float) -> void:
	_dotted_line_offset = fmod(_dotted_line_offset - LINE_SCROLL_SPEED * delta, DOTTED_LINE_PIXELS)
	_refresh_lines()


func set_value(new_value: float) -> void:
	value = new_value
	_refresh_lines()


## The x coordinate where the full part and empty part meet.
func progress_point() -> Vector2:
	return _full.points[1]


## Recalculates the endpoints of the progress bar lines.
func _refresh_lines() -> void:
	# calculate the rightmost point of the full part
	_full.points[1] = lerp(_extents.position, _extents.end, value)
	_full.points[1].x = clamp(_full.points[1].x, _extents.position.x + DOTTED_LINE_PIXELS, _extents.end.x)
	
	# calculate the leftmost point of the empty part
	_empty.points[0] = Vector2(_extents.position.x + DOTTED_LINE_PIXELS + _dotted_line_offset, Global.window_size.y - 40)
