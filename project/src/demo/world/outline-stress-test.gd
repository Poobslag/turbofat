extends Node
"""
Shows the impact of the outline shader on FPS.
"""

const INITIAL_STAR_COUNT := 25

export (PackedScene) var StarPackedScene: PackedScene

func _ready() -> void:
	_add_stars(INITIAL_STAR_COUNT)
	_refresh_star_count()


"""
Adds stars to the scene.

The stars are selected sequentially using a predetermined set of star IDs.

Parameters:
	'count': The number of stars to add.
"""
func _add_stars(count: int) -> void:
	for _i in range(0, count):
		var star: Sprite = StarPackedScene.instance()
		
		var star_index := $Stars.get_child_count()
		
		var target_rect := Rect2(0, 0, 1024, 768).grow(-64)
		star.position.x = rand_range(target_rect.position.x, target_rect.end.x)
		star.position.y = rand_range(target_rect.position.y, target_rect.end.y)
		star.modulate = Color(1.0, 1.0, 1.0, 0.1)
		
		$Stars.add_child(star)
		_refresh_star_count()


"""
Removes stars from the scene.

The stars are removed in FILO order.

Parameters:
	'count': The number of stars to add.
"""
func _remove_stars(count: int) -> void:
	for _i in range(0, count):
		if $Stars.get_child_count() == 0:
			break
		
		var star: Sprite = $Stars.get_children().back()
		star.queue_free()
		$Stars.remove_child(star)
		_refresh_star_count()


"""
Updates the 'star count' label.
"""
func _refresh_star_count() -> void:
	$Ui/Control/StarCount.text = str($Stars.get_child_count())


func _on_Button_pressed(star_delta: int) -> void:
	if star_delta > 0:
		_add_stars(star_delta)
	elif star_delta < 0:
		_remove_stars(-star_delta)
