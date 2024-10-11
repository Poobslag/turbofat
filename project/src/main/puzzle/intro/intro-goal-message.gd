class_name IntroGoalMessage
extends Label
## Shows a goal message before a level.
##
## This message is something like "Earn ¥300 in 5:00 to continue on your journey!" or "Earn ¥25 with 15 lines for rank
## A!". The message describes how the player can reach their next scoring milestone.

## The type of goal the player is aiming for, such as ranking up or beating their high score.
enum GoalType {
	NONE,
	SUCCESS, # meeting the level's success criteria
	RANK, # reaching a new rank milestone
	PERSONAL_BEST # beating their own high score
}

var _sandbox_text := tr("There is no goal in this mode. Just have fun!")

func _ready() -> void:
	CurrentLevel.connect("settings_changed", self, "_on_Level_settings_changed")
	
	refresh()


## Updates the message text based on the player's performance on the current level.
func refresh() -> void:
	match CurrentLevel.settings.finish_condition.type:
		Milestone.CUSTOMERS:
			_prepare_vip_mode()
		Milestone.LINES:
			_prepare_marathon_lines_mode()
		Milestone.PIECES:
			_prepare_marathon_pieces_mode()
		Milestone.SCORE:
			_prepare_ultra_mode()
		Milestone.TIME_OVER:
			_prepare_sprint_mode()
		Milestone.NONE:
			_prepare_sandbox_mode()
		_:
			push_warning("Unrecognized finish condition: %s" % [CurrentLevel.settings.finish_condition.type])
			text = _sandbox_text


## Prepares a message for a "Score X points with Y customers" level.
func _prepare_vip_mode() -> void:
	var customers := CurrentLevel.settings.finish_condition.value
	var target := _calculate_score_target()
	text = _get_customers_goal_text(target.goal_type, target.grade, target.target_score, customers)


## Prepares a message for a "Score X points with Y lines" level.
func _prepare_marathon_lines_mode() -> void:
	var lines := CurrentLevel.settings.finish_condition.value
	var target := _calculate_score_target()
	text = _get_lines_goal_text(target.goal_type, target.grade, target.target_score, lines)


## Prepares a message for a "Score X points with Y pieces" level.
func _prepare_marathon_pieces_mode() -> void:
	var pieces := CurrentLevel.settings.finish_condition.value
	var target := _calculate_score_target()
	text = _get_pieces_goal_text(target.goal_type, target.grade, target.target_score, pieces)


## Prepares a message for a "Score as many points as you can in Y minutes" level.
func _prepare_sprint_mode() -> void:
	var time := CurrentLevel.settings.finish_condition.value
	var target := _calculate_score_target()
	text = _get_standard_goal_text(target.goal_type, target.grade, target.target_score, time)


## Prepares a message for a "Score X points as fast as possible" level.
func _prepare_ultra_mode() -> void:
	var score := CurrentLevel.settings.finish_condition.value
	var target := _calculate_time_target()
	text = _get_standard_goal_text(target.goal_type, target.grade, score, target.target_time)


func _prepare_sandbox_mode() -> void:
	text = _sandbox_text


## Calculates the target for a level where the player is graded on score.
##
## Most levels are graded on score, so this method is used for modes such as Marathon and Sprint.
##
## Returns:
## 	A dictionary with three entries:
## 		'grade': (String) Grade milestone the player should aim for if goal_type is 'RANK'
## 		'goal_type': (int) Enum from GoalType
## 		'target_score': (int) Score the player should aim for.
func _calculate_score_target() -> Dictionary:
	var result := {
		"grade": "",
		"goal_type": GoalType.NONE,
		"target_score": 0,
	}
	
	var rank_calculator := RankCalculator.new()
	var rank_criteria := rank_calculator.filled_rank_criteria()
	var best_result := PlayerData.level_history.best_result(CurrentLevel.level_id)
	
	if CurrentLevel.settings.success_condition.type == Milestone.SCORE \
			and (not best_result or best_result.score < CurrentLevel.settings.success_condition.value):
		# if they haven't met the success criteria, set the grade and target duration to the success criteria
		result.goal_type = GoalType.SUCCESS
		result.target_score = CurrentLevel.settings.success_condition.value
	elif not best_result or best_result.score < rank_criteria.thresholds_by_grade["A-"]:
		# default to 'A' rank (really, A- rank)
		result.goal_type = GoalType.RANK
		result.grade = "A"
		result.target_score = rank_criteria.thresholds_by_grade["A-"]
	elif best_result.score < rank_criteria.thresholds_by_grade["S-"]:
		# if they haven't met the S criteria, set the grade and target duration to S
		result.goal_type = GoalType.RANK
		result.grade = "S"
		result.target_score = rank_criteria.thresholds_by_grade["S-"]
	elif best_result.score < rank_criteria.thresholds_by_grade["SS"]:
		# if they haven't met the SS criteria, set the grade and target duration to SS
		result.goal_type = GoalType.RANK
		result.grade = "SS"
		result.target_score = rank_criteria.thresholds_by_grade["SS"]
	elif best_result.score < rank_criteria.thresholds_by_grade["SSS"]:
		# if they haven't met the SSS criteria, set the grade and target duration to SSS
		result.goal_type = GoalType.RANK
		result.grade = "SSS"
		result.target_score = rank_criteria.thresholds_by_grade["SSS"]
	else:
		# set the grade and target duration to their PB
		result.goal_type = GoalType.PERSONAL_BEST
		result.target_score = best_result.score + 1
	
	return result


## Calculates the target for a level where the player is graded on speed.
##
## For "Ultra" levels the player basically always gets the same score, so they're graded on speed instead.
##
## Returns:
## 	A dictionary with three entries:
## 		'grade': (String) Grade milestone the player should aim for if goal_type is 'RANK'
## 		'goal_type': (int) Enum from GoalType
## 		'target_time': (int) Time the player should aim for.
func _calculate_time_target() -> Dictionary:
	var result := {
		"grade": "",
		"goal_type": GoalType.NONE,
		"target_time": 0,
	}
	
	var rank_calculator := RankCalculator.new()
	var rank_criteria := rank_calculator.filled_rank_criteria()
	var best_result := PlayerData.level_history.best_result(CurrentLevel.level_id)
	
	if CurrentLevel.settings.success_condition.type == Milestone.TIME_UNDER \
			and (not best_result or best_result.seconds > CurrentLevel.settings.success_condition.value):
		# if they haven't met the success criteria, set the grade and target duration to the success criteria
		result.goal_type = GoalType.SUCCESS
		result.target_time = CurrentLevel.settings.success_condition.value
	elif not best_result or best_result.seconds > rank_criteria.thresholds_by_grade["A-"]:
		# default to 'A' rank (really, A- rank)
		result.goal_type = GoalType.RANK
		result.grade = "A"
		result.target_time = rank_criteria.thresholds_by_grade["A-"]
	elif best_result.seconds > rank_criteria.thresholds_by_grade["S-"]:
		# if they haven't met the S criteria, set the grade and target duration to S
		result.goal_type = GoalType.RANK
		result.grade = "S"
		result.target_time = rank_criteria.thresholds_by_grade["S-"]
	elif best_result.seconds > rank_criteria.thresholds_by_grade["SS"]:
		# if they haven't met the SS criteria, set the grade and target duration to SS
		result.goal_type = GoalType.RANK
		result.grade = "SS"
		result.target_time = rank_criteria.thresholds_by_grade["SS"]
	elif best_result.seconds > rank_criteria.thresholds_by_grade["SSS"]:
		# if they haven't met the SSS criteria, set the grade and target duration to SSS
		result.goal_type = GoalType.RANK
		result.grade = "SSS"
		result.target_time = rank_criteria.thresholds_by_grade["SSS"]
	else:
		# set the grade and target duration to their PB
		result.goal_type = GoalType.PERSONAL_BEST
		result.target_time = best_result.seconds - 1
	
	return result


## Returns an 'Earn X from Y customers...' message.
##
## Parameters:
## 	'goal_type': Enum from GoalType
##
## 	'grade': Grade milestone the player should aim for if goal_type is 'RANK'
##
## 	'score': Score the player should aim for
##
## 	'customers': The number of customers which ends the level.
func _get_customers_goal_text(goal_type: int, grade: String, score: int, customers: int) -> String:
	var result: String
	match goal_type:
		GoalType.NONE:
			result = _sandbox_text
		GoalType.SUCCESS:
			if PlayerData.career.is_career_mode():
				if customers == 1:
					result = tr("Earn %s from %s customer to continue on your journey!") \
							% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
				else:
					result = tr("Earn %s from %s customers to continue on your journey!") \
							% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
			else:
				if customers == 1:
					result = tr("Earn %s from %s customer for a passing grade!") \
							% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
				else:
					result = tr("Earn %s from %s customers for a passing grade!") \
							% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
		GoalType.RANK:
			if customers == 1:
				result = tr("Earn %s from %s customer for rank %s!") \
						% [StringUtils.format_money(score), StringUtils.english_number(self, customers), grade]
			else:
				result = tr("Earn %s from %s customers for rank %s!") \
						% [StringUtils.format_money(score), StringUtils.english_number(self, customers), grade]
		GoalType.PERSONAL_BEST:
			if customers == 1:
				result = tr("Earn %s from %s customer to beat your record!") \
						% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
			else:
				result = tr("Earn %s from %s customers to beat your record!") \
						% [StringUtils.format_money(score), StringUtils.english_number(self, customers)]
	return result


## Returns an 'Earn X with Y pieces...' message.
##
## Parameters:
## 	'goal_type': Enum from GoalType
##
## 	'grade': Grade milestone the player should aim for if goal_type is 'RANK'
##
## 	'score': Score the player should aim for
##
## 	'pieces': The number of pieces which ends the level.
func _get_pieces_goal_text(goal_type: int, grade: String, score: int, pieces: int) -> String:
	var result: String
	match goal_type:
		GoalType.NONE:
			result = _sandbox_text
		GoalType.SUCCESS:
			if PlayerData.career.is_career_mode():
				result = tr("Earn %s with %s pieces to continue on your journey!") \
						% [StringUtils.format_money(score), StringUtils.comma_sep(pieces)]
			else:
				result = tr("Earn %s with %s pieces for a passing grade!") \
						% [StringUtils.format_money(score), StringUtils.comma_sep(pieces)]
		GoalType.RANK:
			result = tr("Earn %s with %s pieces for rank %s!") \
					% [StringUtils.format_money(score), StringUtils.comma_sep(pieces), grade]
		GoalType.PERSONAL_BEST:
			result = tr("Earn %s with %s pieces to beat your record!") \
					% [StringUtils.format_money(score), StringUtils.comma_sep(pieces)]
	return result


## Returns an 'Earn X with Y lines...' message.
##
## Parameters:
## 	'goal_type': Enum from GoalType
##
## 	'grade': Grade milestone the player should aim for if goal_type is 'RANK'
##
## 	'score': Score the player should aim for
##
## 	'lines': The number of lines which ends the level.
func _get_lines_goal_text(goal_type: int, grade: String, score: int, lines: int) -> String:
	var result: String
	match goal_type:
		GoalType.NONE:
			result = _sandbox_text
		GoalType.SUCCESS:
			if PlayerData.career.is_career_mode():
				result = tr("Earn %s with %s lines to continue on your journey!") \
						% [StringUtils.format_money(score), StringUtils.comma_sep(lines)]
			else:
				result = tr("Earn %s with %s lines for a passing grade!") \
						% [StringUtils.format_money(score), StringUtils.comma_sep(lines)]
		GoalType.RANK:
			result = tr("Earn %s with %s lines for rank %s!") % \
					[StringUtils.format_money(score), StringUtils.comma_sep(lines), grade]
		GoalType.PERSONAL_BEST:
			result = tr("Earn %s with %s lines to beat your record!") % \
					[StringUtils.format_money(score), StringUtils.comma_sep(lines)]
	return result


## Returns an 'Earn X in Y minutes...' message.
##
## This method is used both for levels with a score goal and levels with a time goal, as the goal in both cases is to
## reach a target score in a limited amount of time.
##
## Parameters:
## 	'goal_type': Enum from GoalType
##
## 	'grade': Grade milestone the player should aim for if goal_type is 'RANK'
##
## 	'score': Score the player should aim for
##
## 	'time': The amount of time the player has to meet the target score
func _get_standard_goal_text(goal_type: int, grade: String, score: int, time: int) -> String:
	var result: String
	match goal_type:
		GoalType.NONE:
			result = _sandbox_text
		GoalType.SUCCESS:
			if PlayerData.career.is_career_mode():
				result = tr("Earn %s in %s to continue on your journey!") \
						% [StringUtils.format_money(score), StringUtils.format_duration(time)]
			else:
				result = tr("Earn %s in %s for a passing grade!") \
						% [StringUtils.format_money(score), StringUtils.format_duration(time)]
		GoalType.RANK:
			result = tr("Earn %s in %s for rank %s!") % \
					[StringUtils.format_money(score), StringUtils.format_duration(time), grade]
		GoalType.PERSONAL_BEST:
			result = tr("Earn %s in %s to beat your record!") % \
					[StringUtils.format_money(score), StringUtils.format_duration(time)]
	return result


func _on_Level_settings_changed() -> void:
	refresh()
