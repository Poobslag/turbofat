extends Tween
"""
Tweens the volumes of music tracks.
"""

const FADE_OUT_DURATION := 0.4
const FADE_IN_DURATION := 2.5


"""
Gradually silences a music track.
"""
func fade_out(player: AudioStreamPlayer) -> void:
	stop(player, "volume_db")
	remove(player, "volume_db")
	interpolate_property(player, "volume_db", player.volume_db, MusicPlayer.MIN_VOLUME, FADE_OUT_DURATION)
	start()


"""
Gradually raises a music track to full volume.
"""
func fade_in(player: AudioStreamPlayer) -> void:
	stop(player, "volume_db")
	remove(player, "volume_db")
	interpolate_property(player, "volume_db", player.volume_db, MusicPlayer.MAX_VOLUME, FADE_IN_DURATION)
	start()


"""
When a music track is faded out, we stop it from playing.
"""
func _on_tween_completed(object: Object, key: String) -> void:
	if object is AudioStreamPlayer:
		if object.volume_db == MusicPlayer.MIN_VOLUME:
			object.stop()
