#@tool
class_name FreeRoamWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles on the free roam overworld.

func _ready() -> void:
	CreatureManager.player.free_roam = true
	CreatureManager.sensei.free_roam = true
	
	$Camera2D.position = CreatureManager.player.position
