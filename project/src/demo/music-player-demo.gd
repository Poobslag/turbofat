extends Node
"""
Demonstrates music player capability.

Shows a string with the 'staleness' of each music track. As sections of the music gets played, they get incremented.
When playing a music track, it skips to the least stale parts of the track.

Keys:
	C: Play chill song
	U: Play upbeat song
	=: Fade in the current song
	-: Fade out the current song
	]: Skip to next checkpoint in song
"""

func _ready() -> void:
	PlayerData.volume_settings.set_bus_volume_linear(VolumeSettings.MUSIC, 0.5)


func _input(event: InputEvent) -> void:
	match(Utils.key_scancode(event)):
		KEY_C: MusicPlayer.play_chill_bgm()
		KEY_EQUAL: MusicPlayer.fade_in()
		KEY_U: MusicPlayer.play_upbeat_bgm()
		KEY_MINUS: MusicPlayer.stop()
		KEY_BRACERIGHT: next_checkpoint()


func next_checkpoint() -> void:
	var freshness_inspector: FreshnessInspector = MusicPlayer.get_node("FreshnessInspector")
	var checkpoints: Array = freshness_inspector.get_checkpoints(MusicPlayer.current_bgm)
	var curr_playback_position := MusicPlayer.current_bgm.get_playback_position()
	var closest_checkpoint := 0.0
	for checkpoint in checkpoints:
		if checkpoint >= curr_playback_position:
			if closest_checkpoint < curr_playback_position \
					or (checkpoint - curr_playback_position < closest_checkpoint - curr_playback_position):
				closest_checkpoint = checkpoint
	MusicPlayer.current_bgm.seek(closest_checkpoint)


func _on_Timer_timeout() -> void:
	var freshness_inspector: FreshnessInspector = MusicPlayer.get_node("FreshnessInspector")
	$RichTextLabel.clear()
	for key in freshness_inspector.bgm_staleness.keys():
		$RichTextLabel.text += "%s %s\n" % [key, freshness_inspector.bgm_staleness.get(key)]
