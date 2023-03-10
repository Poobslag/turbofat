class_name MusicTween
extends Tween
## Tweens the volumes of music tracks.

enum FadingState {
	FADING_NONE,
	FADING_IN,
	FADING_OUT,
}

const FADING_NONE := FadingState.FADING_NONE
const FADING_IN := FadingState.FADING_IN
const FADING_OUT := FadingState.FADING_OUT

const FADE_OUT_DURATION := 0.4
const FADE_IN_DURATION := 2.5

## An enum from FadingState representing whether the music is fading in or out
var fading_state: int = FADING_NONE

## Gradually silences a music track.
func fade_out(player: AudioStreamPlayer, min_volume: float, duration: float = FADE_OUT_DURATION) -> void:
	fading_state = FADING_OUT
	stop(player, "volume_db")
	remove(player, "volume_db")
	interpolate_property(player, "volume_db", null, min_volume, duration)
	start()


## Gradually raises a music track to full volume.
func fade_in(player: AudioStreamPlayer, max_volume: float, duration: float = FADE_IN_DURATION) -> void:
	fading_state = FADING_IN
	stop(player, "volume_db")
	remove(player, "volume_db")
	interpolate_property(player, "volume_db", null, max_volume, duration)
	start()


## When a music track is faded out, we stop it from playing.
func _on_tween_completed(object: Object, _key: String) -> void:
	fading_state = FADING_NONE
	if object is AudioStreamPlayer:
		if object.volume_db == MusicPlayer.MIN_VOLUME:
			object.stop()
