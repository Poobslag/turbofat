extends Camera2D
## Camera for the free roam overworld. Follows the main character.

export (NodePath) var overworld_environment_path: NodePath setget set_overworld_environment_path

var _overworld_environment: OverworldEnvironment

func _ready() -> void:
	_refresh_overworld_environment_path()


func _process(_delta: float) -> void:
	if not _overworld_environment.player:
		# The overworld camera follows the player. If there is no player, we have nothing to follow
		return
	
	position = lerp(position, _overworld_environment.player.position, 0.10)


func set_overworld_environment_path(new_overworld_environment_path: NodePath) -> void:
	overworld_environment_path = new_overworld_environment_path
	_refresh_overworld_environment_path()


func _refresh_overworld_environment_path() -> void:
	if not is_inside_tree():
		return
	
	_overworld_environment = get_node(overworld_environment_path) if overworld_environment_path else null


func _on_OverworldWorld_overworld_environment_changed(value: OverworldEnvironment) -> void:
	overworld_environment_path = get_path_to(value)
	_overworld_environment = value
