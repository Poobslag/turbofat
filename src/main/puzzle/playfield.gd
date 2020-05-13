class_name Playfield
extends Control
"""
Stores information about the game playfield: writing pieces to the playfield, calculating whether a line was cleared
or whether a box was made, pausing and playing sound effects
"""

const CAKE_COLOR_INDEX := 4

# food colors for the food which gets hurled into the customer's mouth
const FOOD_COLORS: Array = [
	Color("a4470b"), # brown
	Color("ff5d68"), # pink
	Color("ffa357"), # bread
	Color("fff6eb") # white
]

# signal emitted before a line is cleared
signal before_lines_cleared(cleared_lines)

# signal emitted when lines are cleared
signal lines_cleared(cleared_lines)

# signal emitted when a box (3x3, 3x4, 3x5) is made
signal box_made(x, y, width, height, color)

# signal emitted when the customer should leave
signal customer_left

# playfield dimensions. the playfield extends a few rows higher than what the player can see
const ROW_COUNT = 20
const COL_COUNT = 9

# bonus points which are awarded as the player continues a combo
const COMBO_SCORE_ARR = [0, 0, 5, 5, 10, 10, 15, 15, 20]

# player's current combo
var combo := 0
# 'true' if the player is currently playing, and the time spent should count towards their stats
var clock_running := false

# lines which are currently being cleared
var _cleared_lines := []
# remaining frames to wait for clearing the current lines
var _remaining_line_clear_frames := 0
# remaining frames to wait for making the current box
var _remaining_box_build_frames := 0
# 'true' if the 'line fall sound' should play after the current lines are cleared. The sound doesn't play if nothing
# drops.
var _should_play_line_fall_sound := false
# The number of pieces the player has dropped without clearing a line or making a box, plus one.
var _combo_break := 0

onready var _score: Score = $"../Score"

# sounds which play as the player continues a combo.
onready var _combo_sounds := [null, null, # no combo sfx for the first two lines
		$Combo01Sound, $Combo02Sound, $Combo03Sound, $Combo04Sound, $Combo05Sound, $Combo06Sound,
		$Combo07Sound, $Combo08Sound, $Combo09Sound, $Combo10Sound, $Combo11Sound, $Combo12Sound,
		$Combo13Sound, $Combo14Sound, $Combo15Sound, $Combo16Sound, $Combo17Sound, $Combo18Sound,
		$Combo19Sound, $Combo20Sound, $Combo21Sound, $Combo22Sound, $Combo23Sound, $Combo24Sound]

onready var _combo_endless_sounds := [$ComboEndless00Sound, $ComboEndless01Sound, $ComboEndless02Sound, 
		$ComboEndless03Sound, $ComboEndless04Sound, $ComboEndless05Sound, $ComboEndless06Sound, $ComboEndless07Sound,
		$ComboEndless08Sound, $ComboEndless09Sound, $ComboEndless10Sound, $ComboEndless11Sound]

func _ready() -> void:
	$TileMapClip/TileMap.clear()
	$TileMapClip/TileMap/CornerMap.clear()


func _physics_process(delta: float) -> void:
	if clock_running:
		Global.scenario_performance.seconds += delta
	
	if _remaining_box_build_frames > 0:
		_remaining_box_build_frames -= 1
		if _remaining_box_build_frames <= 0:
			if _remaining_line_clear_frames > 0:
				_process_line_clear()
				# processing line clear sets combo_break to 0, but it should be 1
				_combo_break += 1
	elif _remaining_line_clear_frames > 0:
		_remaining_line_clear_frames -= 1
		if _remaining_line_clear_frames <= 0:
			_delete_rows()


"""
Returns false the playfield is paused for an of animation or delay which should prevent a new piece from appearing.
"""
func ready_for_new_piece() -> bool:
	return _remaining_line_clear_frames <= 0 and _remaining_box_build_frames <= 0


"""
Clears the playfield and resets everything for a new game.
"""
func start_game() -> void:
	Global.scenario_performance = ScenarioPerformance.new()
	$TileMapClip/TileMap.clear()
	$TileMapClip/TileMap/CornerMap.clear()


"""
Writes a piece to the playfield, checking whether it makes any boxes or clears any lines.

Returns true if the written piece results in a line clear.
"""
func write_piece(pos: Vector2, orientation: int, type: PieceType, piece_speed: PieceSpeed,
		death_piece := false) -> bool:
	for i in range(type.pos_arr[orientation].size()):
		var block_pos := type.get_cell_position(orientation, i)
		var block_color := type.get_cell_color(orientation, i)
		_set_piece_block(pos.x + block_pos.x, pos.y + block_pos.y, block_color)
	
	_remaining_box_build_frames = 0
	if not death_piece and _process_boxes():
		# set at least 1 box build frame; processing occurs when the frame goes from 1 -> 0
		_remaining_box_build_frames = max(1, piece_speed.box_delay)
	
	_remaining_line_clear_frames = 0
	if not death_piece and _any_row_is_full():
		_remaining_line_clear_frames = max(1, piece_speed.line_clear_delay)
		if _remaining_box_build_frames <= 0:
			# process the line clear if we're not already making a box
			_process_line_clear()
	
		# set at least 1 line clear frame; processing occurs when the frame goes from 1 -> 0
	
	_process_combo()
	
	return _remaining_line_clear_frames > 0


"""
Returns 'true' if the specified cell does not contain a block.
"""
func is_cell_empty(x: int, y: int) -> bool:
	return get_cell(x, y) == -1


func end_game() -> void:
	_score.end_combo()
	combo = 0


"""
Deletes all cleared lines from the playfield, shifting everything above them down to fill the gap.
"""
func _delete_rows() -> void:
	_should_play_line_fall_sound = false
	for cleared_line in _cleared_lines:
		_delete_row(cleared_line)
	_cleared_lines = []
	if _should_play_line_fall_sound:
		$LineFallSound.play()


"""
Erases the specified lines from the TileMap and awards points.
"""
func clear_lines(rows: Array) -> void:
	emit_signal("before_lines_cleared", _cleared_lines)
	var total_points := 0
	var piece_points := 0
	for y in _cleared_lines:
		var line_score := 1
		line_score += COMBO_SCORE_ARR[clamp(combo, 0, COMBO_SCORE_ARR.size() - 1)]
		Global.scenario_performance.lines += 1
		Global.scenario_performance.combo_score += COMBO_SCORE_ARR[clamp(combo, 0, COMBO_SCORE_ARR.size() - 1)]
		for x in range(COL_COUNT):
			var autotile_coord: Vector2 = get_cell_autotile_coord(x, y)
			if get_cell(x, y) == 1 \
					and not Connect.is_l(autotile_coord.x):
				if autotile_coord.y == CAKE_COLOR_INDEX:
					# cake piece
					line_score += 10
					Global.scenario_performance.box_score += 10
					piece_points = int(max(piece_points, 2))
				else:
					# snack piece
					line_score += 5
					Global.scenario_performance.box_score += 5
					piece_points = int(max(piece_points, 1))
		_score.add_combo_score(line_score - 1)
		_score.add_score(1)
		_clear_row(y)
		total_points += line_score
		# each line cleared adds to the combo, increasing the score for the following lines
		combo += 1
		_combo_break = 0
	_play_line_clear_sfx(piece_points)
	emit_signal("lines_cleared", _cleared_lines)


"""
Makes a box at the specified location.

Boxes are made when the player forms a 3x3, 3x4, 3x5 rectangle from intact pieces.
"""
func make_box(x: int, y: int, width: int, height: int, box_color: int) -> void:
	# corners
	_set_box_block(x + 0, y + 0, Vector2(10, box_color))
	_set_box_block(x + width - 1, y + 0, Vector2(6, box_color))
	_set_box_block(x + 0, y + height - 1, Vector2(9, box_color))
	_set_box_block(x + width - 1, y + height - 1, Vector2(5, box_color))
	
	# top/bottom edge
	for curr_x in range(x + 1, x + width - 1):
		_set_box_block(curr_x, y + 0, Vector2(14, box_color))
		_set_box_block(curr_x, y + height - 1, Vector2(13, box_color))
	
	# center
	for curr_x in range(x + 1, x + width - 1):
		for curr_y in range(y + 1, y + height - 1):
			_set_box_block(curr_x, curr_y, Vector2(15, box_color))
	
	# left/right edge
	for curr_y in range(y + 1, y + height - 1):
		_set_box_block(x + 0, curr_y, Vector2(11, box_color))
		_set_box_block(x + width - 1, curr_y, Vector2(7, box_color))
		
	emit_signal("box_made", x, y, width, height, box_color)


"""
Creates a new integer matrix of the same dimensions as the playfield.
"""
func _int_matrix() -> Array:
	var matrix := []
	for y in range(ROW_COUNT):
		matrix.append([])
		for _x in range(COL_COUNT):
			matrix[y].resize(COL_COUNT)
	return matrix


"""
Calculates the possible locations for a (width x height) rectangle in the playfield, given an integer matrix with the
possible locations for a (1 x height) rectangle in the playfield. These rectangles must consist of dropped pieces which
haven't been split apart by lines. They can't consist of any empty cells or any previously built boxes.
"""
func _filled_rectangles(db: Array, box_height: int) -> Array:
	var dt := _int_matrix()
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			if db[y][x] >= box_height:
				dt[y][x] = 1 if x == 0 else dt[y][x - 1] + 1
			else:
				dt[y][x] = 0
	return dt


"""
Calculates the possible locations for a (1 x height) rectangle in the playfield, capable of being a part of a 3x3,
3x4, or 3x5 'box'. These rectangles must consist of dropped pieces which haven't been split apart by lines. They can't
consist of any empty cells or any previously built boxes.
"""
func _filled_columns() -> Array:
	var db := _int_matrix()
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			var piece_color: int = get_cell(x, y)
			if piece_color == -1:
				# empty space
				db[y][x] = 0
			elif piece_color == 1:
				# box
				db[y][x] = 0
			elif piece_color == 2:
				# vegetable
				db[y][x] = 0
			else:
				db[y][x] = 1 if y == 0 else db[y - 1][x] + 1
	return db


"""
Builds any possible 3x3, 3x4 or 3x5 'boxes' in the playfield, returning 'true' if a box was built.
"""
func _process_boxes() -> bool:
	# Calculate the possible locations for a (w x h) rectangle in the playfield
	var db := _filled_columns()
	var dt3 := _filled_rectangles(db, 3)
	var dt4 := _filled_rectangles(db, 4)
	var dt5 := _filled_rectangles(db, 5)
	
	for y in range(ROW_COUNT):
		for x in range(COL_COUNT):
			# check for 5x3s (vertical)
			if dt5[y][x] >= 3 and _process_box(x - 2, y - 4, 3, 5, true):
				$MakeCakeBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				return true
			
			# check for 4x3s (vertical)
			if dt4[y][x] >= 3 and _process_box(x - 2, y - 3, 3, 4, true):
				$MakeCakeBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				return true
			
			# check for 5x3s (horizontal)
			if dt3[y][x] >= 5 and _process_box(x - 4, y - 2, 5, 3, true):
				$MakeCakeBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				return true
			
			# check for 4x3s (horizontal)
			if dt3[y][x] >= 4 and _process_box(x - 3, y - 2, 4, 3, true):
				$MakeCakeBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				return true
			
			# check for 3x3s
			if dt3[y][x] >= 3 and _process_box(x - 2, y - 2, 3, 3):
				var box_type := int(get_cell_autotile_coord(x - 2, y - 2).y)
				if box_type == 0:
					$MakeSnackBoxSound0.play()
				elif box_type == 1:
					$MakeSnackBoxSound1.play()
				elif box_type == 2:
					$MakeSnackBoxSound2.play()
				elif box_type == 3:
					$MakeSnackBoxSound3.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				return true
	return false


"""
Checks whether the specified rectangle represents an enclosed box. An enclosed box must not connect to any pieces
outside the box.

It's assumed the rectangle's coordinates contain only dropped pieces which haven't been split apart by lines, and
no empty/vegetable/box cells.
"""
func _process_box(x: int, y: int, width: int, height: int, cake = false) -> bool:
	for curr_x in range(x, x + width):
		if Connect.is_u(get_cell_autotile_coord(curr_x, y).x):
			return false
		if Connect.is_d(get_cell_autotile_coord(curr_x, y + height - 1).x):
			return false
	for curr_y in range(y, y + height):
		if Connect.is_l(get_cell_autotile_coord(x, curr_y).x):
			return false
		if Connect.is_r(get_cell_autotile_coord(x + width - 1, curr_y).x):
			return false
	
	# making a box continues the combo
	_combo_break = 0
	
	var box_color: int = CAKE_COLOR_INDEX if cake else get_cell_autotile_coord(x, y).y
	
	make_box(x, y, width, height, box_color)
	
	return true


"""
Returns 'true' if any rows are full and will result in a line clear when processed.
"""
func _any_row_is_full() -> bool:
	var result := false
	for y in range(ROW_COUNT):
		if _row_is_full(y):
			result = true
			break
	return result


func get_cell(x: int, y:int) -> int:
	return $TileMapClip/TileMap.get_cell(x, y)


func get_cell_autotile_coord(x: int, y:int) -> Vector2:
	return $TileMapClip/TileMap.get_cell_autotile_coord(x, y)


"""
Clears any full lines in the playfield. Updates the combo, awards points, and plays sounds appropriately.
"""
func _process_line_clear() -> void:
	for y in range(ROW_COUNT):
		if _row_is_full(y):
			_cleared_lines.append(y)
	clear_lines(_cleared_lines)


"""
Ends the player's combo if they drop 2 blocks without making a box or scoring points.
"""
func _process_combo() -> void:
	_combo_break += 1
	if _combo_break >= 3:
		if _score.combo_score > 0:
			if combo >= 20:
				$Fanfare3.play()
			elif combo >= 10:
				$Fanfare2.play()
			elif combo >= 5:
				$Fanfare1.play()
		if _score.customer_score > 0:
			emit_signal("customer_left")
			_score.end_combo()
			combo = 0


"""
Play sound effects for clearing a line. A cleared line can result in several sound effects getting queued and played
consecutively.
"""
func _play_line_clear_sfx(piece_points: int) -> void:
	var scheduled_sfx := []
	
	# determine the main line-clear sound effect, which plays for clearing any line
	if _cleared_lines.size() == 1:
		scheduled_sfx.append($Erase1Sound)
	elif _cleared_lines.size() == 2:
		scheduled_sfx.append($Erase2Sound)
	else:
		scheduled_sfx.append($Erase3Sound)
	
	# determine any combo sound effects, which play for continuing a combo
	for combo_sfx in range(combo - _cleared_lines.size(), combo):
		var combo_sound := _get_combo_sound(combo_sfx)
		if combo_sound:
			scheduled_sfx.append(combo_sound)
	if piece_points == 1:
		scheduled_sfx.append($ClearSnackPieceSound)
	elif piece_points >= 2:
		scheduled_sfx.append($ClearCakePieceSound)
	
	# play the calculated sound effects
	if scheduled_sfx.size() > 0:
		# play the first sound effect immediately
		scheduled_sfx[0].play()
		# enqueue other sound effects and play them later
		for sfx_index in range(1, scheduled_sfx.size()):
			yield(get_tree().create_timer(0.025 * sfx_index), "timeout")
			scheduled_sfx[sfx_index].play()


"""
Returns the combo sound which should play for the specified combo.

For smaller combos this goes through an escalating list of sound effects. For larger combos this loops through a
cyclic list of sound effects, where the cycling is masked using something resembling a shepard tone.
"""
func _get_combo_sound(combo: int) -> AudioStreamPlayer:
	var combo_sound: AudioStreamPlayer
	if combo < _combo_sounds.size():
		combo_sound = _combo_sounds[combo]
	else:
		combo_sound = _combo_endless_sounds[(combo - _combo_sounds.size()) % _combo_endless_sounds.size()]
	return combo_sound


"""
Returns true if the specified row has no empty cells.
"""
func _row_is_full(y: int) -> bool:
	var row_is_full := true
	for x in range(COL_COUNT):
		if is_cell_empty(x, y):
			row_is_full = false
			break
	return row_is_full


"""
Clear all cells in the specified row. This leaves any pieces above them floating in mid-air.
"""
func _clear_row(y: int) -> void:
	for x in range(COL_COUNT):
		if get_cell(x, y) == 0:
			_disconnect_block(x, y)
		elif get_cell(x, y) == 1:
			_disconnect_box(x, y)
		
		_clear_block(x, y)


"""
Deletes the specified row in the playfield, dropping all higher rows down to fill the gap.
"""
func _delete_row(y: int) -> void:
	for curr_y in range(y, 0, -1):
		for x in range(COL_COUNT):
			var piece_color: int = get_cell(x, curr_y - 1)
			var autotile_coord: Vector2 = get_cell_autotile_coord(x, curr_y - 1)
			$TileMapClip/TileMap.set_cell(x, curr_y, piece_color, false, false, false, autotile_coord)
			$TileMapClip/TileMap/CornerMap.dirty = true
			if piece_color != -1:
				# only play the line falling sound if at least one block falls
				_should_play_line_fall_sound = true
	
	# remove row
	for x in range(COL_COUNT):
		_clear_block(x, 0)


"""
Disconnects the specified block from all blocks it's connected to, directly or indirectly. All disconnected blocks are
turned into vegetables to ensure they can't be included in boxes in the future.
"""
func _disconnect_block(x: int, y: int) -> void:
	if get_cell(x, y) != 0:
		# not a block; do nothing and don't recurse
		return
	
	# store connections
	var old_autotile_coord: Vector2 = get_cell_autotile_coord(x, y)
	
	# disconnect
	var vegetable_type := old_autotile_coord.y
	if vegetable_type > 3:
		# unusual blocks (maybe in future development) become leafy greens
		vegetable_type = 0
	_set_veg_block(x, y, Vector2(randi() % 18, vegetable_type))
	
	if y > 0 and Connect.is_u(old_autotile_coord.x):
		_disconnect_block(x, y - 1)
	
	if y < ROW_COUNT - 1 and Connect.is_d(old_autotile_coord.x):
		_disconnect_block(x, y + 1)
	
	if x > 0 and Connect.is_l(old_autotile_coord.x):
		_disconnect_block(x - 1, y)
	
	if x < COL_COUNT - 1 and Connect.is_r(old_autotile_coord.x):
		_disconnect_block(x + 1, y)


"""
Disconnects the specified block, which is a part of a box, from the boxes above and below it.

When clearing a line which contains a box, parts of the box can stay behind. We want to redraw those boxes so that
they don't look chopped-off, and so that the player can still tell they're worth bonus points, so we turn them into
smaller 2x3 and 1x3 boxes.

If we didn't perform this step, the chopped-off bottom of a bread box would still just look like bread. This way, the
bottom of a bread box looks like a delicious frosted snack and the player can tell it's special.
"""
func _disconnect_box(x: int, y: int) -> void:
	var old_autotile_coord: Vector2 = get_cell_autotile_coord(x, y)
	if y > 0 and Connect.is_u(old_autotile_coord.x):
		var above_autotile_coord: Vector2 = get_cell_autotile_coord(x, y - 1)
		_set_box_block(x, y - 1, Vector2(Connect.unset_d(above_autotile_coord.x), above_autotile_coord.y))
		_set_box_block(x, y, Vector2(Connect.unset_u(old_autotile_coord.x), old_autotile_coord.y))
	if y < ROW_COUNT - 1 and Connect.is_d(old_autotile_coord.x):
		var below_autotile_coord:Vector2 = get_cell_autotile_coord(x, y + 1)
		_set_box_block(x, y + 1,
				Vector2(Connect.unset_u(below_autotile_coord.x), below_autotile_coord.y))
		_set_box_block(x, y,
				Vector2(Connect.unset_d(old_autotile_coord.x), old_autotile_coord.y))


"""
Writes a block which is a part of an intact piece into the tile map. These intact pieces might later become boxes or
vegetables.
"""
func _set_piece_block(x: int, y: int, block_color: Vector2) -> void:
	$TileMapClip/TileMap.set_cell(x, y, 0, false, false, false, block_color)
	$TileMapClip/TileMap/CornerMap.dirty = true


"""
Writes a block which is a part of a snack box or cake box into the tile map. These are typically written when the
player arranges pieces into a box.
"""
func _set_box_block(x: int, y: int, box_color: Vector2) -> void:
	$TileMapClip/TileMap.set_cell(x, y, 1, false, false, false, box_color)
	$TileMapClip/TileMap/CornerMap.dirty = true


"""
Writes a vegetable block into the tile map. These are typically written when the player breaks up an intact piece.
"""
func _set_veg_block(x: int, y: int, block_color: Vector2) -> void:
	$TileMapClip/TileMap.set_cell(x, y, 2, false, false, false, block_color)
	$TileMapClip/TileMap/CornerMap.dirty = true


"""
Erases a block from the tile map.
"""
func _clear_block(x: int, y: int) -> void:
	$TileMapClip/TileMap.set_cell(x, y, -1)
	$TileMapClip/TileMap/CornerMap.dirty = true
