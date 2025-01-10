class_name CreatureShadow
extends Node2D
## Script which updates the size and position of a shadow beneath a creature.

## Direction of this shadow relative to the creature. Used for creatures sitting on restaurant stools.
export (Vector2) var shadow_offset: Vector2

export (NodePath) var creature_path: NodePath setget set_creature_path
export (Vector2) var shadow_scale := Vector2.ONE

## Creature this shadow is for
var _creature: Creature

## Oval shadow sprite
onready var _sprite: Sprite = $Sprite

## Scales the shadow based on the creature's fatness
onready var _fat_player: AnimationPlayer = $FatPlayer

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


## Connects the shadow to a new creature and updates its position.
func _refresh_creature_path() -> void:
	if not (is_inside_tree() and not creature_path.is_empty()):
		return
	
	if _creature and _creature.is_connected("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed"):
		_creature.disconnect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed")
		_creature.disconnect("dna_loaded", self, "_on_Creature_dna_loaded")
	_creature = get_node(creature_path)
	_creature.connect("visual_fatness_changed", self, "_on_Creature_visual_fatness_changed")
	_creature.connect("dna_loaded", self, "_on_Creature_dna_loaded")
	
	position = _creature.position + shadow_offset
	if not _creature.creature_visuals:
		# wait a frame for the creature's fields to be populated
		yield(get_tree(), "idle_frame")
	if _creature.creature_visuals:
		_sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y
		_refresh_creature_shadow_scale()


## Recalculates the CreatureShadow scale property based on the creature's fatness.
func _refresh_creature_shadow_scale() -> void:
	_fat_player.play("fat")
	_fat_player.advance(_creature.visual_fatness)
	_fat_player.stop()


func _on_Creature_visual_fatness_changed() -> void:
	_refresh_creature_shadow_scale()


func _on_Creature_dna_loaded() -> void:
	_sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y
	_refresh_creature_shadow_scale()
