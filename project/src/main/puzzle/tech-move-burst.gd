class_name TechMoveBurst
extends Node2D
## An indicator like 'J-Squish' or 'P-Spin Double' which appears when the player locks in a piece in a special way.
##
## The indicator includes some colorful stylized text with an accent shape behind it.

enum TechType {
	SPIN,
	SQUISH,
}

const SPIN := TechType.SPIN
const SQUISH := TechType.SQUISH

## The velocity applied to the food when in the 'floating' state
export (Vector2) var velocity: Vector2

## Key: (int) Number of lines cleared
## Value: (String) Word for the number of lines like 'Single' or 'Double'
var _word_by_lines_cleared := {
	0: "",
	1: tr("Single"),
	2: tr("Double"),
	3: tr("Triple"),
	4: tr("Quad"),
}

## Key: (int) Enum from TechType such as Spin or Squish
## Value: (String) Suffix such as 'Spin' for the phrases 'J-Squish' or 'P-Spin'
var _suffix_by_tech_type := {
	SPIN: tr("Spin"),
	SQUISH: tr("Squish"),
}

## The piece type, such as 'J-Piece' or 'P-Piece'
var piece_type: PieceType setget set_piece_type

## An enum from TechType such as 'Spin' or 'Squish'
var tech_type: int setget set_burst_type

## The number of lines cleared by this tech move
var lines_cleared: int setget set_lines_cleared

## Colors to use; these are automatically assigned based on the number of lines cleared
var _font_color: Color
var _accent_color: Color # darker version of the font color
var _particle_color: Color # lighter version of the font color

## particles which explode from the center of the burst
onready var _particles: Particles2D = $Particles2D
onready var _particles_material: ParticlesMaterial = $Particles2D.process_material

## text summarizing the tech move, like 'P-Spin Double'
onready var _label: Label = $Label

## colorful shape which goes behind the text
onready var _accent: PackedSprite = $Accent

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_particles.emitting = true
	_refresh()


func _physics_process(delta: float) -> void:
	position += velocity * delta


func set_piece_type(new_piece_type: PieceType) -> void:
	piece_type = new_piece_type
	_refresh()


func set_lines_cleared(new_lines_cleared: int) -> void:
	lines_cleared = new_lines_cleared
	_refresh()


func set_burst_type(new_burst_type: int) -> void:
	tech_type = new_burst_type
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return

	_calculate_colors()
	_refresh_label()
	_refresh_accent()
	_refresh_particles()


func _calculate_colors() -> void:
	var outline_darkness := 0.2
	if lines_cleared == 0:
		_font_color = Color("4a9fff") # blue
	else:
		_font_color = Color("4affcf") # cyan
	_accent_color = _font_color
	_accent_color.s += outline_darkness
	_accent_color.v -= outline_darkness * 2
	_particle_color = _font_color
	_particle_color.s -= 0.3


func _refresh_label() -> void:
	_label.set("custom_colors/font_color", _font_color)
	var font: DynamicFont = _label.get("custom_fonts/font")
	font.outline_color = _accent_color
	
	# assign text like 'J-Squish' or 'P-Spin Double'
	var new_text := "%s-%s" % [piece_type.string.to_upper(), _suffix_by_tech_type.get(tech_type)]
	if lines_cleared:
		new_text += "\n%s" % [_word_by_lines_cleared.get(lines_cleared, tr("Mega"))]
	_label.text = new_text


func _refresh_accent() -> void:
	if lines_cleared == 0:
		_accent.frame = 0
		_accent.base_scale = Vector2(0.25, 0.25)
	else:
		_accent.frame = 4
		_accent.base_scale = Vector2(0.325, 0.325)
	_accent.frame += randi() % 4 # randomly select between four different similar accents
	_accent.modulate = _accent_color


func _refresh_particles() -> void:
	_particles_material.scale = 5
	if lines_cleared == 0:
		_particles.amount = 6
		_particles_material.initial_velocity = 200
	else:
		_particles.amount = 8
		_particles_material.initial_velocity = 280
	_particles_material.color_ramp.gradient.colors[0] = _font_color
	_particles_material.color_ramp.gradient.colors[1] = Utils.to_transparent(_font_color)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if not Engine.editor_hint:
		queue_free()
