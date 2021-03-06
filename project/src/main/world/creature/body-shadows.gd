#tool #uncomment to view creature in editor
extends Node2D

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

func _ready() -> void:
	_refresh_creature_visuals_path()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if creature_visuals_path and has_node(creature_visuals_path):
		$HeadShadow.creature_visuals_path = $HeadShadow.get_path_to(get_node(creature_visuals_path))
		$ArmShadow.creature_visuals_path = $ArmShadow.get_path_to(get_node(creature_visuals_path))
		$BellyShadow.creature_visuals_path = $BellyShadow.get_path_to(get_node(creature_visuals_path))
	else:
		$HeadShadow.creature_visuals_path = null
		$ArmShadow.creature_visuals_path = null
		$BellyShadow.creature_visuals_path = null
