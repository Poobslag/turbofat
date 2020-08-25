class_name LineClearer
extends Node
"""
Clears lines in a tilemap as new pieces are placed.

Lines are cleared when the player completes rows, tops out or completes a level.
"""

# emitted shortly before a set of lines are cleared
signal line_clears_scheduled(ys)

# emitted before a 'line clear' where a line is erased and the player is rewarded
signal before_line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted after a 'line clear' where a line is erased and the player is rewarded
signal line_cleared(y, total_lines, remaining_lines, box_ints)

# emitted when a line is erased. this includes line clears but also top outs and non-scoring end game rows.
signal line_erased(y, total_lines, remaining_lines, box_ints)

# emitted when erased lines are deleted, causing the rows above them to drop down
signal lines_deleted(lines)

# percent of the line clear delay which should be spent erasing lines.
# 1.0 = erase lines slowly one at a time, 0.0 = erase all lines immediately
const LINE_ERASE_TIMING_PCT := 0.667

export (NodePath) var tile_map_path: NodePath

# lines currently being cleared/erased/deleted as a part of _physics_process
var lines_being_cleared := []
var lines_being_erased := []
var lines_being_deleted := []

# remaining frames to wait for erasing the current lines
var remaining_line_erase_frames := 0

# the index of the next line to clear/erase as a part of _physics_process
var _cleared_line_index := 0
var _erased_line_index := 0

# timing values for lines currently being erased as a part of _physics_process.
# lines are cleared/erased when 'remaining_line_erase_frames' falls below the values in these arrays.
var _remaining_line_clear_timings := []
var _remaining_line_erase_timings := []

# rows containing prebuilt level boxes, which aren't cleared at the end of the level.
var _rows_to_preserve_at_end := {}

onready var _tile_map: PuzzleTileMap = get_node(tile_map_path)
onready var _line_fall_sound: AudioStreamPlayer = $LineFallSound

func _ready() -> void:
	set_physics_process(false)
	PuzzleState.connect("finish_triggered", self, "_on_PuzzleState_finish_triggered")


func _physics_process(_delta: float) -> void:
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
		# Disable processing and reset our state. We need to do this before deleting lines, because deleting lines can
		# potentially trigger the end of the level which in turn schedules more line clears.
		var old_lines_being_deleted := lines_being_deleted
		set_physics_process(false)
		lines_being_cleared = []
		lines_being_erased = []
		lines_being_deleted = []
		
		_delete_lines(old_lines_being_deleted)


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
	lines_being_deleted = []
	
	while unscheduled_clears:
		# schedule the next cleared line
		var next_clear: int = unscheduled_clears.pop_front()
		_remaining_line_clear_timings.append(lines_being_cleared.size() + lines_being_erased.size())
		lines_being_cleared.append(next_clear)
		lines_being_deleted.append(next_clear)
	
	while unscheduled_erases:
		var next_erase: int = unscheduled_erases.pop_front()
		_remaining_line_erase_timings.append(lines_being_cleared.size() + lines_being_erased.size())
		lines_being_erased.append(next_erase)
		lines_being_deleted.append(next_erase)
	
	# Convert all timings from [0, 1, 2...] to delays like [264, 232, 200...]
	remaining_line_erase_frames = max(1, line_clear_delay)
	var per_line_frame_delay := _per_line_frame_delay()
	for i in range(lines_being_cleared.size()):
		_remaining_line_clear_timings[i] = remaining_line_erase_frames \
			- _remaining_line_clear_timings[i] * per_line_frame_delay
	for i in range(lines_being_erased.size()):
		_remaining_line_erase_timings[i] = remaining_line_erase_frames \
			- _remaining_line_erase_timings[i] * per_line_frame_delay
	
	if lines_being_cleared:
		emit_signal("line_clears_scheduled", lines_being_cleared)


func _per_line_frame_delay() -> float:
	var line_erase_timing_window := LINE_ERASE_TIMING_PCT * remaining_line_erase_frames
	return floor(line_erase_timing_window / max(1, lines_being_cleared.size() + lines_being_erased.size() - 1))


"""
Erases all cells in the specified row.

This can be invoked as a part of a 'line clear', or as a part of a top out or something mundane. It does not increase
the combo or award points.
"""
func _erase_line(y: int, total_lines: int, remaining_lines: int) -> void:
	var box_ints:= _box_ints(y)
	_tile_map.erase_playfield_row(y)
	if _rows_to_preserve_at_end:
		_rows_to_preserve_at_end.erase(y)
	emit_signal("line_erased", y, total_lines, remaining_lines, box_ints)


"""
Deletes rows from the playfield, dropping all rows above them.
"""
func _delete_lines(lines: Array) -> void:
	# Calculate whether anything is dropping which will trigger the line fall sound.
	var play_sound := false
	
	if CurrentLevel.settings.blocks_during.line_clear_type == BlocksDuringRules.LineClearType.FLOAT_FALL:
		# instead of deleting the filled lines, delete the bottom lines
		for i in range(lines.size()):
			lines[i] = PuzzleTileMap.ROW_COUNT - i - 1
	elif CurrentLevel.settings.blocks_during.line_clear_type == BlocksDuringRules.LineClearType.FLOAT:
		# don't delete the filled lines
		lines = []
	
	lines.sort()
	var max_line: int = lines.back() if lines else -1
	for y in range(0, max_line):
		if not _tile_map.playfield_row_is_empty(y) and not lines.has(y):
			play_sound = true
			break
	
	if lines:
		_tile_map.delete_rows(lines)
	
	if play_sound:
		_line_fall_sound.play()
	
	if _rows_to_preserve_at_end:
		# Shift all _rows_to_preserve_at_end entries above the deleted rows
		for line_being_deleted in lines:
			var _new_rows_to_preserve_at_end := {}
			for key in _rows_to_preserve_at_end:
				var new_key: int = key
				if key < line_being_deleted:
					new_key += 1
				_new_rows_to_preserve_at_end[new_key] = true
			_rows_to_preserve_at_end = _new_rows_to_preserve_at_end
	
	# we even emit the signal if zero lines are deleted.
	# the 'lines_deleted' signal triggers other important events
	emit_signal("lines_deleted", lines)


"""
Returns a list of food colors in the specified row.

The resulting array can be any of the following:
	1. an empty array, [], for a row of vegetables or disjointed pieces
	2. [BROWN], [PINK], [BREAD] or [WHITE] if the row has a snack box
	3. [CAKE] if the row has a cake box
	4. an array with multiple items, if the row has many boxes

A horizontal box results in multiple duplicate box ints being added. This is by design to result in larger scoring
bonuses for horizontal boxes, as they're less efficient.
"""
func _box_ints(y: int) -> Array:
	var box_ints := []
	for x in range(PuzzleTileMap.COL_COUNT):
		var autotile_coord := _tile_map.get_cell_autotile_coord(x, y)
		var right_autotile_coord := _tile_map.get_cell_autotile_coord(x + 1, y)
		if _tile_map.get_cell(x, y) == 1:
			var should_count: bool = false
			if PuzzleConnect.is_l(autotile_coord.x) and PuzzleConnect.is_r(autotile_coord.x):
				# wide boxes count multiple times to reward difficult horizontal builds
				should_count = true
			elif not PuzzleConnect.is_l(autotile_coord.x) and \
					(not PuzzleConnect.is_r(autotile_coord.x) or not PuzzleConnect.is_r(right_autotile_coord.x)):
				# narrow boxes (1 wide, 2 wide) still count
				should_count = true
			if should_count:
				box_ints.append(int(autotile_coord.y))
	box_ints.shuffle()
	return box_ints


"""
Schedules line clears which occur when a puzzle is finished.

Any full lines and lines containing boxes result in line clears, and the player is awarded points.

Any partial lines containing only vegetables are left behind, the player is not awarded points for those.
"""
func _schedule_finish_line_clears() -> void:
	var full_lines := []
	var box_lines := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _tile_map.playfield_row_is_full(y):
			full_lines.append(y)
		elif _box_ints(y) and not _rows_to_preserve_at_end.has(y):
			box_lines.append(y)
	NearestSorter.new().sort(box_lines, Utils.mean(full_lines + lines_being_cleared, 0.0))
	var lines_to_clear := full_lines + box_lines
	
	# schedule line clears, same pace as clearing three lines concurrently
	if full_lines or box_lines:
		# hard-code the line clear delay; faster values don't look good
		var line_clear_delay := 24
		var total_duration: int = line_clear_delay * ((box_lines.size() - 1) / 3.0) / LINE_ERASE_TIMING_PCT
		var old_lines_being_deleted := lines_being_deleted.duplicate()
		var was_clearing_lines: bool = lines_being_cleared or lines_being_erased
		
		schedule_line_clears(lines_to_clear, total_duration, true)
		
		# preserve full lines which were already being deleted
		for line in old_lines_being_deleted:
			if not lines_being_deleted.has(line):
				lines_being_deleted.append(line)
		
		# if we were already clearing lines, we pause before triggering additional line clears
		if was_clearing_lines:
			remaining_line_erase_frames += _per_line_frame_delay()
	
	# ensure remaining_line_erase_frames is always set to a non-zero value. the level end is triggered when this
	# number decreases from 1 to 0, so if it ends up being 0 or less it causes a softlock
	remaining_line_erase_frames = max(1, remaining_line_erase_frames)


func _on_PuzzleState_finish_triggered() -> void:
	if CurrentLevel.settings.other.clear_on_finish:
		_schedule_finish_line_clears()
	else:
		PuzzleState.end_game()


"""
When a new set of blocks is loaded, we recalculate the rows to preserve at the end.

Any prebuilt level boxes aren't cleared at the end of the level.
"""
func _on_Playfield_blocks_prepared() -> void:
	_rows_to_preserve_at_end.clear()
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cell(cell.x, cell.y) == 1:
			_rows_to_preserve_at_end[int(cell.y)] = true


"""
When a box is made, we remove those rows from the rows to preserve at the end.

Any prebuilt level boxes aren't cleared at the end of the level, but if the player makes additional boxes next to
them, then they're cleared.
"""
func _on_BoxBuilder_box_built(rect: Rect2, _color_int: int) -> void:
	if _rows_to_preserve_at_end:
		for y in range(rect.position.y, rect.end.y):
			_rows_to_preserve_at_end.erase(y)
