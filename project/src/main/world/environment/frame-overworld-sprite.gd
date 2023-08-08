tool
extends Sprite
## Overworld sprite with different cosmetic variations in a sprite sheet.

## Editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	set_frame(randi() % (hframes * vframes))
	set_flip_h(randf() < 0.5)
