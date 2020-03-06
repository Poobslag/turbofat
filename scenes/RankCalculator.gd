"""
Contains logic for calculating the player's performance. This performance is stored as a series of 'ranks', where 0 is
the best possible rank and 999 is the worst.
"""
extends Node

"""
Contains rank information for a playthrough. This includes raw statistics such as how many lines-per-minute the player
cleared, as well as derived statistics such as the computed lines-per-minute rank.
"""
class RankResults:
	# player's speed in lines per minute.
	var speed := 0.0
	var speed_rank := 0.0

	# raw number of cleared lines for the current game, not counting any bonus points
	var lines := 0.0
	var lines_rank := 0.0
	
	# total number of bonus points awarded in the current game by clearing boxes
	var box_score := 0.0
	var box_score_rank := 0.0
	
	# total number of bonus points awarded in the current game for combos
	var combo_score := 0.0
	var combo_score_rank := 0.0
	
	# overall seconds
	var seconds := 0.0
	var seconds_rank := 0.0
	
	# overall score
	var score := 0.0
	var score_rank := 0.0

"""
Calculates the maximum theoretical lines per minute.

Parameters: The number of extra unnecessary frames the player will move their piece for.
"""
func _max_lpm(extra_movement_frames:float = 0) -> float:
	var total_frames := 0.0
	var total_lines := 0.0
	
	for i in range(0, Global.scenario.level_up_conditions.size()):
		var piece_speed = Global.scenario.level_up_conditions[i].piece_speed
		
		var movement_frames := 1 + extra_movement_frames
		var frames_per_line := 0.0
		
		# nine pieces form two blocks (cake blocks) and clear four lines in three groups

		# time spent spawning nine pieces
		frames_per_line += piece_speed.line_appearance_delay * 3 # three 'line clear' pieces spawned
		frames_per_line += piece_speed.appearance_delay * 6 # five 'regular pieces' spawned
		
		# time spent moving nine pieces
		frames_per_line += movement_frames * 9
		
		# time spent while pieces lock into the playfield
		frames_per_line += piece_speed.post_lock_delay * 9 # nine pieces locked
		frames_per_line += piece_speed.line_clear_delay * 3 # three lines cleared
		frames_per_line += piece_speed.line_clear_delay * 3 # three boxes formed
		frames_per_line /= 4
		
		var level_lines: int
		if i + 1 < Global.scenario.level_up_conditions.size():
			if Global.scenario.level_up_conditions[i + 1].type == "lines":
				level_lines = Global.scenario.level_up_conditions[i + 1].value
			elif Global.scenario.level_up_conditions[i + 1].type == "time":
				level_lines = Global.scenario.level_up_conditions[i + 1].value * 60 / frames_per_line
		elif Global.scenario.win_condition.type == "lines":
			level_lines = Global.scenario.win_condition.value
		else:
			level_lines = 100

		total_frames += frames_per_line * level_lines
		total_lines += level_lines
	
	return 60 * 60 * float(total_lines) / total_frames

# These constants from (0.0 - 1.0) affect how far apart the ranks are. A number like 0.99 means the ranks are really
# narrow, and you can fall from rank 10 to rank 20 with only a minor mistake. A number like 0.96 means the ranks are
# more forgiving.
const RDF_SPEED := 0.96
const RDF_LINES := 0.96
const RDF_BOX_SCORE := 0.96
const RDF_COMBO_SCORE := 0.98

"""
Calculates the player's rank.

This is calculated in two steps: First, we calculate the rank for a theoretical M-rank player who plays as fast as
possible and never dies. However, some modes such as 'marathon mode' are designed with the understanding that a
player is not expected to actually finish them. So we also simulate a second S++ rank player who dies in the middle of
the match, and return the better of the two ranks.
"""
func calculate_rank() -> RankResults:
	var rank_results = _inner_calculate_rank(false)
	if Global.scenario.win_condition.lenient_value != Global.scenario.win_condition.value:
		var rank_results_lenient = _inner_calculate_rank(true)
		rank_results.speed_rank = min(rank_results.speed_rank, rank_results_lenient.speed_rank)
		rank_results.lines_rank = min(rank_results.lines_rank, rank_results_lenient.lines_rank)
		rank_results.box_score_rank = min(rank_results.box_score_rank, rank_results_lenient.box_score_rank)
		rank_results.combo_score_rank = min(rank_results.combo_score_rank, rank_results_lenient.combo_score_rank)
		rank_results.score_rank = min(rank_results.score_rank, rank_results_lenient.score_rank)
	
	return rank_results

"""
Calculates the player's rank.

We calculate the player's rank in various areas by comparing them to a perfect player, and diminishing the perfect
player's abilities until they match the actual player's performance.

Parameters: The 'lenient' parameter decides whether or not we compare the player to a perfect M-rank player, or a very
	good S++ rank player. This is mostly done to avoid giving the player a C+ because they 'only' survived for 150
	lines in Marathon mode.
"""
func _inner_calculate_rank(lenient: bool) -> RankResults:
	var rank_results := RankResults.new()
	
	var max_lpm := _max_lpm(6)
	
	var target_speed: float = max_lpm
	var target_box_score := 13.6
	var target_combo_score := 16.8
	var target_lines: float
	var target_seconds: float
	if Global.scenario.win_condition.type == "lines":
		if lenient:
			target_lines = Global.scenario.win_condition.lenient_value
		else:
			target_lines = Global.scenario.win_condition.value
		target_seconds = 60 * target_lines / max_lpm
	elif Global.scenario.win_condition.type == "time":
		target_lines = max_lpm * Global.scenario.win_condition.value / 60.0
		target_seconds = Global.scenario.win_condition.value
	elif Global.scenario.win_condition.type == "score":
		# We add 80 lines to the target to make up for the 80 points we miss out on as our combo starts
		target_lines = ceil((Global.scenario.win_condition.value + 80) / (target_box_score + target_combo_score + 1))
		target_seconds = 60 * target_lines / max_lpm
	
	# calculate raw player performance statistics
	rank_results.speed = 60 * float(Global.scenario_performance.lines) / max(Global.scenario_performance.seconds, 1)
	rank_results.lines = Global.scenario_performance.lines
	rank_results.box_score = float(Global.scenario_performance.box_score) / max(Global.scenario_performance.lines, 1)
	rank_results.combo_score = float(Global.scenario_performance.combo_score) / max(Global.scenario_performance.lines - 4, 1)
	rank_results.score = Global.scenario_performance.score
	rank_results.seconds = Global.scenario_performance.seconds
	
	if Global.scenario_performance.died:
		# don't let the player commit suicide to randomly get an 'M' rank
		rank_results.speed = 60 * float(Global.scenario_performance.lines) / max(Global.scenario_performance.seconds, 24)
		rank_results.box_score = float(Global.scenario_performance.box_score) / max(Global.scenario_performance.lines, 24)
		rank_results.combo_score = float(Global.scenario_performance.combo_score) / max(Global.scenario_performance.lines - 4, 24)
	
	# calculate rank
	rank_results.speed_rank = clamp(log(rank_results.speed / target_speed) / log(RDF_SPEED), 0, 999)
	rank_results.lines_rank = clamp(log(rank_results.lines / target_lines) / log(RDF_LINES), 0, 999)
	rank_results.box_score_rank = clamp(log(rank_results.box_score / target_box_score) / log(RDF_BOX_SCORE), 0, 999)
	rank_results.combo_score_rank = clamp(log(rank_results.combo_score / target_combo_score) / log(RDF_COMBO_SCORE), 0, 999)
	rank_results.seconds_rank = 999.0
	rank_results.score_rank = 999.0
	
	# Binary search for the player's score rank. Score is a function of several criteria, the rank doesn't deteriorate
	# in a predictable way like the other ranks
	var overall_rank_max = 999
	var overall_rank_min = 0
	for _i in range(0, 20):
		var tmp_overall_rank = (overall_rank_max + overall_rank_min) / 2.0
		var tmp_box_score := target_box_score * pow(RDF_BOX_SCORE, tmp_overall_rank)
		var tmp_combo_score := target_combo_score * pow(RDF_COMBO_SCORE, tmp_overall_rank)
		if Global.scenario.win_condition.type == "score":
			var tmp_speed := target_speed * pow(RDF_SPEED, tmp_overall_rank)
			var points_per_second := (tmp_speed * (1 + tmp_box_score + tmp_combo_score)) / 60
			if (Global.scenario.win_condition.value + 80) / points_per_second < rank_results.seconds || Global.scenario_performance.died:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
		else:
			var tmp_lines := target_lines * pow(RDF_LINES, tmp_overall_rank)
			if tmp_lines * (1 + tmp_box_score + tmp_combo_score) > rank_results.score:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
	if Global.scenario.win_condition.type == "score":
		rank_results.seconds_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	else:
		rank_results.score_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	
	if lenient:
		# can't go above S++ with 'lenient' scoring
		rank_results.speed_rank = max(1, rank_results.speed_rank)
		rank_results.lines_rank = max(1, rank_results.lines_rank)
		rank_results.box_score_rank = max(1, rank_results.box_score_rank)
		rank_results.combo_score_rank = max(1, rank_results.combo_score_rank)
		rank_results.score_rank = max(1, rank_results.score_rank)
		rank_results.seconds_rank = max(1, rank_results.seconds_rank)
	
	return rank_results