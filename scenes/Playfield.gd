"""
Stores information about the game playfield: writing pieces to the playfield, calculating whether a line was cleared or whether
a box was made, pausing and playing sound effects
"""
extends Control

# constants used when drawing blocks which are connected to other blocks
const CONNECTED_UP = 1
const CONNECTED_DOWN = 2
const CONNECTED_LEFT = 4
const CONNECTED_RIGHT = 8

# playfield dimensions. the playfield extends a few rows higher than what the player can see
const ROW_COUNT = 18
const COL_COUNT = 9

# signal emitted when a line is cleared
signal line_clear

# lines which are currently being cleared
var cleared_lines = []
# total frames to wait when clearing a line/making a box
var line_clear_delay = 0
# remaining frames to wait for clearing the current lines
var remaining_line_clear_frames = 0
# remaining frames to wait for making the current box
var remaining_box_build_frames = 0
# 'true' if the 'line fall sound' should play after the current lines are cleared. The sound doesn't play if nothing
# drops.
var should_play_line_fall_sound = false

# sounds which play as the player continues a combo
onready var combo_sound_arr = [$Combo1Sound, $Combo1Sound, $Combo2Sound, $Combo3Sound, $Combo4Sound, $Combo5Sound,
		$Combo6Sound, $Combo7Sound, $Combo8Sound, $Combo9Sound, $Combo10Sound, $Combo11Sound, $Combo12Sound,
		$Combo13Sound, $Combo14Sound, $Combo15Sound, $Combo16Sound, $Combo17Sound, $Combo18Sound, $Combo19Sound,
		$Combo20Sound]

# bonus points which are awarded as the player continues a combo
var combo_score_arr = [0, 5, 5, 10, 10, 15, 15, 20]

# player's current combo
var combo = 0
# The number of pieces the player has dropped without clearing a line or making a box, plus one.
var combo_break = 0

# total number of seconds for the current game
var stats_seconds = 0
# raw number of cleared lines for the current game, not counting any bonus points
var stats_lines = 0
# total number of bonus points awarded in the current game by clearing pieces
var stats_piece_score = 0
# total number of bonus points awarded in the current game for combos
var stats_combo_score = 0
# 'true' if the player is currently playing, and the time spent should count towards their stats
var clock_running = false

onready var Score = get_node("../Score")

func _ready():
	set_clip_contents(true)
	$TileMap.clear()

"""
Returns true if the Playfield is ready for a new piece to drop; false if it's paused for some kind of animation or delay.
"""
func ready_for_new_piece():
	return remaining_line_clear_frames <= 0 && remaining_box_build_frames <= 0

func _physics_process(delta):
	if clock_running:
		stats_seconds += delta
	
	if line_clear_delay > 0:
		if remaining_box_build_frames > 0:
			remaining_box_build_frames -= 1
			if remaining_box_build_frames <= 0:
				if check_for_line_clear():
					remaining_line_clear_frames = line_clear_delay
				else:
					line_clear_delay = 0
		elif remaining_line_clear_frames > 0:
			remaining_line_clear_frames -= 1
			if remaining_line_clear_frames <= 0:
				line_clear_delay = 0
				if !cleared_lines.empty():
					delete_rows()

"""
Clears the playfield and resets everything for a new game.
"""
func start_game():
	stats_lines = 0
	stats_piece_score = 0
	stats_combo_score = 0
	stats_seconds = 0
	$TileMap.clear()

"""
Writes a piece to the playfield, checking whether it makes any boxes or clears any lines.

Returns true if the newly written piece results in a pause of some sort.
"""
func write_piece(pos, rotation, type, new_line_clear_frames, death_piece = false):
	for i in range(0, type.pos_arr[rotation].size()):
		var block_pos = type.pos_arr[rotation][i]
		var block_color = type.color_arr[rotation][i]
		set_block(pos.x + block_pos.x, pos.y + block_pos.y, block_color)
	
	if death_piece:
		Score.add_score(Score.combo_score)
		Score.set_combo_score(0)
		return false
	
	if check_for_boxes():
		line_clear_delay = new_line_clear_frames
		remaining_box_build_frames = line_clear_delay
		return true
	elif check_for_line_clear():
		line_clear_delay = new_line_clear_frames
		remaining_line_clear_frames = line_clear_delay
		return true
	else:
		line_clear_delay = 0
		return false

"""
Deletes all cleared lines from the playfield, shifting everything above them down to fill the gap.
"""
func delete_rows():
	should_play_line_fall_sound = false
	for cleared_line in cleared_lines:
		delete_row(cleared_line)
	cleared_lines = []
	if should_play_line_fall_sound:
		$LineFallSound.play()

"""
Creates a new integer matrix of the same dimensions as the playfield.
"""
func int_matrix():
	var matrix = []
	for y in range(0, ROW_COUNT):
		matrix.append([])
		for x in range(0, COL_COUNT):
			matrix[y].resize(COL_COUNT)
	return matrix

"""
Calculates the possible locations for a (width x height) rectangle in the playfield, given an integer matrix with the
possible locations for a (1 x height) rectangle in the playfield. These rectangles must consist of dropped pieces which
haven't been split apart by lines. They can't consist of any empty cells or any previously built boxes.

The method name is nonsensical and should be changed.
"""
func discussion_trucks(db, box_height):
	var dt = int_matrix()
	for y in range(0, ROW_COUNT):
		for x in range(0, COL_COUNT):
			if db[y][x] >= box_height:
				if x == 0:
					dt[y][x] = 1
				else:
					dt[y][x] = dt[y][x - 1] + 1
			else:
				dt[y][x] = 0
	return dt

"""
Calculates the possible locations for a (1 x height) rectangle in the playfield, capable of being a part of a 3x3, 3x4, or
3x5 'box'. These rectangles must consist of dropped pieces which haven't been split apart by lines. They can't consist
of any empty cells or any previously built boxes.

The method name is nonsensical and should be changed.
"""
func discussion_bicycles():
	var db = int_matrix()
	for y in range(0, ROW_COUNT):
		for x in range(0, COL_COUNT):
			var piece_color = $TileMap.get_cell(x, y)
			var autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
			if piece_color != -1 and autotile_coord.y != 0 and autotile_coord.y != 18:
				if y == 0:
					db[y][x] = 1
				else:
					db[y][x] = db[y - 1][x] + 1
			else:
				db[y][x] = 0
	return db

"""
Builds any possible 3x3, 3x4 or 3x5 'boxes' in the playfield, returning 'true' if a box was built.
"""
func check_for_boxes():
	# Calculate the possible locations for a (w x h) rectangle in the playfield
	var db = discussion_bicycles()
	var dt3 = discussion_trucks(db, 3)
	var dt4 = discussion_trucks(db, 4)
	var dt5 = discussion_trucks(db, 5)
	
	for y in range(0, ROW_COUNT):
		for x in range(0, COL_COUNT):
			# check for 5x3s (vertical)
			if dt5[y][x] >= 3 and check_for_box(dt3, x - 2, y - 4, 3, 5, true):
				$GoldBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 4x3s (vertical)
			if dt4[y][x] >= 3 and check_for_box(dt3, x - 2, y - 3, 3, 4, true):
				$GoldBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 5x3s (horizontal)
			if dt3[y][x] >= 5 and check_for_box(dt3, x - 4, y - 2, 5, 3, true):
				$GoldBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 4x3s (horizontal)
			if dt3[y][x] >= 4 and check_for_box(dt3, x - 3, y - 2, 4, 3, true):
				$GoldBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 3x3s
			if dt3[y][x] >= 3 and check_for_box(dt3, x - 2, y - 2, 3, 3):
				$SilverBoxSound.play()
				# exit box check; a dropped piece can only make one box, and making a box invalidates the db cache
				remaining_box_build_frames = line_clear_delay
				return true
	return false

"""
Checks whether the specified rectangle represents an enclosed box. An enclosed box must not connect to any pieces
outside the box.

It's assumed the rectangle's coordinates contain only dropped pieces which haven't been split apart by lines, and
no empty cells.
"""
func check_for_box(dt3, x, y, width, height, gold = false):
	for curr_x in range(x, x + width):
		if int($TileMap.get_cell_autotile_coord(curr_x, y).x) & CONNECTED_UP > 0:
			return
		if int($TileMap.get_cell_autotile_coord(curr_x, y + height - 1).x) & CONNECTED_DOWN > 0:
			return
	for curr_y in range(y, y + height):
		if int($TileMap.get_cell_autotile_coord(x, curr_y).x) & CONNECTED_LEFT > 0:
			return
		if int($TileMap.get_cell_autotile_coord(x + width - 1, curr_y).x) & CONNECTED_RIGHT > 0:
			return
	
	# making a piece continues the combo
	combo_break = 0
	
	var offset
	if gold:
		offset = 7
	else:
		offset = 16
	
	# corners
	set_block(x + 0, y + 0, Vector2(offset + 0, 18))
	set_block(x + width - 1, y + 0, Vector2(offset + 2, 18))
	set_block(x + 0, y + height - 1, Vector2(offset + 6, 18))
	set_block(x + width - 1, y + height - 1, Vector2(offset + 8, 18))
	
	# top/bottom edge
	for curr_x in range(x + 1, x + width - 1):
		set_block(curr_x, y + 0, Vector2(offset + 1, 18))
		set_block(curr_x, y + height - 1, Vector2(offset + 7, 18))
	
	# center
	for curr_x in range(x + 1, x + width - 1):
		for curr_y in range(y + 1, y + height - 1):
			set_block(curr_x, curr_y, Vector2(offset + 4, 18))
	
	# left/right edge
	for curr_y in range(y + 1, y + height - 1):
		set_block(x + 0, curr_y, Vector2(offset + 3, 18))
		set_block(x + width - 1, curr_y, Vector2(offset + 5, 18))
	
	return true

"""
Checks whether any lines in the playfield are full and should be cleared. Updates the combo, awards points, and plays
sounds appropriately. Returns 'true' if any lines were cleared.
"""
func check_for_line_clear():
	var total_points = 0
	var piece_points = 0
	for y in range(0, ROW_COUNT):
		if row_is_full(y):
			var line_score = 1
			line_score += combo_score_arr[clamp(combo, 0, combo_score_arr.size() - 1)]
			stats_lines += 1
			stats_combo_score += combo_score_arr[clamp(combo, 0, combo_score_arr.size() - 1)]
			cleared_lines.append(y)
			for x in range(0, COL_COUNT):
				var autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
				if autotile_coord.y == 18:
					if autotile_coord.x == 7 || autotile_coord.x == 10 || autotile_coord.x == 13:
						# gold piece
						line_score += 10
						stats_piece_score += 10
						piece_points = max(piece_points, 2)
					elif autotile_coord.x == 16 || autotile_coord.x == 19 || autotile_coord.x == 22:
						# silver piece
						line_score += 5
						stats_piece_score += 5
						piece_points = max(piece_points, 1)
			Score.add_combo_score(line_score - 1)
			Score.add_score(1)
			clear_row(y)
			remaining_line_clear_frames = line_clear_delay
			line_score = max(1, line_score)
			total_points += line_score
			
			# clearing lines adds to the combo
			combo += 1
			combo_break = 0
		
	combo_break += 1
	if combo_break >= 3:
		if combo >= 15:
			$Fanfare3.play()
		elif combo >= 10:
			$Fanfare2.play()
		elif combo >= 5:
			$Fanfare1.play()
		Score.add_score(Score.combo_score)
		Score.set_combo_score(0)
		combo = 0
	
	if total_points > 0:
		play_line_clear_sfx(cleared_lines, combo, piece_points)
		emit_signal("line_clear")
	
	return total_points > 0

"""
Play sound effects for clearing a line. A cleared line can result in several sound effects getting queued and played
consecutively.
"""
func play_line_clear_sfx(cleared_lines, combo, piece_points):
	var scheduled_sfx = []
	
	# determine the main line-clear sound effect, which plays for clearing any line
	if cleared_lines.size() == 1:
		scheduled_sfx.append($Erase1Sound)
	elif cleared_lines.size() == 2:
		scheduled_sfx.append($Erase2Sound)
	else:
		scheduled_sfx.append($Erase3Sound)
	
	# determine any combo sound effects, which play for continuing a combo
	for combo_sfx in range(combo - cleared_lines.size(), combo):
		if combo_sfx > 0:
			scheduled_sfx.append(combo_sound_arr[min(combo_sfx, combo_sound_arr.size() - 1)])
	if piece_points == 1:
		scheduled_sfx.append($ClearSilverPieceSound)
	elif piece_points >= 2:
		scheduled_sfx.append($ClearGoldPieceSound)
	
	# play the calculated sound effects
	if scheduled_sfx.size() > 0:
		# play the first sound effect immediately
		scheduled_sfx[0].play()
		# enqueue other sound effects and play them later
		for sfx_index in range(1, scheduled_sfx.size()):
			yield(get_tree().create_timer(0.025 * sfx_index), "timeout")
			scheduled_sfx[sfx_index].play()

func row_is_full(y):
	for x in range(0, COL_COUNT):
		if is_cell_empty(x, y):
			return false
	return true

"""
Clear all cells in the specified row. This leaves any pieces above them floating in mid-air.
"""
func clear_row(y):
	for x in range(0, COL_COUNT):
		disconnect_block(x, y)
		clear_block(x, y)

"""
Deletes the specified row in the playfield, dropping all higher rows down to fill the gap.
"""
func delete_row(y):
	for curr_y in range(y, 0, -1):
		for x in range(0, COL_COUNT):
			var piece_color = $TileMap.get_cell(x, curr_y - 1)
			var autotile_coord = $TileMap.get_cell_autotile_coord(x, curr_y - 1)
			$TileMap.set_cell(x, curr_y, piece_color, false, false, false, autotile_coord)
			if piece_color == 0:
				# only play the line falling sound if at least one piece falls
				should_play_line_fall_sound = true
	
	# remove row
	for x in range(0, COL_COUNT):
		clear_block(x, 0)

"""
Disconnects the specified block from all blocks it's connected to, directly or indirectly. All disconnected blocks are
flagged to ensure they can't be included in 'boxes' in the future.
"""
func disconnect_block(x, y):
	# store connections
	var old_autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
	
	if old_autotile_coord.y == 18:
		# don't disconnect pieces... we don't have the graphics for it
		return
	
	# disconnect
	set_block(x, y, Vector2(0, 0))
	
	if y > 0 && int(old_autotile_coord.x) & CONNECTED_UP > 0:
		disconnect_block(x, y - 1)
	
	if y < ROW_COUNT - 1 && int(old_autotile_coord.x) & CONNECTED_DOWN > 0:
		disconnect_block(x, y + 1)
	
	if x > 0 && int(old_autotile_coord.x) & CONNECTED_LEFT > 0:
		disconnect_block(x - 1, y)
	
	if x < COL_COUNT - 1 && int(old_autotile_coord.x) & CONNECTED_RIGHT > 0:
		disconnect_block(x + 1, y)

func set_block(x, y, block_color):
	$TileMap.set_cell(x, y, 0, false, false, false, block_color)

func clear_block(x, y):
	$TileMap.set_cell(x, y, -1)

func is_cell_empty(x, y):
	return $TileMap.get_cell(x, y) == -1