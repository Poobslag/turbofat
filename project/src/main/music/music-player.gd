extends Node
## Plays music.
##
## Ensures only one music track is playing at once. Organizes music by category and fades music in and out.

signal current_bgm_changed(value)

## highest cutoff for the low-pass night filter; this should render the filter unnoticable
const MAX_FILTER_HZ := 20000.0

## lowest cutoff for the low-pass night filter; this should make the music sound muffled
const MIN_FILTER_HZ := 500.0

## volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

## volume to fade in to
const MAX_VOLUME := 0.0

var all_bgms: Array

## music currently playing
var current_bgm: CheckpointSong

## true if the music should have a low-pass filter applied; used during nighttime
var night_filter: bool = false setget set_night_filter

## volume_db changes when we fade in/fade out so we cache the original value.
##
## key: (String) bgm node name
## value: (float) desired volume_db for playing music
var _max_volume_db_by_bgm := {}

onready var _chill_bgms := [
		$ChubHub, $DessertCourse, $HarderButter,
		$HotFunkSundae, $LoFiChill, $RainbowSherbeat]

onready var _upbeat_bgms := [
		$AcidReflux, $ChocolateChip, $ChubNBass, $ChunkyObake,
		$DooDooDoo, $ExtraSprinkles, $GingerbreadHouse, $JuicerMixerGrinder,
		$MysticMuffin, $PressureCooker, $SugarCrash, $TripleThiccShake,
		]

onready var _tutorial_bgms := [$MyFatnessPal]
onready var _music_tween := $MusicTween
onready var _filter_tween: SceneTreeTween

func _ready() -> void:
	all_bgms = _chill_bgms + _upbeat_bgms + _tutorial_bgms
	_chill_bgms.shuffle()
	_upbeat_bgms.shuffle()
	
	for bgm in all_bgms:
		_max_volume_db_by_bgm[bgm.name] = bgm.volume_db


## Plays a 'chill' song; something suitable for background music when the player's navigating menus or wandering the
## free roam overworld.
##
## If a chill song is already playing, this method has no effect.
func play_chill_bgm(fade_in: bool = true) -> void:
	_play_next_bgm(_chill_bgms, fade_in)


## Plays an 'upbeat' song; something suitable when the player's playing a puzzle level.
##
## If an upbeat song is already playing, this method has no effect.
func play_upbeat_bgm(fade_in: bool = true) -> void:
	_play_next_bgm(_upbeat_bgms, fade_in)


## Plays a 'tutorial song'; something suitable when the player is following a puzzle tutorial.
##
## If a tutorial song is already playing, this method has no effect.
func play_tutorial_bgm(fade_in: bool = true) -> void:
	_play_next_bgm(_tutorial_bgms, fade_in)


## Gradually fades a track in.
##
## Usually it's OK for a track to start abrubtly, but sometimes we want to fade music in more gradually.
func fade_in(duration: float = MusicTween.FADE_IN_DURATION) -> void:
	current_bgm.volume_db = MIN_VOLUME
	_music_tween.fade_in(current_bgm, _max_volume_db_by_bgm[current_bgm.name], duration)


func is_fading_in() -> bool:
	return _music_tween.fading_state == MusicTween.FADING_IN


## Fades out the currently playing track.
func stop(duration: float = MusicTween.FADE_OUT_DURATION) -> void:
	if current_bgm == null:
		return
	
	_music_tween.fade_out(current_bgm, MIN_VOLUME, duration)
	current_bgm = null


## Plays the specified song.
##
## Any currently playing song is faded out.
##
## Parameters:
## 	'from_position': If 0 or greater, the song will begin playing from the specified position. If unspecified or
## 		negative, the song will start somewhere in the middle based on an algorithm.
func play_bgm(new_bgm: CheckpointSong, from_position: float = -1.0) -> void:
	var old_bgm := current_bgm
	if old_bgm == new_bgm:
		return
	
	if current_bgm:
		stop()
	current_bgm = new_bgm
	current_bgm.volume_db = _max_volume_db_by_bgm[current_bgm.name]
	current_bgm.play(from_position)
	emit_signal("current_bgm_changed", current_bgm)


## Enables or disables the low-pass filter used during nighttime.
func set_night_filter(new_night_filter: bool) -> void:
	if night_filter == new_night_filter:
		return
	night_filter = new_night_filter
	
	var bus_idx := AudioServer.get_bus_index("Music Bus")
	var effect_idx := 0
	var low_pass_filter: AudioEffectLowPassFilter = AudioServer.get_bus_effect(bus_idx, effect_idx)
	if new_night_filter:
		# Enable the low-pass filter, but increase its cutoff_hz to where it's unnoticable
		if not _filter_tween or not _filter_tween.is_running():
			low_pass_filter.cutoff_hz = MAX_FILTER_HZ
		AudioServer.set_bus_effect_enabled(bus_idx, effect_idx, true)
		
		# Gradually reduce the cutoff_hz to muffle the music
		_filter_tween = Utils.recreate_tween(self, _filter_tween)
		_filter_tween.tween_property(low_pass_filter, "cutoff_hz", MIN_FILTER_HZ, 0.3) \
				.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	else:
		# Gradually increase the cutoff_hz to unmuffle the music
		_filter_tween = Utils.recreate_tween(self, _filter_tween)
		_filter_tween.tween_property(low_pass_filter, "cutoff_hz", MAX_FILTER_HZ, 0.3) \
				.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		_filter_tween.tween_callback(self, "_on_Tween_unfilter_completed")


## Plays the first song from the specified list, and reorders the songs.
##
## If a song from the specified list is already playing, this method has no effect. Otherwise, any currently playing
## song is faded out.
##
## Parameters:
## 	'bgms': Array of CheckpointSong instances to play
##
## 	'fade_in': 'true' if the music should fade in
func _play_next_bgm(bgms: Array, fade_in: bool) -> void:
	if current_bgm in bgms:
		# a song from the specified list is already playing; don't interrupt it
		return
	
	var new_bgm: CheckpointSong = bgms.pop_front()
	bgms.append(new_bgm)
	play_bgm(new_bgm)
	if fade_in:
		fade_in()


## When the night audio filter finished unmuffling the audio, we disable the filter.
func _on_Tween_unfilter_completed() -> void:
	var bus_idx := AudioServer.get_bus_index("Music Bus")
	var effect_idx := 0
	AudioServer.set_bus_effect_enabled(bus_idx, effect_idx, false)
