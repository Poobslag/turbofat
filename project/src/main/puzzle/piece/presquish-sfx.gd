class_name PresquishSfx
extends AudioStreamPlayer
## Plays sound effects when the player starts a squish move.

## 'true' if a sound effect was played for the current squish move. This seems redundant with the 'playing' property,
## but this property stays set to true after the sound effect completes, preventing the sound from looping undesirably.
var sfx_started := false

## Starts playing a sound effect for a squish move.
func start_presquish_sfx() -> void:
	sfx_started = true
	pitch_scale = rand_range(0.8, 1.3)
	volume_db = rand_range(-15.0, -9.0)
	play(rand_range(0.0, 0.2))


## Stops the current sound effect.
func stop_presquish_sfx() -> void:
	sfx_started = false
	stop()
