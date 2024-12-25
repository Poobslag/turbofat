class_name ChalkboardMapRow
extends Control
## Simplified chalk map where the player walks on a chalk path past chalk landmarks.
##
## The chalk map is divided into a cluster of circles on the left representing past landmarks, and icons on the right
## representing current landmarks.

## Emitted when the player distance changes. Triggers child components to redraw/refresh their values
signal player_distance_changed

## Emitted when a landmark distance changes. Triggers child components to redraw/refresh their values
signal landmark_distance_changed

## Emitted when the landmark count changes. Triggers child components to redraw/refresh their values
signal landmark_count_changed

## Maximum number of landmarks to show at once
const MAX_LANDMARK_COUNT := 6

## Number of landmarks to show. The circles on the left side of the map count as one landmark.
var landmark_count: int = 2 setget set_landmark_count

## Distance the player has travelled in the current career session.
var player_distance: int = 0 setget set_player_distance

## Assigns a new LandmarkType for the specified landmark.
##
## Parameters:
## 	'index': The landmark index. '0' corresponds to the circles on the left side of the map, which are also a
## 		landmark.
##
## 	'landmark_type': Enum from Landmark.LandmarkType for the specified landmark.
func set_landmark_type(index: int, landmark_type: int) -> void:
	if not is_inside_tree():
		return
	
	var landmarks: Array = get_tree().get_nodes_in_group("landmarks")
	
	if index >= landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return
	
	landmarks[index].type = landmark_type


## Returns the LandmarkType for the specified landmark.
##
## Parameters:
## 	'index': The landmark index. '0' corresponds to the circles on the left side of the map, which are also a
## 		landmark.
##
## Returns:
## 	Enum from Landmark.LandmarkType for the specified landmark.
func get_landmark_type(index: int) -> int:
	if not is_inside_tree():
		return Landmark.LandmarkType.NONE
	
	var landmarks: Array = get_tree().get_nodes_in_group("landmarks")
	
	if index >= landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return Landmark.LandmarkType.NONE
	
	return landmarks[index].type


## Assigns the distance for the specified landmark.
##
## This distance is displayed on a label, and also used when calculating the player's distance along the path.
func set_landmark_distance(index: int, landmark_distance: int) -> void:
	if not is_inside_tree():
		return
	
	var landmarks: Array = get_tree().get_nodes_in_group("landmarks")
	
	if index >= landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return
	
	landmarks[index].distance = landmark_distance
	emit_signal("landmark_distance_changed")


## Returns the distance for the specified landmark.
##
## This distance is displayed on a label, and also used when calculating the player's distance along the path.
func get_landmark_distance(index: int) -> int:
	if not is_inside_tree():
		return 0
	
	var landmarks: Array = get_tree().get_nodes_in_group("landmarks")
	
	if index >= landmarks.size():
		push_warning("Invalid landmark index: %s" % [index])
		return 0
	
	return landmarks[index].distance


func set_landmark_count(new_landmark_count: int) -> void:
	landmark_count = clamp(new_landmark_count, 1, MAX_LANDMARK_COUNT)
	emit_signal("landmark_count_changed")


func set_player_distance(new_player_distance: int) -> void:
	player_distance = new_player_distance
	emit_signal("player_distance_changed")
