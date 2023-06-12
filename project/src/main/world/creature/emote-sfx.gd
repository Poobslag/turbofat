extends AudioStreamPlayer
## AudioStreamPlayer which ensures multiple copies of the same sound don't play simultaneously.

@warning_ignore("native_method_override")
func play(from_position = 0.0) -> void:
	if SfxDeconflicter.should_play(self):
		super.play(from_position)
