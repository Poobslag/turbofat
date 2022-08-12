extends OverworldObstacle
## Turbo Fat restaurant which appears in the overworld.
##
## This script toggles the restaurant's appearance based on the player's story progression.

onready var sprite := $Sprite
onready var undecorated_sprite := $UndecoratedSprite

func _ready() -> void:
	if PlayerData.career.best_distance_travelled < CareerData.DECORATED_RESTAURANT_CUTOFF:
		sprite.visible = false
		undecorated_sprite.visible = true
	else:
		sprite.visible = true
		undecorated_sprite.visible = false
