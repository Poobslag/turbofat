class_name LevelSelectButton
extends Button
"""
A button on the level select screen which launches a scenario.
"""

# emitted when a scenario is launched.
signal scenario_started

# short levels have smaller buttons; long levels have larger buttons
enum LevelSize {
	SHORT,
	MEDIUM,
	LONG
}

const SHORT := LevelSize.SHORT
const MEDIUM := LevelSize.MEDIUM
const LONG := LevelSize.LONG
const VERTICAL_SPACING := 6

# the duration of the level; this affects the button size
var level_duration: int = LevelSize.MEDIUM setget set_level_duration

# the width of the column this button is in
var level_column_width: int = 120

# 'true' if this button just received focus this frame. a mouse click which grants focus doesn't emit a 'scenario
# started' event
var _focus_just_entered := false

# 'true' if the 'scenario started' signal should be emitted in response to a button click.
var _emit_scenario_started := false

func _ready() -> void:
	_refresh_level_duration()


func _process(_delta: float) -> void:
	_focus_just_entered = false


func set_level_duration(new_level_duration: int) -> void:
	level_duration = new_level_duration
	_refresh_level_duration()


func _refresh_level_duration() -> void:
	match level_duration:
		LevelSize.SHORT: rect_min_size.y = level_column_width * 0.5
		LevelSize.MEDIUM: rect_min_size.y = level_column_width * 0.75 + VERTICAL_SPACING * 0.5
		LevelSize.LONG: rect_min_size.y = level_column_width + VERTICAL_SPACING


func _on_pressed() -> void:
	if _emit_scenario_started:
		_emit_scenario_started = false
		emit_signal("scenario_started")


func _on_focus_entered() -> void:
	_focus_just_entered = true


func _on_button_down() -> void:
	if _focus_just_entered:
		pass
	else:
		_emit_scenario_started = true
