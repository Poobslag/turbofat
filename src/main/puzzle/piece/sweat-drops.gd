extends Particles2D
"""
Emits sweat particles for a piece during a squish move.
"""

# The cell size for the TileMap containing the playfield blocks. This is used to position our globs.
const CELL_SIZE = Vector2(36, 32)

# local coordinates to emit sweat from
var _sweat_positions: Array

# the index of the local coordinate to emit sweat from
var _sweat_position_index := 0

"""
Relocates this Particles2D to a random location.
"""
func relocate_randomly() -> void:
	if _sweat_positions:
		_sweat_position_index = (_sweat_position_index + 1) % _sweat_positions.size()
		var sweat_position: Vector2 = _sweat_positions[_sweat_position_index]
		position = sweat_position


"""
Recalculates the sweat positions based on the current piece.
"""
func _on_PieceManager_tiles_changed(tile_map: PuzzleTileMap) -> void:
	_sweat_positions.clear()
	if tile_map.get_used_cells():
		for used_cell in tile_map.get_used_cells():
			for _i in range(2):
				_sweat_positions.append(Vector2(used_cell.x + randf(), used_cell.y - 3 + randf()) * CELL_SIZE)
		_sweat_positions.shuffle()
		relocate_randomly()
	else:
		emitting = false


func _on_RelocateTimer_timeout() -> void:
	relocate_randomly()
