extends Node
## Handles gravity, hard drops, and soft drops for the player's active piece.

## Emitted when the hard drop destination for the current piece changes. Used for drawing the ghost piece.
signal hard_drop_target_pos_changed(piece, hard_drop_target_pos)

signal soft_dropped # emitted when the player presses the soft drop key
signal hard_dropped # emitted when the player presses the hard drop key
signal dropped # emitted when the piece falls as a result of a soft drop, hard drop, or gravity

export (NodePath) var input_path: NodePath
export (NodePath) var piece_mover_path: NodePath

## 'true' if the player hard dropped the piece this frame
var did_hard_drop: bool

## The hard drop destination for the current piece. Used for drawing the ghost piece.
var hard_drop_target_pos: Vector2

onready var input: PieceInput = get_node(input_path)
onready var piece_mover: PieceMover = get_node(piece_mover_path)

func _physics_process(_delta: float) -> void:
	did_hard_drop = false


## Recalculates the hard drop destination for the current piece.
func calculate_hard_drop_target(piece: ActivePiece) -> void:
	piece.reset_target()
	while piece.can_move_to(piece.target_pos + Vector2(0, 1), piece.orientation):
		piece.target_pos.y += 1
	hard_drop_target_pos = piece.target_pos
	emit_signal("hard_drop_target_pos_changed", piece, hard_drop_target_pos)


func apply_hard_drop_input(piece: ActivePiece) -> void:
	if not input.is_hard_drop_just_pressed() and not input.is_hard_drop_das_active():
		return
	
	# recalculate hard drop target to avoid bugs when rotating/dropping simultaneously
	calculate_hard_drop_target(piece)
	
	# move and lock piece
	var pos_changed := piece.pos != hard_drop_target_pos
	piece.pos = hard_drop_target_pos
	piece.lock = PieceSpeeds.current_speed.lock_delay
	if pos_changed:
		emit_signal("hard_dropped", piece)
		emit_signal("dropped", piece)
	did_hard_drop = true


## Increments the piece's gravity. A piece will fall once its accumulated gravity exceeds a certain threshold.
func apply_gravity(piece: ActivePiece) -> void:
	if piece.remaining_post_squish_frames > 0:
		piece.remaining_post_squish_frames -= 1
		piece_mover.attempt_mid_drop_movement(piece)
	else:
		var current_gravity: int = PieceSpeeds.current_speed.gravity
		if CurrentLevel.is_piece_speed_cheat_enabled():
			current_gravity *= SystemData.gameplay_settings.get_gravity_factor()
		
		if input.is_soft_drop_pressed():
			# soft drop
			piece.gravity += int(max(PieceSpeeds.DROP_G, current_gravity))
		else:
			piece.gravity += current_gravity
		
		var pos_changed := false
		while piece.gravity >= PieceSpeeds.G:
			piece.gravity -= PieceSpeeds.G
			piece.reset_target()
			piece.target_pos.y = piece.pos.y + 1
			if piece.can_move_to_target():
				pos_changed = true
				piece.move_to_target()
			else:
				break
			
			piece_mover.attempt_mid_drop_movement(piece)
		
		if input.is_soft_drop_pressed() and pos_changed:
			emit_signal("soft_dropped", piece)
		if pos_changed:
			emit_signal("dropped", piece)


## Squish moving pauses gravity for a moment.
##
## This allows players to squish and slide a piece before it drops, even at 20G.
func _on_Squisher_squish_moved(_piece: ActivePiece, _old_pos: Vector2) -> void:
	_piece.remaining_post_squish_frames = PieceSpeeds.POST_SQUISH_FRAMES


func _on_PieceManager_piece_disturbed(piece: ActivePiece) -> void:
	# recalculate hard drop target to draw ghost piece
	calculate_hard_drop_target(piece)


func _on_PieceManager_playfield_disturbed(piece: ActivePiece) -> void:
	# recalculate hard drop target to draw ghost piece
	calculate_hard_drop_target(piece)
