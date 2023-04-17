class_name Moles
extends Node2D
## Handles moles, puzzle critters which dig up star seeds for the player.
##
## Moles dig for a few turns, and then add a pickup to the playfield. But they can be interrupted if they are crushed,
## or if the player clears the row they are digging.

export (PackedScene) var MoleScene: PackedScene

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## key: (Vector2) cell containing a mole
## value: (Mole) mole at that cell location
var _moles_by_cell: Dictionary

var _piece_manager: PieceManager
var _playfield: Playfield

func _ready() -> void:
	PuzzleState.connect("before_piece_written", self, "_on_PuzzleState_before_piece_written")
	_refresh_playfield_path()
	_refresh_piece_manager_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


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


## Connects piece manager listeners.
func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and piece_manager_path):
		return
	
	if _piece_manager:
		_piece_manager.disconnect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null
	
	if _piece_manager:
		_piece_manager.connect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")


## Adds moles to the playfield.
##
## Details like the number of moles to add, where to add them, how long they stay and what they dig are all specified
## by the config parameter.
##
## Parameters:
## 	'config': rules for how many moles to add, where to add them, how long they stay and what they dig.
func add_moles(config: MoleConfig) -> void:
	var potential_mole_cells := _potential_mole_cells(config)
	potential_mole_cells.shuffle()
	for i in range(min(config.count, potential_mole_cells.size())):
		_add_mole(potential_mole_cells[i], config)


## Returns potential cells to which a mole could be added.
##
## Moles must appear on empty cells without a powerup. Levels may have additional rules as specified in config,
## such as only allowing moles to dig through veggie blocks or in the center 3 columns.
##
## Parameters:
## 	'config': rules for where moles can appear.
func _potential_mole_cells(config: MoleConfig) -> Array:
	var potential_mole_cells := []
	
	# Columns which have a ceiling overhead, for moles with a home of 'surface' or 'hole'
	var ceiling_x_coords := {}
	
	# Columns which have a mole overhead
	var midair_mole_x_coords := {}
	
	for y in range(PuzzleTileMap.FIRST_VISIBLE_ROW, PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var mole_cell := Vector2(x, y)
			
			if _playfield.tile_map.get_cellv(mole_cell) != TileMap.INVALID_CELL:
				ceiling_x_coords[x] = true
				midair_mole_x_coords.erase(x)
			
			if _moles_by_cell.has(mole_cell):
				# don't place a mole beneath a mid-air mole; this can happen during line clears
				midair_mole_x_coords[x] = true
			
			if midair_mole_x_coords.has(x):
				continue
			
			# check if the mole is in an appropriate row
			if config.lines:
				if not int(mole_cell.y) in config.lines:
					continue
			
			# check if the mole is in an appropriate column
			if config.columns:
				if not int(mole_cell.x) in config.columns:
					continue
			
			if _mole_cell_has_floor(mole_cell) \
					and not _mole_cell_has_block(mole_cell) \
					and not _mole_cell_has_pickup(mole_cell) \
					and not _mole_cell_has_mole(mole_cell) \
					and not _mole_cell_overlaps_piece(mole_cell):
				
				# check if the mole is at his 'home terrain'; cakes, holes, etc
				var at_home := true
				match config.home:
					MoleConfig.Home.VEG:
						if not _playfield.tile_map.get_cellv(mole_cell + Vector2.DOWN) == PuzzleTileMap.TILE_VEG:
							at_home = false
					MoleConfig.Home.BOX:
						if not _playfield.tile_map.get_cellv(mole_cell + Vector2.DOWN) == PuzzleTileMap.TILE_BOX:
							at_home = false
					MoleConfig.Home.CAKE:
						if not _playfield.tile_map.is_cake_cell(mole_cell + Vector2.DOWN):
							at_home = false
					MoleConfig.Home.SURFACE:
						if ceiling_x_coords.has(int(mole_cell.x)):
							at_home = false
					MoleConfig.Home.HOLE:
						if not ceiling_x_coords.has(int(mole_cell.x)):
							at_home = false
				if not at_home:
					continue
				
				potential_mole_cells.append(mole_cell)
	return potential_mole_cells


## Returns 'true' if the specified cell has a non-empty cell beneath it.
func _mole_cell_has_floor(mole_cell: Vector2) -> bool:
	return mole_cell.y == PuzzleTileMap.ROW_COUNT - 1 \
			or _playfield.tile_map.get_cellv(mole_cell + Vector2.DOWN) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell is non-empty.
func _mole_cell_has_block(mole_cell: Vector2) -> bool:
	return _playfield.tile_map.get_cellv(mole_cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a pickup.
func _mole_cell_has_pickup(mole_cell: Vector2) -> bool:
	return _playfield.pickups.get_pickup_food_type(mole_cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a mole.
func _mole_cell_has_mole(mole_cell: Vector2) -> bool:
	return _moles_by_cell.has(mole_cell)


## Returns 'true' if the specified cell overlaps the currently active piece.
func _mole_cell_overlaps_piece(mole_cell: Vector2) -> bool:
	var result := false
	for pos_arr_item_obj in _piece_manager.piece.get_pos_arr():
		if mole_cell == pos_arr_item_obj + _piece_manager.piece.pos:
			result = true
			break
	return result


## Adds a mole to the specified cell.
##
## Details like how long they should dig for and what they should dig up are specified by the config parameter.
##
## Parameters:
## 	'config': rules for how long moles should dig for and what they should dig up.
func _add_mole(cell: Vector2, config: MoleConfig) -> void:
	if _moles_by_cell.has(cell):
		return
	
	var mole: Mole = MoleScene.instance()
	mole.z_index = 4
	mole.scale = _playfield.tile_map.scale
	
	_update_mole_position(mole, cell)
	
	mole.append_next_state(Mole.WAITING)
	if config.dig_duration >= 2:
		mole.append_next_state(Mole.DIGGING, config.dig_duration - 1)
	if config.dig_duration >= 1:
		mole.append_next_state(Mole.DIGGING_END)
	match config.reward:
		MoleConfig.Reward.SEED:
			mole.append_next_state(Mole.FOUND_SEED)
		MoleConfig.Reward.STAR:
			mole.append_next_state(Mole.FOUND_STAR)
	
	mole.pop_next_state()
	
	add_child(mole)
	_moles_by_cell[cell] = mole


## Advances all moles by one state.
func advance_moles() -> void:
	for cell in _moles_by_cell.duplicate():
		var mole: Mole = _moles_by_cell[cell]
		var new_state := mole.pop_next_state()
		match new_state:
			Mole.FOUND_SEED:
				_playfield.pickups.set_pickup(cell, Foods.BoxType.BREAD)
			Mole.FOUND_STAR:
				_playfield.pickups.set_pickup(cell, Foods.BoxType.CAKE_JTT)
			Mole.NONE:
				remove_mole(cell)


## Plays a 'poof' animation and queues a mole for deletion.
##
## Parameters:
## 	'cell': A playfield cell containing a mole.
func remove_mole(cell: Vector2) -> void:
	if not _moles_by_cell.has(cell):
		return
	
	var mole: Mole = _moles_by_cell[cell]
	mole.poof_and_free()
	_moles_by_cell.erase(cell)


## Recalculates a mole's position based on their playfield cell.
##
## Parameters:
## 	'mole': The mole whose position should be recalculated
##
## 	'cell': The mole's playfield cell
func _update_mole_position(mole: Mole, cell: Vector2) -> void:
	mole.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	mole.position += _playfield.tile_map.cell_size * Vector2(0.5, 0.5)
	mole.position *= _playfield.tile_map.scale


## Removes all moles from all playfield cells.
func _clear_moles() -> void:
	for mole in get_children():
		mole.queue_free()
	_moles_by_cell.clear()


## Updates the overlapped moles as the player moves their piece.
func _refresh_moles_for_piece() -> void:
	for mole_cell in _moles_by_cell:
		var mole: Mole = _moles_by_cell[mole_cell]
		var piece_overlaps_mole := _mole_cell_overlaps_piece(mole_cell)
		
		if piece_overlaps_mole and not mole.hidden:
			mole.hidden = true
		if not piece_overlaps_mole and mole.hidden:
			mole.hidden = false


## Updates all moles based on the contents of the playfield.
##
## As the player clears lines, moles may disappear if they were digging through those rows.
func _refresh_moles_for_playfield(include_waiting_moles: bool = true) -> void:
	for mole_cell in _moles_by_cell.duplicate():
		var mole: Mole = _moles_by_cell[mole_cell]
		
		if _mole_cell_has_floor(mole_cell) \
				and not _mole_cell_has_block(mole_cell):
			continue
		
		if mole.state == Mole.WAITING or mole.hidden and mole.hidden_mole_state == Mole.WAITING:
			# mole hasn't appeared yet; relocate the mole
			if include_waiting_moles:
				_relocate_mole(mole_cell)
		else:
			# mole was squished; remove the mole
			remove_mole(mole_cell)


## Relocates a mole, if they're interrupted but haven't appeared yet.
##
## If the player crushes the mole with their piece when it is hasn't appeared yet, it relocates elsewhere in the
## playfield. This is so that players are not punished unfairly for crushing a mole which they did not see quickly
## enough.
##
## We first search for cells above their current cell, all the way to the top of the playfield. If none are found, we
## search for cells below their current cell, and then we give up.
##
## Parameters:
## 	'old_cell': The mole's previous position.
func _relocate_mole(old_cell: Vector2) -> void:
	var mole: Mole = _moles_by_cell[old_cell]
	var found_new_cell := false
	
	var new_cell := old_cell
	
	if not found_new_cell:
		# search for cells above the mole's current cell
		new_cell = old_cell + Vector2.UP
		while not found_new_cell and new_cell.y > PuzzleTileMap.FIRST_VISIBLE_ROW:
			if _mole_cell_has_floor(new_cell) \
					and not _mole_cell_has_block(new_cell) \
					and not _mole_cell_has_pickup(new_cell) \
					and not _mole_cell_has_mole(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.UP
	
	if not found_new_cell:
		# search for cells below the mole's current cell
		new_cell = old_cell + Vector2.DOWN
		while not found_new_cell and new_cell.y < PuzzleTileMap.ROW_COUNT:
			if _mole_cell_has_floor(new_cell) \
					and not _mole_cell_has_block(new_cell) \
					and not _mole_cell_has_pickup(new_cell) \
					and not _mole_cell_has_mole(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.DOWN
	
	if found_new_cell:
		_update_mole_position(mole, new_cell)
		_moles_by_cell[new_cell] = _moles_by_cell[old_cell]
		_moles_by_cell.erase(old_cell)
	else:
		remove_mole(old_cell)


## Removes all moles from a playfield row.
func _erase_row(y: int) -> void:
	for x in range(PuzzleTileMap.COL_COUNT):
		remove_mole(Vector2(x, y))


## Shifts a group of moles up or down.
##
## Parameters:
## 	'bottom_y': The lowest row to shift. All moles at or above this row will be shifted.
##
## 	'direction': The direction to shift the moles, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_y: int, direction: Vector2) -> void:
	# First, erase and store all the old moles which are shifting
	var shifted := {}
	for cell in _moles_by_cell.keys():
		if cell.y > bottom_y:
			# moles below the specified bottom row are left alone
			continue
		# moles above the specified bottom row are shifted
		_moles_by_cell[cell].position += direction * _playfield.tile_map.cell_size * _playfield.tile_map.scale
		if cell.y == PuzzleTileMap.FIRST_VISIBLE_ROW - 1:
			_moles_by_cell[cell].visible = true
		shifted[cell + direction] = _moles_by_cell[cell]
		_moles_by_cell.erase(cell)
	
	# Next, write the old moles in their new locations
	for cell in shifted.keys():
		_moles_by_cell[cell] = shifted[cell]


func _on_Playfield_blocks_prepared() -> void:
	_clear_moles()


func _on_PieceManager_piece_disturbed(_piece: ActivePiece) -> void:
	_refresh_moles_for_piece()


func _on_PuzzleState_before_piece_written() -> void:
	_refresh_moles_for_playfield()
	
	# restore any remaining moles which were hidden by the active piece
	for mole_cell in _moles_by_cell:
		_moles_by_cell[mole_cell].hidden = false


func _on_Playfield_line_deleted(y: int) -> void:
	# don't erase moles; moles can be added during the line clear process, which includes erase/delete events
	
	# drop all moles above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)
	
	# don't refresh the playfield moles when a single line is deleted; wait until all lines are deleted


func _on_Playfield_line_erased(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	# don't erase moles; moles can be added during the line clear process, which includes erase/delete events
	
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate moles until all lines are deleted.
		# We still delete moles right away; if the row below a mole is cleared, they disappear even if they land on
		# solid ground.
		_refresh_moles_for_playfield(false)
	else:
		_refresh_moles_for_playfield()


func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	# raise all moles at or above the specified row
	_shift_rows(y, Vector2.UP)
	
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate moles until all lines are deleted.
		pass
	else:
		_refresh_moles_for_playfield()


func _on_Playfield_line_filled(_y: int, _tiles_key: String, _src_y: int) -> void:
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate moles until all lines are deleted.
		pass
	else:
		_refresh_moles_for_playfield()


func _on_Playfield_after_lines_deleted(_lines: Array) -> void:
	_refresh_moles_for_playfield()
