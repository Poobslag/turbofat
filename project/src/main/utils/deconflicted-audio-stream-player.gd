extends AudioStreamPlayer
## AudioStreamPlayer which ensures multiple copies of the same sound don't play simultaneously.

## number of milliseconds before the sound can play a second time.
export (int) var suppress_sfx_msec := SfxDeconflicter.DEFAULT_SUPPRESS_SFX_MSEC

func play(from_position = 0.0) -> void:
	if SfxDeconflicter.should_play(self, suppress_sfx_msec):
		.play(from_position)
