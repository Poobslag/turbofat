extends Control

const CONNECTED_UP = 1
const CONNECTED_DOWN = 2
const CONNECTED_LEFT = 4
const CONNECTED_RIGHT = 8

signal line_clear

var row_count = 18
var col_count = 9

var cleared_lines = []
var line_clear_delay = 0
var remaining_line_clear_frames = 0
var remaining_box_build_frames = 0
var should_play_line_fall_sound = false

onready var combo_sound_arr = [$Combo1Sound, $Combo1Sound, $Combo2Sound, $Combo3Sound, $Combo4Sound, $Combo5Sound,
		$Combo6Sound, $Combo7Sound, $Combo8Sound, $Combo9Sound, $Combo10Sound, $Combo11Sound, $Combo12Sound,
		$Combo13Sound, $Combo14Sound, $Combo15Sound, $Combo16Sound, $Combo17Sound, $Combo18Sound, $Combo19Sound,
		$Combo20Sound]
var combo_score_arr = [0, 5, 5, 10, 10, 15, 15, 20]
var combo = 0
var combo_break = 0

var stats_lines = 0
var stats_seconds = 0
var stats_block_score = 0
var stats_combo_score = 0

var clock_running = false

onready var Score = get_node("../Score")

func _ready():
	set_clip_contents(true)
	$TileMap.clear()

"""
Returns true if the Grid is ready for a new block to drop; false if it's paused for some kind of animation or delay.
"""
func ready_for_new_block():
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

func start_game():
	stats_lines = 0
	stats_block_score = 0
	stats_combo_score = 0
	stats_seconds = 0
	$TileMap.clear()

func write_block(pos, rotation, type, new_line_clear_frames, death_block = false):
	for i in range(0, type.pos_arr[rotation].size()):
		var cubit_pos = type.pos_arr[rotation][i]
		var cubit_color = type.color_arr[rotation][i]
		set_cell(pos.x + cubit_pos.x, pos.y + cubit_pos.y, cubit_color)
	
	if death_block:
		Score.add_score(Score.combo_score)
		Score.set_combo_score(0)
		return
	
	if check_for_boxes():
		line_clear_delay = new_line_clear_frames
		remaining_box_build_frames = line_clear_delay
	elif check_for_line_clear():
		line_clear_delay = new_line_clear_frames
		remaining_line_clear_frames = line_clear_delay
	else:
		line_clear_delay = 0

func delete_rows():
	should_play_line_fall_sound = false
	for cleared_line in cleared_lines:
		delete_row(cleared_line)
	cleared_lines = []
	if should_play_line_fall_sound:
		$LineFallSound.play()

func int_matrix():
	var matrix = []
	for y in range(0, row_count):
		matrix.append([])
		for x in range(0, col_count):
			matrix[y].resize(col_count)
	return matrix

func discussion_trucks(vv, box_height):
	var wv = int_matrix()
	for y in range(0, row_count):
		for x in range(0, col_count):
			if vv[y][x] >= box_height:
				if x == 0:
					wv[y][x] = 1
				else:
					wv[y][x] = wv[y][x - 1] + 1
			else:
				wv[y][x] = 0
	return wv

func check_for_boxes():
	# counts the number of consecutive filled cubits, vertically. used for detecting boxes
	var vv = int_matrix()
	
	for y in range(0, row_count):
		for x in range(0, col_count):
			var block_color = $TileMap.get_cell(x, y)
			var autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
			if block_color != -1 and autotile_coord.y != 0 and autotile_coord.y != 18:
				if y == 0:
					vv[y][x] = 1
				else:
					vv[y][x] = vv[y - 1][x] + 1
			else:
				vv[y][x] = 0
	
	var wv3 = discussion_trucks(vv, 3)
	var wv4 = discussion_trucks(vv, 4)
	var wv5 = discussion_trucks(vv, 5)
	
	for y in range(0, row_count):
		for x in range(0, col_count):
			# check for 5x3s (vertical)
			if wv5[y][x] >= 3 and check_for_box(wv3, x - 2, y - 4, 3, 5, true):
				$GoldBoxSound.play()
				# exit box check; a block can only make one box, and making a box invalidates the vv cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 4x3s (vertical)
			if wv4[y][x] >= 3 and check_for_box(wv3, x - 2, y - 3, 3, 4, true):
				$GoldBoxSound.play()
				# exit box check; a block can only make one box, and making a box invalidates the vv cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 5x3s (horizontal)
			if wv3[y][x] >= 5 and check_for_box(wv3, x - 4, y - 2, 5, 3, true):
				$GoldBoxSound.play()
				# exit box check; a block can only make one box, and making a box invalidates the vv cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 4x3s (horizontal)
			if wv3[y][x] >= 4 and check_for_box(wv3, x - 3, y - 2, 4, 3, true):
				$GoldBoxSound.play()
				# exit box check; a block can only make one box, and making a box invalidates the vv cache
				remaining_box_build_frames = line_clear_delay
				return true
			
			# check for 3x3s
			if wv3[y][x] >= 3 and check_for_box(wv3, x - 2, y - 2, 3, 3):
				$SilverBoxSound.play()
				# exit box check; a block can only make one box, and making a box invalidates the vv cache
				remaining_box_build_frames = line_clear_delay
				return true
	
	return false

func check_for_box(wv3, x, y, width, height, gold = false):
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
	
	# making a block continues the combo
	combo_break = 0
	
	var offset
	if gold:
		offset = 7
	else:
		offset = 16
	
	# corners
	$TileMap.set_cell(x + 0, y + 0, 0, false, false, false, Vector2(offset + 0, 18))
	$TileMap.set_cell(x + width - 1, y + 0, 0, false, false, false, Vector2(offset + 2, 18))
	$TileMap.set_cell(x + 0, y + height - 1, 0, false, false, false, Vector2(offset + 6, 18))
	$TileMap.set_cell(x + width - 1, y + height - 1, 0, false, false, false, Vector2(offset + 8, 18))
	
	# top/bottom edge
	for curr_x in range(x + 1, x + width - 1):
		$TileMap.set_cell(curr_x, y + 0, 0, false, false, false, Vector2(offset + 1, 18))
		$TileMap.set_cell(curr_x, y + height - 1, 0, false, false, false, Vector2(offset + 7, 18))
	
	# center
	for curr_x in range(x + 1, x + width - 1):
		for curr_y in range(y + 1, y + height - 1):
			$TileMap.set_cell(curr_x, curr_y, 0, false, false, false, Vector2(offset + 4, 18))
	
	# left/right edge
	for curr_y in range(y + 1, y + height - 1):
		$TileMap.set_cell(x + 0, curr_y, 0, false, false, false, Vector2(offset + 3, 18))
		$TileMap.set_cell(x + width - 1, curr_y, 0, false, false, false, Vector2(offset + 5, 18))
	
	return true

func check_for_line_clear():
	var total_points = 0
	var block_points = 0
	for y in range(0, row_count):
		if row_is_full(y):
			var line_score = 1
			line_score += combo_score_arr[clamp(combo, 0, combo_score_arr.size() - 1)]
			stats_lines += 1
			stats_combo_score += combo_score_arr[clamp(combo, 0, combo_score_arr.size() - 1)]
			cleared_lines.append(y)
			for x in range(0, col_count):
				var autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
				if autotile_coord.y == 18:
					if autotile_coord.x == 7 || autotile_coord.x == 10 || autotile_coord.x == 13:
						# gold block
						line_score += 10
						stats_block_score += 10
						block_points = max(block_points, 2)
					elif autotile_coord.x == 16 || autotile_coord.x == 19 || autotile_coord.x == 22:
						# silver block
						line_score += 5
						stats_block_score += 5
						block_points = max(block_points, 1)
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
		play_line_clear_sfx(cleared_lines, combo, block_points)
		emit_signal("line_clear")
	
	return total_points > 0

func play_line_clear_sfx(cleared_lines, combo, block_points):
	var scheduled_sfx = []
	if cleared_lines.size() == 1:
		scheduled_sfx.append($Erase1Sound)
	elif cleared_lines.size() == 2:
		scheduled_sfx.append($Erase2Sound)
	else:
		scheduled_sfx.append($Erase3Sound)
	var chain_sound_count = 0
	for combo_sfx in range(combo - cleared_lines.size(), combo):
		if combo_sfx > 0:
			scheduled_sfx.append(combo_sound_arr[min(combo_sfx, combo_sound_arr.size() - 1)])
	if block_points == 1:
		scheduled_sfx.append($ClearSilverBlockSound)
	elif block_points >= 2:
		scheduled_sfx.append($ClearGoldBlockSound)
	if scheduled_sfx.size() > 0:
		scheduled_sfx[0].play()
		for sfx_index in range(1, scheduled_sfx.size()):
			yield(get_tree().create_timer(0.025 * sfx_index), "timeout")
			scheduled_sfx[sfx_index].play()

func row_is_full(y):
	for x in range(0, col_count):
		if is_cell_empty(x, y):
			return false
	return true

func clear_row(y):
	for x in range(0, col_count):
		disconnect_cubit(x, y)
		$TileMap.set_cell(x, y, -1)

func delete_row(y):
	for curr_y in range(y, 0, -1):
		for x in range(0, col_count):
			var block_color = $TileMap.get_cell(x, curr_y - 1)
			var autotile_coord = $TileMap.get_cell_autotile_coord(x, curr_y - 1)
			$TileMap.set_cell(x, curr_y, block_color, false, false, false, autotile_coord)
			if block_color == 0:
				# only play the line falling sound if at least one block falls
				should_play_line_fall_sound = true
	
	# remove row
	for x in range(0, col_count):
		$TileMap.set_cell(x, 0, -1)

func disconnect_cubit(x, y):
	# store connections
	var old_autotile_coord = $TileMap.get_cell_autotile_coord(x, y)
	
	if old_autotile_coord.y == 18:
		# don't disconnect blocks... we don't have the graphics for it
		return
	
	# disconnect
	$TileMap.set_cell(x, y, 0, false, false, false, Vector2(0, 0))
	
	if y > 0 && int(old_autotile_coord.x) & CONNECTED_UP > 0:
		disconnect_cubit(x, y - 1)
	
	if y < row_count - 1 && int(old_autotile_coord.x) & CONNECTED_DOWN > 0:
		disconnect_cubit(x, y + 1)
	
	if x > 0 && int(old_autotile_coord.x) & CONNECTED_LEFT > 0:
		disconnect_cubit(x - 1, y)
	
	if x < col_count - 1 && int(old_autotile_coord.x) & CONNECTED_RIGHT > 0:
		disconnect_cubit(x + 1, y)

func set_cell(x, y, block_color):
	$TileMap.set_cell(x, y, 0, false, false, false, block_color)

func is_cell_empty(x, y):
	return $TileMap.get_cell(x, y) == -1