class_name TechMoveDetector
extends Node
## Detects when the player places a sealed-in piece with a spin move or squish move.

export (NodePath) var piece_manager_path: NodePath

## Cannot statically type as 'PieceManager' because of cyclic reference
onready var _piece_manager: Node = get_node(piece_manager_path)

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


func _on_PieceManager_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_refresh_squish(_piece_manager.piece.is_sealed())


func _on_PieceManager_piece_spawned() -> void:
	_refresh_none()


func _on_PieceManager_rotated_cw() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_rotated_ccw() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_rotated_180() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_initial_rotated_cw() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_initial_rotated_ccw() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_initial_rotated_180() -> void:
	_refresh_spin(_piece_manager.piece.is_sealed())


func _on_PieceManager_moved_left() -> void:
	_refresh_none()


func _on_PieceManager_moved_right() -> void:
	_refresh_none()


func _on_PieceManager_dropped() -> void:
	_refresh_none()
