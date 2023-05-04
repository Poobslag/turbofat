@tool
class_name ProgressBoardClockVisuals
extends Node2D
## Draws the analog clock which appears above the progress board.
##
## The clock has an outline, empty/filled parts of the clock face, and a minute/hour hand.

## Number of points in the clock's outline. The higher this number, the smoother the outline.
const sample_count := 48.0

## Number in the range [0.0, 1.0] for how much of the clock face should be filled.
@export_range(0.0, 1.0) var filled_percent := 0.0: set = set_filled_percent

## Number in the range [0.0, 60.0] for the position of the minute hand.
##
## Numbers outside the range of [0.0, 60.0] will not cause errors, but will cause the hour hand to behave strangely. At
## 8:50 pm, the hour hand is between eight and nine. But at 8:200 pm, the hour hand is between eleven and twelve.
@export_range(0.0, 60.0) var minutes := 0.0: set = set_minutes

## Number in the range [0.0, 24.0] for the position of the hour hand.
##
## Numbers outside the range of [0, 12.0] are functionally equivalent, as this is only a twelve hour display.
@export_range(0.0, 24.0) var hours := 0.0: set = set_hours

## Radius of the clock face, not including the outline.
@export var radius := 50.0: set = set_radius

## Width of the lines used to draw the clock's outline and minute/hour hand.
@export var line_width := 8.0: set = set_line_width

## Length of the clock's hands.
@export var minute_hand_length := 40.0: set = set_minute_hand_length
@export var hour_hand_length := 30.0: set = set_hour_hand_length

## Colors used to draw different parts of the clock.
@export var empty_color := Color.WHITE: set = set_empty_color
@export var filled_color := Color.GRAY: set = set_filled_color
@export var line_color := Color.BLACK: set = set_line_color

@onready var _minute_hand := $MinuteHand
@onready var _hour_hand := $HourHand

func _ready() -> void:
	_refresh_hands()


func set_radius(new_radius: float) -> void:
	radius = new_radius
	queue_redraw()


func set_line_width(new_line_width: float) -> void:
	line_width = new_line_width
	_refresh_hands()
	queue_redraw()


func set_filled_percent(new_filled_percent: float) -> void:
	filled_percent = new_filled_percent
	queue_redraw()


func set_empty_color(new_empty_color: Color) -> void:
	empty_color = new_empty_color
	queue_redraw()


func set_filled_color(new_filled_color: Color) -> void:
	filled_color = new_filled_color
	queue_redraw()


func set_line_color(new_line_color: Color) -> void:
	line_color = new_line_color
	_refresh_hands()
	queue_redraw()


func set_minute_hand_length(new_minute_hand_length: float) -> void:
	minute_hand_length = new_minute_hand_length
	_refresh_hands()


func set_hour_hand_length(new_hour_hand_length: float) -> void:
	hour_hand_length = new_hour_hand_length
	_refresh_hands()


func set_minutes(new_minutes: float) -> void:
	minutes = new_minutes
	_refresh_hands()


func set_hours(new_hours: float) -> void:
	hours = new_hours
	_refresh_hands()


## Draws the clock's outline and face.
##
## Does not draw the clock's hands, which are child nodes which render themselves.
func _draw() -> void:
	_draw_empty_area()
	_draw_filled_area()
	_draw_outline()


## Returns a set of points around the outside of the clock face.
##
## The resulting points are ordered, starting from the 12 o'clock position and going clockwise.
##
## Parameters:
## 	'percent': (Optional) Number in the range [0.0, 1.0] for how many points should be returned. A value of '0.333'
## 		means the points from the 12 o'clock to 4 o'clock position will be returned. If omitted, a full set of points
## 		is returned.
##
## 		A number outside the range [0.0, 1.0] such as '1.50' will not produce errors, but will return a set of points
## 		which goes around the clock more than once.
##
## Returns:
## 	A set of points around the outside of the clock face.
func _circle_points(percent: float = 1.0) -> Array:
	var points := []
	var a := 0.0
	while a <= TAU * percent:
		points.append(Vector2(radius * sin(a), -radius * cos(a)))
		a += TAU / sample_count
	
	# append the exact last point; otherwise the circle might stop slightly short
	if percent < 1.0:
		a = TAU * filled_percent
		points.append(Vector2(radius * sin(a), -radius * cos(a)))
	
	return points


## Draws the empty area of the clock face.
func _draw_empty_area() -> void:
	var points := _circle_points()
	# todo: polygon antialiasing is disabled; this used to be specified as a parameter to draw_colored_polygon but 'Normal maps are now specified as part of the CanvasTexture rather than specifying them on the Canvasitem itself' https://github.com/godotengine/godot/issues/59683
	draw_colored_polygon(points, empty_color)


## Draws the filled area of the clock face.
func _draw_filled_area() -> void:
	if filled_percent == 0.0:
		return
	
	var points := _circle_points(filled_percent)
	if filled_percent < 1.0:
		points.append(Vector2.ZERO)
	# todo: polygon antialiasing is disabled; this used to be specified as a parameter to draw_colored_polygon but 'Normal maps are now specified as part of the CanvasTexture rather than specifying them on the Canvasitem itself' https://github.com/godotengine/godot/issues/59683
	draw_colored_polygon(points, filled_color)


## Draws the clock's outline.
func _draw_outline() -> void:
	var percent := 1.0
	var points := _circle_points(percent)
	draw_polyline(points, line_color, line_width, true)


## Updates the positions of the hour and minute hands.
func _refresh_hands() -> void:
	if not (is_inside_tree() and _minute_hand):
		return
	_minute_hand.default_color = line_color
	_minute_hand.width = line_width
	_minute_hand.points = [
		Vector2.ZERO,
		Vector2(0, -minute_hand_length).rotated(minutes * TAU / 60)
	]
	
	_hour_hand.default_color = line_color
	_hour_hand.width = line_width
	_hour_hand.points = [
		Vector2.ZERO,
		Vector2(0, -hour_hand_length).rotated(hours * TAU / 12)
	]
