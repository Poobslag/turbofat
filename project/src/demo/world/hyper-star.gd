extends Sprite


func _process(delta: float) -> void:
	frame = (frame + 1) % (hframes * vframes)
