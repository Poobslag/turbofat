extends Control
"""
Generates visual and audio effects for a squish move.

Makes the piece shake, sweat, turn white, and plays a sound effect.
"""

# Squished pieces blink over time. This field is used to calculate the blink amount
var _total_time: float

# How much the piece should flash and shake as it's squished
var _squish_amount: float

# Calculates how much the piece should flash and shake as it's squished
export (Curve) var squish_curve: Curve

onready var _piece_manager: PieceManager = get_parent()
onready var _sweat_drops: Particles2D = $SweatDrops
onready var _presquish_sfx: PresquishSfx = $PresquishSfx
onready var _squish_map: SquishMap = $SquishMap

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	_prepare_tileset()


func _process(_delta: float) -> void:
	if _squish_map.squish_seconds_remaining > 0:
		_squish_map.show()
		_piece_manager.tile_map.hide()
		
		# if the player continues to move the piece, we keep stretching to its new location
		_squish_map.stretch_to(_piece_manager.piece.get_pos_arr(), _piece_manager.piece.pos)
	else:
		_squish_map.hide()
		_piece_manager.tile_map.show()


func _physics_process(delta: float) -> void:
	_total_time += delta
	_squish_amount = squish_curve.interpolate(_piece_manager.squish_percent())
	
	_handle_shake()
	_handle_flash()
	_handle_sweat()
	_handle_sfx()


func _prepare_tileset() -> void:
	_squish_map.puzzle_tile_set_type = CurrentLevel.settings.other.tile_set


"""
Makes the piece shake left and right if a squish move is in progress.
"""
func _handle_shake() -> void:
	if _squish_amount > 0:
		_piece_manager.tile_map.position.x = _squish_amount * 4 * sin(16 * _total_time * TAU)
	else:
		_piece_manager.tile_map.position.x = 0


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
		_sweat_drops.lifetime = lerp(2.5, 1.0, _squish_amount)
		_sweat_drops.emitting = true
	else:
		_sweat_drops.emitting = false


"""
Plays a sound effect if a squish move is in progress.
"""
func _handle_sfx() -> void:
	if _squish_amount > 0.1:
		if not _presquish_sfx.sfx_started:
			_presquish_sfx.start_presquish_sfx()
	else:
		if _presquish_sfx.sfx_started:
			_presquish_sfx.stop_presquish_sfx()


"""
Initialize the squish animation for long squish moves
"""
func _on_PieceManager_squish_moved(piece: ActivePiece, old_pos: Vector2) -> void:
	if piece.pos.y - old_pos.y >= 3:
		var unblocked_blocks: Array = piece.type.pos_arr[piece.orientation].duplicate()
		_squish_map.start_squish(PieceSpeeds.POST_SQUISH_FRAMES, piece.type.color_arr[piece.orientation][0].y)
		for dy in range(piece.pos.y - old_pos.y):
			var i := 0
			while i < unblocked_blocks.size():
				var target_block_pos: Vector2 = unblocked_blocks[i] + old_pos + Vector2(0, dy)
				if piece.is_cell_blocked(target_block_pos):
					unblocked_blocks.remove(i)
				else:
					i += 1
			_squish_map.stretch_to(unblocked_blocks, old_pos + Vector2(0, dy))


func _on_Level_settings_changed() -> void:
	_prepare_tileset()
