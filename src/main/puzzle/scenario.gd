extends Node2D
"""
Contains the logic for running a puzzle scenario. A puzzle scenario might include specific rules or win conditions
such as 'Marathon mode', a game style which gets harder and harder but theoretically goes on forever if the player is
good enough.
"""

# Hints displayed after the player loses
const HINTS = [
	"Make a snack box by arranging a pentomino and a quadromino into a square!",
	"Make a rainbow cake by arranging 3 pentominos into a rectangle!",
	"Make a rainbow cake by arranging 3 quadrominos into a rectangle!",
	"A snack box scores 5 points per line, a rainbow cake scores 10. Make lots of cakes!",
	"Combos can give you 20 bonus points for completing a line. Make lots of combos!",
	"Build a big combo by making boxes and clearing lines!",
	"When a piece locks, hold left or right to quickly move the next piece!",
	"When a piece locks, hold a rotate key to quickly rotate the next piece!",
	"When a piece locks, hold both rotate keys to quickly flip the next piece!",
	"When a piece locks, hold up to quickly hard-drop the next piece!",
	"After a hard drop, tap 'down' to delay the piece from locking!",
	"Sometimes, pressing 'down' can cheat pieces through other pieces!"
]

# Colors used to render the level number. Easy levels are green, and hard levels are red.
const LEVEL_COLOR_0 := Color(0.111, 0.888, 0.111, 1)
const LEVEL_COLOR_1 := Color(0.444, 0.888, 0.111, 1)
const LEVEL_COLOR_2 := Color(0.888, 0.888, 0.111, 1)
const LEVEL_COLOR_3 := Color(0.888, 0.444, 0.111, 1)
const LEVEL_COLOR_4 := Color(0.888, 0.222, 0.111, 1)
const LEVEL_COLOR_5 := Color(0.888, 0.111, 0.444, 1)

var _rank_calculator = RankCalculator.new()

var _level := 0

# message shown to the player including stats, grades, and a gameplay hint
var _grade_message := ""

func _ready() -> void:
	# reset statistics like time taken, lines cleared
	Global.scenario_performance = ScenarioPerformance.new()
	
	$TimeHUD.hide()
	$LinesHUD.hide()
	$ScoreHUD.hide()
	if Global.scenario_settings.win_condition.type == "time":
		$TimeHUD.show()
		var seconds = ceil(Global.scenario_settings.win_condition.value)
		$TimeHUD/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]
	
	if Global.scenario_settings.win_condition.type == "lines":
		$LinesHUD.show()
		_set_level(0)
	
	if Global.scenario_settings.win_condition.type == "score":
		$ScoreHUD.show()
		$ScoreHUD/ScoreValue.text = str(Global.scenario_settings.win_condition.value)
		$ScoreHUD/TimeLabel.hide()
		$ScoreHUD/TimeValue.hide()


func _physics_process(_delta: float) -> void:
	if Global.scenario_settings.win_condition.type == "time" and $Puzzle/Playfield.clock_running:
		if Global.scenario_performance.seconds >= Global.scenario_settings.win_condition.value:
			$MatchEndSound.play()
			$Puzzle.end_game(2.2, "Finish!")


func _process(_delta: float) -> void:
	if Global.scenario_settings.win_condition.type == "time":
		var seconds = ceil(Global.scenario_settings.win_condition.value - Global.scenario_performance.seconds)
		$TimeHUD/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]
	elif Global.scenario_settings.win_condition.type == "score":
		var seconds = ceil(Global.scenario_performance.seconds)
		$ScoreHUD/TimeValue.text = "%01d:%02d" % [int(seconds) / 60, int(seconds) % 60]


"""
Sets the speed level and updates the UI elements accordingly.
"""
func _set_level(new_level:int) -> void:
	_level = new_level
	$Puzzle/Piece.set_piece_speed(Global.scenario_settings.level_up_conditions[new_level].piece_speed)
	
	# update UI elements for the current level
	$LinesHUD/LevelValue.text = str(Global.scenario_settings.level_up_conditions[new_level].piece_speed.string)
	var gravity = Global.scenario_settings.level_up_conditions[new_level].piece_speed.gravity
	var lock_delay = Global.scenario_settings.level_up_conditions[new_level].piece_speed.lock_delay
	var level_color := LEVEL_COLOR_0
	if gravity >= 20 * PieceSpeeds.G and lock_delay < 30:
		level_color = LEVEL_COLOR_5
	elif gravity >= 20 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_4
	elif gravity >=  1 * PieceSpeeds.G:
		level_color = LEVEL_COLOR_3
	elif gravity >= 128:
		level_color = LEVEL_COLOR_2
	elif gravity >= 32:
		level_color = LEVEL_COLOR_1
	$LinesHUD/LevelValue.add_color_override("font_color", level_color)
	
	$LinesHUD/ProgressBar.get("custom_styles/fg").set_bg_color(Color(level_color.r, level_color.g, level_color.g, 0.33))
	if new_level + 1 < Global.scenario_settings.level_up_conditions.size():
		$LinesHUD/ProgressBar.min_value = Global.scenario_settings.level_up_conditions[new_level].value
		$LinesHUD/ProgressBar.max_value = Global.scenario_settings.level_up_conditions[new_level + 1].value
	elif Global.scenario_settings.win_condition.type == "lines":
		$LinesHUD/ProgressBar.min_value = Global.scenario_settings.level_up_conditions[new_level].value
		$LinesHUD/ProgressBar.max_value = Global.scenario_settings.win_condition.value
	else:
		$LinesHUD/ProgressBar.min_value = 0
		$LinesHUD/ProgressBar.max_value = 100


"""
Method invoked when the game ends. Prepares a game over message to show to the player.
"""
func _on_Puzzle_game_ended() -> void:
	# ensure score is up to date before calculating rank
	$Puzzle/Score.end_combo()
	var rank_result = _rank_calculator.calculate_rank()
	ScenarioHistory.add_scenario_history(Global.scenario_settings.name, rank_result)
	ScenarioHistory.save_scenario_history()
	
	_grade_message = ""
	if Global.scenario_settings.win_condition.type == "score":
		_grade_message += "Speed: %.1f (%s)\n" % [rank_result.speed, Global.grade(rank_result.speed_rank)]
	else:
		_grade_message += "Lines: %.1f (%s)\n" % [rank_result.lines, Global.grade(rank_result.lines_rank)]
	_grade_message += "Boxes: %.1f (%s)\n" % [rank_result.box_score_per_line, Global.grade(rank_result.box_score_per_line_rank)]
	_grade_message += "Combos: %.1f (%s)\n" % [rank_result.combo_score_per_line, Global.grade(rank_result.combo_score_per_line_rank)]
	if Global.scenario_settings.win_condition.type == "score":
		var seconds = ceil(Global.scenario_performance.seconds)
		_grade_message += "Overall: %01d:%02d (%s)\n" % [int(seconds) / 60, int(seconds) % 60, Global.grade(rank_result.seconds_rank)]
		if not Global.scenario_performance.died and rank_result.seconds_rank < 24:
			$ApplauseSound.play()
	else:
		_grade_message += "Overall: (%s)\n" % Global.grade(rank_result.score_rank)
		if not Global.scenario_performance.died and rank_result.score_rank < 24:
			$ApplauseSound.play()
	_grade_message += "Hint: %s" % HINTS[randi() % HINTS.size()]


"""
Method invoked when a line is cleared. Updates the level.
"""
func _on_Puzzle_line_cleared(_lines_cleared: int) -> void:
	var lines: int = Global.scenario_performance.lines
	var new_level := _level
	
	while new_level + 1 < Global.scenario_settings.level_up_conditions.size() and Global.scenario_settings.level_up_conditions[new_level + 1].value <= lines:
		new_level += 1
	
	if _level != new_level:
		$LevelUpSound.play()
		_set_level(new_level)
	
	if Global.scenario_settings.win_condition.type == "lines":
		if new_level + 1 < Global.scenario_settings.level_up_conditions.size():
			if Global.scenario_settings.level_up_conditions[new_level + 1].type == "lines":
				$LinesHUD/ProgressBar.value = lines
		elif Global.scenario_settings.win_condition.type == "lines":
			$LinesHUD/ProgressBar.value = lines
		if lines >= Global.scenario_settings.win_condition.value:
			$ExcellentSound.play()
			$Puzzle.end_game(4.2, "You win!")
	
	if Global.scenario_settings.win_condition.type == "score":
		var total_score: int = $Puzzle/Score.score + $Puzzle/Score.combo_score
		$ScoreHUD/ProgressBar.value = total_score
		if total_score >= Global.scenario_settings.win_condition.value:
			$MatchEndSound.play()
			$Puzzle.end_game(2.2, "Finish!")


func _on_Puzzle_before_game_started() -> void:
	_set_level(0)

	if Global.scenario_settings.win_condition.type == "score":
		$ScoreHUD/TimeLabel.show()
		$ScoreHUD/TimeValue.show()
		$ScoreHUD/ScoreLabel.hide()
		$ScoreHUD/ScoreValue.hide()
		$ScoreHUD/ProgressBar.max_value = Global.scenario_settings.win_condition.value
		$ScoreHUD/ProgressBar.value = 0
	
	if Global.scenario_settings.win_condition.type == "lines":
		$LinesHUD/ProgressBar.value = 0


func _on_Puzzle_after_game_ended() -> void:
	$Puzzle.show_detail_message(_grade_message)
