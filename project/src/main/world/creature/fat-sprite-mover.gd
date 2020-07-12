extends AnimationPlayer
"""
Moves the creature's body parts around as they become fatter.

While this is an AnimationPlayer, the animation is only used to rearrange their body parts. It shouldn't ever be
played as an animation.
"""

export (NodePath) var creature_visuals_path: NodePath

onready var _creature_visuals: CreatureVisuals = get_node(creature_visuals_path)

func _ready() -> void:
	_creature_visuals.connect("visual_fatness_changed", self, "_on_CreatureVisuals_visual_fatness_changed")
	_creature_visuals.connect("orientation_changed", self, "_on_CreatureVisuals_orientation_changed")


func _on_CreatureVisuals_visual_fatness_changed() -> void:
	_refresh_sprite_positions()


func _on_CreatureVisuals_orientation_changed(_old_orientation: int, _new_orientation: int) -> void:
	_refresh_sprite_positions()


func _refresh_sprite_positions() -> void:
	play("fat-se" if _creature_visuals.orientation in [Creature.SOUTHWEST, Creature.SOUTHEAST] else "fat-nw")
	advance(_creature_visuals.visual_fatness)
	stop()
	_creature_visuals.emit_signal("head_moved")
