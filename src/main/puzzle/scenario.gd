extends Control
"""
Contains the logic for running a puzzle scenario. A puzzle scenario might include specific rules or win conditions
such as 'Marathon mode', a game style which gets harder and harder but theoretically goes on forever if the player is
good enough.
"""

# Colors used to render the level number. Easy levels are green, and hard levels are red.
const LEVEL_COLOR_0 := Color(0.111, 0.888, 0.111, 1)
const LEVEL_COLOR_1 := Color(0.444, 0.888, 0.111, 1)
const LEVEL_COLOR_2 := Color(0.888, 0.888, 0.111, 1)
const LEVEL_COLOR_3 := Color(0.888, 0.444, 0.111, 1)
const LEVEL_COLOR_4 := Color(0.888, 0.222, 0.111, 1)
const LEVEL_COLOR_5 := Color(0.888, 0.111, 0.444, 1)

var _rank_calculator := RankCalculator.new()

var _level := 0

func _ready() -> void:
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	$CustomerHud.hide()
	$LinesHud.hide()
	$ScoreHud.hide()
	$TimeHud.hide()

	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.CUSTOMERS:
			$CustomerHud.show()
			$CustomerHud/ProgressBar.min_value = 1
			$CustomerHud/ProgressBar.max_value = winish_condition.value
			$CustomerHud/CustomerValue.text = "1/%s" % winish_condition.value
		ScenarioSettings.LINES:
			$LinesHud.show()
			_set_level(0)
		ScenarioSettings.SCORE:
			$ScoreHud.show()
			$ScoreHud/ScoreValue.text = "¥%s" % winish_condition.value
			$ScoreHud/TimeLabel.hide()
			$ScoreHud/TimeValue.hide()
		ScenarioSettings.TIME:
			$TimeHud.show()
			var seconds := ceil(winish_condition.value)
			$TimeHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]


func _physics_process(_delta: float) -> void:
	if not PuzzleScore.game_active:
		return

	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.TIME:
			var seconds := PuzzleScore.scenario_performance.seconds
			if seconds >= winish_condition.value:
				$MatchEndSound.play()
				$Puzzle.end_game(2.2, "Finish!")


func _process(_delta: float) -> void:
	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.SCORE:
			var seconds := ceil(PuzzleScore.scenario_performance.seconds)
			$ScoreHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]
		ScenarioSettings.TIME:
			var seconds := ceil(winish_condition.value - PuzzleScore.scenario_performance.seconds)
			$TimeHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]


"""
Sets the speed level and updates the UI elements accordingly.
"""
func _set_level(new_level:int) -> void:
	_level = new_level
	PieceSpeeds.current_speed = PieceSpeeds.speed(Global.scenario_settings.level_ups[new_level].level)
	
	# update UI elements for the current level
	$LinesHud/LevelValue.text = str(PieceSpeeds.current_speed.level)
	var level_color := LEVEL_COLOR_0
	if PieceSpeeds.current_speed.gravity >= 20 * PieceSpeeds.G and PieceSpeeds.current_speed.lock_delay < 20:
		level_color = LEVEL_COLOR_5
	elif PieceSpeeds.current_speed.gravity >= 20 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_4
	elif PieceSpeeds.current_speed.gravity >=  1 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_3
	elif PieceSpeeds.current_speed.gravity >= 128:
		level_color = LEVEL_COLOR_2
	elif PieceSpeeds.current_speed.gravity >= 32:
		level_color = LEVEL_COLOR_1
	$LinesHud/LevelValue.add_color_override("font_color", level_color)
	
	$LinesHud/ProgressBar.get("custom_styles/fg").set_bg_color(
			Color(level_color.r, level_color.g, level_color.g, 0.33))
	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.LINES:
			if new_level + 1 < Global.scenario_settings.level_ups.size():
				# marathon mode; fill up the bar as they approach the next level
				$LinesHud/ProgressBar.min_value = Global.scenario_settings.level_ups[new_level].value
				$LinesHud/ProgressBar.max_value = Global.scenario_settings.level_ups[new_level + 1].value
			else:
				# final level of marathon mode; fill up the bar as they near their goal
				$LinesHud/ProgressBar.min_value = Global.scenario_settings.level_ups[new_level].value
				$LinesHud/ProgressBar.max_value = winish_condition.value


func _check_for_match_end() -> void:
	if not PuzzleScore.game_active:
		return

	if _met_finish_condition(Global.scenario_settings.win_condition):
		$ExcellentSound.play()
		$Puzzle.end_game(4.2, "You win!")
	elif _met_finish_condition(Global.scenario_settings.finish_condition):
		$MatchEndSound.play()
		$Puzzle.end_game(2.2, "Finish!")


func _met_finish_condition(condition: ScenarioSettings.FinishCondition) -> bool:
	var result := false
	match condition.type:
		ScenarioSettings.CUSTOMERS:
			var served_customers := PuzzleScore.customer_scores.size() - 1
			result = served_customers >= condition.value
		ScenarioSettings.LINES:
			var lines := PuzzleScore.scenario_performance.lines
			result = lines >= condition.value
		ScenarioSettings.SCORE:
			var total_score: int = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
			result = total_score >= condition.value
	return result


func _update_goal_hud() -> void:
	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.CUSTOMERS:
			var customers := min(PuzzleScore.customer_scores.size(), winish_condition.value)
			$CustomerHud/ProgressBar.value = customers
			$CustomerHud/CustomerValue.text = "%s/%s" % [customers, winish_condition.value]
		ScenarioSettings.LINES:
			var lines: int = PuzzleScore.scenario_performance.lines
			if _level + 1 < Global.scenario_settings.level_ups.size():
				if Global.scenario_settings.level_ups[_level + 1].type == ScenarioSettings.LINES:
					$LinesHud/ProgressBar.value = lines
			elif winish_condition.type == ScenarioSettings.LINES:
				$LinesHud/ProgressBar.value = lines
		ScenarioSettings.SCORE:
			var total_score: int = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
			$ScoreHud/ProgressBar.value = total_score


func _on_PuzzleScore_game_prepared() -> void:
	_set_level(0)

	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.CUSTOMERS:
			$CustomerHud/ProgressBar.min_value = 1
			$CustomerHud/ProgressBar.max_value = winish_condition.value
			$CustomerHud/ProgressBar.value = 0
			$CustomerHud/CustomerValue.text = "1/%s" % winish_condition.value
		ScenarioSettings.LINES:
			$LinesHud/ProgressBar.value = 0
		ScenarioSettings.SCORE:
			$ScoreHud/TimeLabel.show()
			$ScoreHud/TimeValue.show()
			$ScoreHud/ScoreLabel.hide()
			$ScoreHud/ScoreValue.hide()
			$ScoreHud/ProgressBar.max_value = winish_condition.value
			$ScoreHud/ProgressBar.value = 0


func _on_Puzzle_line_cleared(y: int, total_lines: int, remaining_lines: int, box_ints: Array) -> void:
	if not PuzzleScore.game_active:
		return
	
	var lines: int = PuzzleScore.scenario_performance.lines
	var new_level := _level
	
	while new_level + 1 < Global.scenario_settings.level_ups.size() \
			and Global.scenario_settings.level_ups[new_level + 1].value <= lines:
		new_level += 1
	
	if _level != new_level:
		$LevelUpSound.play()
		_set_level(new_level)
	
	_update_goal_hud()
	_check_for_match_end()


func _on_PuzzleScore_combo_ended() -> void:
	_update_goal_hud()
	_check_for_match_end()


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_PuzzleScore_game_ended() -> void:
	# ensure score is up to date before calculating rank
	PuzzleScore.end_combo()
	var rank_result := _rank_calculator.calculate_rank()
	PlayerData.add_scenario_history(Global.scenario_settings.name, rank_result)
	PlayerData.money += rank_result.score
	PlayerSave.save_player_data()
	
	var winish_condition: ScenarioSettings.FinishCondition = Global.scenario_settings.get_winish_condition()
	match winish_condition.type:
		ScenarioSettings.SCORE:
			if not PuzzleScore.scenario_performance.died and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.scenario_performance.died and rank_result.score_rank < 24: $ApplauseSound.play()
