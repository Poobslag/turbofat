class_name RankCalculator
## Contains logic for calculating the player's performance. This performance is stored as a series of 'ranks', where 0
## is the best possible rank and 999 is the worst.

const WORST_RANK := RankResult.WORST_RANK
const BEST_RANK := RankResult.BEST_RANK

## These RDF (rank difference factor) constants from (0.0 - 1.0) affect how far apart the ranks are. A number like 0.99
## means the ranks are really narrow, and you can fall from rank 10 to rank 20 with only a minor mistake. A number like
## 0.96 means the ranks are more forgiving.
const RDF_SPEED := 0.940 # 'speed' measures how fast the player can place pieces
const RDF_ENDURANCE := 0.960 # 'endurance' measures how long the player can sustain
const RDF_BOX_SCORE_PER_LINE := 0.970
const RDF_COMBO_SCORE_PER_LINE := 0.970
const RDF_PICKUP_SCORE := 0.980
const RDF_PICKUP_SCORE_PER_LINE := 0.970

## Performance statistics for a perfect player. These statistics interact, as it's easier to play fast without making
## boxes, and easier to build boxes while ignoring combos. Before increasing any of these, ensure it's feasible for a
## theoretical player to meet all three statistics simultaneously.
const MASTER_BOX_SCORE := 14.5
const MASTER_COMBO_SCORE := 17.575
const MASTER_CUSTOMER_COMBO := 22
const MASTER_LEFTOVER_LINES := 12

## The fastest LPM for a human player at the highest piece speeds. Theoretically this could be as high as 180 based on
## similar records in other games.
##
## The current value of 65 is a conservative estimate extrapolated based on my own personal best of 52 lines per
## minute.
const MASTER_LINES_PER_MINUTE := 65

## The number of extra unnecessary frames a perfect player will spend moving their piece.
const MASTER_MVMT_FRAMES := 6

## amount of points lost while starting a combo
const COMBO_DEFICIT := [0, 20, 40, 55, 70, 80, 90, 95, 100]

## String to display if the player scored worse than the lowest grade
const NO_GRADE := "-"

## highest attainable grade; useful for logic which checks if the player's grade can increase
const HIGHEST_GRADE := "M"

## grades with their corresponding rank requirement
const GRADE_RANKS := [
	["M", 0],
	["SSS", 4],
	["SS+", 7],
	["SS", 10], # 4 stars (medium gap)
	["S+", 16],
	["S", 20],
	["S-", 24], # 1 star (big gap)
	
	["AA+", 32],
	["AA", 36],
	["A+", 40],
	["A", 44],
	["A-", 48], # 1 triangle (big gap)
	
	["B+", 56],
	["B", 60],
	["B-", 64], # 1 dot (big gap)
	
	[NO_GRADE, WORST_RANK],
]

## Calculates the player's rank.
##
## This is calculated in two steps: First, we calculate the rank for a theoretical M-rank player who plays as fast as
## possible and never dies. However, some modes such as 'marathon mode' are designed with the understanding that a
## player is not expected to actually finish them. So we also simulate a second S++ rank player who dies in the middle
## of the match, and return the better of the two ranks.
func calculate_rank(unranked_result: RankResult = null) -> RankResult:
	var rank_result: RankResult
	if unranked_result:
		rank_result = unranked_result
	else:
		rank_result = unranked_result()
	
	if CurrentLevel.settings.rank.unranked:
		# automatic master rank for unranked levels
		rank_result.seconds_rank = WORST_RANK if rank_result.lost else BEST_RANK
		rank_result.score_rank = WORST_RANK if rank_result.lost else BEST_RANK
	else:
		_populate_rank_fields(rank_result, false)
		
		if CurrentLevel.settings.finish_condition.has_meta("lenient_value"):
			var lenient_rank_result := unranked_result()
			_populate_rank_fields(lenient_rank_result, true)
			rank_result.speed_rank = min(rank_result.speed_rank, lenient_rank_result.speed_rank)
			rank_result.lines_rank = min(rank_result.lines_rank, lenient_rank_result.lines_rank)
			rank_result.pieces_rank = min(rank_result.pieces_rank, lenient_rank_result.pieces_rank)
			rank_result.box_score_per_line_rank = \
					min(rank_result.box_score_per_line_rank, lenient_rank_result.box_score_per_line_rank)
			rank_result.combo_score_per_line_rank = \
					min(rank_result.combo_score_per_line_rank, lenient_rank_result.combo_score_per_line_rank)
			rank_result.pickup_score_rank = \
					min(rank_result.pickup_score_rank, lenient_rank_result.pickup_score_rank)
			rank_result.score_rank = min(rank_result.score_rank, lenient_rank_result.score_rank)
	return rank_result


## Calculates the maximum combo score for the specified number of lines.
##
## If it only takes 3 lines to clear a stage, the most combo points you can get is 5 (0 + 0 + 5). On the surface, 5
## combo points for 3 lines seems like a bad score, but it's actually the maximum. We calculate the maximum when
## figuring out the player's performance.
func _max_combo_score(lines: int) -> int:
	var result := lines * 20
	result -= COMBO_DEFICIT[min(lines, COMBO_DEFICIT.size() - 1)]
	result = max(result, 0)
	return result


## Calculates the minimum theoretical frames per line for a given piece speed.
##
## This assumes a perfect player who is making many boxes, clearing lines one at a time, and moving pieces with TAS
## level efficiency.
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


## Calculates the lines per minute for a specific rank.
##
## The lines per minute (lpm) and seconds per line (spl) are limited based on current level's speeds, such as its line
## clear delay and lock delay. It is also limited based on the player's expected skill level.
func rank_lpm(rank: float) -> float:
	var total_frames := 0.0
	var total_lines := 0.0
	
	# calculate the player's lpm/spl based on the master lpm
	var player_lpm_limit := MASTER_LINES_PER_MINUTE * pow(RDF_SPEED, rank)
	var player_spl_limit := 60.0 / player_lpm_limit
	
	for i in range(CurrentLevel.settings.speed.speed_ups.size()):
		# calculate the maximum lpm/spl based on the piece speed
		var milestone: Milestone = CurrentLevel.settings.speed.speed_ups[i]
		var piece_speed: PieceSpeed = PieceSpeeds.speed(milestone.get_meta("speed"))
		var min_frames_per_line := min_frames_per_line(piece_speed)
		var mechanical_spl_limit: float = min_frames_per_line / 60 \
				+ 2 * CurrentLevel.settings.rank.extra_seconds_per_piece
		
		# calculate the spl based on which is slower: the mechanical limit, or the player's limit
		var seconds_per_line := max(mechanical_spl_limit, player_spl_limit)
		
		var finish_condition: Milestone = CurrentLevel.settings.finish_condition
		var level_lines := 100.0
		if i + 1 < CurrentLevel.settings.speed.speed_ups.size():
			# calculate lines until reaching the next speed up
			var speed_up: Milestone = CurrentLevel.settings.speed.speed_ups[i + 1]
			match speed_up.type:
				Milestone.CUSTOMERS:
					level_lines = master_customer_combo(CurrentLevel.settings)
				Milestone.LINES:
					level_lines = speed_up.value
				Milestone.PIECES:
					# warning-ignore:integer_division
					level_lines = speed_up.value / 2
				Milestone.TIME_OVER:
					level_lines = speed_up.value / seconds_per_line
				Milestone.SCORE:
					level_lines = speed_up.value / \
							(master_box_score(CurrentLevel.settings) + master_combo_score(CurrentLevel.settings) + 1)
		else:
			# calculate lines until reaching the end of the level
			match finish_condition.type:
				Milestone.LINES:
					level_lines = finish_condition.value
				Milestone.PIECES:
					# warning-ignore:integer_division
					level_lines = finish_condition.value / 2
				Milestone.SCORE:
					level_lines = finish_condition.value / \
							(master_box_score(CurrentLevel.settings) + master_combo_score(CurrentLevel.settings) + 1)
		
		# avoid divide by zero, and round up to the nearest line clear
		level_lines = ceil(max(level_lines, 1))
		
		total_frames += seconds_per_line * level_lines * 60
		total_lines += level_lines
	
	return 60 * 60 * float(total_lines) / total_frames


## Populates a new RankResult object with raw statistics.
##
## This does not include any rank data, only objective information like lines cleared and time taken.
func unranked_result() -> RankResult:
	var rank_result := RankResult.new()
	
	if CurrentLevel.settings.finish_condition.type == Milestone.SCORE:
		rank_result.compare = "-seconds"

	# calculate raw player performance statistics
	rank_result.box_score = PuzzleState.level_performance.box_score
	rank_result.combo_score = PuzzleState.level_performance.combo_score
	rank_result.pickup_score = PuzzleState.level_performance.pickup_score
	rank_result.leftover_score = PuzzleState.level_performance.leftover_score
	rank_result.lines = PuzzleState.level_performance.lines
	rank_result.pieces = PuzzleState.level_performance.pieces
	rank_result.lost = PuzzleState.level_performance.lost
	rank_result.success = PuzzleState.level_performance.success
	rank_result.score = PuzzleState.level_performance.score + PuzzleState.bonus_score
	rank_result.seconds = PuzzleState.level_performance.seconds
	rank_result.top_out_count = PuzzleState.level_performance.top_out_count
	
	rank_result.box_score_per_line = float(rank_result.box_score) / max(rank_result.lines, 1)
	rank_result.combo_score_per_line = 20 * float(rank_result.combo_score) \
			/ max(5, _max_combo_score(max(rank_result.lines, 1)))
	rank_result.pickup_score_per_line = float(rank_result.pickup_score) / max(rank_result.lines, 1)
	rank_result.speed = 60 * float(rank_result.lines) / max(rank_result.seconds, 1)
	return rank_result


## Calculates the player's rank.
##
## We calculate the player's rank in various areas by comparing them to a perfect player, and diminishing the perfect
## player's abilities until they match the actual player's performance.
##
## Parameters:
## 	'lenient': If false, we compare the player to a perfect M-rank player. If true, we compare the player to a very
## 		good S++ rank player. This is mostly done to avoid giving the player a C+ because they 'only' survived for 150
## 		lines in Marathon mode.
func _populate_rank_fields(rank_result: RankResult, lenient: bool) -> void:
	var target_speed: float = rank_lpm(BEST_RANK)
	var target_box_score_per_line := master_box_score(CurrentLevel.settings)
	var target_combo_score_per_line := master_combo_score(CurrentLevel.settings)
	var target_pickup_score_per_line := master_pickup_score_per_line(CurrentLevel.settings)
	var target_pickup_score := master_pickup_score(CurrentLevel.settings)
	var target_lines: int
	var leftover_lines := master_leftover_lines(CurrentLevel.settings)
	
	var finish_condition: Milestone = CurrentLevel.settings.finish_condition
	match finish_condition.type:
		Milestone.NONE:
			target_lines = 999999
		Milestone.CUSTOMERS:
			target_lines = master_customer_combo(CurrentLevel.settings) * finish_condition.value
			leftover_lines = 0 # the level ends when your combo breaks, it's inefficient to stack extra pieces
		Milestone.LINES:
			target_lines = int(finish_condition.get_meta("lenient_value")) if lenient else finish_condition.value
		Milestone.PIECES:
			# warning-ignore:integer_division
			target_lines = (finish_condition.value + CurrentLevel.settings.rank.preplaced_pieces) / 2.0
		Milestone.SCORE:
			target_lines = target_lines_for_score(target_box_score_per_line, target_combo_score_per_line)
			leftover_lines = 0 # you're racing to a target score, it's inefficient to stack extra pieces
		Milestone.TIME_OVER:
			target_lines = ceil(target_speed * finish_condition.value / 60.0)
			target_lines += ceil(CurrentLevel.settings.rank.preplaced_pieces / 2.0)
	
	# decrease target_lines based on leftover_lines
	if finish_condition.type in [Milestone.PIECES, Milestone.TIME_OVER]:
		target_lines = max(0, ceil(target_lines - leftover_lines / 3.0))
	
	# avoid divide-by-zero errors
	target_lines = max(1, target_lines)
	
	var target_leftover_score := target_leftover_score(leftover_lines)
	
	rank_result.speed_rank = log(rank_result.speed / target_speed) / log(RDF_SPEED)
	if rank_result.compare == "-seconds" or finish_condition.type == Milestone.TIME_OVER:
		# for modes like 'ultra' and 'sprint' where time matters, line/piece rank scales with speed
		rank_result.lines_rank = log(rank_result.lines / float(target_lines)) / log(RDF_SPEED)
		rank_result.pieces_rank = log(rank_result.pieces / (target_lines * 2.0)) / log(RDF_SPEED)
	else:
		# for modes like 'marathon' where time matters, line/piece rank scales with endurance
		rank_result.lines_rank = log(rank_result.lines / float(target_lines)) / log(RDF_ENDURANCE)
		rank_result.pieces_rank = log(rank_result.pieces / (target_lines * 2.0)) / log(RDF_ENDURANCE)
	
	if target_box_score_per_line == 0:
		# award the player master rank if it's impossible to score any box points on a level
		rank_result.box_score_per_line_rank = 0.0
	else:
		rank_result.box_score_per_line_rank = log(rank_result.box_score_per_line / target_box_score_per_line) \
				/ log(RDF_BOX_SCORE_PER_LINE)
	
	if target_combo_score_per_line == 0:
		# award the player master rank if it's impossible to score any combo points on a level
		rank_result.combo_score_per_line_rank = 0.0
	else:
		rank_result.combo_score_per_line_rank = log(rank_result.combo_score_per_line / target_combo_score_per_line) \
				/ log(RDF_COMBO_SCORE_PER_LINE)
	
	if target_pickup_score > 0:
		rank_result.pickup_score_rank = log(rank_result.pickup_score / target_pickup_score) \
				/ log(RDF_PICKUP_SCORE)
	elif target_pickup_score_per_line > 0:
		rank_result.pickup_score_rank = log(rank_result.pickup_score_per_line / target_pickup_score_per_line) \
				/ log(RDF_PICKUP_SCORE_PER_LINE)
	else:
		# award the player master rank if it's impossible to score any pickup points on a level
		rank_result.pickup_score_rank = 0.0
	
	# Binary search for the player's overall rank. Overall rank is a function of several criteria, the rank doesn't
	# deteriorate in a predictable way like the other ranks
	var overall_rank_max := WORST_RANK
	var overall_rank_min := BEST_RANK
	for _i in range(20):
		var tmp_overall_rank := (overall_rank_max + overall_rank_min) / 2.0
		var tmp_box_score_per_line := target_box_score_per_line \
				* pow(RDF_BOX_SCORE_PER_LINE, tmp_overall_rank)
		var tmp_combo_score_per_line := target_combo_score_per_line \
				* pow(RDF_COMBO_SCORE_PER_LINE, tmp_overall_rank)
		var tmp_pickup_score_per_line := target_pickup_score_per_line \
				* pow(RDF_PICKUP_SCORE_PER_LINE, tmp_overall_rank)
		var tmp_leftover_score := target_leftover_score \
				* pow(RDF_BOX_SCORE_PER_LINE, tmp_overall_rank) \
				* pow(RDF_COMBO_SCORE_PER_LINE, tmp_overall_rank)
		
		if rank_result.compare == "-seconds":
			# for modes like 'ultra' where you race to a score, rank scales with speed
			var tmp_speed := rank_lpm(tmp_overall_rank)
			var tmp_lines: float = target_lines_for_score(tmp_box_score_per_line, tmp_combo_score_per_line)
			var seconds_per_line := 60 / tmp_speed
			var target_seconds := seconds_per_line * tmp_lines
			
			if target_seconds < rank_result.seconds:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
		else:
			# calculate the expected line count for this rank
			var tmp_lines: float
			if finish_condition.type == Milestone.TIME_OVER:
				# for modes like 'sprint' where you go for a high score in a time limit, rank scales with speed
				var tmp_speed := rank_lpm(tmp_overall_rank)
				tmp_lines = tmp_speed * finish_condition.value / 60.0
				
				# factor in preplaced pieces
				if CurrentLevel.settings.rank.preplaced_pieces:
					tmp_lines += CurrentLevel.settings.rank.preplaced_pieces / 2.0
			else:
				# for modes like 'marathon' where you aim for a number of lines, rank scales with endurance
				tmp_lines = target_lines * pow(RDF_ENDURANCE, tmp_overall_rank)
			
			# adjust the expected leftover score for this rank
			if finish_condition.type == Milestone.TIME_OVER:
				# for modes like 'sprint' with a time limit, leftover score scales with speed
				var tmp_speed := rank_lpm(tmp_overall_rank)
				tmp_leftover_score *= tmp_speed / target_speed
			else:
				# for modes like 'marathon' with no time limit, leftover score scales with endurance
				# (well, technically speaking it scales with cleverness)
				tmp_leftover_score *= pow(RDF_ENDURANCE, tmp_overall_rank)
			
			var tmp_box_score := tmp_box_score_per_line * tmp_lines
			var tmp_combo_score := tmp_combo_score_per_line * tmp_lines
			tmp_combo_score = max(0, tmp_combo_score - COMBO_DEFICIT[min(ceil(tmp_lines), COMBO_DEFICIT.size() - 1)])
			var tmp_pickup_score := tmp_pickup_score_per_line * tmp_lines
			var tmp_score := tmp_lines + tmp_box_score + tmp_combo_score + tmp_pickup_score + tmp_leftover_score
			if tmp_score > rank_result.score:
				overall_rank_min = tmp_overall_rank
			else:
				overall_rank_max = tmp_overall_rank
	
	if rank_result.compare == "-seconds":
		if rank_result.lost:
			rank_result.seconds_rank = WORST_RANK
		else:
			rank_result.seconds_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	else:
		rank_result.score_rank = stepify((overall_rank_max + overall_rank_min) / 2.0, 0.01)
	
	if MilestoneManager.is_met(CurrentLevel.settings.success_condition):
		if rank_result.compare == "-seconds":
			rank_result.seconds_rank -= CurrentLevel.settings.rank.success_bonus
		else:
			rank_result.score_rank -= CurrentLevel.settings.rank.success_bonus
	
	_clamp_result(rank_result, lenient)


## calculate score for leftover_lines; leftover lines should be a tall stack with half as many box points
func target_leftover_score(leftover_lines: int) -> float:
	var box_score := master_box_score(CurrentLevel.settings) * leftover_lines
	var combo_score := 20 * leftover_lines
	
	# if the combo factor is 0, they will be starting a new combo for the leftovers
	if CurrentLevel.settings.rank.combo_factor == 0.0:
		combo_score = max(0, combo_score - COMBO_DEFICIT[min(ceil(leftover_lines), COMBO_DEFICIT.size() - 1)])
	
	return box_score + combo_score + leftover_lines


## calculate the number of lines needed to reach a target score
func target_lines_for_score(box_score_per_line: float, combo_score_per_line: float) -> int:
	if CurrentLevel.settings.finish_condition.value == 0:
		return 0
	
	var combo_efficiency := combo_score_per_line / 20.0
	
	var result := 0
	for i in range(1, COMBO_DEFICIT.size()):
		if (1 + box_score_per_line) * i + _max_combo_score(i) * combo_efficiency \
				>= CurrentLevel.settings.finish_condition.value:
			result = i
			break
	
	if not result:
		var tmp_scoring_target: float = CurrentLevel.settings.finish_condition.value \
				+ COMBO_DEFICIT[COMBO_DEFICIT.size() - 1] * combo_efficiency
		result = ceil(tmp_scoring_target / (1 + box_score_per_line + combo_score_per_line))
	
	# factor in preplaced pieces
	if CurrentLevel.settings.rank.preplaced_pieces:
		result = max(1, result - (CurrentLevel.settings.rank.preplaced_pieces / 2.0))
	
	return result


## Clamps the player's ranks within [0, 999] to avoid edge cases.
##
## Most importantly, this patches up cases where we've previously divided by zero or calculated the natural log of
## zero. Serializing an infinite/undefined float into JSON corrupts the player's save file.
##
## The player cannot achieve a master rank if the lenient flag is set.
func _clamp_result(rank_result: RankResult, lenient: bool) -> void:
	var min_rank := 1.0 if lenient else BEST_RANK
	var max_rank := WORST_RANK
	rank_result.speed_rank = clamp(rank_result.speed_rank, min_rank, max_rank)
	rank_result.lines_rank = clamp(rank_result.lines_rank, min_rank, max_rank)
	rank_result.pieces_rank = clamp(rank_result.pieces_rank, min_rank, max_rank)
	rank_result.box_score_per_line_rank = clamp(rank_result.box_score_per_line_rank, min_rank, max_rank)
	rank_result.combo_score_per_line_rank = clamp(rank_result.combo_score_per_line_rank, min_rank, max_rank)
	rank_result.score_rank = clamp(rank_result.score_rank, min_rank, max_rank)
	rank_result.seconds_rank = clamp(rank_result.seconds_rank, min_rank, max_rank)
	rank_result.pickup_score_rank = clamp(rank_result.pickup_score_rank, min_rank, max_rank)


## Converts a numeric grade such as '12.6' into a grade string such as 'S+'.
static func grade(rank: float) -> String:
	var grade := NO_GRADE
	
	for grade_ranks_entry in GRADE_RANKS:
		if rank <= grade_ranks_entry[1]:
			grade = grade_ranks_entry[0]
			break
	
	return grade


## Calculates the next grade better than the specified grade.
##
## next_grade("A-")  = "A"
## next_grade("SSS") = "M"
## next_grade("M")   = "M"
## next_grade("-")   = "B-"
static func next_grade(grade: String) -> String:
	var result := NO_GRADE
	for i in range(GRADE_RANKS.size()):
		if grade == GRADE_RANKS[i][0]:
			result = GRADE_RANKS[max(0, i - 1)][0]
	return result


## Converts a letter grade such as 'S+' into a numeric rating such as '12.6'.
##
## The resulting rating is an average rating for that grade -- not a minimum cutoff.
static func rank(grade: String) -> float:
	var rank_lo := WORST_RANK
	var rank_hi := WORST_RANK
	
	for i in range(GRADE_RANKS.size() - 1):
		if grade == GRADE_RANKS[i][0]:
			rank_lo = GRADE_RANKS[max(0, i - 1)][1]
			rank_hi = GRADE_RANKS[i][1]
	
	return 0.5 * (rank_lo + rank_hi)


## Returns the maximum box score per line for the specified level.
static func master_box_score(settings: LevelSettings) -> float:
	return settings.rank.box_factor * MASTER_BOX_SCORE


## Returns the maximum combo score per line for the specified level.
static func master_combo_score(settings: LevelSettings) -> float:
	return settings.rank.combo_factor * MASTER_COMBO_SCORE


## Returns the maximum pickup score per line for the specified level.
static func master_pickup_score_per_line(settings: LevelSettings) -> float:
	return settings.rank.master_pickup_score_per_line


## Returns the maximum overall pickup score for the specified level.
static func master_pickup_score(settings: LevelSettings) -> float:
	return settings.rank.master_pickup_score


## Returns the maximum combo expected for a single customer for the specified level.
static func master_customer_combo(settings: LevelSettings) -> int:
	return settings.rank.customer_combo if settings.rank.customer_combo else MASTER_CUSTOMER_COMBO


## Returns the maximum number of leftover lines expected for the specified level.
static func master_leftover_lines(settings: LevelSettings) -> int:
	var result: int
	if settings.rank.leftover_lines:
		result = settings.rank.leftover_lines
	elif settings.other.tile_set == PuzzleTileMap.TileSetType.VEGGIE:
		result = 0
	else:
		result = MASTER_LEFTOVER_LINES
	return result
