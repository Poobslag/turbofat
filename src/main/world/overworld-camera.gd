extends InterpolatedCamera
"""
Camera used when walking around on the overworld.
"""

func zoom_in() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property(self, "size", size, 70, 1.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()


func zoom_out() -> void:
	$Tween.stop_all()
	$Tween.interpolate_property(self, "size", size, 140, 1.6, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
