extends Panel
## A panel on the level select screen which shows level descriptions.

var text: String setget set_text

onready var _label := $MarginContainer/Label

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func update_unlocked_level_text(settings: LevelSettings) -> void:
	set_text(settings.description)


func _refresh_text() -> void:
	if _label:
		_label.text = text


func _update_tutorial_world_text(ranks: Array) -> void:
	var new_text := ""
	
	# calculate the percent of tutorials which the player hasn't cleared
	var worst_rank_count := 0
	for rank in ranks:
		if RankCalculator.grade(rank) == RankCalculator.NO_GRADE:
			worst_rank_count += 1
	var progress_pct := float(ranks.size() - worst_rank_count) / ranks.size()
	
	if progress_pct < 1.00:
		new_text = tr("Don't worry about completing all the tutorials right away! You know more than you realize.")
	else:
		new_text = tr("Nice, you've completed the tutorials. Now you're ready to play the game!")
	set_text(new_text)


func _update_world_text(ranks: Array) -> void:
	var new_text := ""
	
	# calculate the worst rank
	var worst_rank := 0.0
	for rank in ranks:
		worst_rank = max(worst_rank, rank)
	
	match RankCalculator.grade(worst_rank):
		RankCalculator.NO_GRADE:
			new_text += tr("Try to get a B- or better on every level. Good luck!")
		RankCalculator.HIGHEST_GRADE:
			new_text += tr("You are a master of Turbo Fat!")
		_:
			new_text += tr("Wow, you beat every level! Good job!")
			new_text += "\n\n" + tr("Improve your level scores to earn more stars and increase your grade. Good luck!")
	set_text(new_text)


## When an unlocked level is selected, we display the level's description.
func _on_LevelButtons_unlocked_level_selected(_level_lock: LevelLock, settings: LevelSettings) -> void:
	update_unlocked_level_text(settings)


## When a locked level is selected, we tell the player how to unlock it.
func _on_LevelButtons_locked_level_selected(level_lock: LevelLock, settings: LevelSettings) -> void:
	var new_text := ""
	match level_lock.status:
		LevelLock.STATUS_SOFT_LOCK:
			if level_lock.keys_needed == 1:
				new_text += tr("Clear one more level to unlock this. You can do it!")
			else:
				var level_count := StringUtils.english_number(level_lock.keys_needed)
				new_text += tr("Clear %s more levels to unlock this. You can do it!") % [level_count]
		_:
			push_warning("Unexpected lock status: %s" % [level_lock.status])
	
	# change 'Clear one more level' to 'Finish one more tutorial'
	if settings.other.tutorial:
		new_text = new_text.replace("level", "tutorial")
		new_text = new_text.replace("Clear", "Finish")
	set_text(new_text)


## When the 'overall' button is selected, we summarize the player's progress.
func _on_LevelButtons_overall_selected(world_id: String, ranks: Array) -> void:
	if world_id == LevelLibrary.TUTORIAL_WORLD_ID:
		_update_tutorial_world_text(ranks)
	else:
		_update_world_text(ranks)
