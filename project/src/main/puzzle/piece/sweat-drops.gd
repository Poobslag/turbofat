extends Particles2D
## Emits sweat particles for a piece during a squish move.

## local coordinates to emit sweat from
var _sweat_positions: Array

## index of the local coordinate to emit sweat from
var _sweat_position_index := 0

## Relocates this Particles2D to a random location.
func _relocate_randomly() -> void:
	if _sweat_positions:
		_sweat_position_index = (_sweat_position_index + 1) % _sweat_positions.size()
		var sweat_position: Vector2 = _sweat_positions[_sweat_position_index]
		position = sweat_position


## Recalculates the sweat positions based on the current piece.
func _on_PieceManager_tiles_changed(tile_map: PuzzleTileMap) -> void:
	_sweat_positions.clear()
	if tile_map.get_used_cells():
		for used_cell in tile_map.get_used_cells():
			for _i in range(2):
				_sweat_positions.append(tile_map.somewhere_near_cell(used_cell + Vector2(0, -3)))
		_sweat_positions.shuffle()
		_relocate_randomly()
	else:
		emitting = false


func _on_RelocateTimer_timeout() -> void:
	_relocate_randomly()
