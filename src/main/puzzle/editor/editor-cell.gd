class_name EditorCell
"""
Represents a level editor object which can be placed into the playfield.
"""

var tile: int = -1
var autotile_coord: Vector2 = Vector2.ZERO

func _to_string() -> String:
	return "%s:%s" % [tile, autotile_coord]
