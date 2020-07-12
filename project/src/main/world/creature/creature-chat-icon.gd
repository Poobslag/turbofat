extends ChatIcon
"""
A visual icon which appears next to something the player can interact with.
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
	set_target_position(_creature_visuals.get_node("Neck0").position * 0.4)


func _on_CreatureVisuals_head_moved() -> void:
	_refresh_target_position()
