extends Node
"""
List of paths representing the current scene and its ancestors, leading back to the main menu.

This breadcrumb trail is used for navigation. It keeps track of which scene the user should go back to when they press
the various 'Quit' buttons throughout the game.
"""

"""
Emitted when the user goes back, popping the front item off of the breadcrumb trail

Parameters:
	'prev_path': The path item which was just popped from the breadcrumb trail
"""
signal trail_popped(prev_path)

var trail := []

"""
Navigates back one level in the breadcrumb trail.

Pops the front path off of the breadcrumb trail. Emits a signal and changes the current scene.
"""
func pop_trail() -> void:
	var prev_path: String
	if trail:
		prev_path = trail.pop_front()
	emit_signal("trail_popped", prev_path)
	if not "::" in prev_path:
		# '::' is used as a separator for breadcrumb items which do not result in a scene change
		_change_scene()


"""
Navigates forward one level, appending the new path to the breadcrumb trail.

Parameters:
	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
"""
func push_trail(path: String) -> void:
	trail.push_front(path)
	if not "::" in path:
		_change_scene()


"""
Changes the running scene to the one at the front of the breadcrumb trail.
"""
func _change_scene() -> void:
	if trail:
		get_tree().change_scene(trail.front())
