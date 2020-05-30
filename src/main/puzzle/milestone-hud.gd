extends Control
"""
Shows the user's scenario performance as a progress bar.

the progress bar fills up as they approach the next level up milestone. If there are no more levelups, it fills as they
approach the scenario's win/finish condition.

A label overlaid on the progress bar shows them how much further they need to progress to reach the scenario's
win/finish condition.
"""

# Colors used to render the level number. Easy levels are green, and hard levels are red/purple.
const LEVEL_COLOR_0 := Color("48b968")
const LEVEL_COLOR_1 := Color("78b948")
const LEVEL_COLOR_2 := Color("b9b948")
const LEVEL_COLOR_3 := Color("b95c48")
const LEVEL_COLOR_4 := Color("b94878")
const LEVEL_COLOR_5 := Color("b948b9")

func _ready() -> void:
	PuzzleScore.connect("combo_ended", self, "_on_PuzzleScore_combo_ended")
	PuzzleScore.connect("lines_changed", self, "_on_PuzzleScore_lines_changed")
	PuzzleScore.connect("score_changed", self, "_on_PuzzleScore_score_changed")
	PuzzleScore.connect("bonus_score_changed", self, "_on_PuzzleScore_bonus_score_changed")
	PuzzleScore.connect("after_scenario_prepared", self, "_on_PuzzleScore_after_scenario_prepared")
	match _winish_type():
		Milestone.CUSTOMERS:
			$Desc.text = "Customers"
		Milestone.LINES:
			$Desc.text = "Lines"
		Milestone.SCORE:
			$Desc.text = "Money"
		Milestone.TIME:
			$Desc.text = "Time"
	update_milebar()
	$Value.pick_largest_font()


func _process(_delta: float) -> void:
	if not PuzzleScore.game_prepared:
		return
	
	match _winish_type():
		Milestone.TIME:
			# update time display
			update_milebar()


"""
Defines the milestone progress bar min/max values.
"""
func update_milebar_bounds() -> void:
	$ProgressBar.min_value = Global.scenario_settings.level_ups[PuzzleScore.level_index].value
	if PuzzleScore.level_index + 1 < Global.scenario_settings.level_ups.size():
		# fill up the bar as they approach the next level
		$ProgressBar.max_value = Global.scenario_settings.level_ups[PuzzleScore.level_index + 1].value
	else:
		# fill up the bar as they near their goal
		$ProgressBar.max_value = _winish_value()


"""
Fills the milestone progress bar.
"""
func update_milebar_value() -> void:
	var current_value: int
	match _winish_type():
		Milestone.CUSTOMERS:
			current_value = PuzzleScore.customer_scores.size() - 1
		Milestone.LINES:
			current_value = PuzzleScore.scenario_performance.lines
		Milestone.SCORE:
			current_value = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
		Milestone.TIME:
			current_value = PuzzleScore.scenario_performance.seconds
	$ProgressBar.value = current_value


"""
Updates the milestone progress bar text.
"""
func update_milebar_text() -> void:
	var remaining := max(0, _winish_value() - $ProgressBar.value)
	match _winish_type():
		Milestone.CUSTOMERS, Milestone.LINES:
			$Value.text = StringUtils.comma_sep(remaining)
		Milestone.SCORE:
			$Value.text = "¥%s" % StringUtils.comma_sep(remaining)
		Milestone.TIME:
			$Value.text = StringUtils.format_duration(remaining)


"""
Updates the milestone progress bar color.

Color changes from green to red to purple as difficulty increases.
"""
func update_milebar_color() -> void:
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
	$ProgressBar.get("custom_styles/fg").set_bg_color(Global.to_transparent(level_color, 0.333))


"""
Update the milestone hud's content during a game.
"""
func update_milebar() -> void:
	update_milebar_bounds()
	update_milebar_value()
	update_milebar_text()
	update_milebar_color()


func _winish_type() -> int:
	return Global.scenario_settings.get_winish_condition().type


func _winish_value() -> int:
	return Global.scenario_settings.get_winish_condition().value


func _on_PuzzleScore_lines_changed(_value: int) -> void:
	update_milebar()


func _on_PuzzleScore_score_changed(_value: int) -> void:
	update_milebar()


func _on_PuzzleScore_bonus_score_changed(_value: int) -> void:
	update_milebar()


func _on_PuzzleScore_combo_ended() -> void:
	update_milebar()


func _on_PuzzleScore_after_scenario_prepared() -> void:
	update_milebar()
	
	# Lock in the font size at the start, but leave it the same after that. It would be distracting if the font got
	# bigger as the player progressed.
	$Value.pick_largest_font()
