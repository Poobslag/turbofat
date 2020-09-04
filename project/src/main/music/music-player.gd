extends Node
"""
Plays music.

Ensures only one music track is playing at once. Organizes music by category and fades music in and out.
"""

# volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

# volume to fade in to
const MAX_VOLUME := 0.0

# the music currently playing
var current_bgm: CheckpointSong

# volume_db changes when we fade in/fade out so we cache the original value.
#
# key: bgm node name
# value: desired volume_db for playing music
var _max_volume_db_by_bgm := {}

# newest track(s) play twice as often
onready var _chill_bgms := [$HipHop03, $HipHop04, $HipHop08, $HipHop08]
onready var _upbeat_bgms := [$House01, $House04, $House06, $House08, $House10, $Breakbeat01, $Breakbeat01]
onready var _tutorial_bgms := [$Tutorial]
onready var all_bgms := _chill_bgms + _upbeat_bgms + _tutorial_bgms

func _ready() -> void:
	_chill_bgms.shuffle()
	_upbeat_bgms.shuffle()
	
	for bgm in all_bgms:
		_max_volume_db_by_bgm[bgm.name] = bgm.volume_db


"""
Plays a 'chill' song; something suitable for background music when the player's navigating menus or wandering the
overworld.
"""
func play_chill_bgm() -> void:
	play_music(_chill_bgms)


func is_playing_chill_bgm() -> bool:
	return current_bgm in _chill_bgms


"""
Plays an 'upbeat' song; something suitable when the player's playing a puzzle scenario.
"""
func play_upbeat_bgm() -> void:
	play_music(_upbeat_bgms)


"""
Plays a 'tutorial song'; something suitable when the player is following a puzzle tutorial.
"""
func play_tutorial_bgm() -> void:
	play_music(_tutorial_bgms)


"""
Gradually fades a track in.

Usually it's OK for a track to start abrubtly, but sometimes we want to fade music in more gradually.
"""
func fade_in() -> void:
	current_bgm.volume_db = MIN_VOLUME
	$MusicTween.fade_in(current_bgm, _max_volume_db_by_bgm[current_bgm.name])


"""
Fades out the currently playing track.
"""
func stop() -> void:
	if current_bgm == null:
		return
	
	$MusicTween.fade_out(current_bgm, MIN_VOLUME)
	current_bgm = null


"""
Plays the first song from the specified list, and reorders the songs.

Any currently playing song is abruptly stopped.
"""
func play_music(bgms: Array) -> void:
	var old_bgm := current_bgm
	current_bgm = bgms.pop_front()
	bgms.push_back(current_bgm)
	if current_bgm != old_bgm:
		if old_bgm:
			old_bgm.stop()
		current_bgm.volume_db = _max_volume_db_by_bgm[current_bgm.name]
		current_bgm.play()
