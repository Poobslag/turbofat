extends Control
## Lines drawn between the spots on the progress board trail.
##
## This is actually just one big line, but it appears as multiple lines because the spots are drawn over top of it with
## a dark outline.

## Width in pixels of the main part of the trail
export (float) var line_width := 8.0

## Width in pixels of the trail's outline
export (float) var outline_width := 8.0

## Color for the main part of the trail
export (Color) var path_color := Color.white setget set_path_color

## Color for the trail's outline
export (Color) var outline_color := Color.transparent

## If 'true', the line flashes different colors. Used when the player reaches a goal.
var cycle_colors: bool setget set_cycle_colors

var path2d: Path2D setget set_path2d

var _tween: SceneTreeTween

func _ready() -> void:
	_refresh_cycle_colors()


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


func set_cycle_colors(new_cycle_colors: bool) -> void:
	cycle_colors = new_cycle_colors
	_refresh_cycle_colors()


func set_path2d(new_path2d: Path2D) -> void:
	path2d = new_path2d
	update()


func set_path_color(new_path_color: Color) -> void:
	path_color = new_path_color
	update()


func _refresh_cycle_colors() -> void:
	if cycle_colors:
		# flash different colors
		_tween = Utils.recreate_tween(self, _tween)
		_tween.set_loops()
		var rainbow_colors := ProgressBoard.RAINBOW_CHALK_COLORS.duplicate()
		rainbow_colors.shuffle()
		for i in range(rainbow_colors.size()):
			_tween.tween_callback(self, "set", ["path_color", rainbow_colors[i]])
			_tween.tween_interval(ProgressBoard.RAINBOW_INTERVAL)
	else:
		# reset to our default color
		_tween = Utils.kill_tween(_tween)
		path_color = ProgressBoard.DEFAULT_CHALK_COLOR
