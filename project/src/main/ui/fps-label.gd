extends Label
"""
Renders the current frames-per-second to the screen, '60.00 fps'
"""

func _process(_delta: float) -> void:
	text = "%d fps" % Engine.get_frames_per_second()


func _on_CheatCodeDetector_cheat_detected(cheat: String, detector: CheatCodeDetector) -> void:
	if cheat == "bigfps":
		visible = not visible
		detector.play_cheat_sound(visible)
