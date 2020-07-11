#tool #uncomment to view creature in editor
extends ViewportContainer
"""
Draws decorations over parts of the creature's body.

Maintains a dictionary of decorations which can be selected by index.
"""

# the belly index to draw
export (int) var belly := 0 setget set_belly

# key: Integer belly index.
# value: Array of curve definitions which define the shadow curve coordinates for each of the creature's levels of
# 		fatness. see creature-belly.gd for more details.
export (Dictionary) var curve_defs_by_belly: Dictionary
export (bool) var _save_belly setget save_belly

func _ready() -> void:
	_refresh_belly()


func set_belly(new_belly: int) -> void:
	belly = new_belly
	_refresh_belly()

"""
Saves the belly's curve definition into the appropriate CreatureCurve.
"""
func save_belly(value: bool) -> void:
	if not value:
		return
	curve_defs_by_belly[belly] = $Viewport/Body/Belly.curve_defs


func _refresh_belly() -> void:
	if is_inside_tree():
		$Viewport/Body/Belly.curve_defs = curve_defs_by_belly.get(belly, [])
