extends Tween
"""
Makes the music popup appear and disappear.
"""

# the how long it takes the popup to slide in or out of view
const TWEEN_DURATION := 0.2

# the duration that the popup remains visible
const POPUP_DURATION := 4.0

onready var _music_panel := get_node("../Panel")

"""
Makes the music popup appear, and then hides it after a few seconds.

Parameters:
	'pop_in_delay': The number of seconds to wait before showing the popup.
"""
func pop_in_and_out(pop_in_delay: float) -> void:
	if pop_in_delay:
		yield(get_tree().create_timer(pop_in_delay), "timeout")
	_pop_in()
	$Timer.start(POPUP_DURATION)
	yield($Timer, "timeout")
	_pop_out()


func _pop_in() -> void:
	remove_all()
	interpolate_property(_music_panel, "rect_position:y", _music_panel.rect_position.y, 32, TWEEN_DURATION)
	start()


func _pop_out() -> void:
	remove_all()
	interpolate_property(_music_panel, "rect_position:y", _music_panel.rect_position.y, 0, TWEEN_DURATION)
	start()
