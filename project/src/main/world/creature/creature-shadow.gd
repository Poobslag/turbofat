class_name CreatureShadow
extends Node2D
"""
Script which updates the size and position of a shadow beneath a creature.
"""

# The direction of this shadow relative to the creature. Used for creatures sitting on restaurant stools.
export (Vector2) var shadow_offset: Vector2

export (NodePath) var creature_path: NodePath setget set_creature_path
export (Vector2) var shadow_scale := Vector2(1.0, 1.0)

# The Creature this shadow is for
var _creature: Creature

func _ready() -> void:
	visible = false
	_refresh_creature_path()


func _physics_process(_delta: float) -> void:
	visible = _creature.visible
	position = _creature.position + shadow_offset
	modulate.a = _creature.modulate.a


func set_creature_path(new_creature_path: NodePath) -> void:
	creature_path = new_creature_path
	_refresh_creature_path()


"""
Connects the shadow to a new creature and updates its position.
"""
func _refresh_creature_path() -> void:
	if not (is_inside_tree() and creature_path):
		return
	
	if _creature and _creature.is_connected("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed"):
		_creature.disconnect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed")
		_creature.disconnect("creature_arrived", self, "_on_Creature_creature_arrived")
	_creature = get_node(creature_path)
	_creature.connect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed")
	_creature.connect("creature_arrived", self, "_on_Creature_creature_arrived")
	
	position = _creature.position + shadow_offset
	if _creature.creature_visuals:
		$Sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y


func _on_Creature_visual_fatness_changed() -> void:
	$FatPlayer.play("fat")
	$FatPlayer.advance(_creature.get_visual_fatness())
	$FatPlayer.stop()


func _on_Creature_creature_arrived() -> void:
	$Sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y
