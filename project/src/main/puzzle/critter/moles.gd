class_name Moles
extends Node2D
## Handles moles, puzzle critters which dig up star seeds for the player.
##
## Moles dig for a few turns, and then add a pickup to the playfield. But they can be interrupted if they are crushed,
## or if the player clears the row they are digging.

export (PackedScene) var MoleScene: PackedScene
export (NodePath) var critter_manager_path: NodePath

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## Queue of calls to defer until after line clears are finished
var _call_queue: CallQueue = CallQueue.new()

var _piece_manager: PieceManager
var _playfield: Playfield

onready var _critter_manager: CellCritterManager = get_node(critter_manager_path)

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


## Adds moles to the playfield.
##
## Details like the number of moles to add, where to add them, how long they stay and what they dig are all specified
## by the config parameter.
##
## Parameters:
## 	'config': rules for how many moles to add, where to add them, how long they stay and what they dig.
func add_moles(config: MoleConfig) -> void:
	if _playfield.is_clearing_lines():
		# If moles are being added as a part of line clears, we wait to add moles until all lines are deleted.
		_call_queue.defer(self, "_inner_add_moles", [config])
	else:
		_inner_add_moles(config)


## Advances all moles by one state.
func advance_moles() -> void:
	if _playfield.is_clearing_lines():
		# If moles are being advanced as a part of line clears, we wait to advance moles until all lines are deleted.
		_call_queue.defer(self, "_inner_advance_moles", [])
	else:
		_inner_advance_moles()


## Plays a 'poof' animation and queues a mole for deletion.
##
## Parameters:
## 	'cell': A playfield cell containing a mole.
func remove_mole(cell: Vector2) -> void:
	var mole: Mole = _critter_manager.critters_by_cell[cell]
	mole.poof_and_free()
	_critter_manager.remove_critter(cell)


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


## Connects piece manager listeners.
func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and piece_manager_path):
		return
	
	if _piece_manager:
		_piece_manager.disconnect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null
	
	if _piece_manager:
		_piece_manager.connect("piece_disturbed", self, "_on_PieceManager_piece_disturbed")


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
	var midair_critter_x_coords := {}
	
	for y in range(PuzzleTileMap.FIRST_VISIBLE_ROW, PuzzleTileMap.ROW_COUNT):
		for x in range(PuzzleTileMap.COL_COUNT):
			var mole_cell := Vector2(x, y)
			
			if _playfield.tile_map.get_cellv(mole_cell) != TileMap.INVALID_CELL:
				ceiling_x_coords[x] = true
				midair_critter_x_coords.erase(x)
			
			if _critter_manager.cell_has_critter(mole_cell):
				# don't place a mole beneath a mid-air critter; this can happen during line clears
				midair_critter_x_coords[x] = true
			
			if midair_critter_x_coords.has(x):
				continue
			
			# check if the mole is in an appropriate row
			if config.lines:
				if not int(mole_cell.y) in config.lines:
					continue
			
			# check if the mole is in an appropriate column
			if config.columns:
				if not int(mole_cell.x) in config.columns:
					continue
			
			if _critter_manager.cell_has_floor(mole_cell) \
					and not _critter_manager.cell_has_block(mole_cell) \
					and not _critter_manager.cell_has_pickup(mole_cell) \
					and not _critter_manager.cell_has_critter(mole_cell) \
					and not _critter_manager.cell_overlaps_piece(mole_cell):
				
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


## Adds a mole to the specified cell.
##
## Details like how long they should dig for and what they should dig up are specified by the config parameter.
##
## Parameters:
## 	'config': rules for how long moles should dig for and what they should dig up.
func _add_mole(cell: Vector2, config: MoleConfig) -> void:
	if _critter_manager.critters_by_cell.has(cell):
		return
	
	var mole: Mole = MoleScene.instance()
	mole.z_index = 4
	mole.scale = _playfield.tile_map.scale
	
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
	mole.append_next_state(Mole.NONE)
	
	mole.pop_next_state()
	
	add_child(mole)
	_critter_manager.add_critter(cell, mole)


## Updates the overlapped moles as the player moves their piece.
func _refresh_moles_for_piece() -> void:
	for mole_cell in _critter_manager.critters_by_cell:
		if not _critter_manager.critters_by_cell[mole_cell] is Mole:
			continue
		
		var mole: Mole = _critter_manager.critters_by_cell[mole_cell]
		var piece_overlaps_mole: bool = _critter_manager.cell_overlaps_piece(mole_cell)
		
		if piece_overlaps_mole and not mole.hidden:
			mole.hidden = true
		if not piece_overlaps_mole and mole.hidden:
			mole.hidden = false


## Updates all moles based on the contents of the playfield.
##
## As the player clears lines, moles may disappear if they were digging through those rows.
func _refresh_moles_for_playfield(include_waiting_moles: bool = true) -> void:
	for mole_cell in _critter_manager.get_critter_cells(Mole):
		var mole: Mole = _critter_manager.critters_by_cell[mole_cell]
		
		if _critter_manager.cell_has_floor(mole_cell) \
				and not _critter_manager.cell_has_block(mole_cell):
			continue
		
		if mole.state == Mole.WAITING or mole.hidden and mole.hidden_mole_state == Mole.WAITING:
			# mole hasn't appeared yet; relocate the mole
			if include_waiting_moles:
				_critter_manager.vertically_relocate_critter(mole_cell)
		else:
			# mole was squished; remove the mole
			remove_mole(mole_cell)


## Adds moles to the playfield.
##
## Details like the number of moles to add, where to add them, how long they stay and what they dig are all specified
## by the config parameter.
##
## Parameters:
## 	'config': rules for how many moles to add, where to add them, how long they stay and what they dig.
func _inner_add_moles(config: MoleConfig) -> void:
	var potential_mole_cells := _potential_mole_cells(config)
	potential_mole_cells.shuffle()
	for i in range(min(config.count, potential_mole_cells.size())):
		_add_mole(potential_mole_cells[i], config)


## Advances all moles by one state.
func _inner_advance_moles() -> void:
	for cell in _critter_manager.get_critter_cells(Mole):
		var mole: Mole = _critter_manager.critters_by_cell[cell]
		if not mole.has_next_state():
			# Moles will not disappear just because they exhaust their state queue
			continue

		var new_state := mole.pop_next_state()
		match new_state:
			Mole.FOUND_SEED:
				_playfield.pickups.set_pickup(cell, Foods.BoxType.BREAD)
			Mole.FOUND_STAR:
				_playfield.pickups.set_pickup(cell, Foods.BoxType.CAKE_JTT)
			Mole.NONE:
				remove_mole(cell)


func _on_PieceManager_piece_disturbed(_piece: ActivePiece) -> void:
	_refresh_moles_for_piece()


func _on_PuzzleState_before_piece_written() -> void:
	_refresh_moles_for_playfield()
	
	# restore any remaining moles which were hidden by the active piece
	for mole_cell in _critter_manager.get_critter_cells(Mole):
		_critter_manager.critters_by_cell[mole_cell].hidden = false


func _on_Playfield_line_erased(_y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	# don't erase moles; moles can be added during the line clear process, which includes erase/delete events
	
	if _playfield.is_clearing_lines():
		# If lines are being erased as a part of line clears, we wait to relocate moles until all lines are deleted.
		# We still delete moles right away; if the row below a mole is cleared, they disappear even if they land on
		# solid ground.
		_refresh_moles_for_playfield(false)
	else:
		_refresh_moles_for_playfield()


func _on_CritterManager_line_inserted(_y: int, _tiles_key: String, _src_y: int) -> void:
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
	_call_queue.pop_deferred(self, "_inner_advance_moles")
	_call_queue.pop_deferred(self, "_inner_add_moles")
	_call_queue.assert_empty()

	_refresh_moles_for_playfield()
