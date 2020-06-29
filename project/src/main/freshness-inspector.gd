class_name FreshnessInspector
extends Timer
"""
Measures the 'freshness' of different parts of a music track.

If every song always played from 0:00.000, players would get sick of the beginning of a song and never hear the end.
This class keeps track of which parts of each song have been played the most, so the MusicPlayer can skip ahead to the
parts the player hasn't heard as often.
"""

# we measure which 'chunks' of music have been played the least, this defines the chunk size
const CHUNK_SIZE := 6.0

# the music currently playing
var _current_bgm: AudioStreamPlayer

# key: bgm node name
# value: array of ints corresponding to how much each 'chunk' of music has been played
var bgm_staleness: Dictionary

# key: bgm node name
# value: array of floats corresponding to good start positions in each song
var bgm_checkpoints: Dictionary

# key: bgm node name
# value: 'true' if the BGM node has been played
var bgm_played: Dictionary

func _ready() -> void:
	wait_time = CHUNK_SIZE * 0.4


func add_checkpoint(bgm: AudioStreamPlayer, start: float) -> void:
	if not bgm_checkpoints.has(bgm.name):
		bgm_checkpoints[bgm.name] = []
	bgm_checkpoints[bgm.name].append(start)


func get_nearest_checkpoint(bgm: AudioStreamPlayer, start: float) -> float:
	var checkpoints: Array = get_checkpoints(bgm)
	var checkpoint_index: int = Utils.find_closest(checkpoints, start)
	var result := start
	if checkpoint_index != -1:
		result = checkpoints[checkpoint_index]
	return result


func get_checkpoints(bgm: AudioStreamPlayer) -> Array:
	return bgm_checkpoints.get(bgm.name, [])


"""
Updates the 'freshness record' of the song currently playing.
"""
func _update_staleness() -> void:
	if _current_bgm == null:
		return
	
	if not bgm_staleness.has(_current_bgm.name):
		_init_staleness(_current_bgm)
	
	bgm_played[_current_bgm.name] = true
	bgm_staleness[_current_bgm.name][int(_current_bgm.get_playback_position() / CHUNK_SIZE)] += 1


func _init_staleness(bgm: AudioStreamPlayer) -> void:
	bgm_staleness[bgm.name] = []
	for _i in range(ceil(bgm.stream.get_length() / CHUNK_SIZE)):
		bgm_staleness[bgm.name].append(randi() % 3)


"""
Calculates the ideal position to start playing the specified song.

The algorithm we follow is to create a window with the left half of the 'freshness record'. We gradually advance it
through the entire song, and figure out which half of the song has been played the least. We return the position of
the song at the start of that half.
"""
func freshest_start(bgm: AudioStreamPlayer) -> float:
	if not bgm_staleness.has(bgm.name):
		_init_staleness(bgm)
	
	var freshness_record: Array = bgm_staleness[bgm.name]
	var freshest_start_index := 0
	var min_staleness: int = 0
	var staleness: int = 0
	# warning-ignore:integer_division
	var r: int = freshness_record.size() / 2
	for l in range(0, freshness_record.size()):
		# advance the 'freshness window'
		r = (r + 1) % freshness_record.size()
		
		# recalculate the relative staleness of the current window
		staleness -= freshness_record[l]
		staleness += freshness_record[r]
		
		if staleness < min_staleness:
			# this is the freshest window; store the freshness and the window position
			min_staleness = staleness
			freshest_start_index = (l + 1) % freshness_record.size()
	
	var start := freshest_start_index * CHUNK_SIZE
	if not bgm_played.has(bgm.name):
		# the first time playing a particular song, we start at a checkpoint. this way the player doesn't boot up the
		# game by hearing a musical solo or bridge without context. after the first time, anywhere is OK.
		start = get_nearest_checkpoint(bgm, freshest_start_index)
	return start


func _on_MusicPlayer_bgm_changed(new_bgm: AudioStreamPlayer) -> void:
	_current_bgm = new_bgm
	_update_staleness()


func _on_timeout() -> void:
	_update_staleness()
