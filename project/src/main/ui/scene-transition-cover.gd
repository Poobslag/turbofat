extends CanvasLayer
## Covers the screen during scene transitions.
##
## This must be a CanvasLayer and not simply a Control because it needs to cover everything, including other
## CanvasLayers.

onready var _tween: Tween = $Tween
onready var _color_rect: ColorRect = $ColorRect

func _ready() -> void:
	_tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	SceneTransition.connect("fade_in_started", self, "_on_SceneTransition_fade_in_started")
	
	_refresh_rect_size()
	_initialize_fade()


## Makes our alpha component opaque or translucent based on the transition state. Also schedules the 'fade in' event if
## necessary.
func _initialize_fade() -> void:
	_color_rect.modulate.a = 1.0 if SceneTransition.fading else 0.0
	if SceneTransition.fading:
		_color_rect.color = SceneTransition.fade_color
		# Schedule the 'fade in' event for later. It would be problematic to start fading in before other nodes have
		# had a chance to initialize.
		yield(get_tree(), "idle_frame")
		SceneTransition.fade_in()


## Starts a tween which changes this node's opacity.
func _launch_fade_tween(new_alpha: float, duration: float) -> void:
	_color_rect.color = SceneTransition.fade_color
	
	_tween.remove_all()
	_tween.interpolate_property(_color_rect, "modulate", _color_rect.modulate,
			Utils.to_transparent(_color_rect.modulate, new_alpha), duration)
	_tween.start()


func _refresh_rect_size() -> void:
	_color_rect.rect_size = _color_rect.get_viewport_rect().size


func _on_SceneTransition_fade_out_started() -> void:
	_launch_fade_tween(1.0, SceneTransition.SCREEN_FADE_OUT_DURATION)


func _on_SceneTransition_fade_in_started() -> void:
	_launch_fade_tween(0.0, SceneTransition.SCREEN_FADE_IN_DURATION)


func _on_Tween_tween_all_completed() -> void:
	if _color_rect.modulate.a == 1.0:
		SceneTransition.end_fade_out()
	elif _color_rect.modulate.a == 0.0:
		SceneTransition.end_fade_in()
	else:
		push_warning("Unexpected SceneTransitionCover.ColorRect.modulate.a: %s" % [_color_rect.modulate.a])
