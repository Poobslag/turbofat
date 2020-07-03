class_name PieceMover
extends Node
"""
Handles horizontal movement for the player's active piece.
"""

signal initial_das_moved_left
signal initial_das_moved_right
# warning-ignore:unused_signal
signal das_moved_left
# warning-ignore:unused_signal
signal das_moved_right
# warning-ignore:unused_signal
signal moved_left
# warning-ignore:unused_signal
signal moved_right

export (NodePath) var input_path: NodePath

# how many times the piece has moved horizontally this frame
var _horizontal_movement_count := 0

onready var input: PieceInput = get_node(input_path)

func _physics_process(_delta: float) -> void:
	_horizontal_movement_count = 0

# locations the piece will spawn if the player holds left
const SPAWN_LEFT := [
		Vector2(-4, 0), Vector2(-4, -1), Vector2(-3, 0), Vector2(-3, -1),
		Vector2(-2, 0), Vector2(-2, -1), Vector2(-1, 0), Vector2(-1, -1),
		Vector2(0, 0), Vector2(0, -1), Vector2(1, 0), Vector2(1, -1),
	]

# locations the piece will spawn if the player does not hold left or right
const SPAWN_CENTER := [
		Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0),
		Vector2(-1, -1), Vector2(1, 0), Vector2(1, -1),
	]

# locations the piece will spawn if the player holds right
const SPAWN_RIGHT := [
		Vector2(4, 0), Vector2(4, -1), Vector2(3, 0), Vector2(3, -1),
		Vector2(2, 0), Vector2(2, -1), Vector2(1, 0), Vector2(1, -1),
		Vector2(0, 0), Vector2(0, -1), Vector2(-1, 0), Vector2(-1, -1),
	]

func apply_initial_move_input(piece: ActivePiece) -> void:
	var initial_das_dir := 0
	if input.is_left_das_active():
		input.set_left_input_as_handled()
		initial_das_dir -= 1
	if input.is_right_das_active():
		input.set_right_input_as_handled()
		initial_das_dir += 1
	
	if initial_das_dir == -1:
		# player is holding left; start piece on the left side
		var old_pos := piece.pos
		piece.reset_target()
		piece.kick_piece(SPAWN_LEFT)
		piece.move_to_target()
		if old_pos != piece.pos:
			emit_signal("initial_das_moved_left")
	elif initial_das_dir == 0:
		piece.reset_target()
		piece.kick_piece(SPAWN_CENTER)
		piece.move_to_target()
	elif initial_das_dir == 1:
		# player is holding right; start piece on the right side
		var old_pos := piece.pos
		piece.reset_target()
		piece.kick_piece(SPAWN_RIGHT)
		piece.move_to_target()
		if old_pos != piece.pos:
			emit_signal("initial_das_moved_right")


func apply_move_input(piece: ActivePiece) -> void:
	if not input.is_left_pressed() and not input.is_right_pressed():
		return
	
	piece.reset_target()
	if input.is_left_just_pressed() or input.is_left_das_active():
		piece.target_pos.x -= 1
	
	if input.is_right_just_pressed() or input.is_right_das_active():
		piece.target_pos.x += 1
	
	if piece.target_pos.x != piece.pos.x:
		var movement_signal: String
		if piece.target_pos.x > piece.pos.x:
			if input.is_right_das_active():
				movement_signal = "das_moved_right"
			else:
				movement_signal = "moved_right"
		elif piece.target_pos.x < piece.pos.x:
			if input.is_left_das_active():
				movement_signal = "das_moved_left"
			else:
				movement_signal = "moved_left"
		
		if piece.can_move_to_target():
			piece.move_to_target()
			_horizontal_movement_count += 1
			emit_signal(movement_signal)
		
		# To prevent pieces from slipping past nooks before DAS, we automatically trigger DAS if you're pushing a
		# piece towards an obstruction. We even trigger DAS if the piece already moved successfully.
		#
		# Otherwise, there are some unusual scenarios where, for example, 'O' pieces in a 3-column well will get
		# instant DAS to the right (where they're blocked) but not to the left (where they can move)
		if input.is_left_pressed() and not piece.can_move_to(piece.pos + Vector2.LEFT, piece.orientation):
			input.set_left_das_active()
		if input.is_right_pressed() and not piece.can_move_to(piece.pos + Vector2.RIGHT, piece.orientation):
			input.set_right_das_active()


"""
Move piece once per frame to allow pieces to slide into nooks during 20G.
"""
func attempt_mid_drop_movement(piece: ActivePiece) -> void:
	if _horizontal_movement_count == 0:
		apply_move_input(piece)
