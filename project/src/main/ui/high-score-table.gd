class_name HighScoreTable
extends VBoxContainer
## Table which displays the player's high scores in practice mode.
##
## Scores are separated by mode and difficulty. We also keep daily scores separate.

## if true, only performances with today's date are included
export (bool) var daily := false setget set_daily

## level to display high scores for
var _level: LevelSettings setget set_level

onready var _label: Label = $Label
onready var _grid_container: GridContainer = $GridContainer

func _ready() -> void:
	_refresh_contents()


## Toggles this high score table between 'Today's Best' and 'All-time Best'
func set_daily(new_daily: bool) -> void:
	daily = new_daily
	_refresh_contents()


## Sets the level to display high scores for.
func set_level(new_level: LevelSettings) -> void:
	_level = new_level
	_refresh_contents()


## Clears all rows in the grid container.
func _clear_rows() -> void:
	_label.text = tr("Today's Best") if daily else tr("All-time Best")
	for child_obj in _grid_container.get_children():
		var child: Node = child_obj
		child.queue_free()


## Adds new rows to the grid container.
func _add_rows() -> void:
	if not _level:
		return
	
	for best_result in PlayerData.level_history.best_results(_level.id, daily):
		_add_row(rank_result_row(best_result, daily))


## Clears and regenerates the cells in the grid container.
func _refresh_contents() -> void:
	if is_inside_tree():
		_clear_rows()
		_add_rows()


## Adds a new row to the grid container.
func _add_row(items: Array) -> void:
	for item_obj in items:
		var item: String = item_obj
		var item_label := Label.new()
		item_label.text = item
		item_label.size_flags_horizontal = Label.SIZE_EXPAND
		$GridContainer.add_child(item_label)


## Returns a table row for the specified rank result.
##
## This table row includes a timestamp, number of line clears, score/time, and grade.
static func rank_result_row(result: RankResult, daily_result: bool = false) -> Array:
	var row := []

	# append timestamp
	if daily_result:
		row.append("%02d:%02d" % [
				result.timestamp["hour"],
				result.timestamp["minute"],
			])
	else:
		row.append("%04d-%02d-%02d" % [
				result.timestamp["year"],
				result.timestamp["month"],
				result.timestamp["day"],
			])

	# append lines
	row.append(StringUtils.comma_sep(result.lines))

	# append score/time and grade
	if result.compare == "-seconds":
		var seconds_string := StringUtils.format_duration(result.seconds)
		if result.lost:
			seconds_string = "-"
		row.append(seconds_string)
		row.append(Ranks.grade(result.seconds_rank))
	else:
		var score_string := StringUtils.format_money(result.score)
		if result.lost:
			score_string += "*"
		row.append(score_string)
		row.append(Ranks.grade(result.score_rank))

	return row
