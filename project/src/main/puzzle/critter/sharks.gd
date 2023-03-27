class_name Sharks
extends Node2D
## Handles sharks, puzzle critters which eat pieces.
##
## Sharks wait on the playfield until bumped by a piece. Depending on the size of the shark, they may take a small bite
## from the piece, a big bite from the piece, or eat the entire piece.

export (PackedScene) var SharkScene: PackedScene

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## 'true' if the player hard dropped the piece this frame
var _did_hard_drop := false
var _piece_manager: PieceManager
var _playfield: Playfield

## key: (Vector2) cell containing a shark
## value: (Shark) shark at that cell location
var _sharks_by_cell: Dictionary

func _ready() -> void:
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")
	_refresh_playfield_path()
	_refresh_piece_manager_path()


func _physics_process(_delta: float) -> void:
	_did_hard_drop = false


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


## Adds sharks to the playfield.
##
## Details like the number of sharks to add, where to add them, how long they stay and much they eat are all specified
## by the config parameter.
##
## Parameters:
## 	'config': rules for how many sharks to add, where to add them, how long they stay and how much they eat.
func add_sharks(config: SharkConfig) -> void:
	var potential_shark_cells := _potential_shark_cells(config)
	potential_shark_cells.shuffle()
	
	# sharks prioritize the highest cell, so players can make clever plays by shaping pieces at the top and placing
	# them below.
	potential_shark_cells.sort_custom(self, "_compare_by_y_then_random")
	
	for i in range(min(config.count, potential_shark_cells.size())):
		_add_shark(potential_shark_cells[i], config)


## Advances all sharks by one state.
func advance_sharks() -> void:
	for cell in _sharks_by_cell.duplicate():
		var shark: Shark = _sharks_by_cell[cell]
		if not shark.has_next_state():
			# Sharks will not stop dancing just because they exhaust their state queue
			continue
		
		var new_state := shark.pop_next_state()
		match new_state:
			Shark.NONE:
				remove_shark(cell)
	
	_refresh_sharks_for_playfield()


## Plays a 'poof' animation and queues a shark for deletion.
##
## Parameters:
## 	'cell': A playfield cell containing a shark.
func remove_shark(cell: Vector2) -> void:
	if not _sharks_by_cell.has(cell):
		return
	
	var shark: Shark = _sharks_by_cell[cell]
	shark.poof_and_free()
	_sharks_by_cell.erase(cell)


func _compare_by_y_then_random(a: Vector2, b: Vector2) -> bool:
	return b.y > a.y


func _compare_by_y_then_x(a: Vector2, b: Vector2) -> bool:
	if b.y > a.y:
		return true
	if b.y < a.y:
		return false
	return b.x > a.x


## Updates sharks based on the piece moving around.
##
## Moving a piece can cause a shark to eat the piece, or to get squished.
func _refresh_sharks_for_piece() -> void:
	var shark_cells := _sharks_by_cell.keys().duplicate()
	
	## If multiple sharks touch a piece, the highest shark takes precedence
	shark_cells.sort_custom(self, "_compare_by_y_then_x")
	
	for shark_cell in shark_cells:
		var shark: Shark = _sharks_by_cell[shark_cell]
		var piece_overlaps_shark := _shark_cell_overlaps_piece(shark_cell)
		
		if shark.state == Shark.WAITING:
			shark.visible = not piece_overlaps_shark
		
		if _did_hard_drop and piece_overlaps_shark \
				and shark.state in [Shark.DANCING, Shark.DANCING_END, Shark.EATING, Shark.FED]:
			shark.squish()
		
		if shark.state in [Shark.DANCING, Shark.DANCING_END] and piece_overlaps_shark:
			match shark.shark_size:
				SharkConfig.SharkSize.SMALL:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 5)
				SharkConfig.SharkSize.MEDIUM:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 10)
				SharkConfig.SharkSize.LARGE:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 20)
			
			# Assign the color before the piece is eaten. Otherwise if the entire piece is eaten, we won't know which
			# color it was.
			shark.set_eaten_color(0, _piece_manager.piece.type.get_box_type())
			shark.set_eat_duration(PieceSpeeds.current_speed.lock_delay / 60.0)
			
			# Change the piece, removing any eaten cells
			var old_piece_cells := _playfield_piece_cells()
			match shark.shark_size:
				SharkConfig.SharkSize.SMALL:
					shark.set_eat_duration(0.1)
					_nibble_piece(shark_cell)
				SharkConfig.SharkSize.MEDIUM:
					_replace_active_piece_with_domino()
				SharkConfig.SharkSize.LARGE:
					_eat_entire_piece()
			
			# Change the shark, adding any eaten cells
			var new_piece_cells := _playfield_piece_cells()
			shark.set_state(Shark.EATING)
			_feed_shark_cells(shark_cell, old_piece_cells, new_piece_cells)


## Updates a shark's eaten cells based on how a piece changed.
##
## Parameters:
## 	'shark_cell': Vector2 playfield tilemap coordinate containing a shark
##
## 	'old_piece_cells': Vector2 playfield tilemap coordinates which which contained piece cells, before the piece was
## 		eaten
##
## 	'old_piece_cells': Vector2 playfield tilemap coordinates which which contained piece cells, after the piece was
## 		eaten
func _feed_shark_cells(shark_cell: Vector2, old_piece_cells: Array, new_piece_cells: Array) -> void:
	var shark: Shark = _sharks_by_cell[shark_cell]
	
	# update the tileset to match the piece's current tileset, so that veggie pieces appear correctly
	shark.set_puzzle_tile_set_type(_piece_manager.tile_map.puzzle_tile_set_type)
	
	var eaten_piece_cells := Utils.subtract(old_piece_cells, new_piece_cells)
	
	# if the eaten cells are not at the shark's height, we shift them up/down
	if eaten_piece_cells:
		var max_eaten_piece_cells_y: float = eaten_piece_cells[0].y
		for eaten_piece_cell in eaten_piece_cells:
			max_eaten_piece_cells_y = max(max_eaten_piece_cells_y, eaten_piece_cell.y)
		for i in range(eaten_piece_cells.size()):
			eaten_piece_cells[i].y += (shark_cell.y - max_eaten_piece_cells_y)
	
	for eaten_piece_cell in eaten_piece_cells:
		shark.set_eaten_cell(eaten_piece_cell - shark_cell)
	
	_piece_manager.emit_signal("piece_disturbed", _piece_manager.piece)


## Returns:
## 	Vector2 playfield tilemap coordintaes which contain piece cells
func _playfield_piece_cells() -> Array:
	var result := []
	for cell in _piece_manager.piece.get_pos_arr():
		result.append(cell + _piece_manager.piece.pos)
	return result


## Removes a single block from the active piece. This is the effect of a small shark.
##
## Parameters:
## 	'shark_cell': Cell containing a shark, which will be removed from the active piece
func _nibble_piece(shark_cell: Vector2) -> void:
	var old_type := _piece_manager.piece.type
	var old_pos := _piece_manager.piece.pos
	var old_orientation := _piece_manager.piece.orientation

	var new_type := PieceType.new()
	var new_pos := old_pos
	var new_orientation := old_orientation

	new_type.copy_from(old_type)
	
	PieceTypeMutator.new(new_type).remove_cell(new_orientation, shark_cell - new_pos)
	
	_update_piece_manager_piece(new_type, new_pos, new_orientation)


## Reduces the active piece to a domino; a 2-cell piece. This is the effect of a medium shark.
##
## If the active piece contains 3 or fewer cells, then instead of being reduced to a domino, all of its blocks are
## removed instead.
func _replace_active_piece_with_domino() -> void:
	var old_type := _piece_manager.piece.type
	var old_pos := _piece_manager.piece.pos
	var old_orientation := _piece_manager.piece.orientation
	
	# the shark eats the entire piece if there's no place for a domino
	var new_type := PieceTypes.piece_null
	var new_pos := old_pos
	var new_orientation := old_orientation
	
	# Find a position/orientation for a domino. Check the highest, leftmost positions first.
	if _piece_manager.piece.type.size() <= 3:
		# pieces which are smaller than 3 blocks are eaten completely
		pass
	else:
		var pos_arr: Array = _piece_manager.piece.get_pos_arr()
		for pos_arr_item in pos_arr:
			# first, try orienting our domino horizontally
			if pos_arr.has(pos_arr_item + Vector2.RIGHT):
				new_type = _to_domino(old_type)
				new_orientation = 0
				new_pos = old_pos + pos_arr_item + Vector2(0, -1)
				break
			
			# next, try orienting our domino vertically
			if pos_arr.has(pos_arr_item + Vector2.DOWN):
				new_type = _to_domino(old_type)
				new_orientation = 1
				new_pos = old_pos + pos_arr_item
				break
	
	_update_piece_manager_piece(new_type, new_pos, new_orientation)


## Removes all blocks from the active piece. This is the effect of a large shark.
func _eat_entire_piece() -> void:
	var old_pos := _piece_manager.piece.pos
	var old_orientation := _piece_manager.piece.orientation
	
	_update_piece_manager_piece(PieceTypes.piece_null, old_pos, old_orientation)


## Updates the piece manager with the specified piece type, possibly cycling to the next piece.
##
## If all blocks were removed from the specified piece, we cycle to the next piece after a brief pause.
func _update_piece_manager_piece(new_type: PieceType, new_pos: Vector2, new_orientation: int) -> void:
	_piece_manager.piece.type = new_type
	_piece_manager.piece.pos = new_pos
	_piece_manager.piece.orientation = new_orientation
	
	if _piece_manager.piece.type.empty():
		# null piece type only has one orientation
		_piece_manager.piece.orientation = 0
		_playfield.add_misc_delay_frames(PieceSpeeds.current_speed.lock_delay)
		_piece_manager.set_state(_piece_manager.states.wait_for_playfield)


## Returns a new 'domino' piece type which preserves the color of the specified piece.
func _to_domino(piece_type: PieceType) -> PieceType:
	var result := PieceType.new()
	result.copy_from(PieceTypes.piece_domino)
	result.set_box_type(piece_type.get_box_type())
	return result


## Updates all sharks based on the contents of the playfield.
##
## As the player clears lines, sharks may disappear if they were sitting on those rows.
func _refresh_sharks_for_playfield(include_waiting_sharks: bool = true) -> void:
	for shark_cell in _sharks_by_cell.keys().duplicate():
		var shark: Shark = _sharks_by_cell[shark_cell]
		
		if _shark_cell_has_floor(shark_cell) \
				and not _shark_cell_has_block(shark_cell):
			continue
		
		if shark.state == Shark.WAITING:
			# shark hasn't appeared yet; relocate the shark
			if include_waiting_sharks:
				_relocate_shark(shark_cell)
		elif shark.state == Shark.SQUISHED:
			if not _shark_cell_has_floor(shark_cell):
				# shark's floor was removed; remove the shark
				remove_shark(shark_cell)
		else:
			# shark was squished; remove the shark
			remove_shark(shark_cell)


## Relocates a shark, if they're interrupted but haven't appeared yet.
##
## If the player crushes the shark with their piece when it is hasn't appeared yet, it relocates elsewhere in the
## playfield. This is so that players are not punished unfairly for crushing a shark which they did not see quickly
## enough.
##
## We first search for cells above their current cell, all the way to the top of the playfield. If none are found, we
## search for cells below their current cell, and then we give up.
##
## Parameters:
## 	'old_cell': The shark's previous position.
func _relocate_shark(old_cell: Vector2) -> void:
	var shark: Shark = _sharks_by_cell[old_cell]
	var found_new_cell := false
	
	var new_cell := old_cell
	
	if not found_new_cell:
		# search for cells above the shark's current cell
		new_cell = old_cell + Vector2.UP
		while not found_new_cell and new_cell.y > PuzzleTileMap.FIRST_VISIBLE_ROW:
			if _shark_cell_has_floor(new_cell) \
					and not _shark_cell_has_block(new_cell) \
					and not _shark_cell_has_pickup(new_cell) \
					and not _shark_cell_has_shark(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.UP
	
	if not found_new_cell:
		# search for cells below the shark's current cell
		new_cell = old_cell + Vector2.DOWN
		while not found_new_cell and new_cell.y < PuzzleTileMap.ROW_COUNT:
			if _shark_cell_has_floor(new_cell) \
					and not _shark_cell_has_block(new_cell) \
					and not _shark_cell_has_pickup(new_cell) \
					and not _shark_cell_has_shark(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.DOWN
	
	if found_new_cell:
		_update_shark_position(shark, new_cell)
		_sharks_by_cell[new_cell] = _sharks_by_cell[old_cell]
		_sharks_by_cell.erase(old_cell)
	else:
		remove_shark(old_cell)


## Connects piece manager listeners.
func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and piece_manager_path):
		return
	
	if _piece_manager:
		_piece_manager.disconnect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")
		_piece_manager.disconnect("hard_dropped", self, "_on_PieceManager_hard_dropped")
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null
	
	if _piece_manager:
		_piece_manager.connect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")
		_piece_manager.connect("hard_dropped", self, "_on_PieceManager_hard_dropped")


## Recalculates a shark's position based on their playfield cell.
##
## Parameters:
## 	'shark': The shark whose position should be recalculated
##
## 	'cell': The shark's playfield cell
func _update_shark_position(shark: Shark, cell: Vector2) -> void:
	shark.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	shark.position += _playfield.tile_map.cell_size * Vector2(0.5, 0.5)
	shark.position *= _playfield.tile_map.scale


## Removes all sharks from all playfield cells.
func _clear_sharks() -> void:
	for shark in get_children():
		shark.queue_free()
	_sharks_by_cell.clear()


## Connects playfield listeners.
func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.disconnect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.disconnect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.disconnect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.disconnect("line_filled", self, "_on_Playfield_line_filled")
		_playfield.disconnect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.connect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.connect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.connect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.connect("line_filled", self, "_on_Playfield_line_filled")
		_playfield.connect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")


## Returns potential cells to which a shark could be added.
##
## Sharks must appear on empty cells without a powerup. Levels may have additional rules as specified in config,
## such as only allowing moles to dig through veggie blocks or in the center 3 columns.
##
## Parameters:
## 	'config': rules for where sharks can appear.
func _potential_shark_cells(config: SharkConfig) -> Array:
	var potential_shark_cells := []
	
	# Columns which have a ceiling overhead, for sharks with a home of 'surface' or 'hole'
	var ceiling_x_coords := {}
	
	for y in range(PuzzleTileMap.FIRST_VISIBLE_ROW, PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var shark_cell := Vector2(x, y)
			
			if _playfield.tile_map.get_cellv(shark_cell) != TileMap.INVALID_CELL:
				ceiling_x_coords[x] = true
			
			# check if the shark is in an appropriate row
			if config.lines:
				if not int(shark_cell.y) in config.lines:
					continue
			
			# check if the shark is in an appropriate column
			if config.columns:
				if not int(shark_cell.x) in config.columns:
					continue
			
			if _shark_cell_has_floor(shark_cell) \
					and not _shark_cell_has_block(shark_cell) \
					and not _shark_cell_has_pickup(shark_cell) \
					and not _shark_cell_has_shark(shark_cell) \
					and not _shark_cell_overlaps_piece(shark_cell):
				
				# check if the shark is at his 'home terrain'; cakes, holes, etc
				var at_home := true
				match config.home:
					SharkConfig.Home.VEG:
						if not _playfield.tile_map.get_cellv(shark_cell + Vector2.DOWN) == PuzzleTileMap.TILE_VEG:
							at_home = false
					SharkConfig.Home.BOX:
						if not _playfield.tile_map.get_cellv(shark_cell + Vector2.DOWN) == PuzzleTileMap.TILE_BOX:
							at_home = false
					SharkConfig.Home.CAKE:
						if not _playfield.tile_map.is_cake_cell(shark_cell + Vector2.DOWN):
							at_home = false
					SharkConfig.Home.SURFACE:
						if ceiling_x_coords.has(int(shark_cell.x)):
							at_home = false
					SharkConfig.Home.HOLE:
						if not ceiling_x_coords.has(int(shark_cell.x)):
							at_home = false
				if not at_home:
					continue
				
				potential_shark_cells.append(shark_cell)
	return potential_shark_cells


## Returns 'true' if the specified cell has a non-empty cell beneath it.
func _shark_cell_has_floor(shark_cell: Vector2) -> bool:
	return shark_cell.y == PuzzleTileMap.ROW_COUNT - 1 \
			or _playfield.tile_map.get_cellv(shark_cell + Vector2.DOWN) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell is non-empty.
func _shark_cell_has_block(shark_cell: Vector2) -> bool:
	return _playfield.tile_map.get_cellv(shark_cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a pickup.
func _shark_cell_has_pickup(shark_cell: Vector2) -> bool:
	return _playfield.pickups.get_pickup_food_type(shark_cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a shark.
func _shark_cell_has_shark(shark_cell: Vector2) -> bool:
	return _sharks_by_cell.has(shark_cell)


## Returns 'true' if the specified cell overlaps the currently active piece.
func _shark_cell_overlaps_piece(shark_cell: Vector2) -> bool:
	var result := false
	for pos_arr_item_obj in _piece_manager.piece.get_pos_arr():
		if shark_cell == pos_arr_item_obj + _piece_manager.piece.pos:
			result = true
			break
	return result


## Adds a shark to the specified cell.
##
## Details like how long they stay and much they eat are all specified by the config parameter.
##
## Parameters:
## 	'config': rules for how long sharks should stay and much they eat.
func _add_shark(cell: Vector2, config: SharkConfig) -> void:
	if _sharks_by_cell.has(cell):
		return
	
	var shark: Shark = SharkScene.instance()
	shark.z_index = 4
	shark.scale = _playfield.tile_map.scale
	shark.shark_size = config.size
	
	_update_shark_position(shark, cell)
	
	shark.append_next_state(Shark.WAITING)
	if config.patience <= 0:
		# 'waiting' -> 'dancing' forever
		shark.append_next_state(Shark.DANCING)
	else:
		# 'waiting' -> 'dancing' -> 'dancing' -> ... -> 'dancing_end' -> 'none'
		for _i in range(config.patience - 1):
			shark.append_next_state(Shark.DANCING)
		shark.append_next_state(Shark.DANCING_END)
		shark.append_next_state(Shark.NONE)
	
	shark.pop_next_state()
	
	add_child(shark)
	_sharks_by_cell[cell] = shark


## Removes all sharks from a playfield row.
func _erase_row(y: int) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		remove_shark(Vector2(x, y))


## Shifts a group of sharks up or down.
##
## Parameters:
## 	'bottom_y': The lowest row to shift. All sharks at or above this row will be shifted.
##
## 	'direction': The direction to shift the sharks, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_y: int, direction: Vector2) -> void:
	# First, erase and store all the old sharks which are shifting
	var shifted := {}
	for cell in _sharks_by_cell.keys():
		if cell.y > bottom_y:
			# sharks below the specified bottom row are left alone
			continue
		# sharks above the specified bottom row are shifted
		_sharks_by_cell[cell].position += direction * _playfield.tile_map.cell_size * _playfield.tile_map.scale
		if cell.y == PuzzleTileMap.FIRST_VISIBLE_ROW - 1:
			_sharks_by_cell[cell].visible = true
		shifted[cell + direction] = _sharks_by_cell[cell]
		_sharks_by_cell.erase(cell)
	
	# Next, write the old sharks in their new locations
	for cell in shifted.keys():
		_sharks_by_cell[cell] = shifted[cell]


func _on_Playfield_blocks_prepared() -> void:
	_clear_sharks()


func _on_PieceManager_piece_disturbed(_piece: ActivePiece) -> void:
	_refresh_sharks_for_piece()


func _on_PieceManager_hard_dropped(_piece: ActivePiece) -> void:
	_did_hard_drop = true


func _on_PuzzleState_before_piece_written() -> void:
	_refresh_sharks_for_playfield()
	
	for shark_cell in _sharks_by_cell:
		# restore any remaining sharks which were hidden by the active piece
		_sharks_by_cell[shark_cell].visible = true


func _on_Playfield_line_deleted(y: int) -> void:
	# Levels with the 'FloatFall' LineClearType have rows which are deleted, but not erased. Erase any sharks
	_erase_row(y)
	
	# drop all sharks above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)
	
	# don't refresh the playfield sharks when a single line is deleted; wait until all lines are deleted


func _on_Playfield_line_erased(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	_erase_row(y)
	
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate sharks until all lines are deleted.
		# We still delete sharks right away; if the row below a shark is cleared, they disappear even if they land on
		# solid ground.
		_refresh_sharks_for_playfield(false)
	else:
		_refresh_sharks_for_playfield()


func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	# raise all sharks at or above the specified row
	_shift_rows(y, Vector2.UP)
	_refresh_sharks_for_playfield()


func _on_Playfield_line_filled(_y: int, _tiles_key: String, _src_y: int) -> void:
	_refresh_sharks_for_playfield()


func _on_Playfield_after_lines_deleted(_lines: Array) -> void:
	_refresh_sharks_for_playfield()
