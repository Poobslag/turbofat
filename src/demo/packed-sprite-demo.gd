extends Node
"""
Demonstrates loading and animating a packed sprite.

Keys:
	[Z]: Cycle to the next frame
	Arrows: Move the sprite and print its offset.
"""

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		$PackedSprite.frame = wrapi($PackedSprite.frame + 1, 0, $PackedSprite.frame_count)
	if Input.is_action_just_pressed("ui_right"):
		$PackedSprite.offset.x += 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_left"):
		$PackedSprite.offset.x -= 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_up"):
		$PackedSprite.offset.y -= 1
		_print_frame_details()
	if Input.is_action_just_pressed("ui_down"):
		$PackedSprite.offset.y += 1
		_print_frame_details()


func _print_frame_details() -> void:
	print("json_frame=%s offset=%s" % [$PackedSprite.frame, $PackedSprite.offset])
