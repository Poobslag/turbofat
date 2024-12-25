class_name LandmarkLines
extends Control
## Draws lines connecting landmark icons for career mode's chalkboard map.

export (Resource) var LandmarkLineScene: Resource

func _ready() -> void:
	_refresh_lines()


## Removes and regenerates the lines connecting the landmarks.
func _refresh_lines() -> void:
	if not is_inside_tree():
		return
	
	var landmarks := get_tree().get_nodes_in_group("landmarks")
	
	for child in get_children():
		child.queue_free()
	
	for i in range(1, landmarks.size()):
		# draw a line connecting the previous landmark to this landmark
		var landmark_line: Line2D = LandmarkLineScene.instance()
		landmark_line.points = landmark_line_points(landmarks, i)
		add_child(landmark_line)


## When the Landmarks container arranges its children, we regenerate the lines connecting the landmarks.
##
## Lines can only be properly positioned after the Landmarks container arranges its children. The lines are arranged
## based on the position of the landmarks.
func _on_Landmarks_sort_children() -> void:
	_refresh_lines()


## Returns the position of the line connecting two neighboring landmarks.
##
## Parameters:
## 	'landmarks': An array of Landmark instances
##
## 	'right_landmark_index': The index of the right of the two neighboring landmarks.
##
## Returns:
## 	An array of two Vector2 instances representing the coordinates of a line connecting the specified neighboring
## 	landmarks.
static func landmark_line_points(landmarks: Array, right_landmark_index: int) -> Array:
	var result := [Vector2.ZERO, Vector2.ZERO]
	result[0] = landmarks[right_landmark_index - 1].right_connection_point()
	result[1] = landmarks[right_landmark_index].left_connection_point()
	return result
