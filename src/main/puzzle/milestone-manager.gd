extends Node
"""
Tracks the player's progress towards milestones.

Milestones can involve reaching a certain score, clearing a certain number of lines or surviving a certain number of
seconds.

Reaching a milestone can increase the level, end the scenario, or trigger a success condition.
"""

func _ready() -> void:
	PuzzleScore.connect("score_changed", self, "_on_PuzzleScore_score_changed")


func _physics_process(_delta: float) -> void:
	if PuzzleScore.game_active and milestone_met(Scenario.settings.finish_condition):
		PuzzleScore.end_game()


func milestone_met(milestone: Milestone) -> bool:
	var result := false
	var progress := milestone_progress(milestone)
	match milestone.type:
		Milestone.NONE:
			result = false
		Milestone.TIME_UNDER:
			result = progress <= milestone.value
		_:
			result = progress >= milestone.value
	return result


"""
Returns the player's current progress toward the specified milestone.

Depending on the milestone type, the returned progress value could be the current score, number of lines cleared or
something else.
"""
func milestone_progress(milestone: Milestone) -> float:
	var progress: float
	match milestone.type:
		Milestone.CUSTOMERS:
			progress = PuzzleScore.creature_scores.size() - 1
		Milestone.LINES:
			progress = PuzzleScore.scenario_performance.lines
		Milestone.SCORE:
			progress = PuzzleScore.get_score() + PuzzleScore.get_bonus_score()
		Milestone.TIME_OVER, Milestone.TIME_UNDER:
			progress = PuzzleScore.scenario_performance.seconds
	return progress


"""
Returns the previously completed milestone.

This controls the speed at which the pieces move.
"""
func prev_milestone() -> Milestone:
	return Scenario.settings.level_ups[PuzzleScore.level_index]


"""
Returns the next upcoming milestone. This is reflected in the UI.

The next upcoming milestone could be a 'level up' if this scenario has multiple levels, or it could be the scenario's
finish condition.
"""
func next_milestone() -> Milestone:
	var milestone: Milestone
	if PuzzleScore.level_index + 1 < Scenario.settings.level_ups.size():
		milestone = Scenario.settings.level_ups[PuzzleScore.level_index + 1]
	else:
		milestone = Scenario.settings.finish_condition
	return milestone


"""
If the player reached a milestone, we increase the level.
"""
func _on_PuzzleScore_score_changed() -> void:
	var new_level_index: int = PuzzleScore.level_index
	
	while new_level_index + 1 < Scenario.settings.level_ups.size() \
			and milestone_met(Scenario.settings.level_ups[new_level_index + 1]):
		new_level_index += 1
	
	if PuzzleScore.level_index != new_level_index:
		PuzzleScore.level_index = new_level_index
