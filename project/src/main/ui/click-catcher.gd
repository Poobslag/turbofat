extends Control
## Extends the parent node's input area.
##
## By default, small controls like sliders are difficult to interact with, particularly on mobile devices. By
## assigning a margin to this node, it will relay mouse press events outside the parent control.

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		get_parent()._gui_input(event)
