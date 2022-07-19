extends Node
## Demonstrates loading and animating a packed sprite.
##
## Keys:
## 	[Z]: Cycle to the next frame
## 	Arrows: Move the sprite and print its offset.

onready var _packed_sprite: PackedSprite = $PackedSprite

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_Z:
			_packed_sprite.frame = wrapi(_packed_sprite.frame + 1, 0, _packed_sprite.frame_count)
		KEY_RIGHT:
			_packed_sprite.offset.x += 1
			_print_frame_details()
		KEY_LEFT:
			_packed_sprite.offset.x -= 1
			_print_frame_details()
		KEY_UP:
			_packed_sprite.offset.y -= 1
			_print_frame_details()
		KEY_DOWN:
			_packed_sprite.offset.y += 1
			_print_frame_details()


func _print_frame_details() -> void:
	print("json_frame=%s offset=%s" % [_packed_sprite.frame, _packed_sprite.offset])
