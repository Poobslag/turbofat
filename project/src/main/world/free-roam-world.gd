tool
class_name FreeRoamWorld
extends OverworldWorld
## Populates/unpopulates the creatures and obstacles on the free roam overworld.

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not Breadcrumb.trail:
		# For developers accessing the FreeRoam scene directly, we initialize a default Breadcrumb trail.
		# For regular players the Breadcrumb trail will already be initialized by the menus.
		Breadcrumb.initialize_trail()
	
	MusicPlayer.play_chill_bgm()
	
	ChattableManager.refresh_creatures()
	if PlayerData.free_roam.player_spawn_id:
		overworld_environment.move_creature_to_spawn(ChattableManager.player, PlayerData.free_roam.player_spawn_id)
	
	if PlayerData.free_roam.sensei_spawn_id:
		overworld_environment.move_creature_to_spawn(ChattableManager.sensei, PlayerData.free_roam.sensei_spawn_id)
	
	$Camera.position = ChattableManager.player.position


func prepare_environment_resource() -> void:
	if PlayerData.free_roam.environment_path:
		EnvironmentScene = load(PlayerData.free_roam.environment_path)
