extends Node
## Plays sound effects when the player piece is moved.

func _ready() -> void:
	PuzzleState.connect("speed_index_changed", self, "_on_PuzzleState_speed_index_changed")


func _play_move_sfx() -> void:
	$MoveSound.pitch_scale = 0.94
	$MoveSound.volume_db = -4.00
	$MoveSound.play()


func _play_das_move_sfx() -> void:
	# Adjust the pitch/volume of DAS moves so they don't sound as grating and samey
	$MoveSound.pitch_scale = clamp($MoveSound.pitch_scale + 0.08, 0.94, 2.00)
	$MoveSound.volume_db = clamp($MoveSound.volume_db * 0.92, 0.50, 1.00)
	$MoveSound.play()


func _on_PuzzleState_speed_index_changed(value: int) -> void:
	if value > 0:
		$LevelUpSound.play()

## Movement events ----------------------------------------------------------------

func _on_PieceManager_moved_left(_piece: ActivePiece) -> void:
	_play_move_sfx()


func _on_PieceManager_moved_right(_piece: ActivePiece) -> void:
	_play_move_sfx()


func _on_PieceManager_das_moved_left(_piece: ActivePiece) -> void:
	_play_das_move_sfx()


func _on_PieceManager_das_moved_right(_piece: ActivePiece) -> void:
	_play_das_move_sfx()


func _on_PieceManager_initial_das_moved_left(_piece: ActivePiece) -> void:
	_play_move_sfx()


func _on_PieceManager_initial_das_moved_right(_piece: ActivePiece) -> void:
	_play_move_sfx()


func _on_PieceManager_landed(_piece: ActivePiece) -> void:
	$LandSound.play()


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	$SquishSound.play()

## Rotation events ----------------------------------------------------------------

func _on_PieceManager_initial_rotated_ccw(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed0Sound.play()
	else:
		$Rotate0Sound.play()


func _on_PieceManager_initial_rotated_cw(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed0Sound.play()
	else:
		$Rotate0Sound.play()


func _on_PieceManager_initial_rotated_180(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed0Sound.play()
	else:
		$Rotate0Sound.play()


func _on_PieceManager_rotated_ccw(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed0Sound.play()
	else:
		$Rotate0Sound.play()


func _on_PieceManager_rotated_cw(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed1Sound.play()
	else:
		$Rotate1Sound.play()


func _on_PieceManager_rotated_180(piece: ActivePiece) -> void:
	if piece.is_sealed() \
			and not CurrentLevel.settings.other.suppress_piece_rotation in [
				OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
				OtherRules.SuppressPieceRotation.ROTATION]:
		$RotateSealed0Sound.play()
	else:
		$Rotate0Sound.play()


func _on_PieceManager_hold_piece_swapped(_piece: ActivePiece) -> void:
	$SwapHoldPieceSound.play()

## Other events -------------------------------------------------------------------

func _on_PieceManager_lock_started(_piece: ActivePiece) -> void:
	$LockSound.play()


func _on_PieceManager_lock_cancelled(_piece: ActivePiece) -> void:
	_play_move_sfx()


func _on_PieceManager_finished_spin_move(_piece: ActivePiece, _lines_cleared: int) -> void:
	$TechMoveSound.play()


func _on_PieceManager_finished_squish_move(_piece: ActivePiece, _lines_cleared: int) -> void:
	$TechMoveSound.play()
