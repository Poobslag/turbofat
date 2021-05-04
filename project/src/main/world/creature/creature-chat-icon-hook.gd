extends RemoteTransform2D
"""
Defines the position so that chat icons appear next to the creature's head.
"""

var creature_visuals: CreatureVisuals setget set_creature_visuals

var elevation: float setget set_elevation

func _ready() -> void:
	_connect_creature_visuals_listeners()
	_refresh_target_position()


func set_elevation(new_elevation: float) -> void:
	elevation = new_elevation
	_refresh_target_position()


func set_creature_visuals(new_creature_visuals: CreatureVisuals) -> void:
	if creature_visuals: 
		creature_visuals.disconnect("head_moved", self, "_on_CreatureVisuals_head_moved")
	creature_visuals = new_creature_visuals
	_connect_creature_visuals_listeners()


func _connect_creature_visuals_listeners() -> void:
	if not creature_visuals:
		return
	
	creature_visuals.connect("head_moved", self, "_on_CreatureVisuals_head_moved")


"""
Reposition the icon next to the creature's head.

If we don't reposition the icon, it gets lost behind creatures that are fat.
"""
func _refresh_target_position() -> void:
	if not creature_visuals:
		return
	
	position = creature_visuals.get_node("Neck0").position * creature_visuals.scale.y * 0.4 \
			- Vector2(0, elevation) * 0.4


func _on_CreatureVisuals_head_moved() -> void:
	_refresh_target_position()
