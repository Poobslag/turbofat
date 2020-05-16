extends Node
"""
Plays sound effects when boxes are made.
"""

func _on_Playfield_box_made(x: int, y: int, width: int, height: int, color: int) -> void:
	match color:
		0: $MakeSnackBoxSound0.play()
		1: $MakeSnackBoxSound1.play()
		2: $MakeSnackBoxSound2.play()
		3: $MakeSnackBoxSound3.play()
		4: $MakeCakeBoxSound.play()
