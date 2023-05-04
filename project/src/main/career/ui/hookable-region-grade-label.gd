class_name HookableRegionGradeLabel
extends Node2D
## Shows a grade label for a specific region.
##
## If a region has been cleared, we show something like 'S' or 'B+'. If it hasn't been cleared we show nothing.

## region button this grade label applies to
var button: RegionSelectButton: set = set_button

@onready var _grade_label: GradeLabel = $GradeLabel

## Preemptively initializes onready variables to avoid null references.
func _enter_tree() -> void:
	_grade_label = $GradeLabel


## Assigns this label's button, and updates the label's appearance.
func set_button(new_button: RegionSelectButton) -> void:
	if button == new_button:
		# skip the unnecessary overhead in hooking/unhooking signals and refreshing our appearance
		return
	
	if button:
		button.grade_hook.remote_path = null
		button.tree_exited.disconnect(_on_LevelSelectButton_tree_exited)
	
	button = new_button
	
	button.grade_hook.remote_path = button.grade_hook.get_path_to(self)
	button.tree_exited.connect(_on_LevelSelectButton_tree_exited)
	
	_refresh_appearance()


## Updates the text/icon based on the region's status.
##
## If the region has been completed we show something like 'S' or 'B+'. If it hasn't been cleared we show nothing.
func _refresh_appearance() -> void:
	if button.completion_percent == 1.0:
		# region has been cleared; show text
		_grade_label.visible = true
		var worst_rank := 0.0
		for rank in button.ranks:
			worst_rank = max(worst_rank, rank)
		_refresh_grade_text(worst_rank)
	else:
		# region has not been cleared; show nothing
		_grade_label.visible = false


## Updates the text based on the player's grade on a level.
func _refresh_grade_text(rank: float) -> void:
	_grade_label.visible = true
	_grade_label.text = RankCalculator.grade(rank)
	_grade_label.refresh_color_from_text()


func _on_LevelSelectButton_tree_exited() -> void:
	queue_free()
