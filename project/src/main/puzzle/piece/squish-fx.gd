extends Control
"""
Generates visual and audio effects for a squish move.

Makes the piece shake, sweat, turn white, and plays a sound effect.
"""

onready var _piece_manager: PieceManager = get_parent()

# Squished pieces blink over time. This field is used to calculate the blink amount
var _total_time: float

# How much the piece should flash and shake as it's squished
var _squish_amount: float

# Calculates how much the piece should flash and shake as it's squished
export (Curve) var squish_curve: Curve

func _physics_process(delta: float) -> void:
	_total_time += delta
	_squish_amount = squish_curve.interpolate(_piece_manager.squish_percent())
	
	_handle_shake()
	_handle_flash()
	_handle_sweat()
	_handle_sfx()


"""
Makes the piece shake left and right if a squish move is in progress.
"""
func _handle_shake() -> void:
	if _squish_amount > 0:
		_piece_manager.get_node("TileMap").position.x = _squish_amount * 4 * sin(16 * _total_time * TAU)
	else:
		_piece_manager.get_node("TileMap").position.x = 0


"""
Makes the piece turn white and blink if a squish move is in progress.
"""
func _handle_flash() -> void:
	if _squish_amount > 0:
		_piece_manager.tile_map.whiteness = lerp(0.0, 0.64 + 0.16 * sin(4 * _total_time * TAU), _squish_amount)
	else:
		_piece_manager.tile_map.whiteness = 0


"""
Makes the piece emit sweat particles if a squish move is in progress.
"""
func _handle_sweat() -> void:
	if _squish_amount > 0.1:
		# gradually increase speed of sweat drops
		$SweatDrops.lifetime = lerp(2.5, 1.0, _squish_amount)
		$SweatDrops.emitting = true
	else:
		$SweatDrops.emitting = false


"""
Plays a sound effect if a squish move is in progress.
"""
func _handle_sfx() -> void:
	if _squish_amount > 0.1:
		if not $PresquishSfx.sfx_started:
			$PresquishSfx.start_presquish_sfx()
	else:
		if $PresquishSfx.sfx_started:
			$PresquishSfx.stop_presquish_sfx()


"""
Initialize the squish animation for long squish moves
"""
func _on_PieceManager_squish_moved(piece: ActivePiece, old_pos: Vector2) -> void:
	if piece.pos.y - old_pos.y >= 3:
		var unblocked_blocks: Array = piece.type.pos_arr[piece.orientation].duplicate()
		$SquishMap.start_squish(PieceSpeeds.SQUISH_FRAMES, piece.type.color_arr[piece.orientation][0].y)
		for dy in range(piece.pos.y - old_pos.y):
			var i := 0
			while i < unblocked_blocks.size():
				var target_block_pos: Vector2 = unblocked_blocks[i] + old_pos + Vector2(0, dy)
				if piece.is_cell_blocked(target_block_pos):
					unblocked_blocks.remove(i)
				else:
					i += 1
			$SquishMap.stretch_to(unblocked_blocks, old_pos + Vector2(0, dy))
