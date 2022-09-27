extends Node
## Ensures multiple copies of the same sound don't play simultaneously.
##
## By calling SfxDeconflicter.play() with multiple AudioStreamPlayers, this script tracks when those AudioStreamPlayers
## play to prevent two copies of the same sound from playing simultaneously. This prevents the player from hearing one
## very loud sound effect when several things happen at once.

## The number of milliseconds before the same sound can play a second time.
const SUPPRESS_SFX_MSEC := 20

## key: audio stream resource path
## value: the amount of time passed in milliseconds between when the engine started and when the sound effect was last
## 	played
var last_played_msec_by_resource_path := {}

## Plays the specified sound effect, unless it was recently played.
##
## Parameters:
## 	'player': The sound effect to play.
##
## 	'from_position': The sound effect's start position.
func play(player: AudioStreamPlayer, from_position: float = 0.0) -> void:
	if not should_play(player):
		# suppress sound effect; sound was played too recently
		pass
	else:
		# play sound effect
		player.play(from_position)


## Returns 'true' if the specified sound effect should play, updating our state to ensure it doesn't play again.
##
## Calling this method results in a state change. It should only be called if the caller wants to play the sound.
func should_play(player: AudioStreamPlayer) -> bool:
	var result := true
	var resource_path := player.stream.resource_path
	var last_played_msec: int = last_played_msec_by_resource_path.get(resource_path, 0)
	if last_played_msec + SUPPRESS_SFX_MSEC >= OS.get_ticks_msec():
		# suppress sound effect; sound was played too recently
		result = false
	else:
		# update 'last_played'; sound is about to be played
		last_played_msec_by_resource_path[resource_path] = OS.get_ticks_msec()
	return result
