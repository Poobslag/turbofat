extends Node
## Plays sound effects when boxes are built.

onready var _build_snack_box_sounds := [
		preload("res://assets/main/puzzle/build-snack-box0.wav"),
		preload("res://assets/main/puzzle/build-snack-box1.wav"),
		preload("res://assets/main/puzzle/build-snack-box2.wav"),
		preload("res://assets/main/puzzle/build-snack-box3.wav"),
	]

func _on_Playfield_box_built(_rect: Rect2, color: int) -> void:
	if Foods.is_snack_box(color):
		$BuildSnackBoxSound.stream = _build_snack_box_sounds[color]
		$BuildSnackBoxSound.play()
	elif Foods.is_cake_box(color):
		$BuildCakeBoxSound.play()
