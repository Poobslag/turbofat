class_name CreatureShadow
extends Node2D
## Script which updates the size and position of a shadow beneath a creature.

## Direction of this shadow relative to the creature. Used for creatures sitting on restaurant stools.
@export var shadow_offset: Vector2

@export var creature_path: NodePath: set = set_creature_path
@export var shadow_scale := Vector2.ONE

## Creature this shadow is for
var _creature: Creature

## Oval shadow sprite
@onready var _sprite: Sprite2D = $Sprite2D

## Scales the shadow based on the creature's fatness
@onready var _fat_player: AnimationPlayer = $FatPlayer

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
	
	if _creature and _creature.visual_fatness_changed.is_connected(_on_Creature_visual_fatness_changed):
		_creature.visual_fatness_changed.disconnect(_on_Creature_visual_fatness_changed)
		_creature.dna_loaded.disconnect(_on_Creature_dna_loaded)
	_creature = get_node(creature_path)
	_creature.visual_fatness_changed.connect(_on_Creature_visual_fatness_changed)
	_creature.dna_loaded.connect(_on_Creature_dna_loaded)
	
	position = _creature.position + shadow_offset
	if _creature.creature_visuals:
		_sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y
		_refresh_creature_shadow_scale()


## Recalculates the CreatureShadow scale property based on the creature's fatness.
func _refresh_creature_shadow_scale() -> void:
	_fat_player.play("fat")
	_fat_player.advance(_creature.get_visual_fatness())
	_fat_player.stop()


func _on_Creature_visual_fatness_changed() -> void:
	_refresh_creature_shadow_scale()


func _on_Creature_dna_loaded() -> void:
	_sprite.scale = Vector2(0.17, 0.17) * shadow_scale * _creature.creature_visuals.scale.y
	_refresh_creature_shadow_scale()
