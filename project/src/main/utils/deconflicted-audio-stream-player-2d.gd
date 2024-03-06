extends AudioStreamPlayer2D
## AudioStreamPlayer2D which ensures multiple copies of the same sound don't play simultaneously.

func play(from_position = 0.0) -> void:
	if SfxDeconflicter.should_play(self):
		.play(from_position)
