class_name PieceQueue
extends Node
## Queue of upcoming randomized pieces.
##
## This queue stores the upcoming pieces so they can be displayed, and randomizes them according to some complex rules.
##
## Most Turbo Fat levels use a nine piece bag with two quirks. The first quirk is the bag includes all eight pieces
## plus one 'extra piece'. The second quirk is that the bag is shuffled such that no piece neighbors itself.
##
## These two quirks are necessary for the game to function and be challenging. An intuitive '8 piece bag' with no
## extra pieces makes it too easy to play cleanly. And receiving two of the same piece back to back makes it too hard
## to combo. These two adjustments should hopefully balance out boxes and combos to make them both viable.

## minimum number of next pieces in the queue, before we add more
const MIN_SIZE := 50

const UNLIMITED_PIECES := 999999

## how many pieces are in the 'cheat bag' which generates line pieces
const CHEAT_BAG_SIZE := 9

## queue of upcoming NextPiece instances
var pieces := []

## default pieces to pull from if none are provided by the level
var _default_piece_types := PieceTypes.default_types

var _remaining_piece_count := UNLIMITED_PIECES

var _popped_piece_count := 0

## When line pieces are enabled, they are pulled from a 'cheat bag'.
##
## Imagine a bag with eight blue balls and one red ball. For each opportunity where a line piece could be added to the
## piece queue, you first pull a ball from the bag. If it is red, then you add a line piece, otherwise you don't. Once
## the bag is empty, it is refilled.
##
## These two fields correspond to the number of line pieces and total pieces remaining in the cheat bag.
var _cheat_bag_line_pieces_remaining := 0
var _cheat_bag_pieces_remaining := 0

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	PuzzleState.connect("game_prepared", self, "_on_PuzzleState_game_prepared")
	SystemData.gameplay_settings.connect("line_piece_changed", self, "_on_GameplaySettings_line_piece_changed")
	_fill()


## Clears the pieces and refills the piece queues.
func clear() -> void:
	_popped_piece_count = 0
	if CurrentLevel.settings.finish_condition.type == Milestone.PIECES:
		_remaining_piece_count = CurrentLevel.settings.finish_condition.value
	else:
		_remaining_piece_count = UNLIMITED_PIECES
	pieces.clear()
	_fill()


## Pops the next piece off the queue.
func pop_next_piece() -> NextPiece:
	_popped_piece_count += 1
	var next_piece_type: NextPiece = pieces.pop_front()
	if _remaining_piece_count != UNLIMITED_PIECES:
		_remaining_piece_count -= 1
	_fill()
	return next_piece_type


## Returns a specific piece in the queue.
func get_next_piece(index: int) -> NextPiece:
	return pieces[index]


func shuffled_piece_types() -> Array:
	var result: Array = CurrentLevel.settings.piece_types.types
	if not result:
		result = _default_piece_types
	result = result.duplicate()
	result.shuffle()
	return result


func _apply_piece_limit() -> void:
	if _remaining_piece_count < pieces.size():
		for i in range(_remaining_piece_count, pieces.size()):
			pieces[i] = _new_next_piece(PieceTypes.piece_null)


## Fills the queue with randomized pieces.
##
## The first pieces have some constraints to limit players from having especially lucky or unlucky starts. Later pieces
## have fewer constraints, but still use a bagging algorithm to ensure fairness.
func _fill() -> void:
	_reset_cheat_bag()
	if pieces.empty():
		_fill_initial_pieces()
	_fill_remaining_pieces()
	_apply_piece_limit()


## Initializes an empty queue with a set of starting pieces.
func _fill_initial_pieces() -> void:
	var old_piece_count := pieces.size()
	
	if CurrentLevel.settings.piece_types.types.empty() and CurrentLevel.settings.piece_types.start_types.empty():
		# Default starting pieces:
		# 1. Append three same-size pieces which can't build a cake box; lot, jot, jlt or pqu
		# 2. Append a piece which can't build a snack box or a cake box
		# 3. Append a piece which can build a snack box, but not a cake box
		# 4. Append the remaining three pieces
		# 5. Insert an extra piece in the last 3 positions
		#
		# These are called 'bad starts' since they avoid giving player ideal openings of 'lojpqvut' or 'lqpjutov' where
		# each piece fits with the previous piece.
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
		var bad_start: Array = Utils.rand_value(all_bad_starts)
		for piece_type in bad_start:
			pieces.append(_new_next_piece(piece_type))
		pieces.shuffle()
		
		var _other_piece_types := shuffled_piece_types()
		for piece_type in _other_piece_types:
			var duplicate_piece := false
			if CurrentLevel.settings.piece_types.suppress_repeat_piece:
				for piece in pieces:
					if piece.type == piece_type:
						duplicate_piece = true
						break
			if not duplicate_piece:
				pieces.push_back(_new_next_piece(piece_type))
		
		_insert_annoying_piece(3)
	elif CurrentLevel.settings.piece_types.start_types and CurrentLevel.settings.piece_types.ordered_start:
		# Fixed starting pieces: Append all of the start pieces in order.
		for piece_type in CurrentLevel.settings.piece_types.start_types:
			pieces.append(_new_next_piece(piece_type))
	else:
		# Shuffled starting pieces: Append all of the start pieces in a random order, skipping duplicates.
		var pieces_tmp: Array = CurrentLevel.settings.piece_types.start_types.duplicate()
		pieces_tmp.shuffle()
		for piece_type in pieces_tmp:
			pieces.push_front(_new_next_piece(piece_type))
	
	# insert cheat pieces anywhere (including before the very first piece)
	_maybe_insert_cheat_pieces(old_piece_count)


## Refills the cheat bag with its initial contents; one line piece and several regular pieces.
func _reset_cheat_bag() -> void:
	_cheat_bag_line_pieces_remaining = 1
	_cheat_bag_pieces_remaining = CHEAT_BAG_SIZE


## Inserts line pieces into the queue if certain conditions are met.
##
## Line pieces are only inserted if the player has the line piece cheat enabled. Extra line pieces will not be inserted
## in tutorials, or in levels which already have line pieces.
##
## Parameters:
## 	'min_line_piece_index': The earliest index where a line piece can be inserted. Line pieces can be inserted before
## 		this index, appended to the end of the piece queue, or inserted anywhere in between.
func _maybe_insert_cheat_pieces(min_line_piece_index: int) -> void:
	if not SystemData.gameplay_settings.line_piece:
		# don't add line pieces unless the player has the cheat enabled
		return
	
	if CurrentLevel.settings.other.tutorial:
		# don't add line pieces to tutorials
		return
	
	if PieceTypes.piece_i in CurrentLevel.settings.piece_types.start_types \
			or PieceTypes.piece_i in CurrentLevel.settings.piece_types.types:
		# don't add line pieces to levels which already have them
		return
	
	var piece_index := min_line_piece_index
	while piece_index <= pieces.size():
		if _cheat_bag_pieces_remaining <= 0:
			_reset_cheat_bag()
		
		if _cheat_bag_line_pieces_remaining <= 0:
			# no line pieces remaining in the cheat bag
			pass
		elif piece_index < pieces.size() and pieces[piece_index].type == PieceTypes.piece_i:
			# don't insert a line piece before a line piece
			pass
		elif piece_index - 1 >= 0 and pieces[piece_index - 1].type == PieceTypes.piece_i:
			# don't insert a line piece after a line piece
			pass
		elif randi() % _cheat_bag_pieces_remaining < _cheat_bag_line_pieces_remaining:
			# insert a line piece
			_cheat_bag_line_pieces_remaining -= 1
			pieces.insert(piece_index, _new_next_piece(PieceTypes.piece_i))
		
		_cheat_bag_pieces_remaining -= 1
		piece_index += 1


## Creates a new next piece with the specified type.
func _new_next_piece(type: PieceType) -> NextPiece:
	var next_piece := NextPiece.new()
	next_piece.type = type
	if pieces:
		# if the last piece in the queue has been rotated, we match its orientation.
		next_piece.orientation = pieces.back().orientation
	return next_piece


## Extends a non-empty queue by adding more pieces.
##
## The algorithm puts all 8 piece types into a bag with one extra random piece. It pulls random pieces from the bag,
## but avoids pulling the same piece back to back. With this algorithm you're always able to build four 3x3 boxes, but
## the extra piece acts as an helpful tool for 3x4 boxes and 3x5 boxes, or an annoying deterrent for 3x3 boxes.
func _fill_remaining_pieces() -> void:
	var old_piece_count := pieces.size()
	
	while pieces.size() < MIN_SIZE:
		# fill a bag with one of each piece and one extra; draw them out in a random order
		var new_piece_types := shuffled_piece_types()
		for piece_type in new_piece_types:
			pieces.append(_new_next_piece(piece_type))
		
		if CurrentLevel.settings.piece_types.suppress_repeat_piece and new_piece_types.size() >= 3:
			# for levels with multiple identical pieces in the bag, we shuffle the bag so that those identical pieces
			# aren't back to back
			var min_to_index := pieces.size() - new_piece_types.size()
			var from_index := min_to_index
			while from_index < pieces.size():
				var to_index := from_index
				if pieces[from_index].type == pieces[from_index - 1].type:
					# a piece appears back-to-back; move it to a new position
					to_index = _move_duplicate_piece(from_index, min_to_index)
				if to_index <= from_index:
					# don't advance from_index if it would skip an item in the queue
					from_index += 1
		_insert_annoying_piece(new_piece_types.size())
	
	# insert cheat pieces anywhere, but not before the very first piece -- we already checked if a cheat piece should
	# go there
	_maybe_insert_cheat_pieces(old_piece_count + 1)


## Moves a piece which appears back-to-back in the piece queue.
##
## Parameters:
## 	'from_index': The index of the piece being moved
##
## 	'min_to_index': The earliest position in the queue the piece can be moved to
##
## Returns:
## 	The position the piece was moved to, or 'from_index' if the piece did not move.
func _move_duplicate_piece(from_index: int, min_to_index: int) -> int:
	# remove the piece from the queue
	var duplicate_piece: NextPiece = pieces[from_index]
	pieces.remove(from_index)
	
	# find a new position for it
	var to_index := from_index
	var piece_positions := non_adjacent_indexes(pieces, duplicate_piece.type, min_to_index)
	if piece_positions:
		to_index = Utils.rand_value(piece_positions)
	
	# move the piece to its new place in the queue
	pieces.insert(to_index, duplicate_piece)
	return to_index


## Inserts an extra piece into the queue.
##
## Turbo Fat's pieces fit together too well. We periodically add extra pieces to the queue to ensure the game isn't too
## easy.
##
## Parameters:
## 	'max_pieces_to_right': The maximum number of pieces to the right of the new piece. '0' guarantees the new piece
## 		will be appended to the end of the queue, '8' means it will be mixed in with the last eight pieces.
func _insert_annoying_piece(max_pieces_to_right: int) -> void:
	var new_piece_index := int(rand_range(pieces.size() - max_pieces_to_right + 1, pieces.size() + 1))
	var extra_piece_types: Array = shuffled_piece_types()
	if CurrentLevel.settings.piece_types.suppress_repeat_piece and extra_piece_types.size() >= 3:
		# check the neighboring pieces, and remove those from the pieces we're picking from
		Utils.remove_all(extra_piece_types, pieces[new_piece_index - 1].type)
		if new_piece_index < pieces.size():
			Utils.remove_all(extra_piece_types, pieces[new_piece_index].type)
	
	if extra_piece_types:
		if CurrentLevel.settings.piece_types.suppress_o_piece and extra_piece_types[0] == PieceTypes.piece_o:
			# the O-Block is awful, so it comes 10% less often
			extra_piece_types.shuffle()
		pieces.insert(new_piece_index, _new_next_piece(extra_piece_types[0]))


func _on_Level_settings_changed() -> void:
	clear()


func _on_PuzzleState_game_prepared() -> void:
	clear()


## When the player toggles the line piece cheat, we immediately regenerate the piece queue.
##
## This has the potential for some very silly gameplay where the player repeatedly toggles the cheat on and off to get
## every piece in a particular order.
func _on_GameplaySettings_line_piece_changed(_value: bool) -> void:
	var old_popped_piece_count := _popped_piece_count
	
	clear()
	
	# Reset the piece queue to its previous position. This prevents edge cases such as giving the player extra pieces
	# in levels with limited pieces, or giving the player their initial set of pieces over and over.
	for _i in range(old_popped_piece_count):
		pop_next_piece()


## Returns a list of of positions where a piece can be inserted without being adjacent to another piece of the same
## type.
##
## non_adjacent_indexes(['j', 'o'], 'j')      = [2]
## non_adjacent_indexes(['j', 'o', 't'], 't') = [0, 1]
## non_adjacent_indexes([], 't')              = [0]
## non_adjacent_indexes(['o', 'j', 'o'], 'o') = []
##
## Parameters:
## 	'pieces': An array of NextPiece instances representing pieces in a queue.
##
## 	'piece_type': The type of the piece being inserted.
##
## 	'from_index': The lowest position to check in the piece queue.
static func non_adjacent_indexes(in_pieces: Array, piece_type: PieceType, from_index: int = 0) -> Array:
	var result := []
	for i in range(from_index, in_pieces.size() + 1):
		if (i == 0 or piece_type != in_pieces[i - 1].type) \
				and (i >= in_pieces.size() or piece_type != in_pieces[i].type):
			result.append(i)
	return result
