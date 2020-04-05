extends Control
"""
Contains logic for displaying upcoming pieces to the player, organizing and maintaining all of the 'next piece
displays'.
"""

const DISPLAY_COUNT := 9

export (PackedScene) var NextPieceDisplay

# Queue of upcoming randomized pieces. The first few pieces are displayed to the player
var next_pieces := []

# The "next piece displays" which are shown to the user
var _next_piece_displays := []

func _ready() -> void:
	# Ensure pieces are random
	randomize()
	_fill_queue()
	for i in range(DISPLAY_COUNT):
		_add_display(i, 5, 5 + i * (486 / (DISPLAY_COUNT - 1)), 0.5)


"""
Hides all next piece displays. We can't let the player see the upcoming pieces before the game starts.
"""
func hide_pieces() -> void:
	for next_piece_display in _next_piece_displays:
		next_piece_display.hide()


"""
Starts a new game, randomizing the pieces and filling the piece queues.
"""
func start_game() -> void:
	next_pieces.clear()
	_fill_queue()
	
	for next_piece_display in _next_piece_displays:
		next_piece_display.show()


"""
Pops the next piece off the queue.
"""
func pop_piece_type() -> PieceType:
	var next_piece_type = next_pieces.pop_front()
	_fill_queue()
	return next_piece_type


"""
Adds a new 'next piece display'.
"""
func _add_display(piece_index: int, x: float, y: float, scale: float) -> void:
	var new_display = NextPieceDisplay.instance()
	new_display.piece_index = piece_index
	new_display.scale = Vector2(scale, scale)
	new_display.position = Vector2(x, y)
	add_child(new_display)
	_next_piece_displays.append(new_display)


"""
This method fills the queue of upcoming pieces with newly randomized pieces, following a specific algorithm.

During the game, the random algorithm works as follows: All 8 pieces are randomly thrown into a bag with 1 random
piece. They’re shuffled fairly, but you’re guaranteed to never pull the same piece twice-in-a-row. This makes it so
that you're always able to make four simple 3x3 boxes, but sometimes the extra piece is a pain in the ass. This
prevents the game from being too simple.

Initially, the random algorithm works a little differently: The game comes up with the five pieces necessary to make a
small and large box and shuffles them. This undermines the simple strategy of starting every game by making 4 3x3
boxes.
"""
func _fill_queue() -> void:
	if next_pieces.empty():
		# calculate five pieces which can make a 3x3 and either a 3x4 or 3x5
		var all_threes := [
			[PieceTypes.piece_j, PieceTypes.piece_p],
			[PieceTypes.piece_l, PieceTypes.piece_q],
			[PieceTypes.piece_o, PieceTypes.piece_v],
			[PieceTypes.piece_t, PieceTypes.piece_u]
		]
		next_pieces += all_threes[randi() % all_threes.size()]
		if randf() > 0.5:
			var all_quads := [
				[PieceTypes.piece_j, PieceTypes.piece_t, PieceTypes.piece_t],
				[PieceTypes.piece_l, PieceTypes.piece_t, PieceTypes.piece_t],
				[PieceTypes.piece_j, PieceTypes.piece_j, PieceTypes.piece_o],
				[PieceTypes.piece_l, PieceTypes.piece_l, PieceTypes.piece_o],
				[PieceTypes.piece_j, PieceTypes.piece_l, PieceTypes.piece_o]
			]
			next_pieces += all_quads[randi() % all_quads.size()]
		else:
			var all_pentos := [
				[PieceTypes.piece_p, PieceTypes.piece_u, PieceTypes.piece_v],
				[PieceTypes.piece_q, PieceTypes.piece_u, PieceTypes.piece_v],
				[PieceTypes.piece_p, PieceTypes.piece_q, PieceTypes.piece_v]
			]
			next_pieces += all_pentos[randi() % all_pentos.size()]
		
		# shuffle the five pieces until the same piece doesn't appear twice-in-a-row
		for _mercy in range(1000):
			next_pieces.shuffle()
			var no_touching_pieces := true
			for from_index in range(next_pieces.size() - 1):
				if next_pieces[from_index] == next_pieces[from_index + 1]:
					no_touching_pieces = false
			if no_touching_pieces:
				break
	
	while next_pieces.size() < 50:
		# fill a bag with one of each piece and one extra; draw them out in a random order, ensuring we never see two
		# of the same piece in a row
		var new_pieces: Array = PieceTypes.all_types.duplicate()
		new_pieces.shuffle()
		
		# avoid having two of the same piece consecutively
		if new_pieces[0] == next_pieces.back():
			new_pieces.pop_front()
			new_pieces.insert(int(rand_range(1, new_pieces.size() + 1)), next_pieces.back())
		
		# add one extra piece
		var new_piece_index := int(rand_range(1, new_pieces.size() + 1))
		var extra_piece_types: Array = PieceTypes.all_types.duplicate()
		extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index - 1]))
		if new_piece_index < new_pieces.size():
			extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index]))
		new_pieces.insert(new_piece_index, extra_piece_types[randi() % extra_piece_types.size()])
		
		next_pieces += new_pieces
