extends Node
## Demonstrates the chocolava canyon crowdies.
##
## This demo lets us view a bunch of them at once to make sure they look alright as a group.
##
## Keys:
## 	[=/-]: Increase/decrease the number of crowdie.
## 	Space: Toggle the crowd bouncing and cheering.

export (PackedScene) var LavaCrowdieScene: PackedScene

onready var _crowd_container := $CrowdContainer
onready var _gaze_target := $GazeTarget

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_EQUAL:
			_add_crowds(clamp(_crowd_container.get_child_count() * 0.61805, 3, 50))
		KEY_MINUS:
			_remove_crowds(clamp(_crowd_container.get_child_count() * 0.38196, 1, 50))
		KEY_SPACE:
			_toggle_bounce()
	
	if event is InputEventMouseMotion:
		_gaze_target.position = event.position


## Adds more crowdies.
func _add_crowds(count: int) -> void:
	for _i in range(count):
		var crowd: LavaCrowdie = LavaCrowdieScene.instance()
		crowd.shuffle = true
		var target_rect := Rect2(0, 0, 1024, 600).grow(-50)
		target_rect.position += Vector2(0, 50)
		crowd.position.x = rand_range(target_rect.position.x, target_rect.end.x)
		crowd.position.y = rand_range(target_rect.position.y, target_rect.end.y)
		_crowd_container.add_child(crowd)
		
		crowd.gaze_target_path = crowd.get_path_to(_gaze_target)


## Removes some crowdies.
func _remove_crowds(count: int) -> void:
	for _i in range(count):
		if _crowd_container.get_child_count() == 0:
			return
		
		var crowd: LavaCrowdie = _crowd_container.get_children().back()
		_crowd_container.remove_child(crowd)
		crowd.queue_free()


## Toggles the crowd bouncing and cheering.
func _toggle_bounce() -> void:
	if not is_inside_tree():
		return
	var new_bouncing := true
	if get_tree().get_nodes_in_group("lava_crowdies") \
			and get_tree().get_nodes_in_group("lava_crowdies").front().bouncing:
		new_bouncing = false
	
	for crowd in get_tree().get_nodes_in_group("lava_crowdies"):
		crowd.set_bouncing(new_bouncing)
