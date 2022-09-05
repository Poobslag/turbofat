class_name CheckpointSong
extends AudioStreamPlayer
## Plays a music track from different checkpoints to avoid playing the beginning of the song too much.
##
## If looped songs always played from the start, players would hear the beginning more than the ending. This class
## tracks which parts of the song have been played so the MusicPlayer can skip to the parts which have been played the
## least.

## we measure which 'chunks' of music have been _played the least, this defines the chunk size
const CHUNK_SIZE := 6.0

## array of floats corresponding to good start positions in each song
export (Array, float) var checkpoints: Array = []

## the song title and color shown in the toaster popup
export var song_title: String
export var song_color: Color

## array of ints corresponding to how much each 'chunk' of music has been _played
var _staleness_record: Array

## 'true' if the BGM node has been _played
var _played: bool

func _ready() -> void:
	$StalenessTimer.wait_time = CHUNK_SIZE * 0.4
	for _i in range(ceil(stream.get_length() / CHUNK_SIZE)):
		_staleness_record.append(randi() % 3)
	if not checkpoints:
		push_warning("CheckpointSong %s checkpoints=%s" % [name, checkpoints])


## Plays this song from the specified position, or somewhere in the middle.
##
## Parameters:
## 	'from_position': If 0 or greater, the song will begin playing from the specified position. If unspecified or
## 		negative, the song will start somewhere in the middle based on an algorithm.
func play(from_position: float = -1.0) -> void:
	if from_position < 0:
		# calculate the start position based on an algorithm
		from_position = _freshest_start()
	.play(from_position)
	$StalenessTimer.start()
	_increase_staleness()


func stop() -> void:
	.stop()
	$StalenessTimer.stop()


func get_nearest_checkpoint(start: float) -> float:
	var checkpoint_index: int = Utils.find_closest(checkpoints, start)
	var result := start
	if checkpoint_index != -1:
		result = checkpoints[checkpoint_index]
	return result


## Increases the staleness of the part of the song currently playing.
func _increase_staleness() -> void:
	if playing:
		_played = true
		_staleness_record[int(get_playback_position() / CHUNK_SIZE)] += 1


## Calculates the ideal position to start playing the specified song.
##
## The algorithm we follow is to create a window with the left half of the 'freshness record'. We gradually advance it
## through the entire song, and figure out which half of the song has been played the least. We return the position of
## the song at the start of that half.
func _freshest_start() -> float:
	var freshest_start_index := 0
	var min_staleness: int = 0
	var staleness: int = 0
	# warning-ignore:integer_division
	var r: int = _staleness_record.size() / 2
	for l in range(_staleness_record.size()):
		# advance the 'freshness window'
		r = (r + 1) % _staleness_record.size()
		
		# recalculate the relative staleness of the current window
		staleness -= _staleness_record[l]
		staleness += _staleness_record[r]
		
		if staleness < min_staleness:
			# this is the freshest window; store the freshness and the window position
			min_staleness = staleness
			freshest_start_index = (l + 1) % _staleness_record.size()
	
	var start := freshest_start_index * CHUNK_SIZE
	if not _played:
		# the first time playing a particular song, we start at a checkpoint. this way the player doesn't boot up the
		# game by hearing a musical solo or bridge without context. after the first time, anywhere is OK.
		start = get_nearest_checkpoint(freshest_start_index)
	return start


func _on_StalenessTimer_timeout() -> void:
	_increase_staleness()
