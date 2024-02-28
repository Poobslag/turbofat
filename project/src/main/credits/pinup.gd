class_name Pinup
extends Control
## Shows a creature in the credits scene.

export (Color) var bg_color := Color("6c4331") setget set_bg_color

var creature_id: String setget set_creature_id
var orientation: int = Creatures.SOUTHEAST setget set_orientation

## The velocity that the pinup moves up the screen.
var velocity := Vector2(0, -50)

onready var _bg_color_rect := $Customer/View/Viewport/Bg/ColorRect
onready var _nametag_panel := $Customer/Nametag/Panel
onready var creature := $Customer/View/Viewport/Creature

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


func _refresh() -> void:
	if not is_inside_tree():
		return
	
	# avoid assigning creature id unnecessarily, since it triggers the character's assets to be reloaded
	if creature.creature_id != creature_id:
		creature.creature_id = creature_id
		_nametag_panel.refresh_creature(creature)
	
	creature.orientation = orientation
	_bg_color_rect.color = bg_color
