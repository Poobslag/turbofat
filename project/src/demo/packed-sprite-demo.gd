extends Node
"""
Demonstrates loading and animating a packed sprite.

Keys:
	[Z]: Cycle to the next frame
	Arrows: Move the sprite and print its offset.
"""

onready var _packed_sprite: PackedSprite = $PackedSprite

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_packed_sprite.frame = wrapi(_packed_sprite.frame + 1, 0, _packed_sprite.frame_count)
	if Input.is_action_just_pressed("ui_right"):
		_packed_sprite.offset.x += 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_left"):
		_packed_sprite.offset.x -= 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_up"):
		_packed_sprite.offset.y -= 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_down"):
		_packed_sprite.offset.y += 1
		_print_frame_details()


func _print_frame_details() -> void:
	print("json_frame=%s offset=%s" % [_packed_sprite.frame, _packed_sprite.offset])
