class_name PieceQueue
extends Node
"""
Queue of upcoming randomized pieces.

This queue stores the upcoming pieces so they can be displayed, and randomizes them according to some complex rules.
"""

# minimum number of next _pieces in the queue, before we add more
const MIN_SIZE := 50

var _pieces := []

# default pieces to pull from if none are provided by the scenario
var _default_piece_types := PieceTypes.all_types

func _init() -> void:
	# Ensure pieces are random
	randomize()


func _ready() -> void:
	Scenario.connect("settings_changed", self, "_on_Scenario_settings_changed")
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
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
"""
func _fill_initial_pieces() -> void:
	if Scenario.settings.piece_types.types.empty():
		"""
		Default piece selection:
		1. Append three same-size pieces which can't build a cake box; lot, jot, jlt or pqu
		2. Append a piece which can't build a snack box or a cake box
		3. Append a piece which can build a snack box, but not a cake box
		4. Append the remaining three pieces
		5. Insert an extra piece in the last 3 positions
		"""
		var all_bad_starts := [
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_q],
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_v],
			[PieceTypes.piece_l, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_p, PieceTypes.piece_u],
			
			[PieceTypes.piece_j, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_p],
			[PieceTypes.piece_j, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_v],
			[PieceTypes.piece_j, PieceTypes.piece_o, PieceTypes.piece_t, PieceTypes.piece_q, PieceTypes.piece_u],
			
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
		
		_insert_annoying_piece(3)
	
	if Scenario.settings.piece_types.start_types:
		var pieces_tmp := Scenario.settings.piece_types.start_types.duplicate()
		pieces_tmp.shuffle()
		for piece in pieces_tmp:
			if _pieces.empty() or _pieces[0] != piece:
				# avoid prepending duplicate pieces
				_pieces.push_front(piece)


func shuffled_piece_types() -> Array:
	var result := Scenario.settings.piece_types.types
	if not result:
		result = _default_piece_types
	result = result.duplicate()
	result.shuffle()
	return result


"""
Extends a non-empty queue by adding more pieces.

The algorithm puts all 8 piece types into a bag with one extra random piece. It pulls random pieces from the bag, but
avoids pulling the same piece back to back. With this algorithm you're always able to build four 3x3 boxes, but the
extra piece acts as an helpful tool for 3x4 boxes and 3x5 boxes, or an annoying deterrent for 3x3 boxes.
"""
func _fill_remaining_pieces() -> void:
	while _pieces.size() < MIN_SIZE:
		# fill a bag with one of each piece and one extra; draw them out in a random order
		var new_pieces := shuffled_piece_types()
		# avoid having two of the same piece consecutively, if we have at least 3 pieces to choose from
		if not _pieces.empty() and _pieces.back() == new_pieces[0] and new_pieces.size() >= 3:
			new_pieces.pop_front()
			new_pieces.insert(int(rand_range(1, new_pieces.size() + 1)), _pieces.back())
		_pieces += new_pieces
		_insert_annoying_piece(new_pieces.size())


"""
Inserts an extra piece into the bag.

Turbo Fat's pieces fit together too well. We periodically add extra pieces to the bag to ensure the game isn't too
easy.

Parameters:
	'max_pieces_to_right': The maximum number of pieces to the right of the new piece. '0' guarantees the new piece
			will be appended to the end of the queue, '8' means it will be mixed in with the last eight pieces.
"""
func _insert_annoying_piece(max_pieces_to_right: int) -> void:
	var new_piece_index := int(rand_range(_pieces.size() - max_pieces_to_right + 1, _pieces.size() + 1))
	var extra_piece_types: Array = shuffled_piece_types()
	if extra_piece_types.size() >= 3:
		# check the neighboring pieces, and remove those from the pieces we're picking from
		extra_piece_types.remove(extra_piece_types.rfind(_pieces[new_piece_index - 1]))
		if new_piece_index < _pieces.size():
			extra_piece_types.remove(extra_piece_types.rfind(_pieces[new_piece_index]))
	if extra_piece_types[0] == PieceTypes.piece_o:
		# the o piece is awful, so it comes 10% less often
		extra_piece_types.shuffle()
	_pieces.insert(new_piece_index, extra_piece_types[0])


func _on_Scenario_settings_changed() -> void:
	clear()


func _on_PuzzleScore_game_prepared() -> void:
	clear()
