extends Node
"""
Emits scene transition signals and keeps track of the currently active scene transition.
"""

const SCREEN_FADE_OUT_DURATION := 0.3
const SCREEN_FADE_IN_DURATION := 0.6

# A scene transition emits these four signals in order as the screen fades out and fades back in
signal fade_out_started
signal fade_out_ended
signal fade_in_started
signal fade_in_ended

# Set to 'true' when the scene transition starts fading out, and 'false' when it finishes fading back in
var fading: bool

func start_fade_out() -> void:
	fading = true
	emit_signal("fade_out_started")


func end_fade_out() -> void:
	emit_signal("fade_out_ended")


func start_fade_in() -> void:
	emit_signal("fade_in_started")


func end_fade_in() -> void:
	fading = false
	emit_signal("fade_in_ended")
