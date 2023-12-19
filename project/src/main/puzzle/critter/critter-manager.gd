class_name CellCritterManager
extends Node
## Common logic for puzzle critters like moles and sharks who sit on blocks in the playfield.

## Some critters like moles and sharks need to react to the playfield moving after the critter manager. This signal is
## a 1:1 replacement for the Playfield's 'line_inserted' signal which is always emitted after the critter manager
## shifts critters around.
signal line_inserted(y, tiles_key, src_y)

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## key: (Vector2) cell containing a critter
## value: (Node2D) critter at that cell location
var critters_by_cell: Dictionary

var _piece_manager: PieceManager
var _playfield: Playfield

func _ready() -> void:
	_refresh_playfield_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


func get_critter_cells(critter_type) -> Array:
	var result := []
	for cell in critters_by_cell:
		if critters_by_cell[cell] is critter_type:
			result.append(cell)
	return result


func remove_critter(cell: Vector2) -> void:
	critters_by_cell.erase(cell)


func add_critter(cell: Vector2, critter: Node2D) -> void:
	critters_by_cell[cell] = critter
	_refresh_critter_position(cell)


func move_critter(old_cell: Vector2, new_cell: Vector2) -> void:
	add_critter(new_cell, critters_by_cell[old_cell])
	remove_critter(old_cell)


func cell_has_critter(cell: Vector2) -> bool:
	return critters_by_cell.has(cell)


func cell_has_critter_of_type(cell: Vector2, critter_type) -> bool:
	return critters_by_cell.has(cell) and critters_by_cell[cell] is critter_type


## Returns 'true' if the specified cell is non-empty.
func cell_has_block(cell: Vector2) -> bool:
	return _playfield.tile_map.get_cellv(cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a non-empty cell beneath it.
func cell_has_floor(cell: Vector2) -> bool:
	return cell.y == PuzzleTileMap.ROW_COUNT - 1 \
			or _playfield.tile_map.get_cellv(cell + Vector2.DOWN) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell has a pickup.
func cell_has_pickup(cell: Vector2) -> bool:
	return _playfield.pickups.get_pickup_food_type(cell) != TileMap.INVALID_CELL


## Returns 'true' if the specified cell overlaps the currently active piece.
func cell_overlaps_piece(cell: Vector2) -> bool:
	var result := false
	for pos_arr_item_obj in _piece_manager.piece.get_pos_arr():
		if cell == pos_arr_item_obj + _piece_manager.piece.pos:
			result = true
			break
	return result


## Relocates a critter, if they're interrupted but haven't appeared yet.
##
## If the player crushes the critter with their piece when it is hasn't appeared yet, it relocates elsewhere in the
## playfield. This is so that players are not punished unfairly for crushing a critter which they did not see quickly
## enough.
##
## We first search for cells above their current cell, all the way to the top of the playfield. If none are found, we
## search for cells below their current cell, and then we give up.
##
## Parameters:
## 	'old_cell': The critter's previous position.
func vertically_relocate_critter(old_cell: Vector2) -> void:
	var found_new_cell := false
	
	var new_cell := old_cell
	
	if not found_new_cell:
		# search for cells above the critter's current cell
		new_cell = old_cell + Vector2.UP
		while not found_new_cell and new_cell.y > PuzzleTileMap.FIRST_VISIBLE_ROW:
			if cell_has_floor(new_cell) \
					and not cell_has_block(new_cell) \
					and not cell_has_pickup(new_cell) \
					and not cell_has_critter(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.UP
	
	if not found_new_cell:
		# search for cells below the critter's current cell
		new_cell = old_cell + Vector2.DOWN
		while not found_new_cell and new_cell.y < PuzzleTileMap.ROW_COUNT:
			if cell_has_floor(new_cell) \
					and not cell_has_block(new_cell) \
					and not cell_has_pickup(new_cell) \
					and not cell_has_critter(new_cell):
				found_new_cell = true
			else:
				new_cell += Vector2.DOWN
	
	if found_new_cell:
		move_critter(old_cell, new_cell)
	else:
		critters_by_cell[old_cell].poof_and_free()
		remove_critter(old_cell)


## Updates the piece manager with the specified piece type.
##
## check_for_empty_piece() should be called afterwards to cycle to the next piece if the new piece is empty. It is not
## called here to avoid edge cases where we'd cycle prematurely or fire triggers at bad times.
func update_piece_manager_piece(new_type: PieceType, new_pos: Vector2, new_orientation: int) -> void:
	_piece_manager.piece.type = new_type
	_piece_manager.piece.pos = new_pos
	
	# The null piece type only has one orientation. Illegal orientations can cause errors.
	_piece_manager.piece.orientation = new_orientation % _piece_manager.piece.type.pos_arr.size()


## If all blocks were removed from a piece while being moved, we manually apply some steps which usually happen
## automatically such as pausing and running certain triggers. This occurs when sharks eat an entire piece.
func check_for_empty_piece() -> void:
	if _piece_manager.piece.type.empty() and _piece_manager.get_state() == _piece_manager.states.move_piece:
		_playfield.add_misc_delay_frames(PieceSpeeds.current_speed.lock_delay)
		
		# fire 'piece_written' triggers to ensure critters get advanced
		CurrentLevel.settings.triggers.run_triggers(LevelTrigger.PIECE_WRITTEN)
		_piece_manager.set_state(_piece_manager.states.wait_for_playfield)


## Recalculates a critter's position based on their playfield cell.
##
## Parameters:
## 	'cell': The critter's playfield cell
func _refresh_critter_position(cell: Vector2) -> void:
	var critter: Node2D = critters_by_cell[cell]
	critter.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	critter.position += _playfield.tile_map.cell_size * Vector2(0.5, 0.5)
	critter.position *= _playfield.tile_map.scale


## Removes all critters from all playfield cells.
func _clear_critters() -> void:
	for critter in critters_by_cell.values():
		critter.queue_free()
	critters_by_cell.clear()


## Shifts a group of critters up or down.
##
## Parameters:
## 	'bottom_y': The lowest row to shift. All critters at or above this row will be shifted.
##
## 	'direction': The direction to shift the critters, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_y: int, direction: Vector2) -> void:
	# First, erase and store all the old critters which are shifting
	var shifted := {}
	for cell in critters_by_cell.keys():
		var critter: Node2D = critters_by_cell[cell]
		if cell.y > bottom_y:
			# critters below the specified bottom row are left alone
			continue
		# critters above the specified bottom row are shifted
		critter.position += direction * _playfield.tile_map.cell_size * _playfield.tile_map.scale
		if cell.y == PuzzleTileMap.FIRST_VISIBLE_ROW - 1:
			critter.visible = true
		shifted[cell + direction] = critter
		remove_critter(cell)
	
	# Next, write the old critters in their new locations
	for cell in shifted.keys():
		if cell_has_critter(cell):
			# remove any old critters that are in the way
			critters_by_cell[cell].poof_and_free()
		add_critter(cell, shifted[cell])


## Connects piece manager listeners.
func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and piece_manager_path):
		return
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null


## Connects playfield listeners.
func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.disconnect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.disconnect("line_inserted", self, "_on_Playfield_line_inserted")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.connect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.connect("line_inserted", self, "_on_Playfield_line_inserted")


func _on_Playfield_blocks_prepared() -> void:
	_clear_critters()


func _on_Playfield_line_inserted(y: int, tiles_key: String, src_y: int) -> void:
	# raise all critters at or above the specified row
	_shift_rows(y, Vector2.UP)
	
	# Some critters like moles and sharks need to react to the playfield moving after the critter manager. Emit the
	# corresponding 'line_inserted' signal to ensure they react after us.
	emit_signal("line_inserted", y, tiles_key, src_y)


func _on_Playfield_line_deleted(y: int) -> void:
	# don't erase critters; critters can be added during the line clear process, which includes erase/delete events
	
	# drop all critters above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)
	
	# don't refresh the playfield critters when a single line is deleted; wait until all lines are deleted
