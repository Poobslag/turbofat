extends Node2D
"""
Script which updates the size and position of a shadow beneath a creature.
"""

# The direction of this shadow relative to the creature. Used for creatures sitting on restaurant stools.
export (Vector2) var _shadow_offset: Vector2

export (NodePath) var _creature_path: NodePath
onready var _creature: Creature = get_node(_creature_path)

func _ready() -> void:
	position = _creature.position + _shadow_offset
	_creature.connect("fatness_changed", self, "_on_Creature_fatness_changed")
	_creature.connect("creature_arrived", self, "_on_Creature_creature_arrived")
	visible = false


func _on_Creature_fatness_changed() -> void:
	$FatPlayer.set_fatness(_creature.get_fatness())


func _on_Creature_creature_arrived() -> void:
	visible = true
