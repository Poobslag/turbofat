extends Label
"""
A UI component showing how long the player has spent on the current puzzle.
"""

# The time currently displayed on the timer.
var _displayed_time: float

func _ready() -> void:
	if Level.settings.finish_condition.type == Milestone.TIME_OVER:
		# we don't display a timer for timed levels as it would be redundant
		visible = false
		set_process(false)
	
	_refresh_text()


func _process(_delta: float) -> void:
	if _displayed_time != PuzzleScore.level_performance.seconds:
		_refresh_text()


"""
Updates the label to show the number of seconds the player has spent on the current puzzle.
"""
func _refresh_text() -> void:
	_displayed_time = PuzzleScore.level_performance.seconds
	text = StringUtils.format_duration(_displayed_time)
