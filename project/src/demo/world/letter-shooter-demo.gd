extends Node
## Demonstrates the 'letter shooter' which launches letter projectiles.
##
## Keys:
## 	]: Start shooting letters
## 	[: Stop shooting letters

func _input(event: InputEvent) -> void:
	match Utils.key_scancode(event):
		KEY_BRACKETRIGHT: $LetterShooter.start()
		KEY_BRACKETLEFT: $LetterShooter.stop()
