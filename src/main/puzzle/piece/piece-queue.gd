class_name PieceQueue
"""
Queue of upcoming randomized pieces.

This queue stores the upcoming pieces so they can be displayed, and randomizes them according to some complex rules.
"""

# minimum number of next _pieces in the queue, before we add more
const MIN_SIZE := 50

"""
Initializes the queue with a set of starting pieces.

The algorithm calculates five pieces which make a small and large box and shuffles them. This undermines the strategy
of beginning every game with 3x3 boxes, and mitigates the variance in starting positions.
"""
var _pieces := []

func _init() -> void:
	# Ensure pieces are random
	randomize()
	_fill()


"""
Clears the pieces and refills the piece queues.
"""
func clear() -> void:
	_pieces.clear()
	_fill()


"""
Pops the next piece off the queue.
"""
func pop_next_piece() -> PieceType:
	var next_piece_type: PieceType = _pieces.pop_front()
	_fill()
	return next_piece_type


"""
Returns a specific piece in the queue.
"""
func get_next_piece(index: int) -> PieceType:
	return _pieces[index]


"""
Fills the queue with randomized pieces.

The first pieces have some constraints to limit players from having especially lucky or unlucky starts. Later pieces
have fewer constraints, but still use a bagging algorithm to ensure fairness.
"""
func _fill() -> void:
	if _pieces.empty():
		_fill_initial_pieces()
	_fill_remaining_pieces()


"""
Initializes an empty queue with a set of starting pieces.

The algorithm calculates five pieces which make a small and large box and shuffles them. This undermines the strategy
of beginning every game with 3x3 boxes, and mitigates the variance in starting positions.
"""
func _fill_initial_pieces() -> void:
	# calculate five _pieces which can make a 3x3 and either a 3x4 or 3x5
	var all_threes := [
		[PieceTypes.piece_j, PieceTypes.piece_p],
		[PieceTypes.piece_l, PieceTypes.piece_q],
		[PieceTypes.piece_o, PieceTypes.piece_v],
		[PieceTypes.piece_t, PieceTypes.piece_u]
	]
	_pieces += all_threes[randi() % all_threes.size()]
	if randf() > 0.5:
		var all_quads := [
			[PieceTypes.piece_j, PieceTypes.piece_t, PieceTypes.piece_t],
			[PieceTypes.piece_l, PieceTypes.piece_t, PieceTypes.piece_t],
			[PieceTypes.piece_j, PieceTypes.piece_j, PieceTypes.piece_o],
			[PieceTypes.piece_l, PieceTypes.piece_l, PieceTypes.piece_o],
			[PieceTypes.piece_j, PieceTypes.piece_l, PieceTypes.piece_o]
		]
		_pieces += all_quads[randi() % all_quads.size()]
	else:
		var all_pentos := [
			[PieceTypes.piece_p, PieceTypes.piece_u, PieceTypes.piece_v],
			[PieceTypes.piece_q, PieceTypes.piece_u, PieceTypes.piece_v],
			[PieceTypes.piece_p, PieceTypes.piece_q, PieceTypes.piece_v]
		]
		_pieces += all_pentos[randi() % all_pentos.size()]
	
	# shuffle the five pieces, ensuring no pieces appear back to back
	for _mercy in range(1000):
		_pieces.shuffle()
		var no_touching_pieces := true
		for from_index in range(_pieces.size() - 1):
			if _pieces[from_index] == _pieces[from_index + 1]:
				no_touching_pieces = false
		if no_touching_pieces:
			break


"""
Extends a non-empty queue by adding more pieces.

The algorithm puts all 8 piece types into a bag with one extra random piece. It pulls random pieces from the bag, but
avoids pulling the same piece back to back. With this algorithm you're always able to make four 3x3 boxes, but the
extra piece acts as an helpful tool for 3x4 boxes and 3x5 boxes, or an annoying deterrent for 3x3 boxes.
"""
func _fill_remaining_pieces() -> void:
	while _pieces.size() < MIN_SIZE:
		# fill a bag with one of each piece and one extra; draw them out in a random order
		var new_pieces := PieceTypes.all_types.duplicate()
		new_pieces.shuffle()
		
		# avoid having two of the same piece consecutively
		if new_pieces[0] == _pieces.back():
			new_pieces.pop_front()
			new_pieces.insert(int(rand_range(1, new_pieces.size() + 1)), _pieces.back())
		
		# add one extra piece
		var new_piece_index := int(rand_range(1, new_pieces.size() + 1))
		var extra_piece_types: Array = PieceTypes.all_types.duplicate()
		extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index - 1]))
		if new_piece_index < new_pieces.size():
			extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index]))
		new_pieces.insert(new_piece_index, extra_piece_types[randi() % extra_piece_types.size()])
		
		_pieces += new_pieces
