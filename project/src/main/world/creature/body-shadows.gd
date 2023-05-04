#tool #uncomment to view creature in editor
extends Node2D

@export var creature_visuals_path: NodePath: set = set_creature_visuals_path

func _ready() -> void:
	_refresh_creature_visuals_path()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and not creature_visuals_path.is_empty()):
		return
	
	if not creature_visuals_path.is_empty() and has_node(creature_visuals_path):
		$HeadShadow.creature_visuals_path = $HeadShadow.get_path_to(get_node(creature_visuals_path))
		$ArmShadow.creature_visuals_path = $ArmShadow.get_path_to(get_node(creature_visuals_path))
		$BellyShadow.creature_visuals_path = $BellyShadow.get_path_to(get_node(creature_visuals_path))
	else:
		$HeadShadow.creature_visuals_path = null
		$ArmShadow.creature_visuals_path = null
		$BellyShadow.creature_visuals_path = null
