extends Control
## Draws the player on the career mode's chalkboard map.
##
## This includes four components: a player graphic, a distance label, a dot along the player's current path, and a
## line connecting the player's dot to the distance label.

@export var map_row_path: NodePath

## Shows the player's distance.
@onready var _label: Label = $Label

## Shows a dot along the player's current path.
@onready var _dot_sprite: Sprite2D = $DotSprite

## Shows a player graphic above the path.
@onready var _player_sprite: Sprite2D = $PlayerSprite
@onready var _player_animation_player: AnimationPlayer = $PlayerSprite/AnimationPlayer

## Shows a line connecting the player's dot to the distance label.
@onready var _line: Line2D = $Line2D

@onready var _map_row: ChalkboardMapRow = get_node(map_row_path)

func _ready() -> void:
	_map_row.landmark_distance_changed.connect(_on_MapRow_landmark_distance_changed)
	_map_row.player_distance_changed.connect(_on_MapRow_player_distance_changed)
	_refresh()


## Updates the positions and values for all visual components.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	# update the label text
	_label.text = StringUtils.comma_sep(_map_row.player_distance)
	
	# calculate landmark_endpoints, progress_percent
	var landmarks := get_tree().get_nodes_in_group("landmarks")
	var right_landmark_index := _right_landmark_index(landmarks)
	var landmark_endpoints := LandmarkLines.landmark_line_points(landmarks, right_landmark_index)
	var progress_percent := _progress_percent(landmarks, right_landmark_index)
	
	if PlayerData.career.current_region().has_flag(CareerRegion.FLAG_NO_SENSEI):
		_player_animation_player.play("alone")
	else:
		_player_animation_player.play("default")
	
	# update the position of the player components
	_reposition_nodes(landmark_endpoints, progress_percent)


## Calculates the progress from one landmark to the next.
func _progress_percent(landmarks: Array, right_landmark_index: int) -> float:
	var progress_percent: float
	var from: float = landmarks[right_landmark_index - 1].distance
	if landmarks[right_landmark_index].distance == Careers.MAX_DISTANCE_TRAVELLED:
		progress_percent = clamp(
			inverse_lerp(from, from + 100, _map_row.player_distance), 0, 0.5)
	else:
		progress_percent = clamp(
			inverse_lerp(from, landmarks[right_landmark_index].distance, _map_row.player_distance), 0, 1)
	return progress_percent


## Determines which landmarks the player is between.
func _right_landmark_index(landmarks: Array) -> int:
	var right_landmark_index := 0
	for i in range(landmarks.size()):
		var landmark: Landmark = landmarks[i]
		right_landmark_index = i
		if _map_row.player_distance < landmark.distance:
			break
	return right_landmark_index


## Update the position of the player components.
##
## This includes the player's dot, distance label, and the line connecting the two.
func _reposition_nodes(landmark_endpoints: Array, progress_percent: float) -> void:
	# position the player's dot
	_dot_sprite.position = lerp(landmark_endpoints[0], landmark_endpoints[1], progress_percent)
	# connect line to the player's dot
	_line.points[0] = _dot_sprite.position
	
	# position the distance label
	_label.position = lerp(landmark_endpoints[0], \
			landmark_endpoints[1], 0.5) + Vector2(-_label.size.x * 0.5, 25)
	# connect line to the distance label
	_line.points[1] = _label.position + Vector2(_label.size.x * 0.5, 0)
	
	# position the player sprite
	_player_sprite.position = lerp(landmark_endpoints[0], \
			landmark_endpoints[1], progress_percent * 0.5 + 0.25) + Vector2(0, -40)


## When the Landmarks container arranges its children, we update the player's location on the map.
##
## The player can only be properly positioned after the Landmarks container arranges its children. The player is
## placed based on the position of the landmarks.
func _on_Landmarks_sort_children() -> void:
	_refresh()


## If the landmark distances change, we may need to move the player if they're further/closer to a landmark
func _on_MapRow_landmark_distance_changed() -> void:
	_refresh()


func _on_MapRow_player_distance_changed() -> void:
	_refresh()
