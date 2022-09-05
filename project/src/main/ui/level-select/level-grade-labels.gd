extends Control
## Manages grade labels which overlay level select buttons.
##
## These grade labels appear in the corner and show the player's performance.

export (PackedScene) var GradeLabelScene: PackedScene

## key: (LevelSelectButton) button
## value: (HookableLevelGradeLabel) label for the specified button
var _labels_by_button: Dictionary

## Add a grade label for the specified button.
func add_label(button: LevelSelectButton) -> void:
	if _labels_by_button.has(button):
		# avoid adding two labels for the same button
		return
	
	var new_label: HookableLevelGradeLabel = GradeLabelScene.instance()
	add_child(new_label)
	_labels_by_button[button] = new_label
	new_label.button = button
	
	button.connect("tree_exited", self, "_on_LevelSelectButton_tree_exited", [button])


func _on_LevelButtons_button_added(button: LevelSelectButton) -> void:
	add_label(button)


func _on_LevelSelectButton_tree_exited(button: LevelSelectButton) -> void:
	_labels_by_button.erase(button)
