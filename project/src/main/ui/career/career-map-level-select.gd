class_name CareerLevelSelect
extends CanvasLayer
## UI components for career mode's level select buttons.

signal level_button_focused(button_index)

export (PackedScene) var LevelSelectButtonScene: PackedScene

var _duration_calculator := DurationCalculator.new()

onready var _control := $Control
onready var _grade_labels := $Control/GradeLabels
onready var _level_buttons_container := $Control/LevelButtons

## Returns the index of the currently focused level button, or -1 if none is selected.
##
## For a boss level where only one level is available, this will return '0' if the level button is selected.
func focused_level_button_index() -> int:
	return _level_buttons_container.get_children().find(_control.get_focus_owner())


## Removes all level select button nodes from the scene tree.
func clear_level_select_buttons() -> void:
	for child in _level_buttons_container.get_children():
		child.queue_free()


## Adds a new level select button to the scene tree.
##
## Parameters:
## 	'settings': The level settings which control the button's appearance.
func add_level_select_button(settings: LevelSettings) -> LevelSelectButton:
	var button: LevelSelectButton = LevelSelectButtonScene.instance()
	button.rect_min_size = Vector2(200, 120)
	button.size_flags_horizontal = 6
	button.size_flags_vertical = 4
	button.level_title = settings.title
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


func _on_LevelSelectButton_focus_entered(button_index: int) -> void:
	emit_signal("level_button_focused", button_index)


func _on_SettingsMenu_show() -> void:
	_control.hide()


func _on_SettingsMenu_hide() -> void:
	_control.show()
