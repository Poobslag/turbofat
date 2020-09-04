#tool #uncomment to view creature in editor
extends Node2D
"""
Draws decorations over parts of the creature's body.

Maintains a dictionary of decorations which can be selected by index.
"""

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

# the belly index to draw
export (int) var belly := 0 setget set_belly

# key: Integer belly index.
# value: Array of curve definitions which define the shadow curve coordinates for each of the creature's levels of
# 		fatness. see creature-belly.gd for more details.
export (Dictionary) var curve_defs_by_belly: Dictionary
export (bool) var _save_belly setget save_belly

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh_belly()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func set_belly(new_belly: int) -> void:
	belly = new_belly
	_refresh_belly()


"""
Saves the belly's curve definition into the appropriate CreatureCurve.
"""
func save_belly(value: bool) -> void:
	if not value:
		return
	curve_defs_by_belly[belly] = $Belly.curve_defs


func _refresh_creature_visuals_path() -> void:
	if not is_inside_tree():
		return
	
	if creature_visuals_path:
		$Belly.creature_visuals_path = $Belly.get_path_to(get_node(creature_visuals_path))
	else:
		$Belly.creature_visuals_path = null


func _refresh_belly() -> void:
	if not is_inside_tree():
		return
	
	$Belly.curve_defs = curve_defs_by_belly.get(belly, [])
