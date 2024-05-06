extends Node
## Demonstrates the bubbly letters that poof in during the credits.
##
## Keys:
## 	Space: Add a letter.
## 	[X]: Remove all letters.

export (PackedScene) var CreditsLetterScene: PackedScene

var _next_piece_index := 0

onready var _letters := $Letters

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_SPACE:
			_add_letter()
		KEY_X:
			_remove_all_letters()


func _add_letter() -> void:
	var new_letter: CreditsLetter = CreditsLetterScene.instance()
	new_letter.piece_index = _next_piece_index
	_next_piece_index = (_next_piece_index + 1) % 8
	var target_rect := Rect2(_letters.rect_position, _letters.rect_size).grow(-100)
	new_letter.position.x = rand_range(target_rect.position.x, target_rect.end.x)
	new_letter.position.y = rand_range(target_rect.position.y, target_rect.end.y)
	new_letter.scale = Vector2(0.33333, 0.33333)
	_letters.add_child(new_letter)


func _remove_all_letters() -> void:
	for node in _letters.get_children():
		node.queue_free()
