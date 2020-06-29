extends Node
"""
Plays sound effects when boxes are built.
"""

onready var _build_snack_box_sounds := [
		preload("res://assets/main/puzzle/build-snack-box0.wav"),
		preload("res://assets/main/puzzle/build-snack-box1.wav"),
		preload("res://assets/main/puzzle/build-snack-box2.wav"),
		preload("res://assets/main/puzzle/build-snack-box3.wav"),
	]

func _on_Playfield_box_built(_x: int, _y: int, _width: int, _height: int, color: int) -> void:
	match color:
		0, 1, 2, 3:
			$BuildSnackBoxSound.stream = _build_snack_box_sounds[color]
			$BuildSnackBoxSound.play()
		4: $BuildCakeBoxSound.play()
