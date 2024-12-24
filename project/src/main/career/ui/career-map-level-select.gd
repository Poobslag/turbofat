class_name CareerLevelSelect
extends CanvasLayer
## UI components for career mode's level select buttons.

signal level_button_focused(button_index)

export (PackedScene) var LevelSelectButtonScene: PackedScene
export (PackedScene) var HardcoreLevelSelectButtonScene: PackedScene
export (PackedScene) var BossLevelSelectButtonScene: PackedScene
export (PackedScene) var HardcoreBossLevelSelectButtonScene: PackedScene

var _prev_focused_level_button_index := -1

onready var _control := $VBoxContainer/LevelButtons
onready var _grade_labels := $VBoxContainer/LevelButtons/GradeLabels
onready var _level_buttons_container := $VBoxContainer/LevelButtons/HBoxContainer

func _ready() -> void:
	# If the day is over, we show the career map briefly so the player can see their progress, but we hide the level
	# select buttons.
	if not PlayerData.career.can_play_more_levels():
		_control.visible = false


## Returns the index of the currently focused level button, or -1 if none is selected.
##
## For a boss level where only one level is available, this will return '0' if the level button is selected.
func focused_level_button_index() -> int:
	var focused_child_index := -1
	for child_index in range(_level_buttons_container.get_child_count()):
		if _level_buttons_container.get_child(child_index).has_focus():
			focused_child_index = child_index
			break
	_prev_focused_level_button_index = focused_child_index
	return _prev_focused_level_button_index


## Removes all level select button nodes from the scene tree.
func clear_level_select_buttons() -> void:
	for child in _level_buttons_container.get_children():
		# Immediately remove the child. Our business logic assumes the first child of the level_buttons_container is
		# the leftmost child, so having freed children introduces bugs
		_level_buttons_container.remove_child(child)
		child.queue_free()


## Adds a new level select button to the scene tree.
##
## Parameters:
## 	'settings': The level settings which control the button's appearance.
func add_level_select_button(settings: LevelSettings) -> LevelSelectButton:
	var button: LevelSelectButton
	if PlayerData.career.is_boss_level() and settings.lose_condition.top_out == 1:
		button = HardcoreBossLevelSelectButtonScene.instance()
	elif PlayerData.career.is_boss_level():
		button = BossLevelSelectButtonScene.instance()
	elif settings.lose_condition.top_out == 1:
		button = HardcoreLevelSelectButtonScene.instance()
	else:
		button = LevelSelectButtonScene.instance()
	button.decorate_for_level(PlayerData.career.current_region(), settings, true)
	button.rect_min_size = Vector2(200, 120)
	button.size_flags_horizontal = 6
	button.size_flags_vertical = 4
	
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
	if not is_inside_tree():
		return
	
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
