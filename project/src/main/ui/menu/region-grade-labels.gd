extends Control
## Manages grade labels which overlay region select buttons.
##
## These grade labels appear in the corner and show the player's performance.

export (PackedScene) var GradeLabelScene: PackedScene

## key: (RegionSelectButton) button instance
## value: (HookableRegionGradeLabel) label for the specified button
var _labels_by_button: Dictionary

## Add a grade label for the specified button.
func add_label(button: RegionSelectButton) -> void:
	if _labels_by_button.has(button):
		# avoid adding two labels for the same button
		return
	
	var new_label: HookableRegionGradeLabel = GradeLabelScene.instance()
	add_child(new_label)
	_labels_by_button[button] = new_label
	new_label.button = button
	
	button.connect("tree_exited", self, "_on_RegionSelectButton_tree_exited", [button])


func _on_RegionButtons_button_added(button: RegionSelectButton) -> void:
	add_label(button)


func _on_RegionSelectButton_tree_exited(button: RegionSelectButton) -> void:
	_labels_by_button.erase(button)
