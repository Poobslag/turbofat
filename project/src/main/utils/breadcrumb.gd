extends Node
## List of paths representing the current scene and its ancestors, leading back to the main menu.
##
## This breadcrumb trail is used for navigation. It keeps track of which scene the player should go back to when they
## press the various 'Quit' buttons throughout the game.

## Emitted when the player goes back, popping the front item off of the breadcrumb trail
##
## Parameters:
## 	'prev_path': The path item which was just popped from the breadcrumb trail
signal trail_popped(prev_path)

## Emitted before this class changes the running scene.
signal before_scene_changed

var trail := []

## Initializes the trail to be empty except for the current scene.
##
## This is useful for demos and development where having an empty breadcrumb trail causes bugs. During regular play the
## breadcrumb trail should be initialized conventionally in the splash screen or menus.
func initialize_trail() -> void:
	trail = [get_tree().current_scene.filename]


## Navigates back one level in the breadcrumb trail.
##
## Pops the front path off of the breadcrumb trail. Emits a signal and changes the current scene.
func pop_trail() -> void:
	var prev_path: String
	if trail:
		prev_path = trail.pop_front()
	emit_signal("trail_popped", prev_path)
	if not "::" in prev_path:
		# '::' is used as a separator for breadcrumb items which do not result in a scene change
		change_scene_to_file()


## Navigates forward one level, appending the new path to the breadcrumb trail.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
func push_trail(path: String) -> void:
	trail.push_front(path)
	if not "::" in path:
		change_scene_to_file()


## Stays at the current level in the breadcrumb trail, but replaces the current navigation path.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
func replace_trail(path: String) -> void:
	trail.pop_front()
	trail.push_front(path)
	if not "::" in path:
		change_scene_to_file()


## Changes the running scene to the one at the front of the breadcrumb trail.
func change_scene_to_file() -> void:
	emit_signal("before_scene_changed")
	var scene_path: String
	if trail:
		scene_path = trail.front()
	else:
		# player popped the top item off the breadcrumb trail (possibly from something like a demo)
		# exit to loading screen and load all resources
		ResourceCache.minimal_resources = false
		scene_path = "res://src/main/ui/menu/LoadingScreen.tscn"
	get_tree().change_scene_to_packed(ResourceCache.get_resource(scene_path))
