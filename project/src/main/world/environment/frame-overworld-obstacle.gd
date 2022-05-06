tool
extends OverworldObstacle
## Overworld obstacle with different cosmetic variations in a sprite sheet.

## Current frame to display from the sprite sheet.
export (int) var frame: int setget set_frame

## If true, the sprite's texture is flipped horizontally.
export (bool) var flip_h: bool setget set_flip_h

## An editor toggle which randomizes the obstacle's appearance
export (bool) var shuffle: bool setget set_shuffle

func set_frame(new_frame: int) -> void:
	frame = new_frame
	$Sprite.frame = frame


func set_flip_h(new_flip_h: bool) -> void:
	flip_h = new_flip_h
	$Sprite.flip_h = flip_h


## Randomizes the obstacle's appearance.
func set_shuffle(value: bool) -> void:
	if not value:
		return
	
	set_frame(randi() % ($Sprite.hframes * $Sprite.vframes))
	set_flip_h(randf() > 0.5)
	scale = Vector2(1.0, 1.0)
	
	property_list_changed_notify()
