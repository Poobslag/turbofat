extends Node
"""
Plays sound effects when boxes are made.
"""

onready var _make_snack_box_sounds := [
		preload("res://assets/main/puzzle/make-snack-box0.wav"),
		preload("res://assets/main/puzzle/make-snack-box1.wav"),
		preload("res://assets/main/puzzle/make-snack-box2.wav"),
		preload("res://assets/main/puzzle/make-snack-box3.wav"),
	]

func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color: int) -> void:
	match color:
		0, 1, 2, 3:
			$MakeSnackBoxSound.stream = _make_snack_box_sounds[color]
			$MakeSnackBoxSound.play()
		4: $MakeCakeBoxSound.play()
