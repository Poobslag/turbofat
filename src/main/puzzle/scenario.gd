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
	PuzzleScore.reset()
	$TimeHud.hide()
	$LinesHud.hide()
	$ScoreHud.hide()
	match Global.scenario_settings.win_condition.type:
		ScenarioSettings.TIME:
			$TimeHud.show()
			var seconds := ceil(Global.scenario_settings.win_condition.value)
			$TimeHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]
		ScenarioSettings.LINES:
			$LinesHud.show()
			_set_level(0)
		ScenarioSettings.SCORE:
			$ScoreHud.show()
			$ScoreHud/ScoreValue.text = str(Global.scenario_settings.win_condition.value)
			$ScoreHud/TimeLabel.hide()
			$ScoreHud/TimeValue.hide()


func _physics_process(_delta: float) -> void:
	if Global.scenario_settings.win_condition.type == ScenarioSettings.TIME and $Puzzle/Playfield.clock_running:
		if PuzzleScore.scenario_performance.seconds >= Global.scenario_settings.win_condition.value:
			$MatchEndSound.play()
			$Puzzle.end_game(2.2, "Finish!")


func _process(_delta: float) -> void:
	if Global.scenario_settings.win_condition.type == ScenarioSettings.TIME:
		var seconds := ceil(Global.scenario_settings.win_condition.value - PuzzleScore.scenario_performance.seconds)
		$TimeHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]
	elif Global.scenario_settings.win_condition.type == ScenarioSettings.SCORE:
		var seconds := ceil(PuzzleScore.scenario_performance.seconds)
		$ScoreHud/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]


"""
Sets the speed level and updates the UI elements accordingly.
"""
func _set_level(new_level:int) -> void:
	_level = new_level
	var piece_speed: PieceSpeed = PieceSpeeds.speed(Global.scenario_settings.level_ups[new_level].level)
	$Puzzle/PieceManager.piece_speed = piece_speed
	
	# update UI elements for the current level
	$LinesHud/LevelValue.text = str(piece_speed.level)
	var level_color := LEVEL_COLOR_0
	if piece_speed.gravity >= 20 * PieceSpeeds.G and piece_speed.lock_delay < 20:
		level_color = LEVEL_COLOR_5
	elif piece_speed.gravity >= 20 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_4
	elif piece_speed.gravity >=  1 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_3
	elif piece_speed.gravity >= 128:
		level_color = LEVEL_COLOR_2
	elif piece_speed.gravity >= 32:
		level_color = LEVEL_COLOR_1
	$LinesHud/LevelValue.add_color_override("font_color", level_color)
	
	$LinesHud/ProgressBar.get("custom_styles/fg").set_bg_color(
			Color(level_color.r, level_color.g, level_color.g, 0.33))
	if new_level + 1 < Global.scenario_settings.level_ups.size():
		$LinesHud/ProgressBar.min_value = Global.scenario_settings.level_ups[new_level].value
		$LinesHud/ProgressBar.max_value = Global.scenario_settings.level_ups[new_level + 1].value
	elif Global.scenario_settings.win_condition.type == ScenarioSettings.LINES:
		$LinesHud/ProgressBar.min_value = Global.scenario_settings.level_ups[new_level].value
		$LinesHud/ProgressBar.max_value = Global.scenario_settings.win_condition.value
	else:
		$LinesHud/ProgressBar.min_value = 0
		$LinesHud/ProgressBar.max_value = 100


"""
Method invoked when the game ends. Stores the rank result for later.
"""
func _on_Puzzle_game_ended() -> void:
	# ensure score is up to date before calculating rank
	PuzzleScore.end_combo()
	var rank_result := _rank_calculator.calculate_rank()
	PlayerData.add_scenario_history(Global.scenario_settings.name, rank_result)
	PlayerData.money += rank_result.score
	PlayerSave.save_player_data()
	
	if Global.scenario_settings.win_condition.type == ScenarioSettings.SCORE:
		if not PuzzleScore.scenario_performance.died and rank_result.seconds_rank < 24:
			$ApplauseSound.play()
	else:
		if not PuzzleScore.scenario_performance.died and rank_result.score_rank < 24:
			$ApplauseSound.play()


"""
Method invoked when a line is cleared. Updates the level.
"""
func _on_Puzzle_lines_cleared(_cleared_lines: Array) -> void:
	var lines: int = PuzzleScore.scenario_performance.lines
	var new_level := _level
	
	while new_level + 1 < Global.scenario_settings.level_ups.size() \
			and Global.scenario_settings.level_ups[new_level + 1].value <= lines:
		new_level += 1
	
	if _level != new_level:
		$LevelUpSound.play()
		_set_level(new_level)
	
	if Global.scenario_settings.win_condition.type == ScenarioSettings.LINES:
		if new_level + 1 < Global.scenario_settings.level_ups.size():
			if Global.scenario_settings.level_ups[new_level + 1].type == ScenarioSettings.LINES:
				$LinesHud/ProgressBar.value = lines
		elif Global.scenario_settings.win_condition.type == ScenarioSettings.LINES:
			$LinesHud/ProgressBar.value = lines
		if lines >= Global.scenario_settings.win_condition.value:
			$ExcellentSound.play()
			$Puzzle.end_game(4.2, "You win!")
	
	if Global.scenario_settings.win_condition.type == ScenarioSettings.SCORE:
		var total_score: int = PuzzleScore.get_score() + PuzzleScore.get_combo_score()
		$ScoreHud/ProgressBar.value = total_score
		if total_score >= Global.scenario_settings.win_condition.value:
			$MatchEndSound.play()
			$Puzzle.end_game(2.2, "Finish!")


func _on_Puzzle_before_game_started() -> void:
	_set_level(0)

	if Global.scenario_settings.win_condition.type == ScenarioSettings.SCORE:
		$ScoreHud/TimeLabel.show()
		$ScoreHud/TimeValue.show()
		$ScoreHud/ScoreLabel.hide()
		$ScoreHud/ScoreValue.hide()
		$ScoreHud/ProgressBar.max_value = Global.scenario_settings.win_condition.value
		$ScoreHud/ProgressBar.value = 0
	
	if Global.scenario_settings.win_condition.type == ScenarioSettings.LINES:
		$LinesHud/ProgressBar.value = 0
