extends ColorRect
"""
Covers the screen during scene transitions.
"""

func _ready() -> void:
	$Tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	SceneTransition.connect("fade_in_started", self, "_on_SceneTransition_fade_in_started")
	
	_initialize_fade()


"""
Makes our alpha component opaque or translucent based on the transition state. Also schedules the 'fade in' event if
necessary.
"""
func _initialize_fade() -> void:
	modulate.a = 1.0 if SceneTransition.fading else 0.0
	if SceneTransition.fading:
		# Schedule the 'fade in' event for later. It would be problematic to start fading in before other nodes have
		# had a chance to initialize.
		yield(get_tree(), "idle_frame")
		SceneTransition.start_fade_in()


"""
Starts a tween which changes this node's opacity.
"""
func _launch_fade_tween(new_alpha: float, duration: float) -> void:
	$Tween.remove_all()
	$Tween.interpolate_property(self, "modulate", modulate, Utils.to_transparent(modulate, new_alpha), duration)
	$Tween.start()


func _on_SceneTransition_fade_out_started() -> void:
	_launch_fade_tween(1.0, SceneTransition.SCREEN_FADE_OUT_DURATION)


func _on_SceneTransition_fade_in_started() -> void:
	_launch_fade_tween(0.0, SceneTransition.SCREEN_FADE_IN_DURATION)


func _on_Tween_tween_all_completed() -> void:
	if modulate.a == 1.0:
		SceneTransition.end_fade_out()
	elif modulate.a == 0.0:
		SceneTransition.end_fade_in()
	else:
		push_warning("Unexpected SceneTransitionRect.modulate.a: %s" % [modulate.a])
