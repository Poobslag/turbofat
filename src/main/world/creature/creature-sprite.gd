# uncomment to view creature in editor
#tool
extends Sprite
"""
Sprites which toggles between a single 'toward the camera' and 'away from the camera' frame
"""

export (NodePath) var creature_path: NodePath
export (bool) var invisible_while_moving := false

onready var _creature: Creature = get_node(creature_path)

func _on_Creature_orientation_changed(orientation: int) -> void:
	if orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST]:
		# facing south; initialize textures to forward-facing frame
		frame = 1
	else:
		# facing north; initialize textures to backward-facing frame
		frame = 2


func _on_Creature_movement_mode_changed(movement_mode: bool) -> void:
	if invisible_while_moving:
		visible = not movement_mode
