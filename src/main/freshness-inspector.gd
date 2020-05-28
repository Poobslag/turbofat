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
var freshness_records: Dictionary 

func _ready() -> void:
	wait_time = CHUNK_SIZE * 0.4


func _on_MusicPlayer_bgm_changed(new_bgm: AudioStreamPlayer) -> void:
	_current_bgm = new_bgm
	_update_freshness()


func _on_timeout() -> void:
	_update_freshness()


"""
Updates the 'freshness record' of the song currently playing.
"""
func _update_freshness() -> void:
	if _current_bgm == null:
		return
	
	if not freshness_records.has(_current_bgm.name):
		freshness_records[_current_bgm.name] = []
		for _i in range(ceil(_current_bgm.stream.get_length() / CHUNK_SIZE)):
			freshness_records[_current_bgm.name].append(0)
	freshness_records[_current_bgm.name][int(_current_bgm.get_playback_position() / CHUNK_SIZE)] += 1


"""
Calculates the ideal position to start playing the specified song.

The algorithm we follow is to create a window with the left half of the 'freshness record'. We gradually advance it
through the entire song, and figure out which half of the song has been played the least. We return the position of
the song at the start of that half.
"""
func freshest_start(bgm: AudioStreamPlayer) -> float:
	if not freshness_records.has(bgm.name):
		return 0.0
	
	var freshness_record: Array = freshness_records[bgm.name]
	var freshest_start := 0
	var min_staleness: int = 0
	var staleness: int = 0
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
			freshest_start = (l + 1) % freshness_record.size()
	
	return freshest_start * CHUNK_SIZE
