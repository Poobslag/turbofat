extends Control
"""
Manages grade labels which overlay level select buttons.

These grade labels appear in the corner and show the player's performance.
"""

export (PackedScene) var GradeLabelScene: PackedScene

# key: LevelSelectButton instance
# value: HookableGradeLabel for the specified button
var _labels_by_button: Dictionary

func _ready() -> void:
	for button_obj in get_tree().get_nodes_in_group("level_select_buttons"):
		_add_label(button_obj)


"""
Add a grade label for the specified button.
"""
func _add_label(button: LevelSelectButton) -> void:
	if _labels_by_button.has(button):
		# avoid adding two labels for the same button
		return
	
	var new_label: HookableGradeLabel = GradeLabelScene.instance()
	add_child(new_label)
	_labels_by_button[button] = new_label
	new_label.button = button


func _on_LevelButtons_button_added(button: LevelSelectButton) -> void:
	_add_label(button)
