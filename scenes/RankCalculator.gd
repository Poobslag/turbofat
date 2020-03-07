"""
Contains logic for calculating the player's performance. This performance is stored as a series of 'ranks', where 0 is
the best possible rank and 999 is the worst.
"""
extends Node

"""
Contains rank information for a playthrough. This includes raw statistics such as how many lines-per-minute the player
cleared, as well as derived statistics such as the computed lines-per-minute rank.
"""
class RankResult:
	# player's speed in lines per minute.
	var speed := 0.0
	var speed_rank := 0.0

	# raw number of cleared lines for the current game, not counting any bonus points
	var lines := 0
	var lines_rank := 0.0
	
	# total number of bonus points per line awarded in the current game by clearing boxes
	var box_score := 0.0
	var box_score_rank := 0.0
	
	# total number of bonus points per line awarded in the current game for combos
	var combo_score := 0.0
	var combo_score_rank := 0.0
	
	# overall seconds
	var seconds := 0.0
	var seconds_rank := 0.0
	
	# overall score
	var score := 0
	var score_rank := 0.0
	
	"""
	Returns this object's data as a dictionary. This is useful when saving/loading data.
	"""
	func to_dict() -> Dictionary:
		return {
			"speed": speed,
			"speed_rank": speed_rank,
			"lines": lines,
			"lines_rank": lines_rank,
			"box_score": box_score,
			"box_score_rank": box_score_rank,
			"combo_score": combo_score,
			"combo_score_rank": combo_score_rank,
			"seconds": seconds,
			"seconds_rank": seconds_rank,
			"score": score,
			"score_rank": score_rank }
	
	"""
	Populates this object from a dictionary. This is useful when saving/loading data.
	"""
	func from_dict(dict: Dictionary) -> void:
		speed = dict["speed"]
		speed_rank = dict["speed_rank"]
		lines = int(dict["lines"])
		lines_rank = dict["lines_rank"]
		box_score = dict["box_score"]
		box_score_rank = dict["box_score_rank"]
		combo_score = dict["combo_score"]
		combo_score_rank = dict["combo_score_rank"]
		seconds = dict["seconds"]
		seconds_rank = dict["seconds_rank"]
		score = int(dict["score"])
		score_rank = dict["score_rank"]

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
		
		# eight pieces form three boxes and clear four lines

		# time spent spawning eight pieces
		frames_per_line += piece_speed.line_appearance_delay * 4 # four 'line clear' pieces spawned
		frames_per_line += piece_speed.appearance_delay * 4 # four 'regular pieces' spawned
		
		# time spent moving nine pieces
		frames_per_line += movement_frames * 8
		
		# time spent while pieces lock into the playfield
		frames_per_line += piece_speed.post_lock_delay * 8 # eight pieces locked
		frames_per_line += piece_speed.line_clear_delay * 4 # four lines cleared
		frames_per_line += piece_speed.line_clear_delay * 3 # three boxes formed
		frames_per_line /= 4
		
		var level_lines := 100
		if i + 1 < Global.scenario.level_up_conditions.size():
			if Global.scenario.level_up_conditions[i + 1].type == "lines":
				level_lines = Global.scenario.level_up_conditions[i + 1].value
			elif Global.scenario.level_up_conditions[i + 1].type == "time":
				level_lines = Global.scenario.level_up_conditions[i + 1].value * 60 / frames_per_line
			elif Global.scenario.level_up_conditions[i + 1].type == "score":
				level_lines = Global.scenario.level_up_conditions[i + 1].value / (MASTER_BOX_SCORE + MASTER_COMBO_SCORE + 1)
		elif Global.scenario.win_condition.type == "lines":
			level_lines = Global.scenario.win_condition.value
		elif Global.scenario.win_condition.type == "score":
			level_lines = Global.scenario.win_condition.value / (MASTER_BOX_SCORE + MASTER_COMBO_SCORE + 1)

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

# Performance statistics for a perfect player. These statistics interact, as it's easier to play fast without making
# boxes, and easier to make boxes while ignoring combos. Before increasing any of these, ensure it's feasible for a
# theoretical player to meet all three statistics simultaneously.
const MASTER_BOX_SCORE := 13.6
const MASTER_COMBO_SCORE := 16.8
const MASTER_MVMT_FRAMES := 6

"""
Calculates the player's rank.

This is calculated in two steps: First, we calculate the rank for a theoretical M-rank player who plays as fast as
possible and never dies. However, some modes such as 'marathon mode' are designed with the understanding that a
player is not expected to actually finish them. So we also simulate a second S++ rank player who dies in the middle of
the match, and return the better of the two ranks.
"""
func calculate_rank() -> RankResult:
	var rank_result = _inner_calculate_rank(false)
	if Global.scenario.win_condition.lenient_value != Global.scenario.win_condition.value:
		var rank_results_lenient = _inner_calculate_rank(true)
		rank_result.speed_rank = min(rank_result.speed_rank, rank_results_lenient.speed_rank)
		rank_result.lines_rank = min(rank_result.lines_rank, rank_results_lenient.lines_rank)
		rank_result.box_score_rank = min(rank_result.box_score_rank, rank_results_lenient.box_score_rank)
		rank_result.combo_score_rank = min(rank_result.combo_score_rank, rank_results_lenient.combo_score_rank)
		rank_result.score_rank = min(rank_result.score_rank, rank_results_lenient.score_rank)
	
	return rank_result

"""
Calculates the player's rank.

We calculate the player's rank in various areas by comparing them to a perfect player, and diminishing the perfect
player's abilities until they match the actual player's performance.

Parameters: The 'lenient' parameter decides whether or not we compare the player to a perfect M-rank player, or a very
	good S++ rank player. This is mostly done to avoid giving the player a C+ because they 'only' survived for 150
	lines in Marathon mode.
"""
func _inner_calculate_rank(lenient: bool) -> RankResult:
	var rank_result := RankResult.new()
	
	var max_lpm := _max_lpm(MASTER_MVMT_FRAMES)
	
	var target_speed: float = max_lpm
	var target_box_score := MASTER_BOX_SCORE
	var target_combo_score := MASTER_COMBO_SCORE
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
	rank_result.speed = 60 * float(Global.scenario_performance.lines) / max(Global.scenario_performance.seconds, 1)
	rank_result.lines = Global.scenario_performance.lines
	rank_result.box_score = float(Global.scenario_performance.box_score) / max(Global.scenario_performance.lines, 1)
	rank_result.combo_score = float(Global.scenario_performance.combo_score) / max(Global.scenario_performance.lines - 4, 1)
	rank_result.score = Global.scenario_performance.score
	rank_result.seconds = Global.scenario_performance.seconds
	
	if Global.scenario_performance.died:
		# don't let the player commit suicide to randomly get an 'M' rank
		rank_result.speed = 60 * float(Global.scenario_performance.lines) / max(Global.scenario_performance.seconds, 24)
		rank_result.box_score = float(Global.scenario_performance.box_score) / max(Global.scenario_performance.lines, 24)
		rank_result.combo_score = float(Global.scenario_performance.combo_score) / max(Global.scenario_performance.lines - 4, 24)
	
	# calculate rank
	rank_result.speed_rank = clamp(log(rank_result.speed / target_speed) / log(RDF_SPEED), 0, 999)
	rank_result.lines_rank = clamp(log(rank_result.lines / target_lines) / log(RDF_LINES), 0, 999)
	rank_result.box_score_rank = clamp(log(rank_result.box_score / target_box_score) / log(RDF_BOX_SCORE), 0, 999)
	rank_result.combo_score_rank = clamp(log(rank_result.combo_score / target_combo_score) / log(RDF_COMBO_SCORE), 0, 999)
	rank_result.seconds_rank = 999.0
	rank_result.score_rank = 999.0
	
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
			if (Global.scenario.win_condition.value + 80) / points_per_second < rank_result.seconds || Global.scenario_performance.died:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
		else:
			var tmp_lines := target_lines * pow(RDF_LINES, tmp_overall_rank)
			if tmp_lines * (1 + tmp_box_score + tmp_combo_score) > rank_result.score:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
	if Global.scenario.win_condition.type == "score":
		rank_result.seconds_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	else:
		rank_result.score_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	
	if lenient:
		# can't go above S++ with 'lenient' scoring
		rank_result.speed_rank = max(1, rank_result.speed_rank)
		rank_result.lines_rank = max(1, rank_result.lines_rank)
		rank_result.box_score_rank = max(1, rank_result.box_score_rank)
		rank_result.combo_score_rank = max(1, rank_result.combo_score_rank)
		rank_result.score_rank = max(1, rank_result.score_rank)
		rank_result.seconds_rank = max(1, rank_result.seconds_rank)
	
	return rank_result