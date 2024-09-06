tool
class_name BarGraphGoal
extends Control
## Goal shown in the results screen's bar graph.
##
## Each goal shows something like 'SS ¥1,200'.

export (String) var text: String setget set_text

onready var _goal_label := $GoalLabel

func _ready() -> void:
	_refresh()


## Updates the goal label text.
func _refresh() -> void:
	if not is_inside_tree():
		return
	
	_goal_label.text = text


func set_text(new_text: String) -> void:
	text = new_text
	_refresh()
