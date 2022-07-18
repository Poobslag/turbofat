extends Node
## Plays music.
##
## Ensures only one music track is playing at once. Organizes music by category and fades music in and out.

signal current_bgm_changed(value)

## volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

## volume to fade in to
const MAX_VOLUME := 0.0

## the music currently playing
var current_bgm: CheckpointSong

## volume_db changes when we fade in/fade out so we cache the original value.
##
## key: (String) bgm node name
## value: (float) desired volume_db for playing music
var _max_volume_db_by_bgm := {}

var all_bgms: Array

onready var _chill_bgms := [
		$ChubHub, $DessertCourse, $HarderButter,
		$HotFunkSundae, $LoFiChill, $RainbowSherbeat]

onready var _upbeat_bgms := [
		$ChubNBass, $ChunkyObake, $DooDooDoo, $JuicerMixerGrinder,
		$MysticMuffin, $PressureCooker, $SugarCrash, $TripleThiccShake,
		$AcidReflux, $ExtraSprinkles, $ChocolateChip, $GingerbreadHouse]

onready var _tutorial_bgms := [$MyFatnessPal]
onready var _music_tween := $MusicTween

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
	bgms.push_back(new_bgm)
	play_bgm(new_bgm)
	if fade_in:
		fade_in()
