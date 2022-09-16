extends Node
## Non-interactive demo which shows the different labels and icons for level buttons.

export (PackedScene) var LevelButtonScene: PackedScene

onready var _grid_container := $Control/GridContainer
onready var _grade_labels := $Control/GradeLabels

func _ready() -> void:
	PlayerData.level_history.reset()
	
	# add buttons for different ranks
	for rank in [
			0.0,
			4.0,
			10.0,
			20.0,
			36.0,
			44.0,
			60.0,
			80.0]:
		var button := _button()
		var rank_result := RankResult.new()
		rank_result.score_rank = rank
		PlayerData.level_history.add_result(button.level_id, rank_result)
		_add_button(button)
	
	for lock_status in [
			LevelSelectButton.STATUS_KEY,
			LevelSelectButton.STATUS_CROWN,
			LevelSelectButton.STATUS_CLEARED,
			LevelSelectButton.STATUS_LOCKED]:
		var button := _button()
		button.lock_status = lock_status
		_add_button(button)


## Returns a new LevelSelectButton with a default generated level.
func _button() -> LevelSelectButton:
	var button_index := _grade_labels.get_child_count()
	
	var button: LevelSelectButton = LevelButtonScene.instance()
	button.level_id = "level_%03d" % [button_index]
	button.level_name = "Level %03d" % [button_index]
	
	return button


## Adds the specified button and generates a grade label.
func _add_button(button: LevelSelectButton) -> void:
	_grid_container.add_child(button)
	_grade_labels.add_label(button)
