extends Control
## Lines drawn between the spots on the progress board trail.
##
## This is actually just one big line, but it appears as multiple lines because the spots are drawn over top of it with
## a dark outline.

## Width in pixels of the main part of the trail
@export var line_width := 8.0

## Width in pixels of the trail's outline
@export var outline_width := 8.0

## Color for the main part of the trail
@export var path_color := Color.WHITE

## Color for the trail's outline
@export var outline_color := Color.TRANSPARENT

var path2d: Path2D: set = set_path2d

## Draws the line and outline.
func _draw() -> void:
	if not path2d:
		return
	
	var points := path2d.curve.get_baked_points()
	if points.size() >= 2:
		if outline_color.a > 0 and outline_width > 0:
			# don't waste cycles drawing invisible outlines
			draw_polyline(points, outline_color, line_width + 2 * outline_width, true)
		if path_color.a > 0 and line_width > 0:
			# don't waste cycles drawing invisible lines
			draw_polyline(points, path_color, line_width, true)


func set_path2d(new_path2d: Path2D) -> void:
	path2d = new_path2d
	queue_redraw()
