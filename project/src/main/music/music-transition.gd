extends Node
## Transitions the music for web targets when the scene fades in and out.
##
## On web targets, the music sounds choppy and bad if we leave it running during scene transitions, so we fade out the
## music. On other targets, the music sounds fine.

var _faded_bgm: CheckpointSong

func _ready() -> void:
	SceneTransition.connect("fade_out_started", self, "_on_SceneTransition_fade_out_started")
	SceneTransition.connect("fade_in_started", self, "_on_SceneTransition_fade_in_started")


## When the scene fades back in, we un-fade any music we previously faded out.
func _on_SceneTransition_fade_in_started(_duration: float) -> void:
	if _faded_bgm:
		# If we faded the music out, we fade it back in
		MusicPlayer.play_bgm(_faded_bgm, _faded_bgm.get_playback_position())
		MusicPlayer.fade_in(SceneTransition.DEFAULT_FADE_IN_DURATION * 1.5)
		
		# reset _faded_bgm to avoid fading the same song in twice
		_faded_bgm = null


## When fading out the scene, we fade out the music for web targets.
##
## On web targets, the music sounds choppy and bad if we leave it running during scene transitions.
func _on_SceneTransition_fade_out_started(duration: float) -> void:
	if OS.has_feature("web"):
		_faded_bgm = MusicPlayer.current_bgm
		MusicPlayer.stop(duration * 0.5)
