class_name MilestoneHud
extends Control
"""
Shows the user's level performance as a progress bar.

the progress bar fills up as they approach the next level up milestone. If there are no more speedups, it fills as they
approach the level's win/finish condition.

A label overlaid on the progress bar shows them how much further they need to progress to reach the level's
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
	PuzzleScore.connect("game_prepared", self, "_on_PuzzleScore_game_prepared")
	Level.connect("settings_changed", self, "_on_Level_settings_changed")
	match Level.settings.finish_condition.type:
		Milestone.CUSTOMERS:
			$Desc.text = "Customers"
		Milestone.LINES:
			$Desc.text = "Lines"
		Milestone.SCORE:
			$Desc.text = "Money"
		Milestone.TIME_OVER:
			$Desc.text = "Time"
	init_milebar()


func _process(_delta: float) -> void:
	update_milebar()


"""
Updates the milestone progress bar's value and boundaries.
"""
func update_milebar_values() -> void:
	$ProgressBar.min_value = MilestoneManager.prev_milestone().value
	var next_milestone := MilestoneManager.next_milestone()
	if next_milestone.value == $ProgressBar.min_value:
		# avoid 'cannot get ratio' errors in sandbox mode
		$ProgressBar.max_value = $ProgressBar.min_value + 1.0
	else:
		$ProgressBar.max_value = next_milestone.value
	$ProgressBar.value = MilestoneManager.milestone_progress(next_milestone)


"""
Updates the milestone progress bar text.
"""
func update_milebar_text() -> void:
	var milestone := Level.settings.finish_condition
	var remaining: int = max(0, ceil(milestone.value - MilestoneManager.milestone_progress(milestone)))
	match milestone.type:
		Milestone.NONE:
			$Value.text = "-"
		Milestone.CUSTOMERS, Milestone.LINES:
			$Value.text = StringUtils.comma_sep(remaining)
		Milestone.SCORE:
			$Value.text = "¥%s" % StringUtils.comma_sep(remaining)
		Milestone.TIME_OVER:
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
	$ProgressBar.get("custom_styles/fg").set_bg_color(Utils.to_transparent(level_color, 0.333))


"""
Initializes the milestone progress bar's value and boundaries, and locks in the font size.

It would be distracting if the font got bigger as the player progressed, so the font size is only assigned at the
start of each level when the text should be at its longest value.
"""
func init_milebar() -> void:
	update_milebar()
	$Value.pick_largest_font()


"""
Update the milestone hud's content during a game.
"""
func update_milebar() -> void:
	update_milebar_values()
	update_milebar_text()
	update_milebar_color()


func _on_PuzzleScore_game_prepared() -> void:
	init_milebar()


func _on_Level_settings_changed() -> void:
	init_milebar()
