"""
A SmoothPath which renders an outline around another SmoothPath. Tracks the target path's curves and updates this
outline's curves accordingly.
"""
tool
extends SmoothPath

onready var _parent = get_node("..")

func _process(_delta: float) -> void:
	if _parent != null:
		curve = _parent.curve
		update()
