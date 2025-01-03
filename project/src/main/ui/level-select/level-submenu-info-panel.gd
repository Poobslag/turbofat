extends Panel
## Panel on the level select screen which summarizes level details.
##
## This includes details such as the level's duration, difficulty, and the player's high score.

var text: String setget set_text

onready var _label := $MarginContainer/Label

func _ready() -> void:
	_refresh_text()


func set_text(new_text: String) -> void:
	text = new_text
	_refresh_text()


func _refresh_text() -> void:
	if _label:
		_label.text = text


## Updates the text box to show the level's information.
func _update_unlocked_level_text(settings: LevelSettings) -> void:
	var new_text := ""
	var difficulty_string := tr("Unknown")
	match settings.get_difficulty():
		"T", "0", "1", "2": difficulty_string = tr("Very Easy")
		"3", "4", "5", "6": difficulty_string = tr("Easy")
		"7", "8", "9", "A0", "A1": difficulty_string = tr("Normal")
		"A2", "A3", "A4": difficulty_string = tr("Hard")
		"A5", "A6", "A7", "A8", "A9", "AA", "AB", "AC", "AD": difficulty_string = tr("Very Hard")
		"AE", "AF", "F0", "F1": difficulty_string = tr("Expert")
		"FA", "FB", "FC": difficulty_string = tr("Very Expert")
		"FD", "FE", "FF", "FFF": difficulty_string = tr("Master")
	if settings.other.tutorial:
		difficulty_string = tr("Tutorial")
	new_text += tr("Difficulty: %s") % [difficulty_string]
	new_text += "\n"
	
	var duration_string: String
	var duration: int
	if settings.finish_condition.type == Milestone.TIME_OVER:
		duration = settings.finish_condition.value
	else:
		duration = settings.rank.duration
	
	duration_string = StringUtils.format_duration(duration)
	
	new_text += tr("Duration: %s") % [duration_string]
	new_text += "\n"
	
	var prev_result := PlayerData.level_history.prev_result(settings.id)
	if prev_result:
		new_text += tr("New: %s") % [PoolStringArray(HighScoreTable.rank_result_row(prev_result)).join("   ")]
	new_text += "\n"
	var best_result := PlayerData.level_history.best_result(settings.id)
	if best_result:
		new_text += tr("Top: %s") % [PoolStringArray(HighScoreTable.rank_result_row(best_result)).join("   ")]
	set_text(new_text)


## When an unlocked level is selected, we display some statistics for that level.
func _on_LevelButtons_unlocked_level_focused(settings: LevelSettings) -> void:
	_update_unlocked_level_text(settings)


## When a locked level is selected, we clear out the info panel.
func _on_LevelButtons_locked_level_focused(_settings: LevelSettings) -> void:
	set_text("")
