class_name Spears
extends Node2D
## Handles spears, puzzle critters which add veggie blocks from the sides.
##
## Spears pop out onto the playfield, destroying any blocks they collide with. Depending on the level configuration,
## they might retreat eventually. If they retreat, they leave behind empty cells which is annoying as well.

## If 'true', the spears cover the next queue. I personally think this looks better and is a funny gameplay hurdle,
## but I'm leaving this toggleable in case I change my mind later.
const COVER_NEXT_QUEUE := true

export (NodePath) var critter_manager_path: NodePath
export (PackedScene) var SpearScene: PackedScene
export (PackedScene) var SpearWideScene: PackedScene

var piece_manager_path: NodePath setget set_piece_manager_path
var playfield_path: NodePath setget set_playfield_path

## Queue of calls to defer until after line clears are finished
var _call_queue: CallQueue = CallQueue.new()

var _piece_manager: PieceManager
var _playfield: Playfield

## The previous spear size string which was randomly chosen. We avoid choosing the same spear size twice consecutively.
var _previous_spear_size_string: String

## Keeps track of which cells will be occupied by all of the spears if they are popped in, regardless of whether
## they're currently popped in or not.
##
## key: (Spear) spear which is currently on the playfield
## value: (Array, Vector2) playfield cells which will be occupied by this spear when it is popped in.
var _veg_cells_by_spear := {}

## key: (Spear) spear which is currently on the playfield
## value: (Vector2) spear width/height measured in playfield cells
var _dimensions_by_spear := {}

## node which contains all of the child spear nodes
onready var _spear_holder: Node2D = $SpearHolder
onready var _critter_manager: CellCritterManager = get_node(critter_manager_path)

func _ready() -> void:
	_refresh_playfield_path()
	_refresh_piece_manager_path()


func set_playfield_path(new_playfield_path: NodePath) -> void:
	playfield_path = new_playfield_path
	_refresh_playfield_path()
	_refresh_piece_manager_path()


## Adds spears in response to a level event.
func add_spears(config: SpearConfig) -> void:
	if _playfield.is_clearing_lines():
		# If spears are being added as a part of line clears, we wait to add spears until all lines are deleted.
		_call_queue.defer(self, "_inner_add_spears", [config])
	else:
		_inner_add_spears(config)


## Pops out spears in response to a level event.
func pop_out_spears(count: int) -> void:
	var playfield_disturbed := false
	
	for _i in range(count):
		var spear_to_remove: Spear
		
		# find a popped-out spear to remove
		for next_spear in _spear_holder.get_children():
			if next_spear in _veg_cells_by_spear and next_spear.state == Spear.POPPED_IN:
				spear_to_remove = next_spear
				break
		
		if not spear_to_remove:
			# could not find any spears to remove
			break
		
		# pop the spear out
		playfield_disturbed = true
		spear_to_remove.state = Spear.POPPED_OUT
		spear_to_remove.clear_next_states()
		spear_to_remove.append_next_state(Spear.NONE)
		_remove_veg_cells_for_spear(spear_to_remove)
	
	if playfield_disturbed:
		_piece_manager.emit_signal("playfield_disturbed", _piece_manager.piece)


func set_piece_manager_path(new_piece_manager_path: NodePath) -> void:
	piece_manager_path = new_piece_manager_path
	_refresh_piece_manager_path()


## Advances all spears by one state.
func advance_spears() -> void:
	if _playfield.is_clearing_lines():
		# If spears are being advanced as a part of line clears, we wait to advance spears until all lines are deleted.
		_call_queue.defer(self, "_inner_advance_spears", [])
	else:
		_inner_advance_spears()


## Add a spear to to the playfield.
##
## Parameters:
## 	'config': Rules for spears on this level.
##
## 	'spear_y': The y coordinate of the playfield cell this spear should appear in. For wide spears, this corresponds to
## 		the higher playfield row.
##
## 	'spear_wide': 'true' if the spear is wide.
##
## 	'spear_length': The number of playfield cells the spear extends across horizontally.
##
## 	'spear_side': Spear.RIGHT for spears emerging from the right side of the playfield, Spear.LEFT for the left side.
func _add_spear(config: SpearConfig, spear_y: int, spear_wide: bool, spear_length: int, spear_side: int) -> void:
	if spear_length == 0:
		return
	
	var spear: Spear
	
	# initialize the spear scene
	if spear_wide:
		spear = SpearWideScene.instance()
	else:
		spear = SpearScene.instance()
	spear.z_index = 5
	spear.scale = _playfield.tile_map.scale
	spear.pop_anim_duration = PieceSpeeds.current_speed.lock_delay / 60.0
	spear.side = spear_side
	
	# calculate spear position and length
	var cell := Vector2(0 if spear_side == Spear.LEFT else PuzzleTileMap.COL_COUNT - 1, spear_y)
	spear.position = _playfield.tile_map.map_to_world(cell + Vector2(0, -3))
	spear.position += _playfield.tile_map.cell_size * Vector2(0.0 if spear_side == Spear.LEFT else 1.0, 0.0)
	spear.position += _playfield.tile_map.cell_size * Vector2(0.0, 1.0 if spear_wide else 0.5)
	spear.position *= _playfield.tile_map.scale
	spear.pop_length = spear_length * 72
	if spear_side == Spear.RIGHT and COVER_NEXT_QUEUE:
		# reposition/lengthen spears to cover the next queue
		spear.position += Vector2(64.0, 0.0)
		spear.pop_length += 64 / spear.scale.x
	
	# populate _dimensions_by_spear
	_dimensions_by_spear[spear] = Vector2(spear_length, 2 if spear_wide else 1)
	
	# populate _veg_cells_by_spear
	var veg_cells := []
	for i in range(spear_length):
		var veg_cell := Vector2(i if spear_side == Spear.LEFT else PuzzleTileMap.COL_COUNT - i - 1, spear_y)
		veg_cells.append(veg_cell)
		if spear_wide:
			veg_cells.append(veg_cell + Vector2(0, 1))
	_veg_cells_by_spear[spear] = veg_cells
	
	# populate the spear's states
	if config.wait <= 1:
		# 'waiting end' -> 'popped in' -> ...
		spear.state = Spear.WAITING_END
	else:
		# 'waiting' -> ... -> 'waiting end' -> 'popped in' -> ...
		spear.state = Spear.WAITING
		for _i in range(config.wait - 2):
			spear.append_next_state(Spear.WAITING)
		spear.append_next_state(Spear.WAITING_END)
	
	if config.duration >= 1:
		# ... -> 'popped in' -> 'popped in' -> ... -> 'popped out' -> 'none'
		spear.append_next_state(Spear.POPPED_IN, config.duration)
		spear.append_next_state(Spear.POPPED_OUT)
		spear.append_next_state(Spear.NONE)
	else:
		# ... -> 'popped in' forever
		spear.append_next_state(Spear.POPPED_IN)
	
	_spear_holder.add_child(spear)


## Randomly determines a spear size string from the list of potential size strings.
##
## The list of potential size strings can contain values like 'x5' for a spear which can potentially emerge from either
## side. In addition to selecting a random size string, this method also converts those 'x' lengths to 'l' or 'r'.
##
## Parameters:
## 	'config': Rules for spears on this level.
##
## Returns:
## 	A random spear size string with 'l'/'r' (never 'x')
func _determine_spear_size_string(config: SpearConfig) -> String:
	var spear_size_strings := config.sizes.duplicate()
	if _previous_spear_size_string in spear_size_strings and spear_size_strings.size() >= 2:
		# avoid repeating the same spear twice
		spear_size_strings.remove(spear_size_strings.find(_previous_spear_size_string))
	
	var spear_size_string: String = Utils.rand_value(spear_size_strings)
	spear_size_string = resolve_spear_size_x(spear_size_string)
	
	_previous_spear_size_string = spear_size_string
	
	return spear_size_string

## Determine the row for the specified spear.
##
## We determine which columns the spear will occupy, and find a row where it can emerge without colliding with any
## other spears, popped or unpopped. If no such row exists, this method returns '-1'.
##
## Parameters:
## 	'config': Rules for spears on this level.
##
## 	'spear_size_string': A value like 'l2r4' for the spear to evaluate.
##
## Returns:
## 	The playfield row where this spear can emerge without colliding with any other spears.
func _determine_row(config: SpearConfig, spear_size_string: String) -> int:
	# calculate target columns
	var target_columns := []
	for spear_size_substring in [spear_size_string.substr(0, 2), spear_size_string.substr(2, 4)]:
		if spear_size_substring.length() == 0:
			break
		elif spear_size_substring.length() != 2:
			push_warning("Unexpected spear size: %s" % [spear_size_string])
			break
		
		match spear_size_substring[0]:
			"l", "L":
				for i in range(int(spear_size_substring[1])):
					target_columns.append(i)
			"r", "R":
				for i in range(int(spear_size_substring[1])):
					target_columns.append(8 - i)
	
	var occupied_veg_cells := {}
	for veg_cells_by_spear_value in _veg_cells_by_spear.values():
		for veg_cell in veg_cells_by_spear_value:
			occupied_veg_cells[veg_cell] = true
	
	## find all playfield rows where the asparagus will fit
	var rows_to_check := range(3, PuzzleTileMap.ROW_COUNT)
	var unblocked_rows := {}
	for row in rows_to_check:
		var unblocked_row := true
		for column in target_columns:
			if occupied_veg_cells.has(Vector2(column, row)):
				unblocked_row = false
				break
		
		if unblocked_row:
			unblocked_rows[row] = true
	
	## find all positions where the asparagus can pop out based on its config and size
	var wide := SpearConfig.is_wide(spear_size_string)
	var compatible_rows := []
	for row in unblocked_rows:
		if config.lines and not row in config.lines:
			continue
		
		if wide and not (row + 1) in unblocked_rows:
			continue
		
		compatible_rows.append(row)
	
	## randomly pick one
	return Utils.rand_value(compatible_rows) if compatible_rows else -1


## Adds one or two spears to the specified row.
##
## Parameters:
## 	'config': Rules for spears on this level.
##
## 	'spear_y': The y coordinate of the playfield cell this spear should appear in. For wide spears, this corresponds to
## 		the higher playfield row.
##
## 	'spear_size_string': A value like 'l2r4' for the spear to add.
func _add_spear_for_row(config: SpearConfig, spear_y: int, spear_size_string: String) -> void:
	for spear_size_substring in [spear_size_string.substr(0, 2), spear_size_string.substr(2, 4)]:
		if spear_size_substring.length() == 0:
			break
		elif spear_size_substring.length() != 2:
			push_warning("Unexpected spear size: %s" % [spear_size_string])
			break
		
		var spear_length := 0
		var spear_side := Spear.LEFT
		spear_length = int(spear_size_substring[1])
		match spear_size_substring[0]:
			"l", "L":
				spear_side = Spear.LEFT
			"r", "R":
				spear_side = Spear.RIGHT
			_:
				push_warning("Unexpected spear size: %s" % [spear_size_string])
				break
		var spear_wide := SpearConfig.is_wide(spear_size_string)
		_add_spear(config, spear_y, spear_wide, spear_length, spear_side)


## Adds spears in response to a level event.
##
## Parameters:
## 	'config': Rules for spears on this level.
func _inner_add_spears(config: SpearConfig) -> void:
	for _i in range(config.count):
		var spear_size_string := _determine_spear_size_string(config)
		
		var spear_y := _determine_row(config, spear_size_string)
		
		if spear_y == -1:
			# no suitable row is available
			pass
		else:
			_add_spear_for_row(config, spear_y, spear_size_string)


## Advances all spears by one state.
func _inner_advance_spears() -> void:
	var playfield_disturbed := false
	var cells_consumed := {}
	var box_ints := []
	
	for spear in _spear_holder.get_children():
		if not spear.has_next_state():
			# Spears will not disappear just because they exhaust their state queue
			continue
		
		var old_state: int = spear.state
		var new_state: int = spear.pop_next_state()
		
		if old_state != Spear.POPPED_IN and new_state == Spear.POPPED_IN:
			playfield_disturbed = true
			_check_for_speared_piece(spear)
			_add_veg_cells_for_spear(spear, cells_consumed, box_ints)
		elif old_state == Spear.POPPED_IN and new_state != Spear.POPPED_IN:
			playfield_disturbed = true
			_remove_veg_cells_for_spear(spear)
		
		if new_state in [Spear.NONE, Spear.POPPED_OUT] and not spear.has_next_state():
			_remove_spear(spear)
		
	if cells_consumed:
		_playfield.emit_signal("cells_consumed", cells_consumed.keys(), box_ints)
	
	if playfield_disturbed:
		_piece_manager.emit_signal("playfield_disturbed", _piece_manager.piece)
	
	if box_ints:
		var box_score: int = CurrentLevel.settings.score.box_score_for_box_ints(box_ints)
		PuzzleState.add_box_score(box_score)


## Returns the rows for the spear's 'veg_cells_by_spear' entry.
func _rows_for_spear(spear: Spear) -> Array:
	var lines := {}
	for cell in _veg_cells_by_spear.get(spear, []):
		lines[int(cell.y)] = true
	return lines.keys()


## Poofs the spear out of view.
##
## This should only be used for spears which are being suddenly destroyed. Spears which are retreating should pop out
## first.
##
## 	'spear': The spear to erase.
##
## 	'erased_y': (Optional) The row to veggie cells to erase from the playfield. If omitted, all of the spear's veggie
## 		cells will be erased.
func _remove_spear(spear: Spear, erased_y: int = -1) -> void:
	if spear.state == Spear.POPPED_IN:
		_remove_veg_cells_for_spear(spear, erased_y)
	
	spear.poof_and_free()
	_veg_cells_by_spear.erase(spear)
	_dimensions_by_spear.erase(spear)


## Updates the playfield's cells with invisible veggie cells for a spear.
##
## Parameters:
## 	'spear': The spear whose veggie cells should be added.
##
## 	'cells_consumed': An in/out parameter for cells consumed by this spear. We keep track of this so the player can be
## 		awarded points for any cakes destroyed by spears.
##
## 	'box_ints': An in/out parameter for cakes consumed by this spear. We keep track of this so the player can be
## 		awarded points for any cakes destroyed by spears.
func _add_veg_cells_for_spear(spear: Spear, cells_consumed: Dictionary, box_ints: Array) -> void:
	# emit crumbs if for any consumed cells
	var crumb_colors := {}
	for cell in _veg_cells_by_spear[spear]:
		if _playfield.tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			for crumb_color in _playfield.tile_map.crumb_colors_for_cell(cell):
				crumb_colors[crumb_color] = true
	if crumb_colors:
		spear.emit_crumbs(crumb_colors.keys(), 0)
	
	for cell in _veg_cells_by_spear[spear]:
		# break boxes and award points
		if _playfield.tile_map.get_cellv(cell) == PuzzleTileMap.TILE_BOX:
			var broken_box_int: int = _playfield.tile_map.get_cell_autotile_coord(cell.x, cell.y).y
			var new_cells_consumed := _break_box(cell)
			for new_cell_consumed in new_cells_consumed:
				cells_consumed[new_cell_consumed] = true
			for _i in range(2, max(new_cells_consumed.size(), 3)):
				box_ints.append(broken_box_int)
		elif _playfield.tile_map.get_cellv(cell) != TileMap.INVALID_CELL:
			cells_consumed[cell] = true
		
		_playfield.tile_map.erase_cell(cell)
		
		# popping in; add invisible veggie cells
		_playfield.tile_map.set_block(cell, PuzzleTileMap.TILE_VEG, Vector2(0, 6))


## Checks whether the player's active piece was hit by a spear.
##
## If the player's active piece is hit by a spear, the piece is partially destroyed but the player can keep moving it.
func _check_for_speared_piece(spear: Spear) -> void:
	# The previous type/position/orientation of the player's active piece
	var old_type := _piece_manager.piece.type
	var old_pos := _piece_manager.piece.pos
	var old_orientation := _piece_manager.piece.orientation

	# The new type/position/orientation of the player's active piece, after evaluating any spear collisions
	var new_type := old_type
	var new_pos := old_pos
	var new_orientation := old_orientation
	
	var piece_type_mutator: PieceTypeMutator
	
	# key: (Color) Color instances corresponding to crumb colors for destroyed blocks.
	# value: (bool) true
	var crumb_colors := {}
	
	# Check for any collisions
	for spear_cell in _veg_cells_by_spear[spear]:
		if _critter_manager.cell_overlaps_piece(spear_cell):
			if new_type == old_type:
				new_type = PieceType.new()
				new_type.copy_from(old_type)
				piece_type_mutator = PieceTypeMutator.new(new_type)
			
			for crumb_color in _piece_manager.tile_map.crumb_colors_for_cell(spear_cell):
				crumb_colors[crumb_color] = true
			
			piece_type_mutator.remove_cell(new_orientation, spear_cell - new_pos)
	
	if new_type != old_type:
		# The piece was speared. Update the piece manager with the new piece type, possibly cycling to the next piece.
		spear.emit_crumbs(crumb_colors.keys(), 0)
		_critter_manager.update_piece_manager_piece(new_type, new_pos, new_orientation)
		_critter_manager.check_for_empty_piece()


## Removes veggie cells from the playfield for the specified spear.
##
## 	'spear': The spear whose veggie cells should be erased.
##
## 	'erased_y': (Optional) The row to veggie cells to erase from the playfield. If omitted, all of the spear's veggie
## 		cells will be erased.
func _remove_veg_cells_for_spear(spear: Spear, erased_y: int = -1) -> void:
	# popping out; remove invisible veggie cells
	for cell in _veg_cells_by_spear[spear]:
		if erased_y != -1 and cell.y != erased_y:
			# for 'fat spears' we only erase cells in the erased row; others are turned into regular veggie rows.
			_playfield.tile_map.set_block(cell, PuzzleTileMap.TILE_VEG, PuzzleTileMap.random_veg_autotile_coord())
		else:
			# remove invisible veggie cells
			_playfield.tile_map.set_block(cell, -1)


## Breaks the box occupying the specified cell.
##
## If a spear spears any cell in a cake box or snake box, the cell's row is converted to a vegetable row and detached
## from the rest of the box. The player is awarded points for the destroyed cell.
func _break_box(source_cell: Vector2) -> Array:
	var cells_to_break := [source_cell]
	
	for i in range(1, PuzzleTileMap.COL_COUNT):
		var next_cell := source_cell - Vector2(i, 0)
		if _playfield.tile_map.get_cellv(next_cell) == PuzzleTileMap.TILE_BOX \
				and PuzzleConnect.is_r(_playfield.tile_map.get_cell_autotile_coord(next_cell.x, next_cell.y).x):
			cells_to_break.append(next_cell)
		else:
			break
	
	for i in range(1, PuzzleTileMap.COL_COUNT):
		var next_cell := source_cell + Vector2(i, 0)
		if _playfield.tile_map.get_cellv(next_cell) == PuzzleTileMap.TILE_BOX \
				and PuzzleConnect.is_l(_playfield.tile_map.get_cell_autotile_coord(next_cell.x, next_cell.y).x):
			cells_to_break.append(next_cell)
		else:
			break
	
	for cell_to_break in cells_to_break:
		# disconnect cell from neighbors
		var autotile_coord := _playfield.tile_map.get_cell_autotile_coord(cell_to_break.x, cell_to_break.y)
		if PuzzleConnect.is_u(autotile_coord.x):
			_playfield.tile_map.disconnect_block(cell_to_break + Vector2.UP, PuzzleConnect.DOWN)
		if PuzzleConnect.is_d(autotile_coord.x):
			_playfield.tile_map.disconnect_block(cell_to_break + Vector2.DOWN, PuzzleConnect.UP)
		
		# replace cell with veggie
		_playfield.tile_map.set_block(cell_to_break, PuzzleTileMap.TILE_VEG,
				PuzzleTileMap.random_veg_autotile_coord())
	
	# award points
	return cells_to_break


## Immediately remove all spears from the playfield, with no animation.
func _clear_spears() -> void:
	_veg_cells_by_spear.clear()
	for spear in _spear_holder.get_children():
		spear.queue_free()


func _refresh_piece_manager_path() -> void:
	if not (is_inside_tree() and piece_manager_path):
		return
	
	_piece_manager = get_node(piece_manager_path) if piece_manager_path else null


func _refresh_playfield_path() -> void:
	if not (is_inside_tree() and playfield_path):
		return
	
	if _playfield:
		_playfield.disconnect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.disconnect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.disconnect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.disconnect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.disconnect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")
	
	_playfield = get_node(playfield_path) if playfield_path else null
	
	if _playfield:
		_playfield.connect("blocks_prepared", self, "_on_Playfield_blocks_prepared")
		_playfield.connect("line_erased", self, "_on_Playfield_line_erased")
		_playfield.connect("line_inserted", self, "_on_Playfield_line_inserted")
		_playfield.connect("line_deleted", self, "_on_Playfield_line_deleted")
		_playfield.connect("after_lines_deleted", self, "_on_Playfield_after_lines_deleted")


## Shifts a group of spears up or down.
##
## Parameters:
## 	'bottom_y': The lowest row to shift. All spears at or above this row will be shifted.
##
## 	'direction': The direction to shift the spears, such as Vector2.UP or Vector2.DOWN.
func _shift_rows(bottom_y: int, direction: Vector2) -> void:
	# First, erase and store all the old spears which are shifting
	for spear in _veg_cells_by_spear.keys():
		var should_shift_spear := false
		for spear_line in _rows_for_spear(spear):
			if spear_line <= bottom_y:
				should_shift_spear = true
				break
		if not should_shift_spear:
			# spears below the specified bottom_y are left alone
			continue
		
		# shift the visuals
		spear.position += direction * _playfield.tile_map.cell_size * _playfield.tile_map.scale
		
		# shift the '_veg_cells_by_spear' cell coordinates
		for i in range(_veg_cells_by_spear[spear].size()):
			# spears above the specified bottom row are shifted
			_veg_cells_by_spear[spear][i] += direction
		
		# make the spear visible/invisible if it scrolls off the top of the screen
		var spear_bottom_row := -1
		for spear_line in _rows_for_spear(spear):
			spear_bottom_row = max(spear_line, spear_bottom_row)
		spear.visible = spear_bottom_row >= PuzzleTileMap.FIRST_VISIBLE_ROW
	
	_detect_and_resolve_spear_conflicts()


## Detects any spear overlaps, removing any small spears which overlap larger spears.
##
## Line clears do not remove spears which haven't popped out yet, so it's possible for two spears to end up in the
## same row overlapping the same cells. In this unlikely scenario, we remove the smaller of the overlapping spears.
func _detect_and_resolve_spear_conflicts() -> void:
	# key: (Vector2) playfield cell which will be occupied by a spear when it is popped in
	# value: (Spear) spear which is currently on the playfield
	var spears_by_veg_cell: Dictionary = {}
	
	for spear in _veg_cells_by_spear.keys():
		for veg_cell in _veg_cells_by_spear[spear]:
			var conflicting_spear: Spear = spears_by_veg_cell.get(veg_cell)
			if not conflicting_spear:
				spears_by_veg_cell[veg_cell] = spear
				continue
			
			# Calculate which spear is larger; the larger spear wins the conflict.
			var _spears_by_size := [spear, conflicting_spear]
			_spears_by_size.sort_custom(self, "_compare_spears_by_size")
			var large_spear: Spear = _spears_by_size[0]
			var small_spear: Spear = _spears_by_size[1]
			
			# write the large spear to spears_by_veg_cell, and remove references to the small spear
			spears_by_veg_cell[veg_cell] = large_spear
			for small_cell in _veg_cells_by_spear[small_spear]:
				if spears_by_veg_cell[small_cell] == small_spear:
					spears_by_veg_cell.erase(small_cell)
			_remove_spear(small_spear)
			
			if spear == small_spear:
				# if this spear was removed due to a conflict, we don't check the rest of its cells
				break


func _compare_spears_by_size(a: Spear, b: Spear) -> bool:
	## Spears are compared by width, then length.
	if _dimensions_by_spear[a].y != _dimensions_by_spear[b].y:
		return _dimensions_by_spear[a].y > _dimensions_by_spear[b].y
	return _dimensions_by_spear[a].x > _dimensions_by_spear[b].x


func _on_Playfield_line_erased(y: int, _total_lines: int, _remaining_lines: int, _box_ints: Array) -> void:
	for spear in _veg_cells_by_spear.keys():
		if spear.state != Spear.POPPED_IN:
			continue
		
		if not _rows_for_spear(spear).has(y):
			continue
		
		_remove_spear(spear, y)


func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	# raise all spears at or above the specified row
	_shift_rows(y, Vector2.UP)


func _on_Playfield_line_deleted(y: int) -> void:
	# drop all spears above the specified row to fill the gap
	_shift_rows(y - 1, Vector2.DOWN)


func _on_Playfield_after_lines_deleted(_lines: Array) -> void:
	_call_queue.pop_deferred(self, "_inner_advance_spears")
	_call_queue.pop_deferred(self, "_inner_add_spears")
	_call_queue.assert_empty()


func _on_Playfield_blocks_prepared() -> void:
	_previous_spear_size_string = ""
	_clear_spears()


## Replaces any 'x' values in a spear size string with 'l' or 'r' values.
##
## A size string can contain values like 'x5' for a spear which can potentially emerge from either side. This method
## converts those 'x' lengths to 'l' or 'r'.
##
## Parameters:
## 	'spear_size_string': A value like 'l2r4' for or 'X6' for the length and width of the spear.
##
## 	'r': (Optional) A random number in the range [0.0, 1.0] for whether randomized spears should resolve to to left or
## 		right. If omitted, a random value will be generated. (This is used to seed tests.)
##
## Returns:
## 	A spear size string with any 'x' values replaced with 'l' or 'r'.
static func resolve_spear_size_x(spear_size_string: String, r: float = randf()) -> String:
	var result := spear_size_string
	
	if result.length() >= 2:
		# Replace the first 'x'. 'x3' -> 'l3', 'x3x5' -> 'l3x5'
		if result[0] == "x": result[0] = "l" if r < 0.5 else "r"
		if result[0] == "X": result[0] = "L" if r < 0.5 else "R"
	
	if result.length() >= 4:
		# Replace the second 'x', if any. 'l3x5' -> 'l3r5'
		if result[2] == "x": result[2] = "l" if result[0].to_lower() == "r" else "r"
		if result[2] == "X": result[2] = "L" if result[0].to_lower() == "r" else "R"
	
	return result
