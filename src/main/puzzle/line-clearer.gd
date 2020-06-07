class_name LineClearer
extends Node
"""
Clears lines in a tilemap as new pieces are placed.

Lines are cleared when the player completes rows, tops out or completes a level.
"""

# emitted before a 'line clear' where a line is erased and the player is rewarded
signal before_line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted after a 'line clear' where a line is erased and the player is rewarded
signal line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted when a line is erased. this includes line clears but also top outs and non-scoring end game rows.
signal line_erased(y, total_lines, remaining_lines, box_ints)

# emitted when erased lines are deleted, causing the rows above them to drop down
signal lines_deleted

# percent of the line clear delay which should be spent erasing lines.
# 1.0 = erase lines slowly one at a time, 0.0 = erase all lines immediately
const LINE_ERASE_TIMING_PCT := 0.667

export (NodePath) var _tile_map_path: NodePath

# lines currently being cleared/erased as a part of _physics_process
var lines_being_cleared := []
var lines_being_erased := []

# remaining frames to wait for erasing the current lines
var remaining_line_erase_frames := 0

# the index of the next line to clear/erase as a part of _physics_process
var _cleared_line_index := 0
var _erased_line_index := 0

# timing values for lines currently being erased as a part of _physics_process.
# lines are cleared/erased when 'remaining_line_erase_frames' falls below the values in these arrays.
var _remaining_line_clear_timings := []
var _remaining_line_erase_timings := []

onready var _tile_map: PuzzleTileMap = get_node(_tile_map_path)

func _ready() -> void:
	set_physics_process(false)
	PuzzleScore.connect("finish_triggered", self, "_on_PuzzleScore_finish_triggered")


func _physics_process(delta: float) -> void:
	# clear lines from lines_being_cleared
	while _cleared_line_index < lines_being_cleared.size() \
			and remaining_line_erase_frames <= _remaining_line_clear_timings[_cleared_line_index]:
		clear_line(lines_being_cleared[_cleared_line_index],
				lines_being_cleared.size() + lines_being_erased.size(),
				lines_being_cleared.size() + lines_being_erased.size()
					- _cleared_line_index - _erased_line_index - 1)
		_cleared_line_index += 1

	# erase lines from lines_being_erased
	while _erased_line_index < lines_being_erased.size() \
			and remaining_line_erase_frames <= _remaining_line_erase_timings[_erased_line_index]:
		_erase_line(lines_being_erased[_erased_line_index],
				lines_being_cleared.size() + lines_being_erased.size(),
				lines_being_cleared.size() + lines_being_erased.size()
					- _cleared_line_index - _erased_line_index - 1)
		_erased_line_index += 1

	remaining_line_erase_frames -= 1
	if remaining_line_erase_frames <= 0:
		# stop processing if we're done clearing lines
		_delete_rows()
		emit_signal("lines_deleted")
		set_physics_process(false)


"""
Clears a full line in the playfield as a reward.

Updates the combo, awards points, and triggers things like sounds or creatures eating.
"""
func clear_line(y: int, total_lines: int, remaining_lines: int) -> void:
	var box_ints:= _box_ints(y)
	emit_signal("before_line_cleared", y, total_lines, remaining_lines, box_ints)
	_erase_line(y, total_lines, remaining_lines)
	emit_signal("line_cleared", y, total_lines, remaining_lines, box_ints)


"""
Schedules any full rows to be cleared later.
"""
func schedule_full_row_line_clears() -> void:
	var lines_to_clear := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _tile_map.playfield_row_is_full(y):
			lines_to_clear.append(y)
	if lines_to_clear:
		schedule_line_clears(lines_to_clear, PieceSpeeds.current_speed.line_clear_delay)


"""
Schedules the specified lines to be cleared later.
"""
func schedule_line_clears(lines_to_clear: Array, line_clear_delay: int, award_points: bool = true) -> void:
	var unscheduled_clears := []
	var unscheduled_erases := []
	if award_points:
		for y in lines_to_clear:
			if _box_ints(y) or _tile_map.playfield_row_is_full(y):
				unscheduled_clears.append(y)
			else:
				unscheduled_erases.append(y)
	else:
		for y in lines_to_clear:
			unscheduled_erases.append(y)
	
	_cleared_line_index = 0
	_erased_line_index = 0
	_remaining_line_clear_timings.clear()
	_remaining_line_erase_timings.clear()
	lines_being_cleared = []
	lines_being_erased = []
	
	var closest_clears := closest_clears(unscheduled_clears, unscheduled_erases)
	var erased_line_count := 0
	while unscheduled_clears:
		# schedule the next cleared line
		var next_clear: int = unscheduled_clears.pop_front()
		_remaining_line_clear_timings.append(erased_line_count)
		lines_being_cleared.append(next_clear)
		# schedule any erased lines which are close to this line clear to be cleared simultaneously
		for i in range(unscheduled_erases.size() - 1, -1, -1):
			if closest_clears[i] == next_clear:
				_remaining_line_erase_timings.append(erased_line_count)
				lines_being_erased.append(unscheduled_erases[i])
				unscheduled_erases.remove(i)
				closest_clears.remove(i)
		erased_line_count += 1
	
	while unscheduled_erases:
		_remaining_line_erase_timings.append(erased_line_count)
		lines_being_erased.append(unscheduled_erases.pop_front())
		erased_line_count += 1
	
	# Convert all timings from [0, 1, 2...] to delays like [264, 232, 200...]
	remaining_line_erase_frames = max(1, line_clear_delay)
	var _line_erase_timing_window := LINE_ERASE_TIMING_PCT * remaining_line_erase_frames
	var _per_line_frame_delay := floor(_line_erase_timing_window / max(1, erased_line_count - 1))
	for i in range(lines_being_cleared.size()):
		_remaining_line_clear_timings[i] = remaining_line_erase_frames \
			- _remaining_line_clear_timings[i] * _per_line_frame_delay
	for i in range(lines_being_erased.size()):
		_remaining_line_erase_timings[i] = remaining_line_erase_frames \
			- _remaining_line_erase_timings[i] * _per_line_frame_delay


"""
Erases all cells in the specified row.

This can be invoked as a part of a 'line clear', or as a part of a top out or something mundane. It does not increase
the combo or award points.
"""
func _erase_line(y: int, total_lines: int, remaining_lines: int) -> void:
	var box_ints:= _box_ints(y)
	_tile_map.erase_playfield_row(y)
	emit_signal("line_erased", y, total_lines, remaining_lines, box_ints)


"""
Deletes all erased rows from the playfield, dropping all rows above them.
"""
func _delete_rows() -> void:
	# Calculate whether anything is dropping which will trigger the line fall sound.
	var play_sound := false
	var lines_to_delete := lines_being_cleared + lines_being_erased
	var max_line := Utils.max_value(lines_to_delete)
	for y in range(0, max_line):
		if not _tile_map.playfield_row_is_empty(y) and not lines_to_delete.has(y):
			play_sound = true
			break
	
	_tile_map.delete_rows(lines_to_delete)
	
	if play_sound:
		$LineFallSound.play()


"""
Returns a list of food colors in the specified row.

The resulting array can be any of the following:
	1. an empty array, [], for a row of vegetables or disjointed pieces
	2. [BROWN], [PINK], [BREAD] or [WHITE] if the row has a snack box
	3. [CAKE] if the row has a cake box
	4. an array with multiple items, if the row has many boxes
"""
func _box_ints(y: int) -> Array:
	var box_ints: Array = []
	for x in range(PuzzleTileMap.COL_COUNT):
		var autotile_coord := _tile_map.get_cell_autotile_coord(x, y)
		if _tile_map.get_cell(x, y) == 1 and not Connect.is_l(autotile_coord.x):
			box_ints.append(int(autotile_coord.y))
	box_ints.shuffle()
	return box_ints


"""
Schedules line clears which occur when a puzzle is finished.

Any full lines and lines containing boxes result in line clears, and the player is awarded points.

Any partial lines containing only vegetables are erased, the player is not awarded points for those.
"""
func _schedule_finish_line_clears() -> void:
	# count how many rows are to be cleared; don't count mostly-empty rows
	var box_line_count := 0
	
	var full_lines := []
	var partial_lines := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _tile_map.playfield_row_is_full(y):
			full_lines.append(y)
		elif not _tile_map.playfield_row_is_empty(y):
			partial_lines.append(y)
			if _box_ints(y):
				box_line_count += 1
	NearestSorter.new().sort(partial_lines, Utils.mean(full_lines + lines_being_cleared, 0.0))
	var lines_to_clear := full_lines + partial_lines
	
	# schedule line clears, same pace as clearing three lines concurrently
	if full_lines or box_line_count > 0:
		# hard-code the line clear delay; faster values don't look good
		var line_clear_delay := 24
		var total_duration: int = line_clear_delay * ((box_line_count - 1) / 3.0) / LINE_ERASE_TIMING_PCT
		schedule_line_clears(lines_to_clear, total_duration, true)
	
		# insert a small delay
		var small_delay: int = line_clear_delay / 3.0
		remaining_line_erase_frames += small_delay
		
		# adjust all the timings so that the level ends simultaneously with the last line clear
		if lines_being_cleared:
			var min_line_clear_timing: int = _remaining_line_clear_timings[0]
			for line_clear_timing in _remaining_line_clear_timings:
				min_line_clear_timing = min(min_line_clear_timing, line_clear_timing)
			min_line_clear_timing -= 1
			for i in range(_remaining_line_clear_timings.size()):
				_remaining_line_clear_timings[i] -= min_line_clear_timing
			for i in range(_remaining_line_erase_timings.size()):
				_remaining_line_erase_timings[i] -= min_line_clear_timing
			remaining_line_erase_frames -= min_line_clear_timing


func _on_PuzzleScore_finish_triggered() -> void:
	if Scenario.settings.other.clear_on_finish:
		_schedule_finish_line_clears()
	else:
		PuzzleScore.end_game()


"""
Non-full vegetable lines are erased simultaneously with the nearest line clear.

This method takes a list of cleared lines and erased lines, and pairs all of the erased lines to the nearest cleared
line.
"""
static func closest_clears(lines_being_cleared: Array, lines_being_erased: Array) -> Array:
	var closest_clears := lines_being_erased.duplicate()
	if not lines_being_cleared:
		return closest_clears
	
	for i in range(lines_being_erased.size()): 
		closest_clears[i] = lines_being_cleared[0]
		for j in range(1, lines_being_cleared.size()):
			if abs(lines_being_erased[i] - lines_being_cleared[j]) < abs(lines_being_erased[i] - closest_clears[i]):
				closest_clears[i] = lines_being_cleared[j]
	return closest_clears
