extends Node
## Emits scene transition signals and keeps track of the currently active scene transition.

const SCREEN_FADE_OUT_DURATION := 1.2
const SCREEN_FADE_IN_DURATION := 0.6

## A scene transition emits these two signals in order as the screen fades out and fades back in
signal fade_out_started
signal fade_in_started

## Set to 'true' when the scene transition starts fading out, and 'false' when it finishes fading back in
var fading: bool

## The color to fade to during scene transitions.
var fade_color: Color = ProjectSettings.get_setting("rendering/environment/default_clear_color")

## The method and parameters to call on the Breadcrumb node after fading out.
var breadcrumb_method: FuncRef
var breadcrumb_arg_array: Array

## The duration of the next fade duration (or the current one, if already fading). These can be assigned for a slower
## or faster fadeout, but they will reset to their default values after the next fade.
var next_fade_in_duration := SCREEN_FADE_IN_DURATION
var next_fade_out_duration := SCREEN_FADE_OUT_DURATION

## Navigates forward one level, appending the new path to the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
##
## 	'skip_transition': If 'true', the scene changes immediately without fading.
func push_trail(path: String, skip_transition: bool = false) -> void:
	if skip_transition \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or "::" in path:
		# explicitly assign fading to false in case the scene changes while still fading in
		fading = false
		
		Breadcrumb.push_trail(path)
	else:
		fade_out(funcref(Breadcrumb, "push_trail"), [path])


## Navigates back one level in the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'skip_transition': If 'true', the scene changes immediately without fading.
func pop_trail(skip_transition: bool = false) -> void:
	if skip_transition \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or (Breadcrumb.trail and "::" in Breadcrumb.trail.front()):
		# explicitly assign fading to false in case the scene changes while still fading in
		fading = false
		
		Breadcrumb.pop_trail()
	else:
		fade_out(funcref(Breadcrumb, "pop_trail"))


## Stays at the current level in the breadcrumb trail, but replaces the current navigation path after a scene
## transition.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
##
## 	'skip_transition': If 'true', the scene changes immediately without fading.
func replace_trail(path: String, skip_transition: bool = false) -> void:
	if skip_transition \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or "::" in path:
		# explicitly assign fading to false in case the scene changes while still fading in
		fading = false
		
		Breadcrumb.replace_trail(path)
	else:
		fade_out(funcref(Breadcrumb, "replace_trail"), [path])


## Changes the running scene to the one at the front of the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'skip_transition': If 'true', the scene changes immediately without fading.
func change_scene(skip_transition: bool = false) -> void:
	if skip_transition or not get_tree().get_nodes_in_group("scene_transition_covers"):
		# explicitly assign fading to false in case the user clicks a button while still fading in
		fading = false
		
		Breadcrumb.change_scene()
	else:
		fade_out(funcref(Breadcrumb, "change_scene"), [])


## Called when the 'fade out' visual transition ends, triggering a scene transition.
func end_fade_out() -> void:
	next_fade_out_duration = SCREEN_FADE_OUT_DURATION
	if breadcrumb_method:
		breadcrumb_method.call_funcv(breadcrumb_arg_array)


## Launches the 'fade in' visual transition.
func fade_in() -> void:
	# unignore input immediately; don't wait for fade in to finish
	get_tree().get_root().set_disable_input(false)
	
	emit_signal("fade_in_started")


## Called when the 'fade in' visual transition ends, toggling a state variable.
func end_fade_in() -> void:
	next_fade_out_duration = SCREEN_FADE_IN_DURATION
	fading = false


## Launches the 'fade out' visual transition.
func fade_out(new_breadcrumb_method: FuncRef = null, new_breadcrumb_arg_array: Array = []) -> void:
	# ignore input to prevent edge-cases where player does weird things during scene transitions
	get_tree().get_root().set_disable_input(true)
	
	breadcrumb_method = new_breadcrumb_method
	breadcrumb_arg_array = new_breadcrumb_arg_array
	fading = true
	emit_signal("fade_out_started")
