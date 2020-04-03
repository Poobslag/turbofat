tool
extends SmoothPath
"""
A SmoothPath which renders an outline around another SmoothPath. Tracks the target path's curves and updates this
outline's curves accordingly.
"""

onready var _parent = get_parent()

func _process(_delta: float) -> void:
	if _parent:
		curve = _parent.curve
		update()
