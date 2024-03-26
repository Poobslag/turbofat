class_name EndTextTitle
extends Node2D
## Shows the game title on the end screen.

## z indexes to assign each bubbly letter sprite for an aesthetically pleasing overlap
const LETTER_SPRITE_Z_INDEXES := [0, 0, 0, 0, 0, 2, 1, 0]

export (PackedScene) var CreditsLetterScene: PackedScene

## Defines coordinates for the center of each bubbly letter sprite.
onready var _letter_center_path := $LetterCenterPath

## Container for bubbly letter sprites.
onready var _letter_sprites := $LetterSprites

## Returns the center of a specific letter in the label.
func get_visible_letter_position(i: int) -> Vector2:
	return _letter_center_path.position + _letter_center_path.curve.get_point_position(i)


## Adds a bubbly block letter.
func add_next_letter() -> void:
	if _letter_sprites.get_child_count() < 8:
		_add_letter_sprite()


func reset() -> void:
	for node in _letter_sprites.get_children():
		node.queue_free()
		_letter_sprites.remove_child(node)


## Adds a bubbly block letter.
func _add_letter_sprite() -> void:
	var sprite_index := _letter_sprites.get_child_count()
	var credits_letter: CreditsLetter = CreditsLetterScene.instance()
	credits_letter.position = get_visible_letter_position(sprite_index)
	credits_letter.scale = Vector2(0.25, 0.25)
	credits_letter.z_index = LETTER_SPRITE_Z_INDEXES[sprite_index]
	credits_letter.piece_index = sprite_index
	_letter_sprites.add_child(credits_letter)
