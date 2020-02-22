"""
Contains the logic for 'Marathon mode', a game style which gets harder and harder but theoretically goes on forever if
the player is good enough.
"""
extends Node2D

# Lines required for each level. Because the player starts at level 1, the first two levels have no requirement.
const lines_to_level = [
	# 0 - 15 (beginner -> 1 G)
	0, 0, 10, 20, 30, 40, 50, 60, 70, 80, 100, 110, 120, 130, 140, 150,
	# 16 - 20 (0.5 G -> 20 G)
	200, 220, 240, 260, 280, 300
]

# Hints displayed after the player loses
const HINTS = [
	"Make silver boxes with a pentomino and a quadromino!",
	"Make gold boxes with 3 pentominos!",
	"Make gold boxes with 3 quadrominos!",
	"Silver boxes score 5 points per line, gold boxes score 10. Make lots of boxes!",
	"Combos add up to 20 points for completing a line. Make lots of combos!",
	"Build a big combo by making boxes and clearing lines!",
	"When a piece locks, hold left or right to quickly move the next piece!",
	"When a piece locks, hold a rotate key to quickly rotate the next piece!",
	"When a piece locks, hold both rotate keys to quickly rotate the next piece!",
	"When a piece locks, hold up to quickly hard-drop the next piece!",
	"Press 'C' to hold the current piece. ...Just kidding!",
]

# Colors used to render the level number. Easy levels are green, and hard levels are red.
const LEVEL_COLOR_0 = Color(0.111, 0.888, 0.111, 1)
const LEVEL_COLOR_1 = Color(0.444, 0.888, 0.111, 1)
const LEVEL_COLOR_2 = Color(0.888, 0.888, 0.111, 1)
const LEVEL_COLOR_3 = Color(0.888, 0.444, 0.111, 1)
const LEVEL_COLOR_4 = Color(0.888, 0.222, 0.111, 1)
const LEVEL_COLOR_5 = Color(0.888, 0.111, 0.444, 1)

var level = 0 setget set_level

"""
Method invoked when the game ends. Prepares a game over message to show to the player.
"""
func _on_game_over():
	# calculate stats which are displayed to the player
	var score = $Game/Score.score
	# how many lines the player cleared
	var survival_score = $Game/Playfield.stats_lines
	# how many bonus points per line the player obtained from boxes
	var boxes_score = $Game/Playfield.stats_piece_score / float(max($Game/Playfield.stats_lines, 12))
	# how many bonus points per line the player obtained from combos
	var combos_score = $Game/Playfield.stats_combo_score / float(max($Game/Playfield.stats_lines - 4, 12))
	
	# the player's grade
	var survival_grade = "-"
	var boxes_grade = "-"
	var combos_grade = "-"
	var grade = "-"
	
	# requirements for a master grade
	var target_grade = "M"
	var target_survival_score = 300
	var target_boxes_score = 12.6
	var target_combos_score = 14.8
	var target_overall_score = (target_boxes_score + target_combos_score + 1) * target_survival_score
	
	# we repeatedly check whether the player meets the requirements for the current requirements. if not, we decrease
	# the requirements slightly, possibly decrease the grade slightly, and check again
	for i in range(0, 100):
		# check whether the player meets the current requirements, and assign their grade
		if survival_grade == "-" && survival_score >= target_survival_score:
			survival_grade = target_grade
		if boxes_grade == "-" && boxes_score >= target_boxes_score:
			boxes_grade = target_grade
		if combos_grade == "-" && combos_score >= target_combos_score:
			combos_grade = target_grade
		if grade == "-" && score >= target_overall_score:
			grade = target_grade
		
		# decrease the target grade requirements by a small amount
		target_survival_score *= sqrt(0.93)
		target_boxes_score *= sqrt(0.96)
		target_combos_score *= sqrt(0.98)
		
		# decrease the target grade, based on score requirements
		target_overall_score = (target_boxes_score + target_combos_score + 1) * target_survival_score
		if target_overall_score < 8000:
			target_grade = "S++"
		if target_overall_score < 7000:
			target_grade = "S+"
		if target_overall_score < 6500:
			target_grade = "S"
		if target_overall_score < 3500:
			target_grade = "S-"
		if target_overall_score < 3000:
			target_grade = "A++"
		if target_overall_score < 2600:
			target_grade = "A+"
		if target_overall_score < 2400:
			target_grade = "A"
		if target_overall_score < 1300:
			target_grade = "A-"
		if target_overall_score < 1000:
			target_grade = "B+"
		if target_overall_score < 800:
			target_grade = "B"
		if target_overall_score < 400:
			target_grade = "B-"
		if target_overall_score < 300:
			target_grade = "C+"
		if target_overall_score < 250:
			target_grade = "C"
		if target_overall_score < 125:
			target_grade = "C-"
		if target_overall_score < 100:
			target_grade = "D+"
		if target_overall_score < 80:
			target_grade = "D"
		if target_overall_score < 30:
			target_grade = "D-"
		if target_overall_score < 20:
			break
	
	# message shown to the player, including stats, grades, and a gameplay hint
	var message = ""
	message += str("Lines: ",stepify(survival_score, 1)," (",survival_grade,")\n")
	message += str("Boxes: ",stepify(boxes_score, 0.1)," (",boxes_grade,")\n")
	message += str("Combos: ",stepify(combos_score, 0.1)," (",combos_grade,")\n")
	message += str("Overall: ",grade,"\n")
	message += str("Hint: ",HINTS[randi() % HINTS.size()])

	$Game.show_detail_message(message)

"""
Method invoked when a line is cleared. Updates the level.
"""
func _on_line_clear():
	var lines = $Game/Playfield.stats_lines
	var new_level = level
	var lines_to_next_level = -1
	
	for i in range(0, lines_to_level.size()):
		if lines_to_level[i] <= lines:
			new_level = max(new_level, i)
		elif i < lines_to_level.size() - 1:
			lines_to_next_level = lines_to_level[i + 1]
	
	if level != new_level:
		$LevelUpSound.play()
		set_level(new_level)
	
	$HUD/ProgressBar.value = lines

func _on_start_game():
	set_level(1)
	$Game/Piece.set_piece_speed(0)

func _on_before_start_game():
	set_level(0)

"""
Sets the speed level and updates the UI elements accordingly.
"""
func set_level(new_level):
	$Game/Piece.set_piece_speed(new_level - 1)
	level = new_level
	if new_level == 0:
		# 'level 0' is used when the game is not running
		$HUD/LevelValue.text = "-"
		$HUD/LevelValue.add_color_override("font_color", Color(1, 1, 1, 1))
		
		$HUD/ProgressBar.get("custom_styles/fg").set_bg_color(Color(1, 1, 1, 0.33))
		$HUD/ProgressBar.max_value = 100
	else:
		# update UI elements for the current level
		$HUD/LevelValue.text = str(new_level)
		var level_color = LEVEL_COLOR_0
		if new_level >= 25:
			level_color = LEVEL_COLOR_5
		elif new_level >= 20:
			level_color = LEVEL_COLOR_4
		elif new_level >= 15:
			level_color = LEVEL_COLOR_3
		elif new_level >= 10:
			level_color = LEVEL_COLOR_2
		elif new_level >= 5:
			level_color = LEVEL_COLOR_1
		$HUD/LevelValue.add_color_override("font_color", level_color)
		
		$HUD/ProgressBar.get("custom_styles/fg").set_bg_color(Color(level_color.r, level_color.g, level_color.g, 0.33))
		if new_level < lines_to_level.size() - 1:
			$HUD/ProgressBar.min_value = lines_to_level[new_level]
			$HUD/ProgressBar.max_value = lines_to_level[new_level + 1]
		else:
			$HUD/ProgressBar.min_value = 0
			$HUD/ProgressBar.max_value = 100
