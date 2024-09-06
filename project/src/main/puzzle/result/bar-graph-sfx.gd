extends Node
## Plays sound effects as the bar graph animates.

var _tween: SceneTreeTween

onready var _pop_sfx := $Pop

## Plays a sound effect which increases in pitch until the bar stops growing.
##
## Parameters:
## 	'duration': The duration in seconds that the sound should continuously play.
##
## 	'pitch_scale_start': The pitch scale that the sound should start at.
##
## 	'pitch_scale_end': The pitch scale that the sound should end at.
func play_bar_sound(duration: float, pitch_scale_start: float, pitch_scale_end: float) -> void:
	_tween = Utils.recreate_tween(self, _tween)
	_tween.tween_callback(_pop_sfx, "play")
	
	# gradually increase the sound's pitch
	_pop_sfx.pitch_scale = pitch_scale_start
	_tween.parallel().tween_property(_pop_sfx, "pitch_scale", pitch_scale_end, duration)
	
	# after the bar sound's duration, we decrease the volume to avoid popping before stopping the sound
	_pop_sfx.volume_db = -12
	_tween.tween_property(_pop_sfx, "volume_db", -40, 0.1)
	
	_tween.tween_callback(_pop_sfx, "stop")


## Stops any currently playing sounds.
func reset() -> void:
	_tween = Utils.kill_tween(_tween)
	_pop_sfx.stop()
