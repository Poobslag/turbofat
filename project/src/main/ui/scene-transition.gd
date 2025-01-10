extends CanvasLayer
## Plays scene transition animations.

## Scene transition emits these two signals in order as the screen fades out and fades back in
signal fade_in_started(duration)
signal fade_out_started(duration)

enum TransitionType {
	DEFAULT,
	PUZZLE,
	NONE,
}

const DEFAULT_FADE_IN_DURATION := 0.6
const DEFAULT_FADE_OUT_DURATION := 1.2

## (TransitionType) animation to play. Defaults to a puzzle piece animation
const FLAG_TYPE := "transition-type"

## (float) duration in seconds of the fade in animation. Defaults to DEFAULT_FADE_IN_DURATION
const FLAG_FADE_IN_DURATION := "fade-in-duration"

## (float) duration in seconds of the fade out animation. Defaults to DEFAULT_FADE_OUT_DURATION
const FLAG_FADE_OUT_DURATION := "fade-out-duration"

const TYPE_DEFAULT := TransitionType.DEFAULT
const TYPE_PUZZLE := TransitionType.PUZZLE
const TYPE_NONE := TransitionType.NONE

## Color to fade to during scene transitions.
var fade_color: Color = ProjectSettings.get_setting("rendering/environment/default_clear_color")

## Scheduled breadcrumb method to invoke from the main thread.
##
## Triggering a scene change from a signal handler sometimes causes a silent crash, with no errors or logs.
## We defer the scene change to the main thread to avoid conflicts with signal handling. See Godot #85692
## (https://github.com/godotengine/godot/issues/85692).
var _deferred_breadcrumb_method: FuncRef
var _deferred_breadcrumb_arg_array: Array

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var _mask: Node = $MaskHolder/Mask

func _physics_process(_delta: float) -> void:
	if _deferred_breadcrumb_method:
		Global.print_verbose("Calling breadcrumb method: %s, %s" \
				% [_deferred_breadcrumb_method, _deferred_breadcrumb_arg_array])
		_deferred_breadcrumb_method.call_funcv(_deferred_breadcrumb_arg_array)
		
		_deferred_breadcrumb_method = null
		_deferred_breadcrumb_arg_array = []


## Navigates forward one level, appending the new path to the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
##
## 	'flags': Flags which affect the scene transition's duration and appearance
func push_trail(path: String, flags: Dictionary = {}) -> void:
	if not is_inside_tree():
		return
	if flags.get(FLAG_TYPE) == TransitionType.NONE \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or "::" in path:
		Breadcrumb.push_trail(path)
	else:
		fade_out(flags, funcref(Breadcrumb, "push_trail"), [path])


## Stays at the current level in the breadcrumb trail, but replaces the current navigation path after a scene
## transition.
##
## Parameters:
## 	'path': The path to append to the breadcrumb trail. This is usually a scene path such as 'res://MyScene.tscn', but
## 		it can also include a '::foo' suffix for navigation paths which do not result in a scene change.
##
## 	'flags': Flags which affect the scene transition's duration and appearance
func replace_trail(path: String, flags: Dictionary = {}) -> void:
	if not is_inside_tree():
		return
	if flags.get(FLAG_TYPE) == TransitionType.NONE \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or "::" in path:
		Breadcrumb.replace_trail(path)
	else:
		fade_out(flags, funcref(Breadcrumb, "replace_trail"), [path])


## Changes the running scene to the one at the front of the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'flags': Flags which affect the scene transition's duration and appearance
func change_scene(flags: Dictionary = {}) -> void:
	if not is_inside_tree():
		return
	if flags.get(FLAG_TYPE) == TransitionType.NONE \
			or not get_tree().get_nodes_in_group("scene_transition_covers"):
		Breadcrumb.change_scene()
	else:
		fade_out(flags, funcref(Breadcrumb, "change_scene"), [])


## Navigates back one level in the breadcrumb trail after a scene transition.
##
## Parameters:
## 	'flags': Flags which affect the scene transition's duration and appearance
func pop_trail(flags: Dictionary = {}) -> void:
	if not is_inside_tree():
		return
	if flags.get(FLAG_TYPE) == TransitionType.NONE \
			or not get_tree().get_nodes_in_group("scene_transition_covers") \
			or (Breadcrumb.trail and "::" in Breadcrumb.trail.front()):
		Breadcrumb.pop_trail()
	else:
		fade_out(flags, funcref(Breadcrumb, "pop_trail"))


## Launches the 'fade in' visual transition.
func fade_in(flags: Dictionary = {}) -> void:
	if not is_inside_tree():
		return
	Global.print_verbose("Launching scene transition fade in effect")
	# unignore input immediately; don't wait for fade in to finish
	get_tree().get_root().set_disable_input(false)
	
	_mask.modulate = fade_color
	_animation_player.play("fade-in", -1, 1.0 / _fade_in_duration(flags))
	
	# play a random part of the scene transition sound effect so it's not as repetitive
	var max_audio_start := max(0.0, _audio_stream_player.stream.get_length() - _fade_out_duration(flags))
	_audio_stream_player.play(rand_range(0.0, max_audio_start))
	
	emit_signal("fade_in_started", _fade_in_duration(flags))
	Global.print_verbose("Finished launching scene transition fade in effect")


## Launches the 'fade out' visual transition.
func fade_out(flags: Dictionary = {}, breadcrumb_method: FuncRef = null, breadcrumb_arg_array: Array = []) -> void:
	if not is_inside_tree():
		return
	Global.print_verbose("Launching scene transition fade out effect")
	# ignore input to prevent edge-cases where player does weird things during scene transitions
	get_tree().get_root().set_disable_input(true)
	
	_mask.modulate = fade_color
	_animation_player.play("fade-out", -1, 1.0 / _fade_out_duration(flags))
	
	# play a random part of the scene transition sound effect so it's not as repetitive
	var max_audio_start := max(0.0, _audio_stream_player.stream.get_length() - _fade_out_duration(flags))
	_audio_stream_player.play(rand_range(0.0, max_audio_start))
	
	if _animation_player.is_connected(
			"animation_finished", self, "_on_AnimationPlayer_animation_finished_change_scene"):
		_animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished_change_scene")

	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished_change_scene", \
			[flags, breadcrumb_method, breadcrumb_arg_array])
	emit_signal("fade_out_started", _fade_out_duration(flags))
	Global.print_verbose("Finished launching scene transition fade out effect")


func _fade_out_duration(flags: Dictionary) -> float:
	return flags.get(FLAG_FADE_OUT_DURATION, DEFAULT_FADE_OUT_DURATION)


func _fade_in_duration(flags: Dictionary) -> float:
	return flags.get(FLAG_FADE_IN_DURATION, DEFAULT_FADE_IN_DURATION)


## Called when the 'fade out' visual transition ends, triggering a scene transition.
func _on_AnimationPlayer_animation_finished_change_scene(
		_animation_name: String, flags: Dictionary = {}, breadcrumb_method: FuncRef = null,
		breadcrumb_arg_array: Array = []) -> void:
	Global.print_verbose("Animation finished; disconnecting listeners")
	if _animation_player.is_connected(
			"animation_finished", self, "_on_AnimationPlayer_animation_finished_change_scene"):
		_animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished_change_scene")
	
	if breadcrumb_method:
		Global.print_verbose("Scheduling breadcrumb method: %s, %s" \
				% [breadcrumb_method.function, breadcrumb_arg_array])
		_deferred_breadcrumb_method = breadcrumb_method
		_deferred_breadcrumb_arg_array = breadcrumb_arg_array
	else:
		Global.print_verbose("No breadcrumb method: %s, %s" \
				% [breadcrumb_method, breadcrumb_arg_array])
	
	call_deferred("fade_in", flags)
