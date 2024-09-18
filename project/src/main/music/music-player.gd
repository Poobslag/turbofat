extends Node
## Plays music.
##
## Ensures only one music track is playing at once. Organizes music by category and fades music in and out.

signal current_track_changed(value)

## highest cutoff for the low-pass night filter; this should render the filter unnoticable
const MAX_FILTER_HZ := 20000.0

## lowest cutoff for the low-pass night filter; this should make the music sound muffled
const MIN_FILTER_HZ := 500.0

## volume to fade out to; once the music reaches this volume, it's stopped
const MIN_VOLUME := -40.0

## volume to fade in to
const MAX_VOLUME := 0.0

var all_tracks: Array

## music currently playing
var current_track: CheckpointMusicTrack

## true if the music should have a low-pass filter applied; used during nighttime
var night_filter: bool = false setget set_night_filter

## key: (String) music track id
## value: (CheckpointMusicTrack) music
var tracks_by_id := {}

## volume_db changes when we fade in/fade out so we cache the original value.
##
## key: (String) track node name
## value: (float) desired volume_db for playing music
var _max_volume_db_by_track := {}

var _filter_tween: SceneTreeTween

## Level id for the newest played puzzle music. We monitor this to ensure repeating a puzzle also repeats the music.
var _previous_level_id: String

## Track id for the newest played puzzle music. We monitor this to ensure repeating a puzzle also repeats the music.
var _previous_puzzle_track_id: String

onready var _menu_tracks := [
		$ChubHub, $DessertCourse, $HarderButter,
		$HotFunkSundae, $LoFiChill, $RainbowSherbeat]

onready var _puzzle_tracks := [
		$AcidReflux, $ChocolateChip, $ChubNBass, $ChunkyObake,
		$DooDooDoo, $ExtraSprinkles, $GingerbreadHouse, $JuicerMixerGrinder,
		$MysticMuffin, $PressureCooker, $SugarCrash, $TripleThiccShake,
		]

onready var _credits_track := $SugarCrash
onready var _tutorial_tracks := [$MyFatnessPal]
onready var _music_tween_manager := $MusicTweenManager

func _ready() -> void:
	all_tracks = _menu_tracks + _puzzle_tracks + _tutorial_tracks
	for track in all_tracks:
		tracks_by_id[track.id] = track
	_menu_tracks.shuffle()
	_puzzle_tracks.shuffle()
	
	for track in all_tracks:
		_max_volume_db_by_track[track.name] = track.volume_db


func track_for_id(id: String) -> CheckpointMusicTrack:
	return tracks_by_id.get(id)


## Plays a menu track; something suitable for background music when the player's navigating menus.
##
## If a menu track is already playing, this method has no effect.
func play_menu_track(fade_in: bool = true) -> void:
	if PlayerData.menu_region and PlayerData.menu_region.music.menu_track_id:
		var new_track_id: String = PlayerData.menu_region.music.menu_track_id
		if current_track and current_track.id == new_track_id:
			# track is already playing; don't interrupt it
			pass
		else:
			var new_track: CheckpointMusicTrack = track_for_id(new_track_id)
			
			play_track(new_track)
			if fade_in:
				fade_in()
	else:
		_play_next_track(_menu_tracks, fade_in)


## Plays a puzzle track; something suitable when the player's playing a puzzle level.
##
## If an puzzle track is already playing, this method has no effect.
func play_puzzle_track(fade_in: bool = true) -> void:
	if PlayerData.menu_region and PlayerData.menu_region.music.puzzle_track_ids:
		var region_music: RegionMusic = PlayerData.menu_region.music
		
		var new_track_id: String
		
		if PlayerData.career.hours_passed == 0:
			# if it's the first level, play the 'main puzzle track'
			new_track_id = region_music.main_puzzle_track_id()
		elif CurrentLevel.boss_level:
			# if it's a boss level, play the 'main puzzle track'
			new_track_id = region_music.main_puzzle_track_id()
		elif _previous_level_id == CurrentLevel.level_id \
				and _previous_puzzle_track_id in region_music.puzzle_track_ids:
			# if replaying a level, play the same track
			new_track_id = _previous_puzzle_track_id
		else:
			# otherwise, play a random track
			new_track_id = region_music.random_puzzle_track_id()
		
		if current_track and current_track.id == new_track_id:
			# track is already playing; don't interrupt it
			pass
		else:
			play_track(track_for_id(new_track_id))
			if fade_in:
				fade_in()
		
		_previous_puzzle_track_id = new_track_id
		_previous_level_id = CurrentLevel.level_id
	else:
		_play_next_track(_puzzle_tracks, fade_in)


## Plays a 'tutorial track'; something suitable when the player is following a puzzle tutorial.
##
## If a tutorial track is already playing, this method has no effect.
func play_tutorial_track(fade_in: bool = true) -> void:
	_play_next_track(_tutorial_tracks, fade_in)


func play_credits_track() -> void:
	play_track(_credits_track, false)


## Gradually fades a track in.
##
## Usually it's OK for a track to start abrubtly, but sometimes we want to fade music in more gradually.
func fade_in(duration: float = MusicTweenManager.FADE_IN_DURATION) -> void:
	current_track.volume_db = MIN_VOLUME
	_music_tween_manager.fade_in(current_track, _max_volume_db_by_track[current_track.name], duration)


func is_fading_in() -> bool:
	return _music_tween_manager.fading_state == MusicTweenManager.FADING_IN


## Fades out the currently playing track.
func stop(duration: float = MusicTweenManager.FADE_OUT_DURATION) -> void:
	if current_track == null:
		return
	
	_music_tween_manager.fade_out(current_track, MIN_VOLUME, duration)
	current_track = null


## Plays the specified track.
##
## Any currently playing track is faded out.
##
## Parameters:
## 	'from_position': If 0 or greater, the track will begin playing from the specified position. If unspecified or
## 		negative, the track will start somewhere in the middle based on an algorithm.
func play_track(new_track: CheckpointMusicTrack, from_position: float = -1.0) -> void:
	var old_track := current_track
	if old_track == new_track:
		return
	
	if current_track:
		stop()
	current_track = new_track
	current_track.volume_db = _max_volume_db_by_track[current_track.name]
	current_track.play(from_position)
	emit_signal("current_track_changed", current_track)


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


## Plays the first track from the specified list, and reorders the tracks.
##
## If a track from the specified list is already playing, this method has no effect. Otherwise, any currently playing
## track is faded out.
##
## Parameters:
## 	'tracks': Array of CheckpointMusicTrack instances to play
##
## 	'fade_in': 'true' if the music should fade in
func _play_next_track(tracks: Array, fade_in: bool) -> void:
	if current_track in tracks:
		# a track from the specified list is already playing; don't interrupt it
		return
	
	var new_track: CheckpointMusicTrack = tracks.pop_front()
	tracks.append(new_track)
	play_track(new_track)
	if fade_in:
		fade_in()


## When the night audio filter finished unmuffling the audio, we disable the filter.
func _on_Tween_unfilter_completed() -> void:
	var bus_idx := AudioServer.get_bus_index("Music Bus")
	var effect_idx := 0
	AudioServer.set_bus_effect_enabled(bus_idx, effect_idx, false)
