class_name CareerLevelSelect
extends CanvasLayer
## UI components for career mode's level select buttons.

signal level_button_focused(button_index)

export (PackedScene) var LevelSelectButtonScene: PackedScene

var _duration_calculator := DurationCalculator.new()
var _prev_focused_level_button_index := -1

onready var _control := $Control
onready var _grade_labels := $Control/GradeLabels
onready var _level_buttons_container := $Control/LevelButtons

## Returns the index of the currently focused level button, or -1 if none is selected.
##
## For a boss level where only one level is available, this will return '0' if the level button is selected.
func focused_level_button_index() -> int:
	_prev_focused_level_button_index = _level_buttons_container.get_children().find(_control.get_focus_owner())
	return _prev_focused_level_button_index


## Removes all level select button nodes from the scene tree.
func clear_level_select_buttons() -> void:
	for child in _level_buttons_container.get_children():
		child.queue_free()
		
		# Immediately remove the child. Our business logic assumes the first child of the level_buttons_container is
		# the leftmost child, so having freed children introduces bugs
		_level_buttons_container.remove_child(child)


## Adds a new level select button to the scene tree.
##
## Parameters:
## 	'settings': The level settings which control the button's appearance.
func add_level_select_button(settings: LevelSettings) -> LevelSelectButton:
	var button: LevelSelectButton = LevelSelectButtonScene.instance()
	button.rect_min_size = Vector2(200, 120)
	button.size_flags_horizontal = 6
	button.size_flags_vertical = 4
	button.level_name = settings.name
	button.level_id = settings.id
	var duration := _duration_calculator.duration(settings)
	if duration < 100:
		button.level_duration = LevelSelectButton.SHORT
	elif duration < 200:
		button.level_duration = LevelSelectButton.MEDIUM
	else:
		button.level_duration = LevelSelectButton.LONG
	
	button.connect("focus_entered", self, "_on_LevelSelectButton_focus_entered", \
			[_level_buttons_container.get_child_count()])
	_level_buttons_container.add_child(button)
	
	_grade_labels.add_label(button)
	return button


## Assigns focus to a level select button to allow keyboard support.
##
## Restores focus to the previously selected level select button, if one was selected. Otherwise, assigns focus to the
## rightmost button.
func focus_button() -> void:
	var level_select_buttons := get_tree().get_nodes_in_group("level_select_buttons")
	var node_to_focus: Node
	
	if _prev_focused_level_button_index != -1 and _prev_focused_level_button_index < level_select_buttons.size():
		node_to_focus = level_select_buttons[_prev_focused_level_button_index]
	elif level_select_buttons:
		node_to_focus = level_select_buttons.back()
	
	if node_to_focus:
		node_to_focus.grab_focus()


func _on_LevelSelectButton_focus_entered(button_index: int) -> void:
	emit_signal("level_button_focused", button_index)


func _on_SettingsMenu_show() -> void:
	_control.hide()


func _on_SettingsMenu_hide() -> void:
	_control.show()
	if not _control.get_focus_owner():
		focus_button()
