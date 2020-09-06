extends RemoteTransform2D
"""
Defines the position so that chat icons appear next to the creature's head.
"""

export (NodePath) var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("head_moved", self, "_on_CreatureVisuals_head_moved")
	_refresh_target_position()


"""
Reposition the icon next to the creature's head.

If we don't reposition the icon, it gets lost behind creatures that are fat.
"""
func _refresh_target_position() -> void:
	position = _creature_visuals.get_node("Neck0").position * _creature_visuals.scale.y * 0.4


func _on_CreatureVisuals_head_moved() -> void:
	_refresh_target_position()
