extends Node
## Demonstrates music player capability.
##
## Shows a string with the 'staleness' of each music track. As sections of the music gets played, they get incremented.
## When playing a music track, it skips to the least stale parts of the track.
##
## Keys:
## 	[1]: Play menu music track
## 	[2]: Play puzzle music track
## 	[3]: Play tutorial music track
##
## 	[N]: Toggle night filter
##
## 	[-]: Fade out the current music track
## 	[=]: Fade in the current music track
## 	Right brace: Skip to next checkpoint in music track

func _ready() -> void:
	SystemData.volume_settings.set_bus_volume_linear(VolumeSettings.MUSIC, 0.5)


func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_1: MusicPlayer.play_menu_track(false)
		KEY_2: MusicPlayer.play_puzzle_track(false)
		KEY_3: MusicPlayer.play_tutorial_track(false)
		KEY_N: MusicPlayer.night_filter = not MusicPlayer.night_filter
		KEY_MINUS: MusicPlayer.stop()
		KEY_EQUAL:
			if not MusicPlayer.current_track:
				MusicPlayer.play_menu_track()
			MusicPlayer.fade_in()
		KEY_BRACKETRIGHT: next_checkpoint()


func next_checkpoint() -> void:
	if not MusicPlayer.current_track:
		return
	
	var checkpoints: Array = MusicPlayer.current_track.checkpoints
	var curr_playback_position := MusicPlayer.current_track.get_playback_position()
	var closest_checkpoint := 0.0
	for checkpoint in checkpoints:
		if checkpoint >= curr_playback_position:
			if closest_checkpoint < curr_playback_position \
					or (checkpoint - curr_playback_position < closest_checkpoint - curr_playback_position):
				closest_checkpoint = checkpoint
	MusicPlayer.current_track.seek(closest_checkpoint)


func _on_Timer_timeout() -> void:
	$RichTextLabel.clear()
	for track in MusicPlayer.all_tracks:
		$RichTextLabel.text += "%s %s\n" % [track.name, track._staleness_record]
