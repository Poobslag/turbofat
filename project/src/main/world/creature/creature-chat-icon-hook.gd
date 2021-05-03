extends RemoteTransform2D
"""
Defines the position so that chat icons appear next to the creature's head.
"""

export (NodePath) var creature_visuals_path: NodePath setget set_creature_visuals_path

var _creature_visuals: CreatureVisuals

var elevation: float setget set_elevation

func _ready() -> void:
	_refresh_creature_visuals_path()
	_refresh_target_position()


func set_elevation(new_elevation: float) -> void:
	elevation = new_elevation
	_refresh_target_position()


func set_creature_visuals_path(new_creature_visuals_path: NodePath) -> void:
	creature_visuals_path = new_creature_visuals_path
	_refresh_creature_visuals_path()


func _refresh_creature_visuals_path() -> void:
	if not (is_inside_tree() and creature_visuals_path):
		return
	
	if _creature_visuals:
		_creature_visuals.disconnect("head_moved", self, "_on_CreatureVisuals_head_moved")
	_creature_visuals = get_node(creature_visuals_path)
	_creature_visuals.connect("head_moved", self, "_on_CreatureVisuals_head_moved")


"""
Reposition the icon next to the creature's head.

If we don't reposition the icon, it gets lost behind creatures that are fat.
"""
func _refresh_target_position() -> void:
	if not _creature_visuals:
		return
	
	position = _creature_visuals.get_node("Neck0").position * _creature_visuals.scale.y * 0.4 \
			- Vector2(0, elevation) * 0.4


func _on_CreatureVisuals_head_moved() -> void:
	_refresh_target_position()
