"""
Contains the logic for 'Marathon mode', a game style which gets harder and harder but theoretically goes on forever if
the player is good enough.
"""
extends Node2D

# All gravity constants are integers like '16', which actually correspond to fractions like '16/256' which means the
# piece takes 16 frames to drop one row. G is the denominator of that fraction.
const G = 256

# Lines required for each level. Because the player starts at level 1, the first two levels have no requirement.
const LINES_TO_LEVEL = [
	# 0 - 15 (beginner -> 1 G)
	0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 100, 110, 120, 130, 140, 150,
	# 16 - 20 (0.5 G -> 20 G)
	200, 220, 240, 260, 280, 300
]

# Hints displayed after the player loses
const HINTS = [
	"Make a snack box by arranging a pentomino and a quadromino into a square!",
	"Make a rainbow cake by arranging 3 pentominos into a rectangle!",
	"Make a rainbow cake by arranging 3 quadrominos into a rectangle!",
	"A snack box scores 5 points per line, a rainbow cake scores 10. Make lots of cakes!",
	"Combos add up to 20 points for completing a line. Make lots of combos!",
	"Build a big combo by making boxes and clearing lines!",
	"When a piece locks, hold left or right to quickly move the next piece!",
	"When a piece locks, hold a rotate key to quickly rotate the next piece!",
	"When a piece locks, hold both rotate keys to quickly rotate the next piece!",
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

var RankCalculator = preload("res://scenes/RankCalculator.gd").new()

var _level := 0

# message shown to the player including stats, grades, and a gameplay hint
var _grade_message := ""

"""
Method invoked when the game ends. Prepares a game over message to show to the player.
"""
func _on_game_ended() -> void:
	var rank_results = RankCalculator.calculate_rank()
	
	_grade_message = "Lines: %.1f (%s)\n" % [rank_results.lines, grade(rank_results.lines_rank)]
	_grade_message += "Boxes: %.1f (%s)\n" % [rank_results.box_score, grade(rank_results.box_score_rank)]
	_grade_message += "Combos: %.1f (%s)\n" % [rank_results.combo_score, grade(rank_results.combo_score_rank)]
	_grade_message += "Overall: (%s)\n" % grade(rank_results.score_rank)
	_grade_message += "Hint: %s" % HINTS[randi() % HINTS.size()]

"""
Converts a numeric grade such as '12' into a grade string such as 'A+'.

This functionality arguably belongs in RankCalculator, although the concept of representing grades as strings is
specific to this class in its current state. Eventually, these may instead be stored as raw numbers, or displayed as
images.
"""
func grade(rank: float) -> String:
	if   rank < 1:  return "M"
	elif rank < 2:  return "S++"
	elif rank < 3:  return "S+"
	elif rank < 10: return "S"
	elif rank < 11: return "S-"
	elif rank < 14: return "A+"
	elif rank < 23: return "A"
	elif rank < 24: return "A-"
	elif rank < 27: return "B+"
	elif rank < 34: return "B"
	elif rank < 35: return "B-"
	elif rank < 37: return "C+"
	elif rank < 45: return "C"
	elif rank < 46: return "C-"
	elif rank < 47: return "D+"
	elif rank < 59: return "D"
	elif rank < 65: return "D-"
	else: return "-"

"""
Method invoked when a line is cleared. Updates the level.
"""
func _on_line_cleared() -> void:
	var lines: int = Global.scenario_performance.lines
	var new_level := _level
	
	while new_level + 1 < Global.scenario.level_up_conditions.size() && Global.scenario.level_up_conditions[new_level + 1].value <= lines:
		new_level += 1
	
	if _level != new_level:
		$LevelUpSound.play()
		_set_level(new_level)
	
	if new_level + 1 < Global.scenario.level_up_conditions.size():
		if Global.scenario.level_up_conditions[new_level + 1].type == "lines":
			$HUD/ProgressBar.value = lines
	elif Global.scenario.win_condition.type == "lines":
		$HUD/ProgressBar.value = lines
	
	if Global.scenario.win_condition.type == "lines" && lines >= Global.scenario.win_condition.value:
		$ExcellentSound.play()
		$Game.end_game(4.2, "You win!")

func _on_game_started() -> void:
	_set_level(0)

func _on_before_game_started() -> void:
	$HUD/LevelValue.text = "-"
	$HUD/LevelValue.add_color_override("font_color", Color(1, 1, 1, 1))
	
	$HUD/ProgressBar.get("custom_styles/fg").set_bg_color(Color(1, 1, 1, 0.33))
	$HUD/ProgressBar.min_value = 0
	$HUD/ProgressBar.max_value = 100
	$HUD/ProgressBar.value = 0

"""
Sets the speed level and updates the UI elements accordingly.
"""
func _set_level(new_level:int) -> void:
	_level = new_level
	$Game/Piece.set_piece_speed(Global.scenario.level_up_conditions[new_level].piece_speed)
	
	# update UI elements for the current level
	$HUD/LevelValue.text = str(Global.scenario.level_up_conditions[new_level].piece_speed.string)
	var gravity = Global.scenario.level_up_conditions[new_level].piece_speed.gravity
	var lock_delay = Global.scenario.level_up_conditions[new_level].piece_speed.lock_delay
	var level_color := LEVEL_COLOR_0
	if gravity >= 20 * G && lock_delay < 30:
		level_color = LEVEL_COLOR_5
	elif gravity >= 20 * G:
		level_color = LEVEL_COLOR_4
	elif gravity >=  1 * G:
		level_color = LEVEL_COLOR_3
	elif gravity >= 128:
		level_color = LEVEL_COLOR_2
	elif gravity >= 32:
		level_color = LEVEL_COLOR_1
	$HUD/LevelValue.add_color_override("font_color", level_color)
	
	$HUD/ProgressBar.get("custom_styles/fg").set_bg_color(Color(level_color.r, level_color.g, level_color.g, 0.33))
	if new_level + 1 < Global.scenario.level_up_conditions.size():
		$HUD/ProgressBar.min_value = Global.scenario.level_up_conditions[new_level].value
		$HUD/ProgressBar.max_value = Global.scenario.level_up_conditions[new_level + 1].value
	elif Global.scenario.win_condition.type == "lines":
		$HUD/ProgressBar.min_value = Global.scenario.level_up_conditions[new_level].value
		$HUD/ProgressBar.max_value = Global.scenario.win_condition.value
	else:
		$HUD/ProgressBar.min_value = 0
		$HUD/ProgressBar.max_value = 100

func _on_after_game_ended():
	$Game.show_detail_message(_grade_message)
