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

var _xolonium_24 := preload("res://assets/ui/xolonium-24.tres")
var _xolonium_36 := preload("res://assets/ui/xolonium-36.tres")
var _xolonium_48 := preload("res://assets/ui/xolonium-48.tres")

var _rank_calculator := RankCalculator.new()

var _level := 0

# milestone hud's description label, value label and progress bar
onready var _miledesc: Label = $Puzzle.miledesc()
onready var _milevalue: Label = $Puzzle.milevalue()
onready var _milebar: Label = $Puzzle.milebar()

func _ready() -> void:
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")
	PuzzleScore.connect("game_ended", self, "_on_PuzzleScore_game_ended")
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")

	match _winish_type():
		Milestone.CUSTOMERS:
			_miledesc.text = "Now Serving"
			_milevalue.set("custom_fonts/font", _xolonium_36)
			_milevalue.text = "1/%s" % _winish_value()
		Milestone.LINES:
			_miledesc.text = "Level"
			_milevalue.rect_position.y = 24
			_milevalue.set("custom_fonts/font", _xolonium_48)
			_set_level(0)
			_update_milestone_hud()
		Milestone.SCORE:
			_miledesc.text = "Goal"
			_milevalue.set("custom_fonts/font", _xolonium_24)
			_milevalue.text = "¥%s" % _winish_value()
		Milestone.TIME:
			_miledesc.text = "Time"
			_milevalue.set("custom_fonts/font", _xolonium_36)
			_milevalue.text = StringUtils.format_duration(_winish_value())
	
	if Global.scenario_settings.other.has("tutorial"):
		Global.customer_queue.push_front({
			"line_rgb": "6c4331", "body_rgb": "a854cb", "eye_rgb": "4fa94e dbe28e", "horn_rgb": "f1e398",
			"ear": "2", "horn": "0", "mouth": "1", "eye": "1"
		})
		Global.customer_switch = false
		Global.customer_fatten = false
		$Puzzle/CustomerView.summon_customer()
		$Puzzle.hide_chalkboard()


func _physics_process(_delta: float) -> void:
	if not PuzzleScore.game_active:
		return

	match _winish_type():
		Milestone.TIME:
			var seconds := PuzzleScore.scenario_performance.seconds
			if seconds >= _winish_value():
				$MatchEndSound.play()
				$Puzzle.end_game(2.2, "Finish!")


func _process(_delta: float) -> void:
	if not PuzzleScore.game_prepared:
		return
	
	match _winish_type():
		Milestone.SCORE, Milestone.TIME:
			# update time display
			_update_milestone_hud()


"""
Sets the speed level and updates the UI elements accordingly.
"""
func _set_level(new_level:int) -> void:
	_level = new_level
	var milestone: Milestone = Global.scenario_settings.level_ups[new_level]
	PieceSpeeds.current_speed = PieceSpeeds.speed(milestone.get_meta("level"))


"""
Prepare milestone hud content before the start of a game.

This involves one-time setup such as fonts and progress bar boundaries.
"""
func _prepare_milestone_hud() -> void:
	match _winish_type():
		Milestone.CUSTOMERS:
			_milebar.min_value = 1
			_milebar.max_value = _winish_value() + 1
		Milestone.SCORE:
			_milevalue.set("custom_fonts/font", _xolonium_36)
			_milebar.max_value = _winish_value()
	
	# Marathon mode varies its milestone progress bar color, but most modes just use white on cyan.
	match _winish_type():
		Milestone.LINES:
			pass
		_:
			_milevalue.add_color_override("font_color", Color.white)
			_milebar.get("custom_styles/fg").set_bg_color(Color(0.111, 0.888, 0.888, 0.333))


"""
Update the milestone hud's content during a game.

This involves refreshing 
"""
func _update_milestone_hud() -> void:
	match _winish_type():
		Milestone.CUSTOMERS:
			var customers := PuzzleScore.customer_scores.size()
			_milevalue.text = "%s/%s" % [min(customers, _winish_value()), _winish_value()]
			_milebar.value = customers
		Milestone.LINES:
			_milevalue.text = PieceSpeeds.current_speed.level
			if _level + 1 < Global.scenario_settings.level_ups.size():
				# marathon mode; fill up the bar as they approach the next level
				_milebar.min_value = Global.scenario_settings.level_ups[_level].value
				_milebar.max_value = Global.scenario_settings.level_ups[_level + 1].value
			else:
				# final level of marathon mode; fill up the bar as they near their goal
				_milebar.min_value = Global.scenario_settings.level_ups[_level].value
				_milebar.max_value = _winish_value()
			_milebar.value = PuzzleScore.scenario_performance.lines
		Milestone.SCORE:
			_milevalue.text = StringUtils.format_duration(PuzzleScore.scenario_performance.seconds)
			var total_score: int = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
			_miledesc.text = "Time"
			_milebar.value = total_score
		Milestone.TIME:
			_milevalue.text = \
					StringUtils.format_duration(_winish_value() - PuzzleScore.scenario_performance.seconds)
	
	match _winish_type():
		Milestone.LINES:
			# For marathon mode, the progress bar changes from green to red as difficulty increases.
			var level_color: Color
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
			else:
				level_color = LEVEL_COLOR_0
			
			_milevalue.add_color_override("font_color", level_color)
			_milebar.get("custom_styles/fg").set_bg_color(Global.to_transparent(level_color, 0.333))
		_:
			pass


func _winish_type() -> int:
	return Global.scenario_settings.get_winish_condition().type


func _winish_value() -> int:
	return Global.scenario_settings.get_winish_condition().value


func _check_for_match_end() -> void:
	if not PuzzleScore.game_active:
		return

	if _met_finish_condition(Global.scenario_settings.win_condition):
		$ExcellentSound.play()
		$Puzzle.end_game(4.2, "You win!")
	elif _met_finish_condition(Global.scenario_settings.finish_condition):
		$MatchEndSound.play()
		$Puzzle.end_game(2.2, "Finish!")


func _met_finish_condition(condition: Milestone) -> bool:
	var result := false
	match condition.type:
		Milestone.CUSTOMERS:
			var served_customers := PuzzleScore.customer_scores.size() - 1
			result = served_customers >= condition.value
		Milestone.LINES:
			var lines := PuzzleScore.scenario_performance.lines
			result = lines >= condition.value
		Milestone.SCORE:
			var total_score: int = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
			result = total_score >= condition.value
	return result


func _on_PuzzleScore_game_prepared() -> void:
	_set_level(0)
	_prepare_milestone_hud()
	_update_milestone_hud()


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
	
	_update_milestone_hud()
	_check_for_match_end()


func _on_PuzzleScore_combo_ended() -> void:
	_update_milestone_hud()
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
	
	match _winish_type():
		Milestone.SCORE:
			if not PuzzleScore.scenario_performance.died and rank_result.seconds_rank < 24: $ApplauseSound.play()
		_:
			if not PuzzleScore.scenario_performance.died and rank_result.score_rank < 24: $ApplauseSound.play()
