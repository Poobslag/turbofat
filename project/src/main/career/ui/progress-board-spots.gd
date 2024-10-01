extends Control
## Spots drawn along the progress board trail.

## Frames in the sprite sheet for small spots. Small spots are used when there isn't room for other sizes.
const SPOT_FRAMES_SMALL := [0, 1, 2, 3]

## Frames in the sprite sheet for medium spots. Medium spots are used between the start and finish.
const SPOT_FRAMES_MEDIUM := [4, 5, 6, 7]

## Frames in the sprite sheet for the spot at the start of the trail.
const SPOT_FRAMES_START := [8, 9, 10, 11]

## Frames in the sprite sheet for the spot at the end of the trail.
const SPOT_FRAMES_FINISH := [12]

export (PackedScene) var spot_scene: PackedScene

var path2d: Path2D setget set_path2d

## Number of spots on the trail, including the start and ending spot.
var spot_count: int = 0 setget set_spot_count

## True if the number of spots on the board is truncated. Normally the player's start space is bigger, but when
## truncated the start space looks like just another spot. This way it looks like the player's already travelled a
## great distance.
var spots_truncated: bool = false setget set_spots_truncated

## If 'true', the spots flash different colors. Used when the player reaches a goal.
var cycle_colors: bool setget set_cycle_colors

var _tween: SceneTreeTween

## Colors used for progress board spots when cycle_colors is true. The first array entry is used to color the first
## spot.
var _rainbow_colors: Array

func _ready() -> void:
	_refresh_spots()
	_refresh_cycle_colors()


func set_cycle_colors(new_cycle_colors: bool) -> void:
	cycle_colors = new_cycle_colors
	_refresh_cycle_colors()


func set_path2d(new_path2d: Path2D) -> void:
	path2d = new_path2d
	_refresh_spots()


func set_spot_count(new_spot_count: int) -> void:
	spot_count = new_spot_count
	_refresh_spots()


func set_spots_truncated(new_spots_truncated: bool) -> void:
	spots_truncated = new_spots_truncated
	_refresh_spots()


func get_spot(i: int) -> ProgressBoardSpot:
	return get_child(i) as ProgressBoardSpot


## Returns the position along the trail of the specified spot.
##
## This can be called with a whole number like '3' which will return the position of the fourth spot. It can also be
## called with a decimal like '3.5' which will return a position half-way between the fourth and fifth spot.
##
## Parameters:
## 	'i': The spot whose position should be returned. This can be a whole number like '3' to obtain a spot's exact
## 		position, or a decimal like '3.5' to obtain a position between two spots.
##
## Returns:
## 	The position of the specified spot, or a position between the two specified spots.
func get_spot_position(i: float) -> Vector2:
	if path2d == null:
		return Vector2.ZERO
	
	var baked_points := path2d.curve.get_baked_points()
	var baked_point_float_index: float = lerp(0, baked_points.size() - 1, \
			inverse_lerp(0, spot_count - 1, i))
	
	# avoid baked_points OOB issues by bounding baked_point_float_index
	baked_point_float_index = clamp(baked_point_float_index, 0, baked_points.size() - 1)
	
	return lerp(
			baked_points[int(floor(baked_point_float_index))],
			baked_points[int(ceil(baked_point_float_index))],
			baked_point_float_index - int(baked_point_float_index))


## Cycles the rainbow colors by one, changing the color of all progress board spots.
func _change_rainbow() -> void:
	_rainbow_colors.push_back(_rainbow_colors.pop_front())
	for i in range(get_child_count()):
		get_child(i).set_spot_color(_rainbow_colors[i % _rainbow_colors.size()])


func _refresh_cycle_colors() -> void:
	if cycle_colors:
		# flash different colors
		_tween = Utils.recreate_tween(self, _tween)
		_tween.set_loops()
		_rainbow_colors = ProgressBoard.RAINBOW_CHALK_COLORS.duplicate()
		_rainbow_colors.shuffle()
		_tween.tween_callback(self, "_change_rainbow")
		_tween.tween_interval(ProgressBoard.RAINBOW_INTERVAL)
	else:
		# reset to our default color
		_tween = Utils.kill_tween(_tween)
		for child in get_children():
			child.set_spot_color(ProgressBoard.DEFAULT_CHALK_COLOR)


## Deletes and recreates all spots on the trail, assigning their positions and frames.
func _refresh_spots() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	# position children
	if path2d != null:
		for point_index in spot_count:
			var spot: ProgressBoardSpot = spot_scene.instance()
			spot.rect_position = get_spot_position(point_index)
			add_child(spot)
	
	# calculate minimum distance between two adjacent spots
	var min_dist := 999999.0
	for child_index in range(1, get_child_count()):
		var dist: float = get_child(child_index - 1).rect_position.distance_to(get_child(child_index).rect_position)
		min_dist = min(dist, min_dist)
	
	# assign frames; make each spot a circle, dot, or star
	for child_index in range(get_child_count()):
		var child: ProgressBoardSpot = get_child(child_index)
		var possible_frames := []
		if child_index == get_child_count() - 1:
			possible_frames = SPOT_FRAMES_FINISH
		elif child_index == 0 and not spots_truncated:
			possible_frames = SPOT_FRAMES_START
		else:
			possible_frames = SPOT_FRAMES_MEDIUM if min_dist > 25 else SPOT_FRAMES_SMALL
		child.frame = Utils.rand_value(possible_frames)
