tool
class_name FreeRoamWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles on the free roam overworld.

func _ready() -> void:
	ChattableManager.refresh_creatures()
	if PlayerData.free_roam.player_spawn_id:
		overworld_environment.move_creature_to_spawn(ChattableManager.player, PlayerData.free_roam.player_spawn_id)
	
	if PlayerData.free_roam.sensei_spawn_id:
		overworld_environment.move_creature_to_spawn(ChattableManager.sensei, PlayerData.free_roam.sensei_spawn_id)
	
	$Camera.position = ChattableManager.player.position

func initial_environment_path() -> String:
	return PlayerData.free_roam.environment_path
