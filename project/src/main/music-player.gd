extends Node
"""
Plays music.

Ensures only one music track is playing at once. Tries to skip ahead to the parts of the music the player hasn't heard
recently.
"""

# emitted when the currently playing music changes
signal bgm_changed(new_bgm)

# volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

# volume to fade in to
const MAX_VOLUME := 0.0

# the music currently playing
var current_bgm: AudioStreamPlayer

# newest track(s) play twice as often
onready var _chill_bgms := [$HipHop03, $HipHop04, $HipHop04]
onready var _upbeat_bgms := [$House01, $House04, $House06, $House08, $House08]

func _ready() -> void:
	_chill_bgms.shuffle()
	_upbeat_bgms.shuffle()
	
	$FreshnessInspector.add_checkpoint($HipHop03, 0.000)
	$FreshnessInspector.add_checkpoint($HipHop03, 12.489)
	$FreshnessInspector.add_checkpoint($HipHop03, 32.489)
	$FreshnessInspector.add_checkpoint($HipHop03, 42.489)
	$FreshnessInspector.add_checkpoint($HipHop03, 142.489)
	$FreshnessInspector.add_checkpoint($HipHop03, 152.489)
	$FreshnessInspector.add_checkpoint($HipHop03, 162.489)
	
	$FreshnessInspector.add_checkpoint($HipHop04, 0.000)
	$FreshnessInspector.add_checkpoint($HipHop04, 10.646)
	$FreshnessInspector.add_checkpoint($HipHop04, 21.326)
	$FreshnessInspector.add_checkpoint($HipHop04, 63.988)
	$FreshnessInspector.add_checkpoint($HipHop04, 85.330)
	$FreshnessInspector.add_checkpoint($HipHop04, 213.328)
	
	$FreshnessInspector.add_checkpoint($House01, 0.000)
	$FreshnessInspector.add_checkpoint($House01, 7.747)
	$FreshnessInspector.add_checkpoint($House01, 23.229)
	$FreshnessInspector.add_checkpoint($House01, 38.696)
	
	$FreshnessInspector.add_checkpoint($House04, 0.000)
	$FreshnessInspector.add_checkpoint($House04, 15.233)
	$FreshnessInspector.add_checkpoint($House04, 45.721)
	$FreshnessInspector.add_checkpoint($House04, 76.196)
	$FreshnessInspector.add_checkpoint($House04, 106.670)
	$FreshnessInspector.add_checkpoint($House04, 167.613)
	
	$FreshnessInspector.add_checkpoint($House06, 0.000)
	$FreshnessInspector.add_checkpoint($House06, 15.230)
	$FreshnessInspector.add_checkpoint($House06, 30.474)
	
	$FreshnessInspector.add_checkpoint($House08, 0.000)
	$FreshnessInspector.add_checkpoint($House08, 1.951)
	$FreshnessInspector.add_checkpoint($House08, 204.877)


"""
Plays a 'chill' song; something suitable for background music when the player's navigating menus or wandering the
overworld.
"""
func play_chill_bgm() -> void:
	var chill_bgm: AudioStreamPlayer = _chill_bgms.pop_front()
	play_music(chill_bgm, $FreshnessInspector.freshest_start(chill_bgm))
	_chill_bgms.push_back(chill_bgm)


func is_playing_chill_bgm() -> bool:
	return current_bgm in _chill_bgms


"""
Plays an 'upbeat' song; something suitable when the player's playing a puzzle scenario.
"""
func play_upbeat_bgm() -> void:
	var upbeat_bgm: AudioStreamPlayer = _upbeat_bgms.pop_front()
	play_music(upbeat_bgm, $FreshnessInspector.freshest_start(upbeat_bgm))
	_upbeat_bgms.push_back(upbeat_bgm)


"""
Gradually fades a track in.

Usually it's OK for a track to start abrubtly, but sometimes we want to fade music in more gradually.
"""
func fade_in() -> void:
	current_bgm.volume_db = -40.0
	$MusicTween.fade_in(current_bgm)


"""
Abruptly stops the currently playing track.
"""
func stop() -> void:
	if current_bgm == null:
		return
	
	$MusicTween.fade_out(current_bgm)
	current_bgm = null
	emit_signal("bgm_changed", current_bgm)


"""
Plays a new track.

The currently track is abruptly stopped.
"""
func play_music(new_bgm: AudioStreamPlayer, from_position: float = 0.0) -> void:
	if current_bgm == new_bgm:
		return
	
	stop()
	current_bgm = new_bgm
	current_bgm.volume_db = 0.0
	current_bgm.play(from_position)
	emit_signal("bgm_changed", current_bgm)
