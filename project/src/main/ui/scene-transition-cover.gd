extends CanvasLayer
## Covers the screen during scene transitions.
##
## This must be a CanvasLayer and not simply a Control because it needs to cover everything, including other
## CanvasLayers.

onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var _mask: Node = $MaskHolder/Mask

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	SceneTransition.connect("fade_in_started", self, "_on_SceneTransition_fade_in_started")
	_initialize_fade()


## Launches the 'fade out' visual transition.
func fade_out() -> void:
	_mask.modulate = SceneTransition.fade_color
	_animation_player.play("fade-out", -1, 1.0 / SceneTransition.next_fade_out_duration)
	
	# play a random part of the scene transition sound effect so it's not as repetitive
	var max_audio_start := max(0.0, _audio_stream_player.stream.get_length() - SceneTransition.next_fade_out_duration)
	_audio_stream_player.play(rand_range(0.0, max_audio_start))


## Launches the 'fade in' visual transition.
func fade_in() -> void:
	_mask.modulate = SceneTransition.fade_color
	_animation_player.play("fade-in", -1, 1.0 / SceneTransition.SCREEN_FADE_IN_DURATION)
	
	# play a random part of the scene transition sound effect so it's not as repetitive
	var max_audio_start := max(0.0, _audio_stream_player.stream.get_length() - SceneTransition.SCREEN_FADE_IN_DURATION)
	_audio_stream_player.play(rand_range(0.0, max_audio_start))


## Makes our mask opaque or translucent based on the transition state. Also schedules the 'fade in' event if
## necessary.
func _initialize_fade() -> void:
	_mask.visible = false
	
	if SceneTransition.fading:
		_mask.visible = true
		_mask.modulate = SceneTransition.fade_color
		_mask.material.set_shader_param("invert", true)
		_mask.material.set_shader_param("cutoff", 0.0)

		# Schedule the 'fade in' event for later. It would be problematic to start fading in before other nodes have
		# had a chance to initialize. We use a one-shot listener method instead of a yield statement to avoid 'class
		# instance is gone' errors.
		if not get_tree().is_connected("idle_frame", self, "_finish_initializing_fade"):
			get_tree().connect("idle_frame", self, "_finish_initializing_fade")


func _finish_initializing_fade() -> void:
	if get_tree().is_connected("idle_frame", self, "_finish_initializing_fade"):
		get_tree().disconnect("idle_frame", self, "_finish_initializing_fade")

	SceneTransition.fade_in()


func _on_SceneTransition_fade_out_started() -> void:
	fade_out()


func _on_SceneTransition_fade_in_started() -> void:
	fade_in()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade-in":
			SceneTransition.end_fade_in()
		"fade-out":
			SceneTransition.end_fade_out()
		
