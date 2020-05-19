class_name RankCalculator
"""
Contains logic for calculating the player's performance. This performance is stored as a series of 'ranks', where 0 is
the best possible rank and 999 is the worst.
"""

# These constants from (0.0 - 1.0) affect how far apart the ranks are. A number like 0.99 means the ranks are really
# narrow, and you can fall from rank 10 to rank 20 with only a minor mistake. A number like 0.96 means the ranks are
# more forgiving.
const RDF_SPEED := 0.960
const RDF_LINES := 0.960
const RDF_BOX_SCORE_PER_LINE := 0.970
const RDF_COMBO_SCORE_PER_LINE := 0.970

# Performance statistics for a perfect player. These statistics interact, as it's easier to play fast without making
# boxes, and easier to make boxes while ignoring combos. Before increasing any of these, ensure it's feasible for a
# theoretical player to meet all three statistics simultaneously.
const MASTER_BOX_SCORE := 14.5
const MASTER_COMBO_SCORE := 17.575
const MASTER_COMBO := 22

# The number of extra unnecessary frames a perfect player will spend moving their piece.
const MASTER_MVMT_FRAMES := 6

# amount of points lost while starting a combo
const COMBO_DEFICIT := [0, 20, 40, 55, 70, 80, 90, 95, 100]

"""
Calculates the player's rank.

This is calculated in two steps: First, we calculate the rank for a theoretical M-rank player who plays as fast as
possible and never dies. However, some modes such as 'marathon mode' are designed with the understanding that a
player is not expected to actually finish them. So we also simulate a second S++ rank player who dies in the middle of
the match, and return the better of the two ranks.
"""
func calculate_rank() -> RankResult:
	var rank_result := _inner_calculate_rank(false)
	if Global.scenario_settings.win_condition.has_meta("lenient_value"):
		var rank_results_lenient := _inner_calculate_rank(true)
		rank_result.speed_rank = min(rank_result.speed_rank, rank_results_lenient.speed_rank)
		rank_result.lines_rank = min(rank_result.lines_rank, rank_results_lenient.lines_rank)
		rank_result.box_score_per_line_rank = \
				min(rank_result.box_score_per_line_rank, rank_results_lenient.box_score_per_line_rank)
		rank_result.combo_score_per_line_rank = \
				min(rank_result.combo_score_per_line_rank, rank_results_lenient.combo_score_per_line_rank)
		rank_result.score_rank = min(rank_result.score_rank, rank_results_lenient.score_rank)
	
	return rank_result


"""
Calculates the maximum combo score for the specified number of lines.

If it only takes 3 lines to clear a stage, the most combo points you can get is 5 (0 + 0 + 5). On the surface, 5 combo
points for 3 lines seems like a bad score, but it's actually the maximum. We calculate the maximum when figuring out
the player's performance.
"""
func _max_combo_score(lines: int) -> int:
	var result := lines * 20
	result -= COMBO_DEFICIT[min(lines, COMBO_DEFICIT.size() - 1)]
	result = max(result, 20)
	return result


"""
Calculates the minimum theoretical frames per line for a given piece speed.

This assumes a skilled player who is making many boxes, clearing lines one at a time, and moving pieces very
efficiently.
"""
static func min_frames_per_line(piece_speed: PieceSpeed) -> float:
	var movement_frames := 1 + MASTER_MVMT_FRAMES
	var frames_per_line := 0.0
	
	# eight pieces form three boxes and clear four lines

	# time spent spawning eight pieces
	frames_per_line += piece_speed.line_appearance_delay * 4 # four 'line clear' pieces spawned
	frames_per_line += piece_speed.appearance_delay * 4 # four 'regular pieces' spawned
	
	# time spent moving nine pieces
	frames_per_line += movement_frames * 8
	
	# time spent while pieces lock into the playfield
	frames_per_line += piece_speed.post_lock_delay * 8 # eight pieces locked
	frames_per_line += piece_speed.line_clear_delay * 4 # four lines cleared
	frames_per_line += piece_speed.box_delay * 3 # three boxes formed
	frames_per_line /= 4
	return frames_per_line


"""
Calculates the maximum theoretical lines per minute.
"""
func _max_lpm() -> float:
	var total_frames := 0.0
	var total_lines := 0.0
	
	for i in range(Global.scenario_settings.level_ups.size()):
		var milestone: Milestone = Global.scenario_settings.level_ups[i]
		var piece_speed: PieceSpeed = PieceSpeeds.speed(milestone.get_meta("level"))
		
		var frames_per_line := min_frames_per_line(piece_speed)
		
		var winish_condition: Milestone = Global.scenario_settings.get_winish_condition()
		var level_lines := 100
		if i + 1 < Global.scenario_settings.level_ups.size():
			var level_up: Milestone = Global.scenario_settings.level_ups[i + 1]
			match level_up.type:
				Milestone.CUSTOMERS:
					level_lines = MASTER_COMBO
				Milestone.LINES:
					level_lines = level_up.value
				Milestone.TIME:
					level_lines = level_up.value * 60 / frames_per_line
				Milestone.SCORE:
					level_lines = level_up.value / (MASTER_BOX_SCORE + MASTER_COMBO_SCORE + 1)
		elif winish_condition.type == Milestone.LINES:
			level_lines = winish_condition.value
		elif winish_condition.type == Milestone.SCORE:
			level_lines = winish_condition.value / (MASTER_BOX_SCORE + MASTER_COMBO_SCORE + 1)

		total_frames += frames_per_line * level_lines
		total_lines += level_lines
	
	return 60 * 60 * float(total_lines) / total_frames


"""
Calculates the player's rank.

We calculate the player's rank in various areas by comparing them to a perfect player, and diminishing the perfect
player's abilities until they match the actual player's performance.

Parameters:
	'lenient': If false, we compare the player to a perfect M-rank player. If true, we compare the player to a very
		good S++ rank player. This is mostly done to avoid giving the player a C+ because they 'only' survived for 150
		lines in Marathon mode.
"""
func _inner_calculate_rank(lenient: bool) -> RankResult:
	var rank_result := RankResult.new()
	
	var max_lpm := _max_lpm()
	
	var target_speed: float = max_lpm
	var target_box_score_per_line := MASTER_BOX_SCORE
	var target_combo_score_per_line := MASTER_COMBO_SCORE
	var target_lines: float

	var winish_condition: Milestone = Global.scenario_settings.get_winish_condition()

	match winish_condition.type:
		Milestone.CUSTOMERS:
			target_lines = MASTER_COMBO * winish_condition.value
		Milestone.LINES:
			target_lines = winish_condition.get_meta("lenient_value") if lenient else winish_condition.value
		Milestone.SCORE:
			target_lines = ceil((winish_condition.value + COMBO_DEFICIT[COMBO_DEFICIT.size() - 1]) \
					/ (target_box_score_per_line + target_combo_score_per_line + 1))
		Milestone.TIME:
			target_lines = max_lpm * winish_condition.value / 60.0

	# calculate raw player performance statistics
	rank_result.lines = PuzzleScore.scenario_performance.lines
	rank_result.box_score = PuzzleScore.scenario_performance.box_score
	rank_result.combo_score = PuzzleScore.scenario_performance.combo_score
	rank_result.score = PuzzleScore.scenario_performance.score
	rank_result.seconds = PuzzleScore.scenario_performance.seconds
	rank_result.died = PuzzleScore.scenario_performance.died
	rank_result.speed = 60 * float(rank_result.lines) / max(rank_result.seconds, 1)
	rank_result.box_score_per_line = float(rank_result.box_score) / max(rank_result.lines, 1)
	rank_result.combo_score_per_line = 20 * float(rank_result.combo_score) \
			/ _max_combo_score(max(rank_result.lines, 1))
	
	if rank_result.died:
		# don't let the player commit suicide to randomly get an 'M' rank
		rank_result.speed = 60 * float(rank_result.lines) / max(rank_result.seconds, 24)
		rank_result.box_score_per_line = float(rank_result.box_score) / max(rank_result.lines, 24)
		rank_result.combo_score_per_line = 20 * float(rank_result.combo_score) \
				/ _max_combo_score(max(rank_result.lines, 24))
	
	# calculate rank
	rank_result.speed_rank = clamp(log(rank_result.speed / target_speed) / log(RDF_SPEED), 0, 999)
	rank_result.lines_rank = clamp(log(rank_result.lines / target_lines) / log(RDF_LINES), 0, 999)
	rank_result.box_score_per_line_rank = clamp(log(
			rank_result.box_score_per_line / target_box_score_per_line) / log(RDF_BOX_SCORE_PER_LINE), 0, 999)
	rank_result.combo_score_per_line_rank = clamp(log(
			rank_result.combo_score_per_line / target_combo_score_per_line) / log(RDF_COMBO_SCORE_PER_LINE), 0, 999)
	rank_result.seconds_rank = 999.0
	rank_result.score_rank = 999.0
	
	# Binary search for the player's score rank. Score is a function of several criteria, the rank doesn't deteriorate
	# in a predictable way like the other ranks
	var overall_rank_max := 999.0
	var overall_rank_min := 0.0
	for _i in range(20):
		var tmp_overall_rank := (overall_rank_max + overall_rank_min) / 2.0
		var tmp_box_score_per_line := target_box_score_per_line \
				* pow(RDF_BOX_SCORE_PER_LINE, tmp_overall_rank)
		var tmp_combo_score_per_line := target_combo_score_per_line \
				* pow(RDF_COMBO_SCORE_PER_LINE, tmp_overall_rank)
		if winish_condition.type == Milestone.SCORE:
			var tmp_speed := target_speed * pow(RDF_SPEED, tmp_overall_rank)
			var points_per_second := (tmp_speed * (1 + tmp_box_score_per_line + tmp_combo_score_per_line)) / 60
			if (winish_condition.value + COMBO_DEFICIT[COMBO_DEFICIT.size() - 1]) \
					/ points_per_second < rank_result.seconds or PuzzleScore.scenario_performance.died:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
		else:
			var tmp_lines := target_lines * pow(RDF_LINES, tmp_overall_rank)
			if tmp_lines * (1 + tmp_box_score_per_line + tmp_combo_score_per_line) > rank_result.score:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
	if winish_condition.type == Milestone.SCORE:
		rank_result.seconds_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	else:
		rank_result.score_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	
	if lenient:
		# can't go above S++ with 'lenient' scoring
		rank_result.speed_rank = max(1, rank_result.speed_rank)
		rank_result.lines_rank = max(1, rank_result.lines_rank)
		rank_result.box_score_per_line_rank = max(1, rank_result.box_score_per_line_rank)
		rank_result.combo_score_per_line_rank = max(1, rank_result.combo_score_per_line_rank)
		rank_result.score_rank = max(1, rank_result.score_rank)
		rank_result.seconds_rank = max(1, rank_result.seconds_rank)
	
	if rank_result.died:
		# can't go above S++ if the player dies
		rank_result.lines_rank = max(1, rank_result.lines_rank)
	
	return rank_result
