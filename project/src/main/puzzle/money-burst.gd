class_name MoneyBurst
extends Node2D
## Indicator like '¥20' which appears when the player earns money from a puzzle critter.
##
## The indicator includes some colorful stylized text with an accent shape behind it.

export (Vector2) var velocity: Vector2

## Money value to display. This controls our text.
var money: int setget set_money

## particles which explode from the center of the money
onready var _particles: Particles2D = $Particles2D
onready var _particles_material: ParticlesMaterial = $Particles2D.process_material

## text showing the earned money, like '¥20'
onready var _label: Label = $Label

## colorful shape which goes behind the text
onready var _accent: PackedSprite = $Accent

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_particles.emitting = true
	_refresh_money()


func _physics_process(delta: float) -> void:
	position += velocity * delta


func set_money(new_money: int) -> void:
	money = new_money
	_refresh_money()


func _refresh_money() -> void:
	if not is_inside_tree():
		return

	_refresh_label()
	_refresh_accent()


func _refresh_label() -> void:
	_label.text = StringUtils.format_money(money)


func _refresh_accent() -> void:
	_accent.frame = 0
	_accent.frame += randi() % 4 # randomly select between four different similar accents


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.editor_hint:
		queue_free()
