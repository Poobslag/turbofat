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

# default pieces to pull from if none are provided by the scenario
var _default_piece_types := PieceTypes.all_types

# piece types to choose from. if empty, reverts to the default 8 types (jlopqtuv)
var _piece_types := []

# pieces to prepend to the piece queue before a game begins. these pieces are shuffled
var _piece_start_types := []

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


func set_piece_types(types: Array) -> void:
	_piece_types = types
	clear()


func set_piece_start_types(types: Array) -> void:
	_piece_start_types = types
	clear()


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
"""
func _fill_initial_pieces() -> void:
	if not _piece_types:
		"""
		Default piece selection:
		1. Three same-size pieces which don't make a cake block; lot, jot, jlt or pqu
		2. A piece which doesn't make a snack block
		3. A piece which does make a snack block
		4. The remaining three pieces get appended to the end
		"""
		var all_bad_starts := [
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_q],
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_v],
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_u],
			
			[PieceTypes.piece_j, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_p],
			[PieceTypes.piece_o, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_v],
			[PieceTypes.piece_t, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_u],
			
			[PieceTypes.piece_j, PieceTypes.piece_l, PieceTypes.piece_t, PieceTypes.piece_v, PieceTypes.piece_p],
			[PieceTypes.piece_j, PieceTypes.piece_l, PieceTypes.piece_t, PieceTypes.piece_v, PieceTypes.piece_q],
			[PieceTypes.piece_j, PieceTypes.piece_l, PieceTypes.piece_t, PieceTypes.piece_v, PieceTypes.piece_u],
			
			[PieceTypes.piece_p, PieceTypes.piece_q, PieceTypes.piece_u, PieceTypes.piece_o, PieceTypes.piece_j],
			[PieceTypes.piece_p, PieceTypes.piece_q, PieceTypes.piece_u, PieceTypes.piece_o, PieceTypes.piece_l],
			[PieceTypes.piece_p, PieceTypes.piece_q, PieceTypes.piece_u, PieceTypes.piece_o, PieceTypes.piece_t],
		]
		_pieces += all_bad_starts[randi() % all_bad_starts.size()]
		_pieces.shuffle()
		
		var _other_pieces := shuffled_piece_types()
		for piece in _other_pieces:
			if not _pieces.has(piece):
				_pieces.push_back(piece)
	
	if _piece_start_types:
		var pieces_tmp := _piece_start_types.duplicate()
		pieces_tmp.shuffle()
		for piece in pieces_tmp:
			if _pieces.empty() or _pieces[0] != piece:
				# avoid prepending duplicate pieces
				_pieces.push_front(piece)


func shuffled_piece_types() -> Array:
	var result := _piece_types
	if not result:
		result = _default_piece_types
	result = result.duplicate()
	result.shuffle()
	return result


"""
Extends a non-empty queue by adding more pieces.

The algorithm puts all 8 piece types into a bag with one extra random piece. It pulls random pieces from the bag, but
avoids pulling the same piece back to back. With this algorithm you're always able to make four 3x3 boxes, but the
extra piece acts as an helpful tool for 3x4 boxes and 3x5 boxes, or an annoying deterrent for 3x3 boxes.
"""
func _fill_remaining_pieces() -> void:
	
	while _pieces.size() < MIN_SIZE:
		# fill a bag with one of each piece and one extra; draw them out in a random order
		var new_pieces := shuffled_piece_types()
		
		# avoid having two of the same piece consecutively, if we have at least 3 pieces to choose from
		if new_pieces[0] == _pieces.back() and new_pieces.size() >= 3:
			new_pieces.pop_front()
			new_pieces.insert(int(rand_range(1, new_pieces.size() + 1)), _pieces.back())
		
		# add one extra piece
		var new_piece_index := int(rand_range(1, new_pieces.size() + 1))
		var extra_piece_types: Array = shuffled_piece_types()
		if extra_piece_types.size() >= 3:
			# check the neighboring pieces, and remove those from the pieces we're picking from
			extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index - 1]))
			if new_piece_index < new_pieces.size():
				extra_piece_types.remove(extra_piece_types.rfind(new_pieces[new_piece_index]))
		if extra_piece_types[0] == PieceTypes.piece_o:
			# the o piece is awful. it doesn't show up as often. it still shows up
			extra_piece_types.shuffle()
			print("that was nice of me. have an %s instead" % extra_piece_types[0].string)
		new_pieces.insert(new_piece_index, extra_piece_types[0])
		
		_pieces += new_pieces
