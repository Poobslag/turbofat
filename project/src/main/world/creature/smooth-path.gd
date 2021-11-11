tool
class_name SmoothPath
extends Path2D
## A utility class which allows developers to draw curves in the Godot editor. Use the path tool to define line
## segments, then enable the 'smooth' setting in the inspector.
##
## Adapted from Dlean Jeans' code at https://godotengine.org/qa/32506/how-to-draw-a-curve-in-2d?show=57123#a57123

export(float) var spline_length := 25.0
export(bool) var _smooth: bool setget smooth
export(bool) var _straighten: bool setget straighten
export(bool) var closed := true

export(Color) var line_color := Color.black setget set_line_color
export(Color) var fill_color := Color.transparent setget set_fill_color
export(float) var line_width := 8.0

## internal array used for drawing polygons
var _poly_colors := PoolColorArray()

func _ready() -> void:
	update()


func _draw() -> void:
	var points := curve.get_baked_points()
	if points.size() >= 3:
		if fill_color.a > 0:
			# don't waste cycles drawing invisible polygons
			if _poly_colors.size() != points.size():
				_poly_colors.resize(points.size())
				for i in range(_poly_colors.size()):
					_poly_colors[i] = fill_color
			draw_polygon(points, _poly_colors, PoolVector2Array(), null, null, true)
		if line_color.a > 0:
			# don't waste cycles drawing invisible lines
			if closed:
				points.append(points[0])
			draw_polyline(points, line_color, line_width, true)


func set_line_color(new_line_color: Color) -> void:
	line_color = new_line_color
	update()


func set_fill_color(new_fill_color: Color) -> void:
	fill_color = new_fill_color
	for i in range(_poly_colors.size()):
		_poly_colors.set(i, new_fill_color)
	update()


## Straightens the Path2D into a series of straight lines, instead of smooth curves.
##
## Parameters:
## 	'value': If true, the Path2D will be straightened. If false, the method does nothing.
func straighten(value: bool) -> void:
	if not value:
		return
	for i in curve.get_point_count():
		curve.set_point_in(i, Vector2())
		curve.set_point_out(i, Vector2())


## Smooths the Path2D into a series of smooth curves, instead of straight lines.
##
## Parameters: If 'value' is true, the Path2D will be smoothed. If false, the method does nothing.
func smooth(value: bool) -> void:
	if not value:
		return
	for i in curve.get_point_count():
		var spline := _get_spline(i)
		curve.set_point_in(i, -spline)
		curve.set_point_out(i, spline)


func _get_spline(i: int) -> Vector2:
	var last_point := _get_point(i - 1)
	var next_point := _get_point(i + 1)
	return last_point.direction_to(next_point) * spline_length


func _get_point(i: int) -> Vector2:
	var point_count := curve.get_point_count()
	return curve.get_point_position(wrapi(i, 0, point_count - 1))
