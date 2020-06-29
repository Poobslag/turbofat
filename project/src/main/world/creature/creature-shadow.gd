extends Node2D
"""
Script which updates the size and position of a shadow beneath a creature.
"""

# The direction of this shadow relative to the creature. Used for creatures sitting on restaurant stools.
export (Vector2) var shadow_offset: Vector2

export (NodePath) var creature_path: NodePath
export (Vector2) var shadow_scale := Vector2(1.0, 1.0)

# The Creature or Creature2D instance this shadow is for
onready var _creature: Node = get_node(creature_path)

func _ready() -> void:
	position = _creature.position + shadow_offset
	$Sprite.scale = Vector2(0.17, 0.17) * shadow_scale
	_creature.connect("fatness_changed", self, "_on_Creature_fatness_changed")
	visible = false


func _physics_process(_delta: float) -> void:
	visible = _creature.visible
	position = _creature.position + shadow_offset


func _on_Creature_fatness_changed() -> void:
	$FatPlayer.set_fatness(_creature.get_fatness())
