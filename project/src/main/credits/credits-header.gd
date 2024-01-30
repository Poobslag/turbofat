class_name CreditsHeader
extends Control
## Shows the game title in the credits.
##
## The game title changes from a text label to bubbly block letters, to visualize how the game's pieces spell the
## words "turbo fat".

## z indexes to assign each bubbly letter sprite for an aesthetically pleasing overlap
const LETTER_SPRITE_Z_INDEXES := [0, 0, 0, 0, 0, 2, 1, 0]

export (PackedScene) var CreditsLetterScene: PackedScene

onready var _label := $Label

## Defines coordinates for the center of each letter. This defines the target of projectiles which want to hit the
## letter, and is also the center point of the bubbly letter sprites which replace the label.
onready var _letter_center_path := $LetterCenterPath

## Container for bubbly letter sprites which replace the label
onready var _letter_sprites := $LetterSprites

func _ready() -> void:
	# initialize the text; this text changes as letters are replaced with bubbly block letters
	_label.text = "turbo fat"


## Returns the center of a specific letter in the label.
func get_visible_letter_position(i: int) -> Vector2:
	return _letter_center_path.position + _letter_center_path.curve.get_point_position(i)


## Replaces the leftmost non-transformed letter with a bubbly block letter.
func transform_next_letter() -> void:
	_remove_next_label_letter()
	
	if _letter_sprites.get_child_count() < 8:
		_add_letter_sprite()


## Replaces all non-transformed letters with bubbly block letters.
func transform_all_letters() -> void:
	while _label.text != "":
		transform_next_letter()


## Removes the leftmost non-transformed letter from the label.
func _remove_next_label_letter() -> void:
	_label.text = _label.text.strip_edges()
	if _label.text:
		_label.text = _label.text.substr(1)
	_label.text = _label.text.strip_edges()


## Adds a bubbly block letter.
func _add_letter_sprite() -> void:
	var sprite_index := _letter_sprites.get_child_count()
	var credits_letter: CreditsLetter = CreditsLetterScene.instance()
	credits_letter.position = get_visible_letter_position(sprite_index)
	credits_letter.scale = Vector2(0.25, 0.25)
	credits_letter.z_index = LETTER_SPRITE_Z_INDEXES[sprite_index]
	credits_letter.piece_index = sprite_index
	_letter_sprites.add_child(credits_letter)
