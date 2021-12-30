extends Node
## Demonstrates the map which shows up after the player finishes career mode.
##
## Keys:
## 	[Q,W,E,R,T,Y,U]: Toggle the number of circles on the left side of the map
## 	[brace keys]: Increase/decrease the number of landmarks
## 	[A,S,D,F,G,H]: Switch between different landmarks
## 	[-, =]: Move the player left/right
## 	[Shift + -, Shift + =]: Move the player left right faster

onready var _map_row := $MapRow

func _ready() -> void:
	_map_row.landmark_count = 5
	_map_row.player_distance = 35
	_map_row.circle_count = 1
	for i in range(_map_row.landmark_count):
		_map_row.set_landmark_distance(i, (i + 1) * 20)
		_map_row.set_landmark_type(i, _random_landmark_type())


func _random_landmark_type() -> int:
	return Utils.rand_value([
			Landmark.CACTUS,
			Landmark.FOREST,
			Landmark.GEAR,
			Landmark.ISLAND,
			Landmark.RAINBOW,
			Landmark.SKULL,
			Landmark.VOLCANO,
		])


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Q: _map_row.set_circle_count(0)
		KEY_W: _map_row.set_circle_count(1)
		KEY_E: _map_row.set_circle_count(2)
		KEY_R: _map_row.set_circle_count(3)
		KEY_T: _map_row.set_circle_count(4)
		KEY_Y: _map_row.set_circle_count(5)
		KEY_U: _map_row.set_circle_count(6)
		KEY_BRACELEFT:
			_map_row.landmark_count -= 1
		KEY_BRACERIGHT:
			_map_row.landmark_count += 1
			_map_row.set_landmark_distance(_map_row.landmark_count - 1, _map_row.landmark_count * 20)
			_map_row.set_landmark_type(_map_row.landmark_count - 1, _random_landmark_type())
		KEY_A: _increment_landmark_type(0)
		KEY_S: _increment_landmark_type(1)
		KEY_D: _increment_landmark_type(2)
		KEY_F: _increment_landmark_type(3)
		KEY_G: _increment_landmark_type(4)
		KEY_H: _increment_landmark_type(5)
		KEY_MINUS: _map_row.player_distance -= 10 if Input.is_key_pressed(KEY_SHIFT) else 1
		KEY_EQUAL: _map_row.player_distance += 10 if Input.is_key_pressed(KEY_SHIFT) else 1


## Changes the icon for the specified landmark.
func _increment_landmark_type(landmark_index: int) -> void:
	var old_landmark_type: int = _map_row.get_landmark_type(landmark_index)
	var new_landmark_type: int = (old_landmark_type + 1) % Landmark.LandmarkType.size()
	_map_row.set_landmark_type(landmark_index, new_landmark_type)
