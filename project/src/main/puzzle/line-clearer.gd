class_name LineClearer
extends Node
## Clears lines in a puzzle tilemap as new pieces are placed.
##
## Lines are cleared when the player completes rows, tops out or completes a level.

## emitted after a 'line clear' if the player cleared the final line.
signal all_lines_cleared

## emitted shortly before a set of lines are cleared
signal line_clears_scheduled(y_coords)

## emitted before a 'line clear' where a line is erased and the player is rewarded
signal before_line_cleared(y, total_lines, remaining_lines, box_ints)

## emitted after a 'line clear' where a line is erased and the player is rewarded
signal line_cleared(y, total_lines, remaining_lines, box_ints)

## emitted when a line is erased. this includes line clears but also top outs and non-scoring end game lines.
signal line_erased(y, total_lines, remaining_lines, box_ints)

## emitted when an erased line is deleted, causing the lines above it to drop down
signal line_deleted(y)

## emitted after a set of lines is deleted
signal after_lines_deleted(lines)

## percent of the line clear delay which should be spent erasing lines.
## 1.0 = erase lines slowly one at a time, 0.0 = erase all lines immediately
const LINE_ERASE_TIMING_PCT := 0.667

export (NodePath) var tile_map_path: NodePath

## lines currently being cleared/erased/deleted as a part of _physics_process
var lines_being_cleared := []
var lines_being_erased := []
var lines_being_deleted := []

## Lines currently being cleared/deleted in preparation for firing a trigger. Clearing a line can cause new lines to be
## inserted, which needs to then adjust the lines emitted by the signal.
var lines_being_cleared_during_trigger := []
var lines_being_deleted_during_trigger := []

## monitors the age of lines which have been filled, but not yet cleared due to the level's rules
## key: (int) line index
## value: (int) number of times this line has been full during 'calculate_lines_to_clear'
var line_filled_age := {}

## remaining frames to wait for erasing the current lines
var remaining_line_erase_frames := 0

## index of the next line to clear/erase as a part of _physics_process
var _cleared_line_index := 0
var _erased_line_index := 0

## timing values for lines currently being erased as a part of _physics_process.
## lines are cleared/erased when 'remaining_line_erase_frames' falls below the values in these arrays.
var _remaining_line_clear_timings := []
var _remaining_line_erase_timings := []

## lines containing prebuilt level boxes, which aren't cleared at the end of the level.
## key: (int) line index
## value: (bool) true
var _lines_to_preserve_at_end := {}

## Total number of cleared lines for this level which we pass into triggers. This is distinct from the lines we
## show to the player, because the two values are incremented at different times.
var _total_cleared_line_count := 0

## Maximum score the player has reached.
##
## Level triggers can fire when the player reaches a score threshold. The player's score can decrease if they top out,
## so we monitor their max score to ensure score triggers only fire once.
var _max_trigger_score := 0

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
		var old_lines_being_cleared := lines_being_cleared
		var old_lines_being_erased := lines_being_erased
		var old_lines_being_deleted := lines_being_deleted
		
		lines_being_cleared = []
		lines_being_erased = []
		lines_being_deleted = []
		
		_delete_lines(old_lines_being_cleared, old_lines_being_erased, old_lines_being_deleted)
		
		# setting physics_process to 'false' causes 'Playfield.is_building_boxes()' to return false, so we make sure to
		# assign this after all signals are fired.
		set_physics_process(false)


## Clears a full line in the playfield as a reward.
##
## Updates the combo, awards points, and triggers things like sounds or creatures eating.
func clear_line(y: int, total_lines: int, remaining_lines: int) -> void:
	var box_ints:= _box_ints(y)
	emit_signal("before_line_cleared", y, total_lines, remaining_lines, box_ints)
	
	_erase_line(y, total_lines, remaining_lines)
	emit_signal("line_cleared", y, total_lines, remaining_lines, box_ints)
	
	# All lines are cleared at the end of a level but this shouldn't trigger an 'all clear'.
	if not PuzzleState.finish_triggered and not _tile_map.get_used_cells():
		emit_signal("all_lines_cleared")


## Schedules any filled lines to be cleared later.
func schedule_filled_line_clears(force: bool = false) -> void:
	var lines_to_clear := calculate_lines_to_clear(filled_lines(), force)
	
	if lines_to_clear:
		schedule_line_clears(lines_to_clear, PieceSpeeds.current_speed.line_clear_delay)


## Calculates the lines to clear, based on which lines are currently filled.
##
## This results in a state change, as it updates the 'line_filled_age' array so it should only be called once for each
## potential set of line clears.
func calculate_lines_to_clear(filled_lines: Array, force: bool = false) -> Array:
	var lines_to_clear := filled_lines.duplicate()
	
	# increment entries in line_filled_age
	for line in filled_lines:
		if not line_filled_age.has(line):
			line_filled_age[line] = 0
		else:
			line_filled_age[line] += 1
	
	# apply 'filled_line_clear_min' setting
	if lines_to_clear and not force \
			and lines_to_clear.size() < CurrentLevel.settings.blocks_during.filled_line_clear_min:
		lines_to_clear.clear()
	
	# apply 'filled_line_clear_delay' setting
	if lines_to_clear and not force \
			and CurrentLevel.settings.blocks_during.filled_line_clear_delay >= 1:
		var new_lines_to_clear := []
		for line in lines_to_clear:
			if line_filled_age[line] >= CurrentLevel.settings.blocks_during.filled_line_clear_delay:
				new_lines_to_clear.append(line)
		lines_to_clear = new_lines_to_clear
	
	# apply 'filled_line_clear_order' setting
	lines_to_clear = sort_lines_to_clear(lines_to_clear)
	
	# apply 'filled_line_clear_max' setting
	if lines_to_clear and CurrentLevel.settings.blocks_during.filled_line_clear_max >= 1 and not force:
		lines_to_clear = lines_to_clear.slice(0, CurrentLevel.settings.blocks_during.filled_line_clear_max - 1)
	
	return lines_to_clear


## Sorts the specified list of lines based on the 'filled_line_clear_order' setting.
##
## Parameters:
## 	'lines_to_clear': Row indexes to sort from the puzzle tilemap.
func sort_lines_to_clear(lines_to_clear: Array) -> Array:
	var sorted_lines := lines_to_clear.duplicate()
	if sorted_lines:
		match CurrentLevel.settings.blocks_during.filled_line_clear_order:
			BlocksDuringRules.FilledLineClearOrder.OLDEST:
				sorted_lines.sort_custom(self, "_compare_by_line_filled_age")
			BlocksDuringRules.FilledLineClearOrder.LOWEST:
				sorted_lines.sort()
				sorted_lines.invert()
			BlocksDuringRules.FilledLineClearOrder.RANDOM:
				sorted_lines.shuffle()
			BlocksDuringRules.FilledLineClearOrder.DEFAULT, BlocksDuringRules.FilledLineClearOrder.HIGHEST, _:
				sorted_lines.sort()
	return sorted_lines


func filled_lines() -> Array:
	var filled_lines := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _tile_map.row_is_full(y):
			filled_lines.append(y)
	return filled_lines


## Schedules the specified lines to be cleared later.
##
## Parameters:
## 	'lines_to_clear': Row indexes to clear from the puzzle tilemap
##
## 	'line_clear_delay': Number of frames to spend erasing and deleting lines
##
## 	'award_points': 'true' if these line clears should score points
func schedule_line_clears(lines_to_clear: Array, line_clear_delay: int, award_points: bool = true) -> void:
	var unscheduled_clears := []
	var unscheduled_erases := []
	if award_points:
		for y in lines_to_clear:
			if _box_ints(y) or _tile_map.row_is_full(y):
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


## Schedules line clears which occur when a puzzle is finished.
##
## Any full lines and lines containing boxes result in line clears, and the player is awarded points.
##
## Any partial lines containing only vegetables are left behind, the player is not awarded points for those.
func schedule_finish_line_clears() -> void:
	var full_lines := []
	var box_lines := []
	for y in range(PuzzleTileMap.ROW_COUNT):
		if _tile_map.row_is_full(y):
			full_lines.append(y)
		elif _box_ints(y) and not _lines_to_preserve_at_end.has(y):
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
			Utils.append_if_absent(lines_being_deleted, line)
		
		# if we were already clearing lines, we pause before triggering additional line clears
		if was_clearing_lines:
			remaining_line_erase_frames += _per_line_frame_delay()
	
	# ensure remaining_line_erase_frames is always set to a non-zero value. the level end is triggered when this
	# number decreases from 1 to 0, so if it ends up being 0 or less it causes a softlock
	remaining_line_erase_frames = max(1, remaining_line_erase_frames)


func reset() -> void:
	lines_being_cleared.clear()
	lines_being_cleared_during_trigger.clear()
	lines_being_erased.clear()
	lines_being_deleted.clear()
	lines_being_deleted_during_trigger.clear()
	remaining_line_erase_frames = 0
	_cleared_line_index = 0
	_erased_line_index = 0
	_remaining_line_clear_timings.clear()
	_remaining_line_erase_timings.clear()
	_total_cleared_line_count = 0
	_max_trigger_score = 0
	
	for line_dict in _line_dicts():
		line_dict.clear()


func _per_line_frame_delay() -> float:
	var line_erase_timing_window := LINE_ERASE_TIMING_PCT * remaining_line_erase_frames
	return floor(line_erase_timing_window / max(1, lines_being_cleared.size() + lines_being_erased.size() - 1))


## Erases all cells in the specified row.
##
## This can be invoked as a part of a 'line clear', or as a part of a top out or something mundane. It does not
## increase the combo or award points.
func _erase_line(y: int, total_lines: int, remaining_lines: int) -> void:
	var box_ints:= _box_ints(y)
	_tile_map.erase_row(y)
	for line_dict in _line_dicts():
		line_dict.erase(y)
	emit_signal("line_erased", y, total_lines, remaining_lines, box_ints)


## Deletes lines from the playfield, dropping all lines above them.
func _delete_lines(old_lines_being_cleared: Array, _old_lines_being_erased: Array, \
		old_lines_being_deleted: Array) -> void:
	# Calculate whether anything is dropping which will trigger the line fall sound.
	var play_sound := false
	
	if CurrentLevel.settings.blocks_during.line_clear_type == BlocksDuringRules.LineClearType.FLOAT_FALL:
		# instead of deleting the filled lines, delete the bottom lines
		for i in range(old_lines_being_deleted.size()):
			old_lines_being_deleted[i] = PuzzleTileMap.ROW_COUNT - i - 1
	elif CurrentLevel.settings.blocks_during.line_clear_type == BlocksDuringRules.LineClearType.FLOAT:
		# don't delete the filled lines
		old_lines_being_deleted = []
	
	old_lines_being_deleted.sort()
	var max_line: int = old_lines_being_deleted.back() if old_lines_being_deleted else -1
	for y in range(max_line):
		if not _tile_map.row_is_empty(y) and not old_lines_being_deleted.has(y):
			play_sound = true
			break
	
	# Cache the lines being deleted. Clearing a line can cause new lines to be inserted, which needs to then adjust
	# the lines emitted by the signal. Otherwise we have bugs where pickups get misaligned.
	lines_being_cleared_during_trigger = old_lines_being_cleared
	lines_being_deleted_during_trigger = old_lines_being_deleted
	
	if old_lines_being_deleted:
		var lines_to_delete := old_lines_being_deleted.duplicate()
		# sort to avoid edge cases with row indexes changing during deletion
		lines_to_delete.sort()
		
		for i in range(lines_being_deleted_during_trigger.size()):
			var line_being_deleted: int = lines_being_deleted_during_trigger[i]
			_tile_map.erase_row(line_being_deleted)
			
			if lines_being_cleared_during_trigger.empty():
				# If lines are being deleted because of a top out, we don't fire triggers.
				pass
			elif PuzzleState.finish_triggered:
				# If lines are being deleted at the level end, we don't fire triggers.
				pass
			else:
				# Some levels insert lines in response to lines being deleted. It is important that line clear
				# triggers run after lines are erased, but before they're shifted. Otherwise lines might be inserted
				# in the wrong place, or the newly inserted lines could be deleted as a part of a big line clear.
				_total_cleared_line_count += 1
				
				var event_params := {}
				event_params["y"] = line_being_deleted
				event_params["n"] = _total_cleared_line_count
				event_params["combo"] = PuzzleState.combo - i
				
				var prev_max_trigger_score := _max_trigger_score
				_max_trigger_score = PuzzleState.get_score() + PuzzleState.get_bonus_score()
				event_params["prev_score"] = prev_max_trigger_score
				event_params["score"] = _max_trigger_score
				
				CurrentLevel.settings.triggers.run_triggers(LevelTrigger.LINE_CLEARED, event_params)
			
			# reassign 'line_being_deleted' in case lines_being_deleted_during_trigger was modified during the
			# triggers, like when inserting a line
			line_being_deleted = lines_being_deleted_during_trigger[i]
			
			_tile_map.shift_rows(line_being_deleted - 1, Vector2.DOWN)
			
			for line_dict in _line_dicts():
				# Shift all entries above the deleted line
				var new_line_dict := {}
				for key in line_dict:
					var new_key: int = key
					if key < line_being_deleted:
						new_key += 1
					new_line_dict[new_key] = line_dict[key]
				line_dict.clear()
				line_dict.merge(new_line_dict)
	
	
	if play_sound:
		_line_fall_sound.play()
	
	for y in lines_being_deleted_during_trigger:
		emit_signal("line_deleted", y)
	
	emit_signal("after_lines_deleted", lines_being_deleted_during_trigger)


## Returns a list of food colors in the specified row.
##
## The resulting array can be any of the following:
## 	1. an empty array, [], for a row of vegetables or disjointed pieces
## 	2. [BROWN], [PINK], [BREAD], [WHITE] or [CHEESE] if the row has a snack box
## 	3. [CAKE] if the row has a cake box
## 	4. an array with multiple items, if the row has many boxes
##
## A horizontal box results in multiple duplicate box ints being added. This is by design to result in larger scoring
## bonuses for horizontal boxes, as they're less efficient.
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


func _compare_by_line_filled_age(a: int, b: int) -> bool:
	return line_filled_age.get(a, -1) > line_filled_age.get(b, -1)


## Dictionaries whose keys correspond to lines. These keys must be adjusted as lines are inserted/deleted from the
## playfield.
func _line_dicts() -> Array:
	return [
		_lines_to_preserve_at_end,
		line_filled_age,
	]


## Arrays whose entries correspond to lines. These entries must be adjusted as lines are inserted/deleted from the
## playfield.
func _line_arrays() -> Array:
	return [
		lines_being_cleared,
		lines_being_erased,
		lines_being_deleted,
		lines_being_cleared_during_trigger,
		lines_being_deleted_during_trigger,
	]


func _on_PuzzleState_finish_triggered() -> void:
	if CurrentLevel.settings.other.clear_on_finish:
		schedule_finish_line_clears()
	else:
		PuzzleState.end_game()


## When a new set of blocks is loaded, we recalculate the lines to preserve at the end.
##
## Any prebuilt level boxes aren't cleared at the end of the level.
func _on_Playfield_blocks_prepared() -> void:
	reset()
	for cell in _tile_map.get_used_cells():
		if _tile_map.get_cellv(cell) == 1:
			_lines_to_preserve_at_end[int(cell.y)] = true


## When a box is made, we remove those lines from the lines to preserve at the end.
##
## Any prebuilt level boxes aren't cleared at the end of the level, but if the player makes additional boxes next to
## them, then they're cleared.
func _on_BoxBuilder_box_built(rect: Rect2, _box_type: int) -> void:
	for y in range(rect.position.y, rect.end.y):
		_lines_to_preserve_at_end.erase(y)


## When lines are inserted, we adjust the lines being cleared/erased/deleted.
##
## Without these adjustments, strange behavior happens when lines are inserted and deleted simultaneously.
func _on_Playfield_line_inserted(y: int, _tiles_key: String, _src_y: int) -> void:
	for line_array in _line_arrays():
		for i in range(line_array.size()):
			if line_array[i] <= y:
				line_array[i] -= 1
	
	for line_dict in _line_dicts():
		var new_line_dict := {}
		for i in line_dict.keys():
			if i <= y:
				new_line_dict[i - 1] = line_dict[i]
			else:
				new_line_dict[i] = line_dict[i]
		line_dict.clear()
		line_dict.merge(new_line_dict)
	
	_lines_to_preserve_at_end[y] = true


## When lines are filled, we mark them so they're preserved at the end.
func _on_Playfield_line_filled(y: int, _tiles_key: String, _src_y: int) -> void:
	_lines_to_preserve_at_end[y] = true
