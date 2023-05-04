class_name TechMoveDetector
extends Node
## Detects when the player places a sealed-in piece with a spin move or squish move.

## 'true' if the piece was most recently disturbed by the player spinning it
var did_spin := false

## 'true' if the piece was most recently disturbed by the player squishing it
var did_squish := false

## Records that the player did not recently spin or squish the piece
func _refresh_none() -> void:
	did_spin = false
	did_squish = false


## Records that the player recently spun the piece, but did not squish it
##
## Parameters:
## 	'new_squish': 'true' if the piece was most recently disturbed by the player spinning it
func _refresh_spin(new_spin: bool) -> void:
	did_spin = new_spin
	did_squish = false


## Records that the player recently squished the piece, but did not spin it
##
## Parameters:
## 	'new_squish': 'true' if the piece was most recently disturbed by the player squishing it
func _refresh_squish(new_squish: bool) -> void:
	did_squish = new_squish
	did_spin = false


func _on_PieceManager_squish_moved(piece: ActivePiece, _old_pos: Vector2i) -> void:
	_refresh_squish(piece.is_sealed())


func _on_PieceManager_piece_spawned(_piece: ActivePiece) -> void:
	_refresh_none()


func _on_PieceManager_rotated_cw(piece: ActivePiece) -> void:
	# Piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_rotated_ccw(piece: ActivePiece) -> void:
	# Piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_rotated_180(piece: ActivePiece) -> void:
	# Piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_initial_rotated_cw(piece: ActivePiece) -> void:
	# Initial piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_initial_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_initial_rotated_ccw(piece: ActivePiece) -> void:
	# Initial piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_initial_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_initial_rotated_180(piece: ActivePiece) -> void:
	# Initial piece rotation is suppressed, so T-Spins are impossible
	if CurrentLevel.settings.other.suppress_piece_initial_rotation in [
		OtherRules.SuppressPieceRotation.ROTATION_AND_SIGNALS,
		OtherRules.SuppressPieceRotation.ROTATION
	]:
		return
	
	_refresh_spin(piece.is_sealed())


func _on_PieceManager_moved_left(_piece: ActivePiece) -> void:
	_refresh_none()


func _on_PieceManager_moved_right(_piece: ActivePiece) -> void:
	_refresh_none()


func _on_PieceManager_dropped(_piece: ActivePiece) -> void:
	_refresh_none()
