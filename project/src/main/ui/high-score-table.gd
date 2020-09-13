extends VBoxContainer
"""
A table which displays the player's high scores in practice mode.

Scores are separated by mode and difficulty. We also keep daily scores separate.
"""

# scenario to display high scores for
var _scenario: ScenarioSettings setget set_scenario

# if true, only performances with today's date are included
export (bool) var daily := false setget set_daily

func _ready() -> void:
	_refresh_contents()


"""
Toggles this high score table between 'Today's Best' and 'All-time Best'
"""
func set_daily(new_daily: bool) -> void:
	daily = new_daily
	_refresh_contents()


"""
Sets the scenario to display high scores for.
"""
func set_scenario(new_scenario: ScenarioSettings) -> void:
	_scenario = new_scenario
	_refresh_contents()


"""
Clears all rows in the grid container.
"""
func _clear_rows() -> void:
	$Label.text = "Today's Best" if daily else "All-time Best"
	for child_obj in $GridContainer.get_children():
		var child: Node = child_obj
		child.queue_free()


"""
Adds new rows to the grid container.
"""
func _add_rows() -> void:
	if not _scenario:
		return
	
	for best_result_obj in PlayerData.scenario_history.best_results(_scenario.id, daily):
		var best_result: RankResult = best_result_obj
		var row := []

		# append timestamp
		if daily:
			row.append("%02d:%02d" % [
					best_result.timestamp["hour"],
					best_result.timestamp["minute"],
				])
		else:
			row.append("%04d-%02d-%02d" % [
					best_result.timestamp["year"],
					best_result.timestamp["month"],
					best_result.timestamp["day"],
				])

		# append lines
		row.append(StringUtils.comma_sep(best_result.lines))

		# append score/time and grade
		if best_result.compare == "-seconds":
			var seconds_string := StringUtils.format_duration(best_result.seconds)
			if best_result.lost:
				seconds_string = "-"
			row.append(seconds_string)
			row.append(RankCalculator.grade(best_result.seconds_rank))
		else:
			var score_string := "¥%s" % StringUtils.comma_sep(best_result.score)
			if best_result.lost:
				score_string += "*"
			row.append(score_string)
			row.append(RankCalculator.grade(best_result.score_rank))

		_add_row(row)


"""
Clears and regenerates the cells in the grid container.
"""
func _refresh_contents() -> void:
	if not is_inside_tree():
		return
	
	_clear_rows()
	_add_rows()


"""
Adds a new row to the grid container.
"""
func _add_row(items: Array) -> void:
	for item_obj in items:
		var item: String = item_obj
		var item_label := Label.new()
		item_label.text = item
		item_label.size_flags_horizontal = Label.SIZE_EXPAND
		$GridContainer.add_child(item_label)
