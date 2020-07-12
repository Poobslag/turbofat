extends AnimationPlayer
"""
Moves the restaurant scene's camera as creatures get fatter.

While this is an AnimationPlayer, the animation is only used to calculate the camera position. It shouldn't ever be
played as an animation.
"""

export (NodePath) var restaurant_scene_path: NodePath

# the position that the restaurant scene's camera lerps to
export (Vector2) var _target_camera_position: Vector2

onready var _restaurant_scene: RestaurantScene = get_node(restaurant_scene_path)

func _ready() -> void:
	_restaurant_scene.get_creature_2d(0).connect("visual_fatness_changed", self, \
			"_on_Creature_visual_fatness_changed", [0])
	_restaurant_scene.get_creature_2d(1).connect("visual_fatness_changed", self, \
			"_on_Creature_visual_fatness_changed", [1])
	_restaurant_scene.get_creature_2d(2).connect("visual_fatness_changed", self, \
			"_on_Creature_visual_fatness_changed", [2])


func _physics_process(_delta: float) -> void:
	_restaurant_scene.camera_position = lerp(_restaurant_scene.camera_position, _target_camera_position, 0.16)


func _refresh_target_camera_position() -> void:
	play("fat-se")
	advance(_restaurant_scene.get_creature_2d(_restaurant_scene.current_creature_index).get_visual_fatness())
	stop()


func _on_Creature_visual_fatness_changed(index: int) -> void:
	if index == _restaurant_scene.current_creature_index:
		# only adjust the camera if the current creature changes
		_refresh_target_camera_position()


func _on_RestaurantScene_current_creature_index_changed(_value: int) -> void:
	_refresh_target_camera_position()
