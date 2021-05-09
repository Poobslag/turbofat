extends Label
"""
A UI component showing how long the player has spent on the current puzzle.
"""

func _ready() -> void:
	if CurrentLevel.settings.finish_condition.type == Milestone.TIME_OVER:
		# we don't display a timer for timed levels as it would be redundant
		visible = false
		set_process(false)
	
	_refresh_text()


func _process(_delta: float) -> void:
	_refresh_text()


"""
Updates the label to show the number of seconds the player has spent on the current puzzle.
"""
func _refresh_text() -> void:
	text = StringUtils.format_duration(int(ceil(PuzzleState.level_performance.seconds)))
