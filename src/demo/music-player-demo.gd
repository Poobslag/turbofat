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
"""

func _input(event: InputEvent) -> void:
	match(Global.key_scancode(event)):
		KEY_C: MusicPlayer.play_chill_bgm()
		KEY_EQUAL: MusicPlayer.fade_in()
		KEY_U: MusicPlayer.play_upbeat_bgm()
		KEY_MINUS: MusicPlayer.stop()


func _on_Timer_timeout() -> void:
	var freshness_inspector: FreshnessInspector = MusicPlayer.get_node("FreshnessInspector")
	$RichTextLabel.clear()
	for key in freshness_inspector.freshness_records.keys():
		$RichTextLabel.text += "%s %s\n" % [key, freshness_inspector.freshness_records.get(key)]
