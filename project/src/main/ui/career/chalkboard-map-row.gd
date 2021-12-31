class_name ChalkboardMapRow
extends Control
## A simplified chalk map where the player walks on a chalk path past chalk landmarks.
##
## The chalk map is divided into a cluster of circles on the left representing past landmarks, and icons on the right
## representing current landmarks.

## Maximum number of landmarks to show at once
const MAX_LANDMARK_COUNT := 6

export (Resource) var LandmarkScene: Resource
export (Resource) var LandmarkSpacerScene: Resource
export (Resource) var LandmarkLineScene: Resource

## The distance (in steps) of the circles representing past landmarks.
##
## This is used when calculating the player's position between the circles and the first landmark.
var circle_distance: int = 0.0 setget set_circle_distance

## The number of circles representing past landmarks
var circle_count: int = 0 setget set_circle_count

var landmark_count: int = 1 setget set_landmark_count
var player_distance: int = 0 setget set_player_distance

## List of Control nodes which separate landmarks.
var _landmark_spacers := []

## List of Landmark instances which show icons along the map.
var _landmarks := []

## Draws the circles on the left side of the map
onready var _circles_container := $MarginContainer/Landmarks/Circles

## Draws the landmark icons and distance labels along the map
onready var _landmarks_container := $MarginContainer/Landmarks

## Draws the lines connecting the landmarks. (Does not draw the line connecting the player.)
onready var _lines_container := $MarginContainer/Lines

## Draws the dot and label representing the player, as well as the line connecting them to the path.
onready var _player_landmark := $MarginContainer/Player

func _ready() -> void:
	_landmarks = get_tree().get_nodes_in_group("landmarks")
	_landmark_spacers = get_tree().get_nodes_in_group("landmark_spacers")
	_circles_container.circle_count = circle_count
	_player_landmark.distance = player_distance
	
	_refresh_landmarks()
	_refresh_player_distance()


## Assigns a new LandmarkType for the specified landmark.
func set_landmark_type(index: int, landmark_type: int) -> void:
	if index >= _landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return
	
	_landmarks[index].type = landmark_type


## Returns the LandmarkType for the specified landmark.
func get_landmark_type(index: int) -> int:
	if index >= _landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return Landmark.LandmarkType.NONE
	
	return _landmarks[index].type


## Assigns the distance for the specified landmark.
##
## This distance is displayed on a label, and also used when calculating the player's distance along the path.
func set_landmark_distance(index: int, landmark_distance: int) -> void:
	if index >= _landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return
	
	_landmarks[index].distance = landmark_distance
	_refresh_player_distance()


## Returns the distance for the specified landmark.
##
## This distance is displayed on a label, and also used when calculating the player's distance along the path.
func get_landmark_distance(index: int) -> int:
	if index >= _landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return 0
	
	return _landmarks[index].distance


func set_circle_count(new_circle_count: int) -> void:
	circle_count = new_circle_count
	if is_inside_tree():
		_circles_container.circle_count = new_circle_count
	_refresh_landmarks()


func set_landmark_count(new_landmark_count: int) -> void:
	landmark_count = clamp(new_landmark_count, 1, MAX_LANDMARK_COUNT)
	_refresh_landmarks()


func set_player_distance(new_player_distance: int) -> void:
	player_distance = new_player_distance
	_refresh_player_distance()


func set_circle_distance(new_circle_distance: int) -> void:
	circle_distance = new_circle_distance
	_refresh_player_distance()


## Adds or remove Landmark nodes based on the requested landmark count.
##
## Also adds and removes the corresponding landmark spacers.
func _refresh_landmarks() -> void:
	if not is_inside_tree():
		return
	
	while _landmarks.size() < landmark_count:
		# add spacer
		var new_spacer: Control = LandmarkSpacerScene.instance()
		_landmarks_container.add_child(new_spacer)
		_landmark_spacers.push_back(new_spacer)
		
		# add landmark
		var new_landmark: Landmark = LandmarkScene.instance()
		_landmarks_container.add_child(new_landmark)
		_landmarks.push_back(new_landmark)
	while _landmarks.size() > landmark_count:
		# remove landmark
		var removed_landmark: Landmark = _landmarks.pop_back()
		removed_landmark.queue_free()
		
		# remove spacer
		var removed_spacer: Control = _landmark_spacers.pop_back()
		removed_spacer.queue_free()


## Updates the player's location on the map and the numeric distance label value.
func _refresh_player_distance() -> void:
	if not is_inside_tree():
		return
	
	# calculate number
	_player_landmark.distance = player_distance
	
	# figure out which landmarks the player is between
	var right_landmark_index := 0
	for i in range(_landmarks.size()):
		var landmark: Landmark = _landmarks[i]
		right_landmark_index = i
		if _player_landmark.distance < landmark.distance:
			break
	
	_player_landmark.landmark_endpoints = _landmark_line_points(right_landmark_index)
	
	var from: float
	if right_landmark_index == 0:
		from = circle_distance
	else:
		from = _landmarks[right_landmark_index - 1].distance
	
	if _landmarks[right_landmark_index].distance == CareerData.MAX_DISTANCE_TRAVELLED:
		_player_landmark.progress_percent = clamp(
			inverse_lerp(from, from + 100, _player_landmark.distance), 0, 0.5)
	else:
		_player_landmark.progress_percent = clamp(
			inverse_lerp(from, _landmarks[right_landmark_index].distance, _player_landmark.distance), 0, 1)


## Returns the position of the line connecting two neighboring landmarks.
func _landmark_line_points(right_landmark_index: int) -> Array:
	var result := [Vector2.ZERO, Vector2.ZERO]
	if right_landmark_index == 0:
		result[0] = _circles_container.right_connection_point()
	else:
		result[0] = _landmarks[right_landmark_index - 1].right_connection_point()
	result[1] = _landmarks[right_landmark_index].left_connection_point()
	return result


## Removes and regenerates the lines connecting the landmarks.
func _refresh_lines() -> void:
	for child in _lines_container.get_children():
		child.queue_free()
	
	for i in range(_landmarks.size()):
		# draw a line connecting the previous landmark to this landmark
		var landmark_line: Line2D = LandmarkLineScene.instance()
		landmark_line.points = _landmark_line_points(i)
		
		_lines_container.add_child(landmark_line)


## When the Landmarks container arranges its children, we regenerate the lines connecting the landmarks.
##
## Lines can only be properly positioned after the Landmarks container arranges its children. The lines are arranged
## based on the position of the landmarks.
func _on_Landmarks_sort_children() -> void:
	_refresh_lines()
	_refresh_player_distance()
