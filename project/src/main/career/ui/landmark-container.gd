extends HBoxContainer
## Draws landmark icons for career mode's chalkboard map.

export (Resource) var LandmarkScene: Resource
export (Resource) var LandmarkSpacerScene: Resource

export (NodePath) var map_row_path: NodePath

## List of Control nodes which separate landmarks.
var _landmark_spacers := []

## List of Landmark instances which show icons along the map.
var _landmarks := []

onready var _map_row: ChalkboardMapRow = get_node(map_row_path)

func _ready() -> void:
	_map_row.connect("landmark_count_changed", self, "_on_MapRow_landmark_count_changed")
	_landmarks = get_tree().get_nodes_in_group("landmarks")
	_landmark_spacers = get_tree().get_nodes_in_group("landmark_spacers")
	_refresh_landmarks()


## Adds or remove Landmark nodes based on the requested landmark count.
##
## Also adds and removes the corresponding landmark spacers.
func _refresh_landmarks() -> void:
	if not is_inside_tree():
		return
	
	while _landmarks.size() < _map_row.landmark_count:
		# add spacer
		var new_spacer: Control = LandmarkSpacerScene.instance()
		add_child(new_spacer)
		_landmark_spacers.append(new_spacer)
		
		# add landmark
		var new_landmark: Landmark = LandmarkScene.instance()
		add_child(new_landmark)
		_landmarks.append(new_landmark)
	
	while _landmarks.size() > _map_row.landmark_count:
		# remove landmark from scene tree
		var removed_landmark: Landmark = _landmarks.pop_back()
		remove_child(removed_landmark)
		removed_landmark.queue_free()
		
		# remove spacer from scene tree
		var removed_spacer: Control = _landmark_spacers.pop_back()
		remove_child(removed_spacer)
		removed_spacer.queue_free()


func _on_MapRow_landmark_count_changed() -> void:
	_refresh_landmarks()
