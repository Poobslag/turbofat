extends Panel
"""
A panel on the level select screen which shows level descriptions.
"""

"""
When an unlocked level is selected, we display the level's description.
"""
func _on_LevelButtons_unlocked_level_selected(settings: LevelSettings) -> void:
	$MarginContainer/Label.text = settings.description


"""
When a locked level is selected, we tell the player how to unlock it.
"""
func _on_LevelButtons_locked_level_selected(level_lock: LevelLock) -> void:
	var text := ""
	match level_lock.status:
		LevelLock.STATUS_SOFT_LOCK:
			var level_count := StringUtils.english_number(level_lock.keys_needed)
			text += "Clear %s more levels to unlock this. You can do it!" % [level_count]
			text = text.replace("one more levels", "one more level")
		LevelLock.STATUS_HARD_LOCK:
			text += "You can't unlock this level yet."
			text += "\n\n...Go unlock some other levels first. Patience is key!"
		_:
			push_warning("Unexpected lock status: %s" % [level_lock.status])
	
	$MarginContainer/Label.text = text


"""
When the 'overall' button is selected, we summarize the player's progress.
"""
func _on_LevelButtons_overall_selected(ranks: Array) -> void:
	# calculate the worst rank
	var worst_rank := 0.0
	for rank in ranks:
		worst_rank = max(worst_rank, rank)
	
	var text := ""
	match RankCalculator.grade(worst_rank):
		RankCalculator.NO_GRADE:
			text += "Try to get a B- or better on every level. Good luck!"
		RankCalculator.HIGHEST_GRADE:
			text += "You are a master of Turbo Fat!"
		_:
			text += "Wow, you beat every level! Good job!"
			text += "\n\nImprove your level scores to earn more stars and increase your grade. Good luck!"
	
	$MarginContainer/Label.text = text
