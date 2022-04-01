tool
extends OverworldObstacle
## Overworld obstacle with different cosmetic variations in a sprite sheet.

## Current frame to display from the sprite sheet.
export (int) var frame: int setget set_frame

func set_frame(new_frame: int) -> void:
	frame = new_frame
	$Sprite.frame = frame
