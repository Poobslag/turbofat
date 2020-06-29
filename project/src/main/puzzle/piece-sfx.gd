extends Node
"""
Plays sound effects when the player piece is moved.
"""

func _ready() -> void:
	PuzzleScore.connect("level_index_changed", self, "_on_PuzzleScore_level_index_changed")


func _on_PuzzleScore_level_index_changed(value: int) -> void:
	if value > 0:
		$LevelUpSound.play()


func _play_move_sfx() -> void:
	$MoveSound.pitch_scale = 0.94
	$MoveSound.volume_db = -4.00
	$MoveSound.play()


func _play_das_move_sfx() -> void:
	# Adjust the pitch/volume of DAS moves so they don't sound as grating and samey
	$MoveSound.pitch_scale = clamp($MoveSound.pitch_scale + 0.08, 0.94, 2.00)
	$MoveSound.volume_db = clamp($MoveSound.volume_db * 0.92, 0.50, 1.00)
	$MoveSound.play()

# Movement events ----------------------------------------------------------------

func _on_PieceManager_moved_left() -> void:
	_play_move_sfx()


func _on_PieceManager_moved_right() -> void:
	_play_move_sfx()


func _on_PieceManager_das_moved_left() -> void:
	_play_das_move_sfx()


func _on_PieceManager_das_moved_right() -> void:
	_play_das_move_sfx()


func _on_PieceManager_initial_das_moved_left() -> void:
	_play_move_sfx()


func _on_PieceManager_initial_das_moved_right() -> void:
	_play_move_sfx()


func _on_PieceManager_squish_moved(piece: ActivePiece, old_pos: Vector2) -> void:
	$SquishSound.play()

# Rotation events ----------------------------------------------------------------

func _on_PieceManager_initial_rotated_left() -> void:
	$Rotate0Sound.play()


func _on_PieceManager_initial_rotated_right() -> void:
	$Rotate1Sound.play()


func _on_PieceManager_initial_rotated_twice() -> void:
	$Rotate0Sound.play()


func _on_PieceManager_rotated_left() -> void:
	$Rotate0Sound.play()


func _on_PieceManager_rotated_right() -> void:
	$Rotate1Sound.play()


func _on_PieceManager_rotated_twice() -> void:
	$Rotate0Sound.play()

# Other events -------------------------------------------------------------------

func _on_PieceManager_lock_started() -> void:
	$LockSound.play()


func _on_PieceManager_lock_cancelled() -> void:
	_play_move_sfx()
