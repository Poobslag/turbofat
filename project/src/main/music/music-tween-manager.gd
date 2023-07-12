class_name MusicTweenManager
extends Node
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

## Enum from FadingState representing whether the music is fading in or out
var fading_state: int = FADING_NONE

## key: (AudioStreamPlayer) song
## value: (SceneTreeTween) tween adjusting volume
var _tweens_by_song: Dictionary = {}

## Gradually silences a music track.
func fade_out(player: AudioStreamPlayer, min_volume: float, duration: float = FADE_OUT_DURATION) -> void:
	fading_state = FADING_OUT
	_fade(player, min_volume, duration)


## Gradually raises a music track to full volume.
func fade_in(player: AudioStreamPlayer, max_volume: float, duration: float = FADE_IN_DURATION) -> void:
	fading_state = FADING_IN
	_fade(player, max_volume, duration)


## Gradually adjusts a music track's volume.
func _fade(player: AudioStreamPlayer, new_volume_db: float, duration: float) -> void:
	if _tweens_by_song.has(player):
		_tweens_by_song[player].kill()
	_tweens_by_song[player] = create_tween()
	var fade_tween: SceneTreeTween = _tweens_by_song[player]
	fade_tween.tween_property(player, "volume_db", new_volume_db, duration)
	fade_tween.tween_callback(self, "_on_Tween_completed", [player])


## When a music track is faded out, we stop it from playing.
func _on_Tween_completed(player: AudioStreamPlayer) -> void:
	fading_state = FADING_NONE
	if is_equal_approx(player.volume_db, MusicPlayer.MIN_VOLUME):
		player.stop()
