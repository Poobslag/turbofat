class_name Sharks
extends Node2D
## Handles sharks, puzzle critters which eat pieces.
##
## Sharks wait on the playfield until bumped by a piece. Depending on the size of the shark, they may take a small bite
## from the piece, a big bite from the piece, or eat the entire piece.

export (PackedScene) var SharkScene: PackedScene
export (NodePath) var critter_manager_path: NodePath

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## Queue of calls to defer until after line clears are finished
var _call_queue: CallQueue = CallQueue.new()

## 'true' if the player hard dropped the piece this frame
var _did_hard_drop := false
var _piece_manager: PieceManager
var _playfield: Playfield

## node which contains all of the child shark nodes
onready var _shark_holder := $SharkHolder
onready var _critter_manager: CellCritterManager = get_node(critter_manager_path)

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
	if _playfield.is_clearing_lines():
		# We don't add sharks during line clear events -- the playfield
		_call_queue.defer(self, "_inner_add_sharks", [config])
	else:
		# If sharks are being added as a part of line clears, we wait to add sharks until all lines are deleted.
		_inner_add_sharks(config)


## Plays a 'poof' animation and queues a shark for deletion.
##
## Parameters:
## 	'cell': A playfield cell containing a shark.
func remove_shark(cell: Vector2) -> void:
	var shark: Shark = _critter_manager.critters_by_cell[cell]
	shark.poof_and_free()
	_critter_manager.remove_critter(cell)


## Advances all sharks by one state.
func advance_sharks() -> void:
	if _playfield.is_clearing_lines():
		_call_queue.defer(self, "_inner_advance_sharks", [])
	else:
		# If sharks are being advanced as a part of line clears, we wait to advance sharks until all lines are deleted.
		_inner_advance_sharks()


## Adds sharks to the playfield.
##
## Details like the number of sharks to add, where to add them, how long they stay and much they eat are all specified
## by the config parameter.
##
## Parameters:
## 	'config': rules for how many sharks to add, where to add them, how long they stay and how much they eat.
func _inner_add_sharks(config: SharkConfig) -> void:
	var potential_shark_cells := _potential_shark_cells(config)
	potential_shark_cells.shuffle()
	
	# sharks prioritize the highest cell, so players can make clever plays by shaping pieces at the top and placing
	# them below.
	potential_shark_cells.sort_custom(self, "_compare_by_y_then_random")
	
	for i in range(min(config.count, potential_shark_cells.size())):
		_add_shark(potential_shark_cells[i], config)


## Advances all sharks by one state.
func _inner_advance_sharks() -> void:
	for cell in _critter_manager.get_critter_cells(Shark):
		var shark: Shark = _critter_manager.critters_by_cell[cell]
		if not shark.has_next_state():
			# Sharks will not stop dancing just because they exhaust their state queue
			continue
		
		var new_state := shark.pop_next_state()
		match new_state:
			Shark.NONE:
				remove_shark(cell)
	
	_refresh_sharks_for_playfield()


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
	var shark_cells := _critter_manager.get_critter_cells(Shark)
	
	## If multiple sharks touch a piece, the highest shark takes precedence
	shark_cells.sort_custom(self, "_compare_by_y_then_x")
	
	for shark_cell in shark_cells:
		if not _critter_manager.cell_has_critter_of_type(shark_cell, Shark):
			# this shark was removed as a result of another shark eating
			continue
		
		var shark: Shark = _critter_manager.critters_by_cell[shark_cell]
		var piece_overlaps_shark: bool = _critter_manager.cell_overlaps_piece(shark_cell)
		
		if shark.state == Shark.WAITING:
			shark.visible = not piece_overlaps_shark
		else:
			shark.visible = true
		
		if _did_hard_drop and piece_overlaps_shark \
				and shark.state in [Shark.DANCING, Shark.DANCING_END, Shark.EATING, Shark.FED]:
			shark.squish()
		
		if shark.state in [Shark.DANCING, Shark.DANCING_END] and piece_overlaps_shark:
			match shark.shark_size:
				SharkConfig.SharkSize.SMALL:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 10)
				SharkConfig.SharkSize.MEDIUM:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 20)
				SharkConfig.SharkSize.LARGE:
					PuzzleState.add_unusual_cell_score(shark_cell + Vector2.UP, 50)
			
			# Assign the color before the piece is eaten. Otherwise if the entire piece is eaten, we won't know which
			# color it was.
			shark.set_eaten_color(0, _piece_manager.piece.type.get_box_type())
			
			# Assign the eat duration before the piece is eaten. Otherwise the wrong SFX will play.
			match shark.shark_size:
				SharkConfig.SharkSize.SMALL:
					shark.set_eat_duration(0.1)
				_:
					shark.set_eat_duration(PieceSpeeds.current_speed.lock_delay / 60.0)
			
			var old_piece_cells := _playfield_piece_cells()
			
			# Change the piece, removing any eaten cells
			match shark.shark_size:
				SharkConfig.SharkSize.SMALL:
					_nibble_piece(shark_cell)
				SharkConfig.SharkSize.MEDIUM:
					_replace_active_piece_with_domino()
				SharkConfig.SharkSize.LARGE:
					_eat_entire_piece()
			var new_piece_cells := _playfield_piece_cells()
			
			# Add any eaten cells to the shark
			_feed_shark_cells(shark_cell, old_piece_cells, new_piece_cells)
			
			# Change the shark, setting them into the 'eating' state
			shark.eat()


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
	var shark: Shark = _critter_manager.critters_by_cell[shark_cell]
	
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
## 	Vector2 playfield tilemap coordinates which contain piece cells
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
				new_pos = old_pos + pos_arr_item + Vector2.UP
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
		
		# fire 'piece_written' triggers to ensure sharks get advanced
		CurrentLevel.settings.triggers.run_triggers(LevelTrigger.PIECE_WRITTEN)
		_piece_manager.set_state(_piece_manager.states.wait_for_playfield)


## Returns a new 'domino' piece type which preserves the color of the specified piece.
func _to_domino(piece_type: PieceType) -> PieceType:
	var result := PieceType.new()
	result.copy_from(PieceTypes.piece_domino)
	result.set_box_type(piece_type.get_box_type())
	
	# We update the piece string so that tech moves like 'T-spin' reflect the original piece.
	result.string = piece_type.string
	
	return result


## Updates all sharks based on the contents of the playfield.
##
## As the player clears lines, sharks may disappear if they were sitting on those rows.
func _refresh_sharks_for_playfield(include_waiting_sharks: bool = true) -> void:
	for shark_cell in _critter_manager.get_critter_cells(Shark):
		var shark: Shark = _critter_manager.critters_by_cell[shark_cell]
		
		if _critter_manager.cell_has_floor(shark_cell) \
				and not _critter_manager.cell_has_block(shark_cell):
			continue
		
		shark.visible = true
		
		if shark.state == Shark.WAITING:
			# shark hasn't appeared yet; relocate the shark
			if include_waiting_sharks:
				_critter_manager.vertically_relocate_critter(shark_cell)
		elif shark.state == Shark.SQUISHED:
			if not _critter_manager.cell_has_floor(shark_cell):
				# shark's floor was removed; remove the shark
				remove_shark(shark_cell)
		else:
			# shark was squished; remove the shark
			remove_shark(shark_cell)


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


## Connects playfield listeners.
func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.disconnect("line_filled", self, "_on_Playfield_line_filled")
		_playfield.disconnect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.connect("line_filled", self, "_on_Playfield_line_filled")
		_playfield.connect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")


## Returns potential cells to which a shark could be added.
##
## Sharks must appear on empty cells without a powerup. Levels may have additional rules as specified in config,
## such as only allowing sharks to dig through veggie blocks or in the center 3 columns.
##
## Parameters:
## 	'config': rules for where sharks can appear.
func _potential_shark_cells(config: SharkConfig) -> Array:
	var potential_shark_cells := []
	
	# Columns which have a ceiling overhead, for sharks with a home of 'surface' or 'hole'
	var ceiling_x_coords := {}
	
	# Columns which have a shark overhead
	var midair_critter_x_coords := {}
	
	for y in range(PuzzleTileMap.FIRST_VISIBLE_ROW, PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var shark_cell := Vector2(x, y)
			
			if _playfield.tile_map.get_cellv(shark_cell) != TileMap.INVALID_CELL:
				ceiling_x_coords[x] = true
				midair_critter_x_coords.erase(x)
			
			if _critter_manager.cell_has_critter(shark_cell):
				# don't place a shark beneath a mid-air shark; this can happen during line clears
				midair_critter_x_coords[x] = true
			
			if midair_critter_x_coords.has(x):
				continue
			
			# check if the shark is in an appropriate row
			if config.lines:
				if not int(shark_cell.y) in config.lines:
					continue
			
			# check if the shark is in an appropriate column
			if config.columns:
				if not int(shark_cell.x) in config.columns:
					continue
			
			if _critter_manager.cell_has_floor(shark_cell) \
					and not _critter_manager.cell_has_block(shark_cell) \
					and not _critter_manager.cell_has_pickup(shark_cell) \
					and not _critter_manager.cell_has_critter(shark_cell) \
					and not _critter_manager.cell_overlaps_piece(shark_cell):
				
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


## Adds a shark to the specified cell.
##
## Details like how long they stay and much they eat are all specified by the config parameter.
##
## Parameters:
## 	'config': rules for how long sharks should stay and much they eat.
func _add_shark(cell: Vector2, config: SharkConfig) -> void:
	if _critter_manager.cell_has_critter(cell):
		return
	
	var shark: Shark = SharkScene.instance()
	shark.z_index = 4
	shark.scale = _playfield.tile_map.scale
	shark.shark_size = config.size
	
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
	
	_shark_holder.add_child(shark)
	_critter_manager.add_critter(cell, shark)


func _on_PieceManager_piece_disturbed(_piece: ActivePiece) -> void:
	_refresh_sharks_for_piece()


func _on_PieceManager_hard_dropped(_piece: ActivePiece) -> void:
	_did_hard_drop = true


func _on_PuzzleState_before_piece_written() -> void:
	_refresh_sharks_for_playfield()
	
	for shark_cell in _critter_manager.get_critter_cells(Shark):
		# restore any remaining sharks which were hidden by the active piece
		_critter_manager.critters_by_cell[shark_cell].visible = true


func _on_Playfield_line_erased(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	# don't erase sharks; sharks can be added during the line clear process, which includes erase/delete events
	
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate sharks until all lines are deleted.
		# We still delete sharks right away; if the row below a shark is cleared, they disappear even if they land on
		# solid ground.
		_refresh_sharks_for_playfield(false)
	else:
		_refresh_sharks_for_playfield()


func _on_CritterManager_line_inserted(_y: int, _tiles_key: String, _src_y: int) -> void:
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate sharks until all lines are deleted.
		pass
	else:
		_refresh_sharks_for_playfield()


func _on_Playfield_line_filled(_y: int, _tiles_key: String, _src_y: int) -> void:
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate sharks until all lines are deleted.
		pass
	else:
		_refresh_sharks_for_playfield()


func _on_Playfield_after_lines_deleted(_lines: Array) -> void:
	_call_queue.pop_deferred(self, "_inner_add_sharks")
	_call_queue.pop_deferred(self, "_inner_advance_sharks")
	_call_queue.assert_empty()
	
	_refresh_sharks_for_playfield()
