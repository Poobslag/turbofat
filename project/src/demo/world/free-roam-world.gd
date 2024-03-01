tool
class_name FreeRoamWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles on the free roam overworld.

func _ready() -> void:
	overworld_environment.player.free_roam = true
	overworld_environment.sensei.free_roam = true
	
	$Camera.position = overworld_environment.player.position
