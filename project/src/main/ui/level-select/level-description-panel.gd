extends Panel
"""
A panel on the level select screen which shows level descriptions.
"""

"""
Updates the description panel when a new level is selected.
"""
func _on_LevelButtons_level_selected(settings: ScenarioSettings) -> void:
	$MarginContainer/Label.text = settings.description


func _on_LevelButtons_overall_selected(ranks: Array) -> void:
	# calculate the worst rank
	var worst_rank := 0.0
	for rank in ranks:
		worst_rank = max(worst_rank, rank)
	
	var text := ""
	if RankCalculator.grade(worst_rank) == RankCalculator.NO_GRADE:
		text += "Try to get a B- or better on every level. Good luck!"
	elif RankCalculator.grade(worst_rank) == RankCalculator.HIGHEST_GRADE:
		text += "You are a master of Turbo Fat!"
	else:
		text += "Wow, you beat every level! Good job!"
		text += "\n\nImprove your level scores to earn more stars and increase your grade. Good luck!"
	
	$MarginContainer/Label.text = text
