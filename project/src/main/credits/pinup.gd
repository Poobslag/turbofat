class_name Pinup
extends Control
## Shows a creature in the credits scene.

const TRANSFORMED_SPRITES_BY_CREATURE_ID := {
	"#sensei#": preload("res://assets/main/credits/pinup-sensei.png"),
	"bones": preload("res://assets/main/credits/pinup-bones.png"),
	"chelle": preload("res://assets/main/credits/pinup-chelle.png"),
	"frungle": preload("res://assets/main/credits/pinup-frungle.png"),
	"goris": preload("res://assets/main/credits/pinup-goris.png"),
	"mara": preload("res://assets/main/credits/pinup-mara.png"),
	"namory": preload("res://assets/main/credits/pinup-namory.png"),
	"shirts": preload("res://assets/main/credits/pinup-shirts.png"),
	"tunathy": preload("res://assets/main/credits/pinup-tunathy.png"),
}

export (Color) var bg_color := Color("6c4331") setget set_bg_color

var creature_id: String setget set_creature_id
var orientation: int = Creatures.SOUTHEAST setget set_orientation

## The velocity that the pinup moves up the screen.
var velocity := Vector2(0, -50)

onready var creature := $Untransformed/View/Viewport/Creature

onready var _bg_color_rect := $Untransformed/View/Viewport/Bg/ColorRect
onready var _nametag_panel := $Nametag/Panel
onready var _transformed := $Transformed
onready var _transformed_player := $Transformed/AnimationPlayer
onready var _transformed_sprite := $Transformed/Sprite
onready var _untransformed := $Untransformed

func _ready() -> void:
	_refresh()


func set_bg_color(new_bg_color: Color) -> void:
	bg_color = new_bg_color
	_refresh()


func set_creature_id(new_creature_id: String) -> void:
	creature_id = new_creature_id
	_refresh()


func set_orientation(new_orientation: int) -> void:
	orientation = new_orientation
	_refresh()


## Animates the creature's appearance according to the specified mood: happy, angry, etc...
##
## Parameters:
## 	'mood': The creature's new mood from Creatures.Mood
func play_mood(mood: int) -> void:
	creature.play_mood(mood)


## Restores the pinup to its default untransformed state.
func reset() -> void:
	_transformed_player.play("RESET")
	_untransformed.visible = true
	_transformed.visible = false


## Replaces the pinup with a stylish transformed image.
func transform(flip_h: bool = false) -> void:
	_untransformed.visible = false
	_transformed.visible = true
	_transformed_sprite.flip_h = flip_h
	_transformed_player.play("play")
	
	# initialize the mix_color shader param, otherwise there will be one non-white frame visible
	_transformed_sprite.material.set_shader_param("mix_color", Color.white)
	
	if creature_id in TRANSFORMED_SPRITES_BY_CREATURE_ID:
		_transformed_sprite.texture = TRANSFORMED_SPRITES_BY_CREATURE_ID[creature_id]


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	# avoid assigning creature id unnecessarily, since it triggers the character's assets to be reloaded
	if creature.creature_id != creature_id:
		creature.creature_id = creature_id
		_nametag_panel.refresh_creature(creature)
	
	creature.orientation = orientation
	_bg_color_rect.color = bg_color
